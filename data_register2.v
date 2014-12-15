module data_register2(clk, we, dr, me_re, dr2_select, dr2);
   input clk, we;
   input [31:0] dr, me_re;
   input 	dr2_select;
   output reg [31:0] dr2;

   always @(posedge clk) begin
      if (we == 1'b1) begin
	 dr2 <= (dr2_select == 1'b0) ? dr : me_re;
      end
   end
endmodule
