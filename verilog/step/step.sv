//-----------------------------------------------------------------------------
// Step
// Philip R Brenan at appaapps dot com, Appa Apps Ltd Inc., 2023
//------------------------------------------------------------------------------
module step
 (input  wire in);

  integer count = 0;
  integer clock = 0;

  always @(posedge in) begin
    $display("AAAA");
    count <= 0;
    clock <= 1;
  end
  always @(posedge clock) begin
    count <= count + 1;
    $display("BBBB %d", count);
    clock <= ~ clock;
    if (count > 10) $finish();
  end
  always @(negedge clock) begin
    count <= count + 1;
    $display("CCCC %d", count);
    clock <= ~ clock;
    if (count > 10) $finish();
  end
endmodule
