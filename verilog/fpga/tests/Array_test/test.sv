  task startTest();                                                             // Array_test: load code
    begin
      for(i = 0; i < NInstructions; i = i + 1) code[i] = 0;
      NInstructionEnd = 4;

      code[   0] = 'h0000000100000000000000000000210000000000000320000000000000000000;                                                                          // array
      code[   1] = 'h0000002300000000000000000001150000000000000b20000000000000000000;                                                                          // mov
      code[   2] = 'h0000002300000000000000000001210000000000000115000000000000000000;                                                                          // mov
      code[   3] = 'h0000002700000000000000000000010000000000000121000000000000000000;                                                                          // out
    end
  endtask

  task endTest();                                                               // Array_test: Evaluate results in out channel
    begin
      success = 1;

    end
  endtask
