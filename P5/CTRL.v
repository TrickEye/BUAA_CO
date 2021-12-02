`timescale 1ns/1ps
`include "Head.v"
module CTRL (
    input [31 : 0] Instr,
    input [`Stage_LEN - 1 : 0] Stage,

    output [`NPCOp_LEN - 1 : 0] NPCOp,
    output [`ToWhatReg_LEN - 1 : 0] ToWhatReg,
    output [`WhatToReg_LEN - 1 : 0] WhatToReg,
    output [`MemWrite_LEN - 1: 0] MemWrite,
    output MemWE,
    output [`ALUSrc_LEN - 1 : 0] ALUSrc,
    output [`ALUOp_LEN - 1 : 0] ALUOp,
    output [`Extender_Op_Len - 1 : 0] ExtOp,
    output [3 : 0] Tuse1, 
    output [3 : 0] Tuse2,
    output [4 : 0] Addr1,
    output [4 : 0] Addr2,
    output [3 : 0] Tnew, 
    output [4 : 0] AddrNew
);

    assign ADDU    = (Instr[31 : 26] == `Ctrl_Special && Instr[5 : 0] == `Ctrl_ADDU_S) ? 1 : 0;
    assign SUBU    = (Instr[31 : 26] == `Ctrl_Special && Instr[5 : 0] == `Ctrl_SUBU_S) ? 1 : 0;
    assign ORI     = (Instr[31 : 26] == `Ctrl_ORI    ) ? 1 : 0;
    assign LW      = (Instr[31 : 26] == `Ctrl_LW     ) ? 1 : 0;
    assign SW      = (Instr[31 : 26] == `Ctrl_SW     ) ? 1 : 0;
    assign BEQ     = (Instr[31 : 26] == `Ctrl_BEQ    ) ? 1 : 0;
    assign LUI     = (Instr[31 : 26] == `Ctrl_LUI    ) ? 1 : 0;
    assign JAL     = (Instr[31 : 26] == `Ctrl_JAL    ) ? 1 : 0;
    assign JR      = (Instr[31 : 26] == `Ctrl_Special && Instr[5 : 0] == `Ctrl_JR_S ) ? 1 : 0;
    assign NOP     = (Instr[31 : 26] == `Ctrl_Special && Instr[5 : 0] == `Ctrl_NOP_S) ? 1 : 0;
    assign J       = (Instr[31 : 26] == `Ctrl_J      ) ? 1 : 0;
    assign BGEZAL  = (Instr[31 : 26] == `Ctrl_BGEZAL  && Instr[20 : 16] == `Ctrl_BGEZAL_2) ? 1:0;

    assign NPCOp =      (ADDU | SUBU | ORI | LW | SW | LUI | NOP) ? `NPCOp_Normal :
                        (BEQ)                                     ? `NPCOp_BranchEq :
                        (BGEZAL)                                  ? `NPCOp_BGEZAL :
                        (JAL | J)                                 ? `NPCOp_JumpImm :
                        (JR)                                      ? `NPCOp_JumpReg :
                        0;

    assign ToWhatReg = (ADDU | SUBU)    ? `ToWhatReg_15_11 :
                       (ORI | LW | LUI) ? `ToWhatReg_20_16 :
                       (JAL)            ? `ToWhatReg_31    :
                       (BGEZAL) ? `ToWhatReg_BGEZAL :
                       `ToWhatReg_None;

    assign WhatToReg = (ADDU | SUBU | ORI | LUI) ? `WhatToReg_ALU :
                       (LW)                      ? `WhatToReg_Mem :
                       (JAL | BGEZAL)                     ? `WhatToReg_PC4 :
                       //(BGEZAL)                  ? `WhatToReg_BGEZAL :
                       `WhatToReg_None;
    
    assign MemWrite =   (SW | LW) ? `MemWrite_W : // MemType
                        `MemWrite_None;

    assign MemWE = SW;

    assign ALUSrc =     (ADDU | SUBU) ?          `ALUSrc_20_16 :
                        (ORI | LW | SW | LUI) ?  `ALUSrc_Ext :
                        `ALUSrc_None;

    assign ALUOp =      (ADDU | LW | SW) ?       `ALUOp_Add :
                        (SUBU) ?                  `ALUOp_Sub :
                        (ORI | LUI) ?                  `ALUOp_Or :
                        `ALUOp_Undefined;

    assign ExtOp =      (ORI) ? `Ext_Zero_Left :
                        (LW | SW | BEQ | BGEZAL) ? `Ext_Sign_Left :
                        (LUI) ? `Ext_Zero_Right :
                        `Ext_Undefined;

    assign Tnew  =      (ADDU | SUBU | ORI) ?   (
                                                    (Stage == `Stage_ID) ? 2 :
                                                    (Stage == `Stage_EX) ? 1 :
                                                    0
                                                ) :
                        (LW) ?                  (
                                                    (Stage == `Stage_ID ) ? 3 :
                                                    (Stage == `Stage_EX ) ? 2 :
                                                    (Stage == `Stage_MEM) ? 1 :
                                                    0
                                                ) :     
                        (LUI | JAL) ?           (
                                                    (Stage == `Stage_ID)  ? 1 :
                                                    0
                                                ) :
                        6;

    assign AddrNew =    (ADDU | SUBU) ? Instr[15 : 11] :
                        (ORI | LW | LUI) ? Instr[20 : 16] :
                        (JAL | BGEZAL) ? 31 :
                        0;

    assign Tuse1 =      (ADDU | SUBU | ORI | LW | SW ) ? 1 :
                        (BEQ | JR | BGEZAL) ? 0 :
                        0;
    
    assign Addr1 =      (ADDU | SUBU | ORI | LW | SW | BEQ | JR | BGEZAL) ? Instr[25:21] :
                        0;

    assign Tuse2 =      (ADDU | SUBU) ? 1 :
                        (SW) ? 2 :
                        (BEQ) ? 0 :
                        0;

    assign Addr2 =      (ADDU | SUBU | SW | BEQ) ? Instr[20:16] :
                        0;

endmodule