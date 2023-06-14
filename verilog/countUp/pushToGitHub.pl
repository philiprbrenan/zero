#!/usr/bin/perl -I/home/phil/perl/cpan/DataTableText/lib/
#-------------------------------------------------------------------------------
# Build project
# Philip R Brenan at gmail dot com, Appa Apps Ltd Inc., 2023
#-------------------------------------------------------------------------------
use v5.28;
use warnings FATAL => qw(all);
use strict;
use Carp;
use Data::Dump qw(dump);
use Data::Table::Text qw(:all);

makeDieConfess;

my $home    = q(/home/phil/perl/cpan/ZeroEmulator/verilog/countUp/);            # Local folder
my $yosys   = q(/home/phil/z/yosys/oss-cad-suite/bin/yosys);                    # Yosys
my $nextpnr = q(/home/phil/z/yosys/oss-cad-suite/bin/nextpnr-gowin);            # Next pnr
my $pack    = q(/home/phil/z/yosys/oss-cad-suite/bin/gowin_pack);               # Pack
my $m       = q(countUp);                                                       # Module
my $v       = fpe $home, $m, q(sv);                                             # Source file
my $j       = fpe $home, $m, qw(json);                                          # Json descrtiption
my $p       = fpe $home, $m, qw(pnr);                                           # Place and route
my $d       = qq(GW1NR-LV9QN88PC6/I5);                                          # Device
my $b       = q(/home/phil/perl/cpan/ZeroEmulator/verilog/countUp/tangnano9k.cst); # Device description

unlink $j; unlink $p;

xxx(qq($yosys -p "read_verilog $v; synth_gowin -top countUp -json $j"));
xxx(qq($nextpnr -v --json $j --write $p --device "$d" --family GW1N-9C --cst $b));
xxx(qq($pack -d GW1N-9C -o pack.fs $p));

# /home/phil/z/yosys/oss-cad-suite/bin/nextpnr-gowin
# ERROR: Invalid device GW1NR-9 C6/I5
