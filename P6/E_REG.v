`timescale 1ns/1ps
`include "_const.v"

module E_REG(
    input clk,
    input reset,
    input in_stall,
    input in_enable,

    input [31:0] in_instr,
    input [31:0] in_pc,
    input [7:0]  in_cmpresult,
    input [31:0] in_rdata1,
    input [31:0] in_rdata2,
    input [31:0] in_extout,

    output reg [31:0] out_instr,
    output reg [31:0] out_pc,
    output reg [7:0]  out_cmpresult,
    output reg [31:0] out_rdata1,
    output reg [31:0] out_rdata2,
    output reg [31:0] out_extout,

    output [31:0] fw_v,
    output [4:0]  fw_a,
    output Will_Use_hilo
);

    always @(posedge clk) begin
        if (reset || in_stall) begin
            out_instr        <= 0;
            out_pc           <= 0;
            out_cmpresult    <= 0;
            out_rdata1       <= 0;
            out_rdata2       <= 0;
            out_extout       <= 0;
        end else begin
            out_instr        <= in_instr;
            out_pc           <= in_pc;
            out_cmpresult    <= in_cmpresult;
            out_rdata1       <= in_rdata1;
            out_rdata2       <= in_rdata2;
            out_extout       <= in_extout;
        end
    end

    assign JAL      = (out_instr[31:26] == `JAL   );
    assign JALR     = (out_instr[31:26] == `Special && out_instr[5:0] == `JALR_S );
    assign LUI      = (out_instr[31:26] == `LUI   );
    assign MULT     = (out_instr[31:26] == `Special && out_instr[5:0] == `MULT_S );
    assign MULTU    = (out_instr[31:26] == `Special && out_instr[5:0] == `MULTU_S);
    assign DIV      = (out_instr[31:26] == `Special && out_instr[5:0] == `DIV_S  );
    assign DIVU     = (out_instr[31:26] == `Special && out_instr[5:0] == `DIVU_S );
    assign MFHI     = (out_instr[31:26] == `Special && out_instr[5:0] == `MFHI_S );
    assign MFLO     = (out_instr[31:26] == `Special && out_instr[5:0] == `MFLO_S );
    assign MTHI     = (out_instr[31:26] == `Special && out_instr[5:0] == `MTHI_S );
    assign MTLO     = (out_instr[31:26] == `Special && out_instr[5:0] == `MTLO_S );

    assign fw_a = (JAL) ? 31 : 
                  (JALR) ? out_instr[15:11] :
                  (LUI) ? out_instr[20:16] :
                  0;
    assign fw_v = (JAL | JALR) ? out_pc + 8 :
                  (LUI) ? out_extout :
                  0;
    assign Will_Use_hilo = (MULT | MULTU | DIV | DIVU | MTLO | MTHI | MFLO | MFHI);
endmodule