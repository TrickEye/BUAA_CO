`timescale 1ns/1ps 
`include "Head.v"

module IF_IDReg (
    input clk,
    input reset,
    input [31 : 0] PC,
    input [31 : 0] PC4,
    input [31 : 0] Instr,
    input Stall,

    output reg [31 : 0] ID_PC,
    output reg [31 : 0] ID_PC4,
    output reg [31 : 0] ID_Instr
);

    always @(posedge clk) begin
        if (reset == 1) begin
            ID_PC = 0;//32'h0000_3000;
            ID_PC4 = 0;//32'h0000_3004;
            ID_Instr = 0;
        end
        else if (!Stall) begin
            ID_PC = PC;
            ID_PC4 = PC4;
            ID_Instr = Instr;
        end
    end

endmodule