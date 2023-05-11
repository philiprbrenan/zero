#!/usr/bin/perl -Ilib -I../lib
#-------------------------------------------------------------------------------
# Test Zero Emulator
# Philip R Brenan at appaapps dot com, Appa Apps Ltd Inc., 2023
#-------------------------------------------------------------------------------
use v5.30;
use warnings FATAL => qw(all);
use strict;
use Zero::Emulator qw(:all);
use Test::More qw(no_plan);
use Data::Dump qw(dump);

Test::More->builder->output("/dev/null");

if (1)
 {Start 1;

  my $a = Array "aaa";
  Mov [$a, 0, "aaa"], 1;
  Out "hello World";

  my $e = Execute;

  is_deeply $e->out, ["hello World"];
  is_deeply $e->memory, { 1 => bless([1], "aaa") };
 }

done_testing;
