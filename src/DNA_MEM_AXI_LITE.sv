`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/06/2025 11:39:55 PM
// Design Name: 
// Module Name: DNA_MEM_AXI_LITE
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


module DNA_MEM_AXI_LITE #(
    parameter MEM_SIZE      = 512, // 500B
    parameter MEM_SIZE_RR   = 512,
    parameter ADDR_WIDTH = 32,
    parameter DATA_WIDTH = 32

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

    //port mem
    input     [ADDR_WIDTH-1:0]      addr_read,
    input     [ADDR_WIDTH-1:0]      addr_ref,  
    output    [ADDR_WIDTH-1:0]      dout_read,
    output    [ADDR_WIDTH-1:0]      dout_ref,  


    input   [15:0]                  we_matrix,

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
    input [DATA_WIDTH-1:0] din_matrix15
    );

    //signals to connect
    //wire [3:0] o_wen;
    wire [ADDR_WIDTH-1:0] o_addr_w;
    wire [ADDR_WIDTH-1:0] o_addr_r;                
    wire [DATA_WIDTH-1:0] o_data_w;
    wire [DATA_WIDTH-1:0] i_data_r;

    wire o_valid_w;
    wire o_valid_r;


    reg [ADDR_WIDTH-1:0] addw_read;
    reg [DATA_WIDTH-1:0] din_read;
    reg [ADDR_WIDTH-1:0] addw_ref;
    reg [DATA_WIDTH-1:0] din_ref;
    reg w_read;
    reg w_ref;

    reg r_matrix0, r_matrix1, r_matrix2, r_matrix3, r_matrix4, r_matrix5, r_matrix6, r_matrix7,
        r_matrix8, r_matrix9, r_matrix10, r_matrix11, r_matrix12, r_matrix13, r_matrix14, r_matrix15;
    wire [ADDR_WIDTH-1:0] addr_matrix0, addr_matrix1, addr_matrix2, addr_matrix3,
                          addr_matrix4, addr_matrix5, addr_matrix6, addr_matrix7,
                          addr_matrix8, addr_matrix9, addr_matrix10, addr_matrix11,
                          addr_matrix12, addr_matrix13, addr_matrix14, addr_matrix15;
    wire [DATA_WIDTH-1:0] dout_matrix0, dout_matrix1, dout_matrix2, dout_matrix3,
                          dout_matrix4, dout_matrix5, dout_matrix6, dout_matrix7,
                          dout_matrix8, dout_matrix9, dout_matrix10, dout_matrix11,
                          dout_matrix12, dout_matrix13, dout_matrix14, dout_matrix15;

    // Combinational address decoder
    always @(posedge clk or negedge resetn) begin
        if (~resetn) begin
            w_read <= 0;
            w_ref  <= 0;
            r_matrix0  <= 0;
            r_matrix1  <= 0;
            r_matrix2  <= 0;
            r_matrix3  <= 0;
            r_matrix4  <= 0;
            r_matrix5  <= 0;
            r_matrix6  <= 0;
            r_matrix7  <= 0;
            r_matrix8  <= 0;
            r_matrix9  <= 0;
            r_matrix10 <= 0;
            r_matrix11 <= 0;
            r_matrix12 <= 0;
            r_matrix13 <= 0;
            r_matrix14 <= 0;
            r_matrix15 <= 0;
        end
        else begin
            // Write channel decoder
            casex (o_addr_w)
                32'h0300_0xxx: begin
                    w_read <= 1; // 0x0300_0xxx
                    w_ref  <= 0; 
                end 
                32'h0300_1xxx: begin
                    w_read <= 0; // 0x0300_0xxx
                    w_ref  <= 1; 
                end
                default: begin
                    w_read <= 0;
                    w_ref  <= 0;
                end
            endcase

            // Read channel decoder
            casex (o_addr_r)
            
                32'h0301_xxxx: begin
                    r_matrix0  <= 1; // 0x0301_xxxx
                    r_matrix1  <= 0;
                    r_matrix2  <= 0;
                    r_matrix3  <= 0;
                    r_matrix4  <= 0;
                    r_matrix5  <= 0;
                    r_matrix6  <= 0;
                    r_matrix7  <= 0;
                    r_matrix8  <= 0;
                    r_matrix9  <= 0;
                    r_matrix10 <= 0;
                    r_matrix11 <= 0;
                    r_matrix12 <= 0;
                    r_matrix13 <= 0;
                    r_matrix14 <= 0;
                    r_matrix15 <= 0;
                end
                32'h0302_xxxx: begin
                    r_matrix0  <= 0;
                    r_matrix1  <= 1; // 0x0302_xxxx
                    r_matrix2  <= 0;
                    r_matrix3  <= 0;
                    r_matrix4  <= 0;
                    r_matrix5  <= 0;
                    r_matrix6  <= 0;
                    r_matrix7  <= 0;
                    r_matrix8  <= 0;
                    r_matrix9  <= 0;
                    r_matrix10 <= 0;
                    r_matrix11 <= 0;
                    r_matrix12 <= 0;
                    r_matrix13 <= 0;
                    r_matrix14 <= 0;
                    r_matrix15 <= 0;
                end
                32'h0303_xxxx: begin
                    r_matrix0  <= 0;
                    r_matrix1  <= 0;
                    r_matrix2  <= 1; // 0x0303_xxxx
                    r_matrix3  <= 0;
                    r_matrix4  <= 0;
                    r_matrix5  <= 0;
                    r_matrix6  <= 0;
                    r_matrix7  <= 0;
                    r_matrix8  <= 0;
                    r_matrix9  <= 0;
                    r_matrix10 <= 0;
                    r_matrix11 <= 0;
                    r_matrix12 <= 0;
                    r_matrix13 <= 0;
                    r_matrix14 <= 0;
                    r_matrix15 <= 0;
                end
                32'h0304_xxxx: begin
                    r_matrix0  <= 0;
                    r_matrix1  <= 0;
                    r_matrix2  <= 0;
                    r_matrix3  <= 1; // 0x0304_xxxx
                    r_matrix4  <= 0;
                    r_matrix5  <= 0;
                    r_matrix6  <= 0;
                    r_matrix7  <= 0;
                    r_matrix8  <= 0;
                    r_matrix9  <= 0;
                    r_matrix10 <= 0;
                    r_matrix11 <= 0;
                    r_matrix12 <= 0;
                    r_matrix13 <= 0;
                    r_matrix14 <= 0;
                    r_matrix15 <= 0;
                end
                32'h0305_xxxx: begin
                    r_matrix0  <= 0;
                    r_matrix1  <= 0;
                    r_matrix2  <= 0;
                    r_matrix3  <= 0;
                    r_matrix4  <= 1; // 0x0305_xxxx
                    r_matrix5  <= 0;
                    r_matrix6  <= 0;
                    r_matrix7  <= 0;
                    r_matrix8  <= 0;
                    r_matrix9  <= 0;
                    r_matrix10 <= 0;
                    r_matrix11 <= 0;
                    r_matrix12 <= 0;
                    r_matrix13 <= 0;
                    r_matrix14 <= 0;
                    r_matrix15 <= 0;
                end
                32'h0306_xxxx: begin
                    r_matrix0  <= 0;
                    r_matrix1  <= 0;
                    r_matrix2  <= 0;
                    r_matrix3  <= 0;
                    r_matrix4  <= 0;
                    r_matrix5  <= 1; // 0x0306_xxxx
                    r_matrix6  <= 0;
                    r_matrix7  <= 0;
                    r_matrix8  <= 0;
                    r_matrix9  <= 0;
                    r_matrix10 <= 0;
                    r_matrix11 <= 0;
                    r_matrix12 <= 0;
                    r_matrix13 <= 0;
                    r_matrix14 <= 0;
                    r_matrix15 <= 0;
                end
                32'h0307_xxxx: begin
                    r_matrix0  <= 0;
                    r_matrix1  <= 0;
                    r_matrix2  <= 0;
                    r_matrix3  <= 0;
                    r_matrix4  <= 0;
                    r_matrix5  <= 0;
                    r_matrix6  <= 1; // 0x0307_xxxx
                    r_matrix7  <= 0;
                    r_matrix8  <= 0;
                    r_matrix9  <= 0;
                    r_matrix10 <= 0;
                    r_matrix11 <= 0;
                    r_matrix12 <= 0;
                    r_matrix13 <= 0;
                    r_matrix14 <= 0;
                    r_matrix15 <= 0;
                end
                32'h0308_xxxx: begin
                    r_matrix0  <= 0;
                    r_matrix1  <= 0;
                    r_matrix2  <= 0;
                    r_matrix3  <= 0;
                    r_matrix4  <= 0;
                    r_matrix5  <= 0;
                    r_matrix6  <= 0;
                    r_matrix7  <= 1; // 0x0308_xxxx
                    r_matrix8  <= 0;
                    r_matrix9  <= 0;
                    r_matrix10 <= 0;
                    r_matrix11 <= 0;
                    r_matrix12 <= 0;
                    r_matrix13 <= 0;
                    r_matrix14 <= 0;
                    r_matrix15 <= 0;
                end
                32'h0309_xxxx: begin
                    r_matrix0  <= 0;
                    r_matrix1  <= 0;
                    r_matrix2  <= 0;
                    r_matrix3  <= 0;
                    r_matrix4  <= 0;
                    r_matrix5  <= 0;
                    r_matrix6  <= 0;
                    r_matrix7  <= 0;
                    r_matrix8  <= 1; // 0x0309_xxxx
                    r_matrix9  <= 0;
                    r_matrix10 <= 0;
                    r_matrix11 <= 0;
                    r_matrix12 <= 0;
                    r_matrix13 <= 0;
                    r_matrix14 <= 0;
                    r_matrix15 <= 0;
                end
                32'h030A_xxxx: begin
                    r_matrix0  <= 0;
                    r_matrix1  <= 0;
                    r_matrix2  <= 0;
                    r_matrix3  <= 0;
                    r_matrix4  <= 0;
                    r_matrix5  <= 0;
                    r_matrix6  <= 0;
                    r_matrix7  <= 0;
                    r_matrix8  <= 0;
                    r_matrix9  <= 1; // 0x030A_xxxx
                    r_matrix10 <= 0;
                    r_matrix11 <= 0;
                    r_matrix12 <= 0;
                    r_matrix13 <= 0;
                    r_matrix14 <= 0;
                    r_matrix15 <= 0;
                end
                32'h030B_xxxx: begin
                    r_matrix0  <= 0;
                    r_matrix1  <= 0;
                    r_matrix2  <= 0;
                    r_matrix3  <= 0;
                    r_matrix4  <= 0;
                    r_matrix5  <= 0;
                    r_matrix6  <= 0;
                    r_matrix7  <= 0;
                    r_matrix8  <= 0;
                    r_matrix9  <= 0;
                    r_matrix10 <= 1; // 0x030B_xxxx
                    r_matrix11 <= 0;
                    r_matrix12 <= 0;
                    r_matrix13 <= 0;
                    r_matrix14 <= 0;
                    r_matrix15 <= 0;
                end
                32'h030C_xxxx: begin
                    r_matrix0  <= 0;
                    r_matrix1  <= 0;
                    r_matrix2  <= 0;
                    r_matrix3  <= 0;
                    r_matrix4  <= 0;
                    r_matrix5  <= 0;
                    r_matrix6  <= 0;
                    r_matrix7  <= 0;
                    r_matrix8  <= 0;
                    r_matrix9  <= 0;
                    r_matrix10 <= 0;
                    r_matrix11 <= 1; // 0x030C_xxxx
                    r_matrix12 <= 0;
                    r_matrix13 <= 0;
                    r_matrix14 <= 0;
                    r_matrix15 <= 0;;
                end
                32'h030D_xxxx: begin
                    r_matrix0  <= 0;
                    r_matrix1  <= 0;
                    r_matrix2  <= 0;
                    r_matrix3  <= 0;
                    r_matrix4  <= 0;
                    r_matrix5  <= 0;
                    r_matrix6  <= 0;
                    r_matrix7  <= 0;
                    r_matrix8  <= 0;
                    r_matrix9  <= 0;
                    r_matrix10 <= 0;
                    r_matrix11 <= 0;
                    r_matrix12 <= 1; // 0x030D_xxxx
                    r_matrix13 <= 0;
                    r_matrix14 <= 0;
                    r_matrix15 <= 0;
                end
                32'h030E_xxxx: begin
                    r_matrix0  <= 0;
                    r_matrix1  <= 0;
                    r_matrix2  <= 0;
                    r_matrix3  <= 0;
                    r_matrix4  <= 0;
                    r_matrix5  <= 0;
                    r_matrix6  <= 0;
                    r_matrix7  <= 0;
                    r_matrix8  <= 0;
                    r_matrix9  <= 0;
                    r_matrix10 <= 0;
                    r_matrix11 <= 0;
                    r_matrix12 <= 0;
                    r_matrix13 <= 1; // 0x030E_xxxx
                    r_matrix14 <= 0;
                    r_matrix15 <= 0;
                end
                32'h030F_xxxx: begin
                    r_matrix0  <= 0;
                    r_matrix1  <= 0;
                    r_matrix2  <= 0;
                    r_matrix3  <= 0;
                    r_matrix4  <= 0;
                    r_matrix5  <= 0;
                    r_matrix6  <= 0;
                    r_matrix7  <= 0;
                    r_matrix8  <= 0;
                    r_matrix9  <= 0;
                    r_matrix10 <= 0;
                    r_matrix11 <= 0;
                    r_matrix12 <= 0;
                    r_matrix13 <= 0;
                    r_matrix14 <= 1; // 0x030F_xxxx
                    r_matrix15 <= 0;
                end
                32'h0310_xxxx: begin
                    r_matrix0  <= 0;
                    r_matrix1  <= 0;
                    r_matrix2  <= 0;
                    r_matrix3  <= 0;
                    r_matrix4  <= 0;
                    r_matrix5  <= 0;
                    r_matrix6  <= 0;
                    r_matrix7  <= 0;
                    r_matrix8  <= 0;
                    r_matrix9  <= 0;
                    r_matrix10 <= 0;
                    r_matrix11 <= 0;
                    r_matrix12 <= 0;
                    r_matrix13 <= 0;
                    r_matrix14 <= 0;
                    r_matrix15 <= 1; // 0x0310_xxxx
                end
                default: begin
                    r_matrix0  <= 0;
                    r_matrix1  <= 0;
                    r_matrix2  <= 0;
                    r_matrix3  <= 0;
                    r_matrix4  <= 0;
                    r_matrix5  <= 0;
                    r_matrix6  <= 0;
                    r_matrix7  <= 0;
                    r_matrix8  <= 0;
                    r_matrix9  <= 0;
                    r_matrix10 <= 0;
                    r_matrix11 <= 0;
                    r_matrix12 <= 0;
                    r_matrix13 <= 0;
                    r_matrix14 <= 0;
                    r_matrix15 <= 0;
                end
            endcase
        end
    end

    // Write address and data registers
    always @(posedge clk or negedge resetn) begin
        if (~resetn) begin
            addw_read <= 0;
            din_read  <= 0;
            addw_ref  <= 0;
            din_ref   <= 0;
        end
        else begin
            addw_read <= (w_read) ? o_addr_w : 0;
            din_read  <= (w_read) ? o_data_w : 0;
            addw_ref  <= (w_ref)  ? o_addr_w : 0;
            din_ref   <= (w_ref)  ? o_data_w : 0;
        end
    end

    // Read address routing
    assign addr_matrix0  = (r_matrix0)  ? o_addr_r : 0;
    assign addr_matrix1  = (r_matrix1)  ? o_addr_r : 0;
    assign addr_matrix2  = (r_matrix2)  ? o_addr_r : 0;
    assign addr_matrix3  = (r_matrix3)  ? o_addr_r : 0;
    assign addr_matrix4  = (r_matrix4)  ? o_addr_r : 0;
    assign addr_matrix5  = (r_matrix5)  ? o_addr_r : 0;
    assign addr_matrix6  = (r_matrix6)  ? o_addr_r : 0;
    assign addr_matrix7  = (r_matrix7)  ? o_addr_r : 0;
    assign addr_matrix8  = (r_matrix8)  ? o_addr_r : 0;
    assign addr_matrix9  = (r_matrix9)  ? o_addr_r : 0;
    assign addr_matrix10 = (r_matrix10) ? o_addr_r : 0;
    assign addr_matrix11 = (r_matrix11) ? o_addr_r : 0;
    assign addr_matrix12 = (r_matrix12) ? o_addr_r : 0;
    assign addr_matrix13 = (r_matrix13) ? o_addr_r : 0;
    assign addr_matrix14 = (r_matrix14) ? o_addr_r : 0;
    assign addr_matrix15 = (r_matrix15) ? o_addr_r : 0;

    // Read data multiplexer
    assign i_data_r =
                      (r_matrix0)  ? dout_matrix0 :
                      (r_matrix1)  ? dout_matrix1 :
                      (r_matrix2)  ? dout_matrix2 :
                      (r_matrix3)  ? dout_matrix3 :
                      (r_matrix4)  ? dout_matrix4 :
                      (r_matrix5)  ? dout_matrix5 :
                      (r_matrix6)  ? dout_matrix6 :
                      (r_matrix7)  ? dout_matrix7 :
                      (r_matrix8)  ? dout_matrix8 :
                      (r_matrix9)  ? dout_matrix9 :
                      (r_matrix10) ? dout_matrix10 :
                      (r_matrix11) ? dout_matrix11 :
                      (r_matrix12) ? dout_matrix12 :
                      (r_matrix13) ? dout_matrix13 :
                      (r_matrix14) ? dout_matrix14 :
                      (r_matrix15) ? dout_matrix15 : 0;




    Top_memory #(
        .MEM_SIZE(MEM_SIZE), // 512B
        .MEM_SIZE_RR(MEM_SIZE_RR), // 1KB
        .ADDR_WIDTH(ADDR_WIDTH),
        .DATA_WIDTH(DATA_WIDTH)
    ) mem_dna(
        .clk(clk),

        .we_read(w_read),
        .we_ref(w_ref),

        .addr_read(addr_read<<2),
        .addr_ref(addr_ref<<2),
        .addw_read(addw_read - 32'h0300_0000),
        .addw_ref(addw_ref - 32'h0300_1000),

        .din_read(din_read),
        .din_ref(din_ref),

        .dout_read(dout_read),
        .dout_ref(dout_ref),

        .we_matrix(we_matrix),

        .addr_matrix0(addr_matrix0 - 32'h0301_0000),
        .addr_matrix1(addr_matrix1 - 32'h0302_0000),
        .addr_matrix2(addr_matrix2 - 32'h0303_0000),
        .addr_matrix3(addr_matrix3 - 32'h0304_0000),
        .addr_matrix4(addr_matrix4 - 32'h0305_0000),
        .addr_matrix5(addr_matrix5 - 32'h0306_0000),
        .addr_matrix6(addr_matrix6 - 32'h0307_0000),
        .addr_matrix7(addr_matrix7 - 32'h0308_0000),
        .addr_matrix8(addr_matrix8 - 32'h0309_0000),
        .addr_matrix9(addr_matrix9 - 32'h030A_0000),
        .addr_matrix10(addr_matrix10 - 32'h030B_0000),
        .addr_matrix11(addr_matrix11 - 32'h030C_0000),
        .addr_matrix12(addr_matrix12 - 32'h030D_0000),
        .addr_matrix13(addr_matrix13 - 32'h030E_0000),
        .addr_matrix14(addr_matrix14 - 32'h030F_0000),
        .addr_matrix15(addr_matrix15 - 32'h0310_0000),

        .addw_matrix0(addw_matrix0<<2),
        .addw_matrix1(addw_matrix1<<2),
        .addw_matrix2(addw_matrix2<<2),
        .addw_matrix3(addw_matrix3<<2),
        .addw_matrix4(addw_matrix4<<2),
        .addw_matrix5(addw_matrix5<<2),
        .addw_matrix6(addw_matrix6<<2),
        .addw_matrix7(addw_matrix7<<2),
        .addw_matrix8(addw_matrix8<<2),
        .addw_matrix9(addw_matrix9<<2),
        .addw_matrix10(addw_matrix10<<2),
        .addw_matrix11(addw_matrix11<<2),
        .addw_matrix12(addw_matrix12<<2),
        .addw_matrix13(addw_matrix13<<2),
        .addw_matrix14(addw_matrix14<<2),
        .addw_matrix15(addw_matrix15<<2),

        .din_matrix0(din_matrix0),
        .din_matrix1(din_matrix1),
        .din_matrix2(din_matrix2),
        .din_matrix3(din_matrix3),
        .din_matrix4(din_matrix4),
        .din_matrix5(din_matrix5),
        .din_matrix6(din_matrix6),
        .din_matrix7(din_matrix7),
        .din_matrix8(din_matrix8),
        .din_matrix9(din_matrix9),
        .din_matrix10(din_matrix10),
        .din_matrix11(din_matrix11),
        .din_matrix12(din_matrix12),
        .din_matrix13(din_matrix13),
        .din_matrix14(din_matrix14),
        .din_matrix15(din_matrix15),

        .dout_matrix0(dout_matrix0),
        .dout_matrix1(dout_matrix1),
        .dout_matrix2(dout_matrix2),
        .dout_matrix3(dout_matrix3),
        .dout_matrix4(dout_matrix4),
        .dout_matrix5(dout_matrix5),
        .dout_matrix6(dout_matrix6),
        .dout_matrix7(dout_matrix7),
        .dout_matrix8(dout_matrix8),
        .dout_matrix9(dout_matrix9),
        .dout_matrix10(dout_matrix10),
        .dout_matrix11(dout_matrix11),
        .dout_matrix12(dout_matrix12),
        .dout_matrix13(dout_matrix13),
        .dout_matrix14(dout_matrix14),
        .dout_matrix15(dout_matrix15)
    );


    // Instantiate axi interface module
    dna_axi_lite_interface #(
        .ADDR_WIDTH(ADDR_WIDTH),
        .DATA_WIDTH(DATA_WIDTH)
    ) dna_mem_axi_adapter(
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
