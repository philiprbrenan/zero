//-----------------------------------------------------------------------------
// Fpga test
// Philip R Brenan at appaapps dot com, Appa Apps Ltd Inc., 2023
//------------------------------------------------------------------------------
module fpga                                                                     // Run test programs
 (input  wire run,                                                              // Run - clock at lest once to allow code to be loaded
  output reg  finished,                                                         // Goes high when the program has finished
  output reg  success);                                                         // Goes high on finish if all the tests passed

  parameter integer MemoryElementWidth =  12;                                   // Memory element width

  parameter integer NArea   =        3;                                         // Size of each area on the heap
  parameter integer NArrays =        1;                                         // Maximum number of arrays
  parameter integer NHeap   =        3;                                         // Amount of heap memory
  parameter integer NLocal  =        3;                                         // Size of local memory
  parameter integer NOut    =        5;                                         // Size of output area
  parameter integer NIn     =        0;                                         // Size of input area
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
    if (0) begin                                                  // Clear memory
      for(i = 0; i < NHeap;   ++i) begin    heapMem[i] = 0; end
      for(i = 0; i < NLocal;  ++i) begin   localMem[i] = 0; end
      for(i = 0; i < NArrays; ++i) begin arraySizes[i] = 0; end
    end
  end

  always @(clock) begin                                                         // Each instruction
    steps = steps + 1;
    case(ip)

          0 :
      begin                                                                     // array
if (0) begin
  $display("AAAA %4d %4d array", steps, ip);
end
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0]] = 0;
              ip = 1;
      end

          1 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[1] = 2;
              updateArrayLength(2, 0, 0);
              ip = 2;
      end

          2 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[0]*3 + 0] = 1;
              updateArrayLength(1, localMem[0], 0);
              ip = 3;
      end

          3 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[0]*3 + 1] = 2;
              updateArrayLength(1, localMem[0], 1);
              ip = 4;
      end

          4 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              heapMem[localMem[0]*3 + 2] = 3;
              updateArrayLength(1, localMem[0], 2);
              ip = 5;
      end

          5 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 6;
      end

          6 :
      begin                                                                     // mov
if (0) begin
  $display("AAAA %4d %4d mov", steps, ip);
end
              localMem[2] = 0;
              updateArrayLength(2, 0, 0);
              ip = 7;
      end

          7 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 8;
      end

          8 :
      begin                                                                     // jGe
if (0) begin
  $display("AAAA %4d %4d jGe", steps, ip);
end
              ip = localMem[2] >= 3 ? 15 : 9;
      end

          9 :
      begin                                                                     // out
if (0) begin
  $display("AAAA %4d %4d out", steps, ip);
end
              outMem[outMemPos] = 1;
              outMemPos = (outMemPos + 1) % NOut;
              ip = 10;
      end

         10 :
      begin                                                                     // jEq
if (0) begin
  $display("AAAA %4d %4d jEq", steps, ip);
end
              ip = heapMem[localMem[0]*3 + localMem[2]] == 2 ? 12 : 11;
      end

         11 :
      begin                                                                     // out
if (0) begin
  $display("AAAA %4d %4d out", steps, ip);
end
              outMem[outMemPos] = 2;
              outMemPos = (outMemPos + 1) % NOut;
              ip = 12;
      end

         12 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 13;
      end

         13 :
      begin                                                                     // add
if (0) begin
  $display("AAAA %4d %4d add", steps, ip);
end
              localMem[2] = localMem[2] + 1;
              updateArrayLength(2, 0, 0);
              ip = 14;
      end

         14 :
      begin                                                                     // jmp
if (0) begin
  $display("AAAA %4d %4d jmp", steps, ip);
end
              ip = 7;
      end

         15 :
      begin                                                                     // label
if (0) begin
  $display("AAAA %4d %4d label", steps, ip);
end
              ip = 16;
      end
      default: begin
        success  = 1;
        success  = success && outMem[0] == 1;
        success  = success && outMem[1] == 2;
        success  = success && outMem[2] == 1;
        success  = success && outMem[3] == 1;
        success  = success && outMem[4] == 2;
        finished = 1;
      end
    endcase
    if (steps <=     34) clock <= ~ clock;                                      // Must be non sequential to fire the next iteration
    if (0) begin
      for(i = 0; i < 200; ++i) $write("%2d",   localMem[i]); $display("");
      for(i = 0; i < 200; ++i) $write("%2d",    heapMem[i]); $display("");
      for(i = 0; i < 200; ++i) $write("%2d", arraySizes[i]); $display("");
    end
  end
endmodule
