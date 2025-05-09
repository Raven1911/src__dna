`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/04/2025 04:43:59 PM
// Design Name: 
// Module Name: imem_axi_lite
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
// Module Name: imem_axi_lite
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: AXI-Lite interface for instruction memory with sequential and combinational logic separation
// 
// Dependencies: imem module
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module imem_axi_lite #(
    parameter MEM_SIZE = 16384, // 16KB
    parameter ADDR_WIDTH = 32,
    parameter DATA_WIDTH = 32,
    parameter PROGADDR_RESET = 32'h0000_0000
)(
    input clk,
    input resetn,

    // AXI4-Lite Read Address Channels
    input [ADDR_WIDTH-1:0] i_axi_araddr,
    input i_axi_arvalid,
    output reg o_axi_arready,

    // AXI4-Lite Read Data Channel
    output reg [DATA_WIDTH-1:0] o_axi_rdata,
    output reg o_axi_rvalid,
    input i_axi_rready
);

    // Define state
    localparam R_ADDRESS = 2'b00;
    localparam R_READ = 2'b01;

    reg [1:0] R_state; // Current FSM state
    reg [1:0] R_state_next; // Next FSM state

    // Next value registers for outputs
    reg o_axi_arready_next;
    reg o_axi_rvalid_next;
    reg [DATA_WIDTH-1:0] o_axi_rdata_next;

    // Signals to connect to imem
    wire [ADDR_WIDTH-1:0] addr_r;
    wire [DATA_WIDTH-1:0] dout;

    // Assign read address directly
    assign addr_r = i_axi_araddr;

    // Sequential circuit: Update state and outputs
    always @(posedge clk or negedge resetn) begin
        if (~resetn) begin
            R_state <= R_ADDRESS;
            o_axi_arready <= 0;
            o_axi_rvalid <= 0;
            o_axi_rdata <= 0;
        end
        else begin
            R_state <= R_state_next;
            o_axi_arready <= o_axi_arready_next;
            o_axi_rvalid <= o_axi_rvalid_next;
            o_axi_rdata <= o_axi_rdata_next;
        end
    end

    // Combinational circuit: Determine next state and outputs
    always @(*) begin
        // Default values
        R_state_next = R_state;
        o_axi_arready_next = 0;
        o_axi_rvalid_next = 0;
        o_axi_rdata_next = o_axi_rdata;

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

    // Instantiate imem
    imem #(
        .MEM_SIZE(MEM_SIZE),
        .ADDR_WIDTH(ADDR_WIDTH),
        .DATA_WIDTH(DATA_WIDTH),
        .PROGADDR_RESET(PROGADDR_RESET)
    ) imem_unit (
        .clk(clk),
        .addr_r(addr_r), // Word-aligned address
        .dout(dout)
    );

endmodule



module imem #(
    parameter MEM_SIZE = 'd16384, // 16KB (16384 bytes / 4 = 4096 words)
    parameter ADDR_WIDTH = 32,
    parameter DATA_WIDTH = 32,
    parameter PROGADDR_RESET = 32'h 0000_0000
)(
    input clk,
    input [ADDR_WIDTH-1:0] addr_r,
    output reg [DATA_WIDTH-1:0] dout
);

    reg [DATA_WIDTH-1:0] imem [0:(MEM_SIZE >> 2) - 1];

    // Initialize memory from a hex file
    // initial $readmemh("firmware.hex", imem);

    always @(posedge clk) begin
        dout <= imem[(addr_r - PROGADDR_RESET) >> 2]; // Address map, Đọc dữ liệu từ địa chỉ addr_r 
    end

endmodule
