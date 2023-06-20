  task startTest();                                                             // Subtract_test: load code
    begin
      for(i = 0; i < NInstructions; i = i + 1) code[i] = 0;
      NInstructionEnd = 2;

      code[   0] = 'h0000003900000000000000000000210000000000000420000000000000022000;                                                                          // subtract
      code[   1] = 'h0000002700000000000000000000010000000000000021000000000000000000;                                                                          // out
    end
  endtask

  task endTest();                                                               // Subtract_test: Evaluate results in out channel
    begin
      success = 1;

    end
  endtask
