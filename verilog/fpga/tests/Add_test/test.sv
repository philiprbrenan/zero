  task startTest();                                                             // Add_test: load code
    begin
      for(i = 0; i < NInstructions; i = i + 1) code[i] = 0;
      NInstructionEnd = 2;

      code[   0] = 'h0000000000000000000000000000210000000000000320000000000000022000;                                                                          // add
      code[   1] = 'h0000002700000000000000000000010000000000000021000000000000000000;                                                                          // out
    end
  endtask

  task endTest();                                                               // Add_test: Evaluate results in out channel
    begin
      success = 1;

      success = success && outMem[0] == 5;

    end
  endtask
