  parameter integer NInstructions = 7;

  task startTest();                                                             // Pop_test: load code
    begin

      code[   0] = 'h0000000100000000000000000000210000000000000320000000000000000000;                                                                          // array
      code[   1] = 'h0000002e00000000000000000000210000000000000120000000000000032000;                                                                          // push
      code[   2] = 'h0000002e00000000000000000000210000000000000220000000000000032000;                                                                          // push
      code[   3] = 'h0000002d00000000000000000001210000000000000021000000000000032000;                                                                          // pop
      code[   4] = 'h0000002d00000000000000000002210000000000000021000000000000032000;                                                                          // pop
      code[   5] = 'h0000002700000000000000000000010000000000000121000000000000000000;                                                                          // out
      code[   6] = 'h0000002700000000000000000000010000000000000221000000000000000000;                                                                          // out
    end
  endtask

  task endTest();                                                               // Pop_test: Evaluate results in out channel
    begin
      success = 1;
      success = success && outMem[0] == 2;
      success = success && outMem[1] == 1;
    end
  endtask
