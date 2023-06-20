  task startTest();                                                             // Push_test: load code
    begin
      for(i = 0; i < NInstructions; i = i + 1) code[i] = 0;
      NInstructionEnd = 3;

      code[   0] = 'h0000000100000000000000000000210000000000000320000000000000000000;                                                                          // array
      code[   1] = 'h0000002e00000000000000000000210000000000000120000000000000032000;                                                                          // push
      code[   2] = 'h0000002e00000000000000000000210000000000000220000000000000032000;                                                                          // push
    end
  endtask

  task endTest();                                                               // Push_test: Evaluate results in out channel
    begin
      success = 1;

    end
  endtask
