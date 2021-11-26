`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    13:54:21 11/12/2021 
// Design Name: 
// Module Name:    mips 
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
`include "Head.v"
module mips(
    input clk,
    input reset
    );
	
	wire [31:0] PC, NextPC, PCPlus4, Instr, ReadData, ReadDataA, ReadDataB, ALUResult, ExtenderOut;
	wire [4:0] Instr25_21, Instr20_16, Instr15_11, Instr10_6;
    wire [15:0] Instr15_0;
    wire [25:0] Instr26_0;
    wire [5:0] Instr31_26, Instr5_0;

    wire [`NPCCtrl_Len - 1 : 0] NPCOp;
    wire [`Branch_Ctrl_Len - 1 : 0] BranchCondition;
    wire [`RegDst_Len - 1 : 0] RegDst;
    wire [`ALUSrc_Len - 1 : 0] ALUSrc;
    wire [`Extender_Op_Len - 1 : 0] ExtOp;
    wire [`ALUCtrl_Len - 1 : 0] ALUCtrl;
    wire [`WhatToReg_Len - 1 : 0] WhatToReg;

    wire RegWrite, MemWrite, ALUZero;
	
	NPC NextProgramCounterGenerator (
    //  input:
    .NPCOp              (NPCOp), 
    .BranchAsserted     ((BranchCondition == `Branch_Equal && ALUZero == 1) ? 1 : 
                                                                              0), 
    .BranchImmediate    (Instr15_0), 
    .JImmediate         (Instr26_0), 
    .JRInput            (ReadDataA), 
    .CurrentPC          (PC), 
    //  output:
    .NextPC             (NextPC), 
    .PCPlus4            (PCPlus4)
    );
	
	IFU InstructionFetchUnit (
    //  input:
    .NPC                (NextPC),  
    .clk                (clk), 
    .reset              (reset), 
    //  output:
    .Instr              (Instr), 
    .PC                 (PC),
    .Instr25_21         (Instr25_21), 
    .Instr20_16         (Instr20_16), 
    .Instr15_11         (Instr15_11), 
    .Instr15_0          (Instr15_0), 
    .Instr26_0          (Instr26_0), 
    .Instr31_26         (Instr31_26), 
    .Instr5_0           (Instr5_0), 
    .Instr10_6          (Instr10_6)
    );

	Controller Ctrl (
    //  input:
    .OpCode             (Instr31_26), 
    .Funct              (Instr5_0),  
    //  output:
    .NPCOp              (NPCOp), 
    .BranchCondition    (BranchCondition), 
    .RegDst             (RegDst), 
    .ALUSrc             (ALUSrc), 
    .WhatToReg          (WhatToReg), 
    .RegWrite           (RegWrite), 
    .MemWrite           (MemWrite), 
    .ExtOp              (ExtOp), 
    .ALUCtrl            (ALUCtrl)
    );

	GRF GlobalRegisterFile (
    //  input:
    .PC                 (PC),
    .AddrA              (Instr25_21), 
    .AddrB              (Instr20_16), 
    .AddrC              ((RegDst == `RegDst_20_16) ? Instr20_16 : 
                         (RegDst == `RegDst_15_11) ? Instr15_11 :
                         (RegDst == `RegDst_31)    ? 31         :
                         (RegDst == `RegDst_Undefined) ? 0      : 
                                                         0), 
    .WriteData          ((WhatToReg == `WhatToReg_Mem)          ? ReadData   :
                         (WhatToReg == `WhatToReg_ALU)          ? ALUResult  :
                         (WhatToReg == `WhatToReg_PCPlus4)      ? PCPlus4    :
                         (WhatToReg == `WhatToReg_Undefined)    ? 0          :
                                                                  0), 
    .WriteEnable        (RegWrite), 
    .clk                (clk), 
    .reset              (reset), 
    //  output:
    .ReadDataA          (ReadDataA), 
    .ReadDataB          (ReadDataB)
    );

    EXT Extender (
    //  input:
    .Orig               (Instr15_0), 
    .ExtOp              (ExtOp), 
    .Input              (0),        //This is not used
    //  output: 
    .Result             (ExtenderOut)
    );
    
    ALU AlgoRithmAndLogisticsUnit (
    //  input:
    .ALUCtrl            (ALUCtrl), 
    .NumberA            (ReadDataA), 
    .NumberB            ((ALUSrc == `ALUSrc_20_16) ? ReadDataB      :
                         (ALUSrc == `ALUSrc_EXT)   ? ExtenderOut    :
                         (ALUSrc == `ALUSrc_Undefined) ? 0          :
                                                         0), 
    //  output:
    .ALUZero            (ALUZero), 
    .ALUResult          (ALUResult)
    );

    DM DataMemory (
    //  input:
    .PC                 (PC),
    .Addr               (ALUResult), 
    .Data               (ReadDataB), 
    .Clk                (clk), 
    .reset              (reset), 
    .WriteEnable        (MemWrite), 
    //  output:
    .ReadData           (ReadData)
    );


endmodule
