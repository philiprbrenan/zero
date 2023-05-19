#!/usr/bin/perl -Ilib -I../lib  -I/home/phil/perl/cpan/ZeroEmulator/lib/
#-------------------------------------------------------------------------------
# Zero assembler programming language of in situ insertion sort
# Philip R Brenan at appaapps dot com, Appa Apps Ltd Inc., 2023
#-------------------------------------------------------------------------------
use v5.30;
use warnings FATAL => qw(all);
use strict;
use Data::Dump qw(dump);
use Data::Table::Text qw(:all);
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

        IfLt $a, $b,
        Then                                                                    # Move up
         {Mov [$array, \$j, $name, 1], $b;
         },
        Else                                                                    # Insert
         {Mov [$array, \$j, $name, 1], $a;
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
  Push $a, $_, "array" for @a;                                                  # Load array

  insertionSort($a, "array");                                                   # Sort

  ArrayDump $a, "array";

  my $e = GenerateMachineCodeDisAssembleExecute(suppressOutput=>1);             # Execute assembler program

  is_deeply $e->out, <<END;
bless([1 .. 8], "array")
END

  is_deeply $e->count, 189;                                                     # Instructions executed

  is_deeply formatTable($e->counts), <<END;
array       1
arrayDump   1
arraySize   1
dec        15
inc         7
jGe        27
jLt        22
jmp        44
mov        49
push        8
subtract   14
END
 }

if (1)                                                                          # Reversed array 4 times larger
 {Start 1;
  my $a = Array "array";
  my @a = reverse 1..32;
  Push $a, $_, "array" for @a;

  insertionSort($a, "array");

  ArrayDump $a, "array";

  my $e = GenerateMachineCodeDisAssembleExecute(suppressOutput=>1);             # Execute assembler program

  is_deeply $e->out, <<END;
bless([1 .. 32], "array")
END
  is_deeply $e->count, 3788;                                                    # Approximately 4*4== 16 times bigger
 }
