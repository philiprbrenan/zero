#!/usr/bin/perl -I/home/phil/perl/zero/lib/ -Ilib
#-------------------------------------------------------------------------------
# Zero assembler language implemention of a generic N-Way tree.
# Philip R Brenan at appaapps dot com, Appa Apps Ltd Inc., 2023
#-------------------------------------------------------------------------------
use v5.30;
use warnings FATAL => qw(all);
use strict;
use Data::Dump qw(dump);
use Data::Table::Text qw(:all);
use Zero::NWayTree qw(:all);
use Zero::Emulator qw(:all);
use Test::More tests=>6;

=pod

=head1 Test the construction of N Way Trees using Zero assembler code.

=head2 Iterate over a small sequential tree

This example creates a tree, then loads it with keys from 0..$N-1 . Each key
has a data value of twice the key associated with it.  Iterating over the tree
produces the keys in order. The structure of the tree so constructed is visible
in the printed output.

The code to create and load the tree is written in Zero assembler.  The Zero
assembler language uses Perl as its macro preprocessor to generate the
necessary instruction sequences.  Executing Zero assembler code on an emulator
enables cross checks to be performed on the running code. Such checks include:
the number of instructions executed, whether each memory location is of the
expected type, whether each location has been read since it was last written,
or whether it is being updated with the same value again.

=cut

Test::More->builder->output("/dev/null");

if (1)                                                                          # Dimensions of the tree
 {my $W = 3; my $N = 15;

  Start 1;
  my $t = New($W);

  For                                                                           # Create tree
   {my ($k) = @_;
    my $d = Add $k, $k;                                                         # The data is the key doubled
    Insert($t, $k, $d);
   } $N;

  Iterate                                                                       # Iterate tree
   {my ($find) = @_;                                                            # Find result
    my $k = FindResult_key ($find);
    my $d = FindResult_data($find);
    AssertEq Add($k, $k), $d;                                                   # Check key against data
    Out $k;
   } $t;

  my $e = Execute(suppressOutput=>1);                                           # Execute assembler program

  is_deeply $e->out, [0..$N-1];                                                 # Check output

  is_deeply printTreeKeys($e->memory), <<END;                                   # Check keys in memory
           3           7
     1           5           9    11    13
  0     2     4     6     8    10    12    14
END

  is_deeply printTreeData($e->memory), <<END;                                   # Check data in memory
           6          14
     2          10          18    22    26
  0     4     8    12    16    20    24    28
END
 }

=head2 Iterate over a wider, larger random tree

This example loads a tree with a random rearrangement of the values from
0..$N-1 and then confirms that the tree so produced can be interated to recover
the original sequence before it was disarranged.

The number of executions of each instruction type is checked at the end and
printed as a table using Data::Table::Text.

=cut

if (1)                                                                          # A larger tree
 {my $W = 5; my $N = 2023; my @r = randomArray $N;

  Start 1;
  my $t = New($W);                                                              # Create tree

  my $a = Array "aaa";
  for my $I(1..$N)                                                              # Load array of input keys
   {my $i = $I-1;
    Mov [$a, $i, "aaa"], $r[$i];
   }

  ForArray                                                                      # Load tree
   {my ($i, $k) = @_;
    Insert($t, $k, $k);                                                         # Insert a new node
   } $a, q(aaa);

  Iterate                                                                       # Iterate tree
   {my ($find) = @_;                                                            # Find result
    my $k = FindResult_key($find);
    Out $k;                                                                     # Print
   } $t;

  my $e = Execute(suppressOutput=>1);                                           # Assemble and execute the program
  is_deeply $e->out, [1..$N];                                                   # Check output

  is_deeply $e->count, 859209;                                                  # Total instruction count
  #say STDERR dump("Count", $e->count);
  #say STDERR dump("Counts", $e->counts);
  my $r = formatTable($e->counts, <<END,                                        # Instruction counts
Inst  Instruction name
Count Number of times each instruction was executed
END
    title     => q(Instruction counts),
#   file => q(zzz.txt),
    );

  is_deeply [split "\n", $r], [split m/\n/, <<END];
Instruction counts

   Column  Description
1  Inst    Instruction name
2  Count   Number of times each instruction was executed


Inst        Count
add          16476
array         7309
arraySize        1
assertNe      1468
call          2023
free          4915
inc          31593
jEq          16167
jFalse        2211
jGe          56632
jLe          10850
jLt          12868
jNe          32251
jTrue          735
jmp          43062
label       205701
mov         284465
not          17078
out           2023
paramsGet     6069
paramsPut     6069
resize          15
return        2023
shiftRight     729
shiftUp       5540
subtract     15359
tracePoint   75577
END
}

done_testing;
