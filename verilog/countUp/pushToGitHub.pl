#!/usr/bin/perl -I/home/phil/perl/cpan/DataTableText/lib/
#-------------------------------------------------------------------------------
# Build a gowin project
# Philip R Brenan at gmail dot com, Appa Apps Ltd Inc., 2023
#-------------------------------------------------------------------------------
use v5.28;
use warnings FATAL => qw(all);
use strict;
use Data::Dump qw(dump);
use Data::Table::Text qw(:all);

if (-e q(/home/phil/))
 {fpgaGowin;
 }
else
 {fpgaGowin bin=>q(oss-cad-suite/bin/);
 }
