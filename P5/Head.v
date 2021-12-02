//  Controller
`define Ctrl_Special    6'b000000
`define Ctrl_ADDU_S     6'b100001
`define Ctrl_SUBU_S     6'b100011
`define Ctrl_ORI        6'b001101
`define Ctrl_LW         6'b100011
`define Ctrl_SW         6'b101011
`define Ctrl_BEQ        6'b000100
`define Ctrl_LUI        6'b001111
`define Ctrl_JAL        6'b000011
`define Ctrl_JR_S       6'b001000
`define Ctrl_NOP_S      6'b000000
`define Ctrl_J          6'b000010
`define Ctrl_BGEZAL     6'b000001 
`define Ctrl_BGEZAL_2   5'b10001

`define Stage_LEN       4
`define Stage_IF        0
`define Stage_ID        1
`define Stage_EX        2
`define Stage_MEM       3
`define Stage_WB        4

`define ToWhatReg_LEN   4
`define ToWhatReg_None  0
`define ToWhatReg_15_11 1
`define ToWhatReg_20_16 2
`define ToWhatReg_31    3
`define ToWhatReg_BGEZAL 4

`define WhatToReg_LEN   4
`define WhatToReg_None  0
`define WhatToReg_ALU   1
`define WhatToReg_Mem   2
`define WhatToReg_PC4   3
`define WhatToReg_BGEZAL 4

`define ALUSrc_LEN      4
`define ALUSrc_None     0
`define ALUSrc_20_16    1
`define ALUSrc_Ext      2

//  Next PC Logic
`define NPCOp_LEN       4
`define NPCOp_Normal    0
`define NPCOp_Stall     1
`define NPCOp_BranchEq  2   // Equal
`define NPCOp_BranchLt  3   // Less than
`define NPCOp_BranchLE  4   // Less or Equal
`define NPCOp_BranchGt  5   // Greater than
`define NPCOp_BranchGE  6   // Greater ot Equal
`define NPCOp_BranchNE  7   // Not Equal
`define NPCOp_JumpImm   8   
`define NPCOp_JumpReg   9
`define NPCOp_BGEZAL    10

//  Comparer
`define CmpOut_LEN          3
`define CmpOut_Eq           0
`define CmpOut_Less         1   // A less than B
`define CmpOut_Greater      2   // A greater than B    
`define CmpOut_Undefined    3   // Shouldn't see that.

//  Extender
`define Extender_Op_Len     4
`define Ext_Undefined  0
`define Ext_Zero_Left       1
`define Ext_One_Left        2
`define Ext_Sign_Left       3
`define Ext_Input_Left      4
`define Ext_Zero_Right      5
`define Ext_One_Right       6
`define Ext_LSB_Right       7
`define Ext_Input_Right     8

//  ALU
`define ALUOp_LEN     4
`define ALUOp_Add     1
`define ALUOp_Sub     2
`define ALUOp_And     3
`define ALUOp_Or      4
`define ALUOp_AlessB  5
`define ALUOp_ALorEB  6
`define ALUOp_Undefined 7

`define MemWrite_LEN  4
`define MemWrite_None 0
`define MemWrite_W    1
`define MemWrite_H    2
`define MemWrite_B    3
