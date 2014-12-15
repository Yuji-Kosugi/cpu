module test_bench;
   reg clk, n_rst;
   wire [31:0] rf[0:7];
   
   cpu cpu(clk, n_rst, rf[0], rf[1], rf[2], rf[3], rf[4], rf[5], rf[6], rf[7]);
 
   initial begin
      $dumpfile("test_bench.vcd");
      $dumpvars(0, test_bench);
      $monitor("%d:rf[0]=%h,rf[1]=%h,rf[2]=%h,rf[3]=%h,rf[4]=%h,rf[5]=%h,rf[6]=%h,rf[7]=%h", $time, rf[0], rf[1], rf[2], rf[3], rf[4], rf[5], rf[6], rf[7]);
      clk <= 1'b1;
      n_rst <= 1'b1;
      #10 n_rst <= 1'b0;	
      #10 n_rst <= 1'b1;
      #10000 $finish;
   end
   
   always begin
      #5 clk <= ~clk;
   end
endmodule
