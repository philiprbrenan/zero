#!/usr/bin/perl -I/home/phil/perl/cpan/DataTableText/lib/
#-------------------------------------------------------------------------------
# Push 0 code to GitHub
# Philip R Brenan at gmail dot com, Appa Apps Ltd Inc., 2023
#-------------------------------------------------------------------------------
use warnings FATAL => qw(all);
use strict;
use Carp;
use Data::Dump qw(dump);
use Data::Table::Text qw(:all);
use GitHub::Crud qw(:all);
use Pod::Markdown;
use feature qw(say current_sub);

makeDieConfess;

my $home = q(/home/phil/perl/cpan/ZeroEmulator/);                               # Local files
my $user = q(philiprbrenan);                                                    # User
my $repo = q(zero);                                                             # Store code here so it can be referenced from a browser
my $wf   = q(.github/workflows/main.yml);                                       # Work flow on Ubuntu

sub pod($$$)                                                                    # Write pod file
 {my ($in, $out, $intro) = @_;                                                  # Input, output file, introduction
  binModeAllUtf8;
  my $d = updateDocumentation readFile $in;
  if ($d =~ m(\A(.*)(=head1 Description.*=cut\n))s)
   {my $p = Pod::Markdown->new;
    my $m;
       $p->output_string(\$m);
       $p->parse_string_document("$intro\n$2");
    owf($out, $m);

    say STDERR "$in\n$1\n";
    return;
   }
  confess "Cannot extract documentation for file: $in";
 }

pod fpf($home, q(lib/Zero/Emulator.pm)), fpf($home, q(Emulator.md)), &introEmulator;
pod fpf($home, q(lib/Zero/NWayTree.pm)), fpf($home, q(NWayTree.md)), &introNWayTree;

expandWellKnownWordsInMarkDownFile                                              # Documentation
  fpe($home, qw(README md2)), fpe $home, qw(README md);

push my @files,
  grep {!/backups/}
  grep {!/_build/}
  grep {!/blib/}
  searchDirectoryTreesForMatchingFiles($home, qw(.pm .pl .md));                 # Files

for my $s(@files)                                                               # Upload each selected file
 {my $c = readFile($s);                                                         # Load file
  my $t = swapFilePrefix $s, $home;
  my $w = writeFileUsingSavedToken($user, $repo, $t, $c);
  lll "$w $s $t";
 }

my $d = dateTimeStamp;

my $y = <<'END';
# Test $d

name: Test

on:
  push

jobs:
  test:
    runs-on: ubuntu-latest

    steps:
    - uses: actions/checkout@v2
      with:
        ref: 'main'

    - name: Cpan
      run: |
        sudo cpan install -T Data::Dump Data::Table::Text

    - name: Zero Emulator
      run: |
        perl lib/Zero/Emulator.pm

    - name: Zero NWay
      run: |
        perl lib/Zero/NWayTree.pm

    - name: Zero testEmulator
      run: |
        perl testEmulator.pl

    - name: Zero testNWayTree
      run: |
        perl testNWayTree.pl
END

lll "Ubuntu work flow for $repo ", writeFileUsingSavedToken($user, $repo, $wf, $y);


sub introEmulator{<<'END'}
=pod

=encoding utf-8

=head1 Name

Zero::Emulator - Assemble and emulate a program in the Zero assembly programming language

=for html
<p><a href="https://github.com/philiprbrenan/zero"><img src="https://github.com/philiprbrenan/zero/workflows/Test/badge.svg"></a>

=head1 Synopsis

Say "hello world":

  Start 1;

  Out "hello World";

  my $e = Execute;

  is_deeply $e->out, ["hello World"];
END

sub introNWayTree{<<'END'}
=pod

=encoding utf-8

=head1 Name

Zero::NWayTree - N-Way-Tree in Zero assembler language.

=for html
<p><a href="https://github.com/philiprbrenan/zero"><img src="https://github.com/philiprbrenan/zero/workflows/Test/badge.svg"></a>

=head1 Synopsis

Create a tree, load it from an array of random numbers, then print out the
results:

  my $W = 3; my $N = 107; my @r = randomArray $N;

  Start 1;
  my $t = New($W);                                                              # Create tree at expected location in memory

  my $a = Array "aaa";
  for my $I(1..$N)                                                              # Load array
   {my $i = $I-1;
    Mov [$a, $i, "aaa"], $r[$i];
   }

  ForArray                                                                      # Create tree
   {my ($i, $k) = @_;
    my $n = Keys($t);
    AssertEq $n, $i;                                                            # Check tree size
    my $K = Add $k, $k;
    Tally 1;
    Insert($t, $k, $K);                                                         # Insert a new node
    Tally 0;
   } $a, q(aaa);

  Iterate                                                                       # Iterate tree
   {my ($find) = @_;                                                            # Find result
    my $k = FindResult_key($find);
    Out $k;
    my $f = Find($t, $k);                                                       # Find
    my $d = FindResult_data($f);
    my $K = Add $k, $k;
    AssertEq $K, $d;                                                            # Check result
   } $t;

  my $e = Execute(suppressOutput=>1);

  is_deeply $e->out, [1..$N];                                                   # Expected sequence

  is_deeply $e->tallyCount,  26177;                                             # Insertion instruction counts
  is_deeply $e->tallyCounts->{1}, {
  add        => 860,
  array      => 607,
  call       => 107,
  free       => 360,
  inc        => 1044,
  jEq        => 631,
  jGe        => 1667,
  jLe        => 461,
  jLt        => 565,
  jmp        => 1436,
  jNe        => 1095,
  mov        => 12328,
  not        => 695,
  paramsGet  => 321,
  paramsPut  => 321,
  resize     => 12,
  return     => 107,
  shiftRight => 68,
  shiftUp    => 300,
  subtract   => 641,
  tracePoint => 2551,
};
END
