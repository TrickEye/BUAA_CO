`timescale 1ns/1ps
`include "_signal.v"
`include "_const.v"

module CTRL (
    input wire [31:0] instr,
    input wire [31:0] stage,
    output [10:0] npcop,
    output [10:0] extop,
    output [10:0] TWR,
    output [10:0] WTR,
    output [10:0] alus1,
    output [10:0] alus2,
    output [10:0] aluop,
    output [10:0] hiloop,
    output [10:0] dmop,
    output [10:0] Tnew,
    output [6:0]  Anew,
    output [10:0] Tuse1,
    output [6:0]  Ause1,
    output [10:0] Tuse2,
    output [6:0]  Ause2,
	output E_start
);
    wire LB, LBU, LH, LHU, LW, SB, SH, SW, ADD, ADDU, SUB, SUBU, MULT, MULTU, DIV, DIVU, SLL, SRL, SRA, SLLV, SRLV, SRAV, AND, OR, XOR, NOR, ADDI, ADDIU, ANDI, ORI, XORI, LUI, SLT, SLTI, SLTIU, SLTU, BEQ, BNE, BLEZ, BGTZ, BLTZ, BGEZ, J, JAL, JALR, JR, MFHI, MFLO, MTHI, MTLO;
    assign LB       = (instr[31:26] == `LB    );
    assign LBU      = (instr[31:26] == `LBU   );
    assign LH       = (instr[31:26] == `LH    );
    assign LHU      = (instr[31:26] == `LHU   );
    assign LW       = (instr[31:26] == `LW    );
    assign SB       = (instr[31:26] == `SB    );
    assign SH       = (instr[31:26] == `SH    );
    assign SW       = (instr[31:26] == `SW    );
    assign ADD      = (instr[31:26] == `Special && instr[5:0] == `ADD_S  );
    assign ADDU     = (instr[31:26] == `Special && instr[5:0] == `ADDU_S );
    assign SUB      = (instr[31:26] == `Special && instr[5:0] == `SUB_S  );
    assign SUBU     = (instr[31:26] == `Special && instr[5:0] == `SUBU_S );
    assign MULT     = (instr[31:26] == `Special && instr[5:0] == `MULT_S );
    assign MULTU    = (instr[31:26] == `Special && instr[5:0] == `MULTU_S);
    assign DIV      = (instr[31:26] == `Special && instr[5:0] == `DIV_S  );
    assign DIVU     = (instr[31:26] == `Special && instr[5:0] == `DIVU_S );
    assign SLL      = (instr[31:26] == `Special && instr[5:0] == `SLL_S  );
    assign SRL      = (instr[31:26] == `Special && instr[5:0] == `SRL_S  );
    assign SRA      = (instr[31:26] == `Special && instr[5:0] == `SRA_S  );
    assign SLLV     = (instr[31:26] == `Special && instr[5:0] == `SLLV_S );
    assign SRLV     = (instr[31:26] == `Special && instr[5:0] == `SRLV_S );
    assign SRAV     = (instr[31:26] == `Special && instr[5:0] == `SRAV_S );
    assign AND      = (instr[31:26] == `Special && instr[5:0] == `AND_S  );
    assign OR       = (instr[31:26] == `Special && instr[5:0] == `OR_S   );
    assign XOR      = (instr[31:26] == `Special && instr[5:0] == `XOR_S  );
    assign NOR      = (instr[31:26] == `Special && instr[5:0] == `NOR_S  );
    assign ADDI     = (instr[31:26] == `ADDI  );
    assign ADDIU    = (instr[31:26] == `ADDIU );
    assign ANDI     = (instr[31:26] == `ANDI  );
    assign ORI      = (instr[31:26] == `ORI   );
    assign XORI     = (instr[31:26] == `XORI  );
    assign LUI      = (instr[31:26] == `LUI   );
    assign SLT      = (instr[31:26] == `Special && instr[5:0] == `SLT_S  );
    assign SLTI     = (instr[31:26] == `SLTI  );
    assign SLTIU    = (instr[31:26] == `SLTIU );
    assign SLTU     = (instr[31:26] == `Special && instr[5:0] == `SLTU_S );
    assign BEQ      = (instr[31:26] == `BEQ   );
    assign BNE      = (instr[31:26] == `BNE   );
    assign BLEZ     = (instr[31:26] == `BLEZ  );
    assign BGTZ     = (instr[31:26] == `BGTZ  );
    assign BLTZ     = (instr[31:26] == `Regimm && instr[20:16] == `BLTZ_R );
    assign BGEZ     = (instr[31:26] == `Regimm && instr[20:16] == `BGEZ_R );
    assign J        = (instr[31:26] == `J     );
    assign JAL      = (instr[31:26] == `JAL   );
    assign JALR     = (instr[31:26] == `Special && instr[5:0] == `JALR_S );
    assign JR       = (instr[31:26] == `Special && instr[5:0] == `JR_S   );
    assign MFHI     = (instr[31:26] == `Special && instr[5:0] == `MFHI_S );
    assign MFLO     = (instr[31:26] == `Special && instr[5:0] == `MFLO_S );
    assign MTHI     = (instr[31:26] == `Special && instr[5:0] == `MTHI_S );
    assign MTLO     = (instr[31:26] == `Special && instr[5:0] == `MTLO_S );

    assign npcop = (BEQ) ? `NPC_beq : 
                   (BNE) ? `NPC_bne :
                   (BGEZ) ? `NPC_bgez : 
                   (BGTZ) ? `NPC_bgtz :
                   (BLEZ) ? `NPC_blez :
                   (BLTZ) ? `NPC_bltz :
                   //(BNEZ) ? `NPC_bnez :
                   (J | JAL) ? `NPC_j :
                   (JR | JALR) ? `NPC_jr :
                   `NPC_normal;
    
    assign extop = (ANDI | ORI | XORI) ? `EXT_0L :
                   (LUI) ? `EXT_0R :
                   (LB | LBU | LH | LHU | LW | SB | SH | SW | ADDI | ADDIU | SLTI | SLTIU) ? `EXT_SL : 
                   `EXT_0L;

    assign TWR = (JALR | ADD | ADDU | SUB | SUBU | SLL | SRL | SRA | SLLV | SRLV | SRAV | AND | OR | XOR | NOR | SLT | SLTU | MFHI | MFLO) ? `TWR_1511 :
                 (ANDI | ORI | XORI | LUI | LB | LBU | LH | LHU | LW | ADDI | ADDIU | SLTI | SLTIU) ? `TWR_2016 :
                 (JAL) ? `TWR_31 :
                 (BEQ | BGEZ | BGTZ | BLEZ | BLTZ | BNE | J | JR | MULT | MULTU | DIV | DIVU | MTHI | MTLO | SB | SH | SW) ? `TWR_Irr :
                 `TWR_Irr;

    assign WTR = (ADD | ADDU | SUB | SUBU | SLL | SRL | SRA | SLLV | SRLV | SRAV | AND | OR | XOR | NOR | SLT | SLTU | ANDI | ORI | XORI | LUI | ADDI | ADDIU | SLTI | SLTIU) ? `WTR_aluout :
                 (MFHI) ? `WTR_hi :
                 (MFLO) ? `WTR_lo :
                 (LB | LBU | LH | LHU | LW) ? `WTR_mem :
                 (JALR | JAL) ? `WTR_pc4 :
                 `WTR_Irr;
    
    assign alus1 = (SLL | SRL | SRA | SLLV | SRLV | SRAV) ? `ALUS_2016 :
                   (ADD | ADDU | SUB | SUBU | AND | OR | XOR | NOR | SLT | SLTU | ANDI | ORI | XORI | LUI | ADDI | ADDIU | SLTI | SLTIU | SB | SH | SW | LB | LBU | LH | LHU | LW) ? `ALUS_2521 :
                   `ALUS_Irr;

    assign alus2 = (SLL | SRL | SRA) ? `ALUS_shamt :
                   (SLLV | SRLV | SRAV) ? `ALUS_2521 :
                   (ADD | ADDU | SUB | SUBU | AND | OR | XOR | NOR | SLT | SLTU) ? `ALUS_2016 :
                   (ANDI | ORI | XORI | LUI | ADDI | ADDIU | SLTI | SLTIU | SB | SH | SW | LB | LBU | LH | LHU | LW) ? `ALUS_ext :
                   `ALUS_Irr;
    
    assign aluop = (ADD | ADDU | ADDI | ADDIU | SB | SH | SW | LB | LBU | LH | LHU | LW) ? `ALU_add :
                   (AND | ANDI) ? `ALU_and :
                   (NOR) ? `ALU_nor :
                   (OR | ORI | LUI) ? `ALU_or :
                   (SLL | SLLV) ? `ALU_sl :
                   (SLT | SLTI) ? `ALU_slt :
                   (SLTU | SLTIU) ? `ALU_sltu :
                   (SRA | SRAV) ? `ALU_sra :
                   (SRL | SRLV) ? `ALU_srl :
                   (SUB | SUBU) ? `ALU_sub :
                   (XOR | XORI) ? `ALU_xor :
                   0;
        
    assign hiloop = (DIV) ? `Hilo_div :
                    (DIVU) ? `Hilo_divu :
                    (MULT) ? `Hilo_mult :
                    (MULTU) ? `Hilo_multu :
                    (MTHI) ? `Hilo_ToHi :
                    (MTLO) ? `Hilo_ToLo :
                    0;

    assign dmop = (LB) ? `dm_B :
                  (LBU) ? `dm_BU :
                  (LH) ? `dm_H :
                  (LHU) ? `dm_HU :
                  (LW) ? `dm_W :
                  (SB) ? `dm_SB :
                  (SH) ? `dm_SH :
                  (SW) ? `dm_SW :
                  `dm_Irr;

    assign Tnew = (BEQ | BGEZ | BGTZ | BLEZ | BLTZ | BNE | J | JR | SB | SH | SW) ? 0 :
                  (LUI | JALR | JALR | JAL) ? (stage == `Stage_D ? 1 : 0) : 
                  (ADD | ADDU | ADDI | ADDIU | AND | ANDI | NOR | OR | ORI | SLL | SLLV | SLT | SLTI | SLTU | SLTIU | SRA | SRAV | SRL | SRLV | SUB | SUBU | XOR | XORI | MFHI | MFLO) ? (stage == `Stage_D ? 2 : stage == `Stage_E ? 1 : 0) :
                  (LB | LBU | LH | LHU | LW) ? (stage == `Stage_D ? 3 : stage == `Stage_E ? 2 : stage == `Stage_M ? 1 : 0) : 
                  6;
    assign Anew = (BEQ | BGEZ | BGTZ | BLEZ | BLTZ | BNE | J | JR | SB | SH | SW) ? 0 :
                  (JAL) ? 31 :
                  (JALR | ADD | ADDU | AND | NOR | OR | SLL | SLLV | SLT | SLTU | SRA | SRAV | SRL | SRLV | SUB | SUBU | XOR | MFHI | MFLO) ? instr[15:11] :
                  (LUI | ADDI | ADDIU | ANDI | ORI | XORI | LB | LBU | LH | LHU | LW | SLTI | SLTIU) ? instr[20:16] :
                  //(MTHI | DIV | DIVU | MULT | MULTU | MTLO) ? 6'b100000 :
                  0;
    
    assign Tuse1 = (BEQ | BGEZ | BGTZ | BLEZ | BLTZ | BNE | J | JR | MFHI | MFLO | JAL | JALR) ? 0 :
                   (SB | SH | SW | ADD | ADDU | AND | NOR | OR | SLL | SLLV | SLT | SLTI | SLTU | SLTIU | SRA | SRAV | SRL | SRLV | SUB | SUBU | XOR | LUI | ADDI | ADDIU | ANDI | ORI | XORI | LB | LBU | LH | LHU | LW | MTHI | DIV | DIVU | MULT | MULTU | MTLO) ? 1 :
                   0;
    assign Ause1 = (J | JAL) ? 0 :
                   (SLL | SLLV | SRA | SRAV | SRL | SRLV) ? instr[20:16] :
                   (BEQ | BGEZ | BGTZ | BLEZ | BLTZ | BNE | JR | JALR | SB | SH | SW | ADD | ADDU | AND | NOR | OR | SLT | SLTI | SLTU | SLTIU | SUB | SUBU | XOR | LUI | ADDI | ADDIU | ANDI | ORI | XORI | LB | LBU | LH | LHU | LW) ? instr[25:21] :
                   (DIV | DIVU | MULT | MULTU) ? {{1'b1}, {instr[25:21]}} :
                   (MFHI | MFLO) ? 6'b100000 :
                   (MTHI | MTLO) ? {{1'b1}, {instr[25:21]}} :
                   0;
    assign Tuse2 = (J | JAL | SLL | SRA | SRL | BEQ | BGEZ | BGTZ | BLEZ | BLTZ | BNE | JR | JALR | SLTI | SLTIU | LUI | ADDI | ADDIU | ANDI | ORI | XORI | LB | LBU | LH | LHU | LW | MTHI | MTLO | MFHI | MFLO) ? 0 :
                   (SLLV | SRAV | SRLV | ADD | ADDU | AND | NOR | OR | SLT | SLTU | SUB | SUBU | XOR | DIV | DIVU | MULT | MULTU) ? 1 :
                   (SB | SH | SW) ? 2 :
                   0;
    assign Ause2 = (BGTZ | BLEZ | BLTZ | BNE | ADD | ADDU | AND | NOR | OR | SLT | SLTU | SUB | SUBU | XOR | DIV | DIVU | MULT | MULTU | SB | SH | SW) ? instr[20:16] :
                   (SLLV | SRAV | SRLV) ? instr[25 : 21] :
                   0;

    assign E_start = (MULT | MULTU | DIV | DIVU);
    
                   
endmodule


