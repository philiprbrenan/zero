#!/usr/bin/perl -Ilib -I../lib
#-------------------------------------------------------------------------------
# Zero assembler programming language of in situ insertion sort
# Philip R Brenan at appaapps dot com, Appa Apps Ltd Inc., 2023
#-------------------------------------------------------------------------------
use v5.30;
use warnings FATAL => qw(all);
use strict;
use Data::Dump qw(dump);
use Zero::Emulator qw(:all);
use Test::More tests=>5;

sub insertionSort($$)                                                           # As described at: https://en.wikipedia.org/wiki/Insertion_sort
 {my ($array, $name) = @_;                                                      # Array, name of array memory

  my $N = ArraySize $array, $name;                                              # Size of array

  For                                                                           # Outer loop
   {my ($i) = @_;
    my $a = Mov [$array, \$i, $name];

    Block
     {my ($Start, $Good, $Bad, $End) = @_;
      For                                                                       # Inner loop
       {my ($j) = @_;
        my  $b  = Mov [$array, \$j, $name];
        my  $J  = Add $j, 1;

        IfLt $a, $b,
        Then                                                                    # Move up
         {Mov [$array, \$J, $name], $b;
         },
        Else                                                                    # Insert
         {Mov [$array, \$J, $name], $a;
          Jmp $End;
         };
       } $i, reverse=>1;
       Jmp $Bad;
     }                                                                          # NB: a comma here would be dangerous as the first block is a standalone sub
    Bad                                                                         # Insert at start
     {Mov [$array, \0, $name], $a;
     };
   } [1, $N];
 }

if (1)                                                                          # Small array
 {Start 1;
  my $a = Array "array";
  my @a = qw(6 8 4 2 1 3 5 7);
  Push $a, $_ for @a;                                                           # Load array

  insertionSort($a, "array");                                                   # Sort

  ForArray                                                                      # Print array
   {my ($i, $e) = @_;
    Out $e;
   } $a, "array";

  my $e = Execute(suppressOutput=>1);                                           # Execute assembler program

  is_deeply $e->out, [1..8];                                                    # Check output

  is_deeply $e->count, 250;                                                     # Instructions executed

  is_deeply $e->counts, {                                                       # Counts of each instruction type executed
  add       => 19,
  array     => 1,
  arraySize => 2,
  dec       => 15,
  inc       => 15,
  jGe       => 36,
  jLt       => 22,
  jmp       => 52,
  mov       => 58,
  out       => 8,
  push      => 8,
  subtract  => 14};
 }

if (1)                                                                          # Reversed array 4 times larger
 {Start 1;
  my $a = Array "array";
  my @a = reverse 1..32;
  Push $a, $_ for @a;

  insertionSort($a, "array");

  ForArray
   {my ($i, $e, $Check, $Next, $End) = @_;
    Out $e;
   } $a, "array";

  my $e = Execute(suppressOutput=>1);                                           # Execute assembler program

  is_deeply $e->out, [1..32];                                                   # Check output
  is_deeply $e->count, 4446;                                                    # Approximately 4*4== 16 times bigger
 }
