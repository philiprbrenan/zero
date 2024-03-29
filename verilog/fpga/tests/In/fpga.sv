//-----------------------------------------------------------------------------
// Fpga test
// Philip R Brenan at appaapps dot com, Appa Apps Ltd Inc., 2023
//------------------------------------------------------------------------------
module fpga                                                                     // Run test programs
 (input  wire clock,                                                            // Driving clock
  input  wire reset,                                                            // Restart program
  output reg  finished,                                                         // Goes high when the program has finished
  output reg  success);                                                         // Goes high on finish if all the tests passed

  parameter integer MemoryElementWidth =  12;                                   // Memory element width

  parameter integer NArea   =        1;                                         // Size of each area on the heap
  parameter integer NArrays =        0;                                         // Maximum number of arrays
  parameter integer NHeap   =        0;                                         // Amount of heap memory
  parameter integer NLocal  =        2;                                         // Size of local memory
  parameter integer NOut    =        6;                                         // Size of output area
  parameter integer NIn     =        3;                                         // Size of input area
  reg [MemoryElementWidth-1:0]   arraySizes[NArrays-1:0];                       // Size of each array
  reg [MemoryElementWidth-1:0]      heapMem[NHeap-1  :0];                       // Heap memory
  reg [MemoryElementWidth-1:0]     localMem[NLocal-1 :0];                       // Local memory
  reg [MemoryElementWidth-1:0]       outMem[NOut-1   :0];                       // Out channel
  reg [MemoryElementWidth-1:0]        inMem[NIn-1    :0];                       // In channel
  reg [MemoryElementWidth-1:0]  freedArrays[NArrays-1:0];                       // Freed arrays list implemented as a stack
  reg [MemoryElementWidth-1:0]   arrayShift[NArea-1  :0];                       // Array shift area

  integer inMemPos;                                                             // Current position in input channel
  integer outMemPos;                                                            // Position in output channel
  integer allocs;                                                               // Maximum number of array allocations in use at any one time
  integer freedArraysTop;                                                       // Position in freed arrays stack

  integer ip;                                                                   // Instruction pointer
  integer steps;                                                                // Number of steps executed so far
  integer i, j, k;                                                              // A useful counter

  task updateArrayLength(input integer arena, input integer array, input integer index); // Update array length if we are updating an array
    begin
      if (arena == 1 && arraySizes[array] < index + 1) arraySizes[array] = index + 1;
    end
  endtask

  always @(posedge clock) begin                                                 // Each instruction
    if (reset) begin
      ip             = 0;
      steps          = 0;
      inMemPos       = 0;
      outMemPos      = 0;
      allocs         = 0;
      freedArraysTop = 0;
      finished       = 0;
      success        = 0;

      inMem[0] = 33;
      inMem[1] = 22;
      inMem[2] = 11;
      if (0) begin                                                  // Clear memory
        for(i = 0; i < NHeap;   i = i + 1)    heapMem[i] = 0;
        for(i = 0; i < NLocal;  i = i + 1)   localMem[i] = 0;
        for(i = 0; i < NArrays; i = i + 1) arraySizes[i] = 0;
      end
    end
    else begin
      steps = steps + 1;
      case(ip)

          0 :
        begin                                                                   // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 1;
        end

          1 :
        begin                                                                   // inSize
if (0) begin
  $display("AAAA %4d %4d inSize", steps, ip);
end
              localMem[0] = NIn - inMemPos;
              ip = 2;
        end

          2 :
        begin                                                                   // jFalse
if (0) begin
  $display("AAAA %4d %4d jFalse", steps, ip);
end
              ip = localMem[0] == 0 ? 8 : 3;
        end

          3 :
        begin                                                                   // in
if (0) begin
  $display("AAAA %4d %4d in", steps, ip);
end
              if (inMemPos < NIn) begin
                localMem[1] = inMem[inMemPos];
                inMemPos = inMemPos + 1;
              end
              ip = 4;
        end

          4 :
        begin                                                                   // out
if (0) begin
  $display("AAAA %4d %4d out", steps, ip);
end
              outMem[outMemPos] = localMem[0];
              outMemPos = outMemPos + 1;
              ip = 5;
        end

          5 :
        begin                                                                   // out
if (0) begin
  $display("AAAA %4d %4d out", steps, ip);
end
              outMem[outMemPos] = localMem[1];
              outMemPos = outMemPos + 1;
              ip = 6;
        end

          6 :
        begin                                                                   // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 7;
        end

          7 :
        begin                                                                   // jmp
if (0) begin
  $display("AAAA %4d %4d jmp", steps, ip);
end
              ip = 0;
        end

          8 :
        begin                                                                   // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 9;
        end
      endcase
      if (0) begin
        for(i = 0; i < 200; i = i + 1) $write("%2d",   localMem[i]); $display("");
        for(i = 0; i < 200; i = i + 1) $write("%2d",    heapMem[i]); $display("");
        for(i = 0; i < 200; i = i + 1) $write("%2d", arraySizes[i]); $display("");
      end
      success  = 1;
      success  = success && outMem[0] == 3;
      success  = success && outMem[1] == 33;
      success  = success && outMem[2] == 2;
      success  = success && outMem[3] == 22;
      success  = success && outMem[4] == 1;
      success  = success && outMem[5] == 11;
      finished = steps >     29;
    end
  end

endmodule
