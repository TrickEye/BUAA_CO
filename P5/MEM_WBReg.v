`timescale 1ns/1ps
`include "Head.v"

module MEM_WBReg(
    input clk,
    input reset,
    input [31: 0] PC,
    input [31: 0] PC4,
    input [31: 0] Instr,
    input [31: 0] ReadData,
    input [31: 0] ReadDataA,
    input [31: 0] ReadDataB,
    input [31: 0] ALUResult,
    input CmpOut1,

    output [4 : 0] FWAddr,
    output [31 : 0] FWValue,

    output reg [31: 0] WB_PC,
    output reg [31: 0] WB_PC4,
    output reg [31: 0] WB_Instr,
    output reg [31: 0] WB_ReadData,
    output reg [31: 0] WB_ReadDataA,
    output reg [31: 0] WB_ReadDataB,
    output reg [31: 0] WB_ALUResult,
    output reg WB_CmpOut1

);

    always @(posedge clk) begin
        if (reset == 1) begin
            WB_PC               = 0;
            WB_PC4              = 0;
            WB_Instr            = 0;
            WB_ReadData         = 0;
            WB_ReadDataA        = 0;
            WB_ReadDataB        = 0;
            WB_ALUResult        = 0;  
            WB_CmpOut1 = 0;     
        end
        else begin
            WB_PC               = PC;
            WB_PC4              = PC4;
            WB_Instr            = Instr;
            WB_ReadData         = ReadData;
            WB_ReadDataA        = ReadDataA;
            WB_ReadDataB        = ReadDataB;
            WB_ALUResult        = ALUResult;
            WB_CmpOut1 = CmpOut1;
        end
    end

    assign LW   = (WB_Instr[31 : 26] == `Ctrl_LW     ) ? 1 : 0;
    assign ADDU = (WB_Instr[31 : 26] == `Ctrl_Special && WB_Instr[5 : 0] == `Ctrl_ADDU_S) ? 1 : 0;
    assign SUBU = (WB_Instr[31 : 26] == `Ctrl_Special && WB_Instr[5 : 0] == `Ctrl_SUBU_S) ? 1 : 0;
    assign ORI  = (WB_Instr[31 : 26] == `Ctrl_ORI    ) ? 1 : 0;
    assign JAL  = (WB_Instr[31 : 26] == `Ctrl_JAL    ) ? 1 : 0;
    assign LUI  = (WB_Instr[31 : 26] == `Ctrl_LUI    ) ? 1 : 0;
    
    assign FWAddr  = (LW | ORI | LUI) ? WB_Instr[20 : 16] :
                     (ADDU | SUBU) ?    WB_Instr[15 : 11] :
                     (JAL) ?            31 :
                     0;
    
    assign FWValue = (LW)                      ? WB_ReadData  :
                     (ADDU | SUBU | ORI | LUI) ? WB_ALUResult :
                     (JAL)                     ? WB_PC4 + 4 : 
                     0;

endmodule