`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Module: DNA_mem
// Description: Trích 2 bit lần lượt từ ref_32_i và read_32_i
//////////////////////////////////////////////////////////////////////////////////

module DNA_mem(
    input clk,
    input rst,
    input en,
    input en_read,
    input en_ref,
    input [31:0] ref_32_i,
    input [31:0] read_32_i,
    output [1:0] read_2_o,
    output [1:0] ref_2_o
);

    reg [31:0] ref_32_reg, read_32_reg;
    reg [3:0] idx;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            ref_32_reg <= 32'hFFFF_FFFF;  // Hoặc 0 nếu bạn muốn khởi tạo trắng
            read_32_reg <= 32'h0000_0000;
            idx <= 4'd0;
        end else if (en) begin
            if(en_ref) ref_32_reg <= ref_32_i;
            if(en_read) read_32_reg <= read_32_i;
            idx <= idx - 1'b1; // reset bộ đếm về 0 khi load dữ liệu mới
        end
    end

    assign read_2_o = read_32_reg[2*idx +: 2];
    assign ref_2_o  = ref_32_reg[2*idx +: 2];

endmodule
