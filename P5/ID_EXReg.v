`timescale 1ns/1ps
`include "Head.v"

module ID_EXReg(
    input clk,
    input reset,
    input [31 : 0] PC,
    input [31 : 0] PC4,
    input [31 : 0] Instr,
    input [31 : 0] ReadDataA,
    input [31 : 0] ReadDataB,
    input [31 : 0] ExtenderOut,
    input  CmpOut1,
    input Stall,
	
    output [4 : 0] FWAddr,
    output [31 : 0] FWValue,
    
    output reg [31 : 0] EX_PC,
    output reg [31 : 0] EX_PC4,
    output reg [31 : 0] EX_Instr,
    output reg [31 : 0] EX_ReadDataA,
    output reg [31 : 0] EX_ReadDataB,
    output reg [31 : 0] EX_ExtenderOut,
    output reg  EX_CmpOut1
);

    always @(posedge clk) begin
        if (reset == 1 || Stall) begin
            EX_PC = 0;
            EX_PC4 = 0;
            EX_Instr = 0;
            EX_ReadDataA = 0;
            EX_ReadDataB = 0;
            EX_ExtenderOut = 0;
            EX_CmpOut1 = 0;
        end
        else begin
            EX_PC = PC;
            EX_PC4 = PC4;
            EX_Instr = Instr;
            EX_ReadDataA = ReadDataA;
            EX_ReadDataB = ReadDataB;
            EX_ExtenderOut = ExtenderOut;
            EX_CmpOut1 = CmpOut1;
        end
    end

    assign JAL = (EX_Instr[31 : 26] == `Ctrl_JAL    ) ? 1 : 0;
    assign LUI = (EX_Instr[31 : 26] == `Ctrl_LUI    ) ? 1 : 0;

    assign FWAddr  = (JAL) ? 31 :
                     (LUI) ? EX_Instr[20 : 16] :
                     0;

    assign FWValue = (JAL) ? EX_PC4 + 4 :
                     (LUI) ? EX_ExtenderOut :
                     0;

endmodule