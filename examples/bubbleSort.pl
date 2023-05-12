#!/usr/bin/perl -Ilib -I../lib
#-------------------------------------------------------------------------------
# Zero assembler programming language of in situ bubble sort
# Philip R Brenan at appaapps dot com, Appa Apps Ltd Inc., 2023
#-------------------------------------------------------------------------------
use v5.30;
use warnings FATAL => qw(all);
use strict;
use Zero::Emulator qw(:all);
use Test::More tests=>5;

sub bubbleSort($$)                                                              # As described at: https://en.wikipedia.org/wiki/Bubble_sort
 {my ($array, $name) = @_;                                                      # Array, name of array memory

  my $N = ArraySize $array, $name;                                              # Size of array

  For                                                                           # Outer loop
   {my ($i, $start, $check, $end) = @_;                                         # Loop labels
    my  $L  = Subtract $N, 1;                                                   # An array of one element is already sorted
    my  $c  = Mov 0;                                                            # Count number of swaps
    For                                                                         # Inner loop
     {my ($j) = @_;
      my $a = Mov [$array, \$j, $name];
      my $b = Mov [$array, \$j, $name, 1];

      IfGt $a, $b,
      Then                                                                      # Swap elements to place smaller element lower in array
       {Mov [$array, \$j, $name, 1], $a;
        Mov [$array, \$j, $name],    $b;
        Inc $c;
       };
     } $L;
    JFalse $end, $c;                                                            # Stop if the array is now sorted
   } $N;
 }

if (1)                                                                          # Small array
 {Start 1;
  my $a = Array "array";
  my @a = qw(6 8 4 2 1 3 5 7);
  Push $a, $_ for @a;                                                           # Load array

  bubbleSort($a, "array");                                                      # Sort

  ForArray                                                                      # Print array
   {my ($i, $e) = @_;
    Out $e;
   } $a, "array";

  my $e = Execute(suppressOutput=>1);                                           # Execute assembler program
  is_deeply $e->out, [1..8];                                                    # Check output

  is_deeply $e->count,  347;                                                    # Instructions executed

  is_deeply $e->counts, {                                                       # Counts of each instruction type executed
  array     => 1,
  arraySize => 2,
  inc       => 62,
  jFalse    => 5,
  jGe       => 54,
  jLe       => 35,
  jmp       => 47,
  mov       => 120,
  out       => 8,
  push      => 8,
  subtract  => 5};
 }

if (1)                                                                          # Reversed array 4 times larger
 {Start 1;
  my $a = Array "array";
  my @a = reverse 1..32;
  Push $a, $_ for @a;

  bubbleSort($a, "array");

  ForArray
   {my ($i, $e, $Check, $Next, $End) = @_;
    Out $e;
   } $a, "array";

  my $e = Execute(suppressOutput=>1);                                           # Execute assembler program

  is_deeply $e->out, [1..32];                                                   # Check output
  is_deeply $e->count, 7892;                                                    # Approximately 4*4== 16 times bigger
 }
