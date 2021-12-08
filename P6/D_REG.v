`timescale 1ns/1ps
`include "_const.v"

module D_REG (
    input clk,
    input reset,
    input        in_stall,
    input        in_enable,

    input [31:0] in_instr,
    input [31:0] in_pc,

    output reg [31:0] out_instr,
    output reg [31:0] out_pc
);

    always @(posedge clk) begin
        if (reset) begin
            out_instr <= 0;
            out_pc    <= 0;
        end else if (!in_stall) begin
            out_instr <= in_instr;
            out_pc    <= in_pc;
        end
    end

endmodule