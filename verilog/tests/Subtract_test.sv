  task Subtract_test();
    begin                                                                       // Subtract_test
      NInstructionEnd = 2;

      code[   0] = 'h0000003900000000000000000000210000000000000420000000000000022000;                                                                          // subtract
      code[   1] = 'h0000002700000000000000000000010000000000000021000000000000000000;                                                                          // out
    end
  endtask
