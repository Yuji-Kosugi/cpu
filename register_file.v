module register_file(clk, n_rst, we, ra1, ra2, rf_we, wa, dr2, sp_we, next_sp, reg1, reg2, sp, rf0, rf1, rf2, rf3, rf4, rf5, rf6, rf7);
   input clk, n_rst, we;
   input [2:0] ra1, ra2;
   input 	 rf_we;
   input [2:0] 	 wa;
   input [31:0]  dr2;
   input 	 sp_we;
   input [31:0]  next_sp;
   output reg [31:0] reg1, reg2, sp;
   output [31:0]     rf0, rf1, rf2, rf3, rf4, rf5, rf6, rf7;
   
   reg [31:0] 	 rf [0:7];
   
   assign rf0 = rf[0];
   assign rf1 = rf[1];
   assign rf2 = rf[2];
   assign rf3 = rf[3];
   assign rf4 = rf[4];
   assign rf5 = rf[5];
   assign rf6 = rf[6];
   assign rf7 = rf[7];

   always @(posedge clk or negedge n_rst) begin
      if (n_rst == 1'b0) begin
	 rf[0] <= 32'h00000000;
	 rf[1] <= 32'h00000000;
	 rf[2] <= 32'h00000000;
	 rf[3] <= 32'h00000000;
	 rf[4] <= 32'h00000100;
	 rf[5] <= 32'h00000000;
	 rf[6] <= 32'h00000000;
	 rf[7] <= 32'h00000000;
      end else begin
	 if (we == 1'b1) begin
	    reg1 <= rf[ra1];
	    reg2 <= rf[ra2];
	    sp <= rf[4];
	 end 
	 if (rf_we == 1'b1) begin
	    rf[wa] <= dr2;
	 end
	 if (sp_we == 1'b1) begin
	    rf[4] <= next_sp;
	 end
      end	    
   end
endmodule
