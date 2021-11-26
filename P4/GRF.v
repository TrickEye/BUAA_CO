`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    15:33:08 11/12/2021 
// Design Name: 
// Module Name:    GRF 
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
module GRF(
    input [31:0] PC,
    input [4:0] AddrA,
    input [4:0] AddrB,
    input [4:0] AddrC,
    input [31:0] WriteData,
    input WriteEnable,
    input clk,
    input reset,
    output [31:0] ReadDataA,
    output [31:0] ReadDataB
    );

    reg [31:0] GlobalRegisterFile [31:0];
	
	integer i = 0;
	
    initial begin
        for (i = 0; i < 32; i = i + 1) GlobalRegisterFile[i] <= 0;
    end

    always @(posedge clk) begin
        if (reset == 1) begin
            for (i = 0; i <= 31; i = i + 1) GlobalRegisterFile[i] <= 0;
        end
        else if (WriteEnable == 1) begin
            if (AddrC != 0) begin
                GlobalRegisterFile[AddrC] <= WriteData;
            end
            $display("@%h: $%d <= %h", PC, AddrC, WriteData);
        end
    end

    assign ReadDataA = GlobalRegisterFile[AddrA];
    assign ReadDataB = GlobalRegisterFile[AddrB];

endmodule
