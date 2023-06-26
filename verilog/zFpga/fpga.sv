//-----------------------------------------------------------------------------
// Fpga test
// Philip R Brenan at appaapps dot com, Appa Apps Ltd Inc., 2023
//------------------------------------------------------------------------------
module fpga                                                                     // Run test programs
 (input  wire run,                                                              // Run - clock at lest once to allow code to be loaded
  output reg  finished,                                                         // Goes high when the program has finished
  output reg  success);                                                         // Goes high on finish if all the tests passed
  parameter integer MemoryElementWidth =  12;                                   // Memory element width
  parameter integer NArea          =   2;                                       // Size of each area on the heap
  parameter integer NArrays        =   2;                                       // Maximum number of arrays
  parameter integer NHeap          =   2;                                       // Amount of heap memory
  parameter integer NLocal         =   2;                                       // Size of local memory
  parameter integer NIn            =   2;                                       // Size of input area
  parameter integer NOut           =   2;                                       // Size of output area
  parameter integer NFreedArrays   =   2;                                       // Size of output area
  reg signed [MemoryElementWidth-1:0]   arraySizes[NArrays-1      :0];          // Size of each array
  reg signed [MemoryElementWidth-1:0]      heapMem[NHeap-1        :0];          // Heap memory
  reg signed [MemoryElementWidth-1:0]     localMem[NLocal-1       :0];          // Local memory
  reg signed [MemoryElementWidth-1:0]       outMem[NOut-1         :0];          // Out channel
  reg signed [MemoryElementWidth-1:0]        inMem[NIn-1          :0];          // In channel
  reg signed [MemoryElementWidth-1:0]  freedArrays[NFreedArrays-1 :0];          // Freed arrays list implemented as a stack
  reg signed [MemoryElementWidth-1:0]   arrayShift[NArea-1        :0];          // Array shift area
  integer signed         inMemPos;                                              // Current position in input channel
  integer signed         inMemEnd;                                              // End of input channel, this is the next element that would have been added.
  integer signed        outMemPos;                                              // Position in output channel
  integer signed           allocs;                                              // Maximum number of array allocations in use at any one time
  integer signed   freedArraysTop;                                              // Position in freed arrays stack
  integer signed i, j, k, l, p, q;                                              // Useful integers
  integer ip = 0;                                                               // Instruction pointer
  always @(posedge run) begin
    ip             <= 0;
    finished       <= 0;
    success        <= 0;
    inMemPos       <= 0;
    inMemEnd       <= 0;
    outMemPos      <= 0;
    allocs         <= 0;
    freedArraysTop <= 0;
  end
  always @(posedge ip or negedge ip) begin
    case(ip)
          0 : // out
      begin
              outMem[outMemPos] = 1;
              outMemPos = (outMemPos + 1) % NOut;
              ip = 0;
      end
          1 : // out
      begin
              outMem[outMemPos] = 2;
              outMemPos = (outMemPos + 1) % NOut;
              ip = 1;
      end
          2 : // out
      begin
              outMem[outMemPos] = 3;
              outMemPos = (outMemPos + 1) % NOut;
              ip = 2;
      end
          3 : // label
      begin
      end
          4 : // inSize
      begin
              if (inMemEnd > inMemPos) localMem[0 + 0] =       inMemEnd - inMemPos;
              else                     localMem[0 + 0] = NIn + inMemEnd - inMemPos;
              ip = 5;
      end
          5 : // jFalse
      begin
              ip = localMem[0+0] == 0 ? 11 : 6;
      end
          6 : // in
      begin
        if (inMemPos != inMemEnd) begin
          localMem[0 + 1]  = inMem[inMemPos];
          inMemPos = (inMemPos + 1) % NIn;
        end
        ip = 7;
      end
          7 : // out
      begin
              outMem[outMemPos] = localMem[0+0];
              outMemPos = (outMemPos + 1) % NOut;
              ip = 7;
      end
          8 : // out
      begin
              outMem[outMemPos] = localMem[0+1];
              outMemPos = (outMemPos + 1) % NOut;
              ip = 8;
      end
          9 : // label
      begin
      end
         10 : // jmp
      begin
              ip = 3;
      end
         11 : // label
      begin
      end
    endcase
  end
endmodule
