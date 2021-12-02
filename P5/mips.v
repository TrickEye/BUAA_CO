`timescale 1ns / 1ps
`include "Head.v"

module mips (
    input clk,
    input reset
);


    wire [31 : 0] IF_NPC, IF_PC4, IF_PC, IF_Instr;
	
    wire [31 : 0] ID_PC, ID_PC4, ID_Instr, ID_ReadDataA, ID_ReadDataB, ID_ExtOut;
    wire [`CmpOut_LEN - 1 : 0] ID_CmpOut, EX_CmpOut, MEM_CmpOut, WB_CmpOut;
    wire [`NPCOp_LEN - 1 : 0] ID_NPCOp;
    wire [`Extender_Op_Len -1 : 0] ID_ExtOp;
	
	wire [31 : 0] EX_PC, EX_PC4, EX_Instr, EX_ReadDataA, EX_ReadDataB, EX_ExtOut;
    wire EX_ALUZero;
    wire [31 : 0] EX_ALUResult;
    wire [`ALUSrc_LEN - 1 : 0] EX_ALUSrc;
    wire [`ALUOp_LEN - 1 : 0] EX_ALUOp; 

    wire [31 : 0] Mem_PC, Mem_PC4, Mem_Instr, Mem_ALUResult, Mem_ReadDataA, Mem_ReadDataB;
    wire [31 : 0] Mem_ReadData;
    wire [`MemWrite_LEN-1 : 0] Mem_MemWrite;
    wire Mem_WE;
	
	wire [31 : 0] WB_PC, WB_PC4, WB_Instr, WB_ReadData, WB_ReadDataA, WB_ReadDataB, WB_ALUResult;
    wire [`WhatToReg_LEN - 1 : 0] WB_WhatToReg;
    wire [`ToWhatReg_LEN - 1 : 0] WB_ToWhatReg;

    wire [31 : 0] ID_ReadDataA_beforeFW, ID_ReadDataB_beforeFW;
    wire [31 : 0] EX_ReadDataA_beforeFW, EX_ReadDataB_beforeFW;
    wire [31 : 0] Mem_ReadDataA_beforeFW, Mem_ReadDataB_beforeFW;
    wire [4 : 0] FWAddr_ID_EX, FWAddr_EX_MEM, FWAddr_MEM_WB;
    wire [31 : 0] FWValue_ID_EX, FWValue_EX_MEM, FWValue_MEM_WB;

    wire Stall;

    wire CmpOut1;

///////////////////////////////////////////////////////////////////////////////////////////////////
//  Pipeline Stage1
//  Instruction Fetch

    NPC NextPC(
        .NPCOp          (ID_NPCOp),    
        .CmpResult      (ID_CmpOut),   
        .JumpRegister   (ID_ReadDataA),
        .Instr          (ID_Instr),    
        .PC             (IF_PC),
        .ID_PC          (ID_PC),
        .Stall          (Stall),
        .CmpOut1        (CmpOut1),
    
        .NPC            (IF_NPC),
        .PCPlus4        (IF_PC4)
    );
    
    IFU InstructionFetchUnit(
        .clk            (clk),
        .reset          (reset),
        .NPC            (IF_NPC),
		
        .Instr          (IF_Instr),
        .PC             (IF_PC)
    );

///////////////////////////////////////////////////////////////////////////////////////////////////
//  Pipeline Stage 2
//  Instrction Decode & Register Read

    wire [3 : 0] Tuse1, Tuse2;
    wire [4 : 0] Addr1, Addr2;
    wire [3 : 0] Tnew_EX, Tnew_MEM, Tnew_WB;
    wire [4 : 0] AddrNew_EX, AddrNew_MEM, AddrNew_WB;

    IF_IDReg IF_ID_register(
        .clk            (clk),
        .reset          (reset),
        .PC             (IF_PC),
        .PC4            (IF_PC4),
        .Instr          (IF_Instr),
        .Stall          (Stall),

        .ID_PC          (ID_PC),
        .ID_PC4         (ID_PC4),
        .ID_Instr       (ID_Instr)
    );
	
    CTRL Controller_ID(
        .Instr          (ID_Instr),
        .Stage          (`Stage_ID),
        
        .NPCOp          (ID_NPCOp),
        .ExtOp          (ID_ExtOp),
        .Tuse1          (Tuse1),
        .Tuse2          (Tuse2),
        .Addr1          (Addr1),
        .Addr2          (Addr2)
    );

    assign Stall = (Addr1 && Addr1 == AddrNew_EX  && Tuse1 < Tnew_EX ) |
                   (Addr1 && Addr1 == AddrNew_MEM && Tuse1 < Tnew_MEM) |
                   (Addr1 && Addr1 == AddrNew_WB  && Tuse1 < Tnew_WB ) |
                   (Addr2 && Addr2 == AddrNew_EX  && Tuse1 < Tnew_EX ) |
                   (Addr2 && Addr2 == AddrNew_MEM && Tuse1 < Tnew_MEM) |
                   (Addr2 && Addr2 == AddrNew_WB  && Tuse1 < Tnew_WB ) ;

	CMP Comparer(
		.DataA          (ID_ReadDataA), // leave room for forwarding
        .DataB          (ID_ReadDataB), // leave room for forwarding
		
        .CmpOut         (ID_CmpOut),
        .CmpOut1        (CmpOut1)
	);
	
    GRF GlabalRegisterFile(
        .clk            (clk),
        .reset          (reset),
        .PC             (WB_PC),
        .AddrA          (ID_Instr[25 : 21]),
        .AddrB          (ID_Instr[20 : 16]),
        .AddrC          ((WB_ToWhatReg == `ToWhatReg_20_16) ? WB_Instr[20 : 16] :
                         (WB_ToWhatReg == `ToWhatReg_15_11) ? WB_Instr[15 : 11] :
                         (WB_ToWhatReg == `ToWhatReg_31)    ? 5'd31 :
                         (WB_ToWhatReg == `ToWhatReg_BGEZAL) ? ((WB_CmpOut1) ? 5'd31 : 0) :
                         0), // need WB stage
        .WriteData      ((WB_WhatToReg == `WhatToReg_ALU) ? WB_ALUResult :
                         (WB_WhatToReg == `WhatToReg_Mem) ? WB_ReadData :
                         (WB_WhatToReg == `WhatToReg_PC4) ? WB_PC4 + 4: // + 4 to fill the delayed branch gap
                         //(WB_WhatToReg == `WhatToReg_BGEZAL) ? ( ??? WB_PC4 + 4)) ////////////////////////////////////////////////////////////////
                         0), // need WB stage
        .WriteEnable    (1), // Combined ToWhatReg with WriteEnable, if not enabled, AddrC = 0;
		
        .ReadDataA      (ID_ReadDataA_beforeFW),
        .ReadDataB      (ID_ReadDataB_beforeFW)
    );

    assign ID_ReadDataA = (ID_Instr[25 : 21] && ID_Instr[25 : 21] == FWAddr_ID_EX) ? FWValue_ID_EX :
                          (ID_Instr[25 : 21] && ID_Instr[25 : 21] == FWAddr_EX_MEM) ? FWValue_EX_MEM :
                          (ID_Instr[25 : 21] && ID_Instr[25 : 21] == FWAddr_MEM_WB) ? FWValue_MEM_WB :
                          ID_ReadDataA_beforeFW;

    assign ID_ReadDataB = (ID_Instr[20 : 16] && ID_Instr[20 : 16] == FWAddr_ID_EX) ? FWValue_ID_EX :
                          (ID_Instr[20 : 16] && ID_Instr[20 : 16] == FWAddr_EX_MEM) ? FWValue_EX_MEM :
                          (ID_Instr[20 : 16] && ID_Instr[20 : 16] == FWAddr_MEM_WB) ? FWValue_MEM_WB :
                          ID_ReadDataB_beforeFW;

    EXT Extender(
        .Orig           (ID_Instr[15 : 0]),
        .ExtOp          (ID_ExtOp), // need Ctrl
        .Input          (0),
		
        .Result         (ID_ExtOut)
    );


///////////////////////////////////////////////////////////////////////////////////////////////////
//  Pipeline Stage 3
//  Execution


    ID_EXReg ID_EX_register(
        .clk            (clk),
        .reset          (reset),
        .PC             (ID_PC),
        .PC4            (ID_PC4),
        .Instr          (ID_Instr),
        .ReadDataA      (ID_ReadDataA), // leave room for forwarding
        .ReadDataB      (ID_ReadDataB), // leave room for forwarding
        .ExtenderOut    (ID_ExtOut),
        .Stall          (Stall),
        .CmpOut1        (CmpOut1),

        .FWAddr         (FWAddr_ID_EX),
        .FWValue        (FWValue_ID_EX),
        
        .EX_PC          (EX_PC),
        .EX_PC4         (EX_PC4),
        .EX_Instr       (EX_Instr),
        .EX_ReadDataA   (EX_ReadDataA_beforeFW),
        .EX_ReadDataB   (EX_ReadDataB_beforeFW),
        .EX_ExtenderOut (EX_ExtOut),
        .EX_CmpOut1     (EX_CmpOut1)
    );

    assign EX_ReadDataA = (EX_Instr[25 : 21] && EX_Instr[25 : 21] == FWAddr_EX_MEM) ? FWValue_EX_MEM :
                          (EX_Instr[25 : 21] && EX_Instr[25 : 21] == FWAddr_MEM_WB) ? FWValue_MEM_WB :
                          EX_ReadDataA_beforeFW;
    assign EX_ReadDataB = (EX_Instr[20 : 16] && EX_Instr[20 : 16] == FWAddr_EX_MEM) ? FWValue_EX_MEM :
                          (EX_Instr[20 : 16] && EX_Instr[20 : 16] == FWAddr_MEM_WB) ? FWValue_MEM_WB :
                          EX_ReadDataB_beforeFW;

                        

    CTRL Controller_Ex(
        .Instr          (EX_Instr),
        .Stage          (`Stage_EX),

        .ALUOp          (EX_ALUOp),
        .ALUSrc         (EX_ALUSrc),
        .Tnew           (Tnew_EX),
        .AddrNew        (AddrNew_EX)
    );

    ALU AlgorithmAndLogisticsUnit(
        .ALUOp          (EX_ALUOp), // need Ctrl
        .NumberA        (EX_ReadDataA),
        .NumberB        (EX_ALUSrc == `ALUSrc_Ext   ? EX_ExtOut :
                         EX_ALUSrc == `ALUSrc_20_16 ? EX_ReadDataB : 
                         0), // need Ctrl
    //  output
        .ALUZero        (EX_ALUZero),
        .ALUResult      (EX_ALUResult)
    );


///////////////////////////////////////////////////////////////////////////////////////////////////
//  Pipeline Stage 4
//  Memory Read And Write



    EX_MEMReg EX_MEM_register(
        .clk            (clk),
        .reset          (reset),
        .PC             (EX_PC),
        .PC4            (EX_PC4),
        .Instr          (EX_Instr),
        .ALUResult      (EX_ALUResult),
        .ReadDataA      (EX_ReadDataA),
        .ReadDataB      (EX_ReadDataB),
        .CmpOut1        (EX_CmpOut1),
		
        .FWAddr         (FWAddr_EX_MEM),
        .FWValue        (FWValue_EX_MEM),

        .Mem_PC         (Mem_PC),
        .Mem_PC4        (Mem_PC4),
        .Mem_Instr      (Mem_Instr),
        .Mem_ALUResult  (Mem_ALUResult),
        .Mem_ReadDataA  (Mem_ReadDataA),
        .Mem_ReadDataB  (Mem_ReadDataB_beforeFW),
        .Mem_CmpOut1    (Mem_CmpOut1)
    );

    assign Mem_ReadDataB = (Mem_Instr[20 : 16] && Mem_Instr[20 : 16] == FWAddr_MEM_WB) ? FWValue_MEM_WB :
                           Mem_ReadDataB_beforeFW;

    CTRL Controller_Mem(
        .Instr          (Mem_Instr),
        .Stage          (`Stage_MEM),

        .MemWrite       (Mem_MemWrite),
        .MemWE          (Mem_WE),
        .Tnew           (Tnew_MEM),
        .AddrNew        (AddrNew_MEM)
    );

    DM DataMem(
        .clk            (clk),
        .reset          (reset),
        .PC             (Mem_PC),
        .Addr           (Mem_ALUResult),
        .WriteData      (Mem_ReadDataB),
        .MemType       (Mem_MemWrite),
        .WE             (Mem_WE),

        .ReadData       (Mem_ReadData)
    );

///////////////////////////////////////////////////////////////////////////////////////////////////
//  Pipeline Stage 5
//  Write Back


    MEM_WBReg MEM_WB_register(
        .clk            (clk),
        .reset          (reset),

        .PC             (Mem_PC),
        .PC4            (Mem_PC4),
        .Instr          (Mem_Instr),
        .ReadData       (Mem_ReadData),
        .ReadDataA      (Mem_ReadDataA),
        .ReadDataB      (Mem_ReadDataB),
        .ALUResult      (Mem_ALUResult),
        .CmpOut1        (Mem_CmpOut1),
		
        .FWAddr         (FWAddr_MEM_WB),
        .FWValue        (FWValue_MEM_WB),
		
        .WB_PC          (WB_PC),
        .WB_PC4         (WB_PC4),
        .WB_Instr       (WB_Instr),
        .WB_ReadData    (WB_ReadData),
        .WB_ReadDataA   (WB_ReadDataA),
        .WB_ReadDataB   (WB_ReadDataB),
        .WB_ALUResult   (WB_ALUResult),
        .WB_CmpOut1     (WB_CmpOut1)
    );

    CTRL Controller_WB(
        .Instr          (WB_Instr),
        .Stage          (`Stage_WB),

        .ToWhatReg      (WB_ToWhatReg),
        .WhatToReg      (WB_WhatToReg),
        .Tnew           (Tnew_WB),
        .AddrNew        (AddrNew_WB)
    );


endmodule