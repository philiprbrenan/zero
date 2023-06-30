//-----------------------------------------------------------------------------
// Fpga test
// Philip R Brenan at appaapps dot com, Appa Apps Ltd Inc., 2023
//------------------------------------------------------------------------------
module fpga                                                                     // Run test programs
 (input  wire run,                                                              // Run - clock at lest once to allow code to be loaded
  output reg  finished,                                                         // Goes high when the program has finished
  output reg  success);                                                         // Goes high on finish if all the tests passed

  parameter integer MemoryElementWidth =  12;                                   // Memory element width

  parameter integer NArea          = 10;                                    // Size of each area on the heap
  parameter integer NArrays        =  2000;                                      // Maximum number of arrays
  parameter integer NHeap          = 10000;                                      // Amount of heap memory
  parameter integer NLocal         = 10000;                                      // Size of local memory
  parameter integer NOut           =  2000;                                      // Size of output area
  parameter integer NIn            =     3;                                       // Size of input area
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
  reg     clock;                                                                // Clock - has to be one bit wide for yosys
  integer steps;                                                                // Number of steps executed so far
  integer i, j, k;                                                              // A useful counter

  task updateArrayLength(input integer arena, input integer array, input integer index); // Update array length if we are updating an array
    begin
      if (arena == 1 && arraySizes[array] < index + 1) arraySizes[array] = index + 1;
    end
  endtask

  always @(posedge run) begin                                                   // Initialize
    ip             = 0;
    clock          = 0;
    steps          = 0;
    finished       = 0;
    success        = 0;
    inMemPos       = 0;
    outMemPos      = 0;
    allocs         = 0;
    freedArraysTop = 0;
    for(i = 0; i < NHeap;   ++i)    heapMem[i] = 0;
    for(i = 0; i < NLocal;  ++i)   localMem[i] = 0;
    for(i = 0; i < NArrays; ++i) arraySizes[i] = 0;
    inMem[0] = 33;
    inMem[1] = 22;
    inMem[2] = 11;
  end

  always @(clock) begin                                                         // Each instruction
    steps = steps + 1;
    case(ip)

          0 :
      begin                                                                     // out
if (0) begin
  $display("AAAA %4d %4d out", steps, ip);
end
              outMem[outMemPos] = 1;
              outMemPos = (outMemPos + 1) % NOut;
              ip = 1;
      end

          1 :
      begin                                                                     // out
if (0) begin
  $display("AAAA %4d %4d out", steps, ip);
end
              outMem[outMemPos] = 2;
              outMemPos = (outMemPos + 1) % NOut;
              ip = 2;
      end

          2 :
      begin                                                                     // out
if (0) begin
  $display("AAAA %4d %4d out", steps, ip);
end
              outMem[outMemPos] = 3;
              outMemPos = (outMemPos + 1) % NOut;
              ip = 3;
      end

          3 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 4;
      end

          4 :
      begin                                                                     // inSize
if (0) begin
  $display("AAAA %4d %4d inSize", steps, ip);
end
              localMem[0] = NIn - inMemPos;
              ip = 5;
      end

          5 :
      begin                                                                     // jFalse
if (0) begin
  $display("AAAA %4d %4d jFalse", steps, ip);
end
              ip = localMem[0] == 0 ? 11 : 6;
      end

          6 :
      begin                                                                     // in
if (0) begin
  $display("AAAA %4d %4d in", steps, ip);
end
              if (inMemPos < NIn) begin
                localMem[1] = inMem[inMemPos];
                inMemPos = inMemPos + 1;
              end
              ip = 7;
      end

          7 :
      begin                                                                     // out
if (0) begin
  $display("AAAA %4d %4d out", steps, ip);
end
              outMem[outMemPos] = localMem[0];
              outMemPos = (outMemPos + 1) % NOut;
              ip = 8;
      end

          8 :
      begin                                                                     // out
if (0) begin
  $display("AAAA %4d %4d out", steps, ip);
end
              outMem[outMemPos] = localMem[1];
              outMemPos = (outMemPos + 1) % NOut;
              ip = 9;
      end

          9 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 10;
      end

         10 :
      begin                                                                     // jmp
if (0) begin
  $display("AAAA %4d %4d jmp", steps, ip);
end
              ip = 3;
      end

         11 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 12;
      end
      default: begin
        success  = 1;
        success  = success && outMem[0] == 1;
        success  = success && outMem[1] == 2;
        success  = success && outMem[2] == 3;
        success  = success && outMem[3] == 3;
        success  = success && outMem[4] == 33;
        success  = success && outMem[5] == 2;
        success  = success && outMem[6] == 22;
        success  = success && outMem[7] == 1;
        success  = success && outMem[8] == 11;
        finished = 1;
      end
    endcase
    if (steps <=     32) clock <= ~ clock;                                      // Must be non sequential to fire the next iteration
    if (1 || 0) begin
      for(i = 0; i < 200; ++i) $write("%2d",   localMem[i]); $display("");
      for(i = 0; i < 200; ++i) $write("%2d",    heapMem[i]); $display("");
      for(i = 0; i < 200; ++i) $write("%2d", arraySizes[i]); $display("");
    end
  end
endmodule
