#!/usr/bin/perl -Ilib -I../lib
#-------------------------------------------------------------------------------
# Zero assembler programming language of in situ selection sort
# Philip R Brenan at appaapps dot com, Appa Apps Ltd Inc., 2023
#-------------------------------------------------------------------------------
use v5.30;
use warnings FATAL => qw(all);
use strict;
use Zero::Emulator qw(:all);
use Test::More tests=>5;

sub selectionSort($$)                                                           # As described at: https://en.wikipedia.org/wiki/Selection_sort
 {my ($array, $name) = @_;                                                      # Array, name of array memory

  my $N = ArraySize $array, $name;                                              # Size of array

  For                                                                           # Outer loop
   {my ($i) = @_;
    my  $a  = Mov [$array, \$i, $name];                                         # Index into array

    For                                                                         # Inner loop
     {my ($j) = @_;
      my  $b  = Mov [$array, \$j, $name];

      IfGt $a, $b,
      Then                                                                      # Swap elements to place smaller element lower in array
       {Mov [$array, \$i, $name], $b;
        Mov [$array, \$j, $name], $a;
        Mov $a, $b;
       };
     } [$i, $N];                                                                # Move up through array
   } $N;
 }

if (1)                                                                          # Small array
 {Start 1;
  my $a = Array "array";
  my @a = qw(6 8 4 2 1 3 5 7);
  Push $a, $_ for @a;                                                           # Load array

  selectionSort($a, "array");                                                   # Sort

  ForArray                                                                      # Print array
   {my ($i, $e) = @_;
    Out $e;
   } $a, "array";

  my $e = Execute(suppressOutput=>1);                                           # Execute assembler program
  is_deeply $e->out, [1..8];                                                    # Check output
  is_deeply $e->count,  328;                                                    # Instructions executed
  is_deeply $e->counts, {                                                       # Counts of each instruction type executed
  array     =>   1,
  arraySize =>   2,
  inc       =>  52,
  jGe       =>  62,
  jLe       =>  36,
  jmp       =>  52,
  mov       => 107,
  out       =>   8,
  push      =>   8};
 }

if (1)                                                                          # Reversed array 4 times larger
 {Start 1;
  my $a = Array "array";
  my @a = reverse 1..32;
  Push $a, $_ for @a;

  selectionSort($a, "array");

  ForArray
   {my ($i, $e, $Check, $Next, $End) = @_;
    Out $e;
   } $a, "array";

  my $e = Execute(suppressOutput=>1);                                           # Execute assembler program

  is_deeply $e->out, [1..32];                                                   # Check output
  is_deeply $e->count, 4519;                                                    # Approximately 4*4== 16 times bigger
 }
