#!/usr/bin/perl -Ilib -I../lib -I/home/phil/perl/cpan/ZeroEmulator/lib/
#-------------------------------------------------------------------------------
# Zero assembler programming language of in situ selection sort
# Philip R Brenan at appaapps dot com, Appa Apps Ltd Inc., 2023
#-------------------------------------------------------------------------------
use v5.30;
use warnings FATAL => qw(all);
use strict;
use Data::Table::Text qw(:all);
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
  Push $a, $_, "array" for @a;                                                  # Load array

  selectionSort($a, "array");                                                   # Sort

  ArrayDump $a;

  my $e = GenerateMachineCodeDisAssembleExecute(suppressOutput=>1);             # Execute assembler program

  is_deeply $e->out, <<END;
[1 .. 8]
END
  is_deeply $e->count,  286;                                                    # Instructions executed

  is_deeply formatTable($e->counts), <<END;
array       1
arrayDump   1
arraySize   1
inc        44
jGe        53
jLe        36
jmp        44
mov        98
push        8
END
 }

if (1)                                                                          # Reversed array 4 times larger
 {Start 1;
  my $a = Array "array";
  my @a = reverse 1..32;
  Push $a, $_, "array" for @a;

  selectionSort($a, "array");

  ArrayDump $a;

  my $e = GenerateMachineCodeDisAssembleExecute(suppressOutput=>1);             # Execute assembler program

  is_deeply $e->out, <<END;
[1 .. 32]
END
  is_deeply $e->count, 4357;                                                    # Approximately 4*4== 16 times bigger
 }
