`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/20/2025 02:14:35 AM
// Design Name: 
// Module Name: axi_lite_interconnect
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

/***************************************************************
 * AXI4-Lite Interconnect for picorv32_axi (1 Master, Multiple Slaves)
 ***************************************************************/
module axi_lite_interconnect #(
    parameter int NUM_SLAVES = 6,
    parameter int ADDR_WIDTH = 32,
    parameter int DATA_WIDTH = 32
) (
    // Clock and Reset
    //input logic               clk,
    input logic               resetn,

    // AXI4-Lite Master Interface (from picorv32_axi)
    input logic               i_m_axi_awvalid,    // Master Write Address Valid
    output logic              o_m_axi_awready,    // Master Write Address Ready
    input logic [ADDR_WIDTH-1:0] i_m_axi_awaddr,  // Master Write Address
    input logic [2:0]         i_m_axi_awprot,     // Master Write Protection
    input logic               i_m_axi_wvalid,     // Master Write Data Valid
    output logic              o_m_axi_wready,     // Master Write Data Ready
    input logic [DATA_WIDTH-1:0] i_m_axi_wdata,   // Master Write Data
    input logic [DATA_WIDTH/8-1:0] i_m_axi_wstrb, // Master Write Strobe
    output logic              o_m_axi_bvalid,     // Master Write Response Valid
    input logic               i_m_axi_bready,     // Master Write Response Ready
    input logic               i_m_axi_arvalid,    // Master Read Address Valid
    output logic              o_m_axi_arready,    // Master Read Address Ready
    input logic [ADDR_WIDTH-1:0] i_m_axi_araddr,  // Master Read Address
    input logic [2:0]         i_m_axi_arprot,     // Master Read Protection
    output logic              o_m_axi_rvalid,     // Master Read Data Valid
    input logic               i_m_axi_rready,     // Master Read Data Ready
    output logic [DATA_WIDTH-1:0] o_m_axi_rdata,  // Master Read Data

    // AXI4-Lite Slave Interfaces
    output logic [ADDR_WIDTH-1:0]    o_s_axi_awaddr,   // Slave Write Address
    output logic [NUM_SLAVES-1:0]    o_s_axi_awvalid,  // Slave Write Address Valid
    input logic [NUM_SLAVES-1:0]     i_s_axi_awready,  // Slave Write Address Ready
    output logic [NUM_SLAVES*3-1:0]  o_s_axi_awprot,   // Slave Write Protection (flattened)
    output logic [NUM_SLAVES*DATA_WIDTH-1:0] o_s_axi_wdata, // Slave Write Data (flattened)
    output logic [NUM_SLAVES*(DATA_WIDTH/8)-1:0] o_s_axi_wstrb, // Slave Write Strobe (flattened)
    output logic [NUM_SLAVES-1:0]    o_s_axi_wvalid,   // Slave Write Data Valid
    input logic [NUM_SLAVES-1:0]     i_s_axi_wready,   // Slave Write Data Ready
    input logic [NUM_SLAVES-1:0]     i_s_axi_bvalid,   // Slave Write Response Valid
    output logic [NUM_SLAVES-1:0]    o_s_axi_bready,   // Slave Write Response Ready
    output logic [ADDR_WIDTH-1:0]    o_s_axi_araddr,   // Slave Read Address
    output logic [NUM_SLAVES-1:0]    o_s_axi_arvalid,  // Slave Read Address Valid
    input logic [NUM_SLAVES-1:0]     i_s_axi_arready,  // Slave Read Address Ready
    output logic [NUM_SLAVES*3-1:0]  o_s_axi_arprot,   // Slave Read Protection (flattened)
    input logic [NUM_SLAVES*DATA_WIDTH-1:0] i_s_axi_rdata, // Slave Read Data (flattened)
    input logic [NUM_SLAVES-1:0]     i_s_axi_rvalid,   // Slave Read Data Valid
    output logic [NUM_SLAVES-1:0]    o_s_axi_rready    // Slave Read Data Ready
);

    // Internal signals for slave selection
    logic [NUM_SLAVES-1:0] slave_select_write;
    logic [NUM_SLAVES-1:0] slave_select_read;

    // Decoder: Select slave based on address
    axi_lite_decoder #(
        .NUM_SLAVES(NUM_SLAVES),
        .ADDR_WIDTH(ADDR_WIDTH)
    ) decoder (
        //.clk(clk),
        .resetn(resetn),
        .i_axi_awaddr(i_m_axi_awaddr),
        .i_axi_araddr(i_m_axi_araddr),
        .o_slave_select_write(slave_select_write),
        .o_slave_select_read(slave_select_read)
    );

    // Multiplexer: Route data between master and selected slave
    axi_lite_mux #(
        .NUM_SLAVES(NUM_SLAVES),
        .DATA_WIDTH(DATA_WIDTH)
    ) mux (
        .i_m_axi_awvalid(i_m_axi_awvalid),
        .o_m_axi_awready(o_m_axi_awready),
        .i_m_axi_wvalid(i_m_axi_wvalid),
        .o_m_axi_wready(o_m_axi_wready),
        .i_m_axi_wdata(i_m_axi_wdata),
        .i_m_axi_wstrb(i_m_axi_wstrb),
        .o_m_axi_bvalid(o_m_axi_bvalid),
        .i_m_axi_bready(i_m_axi_bready),
        .i_m_axi_arvalid(i_m_axi_arvalid),
        .o_m_axi_arready(o_m_axi_arready),
        .o_m_axi_rvalid(o_m_axi_rvalid),
        .i_m_axi_rready(i_m_axi_rready),
        .o_m_axi_rdata(o_m_axi_rdata),
        .i_slave_select_write(slave_select_write),
        .i_slave_select_read(slave_select_read),
        .o_s_axi_awvalid(o_s_axi_awvalid),
        .i_s_axi_awready(i_s_axi_awready),
        .o_s_axi_wvalid(o_s_axi_wvalid),
        .i_s_axi_wready(i_s_axi_wready),
        .o_s_axi_wdata(o_s_axi_wdata),
        .o_s_axi_wstrb(o_s_axi_wstrb),
        .i_s_axi_bvalid(i_s_axi_bvalid),
        .o_s_axi_bready(o_s_axi_bready),
        .o_s_axi_arvalid(o_s_axi_arvalid),
        .i_s_axi_arready(i_s_axi_arready),
        .i_s_axi_rvalid(i_s_axi_rvalid),
        .o_s_axi_rready(o_s_axi_rready),
        .i_s_axi_rdata(i_s_axi_rdata)
    );

    // Address and Protection signal routing
    for (genvar i = 0; i < NUM_SLAVES; i++) begin : slave_routing
        assign o_s_axi_awprot[i*3 +: 3] = slave_select_write[i] ? i_m_axi_awprot : '0;
        assign o_s_axi_arprot[i*3 +: 3] = slave_select_read[i] ? i_m_axi_arprot : '0;
    end
    assign o_s_axi_awaddr = i_m_axi_awaddr;
    assign o_s_axi_araddr = i_m_axi_araddr;

endmodule

/***************************************************************
 * AXI4-Lite Decoder
 ***************************************************************/
module axi_lite_decoder #(
    parameter int NUM_SLAVES = 6,
    parameter int ADDR_WIDTH = 32
) (  
    //input logic                   clk,
    input logic                   resetn,
    input logic [ADDR_WIDTH-1:0]  i_axi_awaddr,           // Input Write Address
    input logic [ADDR_WIDTH-1:0]  i_axi_araddr,           // Input Read Address
    output logic [NUM_SLAVES-1:0] o_slave_select_write,   // Output Slave Select for Write
    output logic [NUM_SLAVES-1:0] o_slave_select_read     // Output Slave Select for Read
);

    // Combinatorial circuit with direct output assignment
    always_comb begin
        if (!resetn) begin
            o_slave_select_write = '0;
            o_slave_select_read  = '0;
        end
        else begin
            // Write channel decoder
            unique casez (i_axi_awaddr)
                32'h00??_????: o_slave_select_write = 6'b000001;  // Slave 0
                32'h0200_2???: o_slave_select_write = 6'b000100;  // Slave 2
                32'h0200_3???: o_slave_select_write = 6'b001000;  // Slave 3
                32'h03??_????: o_slave_select_write = 6'b010000;  // Slave 4
                32'h0200_4???: o_slave_select_write = 6'b100000;  // Slave 5
                default:       o_slave_select_write = 6'b000000;  // No slave selected
            endcase

            // Read channel decoder
            unique casez (i_axi_araddr)
                32'h00??_????: o_slave_select_read = 6'b000001;  // Slave 0
                32'h01??_????: o_slave_select_read = 6'b000010;  // Slave 1
                32'h0200_2???: o_slave_select_read = 6'b000100;  // Slave 2
                32'h0200_3???: o_slave_select_read = 6'b001000;  // Slave 3
                32'h03??_????: o_slave_select_read = 6'b010000;  // Slave 4
                32'h0200_4???: o_slave_select_read = 6'b100000;  // Slave 5
                default:       o_slave_select_read = 6'b000000;  // No slave selected
            endcase
        end
    end

endmodule

/***************************************************************
 * AXI4-Lite Multiplexer
 ***************************************************************/
module axi_lite_mux #(
    parameter int NUM_SLAVES = 6,
    parameter int DATA_WIDTH = 32
) (
    // Master Interface (from picorv32_axi)
    input logic                   i_m_axi_awvalid,    // Master Write Address Valid
    output logic                  o_m_axi_awready,    // Master Write Address Ready
    input logic                   i_m_axi_wvalid,     // Master Write Data Valid
    output logic                  o_m_axi_wready,     // Master Write Data Ready
    input logic [DATA_WIDTH-1:0]  i_m_axi_wdata,      // Master Write Data
    input logic [DATA_WIDTH/8-1:0] i_m_axi_wstrb,     // Master Write Strobe
    output logic                  o_m_axi_bvalid,     // Master Write Response Valid
    input logic                   i_m_axi_bready,     // Master Write Response Ready
    input logic                   i_m_axi_arvalid,    // Master Read Address Valid
    output logic                  o_m_axi_arready,    // Master Read Address Ready
    output logic                  o_m_axi_rvalid,     // Master Read Data Valid
    input logic                   i_m_axi_rready,     // Master Read Data Ready
    output logic [DATA_WIDTH-1:0] o_m_axi_rdata,      // Master Read Data
    // Slave Interfaces
    input logic [NUM_SLAVES-1:0]                     i_slave_select_write, // Slave Select for Write
    input logic [NUM_SLAVES-1:0]                     i_slave_select_read,  // Slave Select for Read
    output logic [NUM_SLAVES-1:0]                    o_s_axi_awvalid,      // Slave Write Address Valid
    input logic [NUM_SLAVES-1:0]                     i_s_axi_awready,      // Slave Write Address Ready
    output logic [NUM_SLAVES-1:0]                    o_s_axi_wvalid,       // Slave Write Data Valid
    input logic [NUM_SLAVES-1:0]                     i_s_axi_wready,       // Slave Write Data Ready
    output logic [NUM_SLAVES*DATA_WIDTH-1:0]         o_s_axi_wdata,        // Slave Write Data (flattened)
    output logic [NUM_SLAVES*(DATA_WIDTH/8)-1:0]     o_s_axi_wstrb,        // Slave Write Strobe (flattened)
    input logic [NUM_SLAVES-1:0]                     i_s_axi_bvalid,       // Slave Write Response Valid
    output logic [NUM_SLAVES-1:0]                    o_s_axi_bready,       // Slave Write Response Ready
    output logic [NUM_SLAVES-1:0]                    o_s_axi_arvalid,      // Slave Read Address Valid
    input logic [NUM_SLAVES-1:0]                     i_s_axi_arready,      // Slave Read Address Ready
    input logic [NUM_SLAVES*DATA_WIDTH-1:0]          i_s_axi_rdata,        // Slave Read Data (flattened)
    input logic [NUM_SLAVES-1:0]                     i_s_axi_rvalid,       // Slave Read Data Valid
    output logic [NUM_SLAVES-1:0]                    o_s_axi_rready        // Slave Read Data Ready
);

    // Write Address Channel
    for (genvar i = 0; i < NUM_SLAVES; i++) begin : awvalid_loop
        assign o_s_axi_awvalid[i] = i_slave_select_write[i] ? i_m_axi_awvalid : 1'b0;
    end

    assign o_m_axi_awready = i_slave_select_write[0] ? i_s_axi_awready[0] : 
                             i_slave_select_write[1] ? i_s_axi_awready[1] :
                             i_slave_select_write[2] ? i_s_axi_awready[2] :
                             i_slave_select_write[3] ? i_s_axi_awready[3] :
                             i_slave_select_write[4] ? i_s_axi_awready[4] :
                             i_slave_select_write[5] ? i_s_axi_awready[5] : '0;

    // Write Data Channel
    for (genvar i = 0; i < NUM_SLAVES; i++) begin : wvalid_loop
        assign o_s_axi_wvalid[i] = i_slave_select_write[i] ? i_m_axi_wvalid : 1'b0;
    end

    for (genvar i = 0; i < NUM_SLAVES; i++) begin : wdata_wstrb_loop
        assign o_s_axi_wdata[i*DATA_WIDTH +: DATA_WIDTH] = i_slave_select_write[i] ? i_m_axi_wdata : '0;
        assign o_s_axi_wstrb[i*(DATA_WIDTH/8) +: DATA_WIDTH/8] = i_slave_select_write[i] ? i_m_axi_wstrb : '0;
    end

    assign o_m_axi_wready = i_slave_select_write[0] ? i_s_axi_wready[0] : 
                            i_slave_select_write[1] ? i_s_axi_wready[1] :
                            i_slave_select_write[2] ? i_s_axi_wready[2] :
                            i_slave_select_write[3] ? i_s_axi_wready[3] :
                            i_slave_select_write[4] ? i_s_axi_wready[4] :
                            i_slave_select_write[5] ? i_s_axi_wready[5] : '0;

    // Write Response Channel
    assign o_m_axi_bvalid = i_slave_select_write[0] ? i_s_axi_bvalid[0] :
                            i_slave_select_write[1] ? i_s_axi_bvalid[1] :
                            i_slave_select_write[2] ? i_s_axi_bvalid[2] :
                            i_slave_select_write[3] ? i_s_axi_bvalid[3] : 
                            i_slave_select_write[4] ? i_s_axi_bvalid[4] :
                            i_slave_select_write[5] ? i_s_axi_bvalid[5] : '0;

    for (genvar i = 0; i < NUM_SLAVES; i++) begin : bready_loop
        assign o_s_axi_bready[i] = i_slave_select_write[i] ? i_m_axi_bready : 1'b0;
    end

    // Read Address Channel
    for (genvar i = 0; i < NUM_SLAVES; i++) begin :

 arvalid_loop
        assign o_s_axi_arvalid[i] = i_slave_select_read[i] ? i_m_axi_arvalid : 1'b0;
    end

    assign o_m_axi_arready = i_slave_select_read[0] ? i_s_axi_arready[0] : 
                             i_slave_select_read[1] ? i_s_axi_arready[1] :
                             i_slave_select_read[2] ? i_s_axi_arready[2] :
                             i_slave_select_read[3] ? i_s_axi_arready[3] :
                             i_slave_select_read[4] ? i_s_axi_arready[4] :
                             i_slave_select_read[5] ? i_s_axi_arready[5] : '0;

    // Read Data Channel
    assign o_m_axi_rdata = i_slave_select_read[0] ? i_s_axi_rdata[0*DATA_WIDTH +: DATA_WIDTH] :
                           i_slave_select_read[1] ? i_s_axi_rdata[1*DATA_WIDTH +: DATA_WIDTH] :
                           i_slave_select_read[2] ? i_s_axi_rdata[2*DATA_WIDTH +: DATA_WIDTH] :
                           i_slave_select_read[3] ? i_s_axi_rdata[3*DATA_WIDTH +: DATA_WIDTH] :
                           i_slave_select_read[4] ? i_s_axi_rdata[4*DATA_WIDTH +: DATA_WIDTH] :
                           i_slave_select_read[5] ? i_s_axi_rdata[5*DATA_WIDTH +: DATA_WIDTH] : '0;

    assign o_m_axi_rvalid = i_slave_select_read[0] ? i_s_axi_rvalid[0] : 
                            i_slave_select_read[1] ? i_s_axi_rvalid[1] :
                            i_slave_select_read[2] ? i_s_axi_rvalid[2] :
                            i_slave_select_read[3] ? i_s_axi_rvalid[3] :
                            i_slave_select_read[4] ? i_s_axi_rvalid[4] :
                            i_slave_select_read[5] ? i_s_axi_rvalid[5] : '0;

    for (genvar i = 0; i < NUM_SLAVES; i++) begin : rready_loop
        assign o_s_axi_rready[i] = i_slave_select_read[i] ? i_m_axi_rready : 1'b0;
    end

endmodule