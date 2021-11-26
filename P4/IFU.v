`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    16:11:06 11/12/2021 
// Design Name: 
// Module Name:    IFU 
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
module IFU(
    input [31:0] NPC,
    output [31:0] Instr,
    output reg [31:0] PC,
    input clk,
    input reset,
    output [4:0] Instr25_21,
    output [4:0] Instr20_16,
    output [4:0] Instr15_11,
    output [15:0] Instr15_0,
    output [25:0] Instr26_0,
    output [5:0] Instr31_26,
    output [5:0] Instr5_0,
    output [4:0] Instr10_6
    );

    reg [31:0] InstrMem [0:1023];

    initial begin
        PC = 32'h0000_3000;
        $readmemh("code.txt", InstrMem);
    end

    assign Instr = InstrMem[PC[11:2]];
    assign Instr25_21 = Instr[25:21];
    assign Instr20_16 = Instr[20:16];
    assign Instr15_11 = Instr[15:11];
    assign Instr15_0  = Instr[15:0];
    assign Instr26_0  = Instr[25:0];
    assign Instr31_26 = Instr[31:26];
    assign Instr5_0   = Instr[5:0];
    assign Instr10_6  = Instr[10:6];

    always @(posedge clk) begin
        if (reset == 1) begin
            PC <= 32'h0000_3000;
        end
        else begin 
            PC <= NPC;
        end
    end

endmodule
