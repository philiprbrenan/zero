#!/usr/bin/perl -I/home/phil/perl/cpan/DataTableText/lib/
#-------------------------------------------------------------------------------
# Push Zero code to GitHub
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

my $home    = q(/home/phil/perl/cpan/ZeroEmulator/);                            # Local files
my $user    = q(philiprbrenan);                                                 # User
my $repo    = q(zero);                                                          # Store code here so it can be referenced from a browser
my $wf      = q(.github/workflows/main.yml);                                    # Work flow on Ubuntu
my $repoUrl = q(https://github.com/philiprbrenan/zero);
my $perlXmp = 1;                                                                # Perl examples if true
my $macos   = 0;                                                                # Macos if true
my $windows = 0;                                                                # Windows if true
my $openBsd = 0;                                                                # OpenBsd if true
my $freeBsd = 0;                                                                # FreeBsd if true - fails

sub pod($$$)                                                                    # Write pod file
 {my ($in, $out, $intro) = @_;                                                  # Input, output file, introduction
  binModeAllUtf8;
  my $d = updateDocumentation readFile $in;
  if ($d =~ m(\A(.*)(=head1 Description.*=cut\n))s)
   {my $p = Pod::Markdown->new;
    my $m;
       $p->output_string(\$m);
       $p->parse_string_document(my $pod = "$intro\n$2");                       # Create Pod and convert to markdown
    owf($out, $m);                                                              # Write markdown
    my $podFile = setFileExtension($out, q(pod));                               # Corresponding pod file
    owf($podFile, $pod);                                                        # Write corresponding pod

    say STDERR "$in\n$1\n";                                                     # Print any error messages from automated documentation
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
  grep {!/Build.PL/}
  grep {!/blib/}
  grep {$perlXmp or !/\.pl\Z/}                                                  # No changes expected
  searchDirectoryTreesForMatchingFiles($home, qw(.pm .pl .md));                 # Files

for my $s(@files)                                                               # Upload each selected file
 {my $c = readFile($s);                                                         # Load file
  my $t = swapFilePrefix $s, $home;
  my $w = writeFileUsingSavedToken($user, $repo, $t, $c);
  lll "$w $s $t";
 }

my $d = dateTimeStamp;

my $t = <<END;
    - name: Cpan
      run:  sudo cpan install -T Data::Dump Data::Table::Text

    - name: Emulator
      run:  perl lib/Zero/Emulator.pm

    - name: TestNWayTree
      run:  perl examples/testNWayTree.pl

    - name: BubbleSort
      run:  perl examples/bubbleSort.pl

    - name: InsertionSort
      run:  perl examples/insertionSort.pl

    - name: QuickSort
      run:  perl examples/quickSort.pl

    - name: QuickSort Parallel
      run:  perl examples/quickSortParallel.pl

    - name: SelectionSort
      run:  perl examples/selectionSort.pl

    - name: TestEmulator
      run:  perl examples/testEmulator.pl

    - name: NWayTree
      run:  perl lib/Zero/NWayTree.pm
END

my $y = <<"END" =~ s(XXXX) ($t)gsr;
# Test $d

name: Test

on:
  push

jobs:
  test:
    runs-on: ubuntu-latest

    steps:
    - uses: actions/checkout\@v2
      with:
        ref: 'main'

XXXX
END

my $ym = <<'END' =~ s(XXXX) ($t)gsr;
  testMac:
    runs-on: macos-latest

    steps:
    - uses: actions/checkout@v2
      with:
        ref: 'main'

XXXX
END

$y .= $ym if $macos;

my $yw = <<'END' =~ s(XXXX) ($t)gsr;
  testWindows:
    runs-on: windows-latest

    defaults:
      run:
        shell: wsl-bash {0}                                                     # Use Windows Services For Linux as the command line in subsequent steps

    steps:
    - uses: actions/checkout@v2
      with:
        ref: 'main'

    - uses: Vampire/setup-wsl@v2                                                # Install Windows Services For Linux - just: wsl --install -D Ubuntu
      with:
        distribution: Ubuntu-22.04

    - name: Ubuntu
      run: |
        sudo apt-get -y update

    - name: Configure Ubuntu
      run: |
        sudo apt-get -y install build-essential

XXXX
END

$y .= $yw if $windows;

my $yob = <<'END' =~ s(XXXX) ($t)gsr;
  testOpenBsd:
    runs-on: macos-12
    name: OpenBSD
    env:
      MYTOKEN : ${{ secrets.MYTOKEN }}
      MYTOKEN2: "value2"
    steps:
    - uses: actions/checkout@v3
    - name: Test in OpenBSD
      id: test
      uses: vmactions/openbsd-vm@v0
      with:
        envs: 'MYTOKEN MYTOKEN2'
        usesh: true
        prepare: |
          cpan install -T Data::Dump Data::Table::Text

        run: |
          perl lib/Zero/Emulator.pm
          perl lib/Zero/NWayTree.pm
          perl examples/testEmulator.pl
          perl examples/testNWayTree.pl
          perl examples/bubbleSort.pl
          perl examples/insertionSort.pl
          perl examples/quickSort.pl
          perl examples/selectionSort.pl
END

$y .= $yob if $openBsd;

my $yfb = <<'END' =~ s(XXXX) ($t)gsr;
  testFreeBsd:
    runs-on: macos-12
    name: FreeBSD
    env:
      MYTOKEN : ${{ secrets.MYTOKEN }}
      MYTOKEN2: "value2"
    steps:
    - uses: actions/checkout@v3
    - name: Test in OpenBSD
      id: test
      uses: vmactions/freebsd-vm@v0
      with:
        envs: 'MYTOKEN MYTOKEN2'
        usesh: true
        prepare: |
          cpan install -T Data::Dump Data::Table::Text

        run: |
          perl lib/Zero/Emulator.pm
          perl lib/Zero/NWayTree.pm
          perl lib/Zero/Emulator.pm
          perl lib/Zero/NWayTree.pm
          perl examples/testEmulator.pl
          perl examples/testNWayTree.pl
          perl examples/bubbleSort.pl
          perl examples/insertionSort.pl
          perl examples/quickSort.pl
          perl examples/selectionSort.pl
END

$y .= $yfb if $freeBsd;

lll "Ubuntu work flow for $repo ", writeFileUsingSavedToken($user, $repo, $wf, $y);

sub introEmulator{&introEmulator1.&introEmulator2}

sub introEmulator1{<<"END"}
=pod

=encoding utf-8

=head1 Name

Zero::Emulator - Assemble and emulate a program written in the L<Zero|$repoUrl> assembler programming language.

=for html
<p><a href="$repoUrl"><img src="$repoUrl/workflows/Test/badge.svg"></a>
END

sub introEmulator2{<<'END2'}

=head1 Synopsis

Say "hello world":

  Start 1;

  Out "Hello World";

  my $e = Execute;

  is_deeply $e->out, <<END;
Hello World
END
END2

sub introNWayTree{&introNWayTree1.&introNWayTree2}

sub introNWayTree1{<<"END"}
=pod

=encoding utf-8

=head1 Name

Zero::NWayTree - N-Way-Tree written in the Zero assembler programming language.

=for html
<p><a href="$repoUrl"><img src="$repoUrl/workflows/Test/badge.svg"></a>

=head1 Synopsis

Create a tree, load it from an array of random numbers, then print out the
results. Show the number of instructions executed in the process.  The
challenge, should you wish to acceopt it, is to reduce these instruction counts
to the minimum possible while still passing all the tests.

END

sub introNWayTree2{<<'END2'}
 {my $W = 3; my $N = 107; my @r = randomArray $N;

  Start 1;
  my $t = New($W);                                                              # Create tree at expected location in memory

  my $a = Array "aaa";
  for my $I(1..$N)                                                              # Load array
   {my $i = $I-1;
    Mov [$a, $i, "aaa"], $r[$i];
   }

  my $f = FindResult_new;

  ForArray                                                                      # Create tree
   {my ($i, $k) = @_;
    my $n = Keys($t);
    AssertEq $n, $i;                                                            # Check tree size
    my $K = Add $k, $k;
    Tally 1;
    Insert($t, $k, $K,                                                          # Insert a new node
      findResult=>          $f,
      maximumNumberOfKeys=> $W,
      splitPoint=>          int($W/2),
      rightStart=>          int($W/2)+1,
    );
    Tally 0;
   } $a, q(aaa);

  Iterate                                                                       # Iterate tree
   {my ($find) = @_;                                                            # Find result
    my $k = FindResult_key($find);
    Out $k;
    Tally 2;
    my $f = Find($t, $k, findResult=>$f);                                       # Find
    Tally 0;
    my $d = FindResult_data($f);
    my $K = Add $k, $k;
    AssertEq $K, $d;                                                            # Check result
   } $t;

  Tally 3;
  Iterate {} $t;                                                                # Iterate tree
  Tally 0;

  my $e = Execute(suppressOutput=>1);

  is_deeply $e->out, [1..$N];                                                   # Expected sequence

  #say STDERR dump $e->tallyCount;
  is_deeply $e->tallyCount,  24712;                                             # Insertion instruction counts

  #say STDERR dump $e->tallyTotal;
  is_deeply $e->tallyTotal, { 1 => 15666, 2 => 6294, 3 => 2752};

  #say STDERR dump $e->tallyCounts->{1};
  is_deeply $e->tallyCounts->{1}, {                                             # Insert tally
  add               => 159,
  array             => 247,
  arrayCountGreater => 2,
  arrayCountLess    => 262,
  arrayIndex        => 293,
  dec               => 30,
  inc               => 726,
  jEq               => 894,
  jGe               => 648,
  jLe               => 461,
  jLt               => 565,
  jmp               => 878,
  jNe               => 908,
  mov               => 7724,
  moveLong          => 171,
  not               => 631,
  resize            => 161,
  shiftUp           => 300,
  subtract          => 606,
};

  #say STDERR dump $e->tallyCounts->{2};
  is_deeply $e->tallyCounts->{2}, {                                             # Find tally
  add => 137,
  arrayCountLess => 223,
  arrayIndex => 330,
  inc => 360,
  jEq => 690,
  jGe => 467,
  jLe => 467,
  jmp => 604,
  jNe => 107,
  mov => 1975,
  not => 360,
  subtract => 574};

  #say STDERR dump $e->tallyCounts->{3};
  is_deeply $e->tallyCounts->{3}, {                                             # Iterate tally
  add        => 107,
  array      => 1,
  arrayIndex => 72,
  dec        => 72,
  free       => 1,
  inc        => 162,
  jEq        => 260,
  jFalse     => 28,
  jGe        => 316,
  jmp        => 252,
  jNe        => 117,
  jTrue      => 73,
  mov        => 1111,
  not        => 180};

  #say STDERR printTreeKeys($e->memory); x;
  #say STDERR printTreeData($e->memory); x;
  is_deeply printTreeKeys($e->memory), <<END;
                                                                                                                38                                                                                                    72
                                                             21                                                                                                       56                                                                                                 89
                            10             15                                     28             33                                  45                   52                                     65                                     78             83                               94          98            103
        3        6     8             13          17    19          23       26             31             36          40    42             47    49             54          58    60    62             67    69                75                81             86             91             96            101         105
  1  2     4  5     7     9    11 12    14    16    18    20    22    24 25    27    29 30    32    34 35    37    39    41    43 44    46    48    50 51    53    55    57    59    61    63 64    66    68    70 71    73 74    76 77    79 80    82    84 85    87 88    90    92 93    95    97    99100   102   104   106107
END

  is_deeply printTreeData($e->memory), <<END;
                                                                                                                76                                                                                                   144
                                                             42                                                                                                      112                                                                                                178
                            20             30                                     56             66                                  90                  104                                    130                                    156            166                              188         196            206
        6       12    16             26          34    38          46       52             62             72          80    84             94    98            108         116   120   124            134   138               150               162            172            182            192            202         210
  2  4     8 10    14    18    22 24    28    32    36    40    44    48 50    54    58 60    64    68 70    74    78    82    86 88    92    96   100102   106   110   114   118   122   126128   132   136   140142   146148   152154   158160   164   168170   174176   180   184186   190   194   198200   204   208   212214
END
END2
