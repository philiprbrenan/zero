  parameter integer NInstructions = 6;

  task startTest();                                                             // Not_test: load code
    begin

      code[   0] = 'h0000002300000000000000000000210000000000000320000000000000000000;                                                                          // mov
      code[   1] = 'h0000002600000000000000000001210000000000000021000000000000000000;                                                                          // not
      code[   2] = 'h0000002600000000000000000002210000000000000121000000000000000000;                                                                          // not
      code[   3] = 'h0000002700000000000000000000010000000000000021000000000000000000;                                                                          // out
      code[   4] = 'h0000002700000000000000000000010000000000000121000000000000000000;                                                                          // out
      code[   5] = 'h0000002700000000000000000000010000000000000221000000000000000000;                                                                          // out
    end
  endtask

  task endTest();                                                               // Not_test: Evaluate results in out channel
    begin
      success = 1;
      success = success && outMem[0] == 3;
      success = success && outMem[1] == 0;
      success = success && outMem[2] == 1;
    end
  endtask
