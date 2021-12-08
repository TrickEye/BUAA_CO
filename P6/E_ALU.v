`timescale 1ns/1ps  
`include "_signal.v"

module E_ALU(
    input [31:0] in_pc,
    input [31:0] in_instr,
    input [31:0] in_num1,
    input [31:0] in_num2,
    input [10:0] in_aluop,

    output [31:0] out_aluout
);

    function [31:0] shiftRightLogical;
        input [31:0] n1;
        input [31:0] n2;
        integer i;
        begin
            shiftRightLogical = n1;
            for (i = 0; i < $signed({{1'b0}, {n2[4:0]}}); i = i + 1) begin
                shiftRightLogical = {{1'b0}, {shiftRightLogical[31:1]}};
            end
        end
    endfunction

    function [31:0] shiftRightAlgorithm;
        input [31:0] n1;
        input [31:0] n2;
        integer i;
        begin
            shiftRightAlgorithm = n1;
            for (i = 0; i < $signed({{1'b0}, {n2[4:0]}}); i = i + 1) begin
                shiftRightAlgorithm = {{shiftRightAlgorithm[31]}, {shiftRightAlgorithm[31:1]}};
            end
        end
    endfunction

    function [31:0] shiftLeftLogical;
        input [31:0] n1;
        input [31:0] n2;
        integer i;
        begin
            shiftLeftLogical = n1;
            for (i = 0; i < $signed({{1'b0}, {n2[4:0]}}); i = i + 1) begin
                shiftLeftLogical = {{shiftLeftLogical[30:0]}, {1'b0}};
            end
        end
    endfunction

    assign out_aluout = 
    (in_aluop == `ALU_add ) ? in_num1 + in_num2 :
    (in_aluop == `ALU_sub ) ? in_num1 - in_num2 :
    (in_aluop == `ALU_and ) ? in_num1 & in_num2 :
    (in_aluop == `ALU_or  ) ? in_num1 | in_num2 :
    (in_aluop == `ALU_sl  ) ? shiftLeftLogical(in_num1, in_num2) :
    (in_aluop == `ALU_srl ) ? shiftRightLogical(in_num1, in_num2) :
    (in_aluop == `ALU_sra ) ? shiftRightAlgorithm(in_num1, in_num2) :
    (in_aluop == `ALU_xor ) ? in_num1 ^ in_num2 :
    (in_aluop == `ALU_nor ) ? ~in_num1 & ~in_num2 :
    (in_aluop == `ALU_slt ) ? ($signed(in_num1) < $signed(in_num2) ? 1:0) :
    (in_aluop == `ALU_sltu) ? (in_num1 < in_num2 ? 1:0) :
	0;


endmodule
