#!/usr/bin/perl

#スイ家計簿の出力ファイルからsqliteのデータベースに格納する

use strict;
use warnings;

use Encode;
use utf8;

use DBI;

use Text::CSV_XS;

my $filename = shift;

my @fields = qw/id date agency s_station s_comp s_line e_station e_comp e_line fare balance /;

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
                 'balance'   => 'text'
                 };



my $dbh = DBI->connect("dbi:SQLite:dbname=test.db");

my $fieldlist = join ',',@fields;

my $typelist;
foreach (@fields){
    $typelist .= $_." ".$data_type->{$_}.",";
}

$dbh->do("create table if not exists suica ($fieldlist)");

open my $fh,'<',$filename or die "$!";

my $csv = Text::CSV_XS-> new({binary => 1});

while(my $columns = $csv->getline($fh)){

    #タイトル行を飛ばす
    next if(($columns->[0]) eq "ID");
    
    my $eles = {};
    foreach my $i(0 .. $#fields){
        $eles->{$fields[$i]} = $columns->[$i];
    }
    my $valuelist = $eles->{'id'};
    foreach my $i(1..$#fields){
        $valuelist .= ",\'".decode('Shift_JIS',$eles->{$fields[$i]})."\'";
    }
    #print "insert into suica ($fieldlist) values ($valuelist)\n";
    $dbh->do("insert into suica ($fieldlist) values ($valuelist)");
}

$csv->eof;

$dbh->disconnect;