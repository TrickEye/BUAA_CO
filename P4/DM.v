`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    13:10:15 11/13/2021 
// Design Name: 
// Module Name:    DM 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module DM(
    input [31:0] PC,
    input [31:0] Addr,
    input [31:0] Data,
    input Clk,
    input reset,
    input WriteEnable,
    output [31:0] ReadData
    );

    reg [31:0] DataMem [1023 : 0];
    integer i;

    always @(posedge Clk ) begin
        if (reset == 1) begin
            for (i = 0; i < 1024; i = i + 1) begin
                DataMem[i] = 0;
            end
        end
        if (WriteEnable == 1) begin
            DataMem[Addr[11:2]] = Data;
            $display("@%h: *%h <= %h", PC, Addr, Data);
        end
    end
    assign ReadData = DataMem[Addr[11:2]];
endmodule
