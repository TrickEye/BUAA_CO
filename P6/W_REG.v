`timescale 1ns/1ps

module W_REG(
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

    input [31:0] in_dmout,

    output reg [31:0] out_instr,
    output reg [31:0] out_pc,
    output reg [7:0]  out_cmpresult,
    output reg [31:0] out_rdata1,
    output reg [31:0] out_rdata2,
    output reg [31:0] out_extout,
    output reg [31:0] out_aluout,
    output reg [31:0] out_hi,
    output reg [31:0] out_lo,

    output reg [31:0] out_dmout,

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
            out_dmout        <= 0;
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
            out_dmout        <= in_dmout;
        end
    end

endmodule