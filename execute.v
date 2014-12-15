module execute(clk, n_rst, we, ir, sr, tr, pc, sp, dr, dr2_select, rf_we, rf_wa, sp_we, next_sp, jump, me_ad, me_we, me_wr);
   input clk, n_rst, we;
   input [31:0] ir, sr, tr, pc, sp;
   output reg [31:0] dr;
   output reg 	     dr2_select;
   output reg 	     rf_we;
   output reg [2:0]  rf_wa;
   output reg 	     sp_we;
   output reg [31:0] next_sp;
   output reg 	     jump;
   output [31:0]     me_ad;
   output  	     me_we;
   output [31:0]     me_wr;
   
   wire [7:0] 	     sim8;
   wire [15:0] 	     im16;
   reg 		     sf, zf, cf, of;
   wire [31:0] 	     asy_dr;
   wire [39:0] 	     judge_cf;

   assign sim8 = ir[15:8];
   assign im16 = {ir[7:0], ir[15:8]};

   always @(posedge clk) begin
      if (we == 1'b1) begin
	 dr <= asy_dr;
      end
   end

   assign asy_dr = asy_dr_gen(ir, sr, tr, sim8, pc);
   
   function [31:0] asy_dr_gen;
      input [31:0]   ir, sr, tr;
      input [7:0]    sim8;
      input [31:0]   pc;

      begin
	 case (ir[31:19]) // 即値ロード命令
	   13'b0110_0110_10_111 : asy_dr_gen = {tr[31:16], im16};
	 endcase
	 case (ir[31:22]) // レジスタ間転送命令
	   10'b1000_1001_11 : asy_dr_gen = sr;
	 endcase 
	 case (ir[31:22]) // 二項演算命令 register - register
	   10'b0000_0001_11 : asy_dr_gen = sr + tr;
	   10'b0010_1001_11 : asy_dr_gen = tr - sr;
	   10'b0011_1001_11 : asy_dr_gen = tr - sr;
	   10'b0010_0001_11 : asy_dr_gen = sr & tr;
	   10'b0000_1001_11 : asy_dr_gen = sr | tr;
	   10'b0011_0001_11 : asy_dr_gen = sr ^ tr;
	 endcase
	 case (ir[31:19]) // 二項演算命令 register - immediate
	   13'b1000_0001_11_000 : asy_dr_gen = tr + {24'd0, sim8};
	   13'b1000_0011_11_000 : asy_dr_gen = tr + {{24{sim8[7]}}, sim8};
	   13'b1000_0001_11_101 : asy_dr_gen = tr - {24'd0, sim8};
	   13'b1000_0011_11_101 : asy_dr_gen = tr - {{24{sim8[7]}}, sim8};
	   13'b1000_0001_11_111 : asy_dr_gen = tr - {24'd0, sim8};
	   13'b1000_0011_11_111 : asy_dr_gen = tr - {{24{sim8[7]}}, sim8};
	   13'b1000_0001_11_100 : asy_dr_gen = tr & {24'd0, sim8};
	   13'b1000_0011_11_100 : asy_dr_gen = tr & {{24{sim8[7]}}, sim8};
	   13'b1000_0001_11_001 : asy_dr_gen = tr | {24'd0, sim8};
	   13'b1000_0011_11_001 : asy_dr_gen = tr | {{24{sim8[7]}}, sim8};
	   13'b1000_0001_11_110 : asy_dr_gen = tr ^ {24'd0, sim8};
	   13'b1000_0011_11_110 : asy_dr_gen = tr ^ {{24{sim8[7]}}, sim8};
	 endcase
	 case (ir[31:19]) // 単項演算命令
	   13'b1111_0111_11_011 : asy_dr_gen = -tr;
	   13'b1111_0111_11_010 : asy_dr_gen = ~tr;
	 endcase 
	 case (ir[31:19]) // シフト命令
	   13'b1100_0001_11_100 : asy_dr_gen = tr << sim8;
	   13'b1100_0001_11_101 : asy_dr_gen = tr >> sim8;
	   13'b1100_0001_11_111 : asy_dr_gen = tr >>> sim8;
	 endcase
	 case (ir[31:16]) // 無条件分岐命令
	   16'b1001_0000_1110_1011 : asy_dr_gen = pc + (({{24{sim8[7]}}, sim8} + 32'd3) >>> 2);
	 endcase
	 case (ir[31:20]) // 条件分岐命令
	   12'b1001_0000_0111 : asy_dr_gen = pc + (({{24{sim8[7]}}, sim8} + 32'd3) >>> 2);
	 endcase
	 case (ir[31:19]) // レジスタ間接ジャンプ命令
	   13'b1111_1111_11_100 : asy_dr_gen = tr;
	 endcase
	 case (ir[31:19]) // レジスタ間接ジャンプ&リンク命令
	   13'b1111_1111_11_010 : asy_dr_gen = tr;
	 endcase
      end
   endfunction

   always @(posedge clk) begin
      if (we == 1'b1) begin
	 case (ir[31:22]) // ロード命令
	   10'b1000_1011_01 : dr2_select <= 1'b1;
	 endcase
	 case (ir[31:19]) // 即値ロード命令
	   13'b0110_0110_10_111 : dr2_select <= 1'b0;
	 endcase
	 case (ir[31:22]) // レジスタ間転送命令
	   10'b1000_1001_11 : dr2_select <= 1'b0;
	 endcase 
	 case (ir[31:22]) // 二項演算命令 register - register
	   10'b0000_0001_11 : dr2_select <= 1'b0;
	   10'b0010_1001_11 : dr2_select <= 1'b0;
	   10'b0011_1001_11 : dr2_select <= 1'b0;
	   10'b0010_0001_11 : dr2_select <= 1'b0;
	   10'b0000_1001_11 : dr2_select <= 1'b0;
	   10'b0011_0001_11 : dr2_select <= 1'b0;
	 endcase
	 case (ir[31:19]) // 二項演算命令 register - immediate
	   13'b1000_0001_11_000 : dr2_select <= 1'b0;
	   13'b1000_0011_11_000 : dr2_select <= 1'b0;
	   13'b1000_0001_11_101 : dr2_select <= 1'b0;
	   13'b1000_0011_11_101 : dr2_select <= 1'b0;
	   13'b1000_0001_11_111 : dr2_select <= 1'b0;
	   13'b1000_0011_11_111 : dr2_select <= 1'b0;
	   13'b1000_0001_11_100 : dr2_select <= 1'b0;
	   13'b1000_0011_11_100 : dr2_select <= 1'b0;
	   13'b1000_0001_11_001 : dr2_select <= 1'b0;
	   13'b1000_0011_11_001 : dr2_select <= 1'b0;
	   13'b1000_0001_11_110 : dr2_select <= 1'b0;
	   13'b1000_0011_11_110 : dr2_select <= 1'b0;
	 endcase
	 case (ir[31:19]) // 単項演算命令
	   13'b1111_0111_11_011 : dr2_select <= 1'b0;
	   13'b1111_0111_11_010 : dr2_select <= 1'b0;
	 endcase 
	 case (ir[31:19]) // シフト命令
	   13'b1100_0001_11_100 : dr2_select <= 1'b0;
	   13'b1100_0001_11_101 : dr2_select <= 1'b0;
	   13'b1100_0001_11_111 : dr2_select <= 1'b0;
	 endcase
	 case (ir[31:16]) // 無条件分岐命令
	   16'b1001_0000_1110_1011 : dr2_select <= 1'b0;
	 endcase
	 case (ir[31:20]) // 条件分岐命令
	   16'b1001_0000_0111 : dr2_select <= 1'b0;
	 endcase
	 case (ir[31:19]) // レジスタ間接ジャンプ命令
	   13'b1111_1111_11_100 : dr2_select <= 1'b0;
	 endcase
	 case (ir[31:19]) // レジスタ間接ジャンプ&リンク命令
	   13'b1111_1111_11_010 : dr2_select <= 1'b0;
	 endcase
	 case (ir[31:24]) // リターン命令
	   8'b1100_0011 : dr2_select <= 1'b1;
	 endcase
	 case (ir[31:19]) // プッシュ・ポップ命令
	   13'b1001_0000_0101_1 : dr2_select <= 1'b1;
	 endcase
      end
   end

   always @(posedge clk) begin
      if (we == 1'b1) begin
	 case (ir[31:22]) // ロード命令
	   10'b1000_1011_01 : rf_wa <= ir[21:19];
	 endcase
	 case (ir[31:19]) // 即値ロード命令
	   13'b0110_0110_10_111 : rf_wa <= ir[18:16];
	 endcase
	 case (ir[31:22]) // レジスタ間転送命令
	   10'b1000_1001_11 : rf_wa <= ir[18:16];
	 endcase 
	 case (ir[31:22]) // 二項演算命令 register - register
	   10'b0000_0001_11 : rf_wa <= ir[18:16];
	   10'b0010_1001_11 : rf_wa <= ir[18:16];
	   10'b0011_1001_11 : rf_wa <= ir[18:16];
	   10'b0010_0001_11 : rf_wa <= ir[18:16];
	   10'b0000_1001_11 : rf_wa <= ir[18:16];
	   10'b0011_0001_11 : rf_wa <= ir[18:16];
	 endcase
	 case (ir[31:19]) // 二項演算命令 register - immediate
	   13'b1000_0001_11_000 : rf_wa <= ir[18:16];
	   13'b1000_0011_11_000 : rf_wa <= ir[18:16];
	   13'b1000_0001_11_101 : rf_wa <= ir[18:16];
	   13'b1000_0011_11_101 : rf_wa <= ir[18:16];
	   13'b1000_0001_11_111 : rf_wa <= ir[18:16];
	   13'b1000_0011_11_111 : rf_wa <= ir[18:16];
	   13'b1000_0001_11_100 : rf_wa <= ir[18:16];
	   13'b1000_0011_11_100 : rf_wa <= ir[18:16];
	   13'b1000_0001_11_001 : rf_wa <= ir[18:16];
	   13'b1000_0011_11_001 : rf_wa <= ir[18:16];
	   13'b1000_0001_11_110 : rf_wa <= ir[18:16];
	   13'b1000_0011_11_110 : rf_wa <= ir[18:16];
	 endcase
	 case (ir[31:19]) // 単項演算命令
	   13'b1111_0111_11_011 : rf_wa <= ir[18:16];
	   13'b1111_0111_11_010 : rf_wa <= ir[18:16];
	 endcase 
	 case (ir[31:19]) // シフト命令
	   13'b1100_0001_11_100 : rf_wa <= ir[18:16];
	   13'b1100_0001_11_101 : rf_wa <= ir[18:16];
	   13'b1100_0001_11_111 : rf_wa <= ir[18:16];
	 endcase
	 case (ir[31:19]) // プッシュ・ポップ命令
	   13'b1001_0000_0101_1 : rf_wa <= ir[18:16];
	 endcase
      end
   end

   always @(posedge clk or negedge n_rst) begin
      if (n_rst == 1'b0) begin
	 rf_we <= 1'b0;
      end else if (we == 1'b1) begin
	 case (ir[31:22]) // ロード・ストア命令
	   10'b1000_1011_01 : rf_we <= 1'b1;
	   10'b1000_1001_01 : rf_we <= 1'b0;
	 endcase
	 case (ir[31:19]) // 即値ロード命令
	   13'b0110_0110_10_111 : rf_we <= 1'b1;
	 endcase
	 case (ir[31:22]) // レジスタ間転送命令
	   10'b1000_1001_11 : rf_we <= 1'b1;
	 endcase 
	 case (ir[31:22]) // 二項演算命令 register - register
	   10'b0000_0001_11 : rf_we <= 1'b1;
	   10'b0010_1001_11 : rf_we <= 1'b1;
	   10'b0011_1001_11 : rf_we <= 1'b0;
	   10'b0010_0001_11 : rf_we <= 1'b1;
	   10'b0000_1001_11 : rf_we <= 1'b1;
	   10'b0011_0001_11 : rf_we <= 1'b1;
	 endcase
	 case (ir[31:19]) // 二項演算命令 register - immediate
	   13'b1000_0001_11_000 : rf_we <= 1'b1;
	   13'b1000_0011_11_000 : rf_we <= 1'b1;
	   13'b1000_0001_11_101 : rf_we <= 1'b1;
	   13'b1000_0011_11_101 : rf_we <= 1'b1;
	   13'b1000_0001_11_111 : rf_we <= 1'b1;
	   13'b1000_0011_11_111 : rf_we <= 1'b1;
	   13'b1000_0001_11_100 : rf_we <= 1'b1;
	   13'b1000_0011_11_100 : rf_we <= 1'b1;
	   13'b1000_0001_11_001 : rf_we <= 1'b1;
	   13'b1000_0011_11_001 : rf_we <= 1'b1;
	   13'b1000_0001_11_110 : rf_we <= 1'b1;
	   13'b1000_0011_11_110 : rf_we <= 1'b1;
	 endcase
	 case (ir[31:19]) // 単項演算命令
	   13'b1111_0111_11_011 : rf_we <= 1'b1;
	   13'b1111_0111_11_010 : rf_we <= 1'b1;
	 endcase 
	 case (ir[31:19]) // シフト命令
	   13'b1100_0001_11_100 : rf_we <= 1'b1;
	   13'b1100_0001_11_101 : rf_we <= 1'b1;
	   13'b1100_0001_11_111 : rf_we <= 1'b1;
	 endcase
	 case (ir[31:16]) // 無条件分岐命令
	   16'b1001_0000_1110_1011 : rf_we <= 1'b0;
	 endcase
	 case (ir[31:20]) // 条件分岐命令
	   16'b1001_0000_0111 : rf_we <= 1'b0;
	 endcase
	 case (ir[31:19]) // レジスタ間接ジャンプ命令
	   13'b1111_1111_11_100 : rf_we <= 1'b0;
	 endcase
	 case (ir[31:19]) // レジスタ間接ジャンプ&リンク命令
	   13'b1111_1111_11_010 : rf_we <= 1'b0;
	 endcase
	 case (ir[31:24]) // リターン命令
	   8'b1100_0011 : rf_we <= 1'b0;
	 endcase
	 case (ir[31:19]) // プッシュ・ポップ命令
	   13'b1001_0000_0101_0 : rf_we <= 1'b0;
	   13'b1001_0000_0101_1 : rf_we <= 1'b1;
	 endcase
	 case (ir[31:16]) // NOP命令
	   16'b1001_0000_1001_0000 : rf_we <= 1'b0;
	 endcase
      end
   end

   assign me_we = me_we_gen(ir);

   function me_we_gen;
      input [31:0] ir;

      begin
	 case (ir[31:22]) // ロード・ストア命令
	   10'b1000_1011_01 : me_we_gen = 1'b0;
	   10'b1000_1001_01 : me_we_gen = 1'b1;
	 endcase
	 case (ir[31:19]) // 即値ロード命令
	   13'b0110_0110_10_111 : me_we_gen = 1'b0;
	 endcase
	 case (ir[31:22]) // レジスタ間転送命令
	   10'b1000_1001_11 : me_we_gen = 1'b0;
	 endcase 
	 case (ir[31:22]) // 二項演算命令 register - register
	   10'b0000_0001_11 : me_we_gen = 1'b0;
	   10'b0010_1001_11 : me_we_gen = 1'b0;
	   10'b0011_1001_11 : me_we_gen = 1'b0;
	   10'b0010_0001_11 : me_we_gen = 1'b0;
	   10'b0000_1001_11 : me_we_gen = 1'b0;
	   10'b0011_0001_11 : me_we_gen = 1'b0;
	 endcase
	 case (ir[31:19]) // 二項演算命令 register - immediate
	   13'b1000_0001_11_000 : me_we_gen = 1'b0;
	   13'b1000_0011_11_000 : me_we_gen = 1'b0;
	   13'b1000_0001_11_101 : me_we_gen = 1'b0;
	   13'b1000_0011_11_101 : me_we_gen = 1'b0;
	   13'b1000_0001_11_111 : me_we_gen = 1'b0;
	   13'b1000_0011_11_111 : me_we_gen = 1'b0;
	   13'b1000_0001_11_100 : me_we_gen = 1'b0;
	   13'b1000_0011_11_100 : me_we_gen = 1'b0;
	   13'b1000_0001_11_001 : me_we_gen = 1'b0;
	   13'b1000_0011_11_001 : me_we_gen = 1'b0;
	   13'b1000_0001_11_110 : me_we_gen = 1'b0;
	   13'b1000_0011_11_110 : me_we_gen = 1'b0;
	 endcase
	 case (ir[31:19]) // 単項演算命令
	   13'b1111_0111_11_011 : me_we_gen = 1'b0;
	   13'b1111_0111_11_010 : me_we_gen = 1'b0;
	 endcase 
	 case (ir[31:19]) // シフト命令
	   13'b1100_0001_11_100 : me_we_gen = 1'b0;
	   13'b1100_0001_11_101 : me_we_gen = 1'b0;
	   13'b1100_0001_11_111 : me_we_gen = 1'b0;
	 endcase
	 case (ir[31:16]) // 無条件分岐命令
	   16'b1001_0000_1110_1011 : me_we_gen = 1'b0;
	 endcase
	 case (ir[31:20]) // 条件分岐命令
	   16'b1001_0000_0111 : me_we_gen = 1'b0;
	 endcase
	 case (ir[31:19]) // レジスタ間接ジャンプ命令
	   13'b1111_1111_11_100 : me_we_gen = 1'b0;
	 endcase
	 case (ir[31:19]) // レジスタ間接ジャンプ&リンク命令
	   13'b1111_1111_11_010 : me_we_gen = 1'b1;
	 endcase
	 case (ir[31:24]) // リターン命令
	   8'b1100_0011 : me_we_gen = 1'b0;
	 endcase
	 case (ir[31:19]) // プッシュ・ポップ命令
	   13'b1001_0000_0101_0 : me_we_gen = 1'b1;
	   13'b1001_0000_0101_1 : me_we_gen = 1'b0;
	 endcase
	 case (ir[31:16]) // NOP命令
	   16'b1001_0000_1001_0000 : me_we_gen = 1'b0;
	 endcase
      end
   endfunction

   always @(posedge clk) begin
      if (we == 1'b1) begin
	 sf <= asy_dr[31];
	 zf <= (asy_dr == 32'd0);
	 cf <= (judge_cf[39:32] == 8'd0);
      end
   end

   assign judge_cf = judge_cf_gen(ir, sr, tr, sim8);

   function judge_cf_gen;
      input [31:0] ir;
      input [31:0] sr;
      input [31:0] tr;
      input [7:0]  sim8;

      begin
	 case (ir[31:22]) // 二項演算命令 register - register
	   10'b0000_0001_11 : judge_cf_gen = {8'd0, sr} + {8'd0, tr};
	   10'b0010_1001_11 : judge_cf_gen = {8'd0, sr} - {8'd0, tr};
	   10'b0011_1001_11 : judge_cf_gen = {8'd0, sr} - {8'd0, tr};
	 endcase
	 case (ir[31:19]) // 二項演算命令 register - immediate
	   13'b1000_0001_11_000 : judge_cf_gen = {8'd0, tr} + {32'd0, sim8};
	   13'b1000_0011_11_000 : judge_cf_gen = {8'd0, tr} + {{32{sim8[7]}}, sim8};
	   13'b1000_0001_11_101 : judge_cf_gen = {8'd0, tr} - {32'd0, sim8};
	   13'b1000_0011_11_101 : judge_cf_gen = {8'd0, tr} - {{32{sim8[7]}}, sim8};
	   13'b1000_0001_11_111 : judge_cf_gen = {8'd0, tr} - {32'd0, sim8};
	   13'b1000_0011_11_111 : judge_cf_gen = {8'd0, tr} - {{32{sim8[7]}}, sim8};
	 endcase
	 case (ir[31:19]) // シフト命令
	   13'b1100_0001_11_100 : judge_cf_gen = {8'd0, tr} << sim8;
	 endcase
      end
   endfunction

   always @(posedge clk or negedge n_rst) begin
	 case (ir[31:22]) // 二項演算命令 register - register
	   10'b0000_0001_11 : of <= (!sr[31] & !tr[31] & asy_dr[31]) | (sr[31] & tr[31] & !asy_dr[31]);
	   10'b0010_1001_11 : of <= (!sr[31] & tr[31] & asy_dr[31]) | (sr[31] & !tr[31] & !asy_dr[31]);
	   10'b0011_1001_11 : of <= (!sr[31] & tr[31] & asy_dr[31]) | (sr[31] & !tr[31] & !asy_dr[31]);
	 endcase
	 case (ir[31:19]) // 二項演算命令 register - immediate
	   13'b1000_0001_11_000 : of <= !tr[31] & asy_dr[31];
	   13'b1000_0011_11_000 : of <= (!tr[31] & !sim8[7] & asy_dr[31]) | (tr[31] & sim8[7] & !asy_dr[31]);
	   13'b1000_0001_11_101 : of <= tr[31] & !asy_dr[31];
	   13'b1000_0011_11_101 : of <= (!tr[31] & sim8[7] & asy_dr[31]) | (tr[31] & !sim8[7] & !asy_dr[31]);
	   13'b1000_0001_11_111 : of <= tr[31] & !asy_dr[31];
	   13'b1000_0011_11_111 : of <= (!tr[31] & sim8[7] & asy_dr[31]) | (tr[31] & !sim8[7] & !asy_dr[31]);
	 endcase
	 case (ir[31:19]) // シフト命令
	   13'b1100_0001_11_100 : of <= tr[31] ^ asy_dr[31];
	 endcase
   end
   
   always @(posedge clk or negedge n_rst) begin
      if (n_rst == 1'b0) begin
	 jump <= 1'b0;
      end else if (we == 1'b1) begin
	 case (ir[31:22]) // ロード・ストア命令
	   10'b1000_1011_01 : jump <= 1'b0;
	   10'b1000_1001_01 : jump <= 1'b0;
	 endcase
	 case (ir[31:19]) // 即値ロード命令
	   13'b0110_0110_10_111 : jump <= 1'b0;
	 endcase
	 case (ir[31:22]) // レジスタ間転送命令
	   10'b1000_1001_11 : jump <= 1'b0;
	 endcase
	 case (ir[31:22]) // 二項演算命令 register - register
	   10'b0000_0001_11 : jump <= 1'b0;
	   10'b0010_1001_11 : jump <= 1'b0;
	   10'b0011_1001_11 : jump <= 1'b0;
	   10'b0010_0001_11 : jump <= 1'b0;
	   10'b0000_1001_11 : jump <= 1'b0;
	   10'b0011_0001_11 : jump <= 1'b0;
	 endcase
	 case (ir[31:19]) // 二項演算命令 register - immediate
	   13'b1000_0001_11_000 : jump <= 1'b0;
	   13'b1000_0011_11_000 : jump <= 1'b0;
	   13'b1000_0001_11_101 : jump <= 1'b0;
	   13'b1000_0011_11_101 : jump <= 1'b0;
	   13'b1000_0001_11_111 : jump <= 1'b0;
	   13'b1000_0011_11_111 : jump <= 1'b0;
	   13'b1000_0001_11_100 : jump <= 1'b0;
	   13'b1000_0011_11_100 : jump <= 1'b0;
	   13'b1000_0001_11_001 : jump <= 1'b0;
	   13'b1000_0011_11_001 : jump <= 1'b0;
	   13'b1000_0001_11_110 : jump <= 1'b0;
	   13'b1000_0011_11_110 : jump <= 1'b0;
	 endcase 
	 case (ir[31:19]) // 単項演算命令 
	   13'b1111_0111_11_011 : jump <= 1'b0;
	   13'b1111_0111_11_010 : jump <= 1'b0;
	 endcase
	 case (ir[31:19]) // シフト命令
	   13'b1100_0001_11_100 : jump <= 1'b0;
	   13'b1100_0001_11_101 : jump <= 1'b0;
	   13'b1100_0001_11_111 : jump <= 1'b0;
	 endcase
	 case (ir[31:16]) // 無条件分岐命令
	   16'b1001_0000_1110_1011 : jump <= 1'b1;
	 endcase
	 case (ir[31:16]) // 条件分岐命令
	   16'b1001_0000_0111_0000 : jump <= of;
	   16'b1001_0000_0111_0001 : jump <= ~of;
	   16'b1001_0000_0111_0010 : jump <= cf;
	   16'b1001_0000_0111_0011 : jump <= ~cf;
	   16'b1001_0000_0111_0100 : jump <= zf;
	   16'b1001_0000_0111_0101 : jump <= ~zf;
	   16'b1001_0000_0111_0110 : jump <= zf | cf;
	   16'b1001_0000_0111_0111 : jump <= ~(zf | cf);
	   16'b1001_0000_0111_1000 : jump <= sf;
	   16'b1001_0000_0111_1001 : jump <= ~sf;
	   16'b1001_0000_0111_1100 : jump <= sf ^ of;
	   16'b1001_0000_0111_1101 : jump <= ~(sf ^ of);
	   16'b1001_0000_0111_1110 : jump <= (sf ^ of) | zf;
	   16'b1001_0000_0111_1111 : jump <= ~((sf ^ of) | zf);
	 endcase
	 case (ir[31:19]) // レジスタ間接ジャンプ命令
	   13'b1111_1111_11_100 : jump <= 1'b1;
	 endcase
	 case (ir[31:19]) // レジスタ間接ジャンプ&リンク命令
	   13'b1111_1111_11_010 : jump <= 1'b1;
	 endcase
	 case (ir[31:24]) // リターン命令
	   8'b1100_0011 : jump <= 1'b1;
	 endcase
	 case (ir[31:19]) // プッシュ・ポップ命令
	   13'b1001_0000_0101_0 : jump <= 1'b0;
	   13'b1001_0000_0101_1 : jump <= 1'b0;
	 endcase
	 case (ir[31:16]) // NOP命令
	   16'b1001_0000_1001_0000 : jump <= 1'b0;
	 endcase
      end
   end

   always @(posedge clk) begin
      if (we == 1'b1) begin
	 case (ir[31:19]) // レジスタ間接ジャンプ&リンク命令
	   13'b1111_1111_11_010 : next_sp <= sp - 32'd1;
	 endcase
	 case (ir[31:24]) // リターン命令
	   8'b1100_0011 : next_sp <= sp + 32'd1;
	 endcase
	 case (ir[31:19]) // プッシュ・ポップ命令
	   13'b1001_0000_0101_0 : next_sp <= sp - 32'd1;
	   13'b1001_0000_0101_1 : next_sp <= sp + 32'd1;
	 endcase
      end
   end

   always @(posedge clk or negedge n_rst) begin
      if (n_rst == 1'b0) begin
	 sp_we <= 1'b0;
      end else if (we == 1'b1) begin
	 case (ir[31:22]) // ロード・ストア命令
	   10'b1000_1011_01 : sp_we <= 1'b0;
	   10'b1000_1001_01 : sp_we <= 1'b0;
	 endcase
	 case (ir[31:19]) // 即値ロード命令
	   13'b0110_0110_10_111 : sp_we <= 1'b0;
	 endcase
	 case (ir[31:22]) // レジスタ間転送命令
	   10'b1000_1001_11 : sp_we <= 1'b0; 
	 endcase 
	 case (ir[31:22]) // 二項演算命令 register - register
	   10'b0000_0001_11 : sp_we <= 1'b0; 
	   10'b0010_1001_11 : sp_we <= 1'b0; 
	   10'b0011_1001_11 : sp_we <= 1'b0; 
	   10'b0010_0001_11 : sp_we <= 1'b0; 
	   10'b0000_1001_11 : sp_we <= 1'b0; 
	   10'b0011_0001_11 : sp_we <= 1'b0; 
	 endcase
	 case (ir[31:19]) // 二項演算命令 register - immediate
	   13'b1000_0001_11_000 : sp_we <= 1'b0;
	   13'b1000_0011_11_000 : sp_we <= 1'b0;
	   13'b1000_0001_11_101 : sp_we <= 1'b0;
	   13'b1000_0011_11_101 : sp_we <= 1'b0;
	   13'b1000_0001_11_111 : sp_we <= 1'b0;
	   13'b1000_0011_11_111 : sp_we <= 1'b0;
	   13'b1000_0001_11_100 : sp_we <= 1'b0;
	   13'b1000_0011_11_100 : sp_we <= 1'b0;
	   13'b1000_0001_11_001 : sp_we <= 1'b0;
	   13'b1000_0011_11_001 : sp_we <= 1'b0;
	   13'b1000_0001_11_110 : sp_we <= 1'b0;
	   13'b1000_0011_11_110 : sp_we <= 1'b0;
	 endcase
	 case (ir[31:19]) // 単項演算命令
	   13'b1111_0111_11_011 : sp_we <= 1'b0;
	   13'b1111_0111_11_010 : sp_we <= 1'b0;
	 endcase 
	 case (ir[31:19]) // シフト命令
	   13'b1100_0001_11_100 : sp_we <= 1'b0;
	   13'b1100_0001_11_101 : sp_we <= 1'b0;
	   13'b1100_0001_11_111 : sp_we <= 1'b0;
	 endcase
	 case (ir[31:16]) // 無条件分岐命令
	   16'b1001_0000_1110_1011 : sp_we <= 1'b0;
	 endcase
	 case (ir[31:20]) // 条件分岐命令
	   16'b1001_0000_0111 : sp_we <= 1'b0;
	 endcase
	 case (ir[31:19]) // レジスタ間接ジャンプ命令
	   13'b1111_1111_11_100 : sp_we <= 1'b0;
	 endcase
	 case (ir[31:19]) // レジスタ間接ジャンプ&リンク命令
	   13'b1111_1111_11_010 : sp_we <= 1'b1;
	 endcase
	 case (ir[31:24]) // リターン命令
	   8'b1100_0011 : sp_we <= 1'b1;
	 endcase
	 case (ir[31:19]) // プッシュ・ポップ命令
	   13'b1001_0000_0101_0 : sp_we <= 1'b1;
	   13'b1001_0000_0101_1 : sp_we <= 1'b1;
	 endcase
	 case (ir[31:16]) // NOP命令
	   16'b1001_0000_1001_0000 : sp_we <= 1'b0;
	 endcase
      end 
   end

   assign me_ad = me_ad_gen(ir, tr, sim8, sp);

   function [31:0] me_ad_gen;
      input [31:0] ir, tr;
      input [7:0]  sim8;
      input [31:0] sp;

      begin
	 case (ir[31:22]) // ロード・ストア命令
	   10'b1000_1011_01 : me_ad_gen = tr + sim8;
	   10'b1000_1001_01 : me_ad_gen = tr + sim8;
	 endcase
	 case (ir[31:19]) // レジスタ間接ジャンプ&リンク命令
	   13'b1111_1111_11_010 : me_ad_gen = sp - 32'd1;
	 endcase
	 case (ir[31:24]) // リターン命令
	   8'b1100_0011 : me_ad_gen = sp;
	 endcase
	 case (ir[31:19]) // プッシュ・ポップ命令
	   13'b1001_0000_0101_0 : me_ad_gen = sp - 32'd1;
	   13'b1001_0000_0101_1 : me_ad_gen = sp;
	 endcase
      end
   endfunction

   assign me_wr = me_wr_gen(ir, sr, tr, pc);

   function [31:0] me_wr_gen;
      input [31:0] ir, sr, tr, pc;

      begin
	 case (ir[31:22]) // ストア命令
	   10'b1000_1001_01 : me_wr_gen = sr;
	 endcase
	 case (ir[31:19]) // レジスタ間接ジャンプ&リンク命令
	   13'b1111_1111_11_010 : me_wr_gen = pc + 32'd1;
	 endcase
	 case (ir[31:19]) // プッシュ命令
	   13'b1001_0000_0101_0 : me_wr_gen = tr;
	 endcase
      end
   endfunction
endmodule
