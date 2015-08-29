#!/usr/bin/perl

use strict;
use warnings;

use Encode;
use utf8;

use DBI;


my $filename = shift;

my $dbh = DBI->connect("dbi:SQLite:dbname=test.db");

my $stmt = "select * from suica order by id asc";
my $sth  = $dbh->prepare($stmt);
$sth -> execute;

while(my @row = $sth->fetchrow_array){
    print join '|',@row;
    print "\n";
}

$dbh->disconnect;