module main_memory(address_a, address_b, clock, data_a, data_b, wren_a, wren_b, q_a, q_b);
   input [7:0] address_a, address_b;
   input clock;
   input [31:0] data_a, data_b;
   input 	wren_a, wren_b;
   output [31:0] q_a, q_b;

   reg [7:0] 	 reg_address_a, reg_address_b;
   reg [31:0] 	 reg_data_a, reg_data_b;
   reg 		 reg_wren_a, reg_wren_b;
   reg [31:0] 	 memory[0:255];

   assign q_a = memory[reg_address_a];
   assign q_b = memory[reg_address_b];

   always @(posedge clock) begin
      memory[0] <= 32'h66b90100;
      memory[1] <= 32'h89486490;
      memory[2] <= 32'h66ba0900;
      memory[3] <= 32'h90519090;
      memory[4] <= 32'hffd29090;
      memory[5] <= 32'h66be0300;
      memory[6] <= 32'h39ee9090;
      memory[7] <= 32'h90741590;
      memory[8] <= 32'hf4909090;
      memory[9] <= 32'h8b586490;
      memory[10] <= 32'h66bd0200;
      memory[11] <= 32'h01dd9090;
      memory[12] <= 32'hc3909090;
      memory[13] <= 32'h905f9090;
      memory[14] <= 32'hf4909090;
 
      reg_address_a <= address_a;
      reg_address_b <= address_b;
      reg_data_a <= data_a;
      reg_data_b <= data_b;
      reg_wren_a <= wren_a;
      reg_wren_b <= wren_b;	
      
      if (reg_wren_a == 1'b1) begin
	 memory[reg_address_a] <= reg_data_a;
      end
      if (reg_wren_b == 1'b1) begin
	 memory[reg_address_b] <= reg_data_b;
      end
   end
endmodule
