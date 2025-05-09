`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/05/2025 07:15:37 PM
// Design Name: 
// Module Name: enable
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


module enable(
    input clk,
    input rst,
    input start,
    input signal,
    output en
    );
    reg wr, rd;
    assign en = ~(rd == wr);
    always @(posedge clk, posedge rst) begin
        if(rst) begin
            wr <= 1'b0;
            rd <= 1'b0;
        end else begin
            if(start) rd <= rd + 1'b1;
            if(signal) wr <= wr + 1'b1;
        end     
    end
endmodule
