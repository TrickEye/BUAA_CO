`timescale 1ns / 1ps
`include "Head.v"

module IFU (
    input clk,
    input reset,
    input [31 : 0] NPC,

    output [31 : 0] Instr,
    output reg [31 : 0] PC
);

    reg [31 : 0] InstrMem [0 : 4095];

    initial begin
        PC = 32'h0000_3000;
        $readmemh("code.txt", InstrMem);
    end
    
    assign Instr = InstrMem[ PC[13 : 2] - 12'hc00 ];

    always @(posedge clk) begin
        if (reset == 1) begin
            PC = 32'h0000_3000;
            //$readmemh("code.txt", InstrMem);
        end
        else begin
            PC = NPC;
        end
    end
endmodule