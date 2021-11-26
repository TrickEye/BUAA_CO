//  ALU
`define ALUCtrl_Len     4
`define ALUCtrl_Add     1
`define ALUCtrl_Sub     2
`define ALUCtrl_And     3
`define ALUCtrl_Or      4
`define ALUCtrl_AlessB  5
`define ALUCtrl_ALorEB  6
`define ALUCtrl_Undefined 7

//  NPC
`define NPCCtrl_Len     4
`define NPCCtrl_BEQ     1
`define NPCCtrl_JAL     2
`define NPCCtrl_JR      3

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

`define RegDst_Len          4
`define RegDst_Undefined    0
`define RegDst_15_11        1
`define RegDst_20_16        2
`define RegDst_31           3
`define RegDst_Mem          4

`define WhatToReg_Len       4
`define WhatToReg_ALU       1
`define WhatToReg_Mem       2
`define WhatToReg_PCPlus4   3
`define WhatToReg_Undefined 0

`define ALUSrc_Len          4
`define ALUSrc_Undefined    0
`define ALUSrc_20_16        1
`define ALUSrc_EXT          2

`define Branch_Ctrl_Len     4
`define Branch_Undefined    0
`define Branch_Equal        1
`define Branch_Less         2
`define Branch_LorE         3
`define Branch_Gret         4
`define Branch_GorE         5

//  Extender
`define Extender_Op_Len 4
`define Ext_Zero_Left   1
`define Ext_One_Left    2
`define Ext_Sign_Left   3
`define Ext_Input_Left  4
`define Ext_Zero_Right  5
`define Ext_One_Right   6
`define Ext_LSB_Right   7
`define Ext_Input_Right 8

