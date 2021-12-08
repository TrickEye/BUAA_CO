`timescale 1ns/1ps
//`default_nettype none
`include "_signal.v"

module mips(
    input wire clk,
    input wire reset,
    input wire [31:0] i_inst_rdata,
    input wire [31:0] m_data_rdata,
    output [31:0] i_inst_addr,
    output [31:0] m_data_addr,
    output [31:0] m_data_wdata,
    output [3 :0] m_data_byteen,
    output [31:0] m_inst_addr,
    output w_grf_we,
    output [4:0] w_grf_addr,
    output [31:0] w_grf_wdata,
    output [31:0] w_inst_addr
);

	reg  [31:0] F_pc;
	wire [31:0] D_pc, E_pc, M_pc, W_pc;
    wire [31:0] F_npc;
	wire [31:0] F_instr, D_instr, E_instr, M_instr, W_instr;
	wire [31:0] D_rdata1, E_rdata1, M_rdata1, W_rdata1;
    wire [31:0] D_rdata2, E_rdata2, M_rdata2, W_rdata2;
    wire [31:0] D_rdata1_beforeFW, E_rdata1_beforeFW, M_rdata1_beforeFW, W_rdata1_beforeFW;
    wire [31:0] D_rdata2_beforeFW, E_rdata2_beforeFW, M_rdata2_beforeFW, W_rdata2_beforeFW;
    wire [7:0]  D_cmpresult, E_cmpresult, M_cmpresult, W_cmpresult;
    wire [31:0] D_extout, E_extout, M_extout, W_extout;
    wire [31:0] E_aluout, M_aluout, W_aluout;
    wire [31:0] E_hi, M_hi, W_hi;
    wire [31:0] E_lo, M_lo, W_lo;
    wire E_hiloBusy;
    wire [31:0] M_dmout, W_dmout;

    wire [10:0] D_npcop;
    wire [10:0] D_extop;
    wire [10:0] D_Tuse1, D_Tuse2;
    wire [6:0]  D_Ause1, D_Ause2;

    wire [10:0] E_alus1, E_alus2, E_aluop, E_hiloop;
    wire [10:0] E_Tnew;
    wire [6:0]  E_Anew;

    wire [10:0] M_dmop;
    wire [10:0] M_Tnew;
    wire [6:0]  M_Anew;

    wire [10:0] W_TWR, W_WTR;
    wire [10:0] W_Tnew;
    wire [6:0]  W_Anew;

    wire [31:0] E_fw_v, M_fw_v, W_fw_v;
    wire [4:0]  E_fw_a, M_fw_a, W_fw_a; 
	wire E_Will_Use_hilo;
	wire STALL;

    //  F  /////////////////////////////////////////////////////////////////////////////////////////
    

    always @(posedge clk) begin
        F_pc <= (reset) ? 32'h0000_3000 : F_npc;
    end
    assign F_instr = i_inst_rdata;
    assign i_inst_addr = F_pc;

    //  D  /////////////////////////////////////////////////////////////////////////////////////////

    D_REG d_reg(
        .clk            (clk),
        .reset          (reset),
        .in_stall       (STALL),   // nd
        .in_enable      (1'b1),       // We haven't met the scenario where we must disable the register
        .in_instr       (F_instr),
        .in_pc          (F_pc),

        .out_instr      (D_instr),
        .out_pc         (D_pc)
    );

    CTRL d_ctrl(
        .instr          (D_instr),
        .stage          (`Stage_D),
        .npcop          (D_npcop),
        .extop          (D_extop),
        .TWR            (),    
        .WTR            (),    
        .alus1          (),
        .alus2          (),
        .aluop          (),
        .hiloop         (),
        .dmop           (),
        .Tnew           (),
        .Anew           (),
        .Tuse1          (D_Tuse1),
        .Ause1          (D_Ause1),
        .Tuse2          (D_Tuse2),
        .Ause2          (D_Ause2)
    );

    assign STALL = (E_Anew && (D_Ause1[4:0] == E_Anew[4:0]) && (D_Tuse1 < E_Tnew)) |
                   (M_Anew && (D_Ause1[4:0] == M_Anew[4:0]) && (D_Tuse1 < M_Tnew)) |
                   (W_Anew && (D_Ause1[4:0] == W_Anew[4:0]) && (D_Tuse1 < W_Tnew)) |
                   (E_Anew && (D_Ause2[4:0] == E_Anew[4:0]) && (D_Tuse2 < E_Tnew)) |
                   (M_Anew && (D_Ause2[4:0] == M_Anew[4:0]) && (D_Tuse2 < M_Tnew)) |
                   (W_Anew && (D_Ause2[4:0] == W_Anew[4:0]) && (D_Tuse2 < W_Tnew)) |
                   (D_Ause1[5] == 1 && (E_hiloBusy | E_Will_Use_hilo))|
                   (D_Ause2[5] == 1 && (E_hiloBusy | E_Will_Use_hilo));

    assign stall1 = (E_Anew && (D_Ause1[4:0] == E_Anew[4:0]) && (D_Tuse1 < E_Tnew));
    assign stall2 = (M_Anew && (D_Ause1[4:0] == M_Anew[4:0]) && (D_Tuse1 < M_Tnew));
    assign stall3 = (W_Anew && (D_Ause1[4:0] == W_Anew[4:0]) && (D_Tuse1 < W_Tnew));
    assign stall4 = (E_Anew && (D_Ause2[4:0] == E_Anew[4:0]) && (D_Tuse2 < E_Tnew));
    assign stall5 = (M_Anew && (D_Ause2[4:0] == M_Anew[4:0]) && (D_Tuse2 < M_Tnew));
    assign stall6 = (W_Anew && (D_Ause2[4:0] == W_Anew[4:0]) && (D_Tuse2 < W_Tnew));

	D_NPC d_npc(
		.clk 			(clk),
        .reset          (reset),
        .in_instr       (D_instr),
        .in_Fpc         (F_pc),
        .in_Dpc         (D_pc),
        .in_npcop       (D_npcop), 
        .in_stall       (STALL),   // not defined
        .in_jrdata      (D_rdata1),
        .in_cmpresult   (D_cmpresult),
        .out_pc         (F_npc)
	);

	assign w_grf_we = 1;
    assign w_grf_addr = (W_TWR == `TWR_31 ? 31 :
                         W_TWR == `TWR_2016 ? W_instr[20:16] :
                         W_TWR == `TWR_1511 ? W_instr[15:11] :
                         0);
    assign w_grf_wdata = (W_WTR == `WTR_hi ? W_hi :
                         W_WTR == `WTR_lo ? W_lo :
                         W_WTR == `WTR_aluout ? W_aluout :
                         W_WTR == `WTR_mem ? W_dmout :
                         W_WTR == `WTR_pc4 ? W_pc + 8 :
                         0);
    assign w_inst_addr = W_pc;

    D_GRF d_grf(
        .clk            (clk),
        .reset          (reset),
        .in_raddr1      (D_instr[25:21]),
        .in_raddr2      (D_instr[20:16]),
        .in_waddr       (w_grf_addr),        
        .in_wdata       (w_grf_wdata),         
        .in_we          (1),
        .out_rdata1     (D_rdata1_beforeFW),
        .out_rdata2     (D_rdata2_beforeFW)
    );

    assign D_rdata1 = (D_instr[25:21] && (D_instr[25:21] == E_fw_a)) ? E_fw_v :
                      (D_instr[25:21] && (D_instr[25:21] == M_fw_a)) ? M_fw_v :
                      (D_instr[25:21] && (D_instr[25:21] == w_grf_addr) && w_grf_we) ? w_grf_wdata :
                      D_rdata1_beforeFW;
    assign D_rdata2 = (D_instr[20:16] && (D_instr[20:16] == E_fw_a)) ? E_fw_v :
                      (D_instr[20:16] && (D_instr[20:16] == M_fw_a)) ? M_fw_v :
                      (D_instr[20:16] && (D_instr[20:16] == w_grf_addr) && w_grf_we) ? w_grf_wdata :
                      D_rdata2_beforeFW;

    D_CMP d_cmp(
        .in_pc          (D_pc),
        .in_instr       (D_instr),
        .in_num1        (D_rdata1),
        .in_num2        (D_rdata2),
        .out_cmpresult  (D_cmpresult)
    );

    D_EXT d_ext(
        .in_pc          (D_pc),
        .in_instr       (D_instr),
        .in_extop       (D_extop),        
        .in_orig        (D_instr[15:0]),
        .in_fill        (0),
        .out_extout     (D_extout)
    );

    //  E  /////////////////////////////////////////////////////////////////////////////////////////

    E_REG e_reg(
        .clk            (clk),
        .reset          (reset),
        .in_stall       (STALL),    // nd
        .in_enable      (1),
        .in_instr       (D_instr),
        .in_pc          (D_pc),
        .in_cmpresult   (D_cmpresult),
        .in_rdata1      (D_rdata1),
        .in_rdata2      (D_rdata2),
        .in_extout      (D_extout),
        .out_instr      (E_instr),
        .out_pc         (E_pc),
        .out_cmpresult  (E_cmpresult),
        .out_rdata1     (E_rdata1_beforeFW),
        .out_rdata2     (E_rdata2_beforeFW),
        .out_extout     (E_extout),
        .fw_v           (E_fw_v),
        .fw_a           (E_fw_a),
        .Will_Use_hilo  (E_Will_Use_hilo)
    );

    assign E_rdata1 = (E_instr[25:21] && (E_instr[25:21] == M_fw_a)) ? M_fw_v :
                      (E_instr[25:21] && (E_instr[25:21] == w_grf_addr) && w_grf_we) ? w_grf_wdata :
                      E_rdata1_beforeFW;
    assign E_rdata2 = (E_instr[20:16] && (E_instr[20:16] == M_fw_a)) ? M_fw_v :
                      (E_instr[20:16] && (E_instr[20:16] == w_grf_addr) && w_grf_we) ? w_grf_wdata :
                      E_rdata2_beforeFW;

    CTRL e_ctrl(
        .instr          (E_instr),
        .stage          (`Stage_E),
        //.npcop          (),
        //.extop          (),
        //.TWR            (),    
        //.WTR            (),    
        .alus1          (E_alus1),
        .alus2          (E_alus2),
        .aluop          (E_aluop),
        .hiloop         (E_hiloop),
        //.dmop           (),
        .Tnew           (E_Tnew),
        .Anew           (E_Anew)
        //.Tuse1          (),
        //.Ause1          (),
        //.Tuse2          (),
        //.Ause2          ()
    );

    E_ALU e_alu(
        .in_pc          (E_pc),
        .in_instr       (E_instr),
        .in_num1        (E_alus1 == `ALUS_2521 ? E_rdata1 :
                         E_alus1 == `ALUS_2016 ? E_rdata2 :
                         E_alus1 == `ALUS_shamt? {{27'd0}, {E_instr[10:6]}} : 0),        
        .in_num2        (E_alus2 == `ALUS_2521 ? E_rdata1 :
                         E_alus2 == `ALUS_2016 ? E_rdata2 :
                         E_alus2 == `ALUS_ext  ? E_extout :
                         E_alus2 == `ALUS_shamt? {{27'd0}, {E_instr[10:6]}} : 0),        
        .in_aluop       (E_aluop),        
        .out_aluout     (E_aluout)
    );

    E_HILO e_hilo(
        .clk            (clk),
        .reset          (reset),
        .in_pc          (E_pc),
        .in_instr       (E_instr),
        .in_num1        (E_rdata1),
        .in_num2        (E_rdata2),
        .in_hiloOp      (E_hiloop),         // wait for op
        .out_hi         (E_hi),
        .out_lo         (E_lo),
        .out_hiloBusy   (E_hiloBusy)
    );

    //  M  /////////////////////////////////////////////////////////////////////////////////////////

    M_REG m_reg(
        .clk            (clk),
        .reset          (reset),
        .in_stall       (STALL),         // wait for stall
        .in_enable      (1),
        .in_instr       (E_instr),
        .in_pc          (E_pc),
        .in_cmpresult   (E_cmpresult),
        .in_rdata1      (E_rdata1),
        .in_rdata2      (E_rdata2),
        .in_extout      (E_extout),
        .in_aluout      (E_aluout),
        .in_hi          (E_hi),
        .in_lo          (E_lo),
        .out_instr      (M_instr),
        .out_pc         (M_pc),
        .out_cmpresult  (M_cmpresult),
        .out_rdata1     (M_rdata1_beforeFW),
        .out_rdata2     (M_rdata2_beforeFW),
        .out_extout     (M_extout),
        .out_aluout     (M_aluout),
        .out_hi         (M_hi),
        .out_lo         (M_lo),
        .fw_v           (M_fw_v),
        .fw_a           (M_fw_a)
    );

    assign M_rdata1 = (M_instr[25:21] && (M_instr[25:21] == w_grf_addr) && w_grf_we) ? w_grf_wdata :
               M_rdata1_beforeFW;
    assign M_rdata2 = (M_instr[20:16] && (M_instr[20:16] == w_grf_addr) && w_grf_we) ? w_grf_wdata :
               M_rdata2_beforeFW;

    CTRL m_ctrl(
        .instr          (M_instr),
        .stage          (`Stage_M),
        //.npcop          (),
        //.extop          (),
        //.TWR            (),    
        //.WTR            (),    
        //.alus1          (),
        //.alus2          (),
        //.aluop          (),
        //.hiloop         (),
        .dmop           (M_dmop),
        .Tnew           (M_Tnew),
        .Anew           (M_Anew)
        //.Tuse1          (),
        //.Ause1          (),
        //.Tuse2          (),
        //.Ause2          ()
    );

    M_DM m_dm(
        .clk            (clk),
        .reset          (reset),
        .in_pc          (M_pc),
        .in_instr       (M_instr),
        .in_wdata       (M_rdata2),
        .in_dmop        (M_dmop),         
        .in_addr        (M_aluout),
        .m_data_addr    (m_data_addr),
        .m_data_wdata   (m_data_wdata),
        .m_data_byteen  (m_data_byteen),
        .m_inst_addr    (m_inst_addr),
        .m_data_rdata   (m_data_rdata),
        .out_dmout      (M_dmout)
    );

    //  M  /////////////////////////////////////////////////////////////////////////////////////////

    W_REG w_reg(
        .clk            (clk),
        .reset          (reset),
        .in_stall       (STALL),
        .in_enable      (1),
        .in_instr       (M_instr),
        .in_pc          (M_pc),
        .in_cmpresult   (M_cmpresult),
        .in_rdata1      (M_rdata1),
        .in_rdata2      (M_rdata2),
        .in_extout      (M_extout),
        .in_aluout      (M_aluout),
        .in_hi          (M_hi),
        .in_lo          (M_lo),
        .in_dmout       (M_dmout),
        .out_instr      (W_instr),
        .out_pc         (W_pc),
        .out_cmpresult  (W_cmpresult),
        .out_rdata1     (W_rdata1),
        .out_rdata2     (W_rdata2),
        .out_extout     (W_extout),
        .out_aluout     (W_aluout),
        .out_hi         (W_hi),
        .out_lo         (W_lo),
        .out_dmout      (W_dmout)
    );

    CTRL w_ctrl(
        .instr          (W_instr),
        .stage          (`Stage_W),
        //.npcop          (),
        //.extop          (),
        .TWR            (W_TWR),    
        .WTR            (W_WTR),    
        //.alus1          (),
        //.alus2          (),
        //.aluop          (),
        //.hiloop         (),
        //.dmop           (),
        .Tnew           (W_Tnew),
        .Anew           (W_Anew)
        //.Tuse1          (),
        //.Ause1          (),
        //.Tuse2          (),
        //.Ause2          ()
    );

endmodule

