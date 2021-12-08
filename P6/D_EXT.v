`timescale 1ns/1ps
`include "_signal.v"

module D_EXT(
    input [31:0] in_pc,
    input [31:0] in_instr,
    input [10:0]  in_extop,
    input [15:0] in_orig,
    input        in_fill,
    output [31:0] out_extout
);

    assign out_extout = (in_extop == `EXT_0L) ? {{16{1'b0}}, {in_orig[15:0]}} : 
                        (in_extop == `EXT_0R) ? {{in_orig[15:0]}, {16{1'b0}}} : 
                        (in_extop == `EXT_1L) ? {{16{1'b1}}, {in_orig[15:0]}} :
                        (in_extop == `EXT_1R) ? {{in_orig[15:0]}, {16{1'b1}}} :
                        (in_extop == `EXT_SL) ? {{16{in_orig[15]}}, {in_orig[15:0]}} :
                        (in_extop == `EXT_SR) ? {{in_orig[15:0]}, {16{in_orig[0]}}} :
                        (in_extop == `EXT_IL) ? {{16{in_fill}}, {in_orig[15:0]}} :
                        (in_extop == `EXT_IR) ? {{in_orig[15:0]}, {16{in_fill}}} :
                        0;

endmodule