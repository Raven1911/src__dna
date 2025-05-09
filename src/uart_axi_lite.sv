`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/03/2025 01:41:04 PM
// Design Name: 
// Module Name: uart_axi_lite
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


module uart_axi_lite#(
    parameter ADDR_WIDTH = 32,
    parameter DATA_WIDTH = 32,
    parameter FIFO_DEPTH_BIT = 8 // bit address fifo
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

    //RX TX
    output      tx,
    input       rx
    );

    //signals to connect
    //wire [3:0] o_wen;
    wire [ADDR_WIDTH-1:0] o_addr_w;
    wire [ADDR_WIDTH-1:0] o_addr_r;                
    wire [DATA_WIDTH-1:0] o_data_w;
    wire [DATA_WIDTH-1:0] i_data_r;

    wire o_valid_w;
    wire o_valid_r;



 
    //signals register uart
    wire            wr_uart, rd_uart, wr_dvsr;
    wire            tx_full, rx_empty;
    reg     [10:0]  dvsr_reg;
    wire    [7:0]   r_data;

    //body////////////////////////////////////////////

    always @(posedge clk or negedge resetn) begin
        if(~resetn) dvsr_reg <= 0;
        else begin
            if (wr_dvsr) begin
               dvsr_reg <= o_data_w[10:0];
            end
        end
        
    end

    //decoding logic
    assign wr_dvsr = (o_valid_w && (o_addr_w == 32'h0200_2004)) ? 1 : 0;
    assign wr_uart = (o_valid_w && (o_addr_w == 32'h0200_2008)) ? 1 : 0;
    assign rd_uart = (o_valid_r && (o_addr_r == 32'h0200_200C)) ? 1 : 0;

    //slot read
    assign i_data_r = {22'h00000, tx_full, rx_empty, r_data};

    uart_unit
    #(              .DBIT('d8),       // databit
                    .SB_TICK('d16),   // tick for stop bits
                    .FIFO_W(FIFO_DEPTH_BIT)      // addr bits of FIFO
    ) 
    uart0(
        .clk(clk),
        .reset_n(resetn),
        .rd_uart(rd_uart),
        .wr_uart(wr_uart),
        .rx(rx),
        .w_data(o_data_w[7:0]),
        .dvsr(dvsr_reg),
        .tx_full(tx_full),
        .rx_empty(rx_empty),
        .tx(tx),
        .r_data(r_data)
    );

    

    // Instantiate axi interface module
    axi_lite_interface #(
        .ADDR_WIDTH(ADDR_WIDTH),
        .DATA_WIDTH(DATA_WIDTH)
    ) axi_adapter(
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
        //.o_wen(o_wen),
        .o_addr_w(o_addr_w),
        .o_addr_r(o_addr_r),             
        .o_data_w(o_data_w),
        .i_data_r(i_data_r),
        .o_valid_w(o_valid_w),
        .o_valid_r(o_valid_r)
    );




endmodule
