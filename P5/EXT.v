`timescale 1ns / 1ps
`include "Head.v"
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    22:14:59 11/12/2021 
// Design Name: 
// Module Name:    EXT 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module EXT(
    input [15:0] Orig,
    input [`Extender_Op_Len - 1 : 0] ExtOp,
    input Input,
    output [31:0] Result
    );

    assign Result = (ExtOp == `Ext_Zero_Left)  ? {{16{1'b0}}, {Orig[15:0]}} : 
                    (ExtOp == `Ext_Zero_Right) ? {{Orig[15:0]}, {16{1'b0}}} : 
                    (ExtOp == `Ext_One_Left)   ? {{16{1'b1}}, {Orig[15:0]}} :
                    (ExtOp == `Ext_One_Right)  ? {{Orig[15:0]}, {16{1'b1}}} :
                    (ExtOp == `Ext_Sign_Left)  ? {{16{Orig[15]}}, {Orig[15:0]}} :
                    (ExtOp == `Ext_LSB_Right)  ? {{Orig[15:0]}, {16{Orig[0]}}} :
                    (ExtOp == `Ext_Input_Left) ? {{16{Input}}, {Orig[15:0]}} :
                    (ExtOp == `Ext_Input_Right)? {{Orig[15:0]}, {16{Input}}} :
                    32'h00000000;


endmodule
