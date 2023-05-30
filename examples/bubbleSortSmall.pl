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

sub bubbleSort($$)                                                              # As described at: https://en.wikipedia.org/wiki/Bubble_sort
 {my ($array, $name) = @_;                                                      # Array, name of array memory

  my $N = ArraySize $array, $name;                                              # Size of array

  For                                                                           # Outer loop
   {my ($i, $start, $check, $end) = @_;                                         # Loop labels
    my $l = Subtract $N, $i;                                                    # An array of one element is already sorted
    my $c = Mov 0;                                                              # Count number of swaps
Out 1111;
    For                                                                         # Inner loop
     {my ($j) = @_;
      my $a = Mov [$array, \$j, $name];
      my $b = Mov [$array, \$j, $name, -1];
Out 2222;
Out $j;
Out $a;
Out $b;
      IfLt $a, $b,
      Then                                                                      # Swap elements to place smaller element lower in array
       {Mov [$array, \$j, $name, -1], $a;
        Mov [$array, \$j, $name],     $b;
Out 3333;
Out $a;
Out $b;
        Inc $c;
       };
     } [1, $l];
Out 4444;
    JFalse $end, $c;                                                            # Stop if the array is now sorted
Out 5555;
   } $N;
Out 6666;
 }

if (1)                                                                          # Small array
 {Start 1;
  my $a = Array 'array';
  my @a = qw(33 11 22);
  Push $a, $_, 'array' for @a;                                                  # Load array

  bubbleSort $a, 'array';                                                       # Sort
  Out [$a, \$_, 'array'] for keys @a;

  my $e = Execute(suppressOutput=>0, trace=>0);                                 # Execute
  say STDERR generateVerilogMachineCode("Bubble_sort");

  #say STDERR "AAAA", $e->PrintMemory->($e);
  is_deeply $e->PrintMemory->($e), <<END;
Memory    0    1    2    3    4    5    6    7    8    9   10   11   12   13   14   15   16   17   18   19   20   21   22   23   24   25   26   27   28   29   30   31
Local:    0    3    1    2    0    2   22   11
     0   11   22   33    size:     3
END
  #is_deeply $e->outLines, [11, 22, 33];

  is_deeply $e->count,          44;                                             # Instructions executed
  is_deeply $e->timeParallel,   44;
  is_deeply $e->timeSequential, 44;

  #say STDERR formatTable($e->counts); exit;
  is_deeply formatTable($e->counts), <<END;
add         6
array       1
arraySize   1
jFalse      2
jGe        10
jmp         4
mov        15
push        3
subtract    2
END
 }
