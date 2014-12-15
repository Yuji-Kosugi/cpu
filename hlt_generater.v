module hlt_generater(ir, hlt);
   input [31:0] ir;
   output 	hlt;

   assign hlt = (ir[31:24] == 8'b1111_0100);
endmodule
