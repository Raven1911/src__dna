`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/07/2025 01:09:19 PM
// Design Name: 
// Module Name: dna_core_axi_lite
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


module dna_core_axi_lite#(
    parameter ADDR_WIDTH = 32,
    parameter DATA_WIDTH = 32,

    parameter addr_start_read = 0,
    parameter addr_start_ref = 0,
    parameter addr_end_ref = 'd127,
    parameter addr_start_matrix = 0,
    parameter addr_end_matrix = 'd127
)(
    input clk,
    input resetn,

    //AXI-Lite Write Address Channels
    input [ADDR_WIDTH-1:0]          i_axi_awaddr,
    input                           i_axi_awvalid,
    output wire                     o_axi_awready,

    //AXI-Lite Write Data Channel
    input [DATA_WIDTH-1:0]          i_axi_wdata,
    input [3:0]                     i_axi_wstrb,
    input                           i_axi_wvalid,
    output wire                     o_axi_wready,

    //AXI-Lite Write Response Channels
    output wire                     o_axi_bvalid,
    input                           i_axi_bready,

    //AXI-Lite Read Address Channels
    input [ADDR_WIDTH-1:0]          i_axi_araddr,
    input                           i_axi_arvalid,
    output wire                     o_axi_arready,

    //AXI4-Lite Read Data Channel
    output wire [DATA_WIDTH-1:0]    o_axi_rdata,
    output wire                     o_axi_rvalid,
    input                           i_axi_rready,


    input [DATA_WIDTH-1:0]      ref_32_i,
    input [DATA_WIDTH-1:0]      read_32_i,
    output                      W_matrix,

    output [ADDR_WIDTH-1:0]     addr_ref_o,
    output [ADDR_WIDTH-1:0]     addr_read_o,

    output [DATA_WIDTH-1:0]     addr_matrix_o,
    output [DATA_WIDTH-1:0]     dout_matrix0,
    output [DATA_WIDTH-1:0]     dout_matrix1,
    output [DATA_WIDTH-1:0]     dout_matrix2,
    output [DATA_WIDTH-1:0]     dout_matrix3,
    output [DATA_WIDTH-1:0]     dout_matrix4,
    output [DATA_WIDTH-1:0]     dout_matrix5,
    output [DATA_WIDTH-1:0]     dout_matrix6,
    output [DATA_WIDTH-1:0]     dout_matrix7,
    output [DATA_WIDTH-1:0]     dout_matrix8,
    output [DATA_WIDTH-1:0]     dout_matrix9,
    output [DATA_WIDTH-1:0]     dout_matrix10,
    output [DATA_WIDTH-1:0]     dout_matrix11,
    output [DATA_WIDTH-1:0]     dout_matrix12,
    output [DATA_WIDTH-1:0]     dout_matrix13,
    output [DATA_WIDTH-1:0]     dout_matrix14,
    output [DATA_WIDTH-1:0]     dout_matrix15


    );


    //signals to connect
    //wire [3:0] o_wen;
    wire [ADDR_WIDTH-1:0] o_addr_w;
    wire [ADDR_WIDTH-1:0] o_addr_r;                
    wire [DATA_WIDTH-1:0] o_data_w;
    wire [DATA_WIDTH-1:0] i_data_r;

    wire o_valid_w;
    wire o_valid_r;

    //config regs
    wire w_start;
    wire w_config;
    wire en_o;
    wire ref_empty;
    wire matrix_full;



    reg            start_reg;
    reg     [6:0]  addr_width_read;
    reg     [2:0]  match;
    reg     [2:0]  mismatch;
    reg     [2:0]  gap;

    //decoding logic
    assign w_start  =   (o_valid_w && (o_addr_w == 32'h0200_4000)) ? 1 : 0;
    assign w_config =   (o_valid_w && (o_addr_w == 32'h0200_4004)) ? 1 : 0;
    // assign r_status =   (o_valid_r && (o_addr_r == 32'h0200_400C)) ? 1 : 0;
    assign i_data_r = {29'b0, matrix_full, ref_empty, en_o};

    //reg read


    always @(posedge clk or negedge resetn) begin
        if(~resetn) begin
                start_reg <= 0;
                addr_width_read <= 0;
                match <= 0;
                mismatch <= 0;
                gap <= 0;
        end

        else begin
            if(w_start) begin
                start_reg <= o_data_w[0];
            end

            if (w_config) begin
                addr_width_read <= o_data_w[6:0];
                match           <= o_data_w[9:7];
                mismatch        <= o_data_w[12:10];
                gap             <= o_data_w[15:13];
            end
        end

    end





    // Instantiate axi interface module
    dna_ip_axi_lite_interface #(
        .ADDR_WIDTH(ADDR_WIDTH),
        .DATA_WIDTH(DATA_WIDTH)
    ) dna_ip_axi_adapter(
        .clk(clk),
        .resetn(resetn),

        //AXI-Lite Write Address Channels
        .i_axi_awaddr(i_axi_awaddr),
        .i_axi_awvalid(i_axi_awvalid),
        .o_axi_awready(o_axi_awready),

        //AXI-Lite Write Data Channel
        .i_axi_wdata(i_axi_wdata),
        .i_axi_wstrb(i_axi_wstrb),
        .i_axi_wvalid(i_axi_wvalid),
        .o_axi_wready(o_axi_wready),

        //AXI-Lite Write Response Channels
        .o_axi_bvalid(o_axi_bvalid),
        .i_axi_bready(i_axi_bready),

        //AXI-Lite Read Address Channels
        .i_axi_araddr(i_axi_araddr),
        .i_axi_arvalid(i_axi_arvalid),
        .o_axi_arready(o_axi_arready),

        //AXI4-Lite Read Data Channel
        .o_axi_rdata(o_axi_rdata),
        .o_axi_rvalid(o_axi_rvalid),
        .i_axi_rready(i_axi_rready),

        //channel for slave
        .o_wen(),
        .o_addr_w(o_addr_w),
        .o_addr_r(o_addr_r),             
        .o_data_w(o_data_w),
        .i_data_r(i_data_r),
        .o_valid_w(o_valid_w),
        .o_valid_r(o_valid_r)
    );



    DNA_top#(
        .addr_start_read(addr_start_read),
        .addr_start_ref(addr_start_ref),
        .addr_end_ref(addr_end_ref),
        .addr_start_matrix(addr_start_matrix),
        .addr_end_matrix(addr_end_matrix)
    ) DNA_core_unit(
    .clk(clk),
    .rst(~resetn),
    .start_i(start_reg),
    .ADDR_WIDTH(addr_width_read),
    .match(match),
    .mismatch(mismatch),
    .gap(gap),
    .ref_32_i(ref_32_i),
    .read_32_i(read_32_i),
    .en_o(en_o),
    .ref_empty(ref_empty),
    .matrix_full(matrix_full),
    .W_matrix(W_matrix),
    .addr_ref_o(addr_ref_o),
    .addr_read_o(addr_read_o),
    .addr_matrix_o(addr_matrix_o),
    .matrix_o0(dout_matrix0),
    .matrix_o1(dout_matrix1),
    .matrix_o2(dout_matrix2),
    .matrix_o3(dout_matrix3),
    .matrix_o4(dout_matrix4),
    .matrix_o5(dout_matrix5),
    .matrix_o6(dout_matrix6),
    .matrix_o7(dout_matrix7),
    .matrix_o8(dout_matrix8),
    .matrix_o9(dout_matrix9),
    .matrix_o10(dout_matrix10),
    .matrix_o11(dout_matrix11),
    .matrix_o12(dout_matrix12),
    .matrix_o13(dout_matrix13),
    .matrix_o14(dout_matrix14),
    .matrix_o15(dout_matrix15)
//    output reg [3:0] count, 
//    output reg [31:0] read_prv_i, read_i, score_i, i_i
    );

endmodule
