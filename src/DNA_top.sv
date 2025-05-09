`timescale 1ns / 1ps
  //////////////////////////////////////////////////////////////////////////////////
  // Company: 
  // Engineer: 
  // 
  // Create Date: 05/03/2025 03:47:37 PM
  // Design Name: 
  // Module Name: DNA_top
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

  module DNA_top#(
      parameter addr_start_read = 0,
      parameter addr_start_ref = 0,
      parameter addr_end_ref = 1,
      parameter addr_start_matrix = 0,
      parameter addr_end_matrix = 30
  )(
      input clk,
      input rst,
      input start_i,
      input [6:0] ADDR_WIDTH,
      input [2:0] match,
      input [2:0] mismatch,
      input [2:0] gap,
      input [31:0] ref_32_i,
      input [31:0] read_32_i,
      output en_o,
      output reg ref_empty,
      output reg matrix_full,
      output W_matrix,
      output [31:0] addr_ref_o,
      output [31:0] addr_read_o,
      output [31:0] addr_matrix_o,
      output reg [31:0] matrix_o0,
      output reg [31:0] matrix_o1,
      output reg [31:0] matrix_o2,
      output reg [31:0] matrix_o3,
      output reg [31:0] matrix_o4,
      output reg [31:0] matrix_o5,
      output reg [31:0] matrix_o6,
      output reg [31:0] matrix_o7,
      output reg [31:0] matrix_o8,
      output reg [31:0] matrix_o9,
      output reg [31:0] matrix_o10,
      output reg [31:0] matrix_o11,
      output reg [31:0] matrix_o12,
      output reg [31:0] matrix_o13,
      output reg [31:0] matrix_o14,
      output reg [31:0] matrix_o15
  );

      reg [31:0] addr_ref_reg, addr_read_reg, addr_matrix_reg;
      reg W_matrix1;
      reg nxt;
      reg nxt1;
      reg R_ref, R_read;
      reg [3:0] count;
      reg [31:0] addr_ref_next, addr_read_next, addr_matrix_next;
      reg setup;
      wire [1:0] read_2, ref_2;
      reg [1:0] count_1_times;
      wire [31:0] matrix1_o0 [15:0];
      wire [31:0] matrix1_o1 [15:0];
      wire [31:0] matrix1_o2 [15:0];
      wire [31:0] matrix1_o3 [15:0];
      wire [31:0] matrix1_o4 [15:0];
      wire [31:0] matrix1_o5 [15:0];
      wire [31:0] matrix1_o6 [15:0];
      wire [31:0] matrix1_o7 [15:0];
      wire [31:0] matrix1_o8 [15:0];
      wire [31:0] matrix1_o9 [15:0];
      wire [31:0] matrix1_o10 [15:0];
      wire [31:0] matrix1_o11 [15:0];
      wire [31:0] matrix1_o12 [15:0];
      wire [31:0] matrix1_o13 [15:0];
      wire [31:0] matrix1_o14 [15:0];
      wire [31:0] matrix1_o15 [15:0];
      wire [1:0] ref_dna [15:0];
      wire [31:0] score [15:0];
      wire signal, signal_o;
      wire start_o; // Khai báo start_o rõ ràng

      assign signal = (addr_ref_reg == addr_start_ref && addr_read_reg == addr_start_read) || addr_matrix_reg == addr_start_matrix;
      assign addr_ref_o = addr_ref_reg;
      assign addr_read_o = addr_read_reg;
      assign addr_matrix_o = addr_matrix_reg;
      assign W_matrix = W_matrix1 & en_o;

      enable e(
          .clk(clk),
          .rst(rst),
          .start(start_o),
          .signal(signal_o),
          .en(en_o)
      );
      posedge_detection detect0(
          .clk(clk),
          .rst_i(rst),
          .signal_i(signal),
          .signal_o(signal_o)
      );
      posedge_detection detect1(
          .clk(clk),
          .rst_i(rst),
          .signal_i(start_i),
          .signal_o(start_o)
      );
      DNA_mem MEM (
          .clk(clk),
          .rst(rst),
          .en(en_o),
          .en_read(R_read),
          .en_ref(R_ref),
          .ref_32_i(ref_32_i),
          .read_32_i(read_32_i),
          .read_2_o(read_2),
          .ref_2_o(ref_2)
      );
      generate
          genvar i;
          for(i = 0; i < 16; i = i + 1) begin: dataGen
              DNA_PE #(.ID(i)) PE (
                  .clk(clk),
                  .rst(rst),
                  .en_i(en_o),
                  .ADDR_WIDTH(ADDR_WIDTH),
                  .read_2_i(read_2),
                  .ref_2_i(i == 0 ? ref_2 : ref_dna[i]),
                  .score_i(i == 0 ? score[0] & {32{nxt1}} : score[i]),
                  .match(match),
                  .mismatch(mismatch),
                  .gap(gap),
                  .score_o(score[(i + 1) % 16]),
                  .ref_2_o(ref_dna[(i + 1) % 16]),
                  .matrix_o0(matrix1_o0[i]), .matrix_o1(matrix1_o1[i]), .matrix_o2(matrix1_o2[i]), .matrix_o3(matrix1_o3[i]),
                  .matrix_o4(matrix1_o4[i]), .matrix_o5(matrix1_o5[i]), .matrix_o6(matrix1_o6[i]), .matrix_o7(matrix1_o7[i]),
                  .matrix_o8(matrix1_o8[i]), .matrix_o9(matrix1_o9[i]), .matrix_o10(matrix1_o10[i]), .matrix_o11(matrix1_o11[i]),
                  .matrix_o12(matrix1_o12[i]), .matrix_o13(matrix1_o13[i]), .matrix_o14(matrix1_o14[i]), .matrix_o15(matrix1_o15[i])
              );
          end
      endgenerate
      always @(*) begin
          matrix_o0 = matrix1_o0[|count ? count - 'b1 : 15];
          matrix_o1 = matrix1_o1[|count ? count - 'b1 : 15];
          matrix_o2 = matrix1_o2[|count ? count - 'b1 : 15];
          matrix_o3 = matrix1_o3[|count ? count - 'b1 : 15];
          matrix_o4 = matrix1_o4[|count ? count - 'b1 : 15];
          matrix_o5 = matrix1_o5[|count ? count - 'b1 : 15];
          matrix_o6 = matrix1_o6[|count ? count - 'b1 : 15];
          matrix_o7 = matrix1_o7[|count ? count - 'b1 : 15];
          matrix_o8 = matrix1_o8[|count ? count - 'b1 : 15];
          matrix_o9 = matrix1_o9[|count ? count - 'b1 : 15];
          matrix_o10 = matrix1_o10[|count ? count - 'b1 : 15];
          matrix_o11 = matrix1_o11[|count ? count - 'b1 : 15];
          matrix_o12 = matrix1_o12[|count ? count - 'b1 : 15];
          matrix_o13 = matrix1_o13[|count ? count - 'b1 : 15];
          matrix_o14 = matrix1_o14[|count ? count - 'b1 : 15];
          matrix_o15 = matrix1_o15[|count ? count - 'b1 : 15];
          addr_ref_next = addr_ref_reg == addr_end_ref ? addr_start_ref : addr_ref_reg + 'b1;
          addr_read_next = addr_read_reg == (addr_start_read + 2**ADDR_WIDTH - 1) ? addr_start_read : addr_read_reg + 'b1;
          addr_matrix_next = addr_matrix_reg == addr_end_matrix ? addr_start_matrix : addr_matrix_reg + 'd1;
          R_read = count == 'd15;
          R_ref = (addr_read_reg == addr_start_read) && R_read;        
      end
      always @(posedge clk, posedge rst) begin
          if(rst) begin 
              count <= 'd15;
              addr_ref_reg <= addr_start_ref;
              addr_read_reg <= addr_start_read;
              addr_matrix_reg <= addr_start_matrix;
              count_1_times <= 2'd0;
              W_matrix1 <= 1'b0;
              nxt <= 1'b0;
              nxt1 <= 1'b0;
              setup <= 1'b0;
              matrix_full <= 1'b0;
              ref_empty <= 1'b0;
          end else if(en_o) begin
              count <= count + 1'b1;
              nxt <= ~(addr_read_reg == (addr_start_read + 1)) && ~(ADDR_WIDTH == 0);
              nxt1 <= nxt;
              if(R_ref) addr_ref_reg <= addr_ref_next;
              if(R_read) addr_read_reg <= addr_read_next;
              if (count == 4'd15) count_1_times <= count_1_times + 1'b1;
              if(count_1_times == 2'd2) W_matrix1 <= 1'b1;
              if(W_matrix1) setup <= 1'b1;
              if(W_matrix) addr_matrix_reg <= addr_matrix_next;
              matrix_full <= addr_matrix_reg == addr_start_matrix && setup;
              ref_empty <= addr_ref_reg == addr_start_ref && addr_read_reg == addr_start_read && setup;
          end
      end
  endmodule