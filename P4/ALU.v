`timescale 1ns / 1ps
`include "Head.v"

module ALU(
    input [`ALUCtrl_Len-1:0] ALUCtrl,
    input [31:0] NumberA,
    input [31:0] NumberB,
    output ALUZero,
    output [31:0] ALUResult
    );

    assign ALUResult = (ALUCtrl == `ALUCtrl_Add)? NumberA + NumberB :
                       (ALUCtrl == `ALUCtrl_Sub)? NumberA - NumberB :
                       (ALUCtrl == `ALUCtrl_And)? NumberA & NumberB :
                       (ALUCtrl == `ALUCtrl_Or) ? NumberA | NumberB :
                       (ALUCtrl == `ALUCtrl_AlessB) ? ((NumberA < NumberB)? 1: 0) :
                       (ALUCtrl == `ALUCtrl_ALorEB) ? ((NumberA > NumberB)? 0: 1) :
                       (ALUCtrl == `ALUCtrl_Undefined) ? 0 :
                       0;
    assign ALUZero = (ALUResult == 0) ? 1: 0;

endmodule
