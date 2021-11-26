`timescale 1ns / 1ps
`include "Head.v"
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    14:58:20 11/12/2021 
// Design Name: 
// Module Name:    NPC 
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
module NPC(
    input [`NPCCtrl_Len - 1 : 0] NPCOp,
    input BranchAsserted,
    input [15:0] BranchImmediate,
    input [25:0] JImmediate,
    input [31:0] JRInput,
    input [31:0] CurrentPC,
    output [31:0] NextPC,
    output [31:0] PCPlus4
    );
    
    assign PCPlus4 = CurrentPC + 4;
    assign NextPC = (NPCOp == `NPCCtrl_BEQ) ? ( (BranchAsserted == 1) ? {{14{BranchImmediate[15]}} , {BranchImmediate[15:0]}, {2{1'b0}}} + PCPlus4 : PCPlus4) :
                    (NPCOp == `NPCCtrl_JAL) ? {{CurrentPC[31:28]}, {JImmediate[25:0]}, {2{1'b0}}} :
                    (NPCOp == `NPCCtrl_JR)  ? JRInput :
                    PCPlus4;

endmodule
