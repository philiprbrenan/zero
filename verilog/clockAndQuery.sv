//-----------------------------------------------------------------------------
// Advance the clock and query the results
// Philip R Brenan at appaapps dot com, Appa Apps Ltd Inc., 2023
//------------------------------------------------------------------------------
module ClockAndQuery                                                            // Advance the clock and respond to a pseudo request to see memory
 (input  wire clock,                                                            // Clock
  input  wire reset,                                                            // Restart ip
  input  wire in,                                                               // Memory byte address to be read as 8 bits
  output wire out);                                                             // 8 bits representing the byte in memory corresponding. Visible after 8 bits clocked into in

  parameter integer NSize  = 8;                                                 // Log2(Size of memory)

  reg[NSize:0] ip, ip2;                                                         // Instruction pointer which we will advance
  reg[NSize:0] in2;                                                             // Out driver
  reg[NSize:0] got;                                                             // What we got from memory
  reg out2;                                                                     // Out driving register
  reg[NSize:0] outReg;                                                          // Out driver
  integer state, state2;                                                        // Clock divder

  assign out = out2;

  always @(posedge(clock) && reset) begin                                       // Start ip address
    //$display("Reset");
    ip <= 0; ip2 <= 0;
    state <= 0; state2 <= 0;  in2 <= 0;
  end

  always @(posedge clock && !reset) begin                                       // Capture current input on positive edge
    //$display("Positive");
    ip2 <= ip;                                                                  // Simulate executing an instruction
    state2 <= state;                                                            // Divide the clock so we can read in the address and write the contents as a single bit stream after simulating executing the instruction
  end

// Use NSize clocks to get the address, 1 to read the associated value from memory, NSize to send it back, 1 to execute the next pseudo instruction making 2 * (NSize + 1) in total for each instruction execute, check resulting memory cycle.

  always @(negedge clock) begin                                                 // Next state
    //$display("Negedge state %2d, state2=%2d", state, state2);
    if (state2 > 2 * (1  + NSize)) begin                                        // Cycle state up
      //$display("Reset state");
      state <= 0;
    end
    else begin                                                                  // Reset state
      //$display("Next state %2d", state2 + 1);
      state <= state2 + 1;
    end
  end

  always @(negedge clock) begin                                                 // Read address
    if (state2 > 0 && state2 <= NSize) begin
      in2[state2-1] <= in;
      $display("At state: %2d Read bit %2d value %2d total : %d", state2, state2-1, in, in2);
    end
  end

  always @(negedge clock) begin                                                 // Next pseudo instruction
    if (state2 == NSize+1) begin
      $display("At state: %2d Read memory %d got %d", state2, in2, ip2);
      got = ip2;
    end
  end

  always @(negedge clock) begin                                                 // Write result
    if (state2 > NSize + 1 && state2 <= NSize * 2 + 1) begin
      out2 <= got[state2 - NSize - 2];
      //$display("At state: %2d write bit %2d value %2d", state2, state2 - NSize - 2, got[state2 - NSize - 2]);
    end
  end

  always @(negedge clock) begin                                                 // Next pseudo instruction
    if (state2 == 2 + 2 * NSize) begin
      //$display("Next instruction");
      ip <= ip2 + 1;
    end
  end
endmodule
