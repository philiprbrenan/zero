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
use Test::More tests=>7;

sub bubbleSort($$)                                                              # As described at: https://en.wikipedia.org/wiki/Bubble_sort
 {my ($array, $name) = @_;                                                      # Array, name of array memory

  my $N = ArraySize $array, $name;                                              # Size of array

  For                                                                           # Outer loop
   {my ($i, $start, $check, $end) = @_;                                         # Loop labels
    my $l; my $c;
    Parallel
      sub{$l = Subtract $N, $i},                                                # An array of one element is already sorted
      sub{$c = Mov 0};                                                          # Count number of swaps

    For                                                                         # Inner loop
     {my ($j) = @_;
      my $a; my $b;
      Parallel
        sub{$a = Mov [$array, \$j, $name]},
        sub{$b = Mov [$array, \$j, $name, -1]};

      IfLt $a, $b,
      Then                                                                      # Swap elements to place smaller element lower in array
       {Parallel
          sub{Mov [$array, \$j, $name, -1], $a},
          sub{Mov [$array, \$j, $name],     $b},
          sub{Inc $c};
       };
     } [1, $l];
    JFalse $end, $c;                                                            # Stop if the array is now sorted
   } $N;
 }

if (1)                                                                          # Small array
 {Start 1;
  my $a = Array 'array';
  my @a = qw(6 8 4 2 1 3 5 7);
  Push $a, $_, 'array' for @a;                                                    # Load array

  bubbleSort $a, 'array';                                                       # Sort
  ArrayDump $a;

  #my $e = Execute;
  my $e = GenerateMachineCodeDisAssembleExecute(suppressOutput=>1);             # Execute a disassembled copy of the program just to show that we can
  is_deeply $e->out, <<END;
[1 .. 8]
END

  is_deeply $e->count,  244;                                                    # Instructions executed
  is_deeply $e->timeParallel,   184;
  is_deeply $e->timeSequential, 244;

  #say STDERR formatTable($e->counts);
  is_deeply formatTable($e->counts), <<END;
array       1
arraySize   1
inc        44
jFalse      5
jGe        60
jmp        29
mov        91
push        8
subtract    5
END
 }

if (1)                                                                          # Reversed array 4 times larger
 {Start 1;
  my $a = Array 'array';
  my @a = reverse 1..32;
  Push $a, $_, 'array' for @a;

  bubbleSort $a, 'array';

  ArrayDump $a;

  my $e = GenerateMachineCodeDisAssembleExecute(suppressOutput=>1);             # Execute assembler program

  is_deeply $e->count, 4753;                                                    # Instructions executed

  is_deeply $e->out, <<END;
[1 .. 32]
END
 }
