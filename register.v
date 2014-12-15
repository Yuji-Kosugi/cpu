module instruction_register(clk, we, next_ir, ir);
   input clk, we;
   input [31:0] next_ir;
   output reg [31:0] ir;

   always @(posedge clk) begin
      if (we == 1'b1) begin
	 ir <= next_ir;
      end
   end
endmodule
