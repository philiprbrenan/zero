#!/usr/bin/perl -I/home/phil/perl/cpan/DataTableText/lib/
#-------------------------------------------------------------------------------
# Push Zero code to GitHub
# Philip R Brenan at gmail dot com, Appa Apps Ltd Inc., 2023
#-------------------------------------------------------------------------------
use v5.30;
use warnings FATAL => qw(all);
use strict;
use Carp;
use Data::Dump qw(dump);
use Data::Table::Text qw(:all);

makeDieConfess;

my $home = q(/home/phil/perl/cpan/ZeroEmulator/verilog/fpga1/);                 # Local files
my $bin  = q(/home/phil/intelFPGA_lite/22.1std/quartus/bin);                    # Quartus commands

my $PROJECT        = q(fpga1);
my $TOP_LEVEL_FILE = q(fpga1.sv);
my $FAMILY         = "Cyclone V";
my $PART           = "EP3C10F256C8";
my $PACKING_OPTION = "minimize_area";

xxx(qq($bin/quartus_map "$PROJECT" --source="$TOP_LEVEL_FILE" --family="$FAMILY"));
#xxx(qq($bin/quartus_fit "$PROJECT" --part=$PART --pack_register=$PACKING_OPTION));
#xxx(qq($bin/quartus_asm "$PROJECT"));
#xxx(qq($bin/quartus_sta "$PROJECT"));
