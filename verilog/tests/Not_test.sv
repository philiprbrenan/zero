  task Not_test();
    begin                                                                       // Not_test
      NInstructionEnd = 6;

      code[   0] = 'h0000002300000000000000000000210000000000000320000000000000000000;                                                                          // mov
      code[   1] = 'h0000002600000000000000000001210000000000000021000000000000000000;                                                                          // not
      code[   2] = 'h0000002600000000000000000002210000000000000121000000000000000000;                                                                          // not
      code[   3] = 'h0000002700000000000000000000010000000000000021000000000000000000;                                                                          // out
      code[   4] = 'h0000002700000000000000000000010000000000000121000000000000000000;                                                                          // out
      code[   5] = 'h0000002700000000000000000000010000000000000221000000000000000000;                                                                          // out
    end
  endtask
