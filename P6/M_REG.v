`timescale 1ns/1ps
`include "_const.v"

module M_REG(
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

    input [31:0] in_aluout,
    input [31:0] in_hi,
    input [31:0] in_lo,

    output reg [31:0] out_instr,
    output reg [31:0] out_pc,
    output reg [7:0]  out_cmpresult,
    output reg [31:0] out_rdata1,
    output reg [31:0] out_rdata2,
    output reg [31:0] out_extout,

    output reg [31:0] out_aluout,
    output reg [31:0] out_hi,
    output reg [31:0] out_lo,

    output [31:0] fw_v,
    output [4:0]  fw_a
);

    always @(posedge clk) begin
        if (reset) begin
            out_instr        <= 0;
            out_pc           <= 0;
            out_cmpresult    <= 0;
            out_rdata1       <= 0;
            out_rdata2       <= 0;
            out_extout       <= 0;
            out_aluout       <= 0;
            out_hi           <= 0;
            out_lo           <= 0;
        end else begin
            out_instr        <= in_instr;
            out_pc           <= in_pc;
            out_cmpresult    <= in_cmpresult;
            out_rdata1       <= in_rdata1;
            out_rdata2       <= in_rdata2;
            out_extout       <= in_extout;
            out_aluout       <= in_aluout;
            out_hi           <= in_hi;
            out_lo           <= in_lo;
        end
    end

    assign JAL      = (out_instr[31:26] == `JAL   );
    assign JALR     = (out_instr[31:26] == `Special && out_instr[5:0] == `JALR_S );
    assign LUI      = (out_instr[31:26] == `LUI   );

    assign ADD      = (out_instr[31:26] == `Special && out_instr[5:0] == `ADD_S  );
    assign ADDU     = (out_instr[31:26] == `Special && out_instr[5:0] == `ADDU_S );
    assign SUB      = (out_instr[31:26] == `Special && out_instr[5:0] == `SUB_S  );
    assign SUBU     = (out_instr[31:26] == `Special && out_instr[5:0] == `SUBU_S );
    assign SLL      = (out_instr[31:26] == `Special && out_instr[5:0] == `SLL_S  );
    assign SRL      = (out_instr[31:26] == `Special && out_instr[5:0] == `SRL_S  );
    assign SRA      = (out_instr[31:26] == `Special && out_instr[5:0] == `SRA_S  );
    assign SLLV     = (out_instr[31:26] == `Special && out_instr[5:0] == `SLLV_S );
    assign SRLV     = (out_instr[31:26] == `Special && out_instr[5:0] == `SRLV_S );
    assign SRAV     = (out_instr[31:26] == `Special && out_instr[5:0] == `SRAV_S );
    assign AND      = (out_instr[31:26] == `Special && out_instr[5:0] == `AND_S  );
    assign OR       = (out_instr[31:26] == `Special && out_instr[5:0] == `OR_S   );
    assign XOR      = (out_instr[31:26] == `Special && out_instr[5:0] == `XOR_S  );
    assign NOR      = (out_instr[31:26] == `Special && out_instr[5:0] == `NOR_S  );
    assign ADDI     = (out_instr[31:26] == `ADDI  );
    assign ADDIU    = (out_instr[31:26] == `ADDIU );
    assign ANDI     = (out_instr[31:26] == `ANDI  );
    assign ORI      = (out_instr[31:26] == `ORI   );
    assign XORI     = (out_instr[31:26] == `XORI  );
    assign SLT      = (out_instr[31:26] == `Special && out_instr[5:0] == `SLT_S  );
    assign SLTI     = (out_instr[31:26] == `SLTI  );
    assign SLTIU    = (out_instr[31:26] == `SLTIU );
    assign SLTU     = (out_instr[31:26] == `Special && out_instr[5:0] == `SLTU_S );
    assign MFHI     = (out_instr[31:26] == `Special && out_instr[5:0] == `MFHI_S );
    assign MFLO     = (out_instr[31:26] == `Special && out_instr[5:0] == `MFLO_S );
    

    assign fw_a = (JAL) ? 31 : 
                  (JALR | ADD | ADDU | AND | NOR | OR | SLL | SLLV | SLT | SLTU | SRA | SRAV | SRL | SRLV | SUB | SUBU | XOR | MFHI | MFLO) ? out_instr[15:11] :
                  (LUI | ADDI | ADDIU | ANDI | ORI | XORI | SLTI | SLTIU) ? out_instr[20:16] :
                  0;
    assign fw_v = (JAL | JALR) ? out_pc + 8 :
                  (LUI | ADD | ADDU | SUB | SUBU | SLL | SRL | SRA | SLLV | SRLV | SRAV | AND | OR|XOR|NOR|ADDI|ADDIU|ANDI|ORI|XORI|SLT|SLTI|SLTIU|SLTU) ? out_aluout :
                  (MFHI) ? out_hi :
                  (MFLO) ? out_lo :
                  0;


endmodule