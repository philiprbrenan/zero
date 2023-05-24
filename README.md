# [Zero assembler programming language](https://github.com/philiprbrenan/zero) 
![Test](https://github.com/philiprbrenan/zero/workflows/Test/badge.svg)

A minimal [assembler](https://en.wikipedia.org/wiki/Assembly_language#Assembler) and [emulator](https://en.wikipedia.org/wiki/Emulator) for the [Zero assembler programming language](https://github.com/philiprbrenan/zero) &#9410;.

Open the __Actions__ [tab](https://en.wikipedia.org/wiki/Tab_key) to see the [code](https://en.wikipedia.org/wiki/Computer_program) in action on [Ubuntu](https://ubuntu.com/download/desktop) and [Windows Services for Linux](https://en.wikipedia.org/wiki/Windows_Subsystem_for_Linux) for [Ubuntu](https://ubuntu.com/download/desktop) on windows.

## Installation

Install [Zero assembler programming language](https://github.com/philiprbrenan/zero) by downloading this repo and then following the [steps](http://docs.oasis-open.org/dita/dita/v1.3/errata02/os/complete/part3-all-inclusive/contentmodels/cmlts.html#cmlts__steps) shown in this
[validating action](https://github.com/philiprbrenan/zero/blob/main/.github/workflows/main.yml)

## Application

Includes an implementation of N-Way [trees](https://en.wikipedia.org/wiki/Tree_(data_structure)) using [code](https://en.wikipedia.org/wiki/Computer_program) written in the [Zero assembler programming language](https://github.com/philiprbrenan/zero): assiduously optimized through exhaustive testing, ready for realization in [Silicon](https://en.wikipedia.org/wiki/Silicon) as an [integrated circuit](https://en.wikipedia.org/wiki/Integrated_circuit) rather than as software on a conventional [CPU](https://en.wikipedia.org/wiki/Central_processing_unit) so that large,
extremely fast, associative memories can be manufactured on an industrial
scale.

The initial idea is to produce a small CPU which implements just the
instructions needed to implement the algorithm.  The small CPU will then be
replicated across an [fpga](https://en.wikipedia.org/wiki/Field-programmable_gate_array) so that the [tree](https://en.wikipedia.org/wiki/Tree_(data_structure)) can be queried in parallel.

Only one [tree](https://en.wikipedia.org/wiki/Tree_(data_structure)) will be used: typically mapping 64 [bit](https://en.wikipedia.org/wiki/Bit) keys into 64 [bit](https://en.wikipedia.org/wiki/Bit) data. It
will be useful to add additional data at the front of the keys such as data
length, data position, [process](https://en.wikipedia.org/wiki/Process_management_(computing)) id, [userid](https://en.wikipedia.org/wiki/User_identifier), time stamp etc. As the keys are
sorted in the [tree](https://en.wikipedia.org/wiki/Tree_(data_structure)), [trees](https://en.wikipedia.org/wiki/Tree_(data_structure)) with similar prefixes will tend to collect together
so we can compress out the common prefix of the keys in each node to make
better use of [memory](https://en.wikipedia.org/wiki/Computer_memory). 
Strings longer than 64 bits can be processed in pieces with each piece prefixed
by the [string](https://en.wikipedia.org/wiki/String_(computer_science)) id and the position in the [string](https://en.wikipedia.org/wiki/String_(computer_science)).  Incoming [strings](https://en.wikipedia.org/wiki/String_(computer_science)) can be made
unique by assigning a unique 64 [bit](https://en.wikipedia.org/wiki/Bit) number to each prefix of the [string](https://en.wikipedia.org/wiki/String_(computer_science)) so that
a second such [string](https://en.wikipedia.org/wiki/String_(computer_science)) can be easily recognized.  Once such a long [string](https://en.wikipedia.org/wiki/String_(computer_science)) has
been represented by a unique number it can be located in one descent through
the [tree](https://en.wikipedia.org/wiki/Tree_(data_structure)); although a single traversal of the [tree](https://en.wikipedia.org/wiki/Tree_(data_structure)) will no longer yield such [strings](https://en.wikipedia.org/wiki/String_(computer_science)) in alphabetic order.

All communications with the chip will be done via [TcpIp](https://en.wikipedia.org/wiki/Internet_protocol_suite) .  Incoming read requests
can be done in parallel as long as there are processors left to assign work to.
An update will have to wait for all existing finds to finish while stalling all
trailing actions until the update is complete.

Associative lookups are the [sine qua non](https://en.wikipedia.org/wiki/Sine_qua_non) of all [Turing](https://en.wikipedia.org/wiki/Alan_Turing) complete programming languages.
This arrangement should produce very fast associative lookups - much faster
than can be performed by any generic system reliant on external software. Usage
of power and [integrated circuit](https://en.wikipedia.org/wiki/Integrated_circuit) surface area should be reduced by having a minimal CPU to
perform the lookups. Being able to deliver such lookups faster than can be
done with conventional software solutions might prove profitable in much the
same way as graphics chips and other chips used at scale.

Memory is addressed via named areas which act as flexible [arrays](https://en.wikipedia.org/wiki/Dynamic_array) with the usual
indexing, push, pop, index, iteration, resizing and scan operations.  Each
procedure has its own stack frame implemented as a stack frame area, parameter
area and return results area. Each area can grow as much as is needed to hold
data.  Additional [user](https://en.wikipedia.org/wiki/User_(computing)) [memory](https://en.wikipedia.org/wiki/Computer_memory) areas can be allocated and freed as necessary.
Communication with other systems can be achieved by reading and writing to [arrays](https://en.wikipedia.org/wiki/Dynamic_array) with predetermined names.

References can represent constants via a scalar with zero levels of
dereferencing; direct addresses by scalars with one level of dereferencing, and
indirect addresses by scalars with two levels of dereferencing.  A reference
consisting of an area, an offset within an area and an area name are
represented as an [array](https://en.wikipedia.org/wiki/Dynamic_array) reference with three entries. A reference to a location
in the current stack frame is represented as a single scalar with the
appropriate levels of dereferencing.  The area name is used to confirm that the
area being processed is the one that should be being processed.

If you would like to be involved with this interesting and potentially
lucrative project, please raise an issue saying so!

## Emulator:

The [emulator](https://en.wikipedia.org/wiki/Emulator) converts a [Perl](http://www.perl.org/) representation of the [assembly](https://en.wikipedia.org/wiki/Assembly_language) source [code](https://en.wikipedia.org/wiki/Computer_program) to
executable instructions and then executes these instructions.

[Documentation](https://metacpan.org/dist/Zero-Emulator/view/Emulator.pod)
[Code](https://github.com/philiprbrenan/zero/blob/main/lib/Zero/Emulator.pm)

## Addresses

Each [assembler](https://en.wikipedia.org/wiki/Assembly_language#Assembler) instruction can potentially affect a target [memory](https://en.wikipedia.org/wiki/Computer_memory) location
specified by the target operand known as the **left hand** address.  Each [assembler](https://en.wikipedia.org/wiki/Assembly_language#Assembler) instruction can potentially read zero, one or two source operands to
locate the data to be processed by the instruction.

Each address indexes an [array](https://en.wikipedia.org/wiki/Dynamic_array) in [memory](https://en.wikipedia.org/wiki/Computer_memory). Each [array](https://en.wikipedia.org/wiki/Dynamic_array) has a non unique name to
confirm that we are reading or writing to the right kind of [memory](https://en.wikipedia.org/wiki/Computer_memory). 

### Left hand addresses

#### Left hand address in current stack frame

```
  Mov \1, 2

```

The above instruction moves the constant ```2``` to the location in the current
stack frame identified by location ```1``` in the current stack frame.

#### Left hand addresses as indexed [arrays](https://en.wikipedia.org/wiki/Dynamic_array) 
```
  [Array, address, name, delta]

  Mov [1, 2, 'array name'], 99

```

A **left hand** address can specify the address of a location in an [array](https://en.wikipedia.org/wiki/Dynamic_array) in [memory](https://en.wikipedia.org/wiki/Computer_memory). Left hand addresses always occur first in the written specification of
an instruction.  In the example above, the value ```99``` is being moved to
location ```2``` in [array](https://en.wikipedia.org/wiki/Dynamic_array) ```1``` operating under the name of 'array name'.

If the [array](https://en.wikipedia.org/wiki/Dynamic_array) number is preceded by ```\``` as in ```\1``` then the number of
the [array](https://en.wikipedia.org/wiki/Dynamic_array) will be retrieved from location ```1``` the current stack frame. This
mechanism allows for indirect addressing of [array](https://en.wikipedia.org/wiki/Dynamic_array) names.

Likewise the index of the location in the [array](https://en.wikipedia.org/wiki/Dynamic_array) can either be specified as a
direct number as in ```2``` or indirectly as ```\2```.

The name of the [array](https://en.wikipedia.org/wiki/Dynamic_array) is used to check that we are accessing the expected type
of [array](https://en.wikipedia.org/wiki/Dynamic_array).  If the name does not match the expected name for the [array](https://en.wikipedia.org/wiki/Dynamic_array) being
accessed an error message will be written to the out channel and the execution
of the [program](https://en.wikipedia.org/wiki/Computer_program) will be terminated.

An address can also be specified as just as ```n``` meaning at location ```n```
in the current stack frame, or ```\n``` indicating an indirect location in the
current stack frame.

Scalars on the left hand side are assumed to be addresses not constants because
we cannot assign to a constant. The target address of an instruction is always
a left hand address and is thus never treated as a constant.

### Right hand addresses

#### Right hand addresses as constants

```
  [Array, address, name]

  Mov 3, 99

```

The example above moves the **right hand** constant ```99``` to the location
```3``` in the current stack frame.

Right hand addresses can normally be scalars if a constant is required except
in the case of the **MoveLong** instruction which requires that both its target
operand and its first source operand represent addresses.

#### Right hand addresses as variables

```
  Mov 3, \4
```

The example above moves the contents of location ```4``` in the current stack
frame to location ```3``` in the current stack frame.

#### Right hand addresses as indexed [arrays](https://en.wikipedia.org/wiki/Dynamic_array) 
```
  [Array, address, name]

  my $a = Array "keys";
  Mov [$a, 3, 'keys'], \4

```

The example above moves the contents of location ```4``` in the current stack
frame to location ```3``` in the [array](https://en.wikipedia.org/wiki/Dynamic_array) whose identifying number is located at
location **$a** in the current stack frame.  The [array](https://en.wikipedia.org/wiki/Dynamic_array) is created with an
identifying name of **keys**.  The [string](https://en.wikipedia.org/wiki/String_(computer_science)) **keys** must be presented on each
subsequent access to this [array](https://en.wikipedia.org/wiki/Dynamic_array) to confirm that the correct type of [memory](https://en.wikipedia.org/wiki/Computer_memory) is
being accessed.

## Instructions

[The instruction set](https://metacpan.org/dist/Zero-Emulator/view/Emulator.pod)

## Macro Preprocessor

Every [assembler](https://en.wikipedia.org/wiki/Assembly_language#Assembler) needs a macro [preprocessor](https://en.wikipedia.org/wiki/Preprocessor) to generate [code](https://en.wikipedia.org/wiki/Computer_program) from macro
specifications as writing each instruction by hand is hard work. Using a [preprocessor](https://en.wikipedia.org/wiki/Preprocessor) saves programmer time by allowing common instruction sequences to
be captured as macros which can then be called upon as needed to generate the [code](https://en.wikipedia.org/wiki/Computer_program) for an application. The [Zero assembler programming language](https://github.com/philiprbrenan/zero) uses [Perl](http://www.perl.org/) as its macro [preprocessor](https://en.wikipedia.org/wiki/Preprocessor). Using [Perl](http://www.perl.org/) as the macro [preprocessor](https://en.wikipedia.org/wiki/Preprocessor) for [Zero assembler programming language](https://github.com/philiprbrenan/zero) enables macro libraries to be
published and distributed on [CPAN](https://metacpan.org/author/PRBRENAN) as [Perl](http://www.perl.org/) modules.

## Machine [code](https://en.wikipedia.org/wiki/Computer_program) 
The [Zero assembler programming language](https://github.com/philiprbrenan/zero) [code](https://en.wikipedia.org/wiki/Computer_program) can be converted to a single [string](https://en.wikipedia.org/wiki/String_(computer_science)) using method:
**GenerateMachineCode**.  The [string](https://en.wikipedia.org/wiki/String_(computer_science)) of machine [code](https://en.wikipedia.org/wiki/Computer_program) can then be reloaded using
method: **disAssemble** to [parse](https://en.wikipedia.org/wiki/Parsing) the machine [code](https://en.wikipedia.org/wiki/Computer_program) [string](https://en.wikipedia.org/wiki/String_(computer_science)) back into [code](https://en.wikipedia.org/wiki/Computer_program) that
can be executed as usual via **Execute**.  Alternatively, the machine [code](https://en.wikipedia.org/wiki/Computer_program) [string](https://en.wikipedia.org/wiki/String_(computer_science)) can be used to [program](https://en.wikipedia.org/wiki/Computer_program) a [Silicon](https://en.wikipedia.org/wiki/Silicon) device such as an [fpga](https://en.wikipedia.org/wiki/Field-programmable_gate_array) to execute the [code](https://en.wikipedia.org/wiki/Computer_program) on a chip .

## Memory Schemes

Two [memory](https://en.wikipedia.org/wiki/Computer_memory) schemes are available for providing [memory](https://en.wikipedia.org/wiki/Computer_memory) to executing [Zero assembler programming language](https://github.com/philiprbrenan/zero) [programs](https://en.wikipedia.org/wiki/Computer_program). 
### Segmented [memory](https://en.wikipedia.org/wiki/Computer_memory) scheme

This is the default [memory](https://en.wikipedia.org/wiki/Computer_memory) scheme. The segmented [memory](https://en.wikipedia.org/wiki/Computer_memory) scheme places each [array](https://en.wikipedia.org/wiki/Dynamic_array) in a separate [Perl](http://www.perl.org/) [array](https://en.wikipedia.org/wiki/Dynamic_array).  The current stack frame, parameter [list](https://en.wikipedia.org/wiki/Linked_list) and
return results are all held in such [arrays](https://en.wikipedia.org/wiki/Dynamic_array). Each such [array](https://en.wikipedia.org/wiki/Dynamic_array) is dynamically
extensible to any reasonable size.

A possible downside of this [memory](https://en.wikipedia.org/wiki/Computer_memory) scheme is that the use of different sized [arrays](https://en.wikipedia.org/wiki/Dynamic_array) might eventually fragment the underlying [memory](https://en.wikipedia.org/wiki/Computer_memory). 

### String [memory](https://en.wikipedia.org/wiki/Computer_memory) scheme

Alternatively, in the [string](https://en.wikipedia.org/wiki/String_(computer_science)) [memory](https://en.wikipedia.org/wiki/Computer_memory) scheme, [arrays](https://en.wikipedia.org/wiki/Dynamic_array) are held as a [string](https://en.wikipedia.org/wiki/String_(computer_science)) concatenated together in fixed size blocks.  This imposes the limitation that
each [array](https://en.wikipedia.org/wiki/Dynamic_array) can only extend up to a predetermined size. The number of such [arrays](https://en.wikipedia.org/wiki/Dynamic_array) is determined by the total size of the available [memory](https://en.wikipedia.org/wiki/Computer_memory). 
The advantage of the [string](https://en.wikipedia.org/wiki/String_(computer_science)) [memory](https://en.wikipedia.org/wiki/Computer_memory) scheme is that the allocation and freeing of
such [arrays](https://en.wikipedia.org/wiki/Dynamic_array) is very simple because freed [arrays](https://en.wikipedia.org/wiki/Dynamic_array) can be immediately reused.
Allocation and freeing is thus a fast operation. Thus [memory](https://en.wikipedia.org/wiki/Computer_memory) can be recycled
indefinitely which is very convenient for [fpga](https://en.wikipedia.org/wiki/Field-programmable_gate_array) implementations.  The [string](https://en.wikipedia.org/wiki/String_(computer_science)) [memory](https://en.wikipedia.org/wiki/Computer_memory) scheme is useful in the case of N-Way [trees](https://en.wikipedia.org/wiki/Tree_(data_structure)) where each node in the [tree](https://en.wikipedia.org/wiki/Tree_(data_structure)) only extends to a small fixed size.


## Input and Output channels

There are two channels: **in** for input, **out** for output.

### Input

The input channel is supplied preloaded to the [emulator](https://en.wikipedia.org/wiki/Emulator). The input channel
**in** can be read using the **In** and  **ForIn** instructions.  The numnber
of items remaining in the input channel can be discoevered using the **InSize**
instruction.

### Output

The output channel **out** is written to by the **Out** instruction.  The
results of such writes can be seen on the terminal command line, in the trace
output and in the **out** field of the [emulator](https://en.wikipedia.org/wiki/Emulator) execution environment data
structure.

## Parallelism

Parallelism typically obtains increased performance through increased power
consumption. Programmers typically think of trading performance for [memory](https://en.wikipedia.org/wiki/Computer_memory): the
time space dilemma.  But in designing for [Silicon](https://en.wikipedia.org/wiki/Silicon) we must also consider power
to get a trilemma of: time, space and power that has to be resolved to produce
the optimal solution.

### Code level parallelism

The **Parallel** instruction enables parallel [sub](https://perldoc.perl.org/perlsub.html) sections to be run,
figuratively, in parallel.

```
  Parallel
    sub{Mov [$a, 0, 'array'], 0},
    sub{Mov [$a, 1, 'array'], 1},
    sub{Mov [$a, 2, 'array'], 2};
```

In reality all that happens is that the [emulator](https://en.wikipedia.org/wiki/Emulator) chooses a random order to run
reach parallel section in and then records the time taken by the longest
section as the time for the entire block. This technique allows us to confirm
that the specified sections can be run in any order and thus can also be run in
parallel on a target [fpga](https://en.wikipedia.org/wiki/Field-programmable_gate_array) .  The difference between the figurative parallel
time and sequential time in [code](https://en.wikipedia.org/wiki/Computer_program) execution can be seen in the following fields
maintained by the [emulator](https://en.wikipedia.org/wiki/Emulator): 
```
  is_deeply $e->timeParallel,   184;
  is_deeply $e->timeSequential, 244;
```

### Instruction level parallelism

Each instruction can contain up to 3 addresses: two source operands and one
target operand. Each address contains two components which can access [memory](https://en.wikipedia.org/wiki/Computer_memory) either directly or indirectly. This gives a maximum of ```2**2**3 = 64```
possible addressing configurations for each instruction.  In reality, most
applications will only use a small number of these possible configurations.  To
assist in choosing the most useful combinations  to implement in the [Silicon](https://en.wikipedia.org/wiki/Silicon) realization of an application, the [emulator](https://en.wikipedia.org/wiki/Emulator) tracks the number of times each
variant of each instruction is executed.

## Examples

Examples of [Zero assembler programming language](https://github.com/philiprbrenan/zero) [programs](https://en.wikipedia.org/wiki/Computer_program): 
### Hello World

"Hello World" in the [Zero assembler programming language](https://github.com/philiprbrenan/zero): 
```
  Start 1;

  Out "Hello World";

  my $e = Execute(suppressOutput=>1);

  is_deeply $e->out, <<END;
Hello World
END
```

#### Explanation

```Start``` starts a [program](https://en.wikipedia.org/wiki/Computer_program) using a specified version of the language.

```Out``` writes a message to the ```out``` channel.

```Execute``` causes the [program](https://en.wikipedia.org/wiki/Computer_program) to be assembled and then executed.  The
execution results are stored in the [Perl](http://www.perl.org/) data structure returned by this
instruction.

### N-Way-Tree

An implementation of N-Way-Trees in [Zero assembler programming language](https://github.com/philiprbrenan/zero) .

[Documentation](https://metacpan.org/dist/Zero-Emulator/view/NWayTree.pod)
[Code](https://github.com/philiprbrenan/zero/blob/main/lib/Zero/NWayTree.pm)

Can you reduce the number of instructions required to perform ```107``` inserts
into an N-Way-Tree using the instruction set provided? Please raise an issue if
so stating the licence for your enhancement.

```
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
  mov               => 7619,
  moveLong          => 171,
  not               => 631,
  resize            => 161,
  shiftUp           => 300,
  subtract          => 501,
```

### Sort [programs](https://en.wikipedia.org/wiki/Computer_program) 
[The examples folder](https://github.com/philiprbrenan/zero/tree/main/examples)
contains some [sort](https://en.wikipedia.org/wiki/Sorting) [programs](https://en.wikipedia.org/wiki/Computer_program) written in [Zero assembler programming language](https://github.com/philiprbrenan/zero) . The total number of instructions
executed for each [sort](https://en.wikipedia.org/wiki/Sorting) [program](https://en.wikipedia.org/wiki/Computer_program) on each of two sample sets of data are shown
below. Various prototype solutions were developed for each [sort](https://en.wikipedia.org/wiki/Sorting) [program](https://en.wikipedia.org/wiki/Computer_program): the
one with the lowest emulated instruction count was retained as the optimal
solution.

<table border="0" cellpadding="10">
<tr><th><th colspan=2>Sequential<th colspan=2>Parallel
<tr><th>Method<th>Short<th>Long<th>Short<th>Long
<tr><td><a href="https://github.com/philiprbrenan/zero/blob/main/examples/bubbleSort.pl"   >bubble   </a>  <td align=right>  244 <td align=right>   4753 <td align=right>184  <td align=right>3233
<tr><td><a href="https://github.com/philiprbrenan/zero/blob/main/examples/insertionSort.pl">insertion</a>  <td align=right>  188 <td align=right>   3787 <td align=right>188  <td align=right>3787
<tr><td><a href="https://github.com/philiprbrenan/zero/blob/main/examples/quickSort.pl"    >quickSort</a>  <td align=right>  284 <td align=right>   1433 <td align=right>278  <td align=right>1289
<tr><td><a href="https://github.com/philiprbrenan/zero/blob/main/examples/selectionSort.pl">selection</a>  <td align=right>  285 <td align=right>   4356 <td align=right>270  <td align=right>3860
</table>

#### Bubblesort
 [Bubble Sort](https://en.wikipedia.org/wiki/Bubble_sort) is easy to optimize by overlapping instruction execution across
three channels. Doing so gives it the best performance of the **O(n^2)** [sort](https://en.wikipedia.org/wiki/Sorting) algorithms implemented in [Zero assembler programming language](https://github.com/philiprbrenan/zero) so far. Of course, with unlimited parallelism,
bubble [sort](https://en.wikipedia.org/wiki/Sorting) can [sort](https://en.wikipedia.org/wiki/Sorting) an [array](https://en.wikipedia.org/wiki/Dynamic_array) in **O(N)** time: just let each of **N** [processes](https://en.wikipedia.org/wiki/Process_management_(computing)) perform one pass each on the [array](https://en.wikipedia.org/wiki/Dynamic_array) of length **N** to be sorted.

# Optimization space

In producing [code](https://en.wikipedia.org/wiki/Computer_program) or an [fpga](https://en.wikipedia.org/wiki/Field-programmable_gate_array) we might want to optimize use of the following
resources:

<table border="0" cellpadding="10">

<tr><th>Time<td>The amount of elapsed time it takes to execute the code as this
bears upon the utility of the solution.

<tr><th>Code Space<td>The amount of code required to implement the solution.
The more code required, the more memory, and thus Silicon, is required to store
the code.

<tr><th>Heap Space<td>The amount of memory required to store the data used by
the code.

<tr><th>Energy<td>The amount of energy required to execute the code .
Parallelism can speed up code execution often at the cost of increased power
consumption. This does not necessarily translate into greater energy
consumption for one execution, but, faster executions lead to more frequent
executions, which means more energy per unit time, in essence, higher power
levels.

</table>
