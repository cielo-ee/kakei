#!/usr/bin/perl

#スイ家計簿の出力ファイルからsqliteのデータベースに格納する

use strict;
use warnings;

use Encode;
use utf8;

use DBI;

use Text::CSV_XS;

my $filename = shift;
my ($mday,$mon,$year) = (localtime(time))[3..5];
$year += 1900;
$mon++;
my $date = sprintf "%d/%02d/%02d",$year,$mon,$mday;
     
my @main_fields = qw/id date agency s_station s_comp s_line e_station e_comp e_line fare balance /; #CSVに含まれているフィールド
my @option_fields = qw/filename registration_date /;
my @fields = (@main_fields,@option_fields);

my $data_type = {'id'        => 'int',
                 'date'      => 'text',
                 'agency'    => 'text',
                 's_station' => 'text',
                 's_comp'    => 'text',
                 's_line'    => 'text',
                 'e_station' => 'text',
                 'e_comp'    => 'text',
                 'e_line'    => 'text',
                 'fare'      => 'text',
                 'balance'   => 'text',

                 'filename'  => 'text default null',
                 'registration_date' => 'text default null'
                 };



my $autoupdate = 1;

my $dbh = DBI->connect("dbi:SQLite:dbname=test.db");

my $fieldlist = join ',',@fields;






$dbh->do("create table if not exists suica ($fieldlist,primary key(id,date))");

open my $fh,'<',$filename or die "$!";

my $csv = Text::CSV_XS-> new({binary => 1});

while(my $columns = $csv->getline($fh)){
    #ハッシュにマッピング
    my $eles;
    @$eles{@fields} = @$columns;
    $eles->{'filename'} = $filename;
    $eles->{'registration_date'}     = $date;

    #タイトル行を飛ばす
    next if($eles->{'id'} eq "ID");

    my $valuelist = $eles->{'id'};
    foreach my $i(1..$#fields){
        my $value = decode('UTF-8',$eles->{$fields[$i]});
        $value =~ s/￥|,//g if($fields[$i] eq 'fare');
        $value =~ s/￥|,//g if($fields[$i] eq 'balance');
        $valuelist .= ",\'".$value."\'";
    }

    #重複データを検査する
    my $stmt = "select * from suica where id = $columns->[0]";
    my $sth  = $dbh -> prepare($stmt);
    $sth -> execute;
    next if($sth->fetchrow_array);
    
    $dbh->do("insert into suica ($fieldlist) values ($valuelist)");
}

$csv->eof;

$dbh->disconnect;