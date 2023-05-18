#!/usr/bin/perl -Ilib -I../lib -I/home/phil/perl/cpan/ZeroEmulator/lib/
#-------------------------------------------------------------------------------
# Zero assembler programming language of in situ bubble sort
# Philip R Brenan at appaapps dot com, Appa Apps Ltd Inc., 2023
#-------------------------------------------------------------------------------
use v5.30;
use warnings FATAL => qw(all);
use strict;
use Data::Table::Text qw(:all);
use Zero::Emulator qw(:all);
use Test::More tests=>5;

sub array{99}                                                                   # an arbitrary number identifying the array being sorted

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
  my $a = Array array;
  my @a = qw(6 8 4 2 1 3 5 7);
  Push $a, $_, array for @a;                                                    # Load array

  bubbleSort($a, array);                                                        # Sort

  ArrayDump $a, array;

  my $e = GenerateMachineCodeDisAssembleExecute(suppressOutput=>1);                                           # Execute assembler program
  is_deeply $e->out, <<END;
array
bless([1 .. 8], "array")
END

  is_deeply $e->count,  305;                                                    # Instructions executed

  is_deeply formatTable($e->counts), <<END;
array        1
arrayDump    1
arraySize    1
inc         54
jFalse       5
jGe         45
jLe         35
jmp         39
mov        111
push         8
subtract     5
END
 }

if (1)                                                                          # Reversed array 4 times larger
 {Start 1;
  my $a = Array "array";
  my @a = reverse 1..32;
  Push $a, $_, "array" for @a;

  bubbleSort($a, "array");

  ArrayDump $a, "array";

  my $e = Execute(suppressOutput=>1);                                           # Execute assembler program

  is_deeply $e->out, <<END;
array
bless([1 .. 32], "array")
END
  is_deeply $e->count, 7730;                                                    # Approximately 4*4== 16 times bigger
 }
