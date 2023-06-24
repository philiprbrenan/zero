  parameter integer NInstructions = 3;

  task startTest();                                                             // ShiftLeft_test: load code
    begin

      code[   0] = 'b0000000000000000000000001100010000000000000000000000000000000000000000000000000000000000000000000000000000000000100001000000000000000000000000000000000000000000000000001000000000000100000000000000000000000000000000000000000000000000000000000000000000000000;                                          // mov
      code[   1] = 'b0000000000000000000000000110110000000000000000000000000000000000000000000000000000000000000000000000000000000000100001000000000000000000000000000000000000000000000000000000000010000100000000000000000000000000000000000000000000000000000000000000000000000000;                                          // shiftLeft
      code[   2] = 'b0000000000000000000000001110010000000000000000000000000000000000000000000000000000000000000000000000000000000000100000000000000000000000000000000000000000000000000000000000000010000100000000000000000000000000000000000000000000000000000000000000000000000000;                                          // out
    end
  endtask

  task endTest();                                                               // ShiftLeft_test: Evaluate results in out channel
    begin
      success = 1;
      success = success && outMem[0] == 2;
    end
  endtask
