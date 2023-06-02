//-----------------------------------------------------------------------------
// Circular buffer - test implementation for use in fpga.sv
// Philip R Brenan at appaapps dot com, Appa Apps Ltd Inc., 2023
//------------------------------------------------------------------------------
module CircularBufferTB();                                                      // Circular buffer test bench
  reg clock;                                                                    // Clock which drives both input and output
  reg reset;                                                                    // Reset the buffer
  reg inEnable;                                                                 // Add input to buffer if there is room
  reg outEnable;                                                                // Remove from buffer if there is data
  reg[7:0] in;                                                                  // Input channel
  reg[7:0] inRemainder;                                                         // Remaining free space in buffer
  reg[7:0] out;                                                                 // Output channel
  reg[7:0] outRemainder;                                                        // Data available in buffer. This field plus inRemainder equals the size of the buffer

  parameter integer NBuffer        = 128;                                       // Size of circular buffer
  parameter integer NTestsExpected =  16;                                       // Number of test passes expected

  integer testsPassed;                                                          // Tests passed
  integer testsFailed;                                                          // Tests failed

  task ok(integer signed test, string name);                                    // Check a single test result
    begin
      if (test == 1) begin
        testsPassed++;
      end
      else begin
        $display("Assertion %s FAILED", name);
        testsFailed++;
      end
    end
  endtask

  CircularBuffer                                                                // Create a circular buffer
   c
   (.clock(clock),
    .reset(reset),
    .inEnable(inEnable),
    .outEnable(outEnable),
    .in(in),
    .inRemainder(inRemainder),
    .out(out),
    .outRemainder(outRemainder)
   );
  defparam c.NBuffer = NBuffer;                                                 // Change the default size of the circular buffer
  defparam c.NWidth  = 8;                                                       // Change the default size of the circular buffer

  initial begin                                                                 // Test the circular buffer
    testsPassed = 0; testsFailed = 0;
    #1 reset <= 1; #1 clock <= 1; #1 clock <= 0; #1 reset <= 0;                 // Initial reset
    //$display("AAAA inRemainder=%d,  outRemainder=%d", inRemainder, outRemainder);
    ok(inRemainder  === NBuffer,   "aaa");
    ok(outRemainder === 0,         "bbb");

    #1 in <= 99; inEnable <= 1; #1 clock <= 1; #1 clock <= 0; #1 inEnable <= 0; // Load 99
    ok(inRemainder  === NBuffer-1, "ccc");
    ok(outRemainder === 1,         "ddd");

    #1 in <= 88; inEnable <= 1; #1 clock <= 1; #1 clock <= 0; #1 inEnable <= 0; // Load 88
    ok(inRemainder  === NBuffer-2, "eee");
    ok(outRemainder === 2,         "fff");

    #1 outEnable <= 1; #1 clock <= 1; #1 clock <= 0; #1 outEnable <= 0;         // Read 99
    ok(out          === 99,        "ggg");
    ok(inRemainder  === NBuffer-1, "hhh");
    ok(outRemainder === 1,         "iii");

    #1 in <= 77; inEnable <= 1; #1 clock <= 1; #1 clock <= 0; #1 inEnable <= 0; // Load 77
    ok(inRemainder  === NBuffer-2, "jjj");
    ok(outRemainder === 2,         "kkk");

    #1 in <= 66; inEnable <= 1; #1 clock <= 1; #1 clock <= 0; #1 inEnable <= 0; // Load 66
    ok(inRemainder  === NBuffer-3, "lll");
    ok(outRemainder === 3,         "mmm");

    #1 outEnable <= 1; #1 clock <= 1; #1 clock <= 0; #1 outEnable <= 0;         // Read 88
    ok(out          === 88,        "nnn");
    ok(inRemainder  === NBuffer-2, "ooo");
    ok(outRemainder === 2,         "ppp");
    #1

    if (testsPassed > 0 && testsFailed > 0) begin                               // Summarize test results
       $display("Passed %1d tests, FAILED %1d tests out of %d tests", testsPassed, testsFailed, NTestsExpected);
    end
    else if (testsFailed > 0) begin
       $display("FAILED %1d tests out of %1d tests", testsFailed, NTestsExpected);
    end
    else if (testsPassed > 0 && testsPassed != NTestsExpected) begin
       $display("Passed %1d tests out of %1d tests with no failures ", testsPassed, NTestsExpected);
    end
    else if (testsPassed == NTestsExpected) begin                               // Testing summary
       $display("All %1d tests passed successfully", NTestsExpected);
    end
    else begin
       $display("No tests run passed: %1d, failed: %1d, expected %1d", testsPassed, testsFailed, NTestsExpected);
    end
  end
endmodule

module CircularBuffer                                                           // Circular buffer with options to clear the buffer, add an element to the buffer or remove an element from the buffer in first in, first out order. If there is  room in the buffer as shown by the "inRemainder" pins, the buffer will accept another element fron the "in" pins when "inEnable" is high and the "clock" goes high. Likewise if the "outEnable" pin is high and there is an element in the buffer as shown by the "outRemainder" pins, then an element will be removed from the buffer and placed on the "out" pins when the "clock" goes high. Inthe event that the buffer would run the input request is ignored - the caller must check that ther is space in the buffer  by checking the "inRemainder" pins first.  Likewise, if no output element is available the "out" [pins wil contionue to hold thei last value unless the "outRemainder" pins were not all zero.
 (input  wire clock,                                                             // Clock which drives both input and output
  input  wire reset,                                                            // Reset the buffer
  input  wire inEnable,                                                         // Add input element from "in" to buffer if there is room
  input  wire outEnable,                                                        // Remove element from buffer if possible and plae on "out" pins
  input  wire[NWidth-1:0] in,                                                   // Input channel
  output wire[NControl-1:0] inRemainder,                                        // Remaining free space in buffer
  output wire[NWidth-1:0] out,                                                  // Output channel
  output wire[NControl-1:0] outRemainder);                                      // Data available in buffer.  This field plus inRemainder equals the size of the buffer

  parameter integer NBuffer  =  8;                                              // Size of buffer
  parameter integer NWidth   = 64;                                              // Width of each buffer element
  parameter integer NControl =  $clog2(NBuffer)+1;                              // Width of each control wires

  reg signed [NWidth:0] buffer[NBuffer];                                        // Buffer

  integer signed Pos;                                                           // Start of active buffer
  integer signed End;                                                           // End of active buffer
  integer signed InRemainder;                                                   // Remaining space in buffer - if zero there is no more room until some elements have been read out
  integer signed Out;                                                           // Register to drive "out" pins
  integer signed OutRemainder;                                                  // Number of elements still readable - none when zero

  assign inRemainder  = InRemainder;                                            // Connect results registers to output pins
  assign out          = Out;
  assign outRemainder = OutRemainder;

  task space();                                                                 // Update space available
    fork
      if (End >= Pos) fork                                                      // Buffer not wrapped
        OutRemainder = End - Pos;
        InRemainder  = NBuffer + Pos - End;
      join
      if (End < Pos)  fork                                                      // Buffer wrapped
        OutRemainder = NBuffer - Pos + End;
        InRemainder  = Pos - End;
      join
      //$display("Space pos=%d end=%d NBuffer=%d r=%d InRemainder=%d OutRemainder=%d", Pos, End, NBuffer, r, InRemainder, OutRemainder);
    join
  endtask

  always @(posedge clock) fork                                                  // Next clock action
  //$display("NControl=%d", NControl);
  //$display("Clock Up reset=%d inEnable=%d outEnable=%d", reset, inEnable, outEnable);
    if (reset) begin                                                            // Clear buffer
      fork
        Pos = 0;
        End = 0;
      join
      space();
    end

    if (inEnable  && (End + 1) % NBuffer != Pos) begin                          // Input a new element if there is room
      buffer[End] = in;
      End         = (End + 1) % NBuffer;
      space();
    end

    if (outEnable && (Pos + 1) % NBuffer != End) begin                          // Output an existing element of there is one
      Out         = buffer[Pos];
      Pos         = (Pos + 1) % NBuffer;
      space();
    end
  join
endmodule
