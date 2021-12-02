`timescale 1ns/1ps 
`include "Head.v"

module ALU(
    input [`ALUOp_LEN - 1 : 0] ALUOp,
    input [31 : 0] NumberA,
    input [31 : 0] NumberB,
    output ALUZero,
    output reg [31 : 0] ALUResult
);

    always @(*) begin
        case (ALUOp)
            `ALUOp_Add : begin
                ALUResult = NumberA + NumberB;
            end 
            `ALUOp_Sub : begin
                ALUResult = NumberA - NumberB;
            end            
            `ALUOp_And : begin
                ALUResult = NumberA & NumberB;
            end
            `ALUOp_Or : begin
                ALUResult = NumberA | NumberB;
            end
            `ALUOp_AlessB : begin
                ALUResult = (NumberA < NumberB) ? 1: 0;
            end
            `ALUOp_ALorEB : begin
                ALUResult = (NumberA > NumberB) ? 0: 1;
            end
            `ALUOp_Undefined : begin
                ALUResult = 0; 
			end
            default : begin
                ALUResult = 0;
            end
        endcase
    end

endmodule