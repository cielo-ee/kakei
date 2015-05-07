#!/usr/bin/perl

use strict;
use warnings;

use Encode;
use utf8;

use Text::CSV_XS;

my $filename = shift;

my @fields = qw/id date agency s_station s_comp s_line e_station e_station e_comp e_line fare balance /;


open my $fh,'<',$filename or die "$!";

my $csv = Text::CSV_XS-> new({binary => 1});

while(my $columns = $csv->getline($fh)){
    print join "\t",@$columns;
    print "\n";
}

$csv->eof;
