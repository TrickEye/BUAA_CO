`timescale 1ns/1ps
`include "_signal.v"


module D_CMP(
    input [31:0] in_pc,
    input [31:0] in_instr,
    input [31:0] in_num1,
    input [31:0] in_num2,
    output [7:0] out_cmpresult
);

    function [7:0] out;
        input [31:0] n1;
        input [31:0] n2;
        begin
            out = 32'h00000000;
            if ($signed(n1) >  0)  out = out | `ALargerThan0;
            if ($signed(n1) == 0)  out = out | `AEqual0;
            if ($signed(n2) >  0)  out = out | `BLargerThan0;
            if ($signed(n2) == 0)  out = out | `BEqual0;
            if ($signed(n1) >  $signed(n2)) out = out | `ALargerThanB;
            if ($signed(n1) == $signed(n2)) out = out | `AEqualB;
            if ($signed(n1) <  $signed(n2)) out = out | `ALessThanB;
        end
    endfunction

    assign out_cmpresult = out(in_num1, in_num2);

endmodule