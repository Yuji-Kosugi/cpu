module program_counter(clk, n_rst, we, jump, dr2, next_pc, pc);
   input clk, n_rst, we, jump;
   input [31:0] dr2;
   output [31:0]     next_pc;
   output reg [31:0] pc;

   assign next_pc = (jump == 1'b0) ? pc + 32'd1 : dr2;
   
   always @(posedge clk or negedge n_rst) begin
      if (n_rst == 1'b0) begin
	 pc <= 32'hffffffff;
      end else if (we == 1'b1) begin
	 pc <= next_pc;
      end
   end
endmodule
