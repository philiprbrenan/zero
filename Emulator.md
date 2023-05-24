# Name

Zero::Emulator - Assemble and emulate a program written in the [Zero](https://github.com/philiprbrenan/zero) assembler programming language.

<div>

    <p><a href="https://github.com/philiprbrenan/zero"><img src="https://github.com/philiprbrenan/zero/workflows/Test/badge.svg"></a>
</div>

# Synopsis

Say "hello world":

    Start 1;

    Out "Hello World";

    my $e = Execute;

    is_deeply $e->out, <<END;
  Hello World
  END

# Description

Version 20230519.

The following sections describe the methods in each functional area of this
module.  For an alphabetic listing of all methods by name see [Index](#index).

# Instruction Set

The instruction set used by the Zero assembler programming language.

## Add($target, $s1, $s2)

Add the source locations together and store the result in the target area.

       Parameter  Description
    1  $target    Target address
    2  $s1        Source one
    3  $s2        Source two

**Example:**

    if (1)                                                                          
     {Start 1;
    
      my $a = Add 3, 2;  # 𝗘𝘅𝗮𝗺𝗽𝗹𝗲

      Out  $a;
      my $e = &$ee(suppressOutput=>1);
      is_deeply $e->outLines, [5];
     }
    

## Array($source)

Create a new memory area and write its number into the address named by the target operand.

       Parameter  Description
    1  $source    Name of allocation

**Example:**

    if (1)                                                                             
     {Start 1;
    
      my $a = Array "aaa";  # 𝗘𝘅𝗮𝗺𝗽𝗹𝗲

      Parallel
        sub{Mov [$a, 0, "aaa"], 1},
        sub{Mov [$a, 1, "aaa"], 22},
        sub{Mov [$a, 2, "aaa"], 333};
    
      my $n = ArraySize $a, "aaa";
    
      Out "Array size:", $n;  # 𝗘𝘅𝗮𝗺𝗽𝗹𝗲

      ArrayDump $a;
    
      ForArray
       {my ($i, $e, $check, $next, $end) = @_;
        Out $i; Out $e;
       }  $a, "aaa";
    
      Nop;
      my $e = Execute(suppressOutput=>1);
    
      is_deeply $e->heap(1), [1, 22, 333];
      is_deeply $e->out, <<END if $testSet <= 2;
    
    Array size: 3  # 𝗘𝘅𝗮𝗺𝗽𝗹𝗲

    bless([1, 22, 333], "aaa")
    0
    1
    1
    22
    2
    333
    END
      is_deeply $e->out, <<END if $testSet  > 2;
    
    Array size: 3  # 𝗘𝘅𝗮𝗺𝗽𝗹𝗲

    [1, 22, 333]
    0
    1
    1
    22
    2
    333
    END
     }
    

## ArrayCountLess()

Count the number of elements in the array specified by the first source operand that are less than the element supplied by the second source operand and place the result in the target location.

**Example:**

    if (1)                                                                            
     {Start 1;
      my $a = Array "aaa";
      Mov [$a, 0, "aaa"], 10;
      Mov [$a, 1, "aaa"], 20;
      Mov [$a, 2, "aaa"], 30;
    
      Out ArrayIndex       ($a, 30), ArrayIndex       ($a, 20), ArrayIndex       ($a, 10), ArrayIndex       ($a, 15);
    
      Out ArrayCountLess   ($a, 35), ArrayCountLess   ($a, 25), ArrayCountLess   ($a, 15), ArrayCountLess   ($a,  5);  # 𝗘𝘅𝗮𝗺𝗽𝗹𝗲

      Out ArrayCountGreater($a, 35), ArrayCountGreater($a, 25), ArrayCountGreater($a, 15), ArrayCountGreater($a,  5);
    
      my $e = Execute(suppressOutput=>1);
      is_deeply $e->out, <<END;
    3 2 1 0
    3 2 1 0
    0 1 2 3
    END
     }
    

## ArrayCountGreater()

Count the number of elements in the array specified by the first source operand that are greater than the element supplied by the second source operand and place the result in the target location.

**Example:**

    if (1)                                                                            
     {Start 1;
      my $a = Array "aaa";
      Mov [$a, 0, "aaa"], 10;
      Mov [$a, 1, "aaa"], 20;
      Mov [$a, 2, "aaa"], 30;
    
      Out ArrayIndex       ($a, 30), ArrayIndex       ($a, 20), ArrayIndex       ($a, 10), ArrayIndex       ($a, 15);
      Out ArrayCountLess   ($a, 35), ArrayCountLess   ($a, 25), ArrayCountLess   ($a, 15), ArrayCountLess   ($a,  5);
    
      Out ArrayCountGreater($a, 35), ArrayCountGreater($a, 25), ArrayCountGreater($a, 15), ArrayCountGreater($a,  5);  # 𝗘𝘅𝗮𝗺𝗽𝗹𝗲

    
      my $e = Execute(suppressOutput=>1);
      is_deeply $e->out, <<END;
    3 2 1 0
    3 2 1 0
    0 1 2 3
    END
     }
    

## ArrayDump($target)

Dump an array.

       Parameter  Description
    1  $target    Array to dump

**Example:**

    if (1)                                                                           
     {Start 1;
      my $a = Array "aaa";
      Mov [$a, 0, "aaa"], 1;
      Mov [$a, 1, "aaa"], 22;
      Mov [$a, 2, "aaa"], 333;
    
      ArrayDump $a;  # 𝗘𝘅𝗮𝗺𝗽𝗹𝗲

      my $e = &$ee(suppressOutput=>1);
    
      is_deeply eval($e->out), [1, 22, 333];
    
      is_deeply $e->block->codeToString, <<'END' if $testSet == 1;
    0000     array           \0             3
    0001       mov [\0, \0, 3, 0]             1
    0002       mov [\0, \1, 3, 0]            22
    0003       mov [\0, \2, 3, 0]           333
    0004  arrayDump           \0
    END
    
      is_deeply $e->block->codeToString, <<'END' if $testSet == 2;
    0000     array [undef, \0, 3, 0]  [undef, 3, 3, 0]  [undef, 0, 3, 0]
    0001       mov [\0, \0, 3, 0]  [undef, 1, 3, 0]  [undef, 0, 3, 0]
    0002       mov [\0, \1, 3, 0]  [undef, 22, 3, 0]  [undef, 0, 3, 0]
    0003       mov [\0, \2, 3, 0]  [undef, 333, 3, 0]  [undef, 0, 3, 0]
    0004  arrayDump [undef, \0, 3, 0]  [undef, 0, 3, 0]  [undef, 0, 3, 0]
    END
     }
    

## ArrayIndex()

Find the 1 based index of the second source operand in the array referenced by the first source operand if it is present in the array else 0 into the target location.  The business of returning -1 would have led to the confusion of "try catch" and we certainly do not want that.

**Example:**

    if (1)                                                                            
     {Start 1;
      my $a = Array "aaa";
      Mov [$a, 0, "aaa"], 10;
      Mov [$a, 1, "aaa"], 20;
      Mov [$a, 2, "aaa"], 30;
    
    
      Out ArrayIndex       ($a, 30), ArrayIndex       ($a, 20), ArrayIndex       ($a, 10), ArrayIndex       ($a, 15);  # 𝗘𝘅𝗮𝗺𝗽𝗹𝗲

      Out ArrayCountLess   ($a, 35), ArrayCountLess   ($a, 25), ArrayCountLess   ($a, 15), ArrayCountLess   ($a,  5);
      Out ArrayCountGreater($a, 35), ArrayCountGreater($a, 25), ArrayCountGreater($a, 15), ArrayCountGreater($a,  5);
    
      my $e = Execute(suppressOutput=>1);
      is_deeply $e->out, <<END;
    3 2 1 0
    3 2 1 0
    0 1 2 3
    END
     }
    

## ArraySize($area, $name)

The current size of an array.

       Parameter  Description
    1  $area      Location of area
    2  $name      Name of area

**Example:**

    if (1)                                                                             
     {Start 1;
      my $a = Array "aaa";
      Parallel
        sub{Mov [$a, 0, "aaa"], 1},
        sub{Mov [$a, 1, "aaa"], 22},
        sub{Mov [$a, 2, "aaa"], 333};
    
    
      my $n = ArraySize $a, "aaa";  # 𝗘𝘅𝗮𝗺𝗽𝗹𝗲

      Out "Array size:", $n;
      ArrayDump $a;
    
      ForArray
       {my ($i, $e, $check, $next, $end) = @_;
        Out $i; Out $e;
       }  $a, "aaa";
    
      Nop;
      my $e = Execute(suppressOutput=>1);
    
      is_deeply $e->heap(1), [1, 22, 333];
      is_deeply $e->out, <<END if $testSet <= 2;
    Array size: 3
    bless([1, 22, 333], "aaa")
    0
    1
    1
    22
    2
    333
    END
      is_deeply $e->out, <<END if $testSet  > 2;
    Array size: 3
    [1, 22, 333]
    0
    1
    1
    22
    2
    333
    END
     }
    

## Assert(%options)

Assert regardless.

       Parameter  Description
    1  %options   Options

**Example:**

    if (1)                                                                          
     {Start 1;
    
      Assert;  # 𝗘𝘅𝗮𝗺𝗽𝗹𝗲

      my $e = &$ee(suppressOutput=>1);
      is_deeply $e->out, <<END;
    
    Assert failed  # 𝗘𝘅𝗮𝗺𝗽𝗹𝗲

        1     1 assert
    END
     }
    

## AssertEq($a, $b, %options)

Assert two memory locations are equal.

       Parameter  Description
    1  $a         First memory address
    2  $b         Second memory address
    3  %options

**Example:**

    if (1)                                                                          
     {Start 1;
      Mov 0, 1;
    
      AssertEq \0, 2;  # 𝗘𝘅𝗮𝗺𝗽𝗹𝗲

      my $e = &$ee(suppressOutput=>1);
      is_deeply $e->out, <<END;
    Assert 1 == 2 failed
        1     2 assertEq
    END
     }
    

## AssertFalse($a, %options)

Assert false.

       Parameter  Description
    1  $a         Source operand
    2  %options

**Example:**

    if (1)                                                                          
     {Start 1;
      AssertTrue  1;
    
      AssertFalse 1;  # 𝗘𝘅𝗮𝗺𝗽𝗹𝗲

      my $e = &$ee(suppressOutput=>1, trace=>1);
    
      is_deeply $e->out, <<END;
        1     0     0    assertTrue
    
    AssertFalse 1 failed  # 𝗘𝘅𝗮𝗺𝗽𝗹𝗲

        1     2 assertFalse
        2     1     0   assertFalse
    END
     }
    

## AssertGe($a, $b, %options)

Assert that the first value is greater than or equal to the second value.

       Parameter  Description
    1  $a         First memory address
    2  $b         Second memory address
    3  %options

**Example:**

    if (1)                                                                          
     {Start 1;
      Mov 0, 1;
    
      AssertGe \0, 2;  # 𝗘𝘅𝗮𝗺𝗽𝗹𝗲

      my $e = &$ee(suppressOutput=>1);
      is_deeply $e->out, <<END;
    Assert 1 >= 2 failed
        1     2 assertGe
    END
     }
    

## AssertGt($a, $b, %options)

Assert that the first value is greater than the second value.

       Parameter  Description
    1  $a         First memory address
    2  $b         Second memory address
    3  %options

**Example:**

    if (1)                                                                          
     {Start 1;
      Mov 0, 1;
    
      AssertGt \0, 2;  # 𝗘𝘅𝗮𝗺𝗽𝗹𝗲

      my $e = &$ee(suppressOutput=>1);
      is_deeply $e->out, <<END;
    Assert 1 >  2 failed
        1     2 assertGt
    END
     }
    

## AssertLe($a, $b, %options)

Assert that the first value is less than or equal to the second value.

       Parameter  Description
    1  $a         First memory address
    2  $b         Second memory address
    3  %options

**Example:**

    if (1)                                                                          
     {Start 1;
      Mov 0, 1;
    
      AssertLe \0, 0;  # 𝗘𝘅𝗮𝗺𝗽𝗹𝗲

      my $e = &$ee(suppressOutput=>1);
      is_deeply $e->out, <<END;
    Assert 1 <= 0 failed
        1     2 assertLe
    END
     }
    

## AssertLt($a, $b, %options)

Assert that the first value is less than  the second value.

       Parameter  Description
    1  $a         First memory address
    2  $b         Second memory address
    3  %options

**Example:**

    if (1)                                                                          
     {Start 1;
      Mov 0, 1;
    
      AssertLt \0, 0;  # 𝗘𝘅𝗮𝗺𝗽𝗹𝗲

      my $e = &$ee(suppressOutput=>1);
      is_deeply $e->out, <<END;
    Assert 1 <  0 failed
        1     2 assertLt
    END
     }
    

## AssertNe($a, $b, %options)

Assert two memory locations are not equal.

       Parameter  Description
    1  $a         First memory address
    2  $b         Second memory address
    3  %options

**Example:**

    if (1)                                                                          
     {Start 1;
      Mov 0, 1;
    
      AssertNe \0, 1;  # 𝗘𝘅𝗮𝗺𝗽𝗹𝗲

      my $e = &$ee(suppressOutput=>1);
      is_deeply $e->out, <<END;
    Assert 1 != 1 failed
        1     2 assertNe
    END
     }
    

## AssertTrue($a, %options)

Assert true.

       Parameter  Description
    1  $a         Source operand
    2  %options

**Example:**

    if (1)                                                                          
     {Start 1;
      AssertFalse 0;
    
      AssertTrue  0;  # 𝗘𝘅𝗮𝗺𝗽𝗹𝗲

      my $e = &$ee(suppressOutput=>1, trace=>1);
      is_deeply $e->out, <<END;
        1     0     0   assertFalse
    
    AssertTrue 0 failed  # 𝗘𝘅𝗮𝗺𝗽𝗹𝗲

        1     2 assertTrue
        2     1     0    assertTrue
    END
     }
    

## Bad($bad)

A bad ending to a block of code.

       Parameter  Description
    1  $bad       What to do on a bad ending

**Example:**

    if (1)                                                                            
     {Start 1;
      Block
       {my ($start, $good, $bad, $end) = @_;
        Out 1;
        Jmp $good;
       }
      Good
       {Out 2;
       },
    
      Bad  # 𝗘𝘅𝗮𝗺𝗽𝗹𝗲

       {Out 3;
       };
      Out 4;
      my $e = &$ee(suppressOutput=>1);
      is_deeply $e->out, <<END;
    1
    2
    4
    END
     }
    

## Block($block, %options)

Block of code that can either be restarted or come to a good or a bad ending.

       Parameter  Description
    1  $block     Block
    2  %options   Options

**Example:**

    if (1)                                                                            
     {Start 1;
    
      Block  # 𝗘𝘅𝗮𝗺𝗽𝗹𝗲

       {my ($start, $good, $bad, $end) = @_;
        Out 1;
        Jmp $good;
       }
      Good
       {Out 2;
       },
      Bad
       {Out 3;
       };
      Out 4;
      my $e = &$ee(suppressOutput=>1);
      is_deeply $e->out, <<END;
    1
    2
    4
    END
     }
    
    if (1)                                                                          
     {Start 1;
    
      Block  # 𝗘𝘅𝗮𝗺𝗽𝗹𝗲

       {my ($start, $good, $bad, $end) = @_;
        Out 1;
        Jmp $bad;
       }
      Good
       {Out 2;
       },
      Bad
       {Out 3;
       };
      Out 4;
      my $e = &$ee(suppressOutput=>1);
      is_deeply $e->out, <<END;
    1
    3
    4
    END
     }
    

## Call($p)

Call the subroutine at the target address.

       Parameter  Description
    1  $p         Procedure description.

**Example:**

    if (1)                                                                           
     {Start 1;
      my $w = Procedure 'write', sub
       {Out 1;
        Return;
       };
    
      Call $w;  # 𝗘𝘅𝗮𝗺𝗽𝗹𝗲

      my $e = &$ee(suppressOutput=>1);
      is_deeply $e->outLines, [1];
     }
    
    if (1)                                                                          
     {Start 1;
      my $w = Procedure 'write', sub
       {my $a = ParamsGet 0;
        Out $a;
        Return;
       };
      ParamsPut 0, 999;
    
      Call $w;  # 𝗘𝘅𝗮𝗺𝗽𝗹𝗲

      my $e = &$ee(suppressOutput=>1);
      is_deeply $e->outLines, [999];
     }
    
    if (1)                                                                            
     {Start 1;
      my $w = Procedure 'write', sub
       {ReturnPut 0, 999;
        Return;
       };
    
      Call $w;  # 𝗘𝘅𝗮𝗺𝗽𝗹𝗲

      ReturnGet \0, 0;
      Out \0;
      my $e = &$ee(suppressOutput=>1);
      is_deeply $e->outLines, [999];
     }
    
    if (1)                                                                            
     {Start 1;
      my $a = Array "aaa";
      Dump;
      my $e = Execute(suppressOutput=>1);
      is_deeply $e->out, <<END;
    Stack trace:
        1     2 dump
    END
     }
    
    if (1)                                                                              
     {Start 1;
      my $a = Array "aaa";
      my $i = Mov 1;
      my $v = Mov 11;
      ParamsPut 0, $a;
      ParamsPut 1, $i;
      ParamsPut 2, $v;
      my $set = Procedure 'set', sub
       {my $a = ParamsGet 0;
        my $i = ParamsGet 1;
        my $v = ParamsGet 2;
        Mov [$a, \$i, 'aaa'], $v;
        Return;
       };
    
      Call $set;  # 𝗘𝘅𝗮𝗺𝗽𝗹𝗲

      my $V = Mov [$a, \$i, 'aaa'];
      AssertEq $v, $V;
      Out [$a, \$i, 'aaa'];
      my $e = &$ee(suppressOutput=>1);
      is_deeply $e->outLines, [11];
     }
    
    if (1)                                                                            
     {Start 1;
      my $set = Procedure 'set', sub
       {my $a = ParamsGet 0;
        Out $a;
       };
    
      ParamsPut 0, 1;  Call $set;  # 𝗘𝘅𝗮𝗺𝗽𝗹𝗲

    
      ParamsPut 0, 2;  Call $set;  # 𝗘𝘅𝗮𝗺𝗽𝗹𝗲

    
      ParamsPut 0, 3;  Call $set;  # 𝗘𝘅𝗮𝗺𝗽𝗹𝗲

      my $e = &$ee(suppressOutput=>1);
      is_deeply $e->out, <<END;
    1
    2
    3
    END
     }
    

## Clear($target, $source, $source2)

Clear the first bytes of an area.  The area is specified by the first element of the address, the number of locations to clear is specified by the second element of the target address.

       Parameter  Description
    1  $target    Target address to clear
    2  $source    Number of bytes to clear
    3  $source2   Name of target

**Example:**

    if (1)                                                                           
     {Start 1;
      my $a = Array "aaa";
    
      Clear $a, 10, 'aaa';  # 𝗘𝘅𝗮𝗺𝗽𝗹𝗲

      my $e = &$ee(suppressOutput=>1, maximumArraySize=>10);
      is_deeply $e->heap(1), [0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
     }
    

## Confess()

Confess with a stack trace showing the location both in the emulated code and in the code that produced the emulated code.

**Example:**

    if (1)                                                                          
     {Start 1;
      my $c = Procedure 'confess', sub
    
       {Confess;  # 𝗘𝘅𝗮𝗺𝗽𝗹𝗲

       };
      Call $c;
      my $e = &$ee(suppressOutput=>1);
      is_deeply $e->out, <<END;
    
    Confess at:  # 𝗘𝘅𝗮𝗺𝗽𝗹𝗲

        2     3 confess
        1     6 call
    END
     }
    

## Dec($target)

Decrement the target.

       Parameter  Description
    1  $target    Target address

**Example:**

    if (1)                                                                          
     {Start 1;
      my $a = Mov 3;
    
      Dec $a;  # 𝗘𝘅𝗮𝗺𝗽𝗹𝗲

      Out $a;
      my $e = &$ee(suppressOutput=>1);
      is_deeply $e->outLines, [2];
     }
    

## Dump()

Dump all the arrays currently in memory.

**Example:**

    if (1)                                                                           
     {Start 1;
      my $a = Array "node";
      Out $a;
      Mov [$a, 1, 'node'], 1;
      Mov [$a, 2, 'node'], 2;
      Mov 1, [$a, \1, 'node'];
    
      Dump;  # 𝗘𝘅𝗮𝗺𝗽𝗹𝗲

      Free $a, "node";
      my $e = Execute(suppressOutput=>1);
      is_deeply $e->out, <<END if $testSet <= 2;
    1
    1=bless([undef, 1, 2], "node")
    Stack trace:
        1     6 dump
    END
      is_deeply $e->out, <<END if $testSet >  2;
    1
    1=[0, 1, 2]
    Stack trace:
        1     6 dump
    END
     }
    

## Else($e)

Else block.

       Parameter  Description
    1  $e         Else block subroutine

**Example:**

    if (1)                                                                            
     {Start 1;
      IfFalse 1,
      Then
       {Out 1
       },
    
      Else  # 𝗘𝘅𝗮𝗺𝗽𝗹𝗲

       {Out 0
       };
      my $e = &$ee(suppressOutput=>1);
      is_deeply $e->outLines, [0];
     }
    
    if (1)                                                                            
     {Start 1;
      Trace 1;
      IfEq 1, 2,
      Then
       {Mov 1, 1;
        Mov 2, 1;
       },
    
      Else  # 𝗘𝘅𝗮𝗺𝗽𝗹𝗲

       {Mov 3, 3;
        Mov 4, 4;
       };
      IfEq 2, 2,
      Then
       {Mov 1, 1;
        Mov 2, 1;
       },
    
      Else  # 𝗘𝘅𝗮𝗺𝗽𝗹𝗲

       {Mov 3, 3;
        Mov 4, 4;
       };
      my $e = &$ee(suppressOutput=>1);
      is_deeply $e->out, <<END;
    Trace: 1
        1     0     0         trace
        2     1     1           jNe
        3     5     0         label
        4     6     1           mov  [1, 3, stackArea] = 3
        5     7     1           mov  [1, 4, stackArea] = 4
        6     8     0         label
        7     9     1           jNe
        8    10     1           mov  [1, 1, stackArea] = 1
        9    11     1           mov  [1, 2, stackArea] = 1
       10    12     1           jmp
       11    16     0         label
    END
      my $E = &$ee(suppressOutput=>1);
      is_deeply $E->out, <<END;
    Trace: 1
        1     0     0         trace
        2     1     1           jNe
        3     5     0         label
        4     6     1           mov  [1, 3, stackArea] = 3
        5     7     1           mov  [1, 4, stackArea] = 4
        6     8     0         label
        7     9     1           jNe
        8    10     1           mov  [1, 1, stackArea] = 1
        9    11     1           mov  [1, 2, stackArea] = 1
       10    12     1           jmp
       11    16     0         label
    END
    
      is_deeply scalar($e->notExecuted->@*), 6;
      is_deeply scalar($E->notExecuted->@*), 6;
     }
    

## Execute(%options)

Execute the current assembly.

       Parameter  Description
    1  %options   Options

**Example:**

    if (1)                                                                            
     {Start 1;
      Out "Hello", "World";
    
      my $e = Execute(suppressOutput=>1);  # 𝗘𝘅𝗮𝗺𝗽𝗹𝗲

      is_deeply $e->out, <<END;
    Hello World
    END
     }
    

## For($block, $range, %options)

For loop 0..range-1 or in reverse.

       Parameter  Description
    1  $block     Block
    2  $range     Limit
    3  %options   Options

**Example:**

    if (1)                                                                          
     {Start 1;
    
      For  # 𝗘𝘅𝗮𝗺𝗽𝗹𝗲

       {my ($i) = @_;
        Out $i;
       } 10;
      my $e = &$ee(suppressOutput=>1);
      is_deeply $e->outLines, [0..9];
     }
    
    if (1)                                                                          
     {Start 1;
    
      For  # 𝗘𝘅𝗮𝗺𝗽𝗹𝗲

       {my ($i) = @_;
        Out $i;
       } 10, reverse=>1;
      my $e = &$ee(suppressOutput=>1);
      is_deeply $e->outLines, [reverse 0..9];
     }
    
    if (1)                                                                          
     {Start 1;
    
      For  # 𝗘𝘅𝗮𝗺𝗽𝗹𝗲

       {my ($i) = @_;
        Out $i;
       } [2, 10];
      my $e = &$ee(suppressOutput=>1);
      is_deeply $e->outLines, [2..9];
     }
    
    if (1)                                                                           
     {my $N = 5;
      Start 1;
    
      For  # 𝗘𝘅𝗮𝗺𝗽𝗹𝗲

       {Tally 1;
        my $a = Mov 1;
        Tally 2;
        Inc $a;
        Tally 0;
       } $N;
      my $e = Execute;
    
      is_deeply $e->tallyCount, 2 * $N;
      is_deeply $e->tallyCounts, { 1 => {mov => $N}, 2 => {add => $N}};
     }
    

## ForArray($block, $area, $name, %options)

For loop to process each element of the named area.

       Parameter  Description
    1  $block     Block of code
    2  $area      Area
    3  $name      Area name
    4  %options   Options

**Example:**

    if (1)                                                                             
     {Start 1;
      my $a = Array "aaa";
      Parallel
        sub{Mov [$a, 0, "aaa"], 1},
        sub{Mov [$a, 1, "aaa"], 22},
        sub{Mov [$a, 2, "aaa"], 333};
    
      my $n = ArraySize $a, "aaa";
      Out "Array size:", $n;
      ArrayDump $a;
    
    
      ForArray  # 𝗘𝘅𝗮𝗺𝗽𝗹𝗲

       {my ($i, $e, $check, $next, $end) = @_;
        Out $i; Out $e;
       }  $a, "aaa";
    
      Nop;
      my $e = Execute(suppressOutput=>1);
    
      is_deeply $e->heap(1), [1, 22, 333];
      is_deeply $e->out, <<END if $testSet <= 2;
    Array size: 3
    bless([1, 22, 333], "aaa")
    0
    1
    1
    22
    2
    333
    END
      is_deeply $e->out, <<END if $testSet  > 2;
    Array size: 3
    [1, 22, 333]
    0
    1
    1
    22
    2
    333
    END
     }
    

## ForIn($block, %options)

For loop to process each element remaining in the input channel

       Parameter  Description
    1  $block     Block of code
    2  %options   Area

**Example:**

    if (1)                                                                          
     {Start 1;
    
    
      ForIn  # 𝗘𝘅𝗮𝗺𝗽𝗹𝗲

       {my ($i, $e, $check, $next, $end) = @_;
        Out $i; Out $e;
       };
    
      my $e = Execute(suppressOutput=>1, in=>[333, 22, 1]);
      is_deeply $e->outLines, [0, 333,  1, 22, 2, 1];
     }
    

## Free($target, $source)

Free the memory area named by the target operand after confirming that it has the name specified on the source operand.

       Parameter  Description
    1  $target    Target area yielding the id of the area to be freed
    2  $source    Source area yielding the name of the area to be freed

**Example:**

    if (1)                                                                          
     {Start 1;
      my $a = Array "node";
    
      Free $a, "aaa";  # 𝗘𝘅𝗮𝗺𝗽𝗹𝗲

      my $e = Execute(suppressOutput=>1);
      is_deeply $e->out, <<END;
    Wrong name: aaa for array with name: node
        1     2 free
    END
     }
    
    if (1)                                                                           
     {Start 1;
      my $a = Array "node";
      Out $a;
      Mov [$a, 1, 'node'], 1;
      Mov [$a, 2, 'node'], 2;
      Mov 1, [$a, \1, 'node'];
      Dump;
    
      Free $a, "node";  # 𝗘𝘅𝗮𝗺𝗽𝗹𝗲

      my $e = Execute(suppressOutput=>1);
      is_deeply $e->out, <<END if $testSet <= 2;
    1
    1=bless([undef, 1, 2], "node")
    Stack trace:
        1     6 dump
    END
      is_deeply $e->out, <<END if $testSet >  2;
    1
    1=[0, 1, 2]
    Stack trace:
        1     6 dump
    END
     }
    

## Good($good)

A good ending to a block of code.

       Parameter  Description
    1  $good      What to do on a good ending

**Example:**

    if (1)                                                                            
     {Start 1;
      Block
       {my ($start, $good, $bad, $end) = @_;
        Out 1;
        Jmp $good;
       }
    
      Good  # 𝗘𝘅𝗮𝗺𝗽𝗹𝗲

       {Out 2;
       },
      Bad
       {Out 3;
       };
      Out 4;
      my $e = &$ee(suppressOutput=>1);
      is_deeply $e->out, <<END;
    1
    2
    4
    END
     }
    

## IfEq($a, $b, %options)

Execute then or else clause depending on whether two memory locations are equal.

       Parameter  Description
    1  $a         First memory address
    2  $b         Second memory address
    3  %options   Then block

**Example:**

    if (1)                                                                                   
     {Start 1;
      my $a = Mov 1;
      my $b = Mov 2;
    
      IfEq $a, $a, Then {Out "Eq"};  # 𝗘𝘅𝗮𝗺𝗽𝗹𝗲

      IfNe $a, $a, Then {Out "Ne"};
      IfLe $a, $a, Then {Out "Le"};
      IfLt $a, $a, Then {Out "Lt"};
      IfGe $a, $a, Then {Out "Ge"};
      IfGt $a, $a, Then {Out "Gt"};
      my $e = Execute(suppressOutput=>1);
      is_deeply $e->out, <<END;
    Eq
    Le
    Ge
    END
     }
    
    if (1)                                                                                   
     {Start 1;
      my $a = Mov 1;
      my $b = Mov 2;
    
      IfEq $a, $b, Then {Out "Eq"};  # 𝗘𝘅𝗮𝗺𝗽𝗹𝗲

      IfNe $a, $b, Then {Out "Ne"};
      IfLe $a, $b, Then {Out "Le"};
      IfLt $a, $b, Then {Out "Lt"};
      IfGe $a, $b, Then {Out "Ge"};
      IfGt $a, $b, Then {Out "Gt"};
      my $e = Execute(suppressOutput=>1);
      is_deeply $e->out, <<END;
    Ne
    Le
    Lt
    END
     }
    
    if (1)                                                                                   
     {Start 1;
      my $a = Mov 1;
      my $b = Mov 2;
    
      IfEq $b, $a, Then {Out "Eq"};  # 𝗘𝘅𝗮𝗺𝗽𝗹𝗲

      IfNe $b, $a, Then {Out "Ne"};
      IfLe $b, $a, Then {Out "Le"};
      IfLt $b, $a, Then {Out "Lt"};
      IfGe $b, $a, Then {Out "Ge"};
      IfGt $b, $a, Then {Out "Gt"};
      my $e = Execute(suppressOutput=>1);
      is_deeply $e->out, <<END;
    Ne
    Ge
    Gt
    END
     }
    

## IfFalse($a, %options)

Execute then clause if the specified memory address is zero thus representing false.

       Parameter  Description
    1  $a         Memory address
    2  %options   Then block

**Example:**

    if (1)                                                                            
     {Start 1;
    
      IfFalse 1,  # 𝗘𝘅𝗮𝗺𝗽𝗹𝗲

      Then
       {Out 1
       },
      Else
       {Out 0
       };
      my $e = &$ee(suppressOutput=>1);
      is_deeply $e->outLines, [0];
     }
    

## IfGe($a, $b, %options)

Execute then or else clause depending on whether two memory locations are greater than or equal.

       Parameter  Description
    1  $a         First memory address
    2  $b         Second memory address
    3  %options   Then block

**Example:**

    if (1)                                                                                   
     {Start 1;
      my $a = Mov 1;
      my $b = Mov 2;
      IfEq $a, $a, Then {Out "Eq"};
      IfNe $a, $a, Then {Out "Ne"};
      IfLe $a, $a, Then {Out "Le"};
      IfLt $a, $a, Then {Out "Lt"};
    
      IfGe $a, $a, Then {Out "Ge"};  # 𝗘𝘅𝗮𝗺𝗽𝗹𝗲

      IfGt $a, $a, Then {Out "Gt"};
      my $e = Execute(suppressOutput=>1);
      is_deeply $e->out, <<END;
    Eq
    Le
    Ge
    END
     }
    
    if (1)                                                                                   
     {Start 1;
      my $a = Mov 1;
      my $b = Mov 2;
      IfEq $a, $b, Then {Out "Eq"};
      IfNe $a, $b, Then {Out "Ne"};
      IfLe $a, $b, Then {Out "Le"};
      IfLt $a, $b, Then {Out "Lt"};
    
      IfGe $a, $b, Then {Out "Ge"};  # 𝗘𝘅𝗮𝗺𝗽𝗹𝗲

      IfGt $a, $b, Then {Out "Gt"};
      my $e = Execute(suppressOutput=>1);
      is_deeply $e->out, <<END;
    Ne
    Le
    Lt
    END
     }
    
    if (1)                                                                                   
     {Start 1;
      my $a = Mov 1;
      my $b = Mov 2;
      IfEq $b, $a, Then {Out "Eq"};
      IfNe $b, $a, Then {Out "Ne"};
      IfLe $b, $a, Then {Out "Le"};
      IfLt $b, $a, Then {Out "Lt"};
    
      IfGe $b, $a, Then {Out "Ge"};  # 𝗘𝘅𝗮𝗺𝗽𝗹𝗲

      IfGt $b, $a, Then {Out "Gt"};
      my $e = Execute(suppressOutput=>1);
      is_deeply $e->out, <<END;
    Ne
    Ge
    Gt
    END
     }
    

## IfGt($a, $b, %options)

Execute then or else clause depending on whether two memory locations are greater than.

       Parameter  Description
    1  $a         First memory address
    2  $b         Second memory address
    3  %options   Then block

**Example:**

    if (1)                                                                                   
     {Start 1;
      my $a = Mov 1;
      my $b = Mov 2;
      IfEq $a, $a, Then {Out "Eq"};
      IfNe $a, $a, Then {Out "Ne"};
      IfLe $a, $a, Then {Out "Le"};
      IfLt $a, $a, Then {Out "Lt"};
      IfGe $a, $a, Then {Out "Ge"};
    
      IfGt $a, $a, Then {Out "Gt"};  # 𝗘𝘅𝗮𝗺𝗽𝗹𝗲

      my $e = Execute(suppressOutput=>1);
      is_deeply $e->out, <<END;
    Eq
    Le
    Ge
    END
     }
    
    if (1)                                                                                   
     {Start 1;
      my $a = Mov 1;
      my $b = Mov 2;
      IfEq $a, $b, Then {Out "Eq"};
      IfNe $a, $b, Then {Out "Ne"};
      IfLe $a, $b, Then {Out "Le"};
      IfLt $a, $b, Then {Out "Lt"};
      IfGe $a, $b, Then {Out "Ge"};
    
      IfGt $a, $b, Then {Out "Gt"};  # 𝗘𝘅𝗮𝗺𝗽𝗹𝗲

      my $e = Execute(suppressOutput=>1);
      is_deeply $e->out, <<END;
    Ne
    Le
    Lt
    END
     }
    
    if (1)                                                                                   
     {Start 1;
      my $a = Mov 1;
      my $b = Mov 2;
      IfEq $b, $a, Then {Out "Eq"};
      IfNe $b, $a, Then {Out "Ne"};
      IfLe $b, $a, Then {Out "Le"};
      IfLt $b, $a, Then {Out "Lt"};
      IfGe $b, $a, Then {Out "Ge"};
    
      IfGt $b, $a, Then {Out "Gt"};  # 𝗘𝘅𝗮𝗺𝗽𝗹𝗲

      my $e = Execute(suppressOutput=>1);
      is_deeply $e->out, <<END;
    Ne
    Ge
    Gt
    END
     }
    

## IfNe($a, $b, %options)

Execute then or else clause depending on whether two memory locations are not equal.

       Parameter  Description
    1  $a         First memory address
    2  $b         Second memory address
    3  %options   Then block

**Example:**

    if (1)                                                                                   
     {Start 1;
      my $a = Mov 1;
      my $b = Mov 2;
      IfEq $a, $a, Then {Out "Eq"};
    
      IfNe $a, $a, Then {Out "Ne"};  # 𝗘𝘅𝗮𝗺𝗽𝗹𝗲

      IfLe $a, $a, Then {Out "Le"};
      IfLt $a, $a, Then {Out "Lt"};
      IfGe $a, $a, Then {Out "Ge"};
      IfGt $a, $a, Then {Out "Gt"};
      my $e = Execute(suppressOutput=>1);
      is_deeply $e->out, <<END;
    Eq
    Le
    Ge
    END
     }
    
    if (1)                                                                                   
     {Start 1;
      my $a = Mov 1;
      my $b = Mov 2;
      IfEq $a, $b, Then {Out "Eq"};
    
      IfNe $a, $b, Then {Out "Ne"};  # 𝗘𝘅𝗮𝗺𝗽𝗹𝗲

      IfLe $a, $b, Then {Out "Le"};
      IfLt $a, $b, Then {Out "Lt"};
      IfGe $a, $b, Then {Out "Ge"};
      IfGt $a, $b, Then {Out "Gt"};
      my $e = Execute(suppressOutput=>1);
      is_deeply $e->out, <<END;
    Ne
    Le
    Lt
    END
     }
    
    if (1)                                                                                   
     {Start 1;
      my $a = Mov 1;
      my $b = Mov 2;
      IfEq $b, $a, Then {Out "Eq"};
    
      IfNe $b, $a, Then {Out "Ne"};  # 𝗘𝘅𝗮𝗺𝗽𝗹𝗲

      IfLe $b, $a, Then {Out "Le"};
      IfLt $b, $a, Then {Out "Lt"};
      IfGe $b, $a, Then {Out "Ge"};
      IfGt $b, $a, Then {Out "Gt"};
      my $e = Execute(suppressOutput=>1);
      is_deeply $e->out, <<END;
    Ne
    Ge
    Gt
    END
     }
    

## IfLe($a, $b, %options)

Execute then or else clause depending on whether two memory locations are less than or equal.

       Parameter  Description
    1  $a         First memory address
    2  $b         Second memory address
    3  %options   Then block

**Example:**

    if (1)                                                                                   
     {Start 1;
      my $a = Mov 1;
      my $b = Mov 2;
      IfEq $a, $a, Then {Out "Eq"};
      IfNe $a, $a, Then {Out "Ne"};
    
      IfLe $a, $a, Then {Out "Le"};  # 𝗘𝘅𝗮𝗺𝗽𝗹𝗲

      IfLt $a, $a, Then {Out "Lt"};
      IfGe $a, $a, Then {Out "Ge"};
      IfGt $a, $a, Then {Out "Gt"};
      my $e = Execute(suppressOutput=>1);
      is_deeply $e->out, <<END;
    Eq
    Le
    Ge
    END
     }
    
    if (1)                                                                                   
     {Start 1;
      my $a = Mov 1;
      my $b = Mov 2;
      IfEq $a, $b, Then {Out "Eq"};
      IfNe $a, $b, Then {Out "Ne"};
    
      IfLe $a, $b, Then {Out "Le"};  # 𝗘𝘅𝗮𝗺𝗽𝗹𝗲

      IfLt $a, $b, Then {Out "Lt"};
      IfGe $a, $b, Then {Out "Ge"};
      IfGt $a, $b, Then {Out "Gt"};
      my $e = Execute(suppressOutput=>1);
      is_deeply $e->out, <<END;
    Ne
    Le
    Lt
    END
     }
    
    if (1)                                                                                   
     {Start 1;
      my $a = Mov 1;
      my $b = Mov 2;
      IfEq $b, $a, Then {Out "Eq"};
      IfNe $b, $a, Then {Out "Ne"};
    
      IfLe $b, $a, Then {Out "Le"};  # 𝗘𝘅𝗮𝗺𝗽𝗹𝗲

      IfLt $b, $a, Then {Out "Lt"};
      IfGe $b, $a, Then {Out "Ge"};
      IfGt $b, $a, Then {Out "Gt"};
      my $e = Execute(suppressOutput=>1);
      is_deeply $e->out, <<END;
    Ne
    Ge
    Gt
    END
     }
    

## IfLt($a, $b, %options)

Execute then or else clause depending on whether two memory locations are less than.

       Parameter  Description
    1  $a         First memory address
    2  $b         Second memory address
    3  %options   Then block

**Example:**

    if (1)                                                                                   
     {Start 1;
      my $a = Mov 1;
      my $b = Mov 2;
      IfEq $a, $a, Then {Out "Eq"};
      IfNe $a, $a, Then {Out "Ne"};
      IfLe $a, $a, Then {Out "Le"};
    
      IfLt $a, $a, Then {Out "Lt"};  # 𝗘𝘅𝗮𝗺𝗽𝗹𝗲

      IfGe $a, $a, Then {Out "Ge"};
      IfGt $a, $a, Then {Out "Gt"};
      my $e = Execute(suppressOutput=>1);
      is_deeply $e->out, <<END;
    Eq
    Le
    Ge
    END
     }
    
    if (1)                                                                                   
     {Start 1;
      my $a = Mov 1;
      my $b = Mov 2;
      IfEq $a, $b, Then {Out "Eq"};
      IfNe $a, $b, Then {Out "Ne"};
      IfLe $a, $b, Then {Out "Le"};
    
      IfLt $a, $b, Then {Out "Lt"};  # 𝗘𝘅𝗮𝗺𝗽𝗹𝗲

      IfGe $a, $b, Then {Out "Ge"};
      IfGt $a, $b, Then {Out "Gt"};
      my $e = Execute(suppressOutput=>1);
      is_deeply $e->out, <<END;
    Ne
    Le
    Lt
    END
     }
    
    if (1)                                                                                   
     {Start 1;
      my $a = Mov 1;
      my $b = Mov 2;
      IfEq $b, $a, Then {Out "Eq"};
      IfNe $b, $a, Then {Out "Ne"};
      IfLe $b, $a, Then {Out "Le"};
    
      IfLt $b, $a, Then {Out "Lt"};  # 𝗘𝘅𝗮𝗺𝗽𝗹𝗲

      IfGe $b, $a, Then {Out "Ge"};
      IfGt $b, $a, Then {Out "Gt"};
      my $e = Execute(suppressOutput=>1);
      is_deeply $e->out, <<END;
    Ne
    Ge
    Gt
    END
     }
    

## IfTrue($a, %options)

Execute then clause if the specified memory address is not zero thus representing true.

       Parameter  Description
    1  $a         Memory address
    2  %options   Then block

**Example:**

    if (1)                                                                          
     {Start 1;
    
      IfTrue 1,  # 𝗘𝘅𝗮𝗺𝗽𝗹𝗲

      Then
       {Out 1
       },
      Else
       {Out 0
       };
      my $e = &$ee(suppressOutput=>1);
      is_deeply $e->outLines, [1];
     }
    

## In(if (@\_ == 0))

Read a value from the input channel

       Parameter     Description
    1  if (@_ == 0)  Create a new stack frame variable to hold the value read from input

**Example:**

    if (1)                                                                           
     {Start 1;
      my $i2 = InSize;
    
      my $a = In;  # 𝗘𝘅𝗮𝗺𝗽𝗹𝗲

      my $i1 = InSize;
    
      my $b = In;  # 𝗘𝘅𝗮𝗺𝗽𝗹𝗲

      my $i0 = InSize;
      Out $a;
      Out $b;
      Out $i2;
      Out $i1;
      Out $i0;
      my $e = Execute(suppressOutput=>1, in=>[88, 44]);
      is_deeply $e->outLines, [88, 44, 2, 1, 0];
     }
    

## InSize(if (@\_ == 0))

Number of elements remining in the input channel

       Parameter     Description
    1  if (@_ == 0)  Create a new stack frame variable to hold the value read from input

**Example:**

    if (1)                                                                           
     {Start 1;
    
      my $i2 = InSize;  # 𝗘𝘅𝗮𝗺𝗽𝗹𝗲

      my $a = In;
    
      my $i1 = InSize;  # 𝗘𝘅𝗮𝗺𝗽𝗹𝗲

      my $b = In;
    
      my $i0 = InSize;  # 𝗘𝘅𝗮𝗺𝗽𝗹𝗲

      Out $a;
      Out $b;
      Out $i2;
      Out $i1;
      Out $i0;
      my $e = Execute(suppressOutput=>1, in=>[88, 44]);
      is_deeply $e->outLines, [88, 44, 2, 1, 0];
     }
    

## Inc($target)

Increment the target.

       Parameter  Description
    1  $target    Target address

**Example:**

    if (1)                                                                          
     {Start 1;
      my $a = Mov 3;
    
      Inc $a;  # 𝗘𝘅𝗮𝗺𝗽𝗹𝗲

      Out $a;
      my $e = &$ee(suppressOutput=>1);
      is_deeply $e->outLines, [4];
     }
    

## Jeq($target, $source, $source2)

Jump to a target label if the first source field is equal to the second source field.

       Parameter  Description
    1  $target    Target label
    2  $source    Source to test
    3  $source2

**Example:**

    if (1)                                                                                 
     {Start 1;
      my $a = Array "aaa";
      my $b = Array "bbb";
      Mov [$a, 0, 'aaa'], $b;
      Mov [$b, 0, 'bbb'], 99;
    
      For
       {my ($i, $check, $next, $end) = @_;
        my $c = Mov [$a, \0, 'aaa'];
        my $d = Mov [$c, \0, 'bbb'];
    
        Jeq $next, $d, $d;  # 𝗘𝘅𝗮𝗺𝗽𝗹𝗲

        Jne $next, $d, $d;
        Jle $next, $d, $d;
        Jlt $next, $d, $d;
        Jge $next, $d, $d;
        Jgt $next, $d, $d;
       } 3;
    
      my $e = &$ee(suppressOutput=>1);
    
      is_deeply $e->analyzeExecutionResults(doubleWrite=>3), "#       24 instructions executed";
      is_deeply $e->heap(1), [2];
      is_deeply $e->heap(2), [99];
     }
    

## JFalse($target, $source)

Jump to a target label if the first source field is equal to zero.

       Parameter  Description
    1  $target    Target label
    2  $source    Source to test

**Example:**

    if (1)                                                                           
     {Start 1;
      my $a = Mov 1;
      Block
       {my ($start, $good, $bad, $end) = @_;
        JTrue $end, $a;
        Out 1;
       };
      Block
       {my ($start, $good, $bad, $end) = @_;
    
        JFalse $end, $a;  # 𝗘𝘅𝗮𝗺𝗽𝗹𝗲

        Out 2;
       };
      Mov $a, 0;
      Block
       {my ($start, $good, $bad, $end) = @_;
        JTrue $end, $a;
        Out 3;
       };
      Block
       {my ($start, $good, $bad, $end) = @_;
    
        JFalse $end, $a;  # 𝗘𝘅𝗮𝗺𝗽𝗹𝗲

        Out 4;
       };
      my $e = &$ee(suppressOutput=>1);
      is_deeply $e->out, <<END;
    2
    3
    END
     }
    

## Jge($target, $source, $source2)

Jump to a target label if the first source field is greater than or equal to the second source field.

       Parameter  Description
    1  $target    Target label
    2  $source    Source to test
    3  $source2

**Example:**

    if (1)                                                                                 
     {Start 1;
      my $a = Array "aaa";
      my $b = Array "bbb";
      Mov [$a, 0, 'aaa'], $b;
      Mov [$b, 0, 'bbb'], 99;
    
      For
       {my ($i, $check, $next, $end) = @_;
        my $c = Mov [$a, \0, 'aaa'];
        my $d = Mov [$c, \0, 'bbb'];
        Jeq $next, $d, $d;
        Jne $next, $d, $d;
        Jle $next, $d, $d;
        Jlt $next, $d, $d;
    
        Jge $next, $d, $d;  # 𝗘𝘅𝗮𝗺𝗽𝗹𝗲

        Jgt $next, $d, $d;
       } 3;
    
      my $e = &$ee(suppressOutput=>1);
    
      is_deeply $e->analyzeExecutionResults(doubleWrite=>3), "#       24 instructions executed";
      is_deeply $e->heap(1), [2];
      is_deeply $e->heap(2), [99];
     }
    

## Jgt($target, $source, $source2)

Jump to a target label if the first source field is greater than the second source field.

       Parameter  Description
    1  $target    Target label
    2  $source    Source to test
    3  $source2

**Example:**

    if (1)                                                                                 
     {Start 1;
      my $a = Array "aaa";
      my $b = Array "bbb";
      Mov [$a, 0, 'aaa'], $b;
      Mov [$b, 0, 'bbb'], 99;
    
      For
       {my ($i, $check, $next, $end) = @_;
        my $c = Mov [$a, \0, 'aaa'];
        my $d = Mov [$c, \0, 'bbb'];
        Jeq $next, $d, $d;
        Jne $next, $d, $d;
        Jle $next, $d, $d;
        Jlt $next, $d, $d;
        Jge $next, $d, $d;
    
        Jgt $next, $d, $d;  # 𝗘𝘅𝗮𝗺𝗽𝗹𝗲

       } 3;
    
      my $e = &$ee(suppressOutput=>1);
    
      is_deeply $e->analyzeExecutionResults(doubleWrite=>3), "#       24 instructions executed";
      is_deeply $e->heap(1), [2];
      is_deeply $e->heap(2), [99];
     }
    

## Jle($target, $source, $source2)

Jump to a target label if the first source field is less than or equal to the second source field.

       Parameter  Description
    1  $target    Target label
    2  $source    Source to test
    3  $source2

**Example:**

    if (1)                                                                                 
     {Start 1;
      my $a = Array "aaa";
      my $b = Array "bbb";
      Mov [$a, 0, 'aaa'], $b;
      Mov [$b, 0, 'bbb'], 99;
    
      For
       {my ($i, $check, $next, $end) = @_;
        my $c = Mov [$a, \0, 'aaa'];
        my $d = Mov [$c, \0, 'bbb'];
        Jeq $next, $d, $d;
        Jne $next, $d, $d;
    
        Jle $next, $d, $d;  # 𝗘𝘅𝗮𝗺𝗽𝗹𝗲

        Jlt $next, $d, $d;
        Jge $next, $d, $d;
        Jgt $next, $d, $d;
       } 3;
    
      my $e = &$ee(suppressOutput=>1);
    
      is_deeply $e->analyzeExecutionResults(doubleWrite=>3), "#       24 instructions executed";
      is_deeply $e->heap(1), [2];
      is_deeply $e->heap(2), [99];
     }
    

## Jlt($target, $source, $source2)

Jump to a target label if the first source field is less than the second source field.

       Parameter  Description
    1  $target    Target label
    2  $source    Source to test
    3  $source2

**Example:**

    if (1)                                                                                 
     {Start 1;
      my $a = Array "aaa";
      my $b = Array "bbb";
      Mov [$a, 0, 'aaa'], $b;
      Mov [$b, 0, 'bbb'], 99;
    
      For
       {my ($i, $check, $next, $end) = @_;
        my $c = Mov [$a, \0, 'aaa'];
        my $d = Mov [$c, \0, 'bbb'];
        Jeq $next, $d, $d;
        Jne $next, $d, $d;
        Jle $next, $d, $d;
    
        Jlt $next, $d, $d;  # 𝗘𝘅𝗮𝗺𝗽𝗹𝗲

        Jge $next, $d, $d;
        Jgt $next, $d, $d;
       } 3;
    
      my $e = &$ee(suppressOutput=>1);
    
      is_deeply $e->analyzeExecutionResults(doubleWrite=>3), "#       24 instructions executed";
      is_deeply $e->heap(1), [2];
      is_deeply $e->heap(2), [99];
     }
    

## Jmp($target)

Jump to a label.

       Parameter  Description
    1  $target    Target address

**Example:**

    if (1)                                                                          
     {Start 1;
    
      Jmp (my $a = label);  # 𝗘𝘅𝗮𝗺𝗽𝗹𝗲

        Out  1;
    
        Jmp (my $b = label);  # 𝗘𝘅𝗮𝗺𝗽𝗹𝗲

      setLabel($a);
        Out  2;
      setLabel($b);
      my $e = &$ee(suppressOutput=>1);
      is_deeply $e->outLines, [2];
     }
    

## Jne($target, $source, $source2)

Jump to a target label if the first source field is not equal to the second source field.

       Parameter  Description
    1  $target    Target label
    2  $source    Source to test
    3  $source2

**Example:**

    if (1)                                                                                 
     {Start 1;
      my $a = Array "aaa";
      my $b = Array "bbb";
      Mov [$a, 0, 'aaa'], $b;
      Mov [$b, 0, 'bbb'], 99;
    
      For
       {my ($i, $check, $next, $end) = @_;
        my $c = Mov [$a, \0, 'aaa'];
        my $d = Mov [$c, \0, 'bbb'];
        Jeq $next, $d, $d;
    
        Jne $next, $d, $d;  # 𝗘𝘅𝗮𝗺𝗽𝗹𝗲

        Jle $next, $d, $d;
        Jlt $next, $d, $d;
        Jge $next, $d, $d;
        Jgt $next, $d, $d;
       } 3;
    
      my $e = &$ee(suppressOutput=>1);
    
      is_deeply $e->analyzeExecutionResults(doubleWrite=>3), "#       24 instructions executed";
      is_deeply $e->heap(1), [2];
      is_deeply $e->heap(2), [99];
     }
    

## JTrue($target, $source)

Jump to a target label if the first source field is not equal to zero.

       Parameter  Description
    1  $target    Target label
    2  $source    Source to test

**Example:**

    if (1)                                                                           
     {Start 1;
      my $a = Mov 1;
      Block
       {my ($start, $good, $bad, $end) = @_;
    
        JTrue $end, $a;  # 𝗘𝘅𝗮𝗺𝗽𝗹𝗲

        Out 1;
       };
      Block
       {my ($start, $good, $bad, $end) = @_;
        JFalse $end, $a;
        Out 2;
       };
      Mov $a, 0;
      Block
       {my ($start, $good, $bad, $end) = @_;
    
        JTrue $end, $a;  # 𝗘𝘅𝗮𝗺𝗽𝗹𝗲

        Out 3;
       };
      Block
       {my ($start, $good, $bad, $end) = @_;
        JFalse $end, $a;
        Out 4;
       };
      my $e = &$ee(suppressOutput=>1);
      is_deeply $e->out, <<END;
    2
    3
    END
     }
    

## LoadAddress()

Load the address component of an address.

**Example:**

    if (1)                                                                           
     {Start 1;
      my $a = Array "array";
      my $b = Mov 2;
      my $c = Mov 5;
    
      my $d = LoadAddress $c;  # 𝗘𝘅𝗮𝗺𝗽𝗹𝗲

      my $f = LoadArea    [$a, \0, 'array'];
    
      Out $d;
      Out $f;
    
      Mov [$a, \$b, 'array'], 22;
      Mov [$a, \$c, 'array'], 33;
      Mov [$f, \$d, 'array'], 44;
    
      my $e = &$ee(suppressOutput=>1, maximumArraySize=>6);
    
      is_deeply $e->out, <<END;
    2
    1
    END
    
      is_deeply $e->heap(1), [undef, undef, 44, undef, undef, 33] if $testSet <= 2;
      is_deeply $e->heap(1), [0,     0,     44, 0,     0,     33] if $testSet  > 2;
      is_deeply $e->widestAreaInArena, [4,5];
      is_deeply $e->namesOfWidestArrays, ["stackArea", "array"] if $testSet % 2;
     }
    

## LoadArea()

Load the area component of an address.

**Example:**

    if (1)                                                                           
     {Start 1;
      my $a = Array "array";
      my $b = Mov 2;
      my $c = Mov 5;
      my $d = LoadAddress $c;
    
      my $f = LoadArea    [$a, \0, 'array'];  # 𝗘𝘅𝗮𝗺𝗽𝗹𝗲

    
      Out $d;
      Out $f;
    
      Mov [$a, \$b, 'array'], 22;
      Mov [$a, \$c, 'array'], 33;
      Mov [$f, \$d, 'array'], 44;
    
      my $e = &$ee(suppressOutput=>1, maximumArraySize=>6);
    
      is_deeply $e->out, <<END;
    2
    1
    END
    
      is_deeply $e->heap(1), [undef, undef, 44, undef, undef, 33] if $testSet <= 2;
      is_deeply $e->heap(1), [0,     0,     44, 0,     0,     33] if $testSet  > 2;
      is_deeply $e->widestAreaInArena, [4,5];
      is_deeply $e->namesOfWidestArrays, ["stackArea", "array"] if $testSet % 2;
     }
    

## Mov()

Copy a constant or memory address to the target address.

**Example:**

    if (1)                                                                          
     {Start 1;
    
      my $a = Mov 2;  # 𝗘𝘅𝗮𝗺𝗽𝗹𝗲

      Out $a;
      my $e = &$ee(suppressOutput=>1);
      is_deeply $e->outLines, [2];
     }
    
     {Start 1;                                                                      
    
    if (1)                                                                          
     {Start 1;
      my $a = Array "aaa";
    
      Mov     [$a,  1, "aaa"],  11;  # 𝗘𝘅𝗮𝗺𝗽𝗹𝗲

    
      Mov  1, [$a, \1, "aaa"];  # 𝗘𝘅𝗮𝗺𝗽𝗹𝗲

      Out \1;
      my $e = &$ee(suppressOutput=>1);
      is_deeply $e->outLines, [11];
     }
    
    if (1)                                                                           
     {Start 1;
      my $a = Array "alloc";
    
      my $b = Mov 99;  # 𝗘𝘅𝗮𝗺𝗽𝗹𝗲

    
      my $c = Mov $a;  # 𝗘𝘅𝗮𝗺𝗽𝗹𝗲

    
      Mov [$a, 0, 'alloc'], $b;  # 𝗘𝘅𝗮𝗺𝗽𝗹𝗲

    
      Mov [$c, 1, 'alloc'], 2;  # 𝗘𝘅𝗮𝗺𝗽𝗹𝗲

      my $e = &$ee(suppressOutput=>1);
      is_deeply $e->heap(1), [99, 2];
     }
    
    if (1)                                                                            
     {Start 1;
      my $a = Array "aaa";
      Dump;
      my $e = Execute(suppressOutput=>1);
      is_deeply $e->out, <<END;
    Stack trace:
        1     2 dump
    END
     }
    
    if (1)                                                                              
     {Start 1;
      my $a = Array "aaa";
    
      my $i = Mov 1;  # 𝗘𝘅𝗮𝗺𝗽𝗹𝗲

    
      my $v = Mov 11;  # 𝗘𝘅𝗮𝗺𝗽𝗹𝗲

      ParamsPut 0, $a;
      ParamsPut 1, $i;
      ParamsPut 2, $v;
      my $set = Procedure 'set', sub
       {my $a = ParamsGet 0;
        my $i = ParamsGet 1;
        my $v = ParamsGet 2;
    
        Mov [$a, \$i, 'aaa'], $v;  # 𝗘𝘅𝗮𝗺𝗽𝗹𝗲

        Return;
       };
      Call $set;
    
      my $V = Mov [$a, \$i, 'aaa'];  # 𝗘𝘅𝗮𝗺𝗽𝗹𝗲

      AssertEq $v, $V;
      Out [$a, \$i, 'aaa'];
      my $e = &$ee(suppressOutput=>1);
      is_deeply $e->outLines, [11];
     }
    
    if (1)                                                                            
     {Start 1;
      my $set = Procedure 'set', sub
       {my $a = ParamsGet 0;
        Out $a;
       };
      ParamsPut 0, 1;  Call $set;
      ParamsPut 0, 2;  Call $set;
      ParamsPut 0, 3;  Call $set;
      my $e = &$ee(suppressOutput=>1);
      is_deeply $e->out, <<END;
    1
    2
    3
    END
     }
    
    if (1)                                                                                 
     {Start 1;
      my $a = Array "aaa";
      my $b = Array "bbb";
    
      Mov [$a, 0, 'aaa'], $b;  # 𝗘𝘅𝗮𝗺𝗽𝗹𝗲

    
      Mov [$b, 0, 'bbb'], 99;  # 𝗘𝘅𝗮𝗺𝗽𝗹𝗲

    
      For
       {my ($i, $check, $next, $end) = @_;
    
        my $c = Mov [$a, \0, 'aaa'];  # 𝗘𝘅𝗮𝗺𝗽𝗹𝗲

    
        my $d = Mov [$c, \0, 'bbb'];  # 𝗘𝘅𝗮𝗺𝗽𝗹𝗲

        Jeq $next, $d, $d;
        Jne $next, $d, $d;
        Jle $next, $d, $d;
        Jlt $next, $d, $d;
        Jge $next, $d, $d;
        Jgt $next, $d, $d;
       } 3;
    
      my $e = &$ee(suppressOutput=>1);
    
      is_deeply $e->analyzeExecutionResults(doubleWrite=>3), "#       24 instructions executed";
      is_deeply $e->heap(1), [2];
      is_deeply $e->heap(2), [99];
     }
    
    if (1)                                                                           
     {Start 1;
      my $a = Array 'aaa';
    
      my $b = Mov 2;                                                                # Location to move to in a  # 𝗘𝘅𝗮𝗺𝗽𝗹𝗲

    
      For
       {my ($i, $check, $next, $end) = @_;
    
        Mov [$a, \$b, 'aaa'], 1;  # 𝗘𝘅𝗮𝗺𝗽𝗹𝗲

        Jeq $next, [$a, \$b, 'aaa'], 1;
       } 3;
    
      my $e = &$ee(suppressOutput=>1);
    
      is_deeply $e->analyzeExecutionResults(doubleWrite=>3), "#       19 instructions executed";
      is_deeply $e->heap(1), [undef, undef, 1] if $testSet <= 2;
      is_deeply $e->heap(1), [0,     0,     1] if $testSet  > 2;
     }
    
    if (1)                                                                           
     {Start 1;
      my $a = Array "aaa";
    
      Mov [$a, 0, "aaa"], 1;  # 𝗘𝘅𝗮𝗺𝗽𝗹𝗲

    
      Mov [$a, 1, "aaa"], 22;  # 𝗘𝘅𝗮𝗺𝗽𝗹𝗲

    
      Mov [$a, 2, "aaa"], 333;  # 𝗘𝘅𝗮𝗺𝗽𝗹𝗲

      ArrayDump $a;
      my $e = &$ee(suppressOutput=>1);
    
      is_deeply eval($e->out), [1, 22, 333];
    
      is_deeply $e->block->codeToString, <<'END' if $testSet == 1;
    0000     array           \0             3
    0001       mov [\0, \0, 3, 0]             1
    0002       mov [\0, \1, 3, 0]            22
    0003       mov [\0, \2, 3, 0]           333
    0004  arrayDump           \0
    END
    
      is_deeply $e->block->codeToString, <<'END' if $testSet == 2;
    0000     array [undef, \0, 3, 0]  [undef, 3, 3, 0]  [undef, 0, 3, 0]
    0001       mov [\0, \0, 3, 0]  [undef, 1, 3, 0]  [undef, 0, 3, 0]
    0002       mov [\0, \1, 3, 0]  [undef, 22, 3, 0]  [undef, 0, 3, 0]
    0003       mov [\0, \2, 3, 0]  [undef, 333, 3, 0]  [undef, 0, 3, 0]
    0004  arrayDump [undef, \0, 3, 0]  [undef, 0, 3, 0]  [undef, 0, 3, 0]
    END
     }
    

## MoveLong($target, $source, $source2)

Copy the number of elements specified by the second source operand from the location specified by the first source operand to the target operand.

       Parameter  Description
    1  $target    Target of move
    2  $source    Source of move
    3  $source2   Length of move

**Example:**

    if (1)                                                                          
     {my $N = 10;
      Start 1;
      my $a = Array "aaa";
      my $b = Array "bbb";
      For
       {my ($i, $Check, $Next, $End) = @_;
        Mov [$a, \$i, "aaa"], $i;
        my $j = Add $i, 100;
        Mov [$b, \$i, "bbb"], $j;
       } $N;
    
    
      MoveLong [$b, \2, 'bbb'], [$a, \4, 'aaa'], 3;  # 𝗘𝘅𝗮𝗺𝗽𝗹𝗲

    
      my $e = &$ee(suppressOutput=>1, maximumArraySize=>11);
      is_deeply $e->heap(1), [0 .. 9];
      is_deeply $e->heap(2), [100, 101, 4, 5, 6, 105 .. 109];
     }
    

## Not()

Move and not.

**Example:**

    if (1)                                                                          
     {Start 1;
      my $a = Mov 3;
    
      my $b = Not $a;  # 𝗘𝘅𝗮𝗺𝗽𝗹𝗲

    
      my $c = Not $b;  # 𝗘𝘅𝗮𝗺𝗽𝗹𝗲

      Out $a;
      Out $b;
      Out $c;
      my $e = &$ee(suppressOutput=>1);
      is_deeply $e->out, <<END;
    3
    
    1
    END
     }
    

## Nop()

Do nothing (but do it well!).

**Example:**

    if (1)                                                                          
     {Start 1;
    
      Nop;  # 𝗘𝘅𝗮𝗺𝗽𝗹𝗲

      my $e = &$ee;
      is_deeply $e->out, "";
     }
    
    if (1)                                                                             
     {Start 1;
      my $a = Array "aaa";
      Parallel
        sub{Mov [$a, 0, "aaa"], 1},
        sub{Mov [$a, 1, "aaa"], 22},
        sub{Mov [$a, 2, "aaa"], 333};
    
      my $n = ArraySize $a, "aaa";
      Out "Array size:", $n;
      ArrayDump $a;
    
      ForArray
       {my ($i, $e, $check, $next, $end) = @_;
        Out $i; Out $e;
       }  $a, "aaa";
    
    
      Nop;  # 𝗘𝘅𝗮𝗺𝗽𝗹𝗲

      my $e = Execute(suppressOutput=>1);
    
      is_deeply $e->heap(1), [1, 22, 333];
      is_deeply $e->out, <<END if $testSet <= 2;
    Array size: 3
    bless([1, 22, 333], "aaa")
    0
    1
    1
    22
    2
    333
    END
      is_deeply $e->out, <<END if $testSet  > 2;
    Array size: 3
    [1, 22, 333]
    0
    1
    1
    22
    2
    333
    END
     }
    

## Out(@source)

Write memory location contents to out.

       Parameter  Description
    1  @source    Either a scalar constant or memory address to output

**Example:**

    if (1)                                                                            
     {Start 1;
    
      Out "Hello", "World";  # 𝗘𝘅𝗮𝗺𝗽𝗹𝗲

      my $e = Execute(suppressOutput=>1);
      is_deeply $e->out, <<END;
    Hello World
    END
     }
    

## ParamsGet()

Get a word from the parameters in the previous frame and store it in the current frame.

**Example:**

    if (1)                                                                              
     {Start 1;
      my $a = Array "aaa";
      my $i = Mov 1;
      my $v = Mov 11;
      ParamsPut 0, $a;
      ParamsPut 1, $i;
      ParamsPut 2, $v;
      my $set = Procedure 'set', sub
    
       {my $a = ParamsGet 0;  # 𝗘𝘅𝗮𝗺𝗽𝗹𝗲

    
        my $i = ParamsGet 1;  # 𝗘𝘅𝗮𝗺𝗽𝗹𝗲

    
        my $v = ParamsGet 2;  # 𝗘𝘅𝗮𝗺𝗽𝗹𝗲

        Mov [$a, \$i, 'aaa'], $v;
        Return;
       };
      Call $set;
      my $V = Mov [$a, \$i, 'aaa'];
      AssertEq $v, $V;
      Out [$a, \$i, 'aaa'];
      my $e = &$ee(suppressOutput=>1);
      is_deeply $e->outLines, [11];
     }
    

## ParamsPut($target, $source)

Put a word into the parameters list to make it visible in a called procedure.

       Parameter  Description
    1  $target    Parameter number
    2  $source    Address to fetch parameter from

**Example:**

    if (1)                                                                              
     {Start 1;
      my $a = Array "aaa";
      my $i = Mov 1;
      my $v = Mov 11;
    
      ParamsPut 0, $a;  # 𝗘𝘅𝗮𝗺𝗽𝗹𝗲

    
      ParamsPut 1, $i;  # 𝗘𝘅𝗮𝗺𝗽𝗹𝗲

    
      ParamsPut 2, $v;  # 𝗘𝘅𝗮𝗺𝗽𝗹𝗲

      my $set = Procedure 'set', sub
       {my $a = ParamsGet 0;
        my $i = ParamsGet 1;
        my $v = ParamsGet 2;
        Mov [$a, \$i, 'aaa'], $v;
        Return;
       };
      Call $set;
      my $V = Mov [$a, \$i, 'aaa'];
      AssertEq $v, $V;
      Out [$a, \$i, 'aaa'];
      my $e = &$ee(suppressOutput=>1);
      is_deeply $e->outLines, [11];
     }
    

## Pop(if (@\_ == 2))

Pop the memory area specified by the source operand into the memory address specified by the target operand.

       Parameter     Description
    1  if (@_ == 2)  Pop indicated area into a local variable

**Example:**

    if (1)                                                                           
     {Start 1;
      my $a = Array   "aaa";
      Push $a, 1,     "aaa";
      Push $a, 2,     "aaa";
    
      my $c = Pop $a, "aaa";  # 𝗘𝘅𝗮𝗺𝗽𝗹𝗲

    
      my $d = Pop $a, "aaa";  # 𝗘𝘅𝗮𝗺𝗽𝗹𝗲

    
      Out $c;
      Out $d;
      my $e = &$ee(suppressOutput=>1);
      is_deeply $e->out, <<END;
    2
    1
    END
      is_deeply $e->heap(1), [];
     }
    

## Procedure($name, $source)

Define a procedure.

       Parameter  Description
    1  $name      Name of procedure
    2  $source    Source code as a subroutine

**Example:**

    if (1)                                                                          
     {Start 1;
    
      my $add = Procedure 'add2', sub  # 𝗘𝘅𝗮𝗺𝗽𝗹𝗲

       {my $a = ParamsGet 0;
        my $b = Add $a, 2;
        ReturnPut 0, $b;
        Return;
       };
      ParamsPut 0, 2;
      Call $add;
      my $c = ReturnGet 0;
      Out $c;
      my $e = &$ee(suppressOutput=>1);
      is_deeply $e->outLines, [4];
     }
    
    if (1)                                                                          
     {Start 1;
      for my $i(1..10)
       {Out $i;
       };
      IfTrue 0,
      Then
       {Out 99;
       };
      my $e = &$ee(suppressOutput=>1);
      is_deeply $e->outLines, [1..10];
      is_deeply $e->outLines, [1..10];
     }
    

## Push($target, $source, $source2)

Push the value in the current stack frame specified by the source operand onto the memory area identified by the target operand.

       Parameter  Description
    1  $target    Memory area to push to
    2  $source    Memory containing value to push
    3  $source2

**Example:**

    if (1)                                                                           
     {Start 1;
      my $a = Array   "aaa";
    
      Push $a, 1,     "aaa";  # 𝗘𝘅𝗮𝗺𝗽𝗹𝗲

    
      Push $a, 2,     "aaa";  # 𝗘𝘅𝗮𝗺𝗽𝗹𝗲

      my $c = Pop $a, "aaa";
      my $d = Pop $a, "aaa";
    
      Out $c;
      Out $d;
      my $e = &$ee(suppressOutput=>1);
      is_deeply $e->out, <<END;
    2
    1
    END
      is_deeply $e->heap(1), [];
     }
    
    if (1)                                                                          
     {Start 1;
      my $a = Array "aaa";
    
      Push $a, 1, "aaa";  # 𝗘𝘅𝗮𝗺𝗽𝗹𝗲

    
      Push $a, 2, "aaa";  # 𝗘𝘅𝗮𝗺𝗽𝗹𝗲

    
      Push $a, 3, "aaa";  # 𝗘𝘅𝗮𝗺𝗽𝗹𝗲

      my $b = Array "bbb";
    
      Push $b, 11, "bbb";  # 𝗘𝘅𝗮𝗺𝗽𝗹𝗲

    
      Push $b, 22, "bbb";  # 𝗘𝘅𝗮𝗺𝗽𝗹𝗲

    
      Push $b, 33, "bbb";  # 𝗘𝘅𝗮𝗺𝗽𝗹𝗲

      my $e = &$ee(suppressOutput=>1);
      is_deeply $e->GetMemoryHeaps->($e), 3;
      is_deeply $e->heap(1), [1, 2, 3];
      is_deeply $e->heap(2), [11, 22, 33];
      is_deeply $e->mostArrays, [1, 2, 1, 1];
     }
    

## Resize($target, $source, $source2)

Resize the target area to the source size.

       Parameter  Description
    1  $target    Target array
    2  $source    New size
    3  $source2   Array name

**Example:**

    if (1)                                                                          
     {Start 1;
      my $a = Array 'aaa';
      Parallel
        sub{Mov [$a, 0, 'aaa'], 1},
        sub{Mov [$a, 1, 'aaa'], 2},
        sub{Mov [$a, 2, 'aaa'], 3};
    
      Resize $a, 2, "aaa";  # 𝗘𝘅𝗮𝗺𝗽𝗹𝗲

      ArrayDump $a;
      my $e = &$ee(suppressOutput=>1);
    
      is_deeply $e->heap(1), [1, 2];
      is_deeply eval($e->out), [1,2];
     }
    

## Random(if (@\_ == 1))

Create a random number in a specified range.

       Parameter     Description
    1  if (@_ == 1)  Create a variable

**Example:**

    if (1)                                                                           
     {Start 1;
      RandomSeed 1;
    
      my $a = Random 10;  # 𝗘𝘅𝗮𝗺𝗽𝗹𝗲

      Out $a;
      my $e = &$ee(suppressOutput=>1);
      ok $e->out =~ m(\A\d\Z);
     }
    

## RandomSeed($seed)

Seed the random number generator.

       Parameter  Description
    1  $seed      Parameters

**Example:**

    if (1)                                                                           
     {Start 1;
    
      RandomSeed 1;  # 𝗘𝘅𝗮𝗺𝗽𝗹𝗲

      my $a = Random 10;
      Out $a;
      my $e = &$ee(suppressOutput=>1);
      ok $e->out =~ m(\A\d\Z);
     }
    

## Return()

Return from a procedure via the call stack.

**Example:**

    if (1)                                                                           
     {Start 1;
      my $w = Procedure 'write', sub
       {Out 1;
    
        Return;  # 𝗘𝘅𝗮𝗺𝗽𝗹𝗲

       };
      Call $w;
      my $e = &$ee(suppressOutput=>1);
      is_deeply $e->outLines, [1];
     }
    

## ReturnGet(if (@\_ == 1))

Get a word from the return area and save it.

       Parameter     Description
    1  if (@_ == 1)  Create a variable

**Example:**

    if (1)                                                                            
     {Start 1;
      my $w = Procedure 'write', sub
       {ReturnPut 0, 999;
        Return;
       };
      Call $w;
    
      ReturnGet \0, 0;  # 𝗘𝘅𝗮𝗺𝗽𝗹𝗲

      Out \0;
      my $e = &$ee(suppressOutput=>1);
      is_deeply $e->outLines, [999];
     }
    

## ReturnPut($target, $source)

Put a word into the return area.

       Parameter  Description
    1  $target    Offset in return area to write to
    2  $source    Memory address whose contents are to be placed in the return area

**Example:**

    if (1)                                                                            
     {Start 1;
      my $w = Procedure 'write', sub
    
       {ReturnPut 0, 999;  # 𝗘𝘅𝗮𝗺𝗽𝗹𝗲

        Return;
       };
      Call $w;
      ReturnGet \0, 0;
      Out \0;
      my $e = &$ee(suppressOutput=>1);
      is_deeply $e->outLines, [999];
     }
    

## ShiftDown(if (@\_ == 1))

Shift an element down one in an area.

       Parameter     Description
    1  if (@_ == 1)  Create a variable

**Example:**

    if (1)                                                                          
     {Start 1;
      my $a = Array "array";
    
      Parallel
        sub{Mov [$a, 0, 'array'], 0},
        sub{Mov [$a, 1, 'array'], 99},
        sub{Mov [$a, 2, 'array'], 2};
    
    
      my $b = ShiftDown [$a, \1, 'array'];  # 𝗘𝘅𝗮𝗺𝗽𝗹𝗲

      Out $b;
    
      my $e = &$ee(suppressOutput=>1);
      is_deeply $e->heap(1), [0, 2];
      is_deeply $e->outLines, [99];
     }
    

## ShiftLeft(my ($target, $source)

Shift left within an element.

       Parameter    Description
    1  my ($target  Target to shift
    2  $source      Amount to shift

**Example:**

    if (1)                                                                          
     {Start 1;
      my $a = Mov 1;
    
      ShiftLeft $a, $a;  # 𝗘𝘅𝗮𝗺𝗽𝗹𝗲

      Out $a;
      my $e = &$ee(suppressOutput=>1);
      is_deeply $e->outLines, [2];
     }
    

## ShiftRight(my ($target, $source)

Shift right with an element.

       Parameter    Description
    1  my ($target  Target to shift
    2  $source      Amount to shift

**Example:**

    if (1)                                                                          
     {Start 1;
      my $a = Mov 4;
    
      ShiftRight $a, 1;  # 𝗘𝘅𝗮𝗺𝗽𝗹𝗲

      Out $a;
      my $e = &$ee(suppressOutput=>1);
      is_deeply $e->outLines, [2];
     }
    

## ShiftUp($target, $source)

Shift an element up one in an area.

       Parameter  Description
    1  $target    Target to shift
    2  $source    Amount to shift

**Example:**

    if (1)                                                                          
     {Start 1;
      my $a = Array "array";
    
      Mov [$a, 0, 'array'], 0;
      Mov [$a, 1, 'array'], 1;
      Mov [$a, 2, 'array'], 2;
    
      ShiftUp [$a, 0, 'array'], 99;  # 𝗘𝘅𝗮𝗺𝗽𝗹𝗲

    
      my $e = &$ee(suppressOutput=>0);
      is_deeply $e->heap(1), [99, 0, 1, 2];
     }
    
    if (1)                                                                          
     {Start 1;
      my $a = Array "array";
    
      Mov [$a, 0, 'array'], 0;
      Mov [$a, 1, 'array'], 1;
      Mov [$a, 2, 'array'], 2;
    
      ShiftUp [$a, 1, 'array'], 99;  # 𝗘𝘅𝗮𝗺𝗽𝗹𝗲

    
      my $e = &$ee(suppressOutput=>0);
      is_deeply $e->heap(1), [0, 99, 1, 2];
     }
    
    if (1)                                                                           
     {Start 1;
      my $a = Array "array";
    
      Sequential
        sub{Mov [$a, 0, 'array'], 0},
        sub{Mov [$a, 1, 'array'], 1},
        sub{Mov [$a, 2, 'array'], 2};
    
    
      ShiftUp [$a, 2, 'array'], 99;  # 𝗘𝘅𝗮𝗺𝗽𝗹𝗲

    
      my $e = &$ee(suppressOutput=>0);
      is_deeply $e->heap(1), [0, 1, 99, 2];
     }
    
    if (1)                                                                           
     {Start 1;
      my $a = Array "array";
    
      Parallel
        sub{Mov [$a, 0, 'array'], 0},
        sub{Mov [$a, 1, 'array'], 1},
        sub{Mov [$a, 2, 'array'], 2};
    
    
      ShiftUp [$a, 3, 'array'], 99;  # 𝗘𝘅𝗮𝗺𝗽𝗹𝗲

    
      my $e = &$ee(suppressOutput=>0);
      is_deeply $e->heap(1), [0, 1, 2, 99];
      is_deeply [$e->timeParallel, $e->timeSequential], [3,5];
     }
    
    if (1)                                                                          
     {Start 1;
      my $a = Array "array";
    
      my @i;
      for my $i(1..7)
       {push @i, sub{Mov [$a, $i-1, 'array'], 10*$i};
       }
      Parallel @i;
    
    
      ShiftUp [$a, 2, 'array'], 26;  # 𝗘𝘅𝗮𝗺𝗽𝗹𝗲

      my $e = &$ee(suppressOutput=>1, maximumArraySize=>8);
      is_deeply $e->heap(1), bless([10, 20, 26, 30, 40, 50, 60, 70], "array");
     }
    

## Start($version)

Start the current assembly using the specified version of the Zero language.  At  the moment only version 1 works.

       Parameter  Description
    1  $version   Version desired - at the moment only 1

**Example:**

    if (1)                                                                            
    
     {Start 1;  # 𝗘𝘅𝗮𝗺𝗽𝗹𝗲

      Out "Hello", "World";
      my $e = Execute(suppressOutput=>1);
      is_deeply $e->out, <<END;
    Hello World
    END
     }
    

## Subtract($target, $s1, $s2)

Subtract the second source operand value from the first source operand value and store the result in the target area.

       Parameter  Description
    1  $target    Target address
    2  $s1        Source one
    3  $s2        Source two

**Example:**

    if (1)                                                                          
     {Start 1;
    
      my $a = Subtract 4, 2;  # 𝗘𝘅𝗮𝗺𝗽𝗹𝗲

      Out $a;
      my $e = &$ee(suppressOutput=>1);
      is_deeply $e->outLines, [2];
     }
    

## Tally($source)

Counts instructions when enabled.

       Parameter  Description
    1  $source    Tally instructions when true

**Example:**

    if (1)                                                                           
     {my $N = 5;
      Start 1;
      For
    
       {Tally 1;  # 𝗘𝘅𝗮𝗺𝗽𝗹𝗲

        my $a = Mov 1;
    
        Tally 2;  # 𝗘𝘅𝗮𝗺𝗽𝗹𝗲

        Inc $a;
    
        Tally 0;  # 𝗘𝘅𝗮𝗺𝗽𝗹𝗲

       } $N;
      my $e = Execute;
    
      is_deeply $e->tallyCount, 2 * $N;
      is_deeply $e->tallyCounts, { 1 => {mov => $N}, 2 => {add => $N}};
     }
    

## Then($t)

Then block.

       Parameter  Description
    1  $t         Then block subroutine

**Example:**

    if (1)                                                                            
     {Start 1;
      IfFalse 1,
    
      Then  # 𝗘𝘅𝗮𝗺𝗽𝗹𝗲

       {Out 1
       },
      Else
       {Out 0
       };
      my $e = &$ee(suppressOutput=>1);
      is_deeply $e->outLines, [0];
     }
    
    if (1)                                                                            
     {Start 1;
      Trace 1;
      IfEq 1, 2,
    
      Then  # 𝗘𝘅𝗮𝗺𝗽𝗹𝗲

       {Mov 1, 1;
        Mov 2, 1;
       },
      Else
       {Mov 3, 3;
        Mov 4, 4;
       };
      IfEq 2, 2,
    
      Then  # 𝗘𝘅𝗮𝗺𝗽𝗹𝗲

       {Mov 1, 1;
        Mov 2, 1;
       },
      Else
       {Mov 3, 3;
        Mov 4, 4;
       };
      my $e = &$ee(suppressOutput=>1);
      is_deeply $e->out, <<END;
    Trace: 1
        1     0     0         trace
        2     1     1           jNe
        3     5     0         label
        4     6     1           mov  [1, 3, stackArea] = 3
        5     7     1           mov  [1, 4, stackArea] = 4
        6     8     0         label
        7     9     1           jNe
        8    10     1           mov  [1, 1, stackArea] = 1
        9    11     1           mov  [1, 2, stackArea] = 1
       10    12     1           jmp
       11    16     0         label
    END
      my $E = &$ee(suppressOutput=>1);
      is_deeply $E->out, <<END;
    Trace: 1
        1     0     0         trace
        2     1     1           jNe
        3     5     0         label
        4     6     1           mov  [1, 3, stackArea] = 3
        5     7     1           mov  [1, 4, stackArea] = 4
        6     8     0         label
        7     9     1           jNe
        8    10     1           mov  [1, 1, stackArea] = 1
        9    11     1           mov  [1, 2, stackArea] = 1
       10    12     1           jmp
       11    16     0         label
    END
    
      is_deeply scalar($e->notExecuted->@*), 6;
      is_deeply scalar($E->notExecuted->@*), 6;
     }
    

## Trace($source)

Start or stop tracing.  Tracing prints each instruction executed and its effect on memory.

       Parameter  Description
    1  $source    Trace setting

**Example:**

    if (1)                                                                            
     {Start 1;
    
      Trace 1;  # 𝗘𝘅𝗮𝗺𝗽𝗹𝗲

      IfEq 1, 2,
      Then
       {Mov 1, 1;
        Mov 2, 1;
       },
      Else
       {Mov 3, 3;
        Mov 4, 4;
       };
      IfEq 2, 2,
      Then
       {Mov 1, 1;
        Mov 2, 1;
       },
      Else
       {Mov 3, 3;
        Mov 4, 4;
       };
      my $e = &$ee(suppressOutput=>1);
      is_deeply $e->out, <<END;
    
    Trace: 1  # 𝗘𝘅𝗮𝗺𝗽𝗹𝗲

        1     0     0         trace
        2     1     1           jNe
        3     5     0         label
        4     6     1           mov  [1, 3, stackArea] = 3
        5     7     1           mov  [1, 4, stackArea] = 4
        6     8     0         label
        7     9     1           jNe
        8    10     1           mov  [1, 1, stackArea] = 1
        9    11     1           mov  [1, 2, stackArea] = 1
       10    12     1           jmp
       11    16     0         label
    END
      my $E = &$ee(suppressOutput=>1);
      is_deeply $E->out, <<END;
    
    Trace: 1  # 𝗘𝘅𝗮𝗺𝗽𝗹𝗲

        1     0     0         trace
        2     1     1           jNe
        3     5     0         label
        4     6     1           mov  [1, 3, stackArea] = 3
        5     7     1           mov  [1, 4, stackArea] = 4
        6     8     0         label
        7     9     1           jNe
        8    10     1           mov  [1, 1, stackArea] = 1
        9    11     1           mov  [1, 2, stackArea] = 1
       10    12     1           jmp
       11    16     0         label
    END
    
      is_deeply scalar($e->notExecuted->@*), 6;
      is_deeply scalar($E->notExecuted->@*), 6;
     }
    

## TraceLabels($source)

Enable or disable label tracing.  If tracing is enabled a stack trace is printed for each label instruction executed showing the call stack at the time the instruction was generated as well as the current stack frames.

       Parameter  Description
    1  $source    Trace points if true

**Example:**

    if (1)                                                                          
     {my $N = 5;
      Start 1;
    
      TraceLabels 1;  # 𝗘𝘅𝗮𝗺𝗽𝗹𝗲

      For
       {my $a = Mov 1;
        Inc $a;
       } $N;
      my $e = &$ee(suppressOutput=>1);
    
      is_deeply $e->out, <<END;
    
    TraceLabels: 1  # 𝗘𝘅𝗮𝗺𝗽𝗹𝗲

    Label
        1     2 label
    Label
        1     4 label
    Label
        1     8 label
    Label
        1     4 label
    Label
        1     8 label
    Label
        1     4 label
    Label
        1     8 label
    Label
        1     4 label
    Label
        1     8 label
    Label
        1     4 label
    Label
        1     8 label
    Label
        1     4 label
    Label
        1    11 label
    END
     }
    

## Var($value)

Create a variable initialized to the specified value.

       Parameter  Description
    1  $value     Value

**Example:**

    if (1)                                                                          
     {Start 1;
    
      my $a = Var 22;  # 𝗘𝘅𝗮𝗺𝗽𝗹𝗲

      AssertEq $a, 22;
      my $e = &$ee(suppressOutput=>1);
      is_deeply $e->out, "";
     }
    

## Watch($target)

Watches for changes to the specified memory location.

       Parameter  Description
    1  $target    Memory address to watch

**Example:**

    if (1)                                                                          
     {Start 1;
      my $a = Mov 1;
      my $b = Mov 2;
      my $c = Mov 3;
    
      Watch $b;  # 𝗘𝘅𝗮𝗺𝗽𝗹𝗲

      Mov $a, 4;
      Mov $b, 5;
      Mov $c, 6;
      my $e = Execute(suppressOutput=>1);
      is_deeply $e->out, <<END;
    Change at watched arena: 0, area: 1(stackArea), address: 1
        1     6 mov
    Current value: 2 New value: 5
    END
     }
    

## Parallel(@subs)

Runs its sub sections in simulated parallel so that we can prove that the sections can be run in parallel.

       Parameter  Description
    1  @subs      Subroutines containing code to be run in simulated parallel

**Example:**

    if (1)                                                                           
     {Start 1;
      my $a = Array "array";
    
    
      Parallel  # 𝗘𝘅𝗮𝗺𝗽𝗹𝗲

        sub{Mov [$a, 0, 'array'], 0},
        sub{Mov [$a, 1, 'array'], 1},
        sub{Mov [$a, 2, 'array'], 2};
    
      ShiftUp [$a, 3, 'array'], 99;
    
      my $e = &$ee(suppressOutput=>0);
      is_deeply $e->heap(1), [0, 1, 2, 99];
      is_deeply [$e->timeParallel, $e->timeSequential], [3,5];
     }
    

## Sequential(@subs)

Runs its sub sections in sequential order

       Parameter  Description
    1  @subs      Subroutines containing code to be run sequentially

**Example:**

    if (1)                                                                           
     {Start 1;
      my $a = Array "array";
    
    
      Sequential  # 𝗘𝘅𝗮𝗺𝗽𝗹𝗲

        sub{Mov [$a, 0, 'array'], 0},
        sub{Mov [$a, 1, 'array'], 1},
        sub{Mov [$a, 2, 'array'], 2};
    
      ShiftUp [$a, 2, 'array'], 99;
    
      my $e = &$ee(suppressOutput=>0);
      is_deeply $e->heap(1), [0, 1, 99, 2];
     }
    

# Instruction Set Architecture

Map the instruction set into a machine architecture.

## GenerateMachineCode(%options)

Generate a string of machine code from the current block of code.

       Parameter  Description
    1  %options   Generation options

**Example:**

    if (1)                                                                            
     {Start 1;
      my $a = Mov 1;
    
      my $g = GenerateMachineCode;  # 𝗘𝘅𝗮𝗺𝗽𝗹𝗲

      is_deeply dump($g), 'pack("H*","0000002300000000000000000000017f000000010000007f000000000000007f")';
    
      my $d = disAssemble $g;
         $d->assemble;
      is_deeply $d->codeToString, <<'END';
    0000       mov [undef, \0, 3, 0]  [undef, 1, 3, 0]  [undef, 0, 3, 0]
    END
      my $e =  GenerateMachineCodeDisAssembleExecute;
      is_deeply $e->block->codeToString, <<'END';
    0000       mov [undef, \0, 3, 0]  [undef, 1, 3, 0]  [undef, 0, 3, 0]
    END
     }
    

## disAssemble($mc)

Disassemble machine code.

       Parameter  Description
    1  $mc        Machine code string

**Example:**

    if (1)                                                                            
     {Start 1;
      my $a = Mov 1;
      my $g = GenerateMachineCode;
      is_deeply dump($g), 'pack("H*","0000002300000000000000000000017f000000010000007f000000000000007f")';
    
    
      my $d = disAssemble $g;  # 𝗘𝘅𝗮𝗺𝗽𝗹𝗲

         $d->assemble;
      is_deeply $d->codeToString, <<'END';
    0000       mov [undef, \0, 3, 0]  [undef, 1, 3, 0]  [undef, 0, 3, 0]
    END
      my $e =  GenerateMachineCodeDisAssembleExecute;
      is_deeply $e->block->codeToString, <<'END';
    0000       mov [undef, \0, 3, 0]  [undef, 1, 3, 0]  [undef, 0, 3, 0]
    END
     }
    

## GenerateMachineCodeDisAssembleExecute(%options)

Round trip: generate machine code and write it onto a string, disassemble the generated machine code string and recreate a block of code from it, then execute the reconstituted code to prove that it works as well as the original code.

       Parameter  Description
    1  %options   Options

**Example:**

    if (1)                                                                            
     {Start 1;
      my $a = Mov 1;
      my $g = GenerateMachineCode;
      is_deeply dump($g), 'pack("H*","0000002300000000000000000000017f000000010000007f000000000000007f")';
    
      my $d = disAssemble $g;
         $d->assemble;
      is_deeply $d->codeToString, <<'END';
    0000       mov [undef, \0, 3, 0]  [undef, 1, 3, 0]  [undef, 0, 3, 0]
    END
    
      my $e =  GenerateMachineCodeDisAssembleExecute;  # 𝗘𝘅𝗮𝗺𝗽𝗹𝗲

      is_deeply $e->block->codeToString, <<'END';
    0000       mov [undef, \0, 3, 0]  [undef, 1, 3, 0]  [undef, 0, 3, 0]
    END
     }
    

# Hash Definitions

## Zero::Emulator Definition

Emulator execution environment

### Output fields

#### AllocMemoryArea

Low level memory access - allocate new area

#### FreeMemoryArea

Low level memory access - free an area

#### GetMemoryArea

Low level memory access - area

#### GetMemoryHeaps

Low level memory access - arenas in use

#### GetMemoryLocation

Low level memory access - location

#### PopMemoryArea

Low level memory access - pop from area

#### PushMemoryArea

Low level memory access - push onto area

#### ResizeMemoryArea

Low level memory access - resize an area

#### block

Block of code to be executed

#### calls

Call stack

#### checkArrayNames

Check array names to confirm we are accessing the expected data

#### count

Executed instructions count

#### counts

Executed instructions by name counts

#### doubleWrite

Source of double writes {instruction number} to count - an existing value was overwritten before it was used

#### freedArrays

Arrays that have been recently freed and can thus be reused

#### in

The input chnnel.  the [In](https://metacpan.org/pod/In) instruction reads one element at a time from this array.

#### instructionCounts

The number of times each actual instruction is executed

#### instructionPointer

Current instruction

#### lastAssignAddress

Last assignment performed - address

#### lastAssignArea

Last assignment performed - area

#### lastAssignArena

Last assignment performed - arena

#### lastAssignBefore

Prior value of memory area before assignment

#### lastAssignType

Last assignment performed - name of area assigned into

#### lastAssignValue

Last assignment performed - value

#### memory

Memory contents at the end of execution

#### memoryString

Memory packed into one string

#### memoryStringElementWidth

Width in bytes of a memory area element

#### memoryStringSystemElements

Maximum number of elements in the system area of a heap arena if such is required by the memory allocation technique in play

#### memoryStringTotalElements

Maximum number of elements in total in an area in a heap arena if such is required by the memory allocation technique in play

#### memoryStringUserElements

Maximum number of elements in the user area of a heap arena if such is required by the memory allocation technique in play

#### memoryType

Memory contents at the end of execution

#### mostArrays

The maximum number of arrays active at any point during the execution in each arena

#### namesOfWidestArrays

The name of the widest arrays in each arena

#### notExecuted

Instructions not executed

#### notReadAddresses

Memory addresses never read

#### out

The out channel. [Out](https://metacpan.org/pod/Out) writes an array of items to this followed by a new line.  [out](https://metacpan.org/pod/out) does the same but without the new line.

#### parallelLastStart

Point in time at which last parallel section started

#### parallelLongest

Longest paralle section so far

#### pointlessAssign

Location already has the specified value

#### printDoubleWrite

Double writes: earlier instruction number to later instruction number

#### printNotRead

Memory locations never read

#### printPointlessAssign

Pointless assigns {instruction number} to count - address already has the specified value

#### read

Records whether a memory address was ever read allowing us to find all the unused locations

#### rw

Read / write access to memory

#### stopOnError

Stop on non fatal errors if true

#### suppressOutput

If true the Out instruction will only write to the execution out array but not to stdout as well.

#### tally

Tally executed instructions in a bin of this name

#### tallyCount

Executed instructions tally count

#### tallyCounts

Executed instructions by name tally counts

#### tallyTotal

Total instructions executed in each tally

#### timeDelta

Time for last insytruction if sometyhing other than 1

#### timeParallel

Notional time elapsed since start with parallelism taken into account

#### timeSequential

Notional time elapsed since start without parellelism

#### trace

Trace all statements

#### traceLabels

Trace changes in execution flow

#### watch

Addresses to watch for changes

#### widestAreaInArena

Track highest array access in each arena

## Zero::Emulator::Address Definition

Address memory

### Output fields

#### address

Address within area, either a number or a reference to a number indicating the level of indirection

#### area

Area in memory, either a number or a reference to a number indicating the level of indirection

#### arena

Arena in memory

#### delta

Offset from indicated address

#### name

Name of area

## Zero::Emulator::AreaStructure Definition

Description of a data structure mapping a memory area

### Output fields

#### fieldNames

Maps the names of the fields to their offsets in the structure

#### fieldOrder

Order of the elements in the structure, in effect, giving the offset of each element in the data structure

#### structureName

Name of the structure

## Zero::Emulator::Code Definition

Block of code description.

### Output fields

#### arrayNames

Array names as strings to numbers

#### arrayNumbers

Array number to name

#### code

An array of instructions

#### files

File number to file name

#### labelCounter

Label counter used to generate unique labels

#### labels

Label name to instruction

#### procedures

Procedures defined in this block of code

#### variables

Variables in this block of code

## Zero::Emulator::Code::Instruction Definition

Instruction details

### Output fields

#### action

Instruction name

#### context

The call context in which this instruction was created

#### executed

The number of times this instruction was executed

#### file

Source file in which instruction was encoded

#### jump

Jump target

#### line

Line in source file at which this instruction was encoded

#### number

Instruction sequence number

#### source

Source memory address

#### source2

Secondary source memory address

#### step

The last time (in steps from the start) that this instruction was executed

#### target

Target memory address

## Zero::Emulator::Procedure Definition

Description of a procedure

### Output fields

#### target

Label to call to call this procedure

#### variables

Registers local to this procedure

## Zero::Emulator::StackFrame Definition

Description of a stack frame. A stack frame provides the context in which a method runs.

### Output fields

#### file

The file number from which the call was made - this could be folded into the line number but for reasons best known to themselves people who cannot program very well often scatter projects across several files a practice that is completely pointless in this day of git and so can only lead to chaos and confusion

#### instruction

The address of the instruction making the call

#### line

The line number from which the call was made

#### params

Memory area containing parameter list

#### return

Memory area containing returned result

#### stackArea

Memory area containing data for this method

#### target

The address of the subroutine being called

#### variables

Variables local to this stack frame

# Private Methods

## Assembly()

Start some assembly code.

## Assert1($op, $a)

Assert operation.

       Parameter  Description
    1  $op        Operation
    2  $a         Source operand

## Assert2($op, $a, $b)

Assert operation.

       Parameter  Description
    1  $op        Operation
    2  $a         First memory address
    3  $b         Second memory address

## Ifx($cmp, $a, $b, %options)

Execute then or else clause depending on whether two memory locations are equal.

       Parameter  Description
    1  $cmp       Comparison
    2  $a         First memory address
    3  $b         Second memory address
    4  %options   Then block

## Label($source)

Create a label.

       Parameter  Description
    1  $source    Name of label

**Example:**

    if (1)                                                                           
     {Start 1;
      Mov 0, 1;
      my $e = &$ee(suppressOutput=>1);
     }
    
    if (1)                                                                           
     {Start 1;
      Mov 0, 1;
      Jlt ((my $a = label), \0, 2);
        Out  1;
        Jmp (my $b = label);
      setLabel($a);
        Out  2;
      setLabel($b);
    
      Jgt ((my $c = label), \0, 3);
        Out  3;
        Jmp (my $d = label);
      setLabel($c);
        Out  4;
      setLabel($d);
      my $e = &$ee(suppressOutput=>1);
      is_deeply $e->outLines, [2..3];
     }
    
    if (1)                                                                          
     {Start 1;
      Mov 0, 0;
      my $a = setLabel;
        Out \0;
        Inc \0;
      Jlt $a, \0, 10;
      my $e = &$ee(suppressOutput=>1);
      is_deeply $e->outLines, [0..9];
     }
    

## ParallelStart()

Start recording the elapsed time for parallel sections.

## ParallelContinue()

Continue recording the elapsed time for parallel sections.

## ParallelStop()

Stop recording the elapsed time for parallel sections.

## instructionList()

Create a list of instructions.

## instructionListExport()

Create an export statement.

## instructionListReadMe()

List  instructions for inclusion in read me.

## instructionListMapping()

Map instructions to small integers.

## rerefValue($value, $depth)

Re-reference a value.

       Parameter  Description
    1  $value     Value to reference
    2  $depth     Depth of reference

## Zero::Emulator::Code::packRef($code, $instruction, $ref)

Pack a reference into 8 bytes.

       Parameter     Description
    1  $code         Code block being packed
    2  $instruction  Instruction being packed
    3  $ref          Reference being packed

## Zero::Emulator::Code::unpackRef($code, $a, $operand)

Unpack a reference.

       Parameter  Description
    1  $code      Code block being packed
    2  $a         Instruction being packed
    3  $operand   Reference being packed

## Zero::Emulator::Code::packInstruction($code, $i)

Pack an instruction.

       Parameter  Description
    1  $code      Code being packed
    2  $i         Instruction to pack

## unpackInstruction($I)

Unpack an instruction.

       Parameter  Description
    1  $I         Instruction numbers

## disAssembleMinusContext($D)

Disassemble and remove context information from disassembly to make testing easier.

       Parameter  Description
    1  $D         Machine code string

# Index

1 [Add](#add) - Add the source locations together and store the result in the target area.

2 [Array](#array) - Create a new memory area and write its number into the address named by the target operand.

3 [ArrayCountGreater](#arraycountgreater) - Count the number of elements in the array specified by the first source operand that are greater than the element supplied by the second source operand and place the result in the target location.

4 [ArrayCountLess](#arraycountless) - Count the number of elements in the array specified by the first source operand that are less than the element supplied by the second source operand and place the result in the target location.

5 [ArrayDump](#arraydump) - Dump an array.

6 [ArrayIndex](#arrayindex) - Find the 1 based index of the second source operand in the array referenced by the first source operand if it is present in the array else 0 into the target location.

7 [ArraySize](#arraysize) - The current size of an array.

8 [Assembly](#assembly) - Start some assembly code.

9 [Assert](#assert) - Assert regardless.

10 [Assert1](#assert1) - Assert operation.

11 [Assert2](#assert2) - Assert operation.

12 [AssertEq](#asserteq) - Assert two memory locations are equal.

13 [AssertFalse](#assertfalse) - Assert false.

14 [AssertGe](#assertge) - Assert that the first value is greater than or equal to the second value.

15 [AssertGt](#assertgt) - Assert that the first value is greater than the second value.

16 [AssertLe](#assertle) - Assert that the first value is less than or equal to the second value.

17 [AssertLt](#assertlt) - Assert that the first value is less than  the second value.

18 [AssertNe](#assertne) - Assert two memory locations are not equal.

19 [AssertTrue](#asserttrue) - Assert true.

20 [Bad](#bad) - A bad ending to a block of code.

21 [Block](#block) - Block of code that can either be restarted or come to a good or a bad ending.

22 [Call](#call) - Call the subroutine at the target address.

23 [Clear](#clear) - Clear the first bytes of an area.

24 [Confess](#confess) - Confess with a stack trace showing the location both in the emulated code and in the code that produced the emulated code.

25 [Dec](#dec) - Decrement the target.

26 [disAssemble](#disassemble) - Disassemble machine code.

27 [disAssembleMinusContext](#disassembleminuscontext) - Disassemble and remove context information from disassembly to make testing easier.

28 [Dump](#dump) - Dump all the arrays currently in memory.

29 [Else](#else) - Else block.

30 [Execute](#execute) - Execute the current assembly.

31 [For](#for) - For loop 0.

32 [ForArray](#forarray) - For loop to process each element of the named area.

33 [ForIn](#forin) - For loop to process each element remaining in the input channel

34 [Free](#free) - Free the memory area named by the target operand after confirming that it has the name specified on the source operand.

35 [GenerateMachineCode](#generatemachinecode) - Generate a string of machine code from the current block of code.

36 [GenerateMachineCodeDisAssembleExecute](#generatemachinecodedisassembleexecute) - Round trip: generate machine code and write it onto a string, disassemble the generated machine code string and recreate a block of code from it, then execute the reconstituted code to prove that it works as well as the original code.

37 [Good](#good) - A good ending to a block of code.

38 [IfEq](#ifeq) - Execute then or else clause depending on whether two memory locations are equal.

39 [IfFalse](#iffalse) - Execute then clause if the specified memory address is zero thus representing false.

40 [IfGe](#ifge) - Execute then or else clause depending on whether two memory locations are greater than or equal.

41 [IfGt](#ifgt) - Execute then or else clause depending on whether two memory locations are greater than.

42 [IfLe](#ifle) - Execute then or else clause depending on whether two memory locations are less than or equal.

43 [IfLt](#iflt) - Execute then or else clause depending on whether two memory locations are less than.

44 [IfNe](#ifne) - Execute then or else clause depending on whether two memory locations are not equal.

45 [IfTrue](#iftrue) - Execute then clause if the specified memory address is not zero thus representing true.

46 [Ifx](#ifx) - Execute then or else clause depending on whether two memory locations are equal.

47 [In](#in) - Read a value from the input channel

48 [Inc](#inc) - Increment the target.

49 [InSize](#insize) - Number of elements remining in the input channel

50 [instructionList](#instructionlist) - Create a list of instructions.

51 [instructionListExport](#instructionlistexport) - Create an export statement.

52 [instructionListMapping](#instructionlistmapping) - Map instructions to small integers.

53 [instructionListReadMe](#instructionlistreadme) - List  instructions for inclusion in read me.

54 [Jeq](#jeq) - Jump to a target label if the first source field is equal to the second source field.

55 [JFalse](#jfalse) - Jump to a target label if the first source field is equal to zero.

56 [Jge](#jge) - Jump to a target label if the first source field is greater than or equal to the second source field.

57 [Jgt](#jgt) - Jump to a target label if the first source field is greater than the second source field.

58 [Jle](#jle) - Jump to a target label if the first source field is less than or equal to the second source field.

59 [Jlt](#jlt) - Jump to a target label if the first source field is less than the second source field.

60 [Jmp](#jmp) - Jump to a label.

61 [Jne](#jne) - Jump to a target label if the first source field is not equal to the second source field.

62 [JTrue](#jtrue) - Jump to a target label if the first source field is not equal to zero.

63 [Label](#label) - Create a label.

64 [LoadAddress](#loadaddress) - Load the address component of an address.

65 [LoadArea](#loadarea) - Load the area component of an address.

66 [Mov](#mov) - Copy a constant or memory address to the target address.

67 [MoveLong](#movelong) - Copy the number of elements specified by the second source operand from the location specified by the first source operand to the target operand.

68 [Nop](#nop) - Do nothing (but do it well!).

69 [Not](#not) - Move and not.

70 [Out](#out) - Write memory location contents to out.

71 [Parallel](#parallel) - Runs its sub sections in simulated parallel so that we can prove that the sections can be run in parallel.

72 [ParallelContinue](#parallelcontinue) - Continue recording the elapsed time for parallel sections.

73 [ParallelStart](#parallelstart) - Start recording the elapsed time for parallel sections.

74 [ParallelStop](#parallelstop) - Stop recording the elapsed time for parallel sections.

75 [ParamsGet](#paramsget) - Get a word from the parameters in the previous frame and store it in the current frame.

76 [ParamsPut](#paramsput) - Put a word into the parameters list to make it visible in a called procedure.

77 [Pop](#pop) - Pop the memory area specified by the source operand into the memory address specified by the target operand.

78 [Procedure](#procedure) - Define a procedure.

79 [Push](#push) - Push the value in the current stack frame specified by the source operand onto the memory area identified by the target operand.

80 [Random](#random) - Create a random number in a specified range.

81 [RandomSeed](#randomseed) - Seed the random number generator.

82 [rerefValue](#rerefvalue) - Re-reference a value.

83 [Resize](#resize) - Resize the target area to the source size.

84 [Return](#return) - Return from a procedure via the call stack.

85 [ReturnGet](#returnget) - Get a word from the return area and save it.

86 [ReturnPut](#returnput) - Put a word into the return area.

87 [Sequential](#sequential) - Runs its sub sections in sequential order

88 [ShiftDown](#shiftdown) - Shift an element down one in an area.

89 [ShiftLeft](#shiftleft) - Shift left within an element.

90 [ShiftRight](#shiftright) - Shift right with an element.

91 [ShiftUp](#shiftup) - Shift an element up one in an area.

92 [Start](#start) - Start the current assembly using the specified version of the Zero language.

93 [Subtract](#subtract) - Subtract the second source operand value from the first source operand value and store the result in the target area.

94 [Tally](#tally) - Counts instructions when enabled.

95 [Then](#then) - Then block.

96 [Trace](#trace) - Start or stop tracing.

97 [TraceLabels](#tracelabels) - Enable or disable label tracing.

98 [unpackInstruction](#unpackinstruction) - Unpack an instruction.

99 [Var](#var) - Create a variable initialized to the specified value.

100 [Watch](#watch) - Watches for changes to the specified memory location.

101 [Zero::Emulator::Code::packInstruction](#zero-emulator-code-packinstruction) - Pack an instruction.

102 [Zero::Emulator::Code::packRef](#zero-emulator-code-packref) - Pack a reference into 8 bytes.

103 [Zero::Emulator::Code::unpackRef](#zero-emulator-code-unpackref) - Unpack a reference.

# Installation

This module is written in 100% Pure Perl and, thus, it is easy to read,
comprehend, use, modify and install via **cpan**:

    sudo cpan install Zero::Emulator

# Author

[philiprbrenan@gmail.com](mailto:philiprbrenan@gmail.com)

[http://www.appaapps.com](http://www.appaapps.com)

# Copyright

Copyright (c) 2016-2023 Philip R Brenan.

This module is free software. It may be used, redistributed and/or modified
under the same terms as Perl itself.
