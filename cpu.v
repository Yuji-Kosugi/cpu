module cpu(clk, n_rst, rf0, rf1, rf2, rf3, rf4, rf5, rf6, rf7);
   input clk, n_rst;
   output [31:0] rf0, rf1, rf2, rf3, rf4, rf5, rf6, rf7;

   wire 	 hlt, dr2_select, rf_we, sp_we, me_we, jump;
   wire [2:0] 	 rf_wa;
   wire [4:0] 	 phase;
   wire [31:0] 	 next_pc, pc, next_ir, ir, sr, tr, dr, sp, next_sp, me_ad, me_wr, me_re, dr2;

   hlt_generater hlt_generater(ir, hlt);
   phase_generater phase_generater(clk, n_rst, hlt, phase);
   program_counter program_counter(clk, n_rst, phase[4], jump, dr2, next_pc, pc);
   instruction_register instruction_register(clk, phase[0], next_ir, ir);
   register_file register_file(clk, n_rst, phase[1], ir[21:19], ir[18:16], phase[4] & rf_we, rf_wa, dr2, phase[4] & sp_we, next_sp, sr, tr, sp, rf0, rf1, rf2, rf3, rf4, rf5, rf6, rf7);
   execute execute(clk, n_rst, phase[2], ir, sr, tr, pc, sp, dr, dr2_select, rf_we, rf_wa, sp_we, next_sp, jump, me_ad, me_we, me_wr);
   data_register2 data_register2(clk, phase[3], dr, me_re, dr2_select, dr2);
   main_memory main_memory(next_pc[7:0], me_ad[7:0], clk, 32'd0, me_wr, 1'b0, phase[2] & me_we, next_ir, me_re);
endmodule
