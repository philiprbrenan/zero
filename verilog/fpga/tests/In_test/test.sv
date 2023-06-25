  parameter integer NInstructions = 9;

  task startTest();                                                             // In_test: load code
    begin

      code[   0] = 'h0000002000000000000000000000010000000000000120000000000000000000;                                                                          // label
      code[   1] = 'h0000001600000000000000000000210000000000000000000000000000000000;                                                                          // inSize
      code[   2] = 'h0000001800000000000000060003210000000000000021000000000000000000;                                                                          // jFalse
      code[   3] = 'h0000001500000000000000000001210000000000000000000000000000000000;                                                                          // in
      code[   4] = 'h0000002700000000000000000000010000000000000021000000000000000000;                                                                          // out
      code[   5] = 'h0000002700000000000000000000010000000000000121000000000000000000;                                                                          // out
      code[   6] = 'h0000002000000000000000000000010000000000000220000000000000000000;                                                                          // label
      code[   7] = 'h0000001f00000000fffffff90001210000000000000000000000000000000000;                                                                          // jmp
      code[   8] = 'h0000002000000000000000000000010000000000000320000000000000000000;                                                                          // label
    end
  endtask

  task endTest();                                                               // In_test: Evaluate results in out channel
    begin
      success = 1;
      success = success && outMem[0] == 3;
      success = success && outMem[1] == 33;
      success = success && outMem[2] == 2;
      success = success && outMem[3] == 22;
      success = success && outMem[4] == 1;
      success = success && outMem[5] == 11;
    end
  endtask
