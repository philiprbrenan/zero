#!/usr/bin/perl -I/home/phil/perl/cpan/DataTableText/lib/
#-------------------------------------------------------------------------------
# Build Conflicting updates as a gowin project
# Philip R Brenan at gmail dot com, Appa Apps Ltd Inc., 2023
#-------------------------------------------------------------------------------
use v5.28;
use warnings FATAL => qw(all);
use strict;
use Data::Dump qw(dump);
use Data::Table::Text qw(:all);

fpgaGowin;
