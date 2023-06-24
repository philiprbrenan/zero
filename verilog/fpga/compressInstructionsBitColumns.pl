#!/usr/bin/perl -I/home/phil/perl/cpan/DataTableText/lib/
#-------------------------------------------------------------------------------
# Compress instructions
# Philip R Brenan at appaapps dot com, Appa Apps Ltd Inc., 2023
#-------------------------------------------------------------------------------
use v5.30;
use warnings FATAL => qw(all);
use strict;
use Carp;
use Data::Dump qw(dump);
use Data::Table::Text qw(:all);
use Test::More qw(no_plan);

my $instructionsAsBits = eval readFile q(/home/phil/perl/cpan/ZeroEmulator/verilog/fpga/tests/BTree/test.txt);
my @instructionsAsBits = @$instructionsAsBits;

my sub column($)                                                                # Get one column of bits as a string
 {my ($col) = @_;                                                               # Column to fetch
  my @b;
  for my $i(@instructionsAsBits)
   {my $b = substr($i, $col, 1);
    push @b, $b;
   }
  join "", @b;
 }

my sub invert($)                                                                # Invert a bit string
 {my ($bits) = @_;                                                              # Bit string
  my @b;
  for my $b(split //, $bits)
   {push @b, $b ? '0' : '1';
   }
  join "", @b;
 }

my %b; my %i; my %m;                                                            # Previous bits, previous inversions, mask for columns that must remain
my $z = 0; my $o = 0; my $e = 0; my $i = 0; my $d = 0; my $D = 0;

for my $col(0..length($instructionsAsBits[0])-1)
 {my $b = column($col);
  my $i = invert($b);

  my $B = $col ? column($col - 1) : undef;
  my $I = $col ? invert($B) : '';

  if    ($b =~ m(\A0+\Z))        {++$z}
  elsif ($b =~ m(\A1+\Z))        {++$o}
  elsif ($b{$b})                 {++$d}
  elsif ($i{$b})                 {++$D}
  elsif ($B and $b eq $B)        {++$e}
  elsif ($B and $b eq invert $B) {++$i}
  else {$m{$col} = 1}

  $b{$b}++;
  $i{$i}++;
 }

for   my $i(@instructionsAsBits)
 {my @b;
  for my $col(0..length($instructionsAsBits[0])-1)
   {if ($m{$col})
     {my $b = substr($i, $col, 1);
      push @b, $b;
     }
   }
  say STDERR join "", @b;
 }

my $n = $z + $o + $e + $i + $d + $D; my $N = 256 - $n;
say STDERR "AAAA z=$z  o=$o  e=$e  i=$i  d=$d  D=$D  n=$n  N=$N";
