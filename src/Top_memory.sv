`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/06/2025 10:43:41 PM
// Design Name: 
// Module Name: Top_memory
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


module Top_memory#(
    parameter MEM_SIZE = 512, // 500B
    parameter MEM_SIZE_RR = 512,
    parameter ADDR_WIDTH = 32,
    parameter DATA_WIDTH = 32

)(  
    input                                   clk,
    input                                   we_read, we_ref,
    input   [ADDR_WIDTH-1:0]                addr_read, addr_ref,
    input   [ADDR_WIDTH-1:0]                addw_read, addw_ref,
    input   [DATA_WIDTH-1:0]                din_read, din_ref,
    output  [DATA_WIDTH-1:0]                dout_read, dout_ref,

    input [15:0]           we_matrix,



    input [ADDR_WIDTH-1:0] addr_matrix0,
    input [ADDR_WIDTH-1:0] addr_matrix1,
    input [ADDR_WIDTH-1:0] addr_matrix2,
    input [ADDR_WIDTH-1:0] addr_matrix3,
    input [ADDR_WIDTH-1:0] addr_matrix4,
    input [ADDR_WIDTH-1:0] addr_matrix5,
    input [ADDR_WIDTH-1:0] addr_matrix6,
    input [ADDR_WIDTH-1:0] addr_matrix7,
    input [ADDR_WIDTH-1:0] addr_matrix8,
    input [ADDR_WIDTH-1:0] addr_matrix9,
    input [ADDR_WIDTH-1:0] addr_matrix10,
    input [ADDR_WIDTH-1:0] addr_matrix11,
    input [ADDR_WIDTH-1:0] addr_matrix12,
    input [ADDR_WIDTH-1:0] addr_matrix13,
    input [ADDR_WIDTH-1:0] addr_matrix14,
    input [ADDR_WIDTH-1:0] addr_matrix15,

    input [ADDR_WIDTH-1:0] addw_matrix0,
    input [ADDR_WIDTH-1:0] addw_matrix1,
    input [ADDR_WIDTH-1:0] addw_matrix2,
    input [ADDR_WIDTH-1:0] addw_matrix3,
    input [ADDR_WIDTH-1:0] addw_matrix4,
    input [ADDR_WIDTH-1:0] addw_matrix5,
    input [ADDR_WIDTH-1:0] addw_matrix6,
    input [ADDR_WIDTH-1:0] addw_matrix7,
    input [ADDR_WIDTH-1:0] addw_matrix8,
    input [ADDR_WIDTH-1:0] addw_matrix9,
    input [ADDR_WIDTH-1:0] addw_matrix10,
    input [ADDR_WIDTH-1:0] addw_matrix11,
    input [ADDR_WIDTH-1:0] addw_matrix12,
    input [ADDR_WIDTH-1:0] addw_matrix13,
    input [ADDR_WIDTH-1:0] addw_matrix14,
    input [ADDR_WIDTH-1:0] addw_matrix15,


    input [DATA_WIDTH-1:0] din_matrix0,
    input [DATA_WIDTH-1:0] din_matrix1,
    input [DATA_WIDTH-1:0] din_matrix2,
    input [DATA_WIDTH-1:0] din_matrix3,
    input [DATA_WIDTH-1:0] din_matrix4,
    input [DATA_WIDTH-1:0] din_matrix5,
    input [DATA_WIDTH-1:0] din_matrix6,
    input [DATA_WIDTH-1:0] din_matrix7,
    input [DATA_WIDTH-1:0] din_matrix8,
    input [DATA_WIDTH-1:0] din_matrix9,
    input [DATA_WIDTH-1:0] din_matrix10,
    input [DATA_WIDTH-1:0] din_matrix11,
    input [DATA_WIDTH-1:0] din_matrix12,
    input [DATA_WIDTH-1:0] din_matrix13,
    input [DATA_WIDTH-1:0] din_matrix14,
    input [DATA_WIDTH-1:0] din_matrix15,

    output [DATA_WIDTH-1:0] dout_matrix0,
    output [DATA_WIDTH-1:0] dout_matrix1,
    output [DATA_WIDTH-1:0] dout_matrix2,
    output [DATA_WIDTH-1:0] dout_matrix3,
    output [DATA_WIDTH-1:0] dout_matrix4,
    output [DATA_WIDTH-1:0] dout_matrix5,
    output [DATA_WIDTH-1:0] dout_matrix6,
    output [DATA_WIDTH-1:0] dout_matrix7,
    output [DATA_WIDTH-1:0] dout_matrix8,
    output [DATA_WIDTH-1:0] dout_matrix9,
    output [DATA_WIDTH-1:0] dout_matrix10,
    output [DATA_WIDTH-1:0] dout_matrix11,
    output [DATA_WIDTH-1:0] dout_matrix12,
    output [DATA_WIDTH-1:0] dout_matrix13,
    output [DATA_WIDTH-1:0] dout_matrix14,
    output [DATA_WIDTH-1:0] dout_matrix15

    );

    mem_reg #(
        .MEM_SIZE(MEM_SIZE),
        .ADDR_WIDTH(ADDR_WIDTH),
        .DATA_WIDTH(DATA_WIDTH)
    ) mem_read (
        .clk(clk),
        .we_A(we_read), // Word-aligned address (ignore lower 2 bits)
        .addr_A(addr_read), // Word-aligned address (ignore lower 2 bits)
        .addw_A(addw_read),
        .din_A(din_read),
        .dout_A(dout_read)
    );

    mem_reg #(
        .MEM_SIZE(MEM_SIZE),
        .ADDR_WIDTH(ADDR_WIDTH),
        .DATA_WIDTH(DATA_WIDTH)
    ) mem_ref (
        .clk(clk),
        .we_A(we_ref), // Word-aligned address (ignore lower 2 bits)
        .addr_A(addr_ref), // Word-aligned address (ignore lower 2 bits)
        .addw_A(addw_ref),
        .din_A(din_ref),
        .dout_A(dout_ref)
    );


    mem_reg #(
        .MEM_SIZE(MEM_SIZE),
        .ADDR_WIDTH(ADDR_WIDTH),
        .DATA_WIDTH(DATA_WIDTH)
    ) mem_matrix0 (
        .clk(clk),
        .we_A(we_matrix[0]), // Word-aligned address (ignore lower 2 bits)
        .addr_A(addr_matrix0), // Word-aligned address (ignore lower 2 bits)
        .addw_A(addw_matrix0),
        .din_A(din_matrix0),
        .dout_A(dout_matrix0)
    );

    mem_reg #(
        .MEM_SIZE(MEM_SIZE),
        .ADDR_WIDTH(ADDR_WIDTH),
        .DATA_WIDTH(DATA_WIDTH)
    ) mem_matrix1 (
        .clk(clk),
        .we_A(we_matrix[1]), // Word-aligned address (ignore lower 2 bits)
        .addr_A(addr_matrix1), // Word-aligned address (ignore lower 2 bits)
        .addw_A(addw_matrix1),
        .din_A(din_matrix1),
        .dout_A(dout_matrix1)
    );

    mem_reg #(
        .MEM_SIZE(MEM_SIZE),
        .ADDR_WIDTH(ADDR_WIDTH),
        .DATA_WIDTH(DATA_WIDTH)
    ) mem_matrix2 (
        .clk(clk),
        .we_A(we_matrix[2]), // Word-aligned address (ignore lower 2 bits)
        .addr_A(addr_matrix2), // Word-aligned address (ignore lower 2 bits)
        .addw_A(addw_matrix2),
        .din_A(din_matrix2),
        .dout_A(dout_matrix2)
    );

    mem_reg #(
        .MEM_SIZE(MEM_SIZE),
        .ADDR_WIDTH(ADDR_WIDTH),
        .DATA_WIDTH(DATA_WIDTH)
    ) mem_matrix3 (
        .clk(clk),
        .we_A(we_matrix[3]), // Word-aligned address (ignore lower 2 bits)
        .addr_A(addr_matrix3), // Word-aligned address (ignore lower 2 bits)
        .addw_A(addw_matrix3),
        .din_A(din_matrix3),
        .dout_A(dout_matrix3)
    );

    mem_reg #(
        .MEM_SIZE(MEM_SIZE),
        .ADDR_WIDTH(ADDR_WIDTH),
        .DATA_WIDTH(DATA_WIDTH)
    ) mem_matrix4 (
        .clk(clk),
        .we_A(we_matrix[4]), // Word-aligned address (ignore lower 2 bits)
        .addr_A(addr_matrix4), // Word-aligned address (ignore lower 2 bits)
        .addw_A(addw_matrix4),
        .din_A(din_matrix4),
        .dout_A(dout_matrix4)
    );

    mem_reg #(
        .MEM_SIZE(MEM_SIZE),
        .ADDR_WIDTH(ADDR_WIDTH),
        .DATA_WIDTH(DATA_WIDTH)
    ) mem_matrix5 (
        .clk(clk),
        .we_A(we_matrix[5]), // Word-aligned address (ignore lower 2 bits)
        .addr_A(addr_matrix5), // Word-aligned address (ignore lower 2 bits)
        .addw_A(addw_matrix5),
        .din_A(din_matrix5),
        .dout_A(dout_matrix5)
    );

    mem_reg #(
        .MEM_SIZE(MEM_SIZE),
        .ADDR_WIDTH(ADDR_WIDTH),
        .DATA_WIDTH(DATA_WIDTH)
    ) mem_matrix6 (
        .clk(clk),
        .we_A(we_matrix[6]), // Word-aligned address (ignore lower 2 bits)
        .addr_A(addr_matrix6), // Word-aligned address (ignore lower 2 bits)
        .addw_A(addw_matrix6),
        .din_A(din_matrix6),
        .dout_A(dout_matrix6)
    );

    mem_reg #(
        .MEM_SIZE(MEM_SIZE),
        .ADDR_WIDTH(ADDR_WIDTH),
        .DATA_WIDTH(DATA_WIDTH)
    ) mem_matrix7 (
        .clk(clk),
        .we_A(we_matrix[7]), // Word-aligned address (ignore lower 2 bits)
        .addr_A(addr_matrix7), // Word-aligned address (ignore lower 2 bits)
        .addw_A(addw_matrix7),
        .din_A(din_matrix7),
        .dout_A(dout_matrix7)
    );

    mem_reg #(
        .MEM_SIZE(MEM_SIZE),
        .ADDR_WIDTH(ADDR_WIDTH),
        .DATA_WIDTH(DATA_WIDTH)
    ) mem_matrix8 (
        .clk(clk),
        .we_A(we_matrix[8]), // Word-aligned address (ignore lower 2 bits)
        .addr_A(addr_matrix8), // Word-aligned address (ignore lower 2 bits)
        .addw_A(addw_matrix8),
        .din_A(din_matrix8),
        .dout_A(dout_matrix8)
    );

    mem_reg #(
        .MEM_SIZE(MEM_SIZE),
        .ADDR_WIDTH(ADDR_WIDTH),
        .DATA_WIDTH(DATA_WIDTH)
    ) mem_matrix9 (
        .clk(clk),
        .we_A(we_matrix[9]), // Word-aligned address (ignore lower 2 bits)
        .addr_A(addr_matrix9), // Word-aligned address (ignore lower 2 bits)
        .addw_A(addw_matrix9),
        .din_A(din_matrix9),
        .dout_A(dout_matrix9)
    );

    mem_reg #(
        .MEM_SIZE(MEM_SIZE),
        .ADDR_WIDTH(ADDR_WIDTH),
        .DATA_WIDTH(DATA_WIDTH)
    ) mem_matrix10 (
        .clk(clk),
        .we_A(we_matrix[10]), // Word-aligned address (ignore lower 2 bits)
        .addr_A(addr_matrix10), // Word-aligned address (ignore lower 2 bits)
        .addw_A(addw_matrix10),
        .din_A(din_matrix10),
        .dout_A(dout_matrix10)
    );

    mem_reg #(
        .MEM_SIZE(MEM_SIZE),
        .ADDR_WIDTH(ADDR_WIDTH),
        .DATA_WIDTH(DATA_WIDTH)
    ) mem_matrix11 (
        .clk(clk),
        .we_A(we_matrix[11]), // Word-aligned address (ignore lower 2 bits)
        .addr_A(addr_matrix11), // Word-aligned address (ignore lower 2 bits)
        .addw_A(addw_matrix11),
        .din_A(din_matrix11),
        .dout_A(dout_matrix11)
    );

    mem_reg #(
        .MEM_SIZE(MEM_SIZE),
        .ADDR_WIDTH(ADDR_WIDTH),
        .DATA_WIDTH(DATA_WIDTH)
    ) mem_matrix12 (
        .clk(clk),
        .we_A(we_matrix[12]), // Word-aligned address (ignore lower 2 bits)
        .addr_A(addr_matrix12), // Word-aligned address (ignore lower 2 bits)
        .addw_A(addw_matrix12),
        .din_A(din_matrix12),
        .dout_A(dout_matrix12)
    );

    mem_reg #(
        .MEM_SIZE(MEM_SIZE),
        .ADDR_WIDTH(ADDR_WIDTH),
        .DATA_WIDTH(DATA_WIDTH)
    ) mem_matrix13 (
        .clk(clk),
        .we_A(we_matrix[13]), // Word-aligned address (ignore lower 2 bits)
        .addr_A(addr_matrix13), // Word-aligned address (ignore lower 2 bits)
        .addw_A(addw_matrix13),
        .din_A(din_matrix13),
        .dout_A(dout_matrix13)
    );

    mem_reg #(
        .MEM_SIZE(MEM_SIZE),
        .ADDR_WIDTH(ADDR_WIDTH),
        .DATA_WIDTH(DATA_WIDTH)
    ) mem_matrix14 (
        .clk(clk),
        .we_A(we_matrix[14]), // Word-aligned address (ignore lower 2 bits)
        .addr_A(addr_matrix14), // Word-aligned address (ignore lower 2 bits)
        .addw_A(addw_matrix14),
        .din_A(din_matrix14),
        .dout_A(dout_matrix14)
    );

    mem_reg #(
        .MEM_SIZE(MEM_SIZE),
        .ADDR_WIDTH(ADDR_WIDTH),
        .DATA_WIDTH(DATA_WIDTH)
    ) mem_matrix15 (
        .clk(clk),
        .we_A(we_matrix[15]), // Word-aligned address (ignore lower 2 bits)
        .addr_A(addr_matrix15), // Word-aligned address (ignore lower 2 bits)
        .addw_A(addw_matrix15),
        .din_A(din_matrix15),
        .dout_A(dout_matrix15)
    );

endmodule
