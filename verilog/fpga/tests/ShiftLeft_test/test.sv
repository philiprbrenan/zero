  task startTest();                                                             // ShiftLeft_test: load code
    begin
      for(i = 0; i < NInstructions; i = i + 1) code[i] = 0;
      NInstructionEnd = 3;

      code[   0] = 'h0000002300000000000000000000210000000000000120000000000000000000;                                                                          // mov
      code[   1] = 'h0000003600000000000000000000210000000000000021000000000000000000;                                                                          // shiftLeft
      code[   2] = 'h0000002700000000000000000000010000000000000021000000000000000000;                                                                          // out
    end
  endtask

  task endTest();                                                               // ShiftLeft_test: Evaluate results in out channel
    begin
      success = 1;

    end
  endtask
