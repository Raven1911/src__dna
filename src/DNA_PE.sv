`timescale 1ns / 1ps
  //////////////////////////////////////////////////////////////////////////////////
  // Company: 
  // Engineer: 
  // 
  // Create Date: 05/03/2025 03:47:37 PM
  // Design Name: 
  // Module Name: DNA_PE
  // Project Name: 
  // Target Devices: 
  // Tool Versions: 
  // Description: 
  // 
  // Dependencies: 
  // 
  // Revision:
  // Revision 0.01 - File Created
  // Additional Comments:
  // 
  //////////////////////////////////////////////////////////////////////////////////

  module DNA_PE #(parameter ID = 32'b0)(
      input clk,
      input rst,
      input en_i,
      input [6:0] ADDR_WIDTH,
      input [1:0] read_2_i,
      input [1:0] ref_2_i,
      input [31:0] score_i,
      input [2:0] match,
      input [2:0] mismatch,
      input [2:0] gap,
      output [31:0] score_o,
      output [1:0] ref_2_o,
      output [31:0] matrix_o0,
      output [31:0] matrix_o1,
      output [31:0] matrix_o2,
      output [31:0] matrix_o3,
      output [31:0] matrix_o4,
      output [31:0] matrix_o5,
      output [31:0] matrix_o6,
      output [31:0] matrix_o7,
      output [31:0] matrix_o8,
      output [31:0] matrix_o9,
      output [31:0] matrix_o10,
      output [31:0] matrix_o11,
      output [31:0] matrix_o12,
      output [31:0] matrix_o13,
      output [31:0] matrix_o14,
      output [31:0] matrix_o15
  );
      reg [1:0] ref_reg;
      reg [1:0] read_reg;
      reg [31:0] sc_reg;
      reg [31:0] score [15:0];
      reg [3:0] i;
      reg [3:0] i_next;
      reg [31:0] a;
      reg [31:0] b;
      reg [31:0] c;
      reg [31:0] d;
      reg [31:0] read_prv_reg;
      reg [31:0] read_score_reg;
      wire [31:0] read_prv, read;
      reg [31:0] tmpa;
      reg [31:0] tmpb;
      reg [31:0] tmpd;
      wire [31:0] we_matrix; // Khai báo we_matrix
      reg [31:0] tmp_score;
      
      assign we_matrix = 1 << i; // Giữ gán, nhưng có thể comment nếu không dùng
      assign score_o = tmp_score;
      assign ref_2_o = ref_reg;
      assign matrix_o0 = score[0];
      assign matrix_o1 = score[1];
      assign matrix_o2 = score[2];
      assign matrix_o3 = score[3];
      assign matrix_o4 = score[4];
      assign matrix_o5 = score[5];
      assign matrix_o6 = score[6];
      assign matrix_o7 = score[7];
      assign matrix_o8 = score[8];
      assign matrix_o9 = score[9];
      assign matrix_o10 = score[10];
      assign matrix_o11 = score[11];
      assign matrix_o12 = score[12];
      assign matrix_o13 = score[13];
      assign matrix_o14 = score[14];
      assign matrix_o15 = score[15];

      FIFO_dna #(.DATA_WIDTH(32))
          prv_sc_mem (
              .clk(clk), .reset(rst), .en(en_i), .ADDR_WIDTH(ADDR_WIDTH),
              .wr(i == 15), .w_data(score_i), 
              .rd(i == 0), .r_data(read_prv)
          );
      FIFO_dna #(.DATA_WIDTH(32))
          sc_mem (
              .clk(clk), .reset(rst), .en(en_i), .ADDR_WIDTH(ADDR_WIDTH),
              .wr(i == 5), .w_data({score[15]}),
              .rd(i == 0), .r_data(read)
          );

      always @(*) begin
          tmpa = (i == 4'd0) ? read_prv_reg : sc_reg;
          a = (ref_reg == read_reg) ? tmpa + match : ((tmpa > mismatch) ? tmpa - mismatch : 32'd0);
          tmpb = (i == 0) ? read_score_reg : tmp_score;
          b = tmpb > gap ? tmpb - gap : 32'd0;
          c = (score_i > gap) ? score_i - gap : 32'd0;
          tmpd = (a > b) ? a : b;
          d = (tmpd > c) ? tmpd : c;
          i_next = i == 4'd15 ? 4'd0 : i + 1;
      end
      always @(posedge clk, posedge rst) begin
          if(rst) begin
              ref_reg <= 2'b11;
              read_reg <= 2'b00;
              sc_reg <= 32'd0;
              i <= ID < 4'd15 ? 4'd14 - ID : 15;
              score[0] <= 32'd0;
              score[1] <= 32'd0;
              score[2] <= 32'd0;
              score[3] <= 32'd0;
              score[4] <= 32'd0;
              score[5] <= 32'd0;
              score[6] <= 32'd0;
              score[7] <= 32'd0;
              score[8] <= 32'd0;
              score[9] <= 32'd0;
              score[10] <= 32'd0;
              score[11] <= 32'd0;
              score[12] <= 32'd0;
              score[13] <= 32'd0;
              score[14] <= 32'd0;
              score[15] <= 32'd0;
              tmp_score <= 32'd0;
              read_score_reg <= 32'd0;
              read_prv_reg <= 32'd0;
          end else if(en_i) begin
              ref_reg <= ref_2_i;
              if(i == 'd15) read_reg <= read_2_i;
              sc_reg <= score_i;
              score[i] <= d;
              i <= i_next;
              read_score_reg <= read;
              read_prv_reg <= read_prv;
              tmp_score <= d;
          end
      end
  endmodule