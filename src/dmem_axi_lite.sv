`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/04/2025 04:43:59 PM
// Design Name: 
// Module Name: dmem_axi_lite
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


`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 
// Design Name: 
// Module Name: dmem_axi_lite
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: AXI-Lite interface for data memory with sequential and combinational logic separation
// 
// Dependencies: dmem module
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module dmem_axi_lite #(
    parameter MEM_SIZE = 532480, // 520KB
    parameter ADDR_WIDTH = 32,
    parameter DATA_WIDTH = 32
)(  
    input clk,
    input resetn,

    // AXI-Lite Write Address Channels
    input [ADDR_WIDTH-1:0] i_axi_awaddr,
    input i_axi_awvalid,
    output reg o_axi_awready,

    // AXI-Lite Write Data Channel
    input [DATA_WIDTH-1:0] i_axi_wdata,
    input [3:0] i_axi_wstrb,
    input i_axi_wvalid,
    output reg o_axi_wready,

    // AXI-Lite Write Response Channels
    output reg o_axi_bvalid,
    input i_axi_bready,

    // AXI-Lite Read Address Channels
    input [ADDR_WIDTH-1:0] i_axi_araddr,
    input i_axi_arvalid,
    output reg o_axi_arready,

    // AXI4-Lite Read Data Channel
    output reg [DATA_WIDTH-1:0] o_axi_rdata,
    output reg o_axi_rvalid,
    input i_axi_rready
);

    // State declaration
    // Write channel FSM
    localparam W_ADDRESS   = 2'b00;
    localparam W_WRITE     = 2'b01;
    localparam W_RESPONSE  = 2'b10;

    // Read channel FSM
    localparam R_ADDRESS   = 2'b00;
    localparam R_READ      = 2'b01;

    reg [1:0] W_state, R_state; // Current FSM states
    reg [1:0] W_state_next, R_state_next; // Next FSM states

    // Signals to connect to dmem
    reg [3:0] wen;
    reg [ADDR_WIDTH-1:0] addr_w;
    wire [ADDR_WIDTH-1:0] addr_r;                
    reg [DATA_WIDTH-1:0] din;
    wire [DATA_WIDTH-1:0] dout;

    // Next value registers for outputs
    reg o_axi_awready_next, o_axi_wready_next, o_axi_bvalid_next;
    reg o_axi_arready_next, o_axi_rvalid_next;
    reg [DATA_WIDTH-1:0] o_axi_rdata_next;
    reg [3:0] wen_next;
    reg [ADDR_WIDTH-1:0] addr_w_next;
    reg [DATA_WIDTH-1:0] din_next;

    // Sequential circuit: Update states and outputs
    always @(posedge clk or negedge resetn) begin
        if (~resetn) begin
            W_state <= W_ADDRESS;
            R_state <= R_ADDRESS;
            o_axi_awready <= 0;
            o_axi_wready <= 0;
            o_axi_bvalid <= 0;
            o_axi_arready <= 0;
            o_axi_rvalid <= 0;
            o_axi_rdata <= 0;
            wen <= 4'b0000;
            addr_w <= 0;
            din <= 0;
        end
        else begin
            W_state <= W_state_next;
            R_state <= R_state_next;
            o_axi_awready <= o_axi_awready_next;
            o_axi_wready <= o_axi_wready_next;
            o_axi_bvalid <= o_axi_bvalid_next;
            o_axi_arready <= o_axi_arready_next;
            o_axi_rvalid <= o_axi_rvalid_next;
            o_axi_rdata <= o_axi_rdata_next;
            wen <= wen_next;
            addr_w <= addr_w_next;
            din <= din_next;
        end
    end

    // Combinational circuit: Determine next states and outputs
    always @(*) begin
        // Default values
        W_state_next = W_state;
        R_state_next = R_state;
        o_axi_awready_next = 0;
        o_axi_wready_next = 0;
        o_axi_bvalid_next = 0;
        o_axi_arready_next = 0;
        o_axi_rvalid_next = 0;
        o_axi_rdata_next = o_axi_rdata;
        wen_next = 4'b0000;
        addr_w_next = addr_w;
        din_next = din;

        // Write channel FSM
        case (W_state)
            W_ADDRESS: begin
                o_axi_bvalid_next = 0;
                if (i_axi_awvalid) begin
                    o_axi_awready_next = 1;
                    addr_w_next = i_axi_awaddr;
                    W_state_next = W_WRITE;
                end
            end
            W_WRITE: begin
                o_axi_awready_next = 0;
                if (i_axi_wvalid) begin
                    o_axi_wready_next = 1;
                    wen_next = i_axi_wstrb;
                    din_next = i_axi_wdata;
                    W_state_next = W_RESPONSE;
                end
            end
            W_RESPONSE: begin
                o_axi_wready_next = 0;
                wen_next = 4'b0000;
                if (i_axi_bready) begin
                    o_axi_bvalid_next = 1;
                    W_state_next = W_ADDRESS;
                end
            end
            default: begin
                W_state_next = W_ADDRESS;
            end
        endcase

        // Read channel FSM
        case (R_state)
            R_ADDRESS: begin
                o_axi_rvalid_next = 0;
                if (i_axi_arvalid) begin
                    o_axi_arready_next = 1;
                    R_state_next = R_READ;
                end
            end
            R_READ: begin
                o_axi_arready_next = 0;
                if (i_axi_rready) begin
                    o_axi_rvalid_next = 1;
                    o_axi_rdata_next = dout;
                    R_state_next = R_ADDRESS;
                end
            end
            default: begin
                R_state_next = R_ADDRESS;
            end
        endcase
    end

    // Assign read address directly
    assign addr_r = i_axi_araddr;

    // Instantiate dmem module
    dmem #(
        .MEM_SIZE(MEM_SIZE),
        .ADDR_WIDTH(ADDR_WIDTH),
        .DATA_WIDTH(DATA_WIDTH)
    ) dmem_unit (
        .clk(clk),
        .wen(wen),
        .addr_r(addr_r), // Word-aligned address (ignore lower 2 bits)
        .addr_w(addr_w), // Word-aligned address (ignore lower 2 bits)
        .din(din),
        .dout(dout)
    );

endmodule



module dmem #(
    parameter MEM_SIZE = 532480, // 520KB
    parameter ADDR_WIDTH = 32,
    parameter DATA_WIDTH = 32

)(
    input clk,
    input [3:0] wen,
    input [ADDR_WIDTH-1:0] addr_r, addr_w,
    input [DATA_WIDTH-1:0] din,
    output reg [DATA_WIDTH-1:0] dout
    );

    //big endian
    reg [DATA_WIDTH-1:0] dmem [0:(MEM_SIZE >> 2) - 1];
    //initial $readmemh("firmware.hex", dmem);

    always @(posedge clk) begin
        dout <= dmem[addr_r>>2];
        if (wen[0]) dmem[addr_w >> 2][ 7: 0] <= din[ 7: 0];
		if (wen[1]) dmem[addr_w >> 2][15: 8] <= din[15: 8];
		if (wen[2]) dmem[addr_w >> 2][23:16] <= din[23:16];
		if (wen[3]) dmem[addr_w >> 2][31:24] <= din[31:24];
        
    end

    
endmodule


