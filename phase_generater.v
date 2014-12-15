module phase_generater(clk, n_rst, hlt, phase);
   input clk, n_rst, hlt;
   output reg [4:0] phase;
   
   reg n_rst_d;
   
   always @(posedge clk) begin
      n_rst_d <= n_rst;
      if (hlt == 1'b1) begin
	phase <= 5'b00000;
      end else if (n_rst_d == 1'b0 && n_rst == 1'b1) begin
	 phase <= 5'b10000;
      end else begin
	phase <= {phase[3:0], phase[4]};
      end
   end
endmodule
