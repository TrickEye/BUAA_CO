// CMP:
`define ALargerThan0    8'b10000000
`define AEqual0         8'b01000000 
`define BLargerThan0    8'b00100000 
`define BEqual0         8'b00010000 
`define ALargerThanB    8'b00001000 
`define AEqualB         8'b00000100 
`define ALessThanB      8'b00000010 
`define CMP_Undefined   8'b00000000

// NPC
`define NPC_normal      1
`define NPC_beq         2
`define NPC_bne         3
`define NPC_bgt         4
`define NPC_bge         5
`define NPC_blt         6
`define NPC_ble         7
`define NPC_j           8
`define NPC_jr          9
`define NPC_blez        10
`define NPC_bgtz        11
`define NPC_bez         12
`define NPC_bnez        13
`define NPC_bltz        14
`define NPC_bgez        15

// EXT:
`define EXT_0L          1
`define EXT_1L          2
`define EXT_0R          3
`define EXT_1R          4
`define EXT_SL          5
`define EXT_SR          6
`define EXT_IL          7
`define EXT_IR          8

// ALU
`define ALU_add         1
`define ALU_sub         2
`define ALU_and         3
`define ALU_or          4
`define ALU_sl          5
`define ALU_srl         6
`define ALU_sra         7
`define ALU_xor         8
`define ALU_nor         9
`define ALU_slt         10
`define ALU_sltu        11

// Hilo
`define Hilo_mult       1
`define Hilo_div        2
`define Hilo_ToHi       3
`define Hilo_ToLo       4
`define Hilo_multu      5
`define Hilo_divu       6

// DM
`define dm_Irr          0
`define dm_B            1
`define dm_H            2
`define dm_W            3
`define dm_BU           4
`define dm_HU           5
`define dm_WU           6
`define dm_SB           7
`define dm_SH           8
`define dm_SW           9

// TWR
`define TWR_1511 1
`define TWR_2016 2
`define TWR_31   3
`define TWR_Irr  0

// WTR
`define WTR_aluout 1
`define WTR_hi     2
`define WTR_lo     3
`define WTR_mem    4
`define WTR_pc4    5
`define WTR_Irr    6

// ALUS
`define ALUS_2521  1
`define ALUS_2016  2
`define ALUS_ext   3
`define ALUS_shamt 4
`define ALUS_Irr   5

// Stage
`define Stage_F 1
`define Stage_D 2
`define Stage_E 3
`define Stage_M 4
`define Stage_W 5