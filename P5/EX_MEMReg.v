`timescale 1ns/1ps
`include "Head.v"

module EX_MEMReg(
    input clk, 
    input reset,
    input [31 : 0] PC,
    input [31 : 0] PC4,
    input [31 : 0] Instr,
    input [31 : 0] ALUResult,
    input [31 : 0] ReadDataA,
    input [31 : 0] ReadDataB,
    input CmpOut1,

    output [4 : 0] FWAddr,
    output [31 : 0] FWValue,

    output reg [31 : 0] Mem_PC,
    output reg [31 : 0] Mem_PC4,
    output reg [31 : 0] Mem_Instr,
    output reg [31 : 0] Mem_ALUResult,
    output reg [31 : 0] Mem_ReadDataA,
    output reg [31 : 0] Mem_ReadDataB,
    output reg Mem_CmpOut1
);

    always @(posedge clk) begin
        if (reset == 1) begin
            Mem_PC          = 0;
            Mem_PC4         = 0;
            Mem_Instr       = 0;
            Mem_ALUResult   = 0;
            Mem_ReadDataA   = 0;
            Mem_ReadDataB   = 0;
            Mem_CmpOut1 = 0;
        end
        else begin
            Mem_PC        = PC;
            Mem_PC4       = PC4;
            Mem_Instr     = Instr;
            Mem_ALUResult = ALUResult;
            Mem_ReadDataA = ReadDataA;
            Mem_ReadDataB = ReadDataB;
            Mem_CmpOut1 = CmpOut1;
        end
    end

    assign ADDU = (Mem_Instr[31 : 26] == `Ctrl_Special && Mem_Instr[5 : 0] == `Ctrl_ADDU_S) ? 1 : 0;
    assign SUBU = (Mem_Instr[31 : 26] == `Ctrl_Special && Mem_Instr[5 : 0] == `Ctrl_SUBU_S) ? 1 : 0;
    assign ORI  = (Mem_Instr[31 : 26] == `Ctrl_ORI    ) ? 1 : 0;
    assign JAL  = (Mem_Instr[31 : 26] == `Ctrl_JAL    ) ? 1 : 0;
    assign LUI  = (Mem_Instr[31 : 26] == `Ctrl_LUI    ) ? 1 : 0;

    assign FWAddr  = (ADDU | SUBU) ? Mem_Instr[15 : 11] :
                     (ORI | LUI) ?   Mem_Instr[20 : 16] :
                     (JAL) ?         31 :
                     0;

    assign FWValue = (ADDU | SUBU | ORI | LUI) ? Mem_ALUResult :
                     (JAL) ? Mem_PC4 + 4 :
                     0;

endmodule