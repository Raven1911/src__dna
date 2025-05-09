`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01/03/2025 02:57:13 PM
// Design Name: 
// Module Name: fifo_ctrl
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


module fifo_ctrl_dna(
    input clk, reset,
    input wr, rd,
    input [6:0] ADDR_WIDTH,
    output [31 : 0] w_addr,
    output [31 : 0] r_addr
    );

    //variable sequential
    reg [31 : 0] w_ptr, w_ptr_next;
    reg [31 : 0] r_ptr, r_ptr_next;
 


    // sequential circuit
    always @(posedge clk, posedge reset) begin
        if(reset)begin
            w_ptr <= 2 ** ADDR_WIDTH - 1;
            r_ptr <= 'b0;
        end else begin
            w_ptr <= w_ptr_next;
            r_ptr <= r_ptr_next;
        end

    end

    //combi circuit
    always @(*)begin
        //default
        w_ptr_next = w_ptr;
        r_ptr_next = r_ptr;
        if(wr) w_ptr_next = w_ptr ==  2 ** ADDR_WIDTH - 1 ? 'b0 : w_ptr + 'b1;
        if(rd) r_ptr_next = (r_ptr ==  2 ** ADDR_WIDTH - 1) ? 'b0 : r_ptr + 'b1;
//        if(rd) r_ptr_next = r_ptr + 1'b1 == w_ptr ? r_ptr : (r_ptr ==  2 ** ADDR_WIDTH - 1 ? 'b0 : r_ptr + 'b1);
    end

    //output
    assign w_addr = w_ptr;
    assign r_addr = r_ptr;

endmodule