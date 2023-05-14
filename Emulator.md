# Name

Zero::Emulator - Assemble and emulate a program written in the [Zero](https://github.com/philiprbrenan/zero) assembler programming language.

<div>

    <p><a href="https://github.com/philiprbrenan/zero"><img src="https://github.com/philiprbrenan/zero/workflows/Test/badge.svg"></a>
</div>

# Synopsis

Say "hello world":

    Start 1;

    Out "hello World";

    my $e = Execute;

    is_deeply $e->out, ["hello World"];

# Description

Version 20230515.

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
      my $e = Execute(suppressOutput=>1);
      is_deeply $e->out, <<END;
    5
    END
     }
    

## Array($name)

Create a new memory area and write its number into the address named by the target operand.

       Parameter  Description
    1  $name      Name of allocation

**Example:**

    if (1)                                                                             
     {Start 1;
    
      my $a = Array "aaa";  # 𝗘𝘅𝗮𝗺𝗽𝗹𝗲

        Mov [$a, 0, "aaa"], 1;
        Mov [$a, 1, "aaa"], 22;
        Mov [$a, 2, "aaa"], 333;
    
      my $n = ArraySize $a, "aaa";
    
      Out "Array size:", $n;  # 𝗘𝘅𝗮𝗺𝗽𝗹𝗲

      ArrayDump $a, "AAAA";
    
      ForArray
       {my ($i, $e, $check, $next, $end) = @_;
        Out $i; Out $e;
       }  $a, "aaa";
    
      Nop;
      my $e = Execute(suppressOutput=>1);
    
      is_deeply $e->memory, {4=>[1, 22, 333]};
    
      is_deeply join(' ', $e->out->@*), <<END;
    
    Array size: 3  # 𝗘𝘅𝗮𝗺𝗽𝗹𝗲

     AAAA bless([1, 22, 333], "aaa") Stack trace     1     9 arrayDump 0
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
    
      Out ArrayIndex $a, 30;
      Out ArrayIndex $a, 20;
      Out ArrayIndex $a, 10;
      Out ArrayIndex $a, 15;
    
    
      Out ArrayCountLess $a, 35;  # 𝗘𝘅𝗮𝗺𝗽𝗹𝗲

    
      Out ArrayCountLess $a, 25;  # 𝗘𝘅𝗮𝗺𝗽𝗹𝗲

    
      Out ArrayCountLess $a, 15;  # 𝗘𝘅𝗮𝗺𝗽𝗹𝗲

    
      Out ArrayCountLess $a,  5;  # 𝗘𝘅𝗮𝗺𝗽𝗹𝗲

    
      Out ArrayCountGreater $a, 35;
      Out ArrayCountGreater $a, 25;
      Out ArrayCountGreater $a, 15;
      Out ArrayCountGreater $a,  5;
    
      my $e = Execute(suppressOutput=>1);
      is_deeply $e->out, [3,2,1,0,  3,2,1,0,  0,1,2,3];
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
    
      Out ArrayIndex $a, 30;
      Out ArrayIndex $a, 20;
      Out ArrayIndex $a, 10;
      Out ArrayIndex $a, 15;
    
      Out ArrayCountLess $a, 35;
      Out ArrayCountLess $a, 25;
      Out ArrayCountLess $a, 15;
      Out ArrayCountLess $a,  5;
    
    
      Out ArrayCountGreater $a, 35;  # 𝗘𝘅𝗮𝗺𝗽𝗹𝗲

    
      Out ArrayCountGreater $a, 25;  # 𝗘𝘅𝗮𝗺𝗽𝗹𝗲

    
      Out ArrayCountGreater $a, 15;  # 𝗘𝘅𝗮𝗺𝗽𝗹𝗲

    
      Out ArrayCountGreater $a,  5;  # 𝗘𝘅𝗮𝗺𝗽𝗹𝗲

    
      my $e = Execute(suppressOutput=>1);
      is_deeply $e->out, [3,2,1,0,  3,2,1,0,  0,1,2,3];
     }
    

## ArrayDump($target, $title)

Dump an array.

       Parameter  Description
    1  $target    Array to dump
    2  $title     Title of dump

**Example:**

    if (1)                                                                           
     {Start 1;
      my $a = Array "aaa";
      Mov [$a, 0, "aaa"], 1;
      Mov [$a, 1, "aaa"], 22;
      Mov [$a, 2, "aaa"], 333;
    
      ArrayDump $a, "AAAA";  # 𝗘𝘅𝗮𝗺𝗽𝗹𝗲

      my $e = Execute(suppressOutput=>1);
    
      is_deeply $e->out, [
      "AAAA",
      "bless([1, 22, 333], \"aaa\")",
      "Stack trace",
      "    1     5 arrayDump"];
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
    
    
      Out ArrayIndex $a, 30;  # 𝗘𝘅𝗮𝗺𝗽𝗹𝗲

    
      Out ArrayIndex $a, 20;  # 𝗘𝘅𝗮𝗺𝗽𝗹𝗲

    
      Out ArrayIndex $a, 10;  # 𝗘𝘅𝗮𝗺𝗽𝗹𝗲

    
      Out ArrayIndex $a, 15;  # 𝗘𝘅𝗮𝗺𝗽𝗹𝗲

    
      Out ArrayCountLess $a, 35;
      Out ArrayCountLess $a, 25;
      Out ArrayCountLess $a, 15;
      Out ArrayCountLess $a,  5;
    
      Out ArrayCountGreater $a, 35;
      Out ArrayCountGreater $a, 25;
      Out ArrayCountGreater $a, 15;
      Out ArrayCountGreater $a,  5;
    
      my $e = Execute(suppressOutput=>1);
      is_deeply $e->out, [3,2,1,0,  3,2,1,0,  0,1,2,3];
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
        Mov [$a, 0, "aaa"], 1;
        Mov [$a, 1, "aaa"], 22;
        Mov [$a, 2, "aaa"], 333;
    
    
      my $n = ArraySize $a, "aaa";  # 𝗘𝘅𝗮𝗺𝗽𝗹𝗲

      Out "Array size:", $n;
      ArrayDump $a, "AAAA";
    
      ForArray
       {my ($i, $e, $check, $next, $end) = @_;
        Out $i; Out $e;
       }  $a, "aaa";
    
      Nop;
      my $e = Execute(suppressOutput=>1);
    
      is_deeply $e->memory, {4=>[1, 22, 333]};
    
      is_deeply join(' ', $e->out->@*), <<END;
    Array size: 3
     AAAA bless([1, 22, 333], "aaa") Stack trace     1     9 arrayDump 0
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

      my $e = Execute(suppressOutput=>1);
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

      my $e = Execute(suppressOutput=>1);
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

      my $e = Execute(suppressOutput=>1, trace=>1);
    
      is_deeply $e->out, <<END;
        1     0     1    assertTrue
    
    AssertFalse 1 failed  # 𝗘𝘅𝗮𝗺𝗽𝗹𝗲

        1     2 assertFalse
        2     1     1   assertFalse
    END
     }
    

## AssertGe($a, $b, %options)

Assert are greater than or equal.

       Parameter  Description
    1  $a         First memory address
    2  $b         Second memory address
    3  %options

**Example:**

    if (1)                                                                          
     {Start 1;
      Mov 0, 1;
    
      AssertGe \0, 2;  # 𝗘𝘅𝗮𝗺𝗽𝗹𝗲

      my $e = Execute(suppressOutput=>1);
      is_deeply $e->out, <<END;
    Assert 1 >= 2 failed
        1     2 assertGe
    END
     }
    

## AssertGt($a, $b, %options)

Assert two memory locations are greater than.

       Parameter  Description
    1  $a         First memory address
    2  $b         Second memory address
    3  %options

**Example:**

    if (1)                                                                          
     {Start 1;
      Mov 0, 1;
    
      AssertGt \0, 2;  # 𝗘𝘅𝗮𝗺𝗽𝗹𝗲

      my $e = Execute(suppressOutput=>1);
      is_deeply $e->out, <<END;
    Assert 1 >  2 failed
        1     2 assertGt
    END
     }
    

## AssertLe($a, $b, %options)

Assert two memory locations are less than or equal.

       Parameter  Description
    1  $a         First memory address
    2  $b         Second memory address
    3  %options

**Example:**

    if (1)                                                                          
     {Start 1;
      Mov 0, 1;
    
      AssertLe \0, 0;  # 𝗘𝘅𝗮𝗺𝗽𝗹𝗲

      my $e = Execute(suppressOutput=>1);
      is_deeply $e->out, <<END;
    Assert 1 <= 0 failed
        1     2 assertLe
    END
     }
    

## AssertLt($a, $b, %options)

Assert two memory locations are less than.

       Parameter  Description
    1  $a         First memory address
    2  $b         Second memory address
    3  %options

**Example:**

    if (1)                                                                          
     {Start 1;
      Mov 0, 1;
    
      AssertLt \0, 0;  # 𝗘𝘅𝗮𝗺𝗽𝗹𝗲

      my $e = Execute(suppressOutput=>1);
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

      my $e = Execute(suppressOutput=>1);
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

      my $e = Execute(suppressOutput=>1, trace=>1);
      is_deeply $e->out, <<END;
        1     0     1   assertFalse
    
    AssertTrue 0 failed  # 𝗘𝘅𝗮𝗺𝗽𝗹𝗲

        1     2 assertTrue
        2     1     1    assertTrue
    END
     }
    

## Bad($bad)

A bad ending.

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
      my $e = Execute(suppressOutput=>1);
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
      my $e = Execute(suppressOutput=>1);
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
      my $e = Execute(suppressOutput=>1);
      is_deeply $e->out, <<END;
    1
    3
    4
    END
     }
    

## Call($p)

Call the subroutine at the target address.

       Parameter  Description
    1  $p         Procedure description

**Example:**

    if (1)                                                                           
     {Start 1;
      my $w = Procedure 'write', sub
       {Out 'aaa';
        Return;
       };
    
      Call $w;  # 𝗘𝘅𝗮𝗺𝗽𝗹𝗲

      my $e = Execute(suppressOutput=>1);
      is_deeply $e->out, <<END;
    aaa
    END
     }
    
    if (1)                                                                          
     {Start 1;
      my $w = Procedure 'write', sub
       {my $a = ParamsGet 0;
        Out $a;
        Return;
       };
      ParamsPut 0, 'bbb';
    
      Call $w;  # 𝗘𝘅𝗮𝗺𝗽𝗹𝗲

      my $e = Execute(suppressOutput=>1);
      is_deeply $e->out, <<END;
    bbb
    END
     }
    
    if (1)                                                                            
     {Start 1;
      my $w = Procedure 'write', sub
       {ReturnPut 0, "ccc";
        Return;
       };
    
      Call $w;  # 𝗘𝘅𝗮𝗺𝗽𝗹𝗲

      ReturnGet \0, 0;
      Out \0;
      my $e = Execute(suppressOutput=>1);
      is_deeply $e->out, <<END;
    ccc
    END
     }
    
    if (1)                                                                            
     {Start 1;
      my $a = Array "aaa";
      Dump "dddd";
      my $e = Execute(suppressOutput=>1);
    
      is_deeply $e->out, <<END;
    dddd
    1=bless([4], "stackArea")
    2=bless([], "params")
    3=bless([], "return")
    4=bless([], "aaa")
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
      my $e = Execute(suppressOutput=>1);
      is_deeply $e->out, <<END;
    11
    END
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

      my $e = Execute(suppressOutput=>1);
      is_deeply $e->out, <<END;
    1
    2
    3
    END
     }
    

## Clear($target)

Clear the first bytes of an area.  The area is specified by the first element of the address, the number of locations to clear is specified by the second element of the target address.

       Parameter  Description
    1  $target    Target address

**Example:**

    if (1)                                                                           
     {Start 1;
      my $a = Array "aaa";
    
      Clear [$a, 10, 'aaa'];  # 𝗘𝘅𝗮𝗺𝗽𝗹𝗲

      my $e = Execute(suppressOutput=>1);
      is_deeply $e->memory->{4}, [0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
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
      my $e = Execute(suppressOutput=>1);
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
      my $e = Execute(suppressOutput=>1);
      is_deeply $e->out, <<END;
    2
    END
     }
    

## Dump($title)

Dump all the arrays currently in memory.

       Parameter  Description
    1  $title     Title

**Example:**

    if (1)                                                                           
     {Start 1;
      my $a = Array "node";
      Out $a;
      Mov [$a, 1, 'node'], 1;
      Mov [$a, 2, 'node'], 2;
      Mov 1, [$a, \1, 'node'];
    
      Dump "dddd";  # 𝗘𝘅𝗮𝗺𝗽𝗹𝗲

      Free $a, "node";
      my $e = Execute(suppressOutput=>1);
      is_deeply $e->out, <<END;
    4
    dddd
    1=bless([4, 1], "stackArea")
    2=bless([], "params")
    3=bless([], "return")
    4=bless([undef, 1, 2], "node")
    Stack trace:
        1     7 dump
    END
     }
    

## Else($e)

Else block.

       Parameter  Description
    1  $e         Else block subroutine

**Example:**

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
      my $e = Execute(suppressOutput=>1);
      is_deeply scalar($e->out->@*), 14;
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
      my $e = Execute(suppressOutput=>1);
      is_deeply $e->out, <<END;
    0
    1
    2
    3
    4
    5
    6
    7
    8
    9
    END
     }
    
    if (1)                                                                          
     {Start 1;
    
      For  # 𝗘𝘅𝗮𝗺𝗽𝗹𝗲

       {my ($i) = @_;
        Out $i;
       } 10, reverse=>1;
      my $e = Execute(suppressOutput=>1);
      is_deeply $e->out, <<END;
    9
    8
    7
    6
    5
    4
    3
    2
    1
    0
    END
     }
    
    if (1)                                                                          
     {Start 1;
    
      For  # 𝗘𝘅𝗮𝗺𝗽𝗹𝗲

       {my ($i) = @_;
        Out $i;
       } [2, 10];
      my $e = Execute(suppressOutput=>1);
      is_deeply $e->out, <<END;
    2
    3
    4
    5
    6
    7
    8
    9
    END
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
      is_deeply $e->tallyCounts, { 1 => {mov => $N}, 2 => {inc => $N}};
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
        Mov [$a, 0, "aaa"], 1;
        Mov [$a, 1, "aaa"], 22;
        Mov [$a, 2, "aaa"], 333;
    
      my $n = ArraySize $a, "aaa";
      Out "Array size:", $n;
      ArrayDump $a, "AAAA";
    
    
      ForArray  # 𝗘𝘅𝗮𝗺𝗽𝗹𝗲

       {my ($i, $e, $check, $next, $end) = @_;
        Out $i; Out $e;
       }  $a, "aaa";
    
      Nop;
      my $e = Execute(suppressOutput=>1);
    
      is_deeply $e->memory, {4=>[1, 22, 333]};
    
      is_deeply join(' ', $e->out->@*), <<END;
    Array size: 3
     AAAA bless([1, 22, 333], "aaa") Stack trace     1     9 arrayDump 0
     1
     1
     22
     2
     333
    END
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
      Dump "dddd";
    
      Free $a, "node";  # 𝗘𝘅𝗮𝗺𝗽𝗹𝗲

      my $e = Execute(suppressOutput=>1);
      is_deeply $e->out, <<END;
    4
    dddd
    1=bless([4, 1], "stackArea")
    2=bless([], "params")
    3=bless([], "return")
    4=bless([undef, 1, 2], "node")
    Stack trace:
        1     7 dump
    END
     }
    

## Good($good)

A good ending.

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
      my $e = Execute(suppressOutput=>1);
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
      my $e = Execute(suppressOutput=>1);
      is_deeply $e->out, <<END;
    0
    END
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
      my $e = Execute(suppressOutput=>1);
      is_deeply $e->out, <<END;
    1
    END
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
      my $e = Execute(suppressOutput=>1);
      is_deeply $e->out, <<END;
    4
    END
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
    
      my $e = Execute(suppressOutput=>1);
    
      is_deeply $e->analyzeExecutionResults(doubleWrite=>3), "#       24 instructions executed";
      is_deeply $e->memory, {4 => [5], 5 => [99]};
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
      my $e = Execute(suppressOutput=>1);
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
    
      my $e = Execute(suppressOutput=>1);
    
      is_deeply $e->analyzeExecutionResults(doubleWrite=>3), "#       24 instructions executed";
      is_deeply $e->memory, {4 => [5], 5 => [99]};
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
    
      my $e = Execute(suppressOutput=>1);
    
      is_deeply $e->analyzeExecutionResults(doubleWrite=>3), "#       24 instructions executed";
      is_deeply $e->memory, {4 => [5], 5 => [99]};
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
    
      my $e = Execute(suppressOutput=>1);
    
      is_deeply $e->analyzeExecutionResults(doubleWrite=>3), "#       24 instructions executed";
      is_deeply $e->memory, {4 => [5], 5 => [99]};
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
    
      my $e = Execute(suppressOutput=>1);
    
      is_deeply $e->analyzeExecutionResults(doubleWrite=>3), "#       24 instructions executed";
      is_deeply $e->memory, {4 => [5], 5 => [99]};
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
      my $e = Execute(suppressOutput=>1);
      is_deeply $e->out, <<END;
    2
    END
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
    
      my $e = Execute(suppressOutput=>1);
    
      is_deeply $e->analyzeExecutionResults(doubleWrite=>3), "#       24 instructions executed";
      is_deeply $e->memory, {4 => [5], 5 => [99]};
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
      my $e = Execute(suppressOutput=>1);
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
    
      my $e = Execute(suppressOutput=>1);
    
      is_deeply $e->out, <<END;
    2
    4
    END
    
      is_deeply $e->memory, {4=>[undef, undef, 44, undef, undef, 33]};
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
    
      my $e = Execute(suppressOutput=>1);
    
      is_deeply $e->out, <<END;
    2
    4
    END
    
      is_deeply $e->memory, {4=>[undef, undef, 44, undef, undef, 33]};
     }
    

## Mov()

Copy a constant or memory address to the target address.

**Example:**

    if (1)                                                                          
     {Start 1;
    
      my $a = Mov 2;  # 𝗘𝘅𝗮𝗺𝗽𝗹𝗲

      Out $a;
      my $e = Execute(suppressOutput=>1);
      is_deeply $e->out, <<END;
    2
    END
     }
    
     {Start 1;                                                                      
    
    if (1)                                                                          
     {Start 1;
      my $a = Array "aaa";
    
      Mov     [$a,  1, "aaa"],  11;  # 𝗘𝘅𝗮𝗺𝗽𝗹𝗲

    
      Mov  1, [$a, \1, "aaa"];  # 𝗘𝘅𝗮𝗺𝗽𝗹𝗲

      Out \1;
      my $e = Execute(suppressOutput=>1);
      is_deeply $e->out, <<END;
    11
    END
     }
    
    if (1)                                                                           
     {Start 1;
      my $a = Array "alloc";
    
      my $b = Mov 99;  # 𝗘𝘅𝗮𝗺𝗽𝗹𝗲

    
      my $c = Mov $a;  # 𝗘𝘅𝗮𝗺𝗽𝗹𝗲

    
      Mov [$a, 0, 'alloc'], $b;  # 𝗘𝘅𝗮𝗺𝗽𝗹𝗲

    
      Mov [$c, 1, 'alloc'], 2;  # 𝗘𝘅𝗮𝗺𝗽𝗹𝗲

      my $e = Execute(suppressOutput=>1);
      is_deeply $e->memory, {4 => [99, 2]};
     }
    
    if (1)                                                                            
     {Start 1;
      my $a = Array "aaa";
      Dump "dddd";
      my $e = Execute(suppressOutput=>1);
    
      is_deeply $e->out, <<END;
    dddd
    1=bless([4], "stackArea")
    2=bless([], "params")
    3=bless([], "return")
    4=bless([], "aaa")
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
      my $e = Execute(suppressOutput=>1);
      is_deeply $e->out, <<END;
    11
    END
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
      my $e = Execute(suppressOutput=>1);
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
    
      my $e = Execute(suppressOutput=>1);
    
      is_deeply $e->analyzeExecutionResults(doubleWrite=>3), "#       24 instructions executed";
      is_deeply $e->memory, {4 => [5], 5 => [99]};
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
    
      my $e = Execute(suppressOutput=>1);
    
      is_deeply $e->analyzeExecutionResults(doubleWrite=>3), "#       19 instructions executed";
      is_deeply $e->memory, {4 =>  bless([undef, undef, 1], "aaa")};
     }
    
    if (1)                                                                           
     {Start 1;
      my $a = Array "aaa";
    
      Mov [$a, 0, "aaa"], 1;  # 𝗘𝘅𝗮𝗺𝗽𝗹𝗲

    
      Mov [$a, 1, "aaa"], 22;  # 𝗘𝘅𝗮𝗺𝗽𝗹𝗲

    
      Mov [$a, 2, "aaa"], 333;  # 𝗘𝘅𝗮𝗺𝗽𝗹𝗲

      ArrayDump $a, "AAAA";
      my $e = Execute(suppressOutput=>1);
    
      is_deeply $e->out, [
      "AAAA",
      "bless([1, 22, 333], \"aaa\")",
      "Stack trace",
      "    1     5 arrayDump"];
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

    
      my $e = Execute(suppressOutput=>1);
    
      is_deeply $e->memory, {
      4 => [0 .. 9],
      5 => [100, 101, 4, 5, 6, 105 .. 109]};
     }
    

## Not()

Move and not.

**Example:**

    if (1)                                                                          
     {Start 1;
      my $a = Mov 3;
    
      my $b = Not $a;  # 𝗘𝘅𝗮𝗺𝗽𝗹𝗲

    
      my $c = Not $b;  # 𝗘𝘅𝗮𝗺𝗽𝗹𝗲

      Out $a, $b, $c;
      my $e = Execute(suppressOutput=>1);
      is_deeply $e->out, <<END;
    3  1
    END
     }
    

## Nop()

Do nothing (but do it well!).

**Example:**

    if (1)                                                                          
     {Start 1;
    
      Nop;  # 𝗘𝘅𝗮𝗺𝗽𝗹𝗲

      my $e = Execute;
      is_deeply $e->out, "";
    
     }
    
    if (1)                                                                             
     {Start 1;
      my $a = Array "aaa";
        Mov [$a, 0, "aaa"], 1;
        Mov [$a, 1, "aaa"], 22;
        Mov [$a, 2, "aaa"], 333;
    
      my $n = ArraySize $a, "aaa";
      Out "Array size:", $n;
      ArrayDump $a, "AAAA";
    
      ForArray
       {my ($i, $e, $check, $next, $end) = @_;
        Out $i; Out $e;
       }  $a, "aaa";
    
    
      Nop;  # 𝗘𝘅𝗮𝗺𝗽𝗹𝗲

      my $e = Execute(suppressOutput=>1);
    
      is_deeply $e->memory, {4=>[1, 22, 333]};
    
      is_deeply join(' ', $e->out->@*), <<END;
    Array size: 3
     AAAA bless([1, 22, 333], "aaa") Stack trace     1     9 arrayDump 0
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
      my $e = Execute(suppressOutput=>1);
      is_deeply $e->out, <<END;
    11
    END
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
      my $e = Execute(suppressOutput=>1);
      is_deeply $e->out, <<END;
    11
    END
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

    
      Out $c, $d;
      my $e = Execute(suppressOutput=>1);
      is_deeply $e->out, <<END;
    2 1
    END
      is_deeply $e->memory, {4 => []};
     }
    

## Procedure($name, $source)

Define a procedure.

       Parameter  Description
    1  $name      Name of procedure
    2  $source    Source code as a subroutine# $assembly->instruction(action=>"procedure"

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
      my $e = Execute(suppressOutput=>1);
      is_deeply $e->out, <<END;
    4
    END
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
      my $e = Execute(suppressOutput=>1);
      is_deeply $e->out, <<END;
    1
    2
    3
    4
    5
    6
    7
    8
    9
    10
    END
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
    
      Out $c, $d;
      my $e = Execute(suppressOutput=>1);
      is_deeply $e->out, <<END;
    2 1
    END
      is_deeply $e->memory, {4 => []};
     }
    

## Resize($target, $source)

Resize the target area to the source size.

       Parameter  Description
    1  $target    Target address
    2  $source    Source address

**Example:**

    if (1)                                                                          
     {Start 1;
      my $a = Array 'aaa';
      Mov [$a, 0, 'aaa'], 1;
      Mov [$a, 1, 'aaa'], 2;
      Mov [$a, 2, 'aaa'], 3;
      my $n = Mov [$a, \1, 'aaa', -1];
      my $N = Mov [$a, \1, 'aaa', +1];
    
      Resize $a, 2;  # 𝗘𝘅𝗮𝗺𝗽𝗹𝗲

    
      Out $N; Out $n;
    
      my $e = Execute(suppressOutput=>1);
    
      is_deeply $e->memory, {4 => [1, 2]};
      is_deeply $e->out,    [map {($_, "
  ")} 3, 1];
     }
    

## Random(if (@\_ == 1))

Create a random number in a specified range

       Parameter     Description
    1  if (@_ == 1)  Create a variable

**Example:**

    if (1)                                                                           
     {Start 1;
      RandomSeed 1;
    
      my $a = Random 10;  # 𝗘𝘅𝗮𝗺𝗽𝗹𝗲

      Out $a;
      my $e = Execute(suppressOutput=>1);
      ok $e->out->[0] =~ m(\A\d\Z);
     }
    

## RandomSeed($seed)

Seed the random number generator

       Parameter  Description
    1  $seed      Parameters

**Example:**

    if (1)                                                                           
     {Start 1;
    
      RandomSeed 1;  # 𝗘𝘅𝗮𝗺𝗽𝗹𝗲

      my $a = Random 10;
      Out $a;
      my $e = Execute(suppressOutput=>1);
      ok $e->out->[0] =~ m(\A\d\Z);
     }
    

## Return()

Return from a procedure via the call stack.

**Example:**

    if (1)                                                                           
     {Start 1;
      my $w = Procedure 'write', sub
       {Out 'aaa';
    
        Return;  # 𝗘𝘅𝗮𝗺𝗽𝗹𝗲

       };
      Call $w;
      my $e = Execute(suppressOutput=>1);
      is_deeply $e->out, <<END;
    aaa
    END
     }
    

## ReturnGet(if (@\_ == 1))

Get a word from the return area and save it.

       Parameter     Description
    1  if (@_ == 1)  Create a variable

**Example:**

    if (1)                                                                            
     {Start 1;
      my $w = Procedure 'write', sub
       {ReturnPut 0, "ccc";
        Return;
       };
      Call $w;
    
      ReturnGet \0, 0;  # 𝗘𝘅𝗮𝗺𝗽𝗹𝗲

      Out \0;
      my $e = Execute(suppressOutput=>1);
      is_deeply $e->out, <<END;
    ccc
    END
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
    
       {ReturnPut 0, "ccc";  # 𝗘𝘅𝗮𝗺𝗽𝗹𝗲

        Return;
       };
      Call $w;
      ReturnGet \0, 0;
      Out \0;
      my $e = Execute(suppressOutput=>1);
      is_deeply $e->out, <<END;
    ccc
    END
     }
    

## ShiftDown(if (@\_ == 1))

Shift an element down one in an area.

       Parameter     Description
    1  if (@_ == 1)  Create a variable

**Example:**

    if (1)                                                                          
     {Start 1;
      my $a = Array "array";
      Mov [$a, 0, 'array'], 0;
      Mov [$a, 1, 'array'], 99;
      Mov [$a, 2, 'array'], 2;
    
    
      my $b = ShiftDown [$a, \1, 'array'];  # 𝗘𝘅𝗮𝗺𝗽𝗹𝗲

      Out $b;
    
      my $e = Execute(suppressOutput=>1);
      is_deeply $e->memory, {4=>[0, 2]};
      is_deeply $e->out, <<END;
    99
    END
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
      my $e = Execute(suppressOutput=>1);
      is_deeply $e->out, <<END;
    2
    END
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
      my $e = Execute(suppressOutput=>1);
      is_deeply $e->out, <<END;
    2
    END
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
    
      ShiftUp [$a, 1, 'array'], 99;  # 𝗘𝘅𝗮𝗺𝗽𝗹𝗲

    
      my $e = Execute(suppressOutput=>1);
    
      is_deeply $e->memory, {4=>[0, 99, 1, 2]};
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
      my $e = Execute(suppressOutput=>1);
      is_deeply $e->out, <<END;
    2
    END
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
      is_deeply $e->tallyCounts, { 1 => {mov => $N}, 2 => {inc => $N}};
     }
    

## Then($t)

Then block.

       Parameter  Description
    1  $t         Then block subroutine

**Example:**

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
      my $e = Execute(suppressOutput=>1);
      is_deeply scalar($e->out->@*), 14;
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
      my $e = Execute(suppressOutput=>1);
      is_deeply scalar($e->out->@*), 14;
     }
    

## TracePoints($source)

Enable or disable trace points.  If trace points are enabled a stack trace is printed for each instruction executed showing the call stack at the time the instruction was generated as well as the current stack frames.

       Parameter  Description
    1  $source    Trace points if true

**Example:**

    if (1)                                                                          
     {my $N = 5;
      Start 1;
    
      TracePoints 1;  # 𝗘𝘅𝗮𝗺𝗽𝗹𝗲

      For
       {my $a = Mov 1;
        Inc $a;
       } $N;
      my $e = Execute(suppressOutput=>1);
      is_deeply $e->out, [
    
      "TracePoints: 1",  # 𝗘𝘅𝗮𝗺𝗽𝗹𝗲

      "Trace",
      "    1     6 tracePoint",
      "Trace",
      "    1     6 tracePoint",
      "Trace",
      "    1     6 tracePoint",
      "Trace",
      "    1     6 tracePoint",
      "Trace",
      "    1     6 tracePoint"];
     }
    

## Var($value)

Create a variable initialized to the specified value.

       Parameter  Description
    1  $value     Value

**Example:**

    if (1)                                                                          
     {Start 1;
    
      my $a = Var 1;  # 𝗘𝘅𝗮𝗺𝗽𝗹𝗲

      AssertEq $a, 1;
      my $e = Execute(suppressOutput=>0);
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
    
      is_deeply $e->out, [
      "Change at watched area: 1 (stackArea), address: 1",
      "    1     6 mov",
      "Current value: 2",
      "New     value: 5",
      "1=bless([4, 2, 3], \"stackArea\")",
      "2=bless([], \"params\")",
      "3=bless([], \"return\")"];
     }
    

# Private Methods

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
      my $e = Execute(suppressOutput=>1);
      is_deeply $e->out, <<END;
    2
    3
    END
     }
    
    if (1)                                                                          
     {Start 1;
      Mov 0, 0;
      my $a = setLabel;
        Out \0;
        Inc \0;
      Jlt $a, \0, 10;
      my $e = Execute(suppressOutput=>1);
      is_deeply $e->out, <<END;
    0
    1
    2
    3
    4
    5
    6
    7
    8
    9
    END
     }
    

## TracePoint(%options)

Trace point - a point in the code where the flow of execution might change.

       Parameter  Description
    1  %options   Parameters

# Index

1 [Add](#add) - Add the source locations together and store the result in the target area.

2 [Array](#array) - Create a new memory area and write its number into the address named by the target operand.

3 [ArrayCountGreater](#arraycountgreater) - Count the number of elements in the array specified by the first source operand that are greater than the element supplied by the second source operand and place the result in the target location.

4 [ArrayCountLess](#arraycountless) - Count the number of elements in the array specified by the first source operand that are less than the element supplied by the second source operand and place the result in the target location.

5 [ArrayDump](#arraydump) - Dump an array.

6 [ArrayIndex](#arrayindex) - Find the 1 based index of the second source operand in the array referenced by the first source operand if it is present in the array else 0 into the target location.

7 [ArraySize](#arraysize) - The current size of an array.

8 [Assert](#assert) - Assert regardless.

9 [Assert1](#assert1) - Assert operation.

10 [Assert2](#assert2) - Assert operation.

11 [AssertEq](#asserteq) - Assert two memory locations are equal.

12 [AssertFalse](#assertfalse) - Assert false.

13 [AssertGe](#assertge) - Assert are greater than or equal.

14 [AssertGt](#assertgt) - Assert two memory locations are greater than.

15 [AssertLe](#assertle) - Assert two memory locations are less than or equal.

16 [AssertLt](#assertlt) - Assert two memory locations are less than.

17 [AssertNe](#assertne) - Assert two memory locations are not equal.

18 [AssertTrue](#asserttrue) - Assert true.

19 [Bad](#bad) - A bad ending.

20 [Block](#block) - Block of code that can either be restarted or come to a good or a bad ending.

21 [Call](#call) - Call the subroutine at the target address.

22 [Clear](#clear) - Clear the first bytes of an area.

23 [Confess](#confess) - Confess with a stack trace showing the location both in the emulated code and in the code that produced the emulated code.

24 [Dec](#dec) - Decrement the target.

25 [Dump](#dump) - Dump all the arrays currently in memory.

26 [Else](#else) - Else block.

27 [Execute](#execute) - Execute the current assembly.

28 [For](#for) - For loop 0.

29 [ForArray](#forarray) - For loop to process each element of the named area.

30 [Free](#free) - Free the memory area named by the target operand after confirming that it has the name specified on the source operand.

31 [Good](#good) - A good ending.

32 [IfEq](#ifeq) - Execute then or else clause depending on whether two memory locations are equal.

33 [IfFalse](#iffalse) - Execute then clause if the specified memory address is zero thus representing false.

34 [IfGe](#ifge) - Execute then or else clause depending on whether two memory locations are greater than or equal.

35 [IfGt](#ifgt) - Execute then or else clause depending on whether two memory locations are greater than.

36 [IfLe](#ifle) - Execute then or else clause depending on whether two memory locations are less than or equal.

37 [IfLt](#iflt) - Execute then or else clause depending on whether two memory locations are less than.

38 [IfNe](#ifne) - Execute then or else clause depending on whether two memory locations are not equal.

39 [IfTrue](#iftrue) - Execute then clause if the specified memory address is not zero thus representing true.

40 [Ifx](#ifx) - Execute then or else clause depending on whether two memory locations are equal.

41 [Inc](#inc) - Increment the target.

42 [Jeq](#jeq) - Jump to a target label if the first source field is equal to the second source field.

43 [JFalse](#jfalse) - Jump to a target label if the first source field is equal to zero.

44 [Jge](#jge) - Jump to a target label if the first source field is greater than or equal to the second source field.

45 [Jgt](#jgt) - Jump to a target label if the first source field is greater than the second source field.

46 [Jle](#jle) - Jump to a target label if the first source field is less than or equal to the second source field.

47 [Jlt](#jlt) - Jump to a target label if the first source field is less than the second source field.

48 [Jmp](#jmp) - Jump to a label.

49 [Jne](#jne) - Jump to a target label if the first source field is not equal to the second source field.

50 [JTrue](#jtrue) - Jump to a target label if the first source field is not equal to zero.

51 [Label](#label) - Create a label.

52 [LoadAddress](#loadaddress) - Load the address component of an address.

53 [LoadArea](#loadarea) - Load the area component of an address.

54 [Mov](#mov) - Copy a constant or memory address to the target address.

55 [MoveLong](#movelong) - Copy the number of elements specified by the second source operand from the location specified by the first source operand to the target operand.

56 [Nop](#nop) - Do nothing (but do it well!).

57 [Not](#not) - Move and not.

58 [Out](#out) - Write memory location contents to out.

59 [ParamsGet](#paramsget) - Get a word from the parameters in the previous frame and store it in the current frame.

60 [ParamsPut](#paramsput) - Put a word into the parameters list to make it visible in a called procedure.

61 [Pop](#pop) - Pop the memory area specified by the source operand into the memory address specified by the target operand.

62 [Procedure](#procedure) - Define a procedure.

63 [Push](#push) - Push the value in the current stack frame specified by the source operand onto the memory area identified by the target operand.

64 [Random](#random) - Create a random number in a specified range

65 [RandomSeed](#randomseed) - Seed the random number generator

66 [Resize](#resize) - Resize the target area to the source size.

67 [Return](#return) - Return from a procedure via the call stack.

68 [ReturnGet](#returnget) - Get a word from the return area and save it.

69 [ReturnPut](#returnput) - Put a word into the return area.

70 [ShiftDown](#shiftdown) - Shift an element down one in an area.

71 [ShiftLeft](#shiftleft) - Shift left within an element.

72 [ShiftRight](#shiftright) - Shift right with an element.

73 [ShiftUp](#shiftup) - Shift an element up one in an area.

74 [Start](#start) - Start the current assembly using the specified version of the Zero language.

75 [Subtract](#subtract) - Subtract the second source operand value from the first source operand value and store the result in the target area.

76 [Tally](#tally) - Counts instructions when enabled.

77 [Then](#then) - Then block.

78 [Trace](#trace) - Start or stop tracing.

79 [TracePoint](#tracepoint) - Trace point - a point in the code where the flow of execution might change.

80 [TracePoints](#tracepoints) - Enable or disable trace points.

81 [Var](#var) - Create a variable initialized to the specified value.

82 [Watch](#watch) - Watches for changes to the specified memory location.

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
