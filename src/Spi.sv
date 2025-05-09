`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/17/2025 11:39:06 PM
// Design Name: 
// Module Name: Spi
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


module Spi #(
    parameter DATA_WIDTH = 8
)(
    input                       clk,
    input                       resetn,
    input   [DATA_WIDTH-1:0]     din,
    input   [15:0]              dvsr, //0.5*(# clk in SCK period)
    input                       start,
    input                       cpol,
    input                       cpha,
    output  [DATA_WIDTH-1:0]     dout,
    output                      spi_done_tick,
    output                      ready,

    //spi interface
    output                      sclk,
    input                       miso,
    output                      mosi    
);

    //fsm state type
    localparam  idle        = 2'b00,
                cpha_delay  = 2'b01,
                p0          = 2'b10,
                p1          = 2'b11;

    //define variable
    reg [1:0] state_reg, state_next;
    wire p_clk; // Thay reg bằng wire vì dùng assign
    reg [15:0] c_reg, c_next;
    reg spi_clk_reg; 
    wire spi_clk_next; // Thay reg bằng wire vì dùng assign
    reg ready_i; 
    reg spi_done_tick_i;
    reg [2:0] n_reg, n_next;
    reg [DATA_WIDTH-1:0] si_reg, si_next;
    reg [DATA_WIDTH-1:0] so_reg, so_next;

    /////////BODY//////////////
    //fsm for transmitting one byte

    //sequential circuit
    always @(posedge clk, negedge resetn) begin
        if (~resetn) begin
            state_reg       <= idle;
            c_reg           <= 0;
            spi_clk_reg     <= 0;
            n_reg           <= 0;
            si_reg          <= 0;
            so_reg          <= 0;
        end
        else begin
            state_reg       <= state_next;
            c_reg           <= c_next;
            spi_clk_reg     <= spi_clk_next;
            n_reg           <= n_next;
            si_reg          <= si_next;
            so_reg          <= so_next;
        end
    end

    //comb circuit
    always @(state_reg) begin
        //default state
        state_next       = state_reg;
        c_next           = c_reg;
        ready_i          = 0;
        spi_done_tick_i  = 0;
        n_next           = n_reg;
        si_next          = si_reg;
        so_next          = so_reg;
        //spi_clk_next     = spi_clk_reg;

        case (state_reg)
            idle: begin
                ready_i = 1;
                if (start) begin
                    so_next = din;
                    c_next  = 0;
                    n_next  = 0;
                    if (cpha) begin
                        state_next = cpha_delay;
                    end
                    else state_next = p0;
                end
            end
            cpha_delay: begin
                if (c_reg == dvsr) begin
                    state_next  = p0;
                    c_next      = 0;
                end   
                //else c_next = c_reg + 1;
            end
            p0: begin
                if (c_reg == dvsr) begin // sclk 0 to 1
                    state_next = p1;
                    si_next = {si_reg[DATA_WIDTH-2:0], miso};
                    c_next = 0;
                end
                else c_next = c_reg + 1;
            end
            p1: begin
                if (c_reg == dvsr) begin
                    if (n_reg == DATA_WIDTH - 1) begin
                        spi_done_tick_i = 1;
                        state_next = idle;
                    end
                    else begin
                        so_next = {so_reg[DATA_WIDTH-2:0], 1'b0};
                        state_next = p0;
                        n_next = n_reg + 1;
                        c_next = 0;
                    end
                end
                else c_next = c_reg + 1;
            end 
            default: state_next = idle;
        endcase
    end

    // Tính toán p_clk và spi_clk_next bằng assign
    assign p_clk = (state_next == p1 && ~cpha) || (state_next == p0 && cpha);
    assign spi_clk_next = (cpol) ? ~p_clk : p_clk;

    //output
    assign ready = ready_i;
    assign spi_done_tick = spi_done_tick_i;
    assign dout = si_reg;
    assign mosi = (ready_i) ? 0 : so_reg[DATA_WIDTH-1];
    assign sclk = spi_clk_reg;

endmodule