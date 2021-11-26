`timescale 1ns / 1ps
`include "Head.v"
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    20:42:53 11/12/2021 
// Design Name: 
// Module Name:    Controller 
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
module Controller(
    input [5:0] OpCode,
    input [5:0] Funct,
    output [`NPCCtrl_Len - 1 : 0] NPCOp,
    output [`Branch_Ctrl_Len - 1 : 0] BranchCondition,
    output [`RegDst_Len - 1 : 0] RegDst,    
    output [`ALUSrc_Len - 1 : 0]ALUSrc,
    // output MemToReg,
    output [`WhatToReg_Len - 1 : 0] WhatToReg,
    output RegWrite,
    output MemWrite,
    output [`Extender_Op_Len - 1 : 0] ExtOp,
    output [`ALUCtrl_Len - 1 : 0] ALUCtrl
    );

    assign ADDU = (OpCode == `Ctrl_Special) && (Funct == `Ctrl_ADDU_S);
    assign SUBU = (OpCode == `Ctrl_Special) && (Funct == `Ctrl_SUBU_S);
    assign ORI  = (OpCode == `Ctrl_ORI);
    assign LW   = (OpCode == `Ctrl_LW);
    assign SW   = (OpCode == `Ctrl_SW);
    assign BEQ  = (OpCode == `Ctrl_BEQ);
    assign LUI  = (OpCode == `Ctrl_LUI);
    assign JAL  = (OpCode == `Ctrl_JAL);
    assign JR   = (OpCode == `Ctrl_Special) && (Funct == `Ctrl_JR_S);
    assign NOP  = (OpCode == `Ctrl_Special) && (Funct == `Ctrl_NOP_S);

    assign NPCOp = BEQ       ? `NPCCtrl_BEQ : 
                   JAL       ? `NPCCtrl_JAL :
                   JR        ? `NPCCtrl_JR  :
                                0;

    assign BranchCondition = 
                        BEQ  ? `Branch_Equal :
                               `Branch_Undefined;
						
    assign RegDst =     ADDU ? `RegDst_15_11 : 
                        SUBU ? `RegDst_15_11 :
                        ORI  ? `RegDst_20_16 :
                        LW   ? `RegDst_20_16 :
                        SW   ? `RegDst_Undefined :
                        BEQ  ? `RegDst_Undefined :
                        LUI  ? `RegDst_20_16 :
                        JAL  ? `RegDst_31 :
                        JR   ? `RegDst_Undefined : 
                               `RegDst_Undefined;
						
    assign ALUSrc =     ADDU ? `ALUSrc_20_16 :
                        SUBU ? `ALUSrc_20_16 :
                        ORI  ? `ALUSrc_EXT :
                        LW   ? `ALUSrc_EXT :
                        SW   ? `ALUSrc_EXT :
                        BEQ  ? `ALUSrc_20_16 :
                        LUI  ? `ALUSrc_EXT :
                        JAL  ? `ALUSrc_Undefined :
                        JR   ? `ALUSrc_Undefined :
                               `ALUSrc_Undefined;
						
    // assign MemToReg =   LW;
    assign WhatToReg =  ADDU ? `WhatToReg_ALU :
                        SUBU ? `WhatToReg_ALU :
                        ORI  ? `WhatToReg_ALU :
                        LW   ? `WhatToReg_Mem :
                        SW   ? `WhatToReg_Undefined :
                        LUI  ? `WhatToReg_ALU :
                        JAL  ? `WhatToReg_PCPlus4 :
                        JR   ? `WhatToReg_Undefined :
                        `WhatToReg_Undefined;
	
    assign RegWrite =   ADDU |
                        SUBU |
                        ORI  |
                        LW   |
                        LUI  |
                        JAL;
						
    assign MemWrite =   SW;
	
    assign ExtOp =      ORI  ? `Ext_Zero_Left :
                        LW   ? `Ext_Sign_Left :
                        SW   ? `Ext_Sign_Left :
                        BEQ  ? `Ext_Sign_Left :
                        LUI  ? `Ext_Zero_Right :
                        0 ;

    assign ALUCtrl =    ADDU ? `ALUCtrl_Add :
                        SUBU ? `ALUCtrl_Sub :
                        ORI  ? `ALUCtrl_Or :
                        LW   ? `ALUCtrl_Add :
                        SW   ? `ALUCtrl_Add :
                        BEQ  ? `ALUCtrl_Sub :
                        LUI  ? `ALUCtrl_Or :
                        `ALUCtrl_Undefined;

endmodule
