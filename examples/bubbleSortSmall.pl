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
use Test::More tests=>3;

sub bubbleSort($$)                                                              # As described at: https://en.wikipedia.org/wiki/Bubble_sort
 {my ($array, $name) = @_;                                                      # Array, name of array memory

  my $N = ArraySize $array, $name;                                              # Size of array

  For                                                                           # Outer loop
   {my ($i, $start, $check, $end) = @_;                                         # Loop labels
Out 1001;
Out $i;
Out $N;
    my $l = Subtract $N, $i;                                                    # An array of one element is already sorted
    my $c = Mov 0;                                                              # Count number of swaps
Out 1111;
Out $l;
    For                                                                         # Inner loop
     {my ($j) = @_;
Out 2222;
Out $j;
      my $a = Mov [$array, \$j, $name];
Out 3333;
      my $b = Mov [$array, \$j, $name, -1];
Out 4444;
Out $j;
Out $a;
Out $b;
      IfLt $a, $b,
      Then                                                                      # Swap elements to place smaller element lower in array
       {
Out 5555;
        Mov [$array, \$j, $name, -1], $a;
Out 6666;
        Mov [$array, \$j, $name],     $b;
Out 7777;
Out $a;
Out $b;
        Inc $c;
       };
     } [1, $l];
Out 8888;
    JFalse $end, $c;                                                            # Stop if the array is now sorted
Out 9999;
   } $N;
Out 1010;
 }

if (1)                                                                          # Small array
 {Start 1;
  my $a = Array 'array';
  my @a = qw(33 11 22 44 77 55 66 88);
  Push $a, $_, 'array' for @a;                                                  # Load array

  bubbleSort $a, 'array';                                                       # Sort
  Out [$a, \$_, 'array'] for keys @a;

  my $e = Execute(suppressOutput=>0, trace=>0);                                 # Execute
  say STDERR generateVerilogMachineCode("Bubble_sort");

  #say STDERR "AAAA", $e->PrintMemory->($e); exit;
  is_deeply $e->PrintMemory->($e), <<END;
Memory    0    1    2    3    4    5    6    7    8    9   10   11   12   13   14   15   16   17   18   19   20   21   22   23   24   25   26   27   28   29   30   31
Local:    0    8    1    7    0    7   77   66
     0   11   22   33   44   55   66   77   88    size:     8
END
  #is_deeply $e->outLines, [11, 22, 33];

  is_deeply $e->count,          115;

  #say STDERR formatTable($e->counts); exit;
  is_deeply formatTable($e->counts), <<END;
add        18
array       1
arraySize   1
jFalse      2
jGe        30
jmp        14
mov        39
push        8
subtract    2
END
 }
