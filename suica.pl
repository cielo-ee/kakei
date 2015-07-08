#!/usr/bin/perl

use strict;
use warnings;

use Encode;
use utf8;

use DBI;

use Text::CSV_XS;

my $filename = shift;

my @fields = qw/id date agency s_station s_comp s_line e_station e_comp e_line fare balance /;


my $dbh = DBI->connect("dbi:SQLite:dbname=test.db");

my $fieldlist = join ',',@fields;
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
        $valuelist .= ",\'".$eles->{$fields[$i]}."\'";
    }
    #print "insert into suica ($fieldlist) values ($valuelist)\n";
    $dbh->do("insert into suica ($fieldlist) values ($valuelist)");
}

$csv->eof;

$dbh->disconnect;