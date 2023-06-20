  task startTest();                                                             // Shift_up_test: load code
    begin
      NInstructionEnd = 5;

      code[   0] = 'h0000000100000000000000000000210000000000000320000000000000000000;                                                                          // array
      code[   1] = 'h0000002300000000000000000000150000000000000020000000000000000000;                                                                          // mov
      code[   2] = 'h0000002300000000000000000001150000000000000120000000000000000000;                                                                          // mov
      code[   3] = 'h0000002300000000000000000002150000000000000220000000000000000000;                                                                          // mov
      code[   4] = 'h0000003800000000000000000000150000000000006320000000000000000000;                                                                          // shiftUp
    end
  endtask

  task endTest();                                                               // Shift_up_test: Evaluate results in out channel
    begin
      success = 1;

    end
  endtask
