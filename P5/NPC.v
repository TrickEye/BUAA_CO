`timescale 1ns / 1ps
`include "Head.v"

module NPC (
    input [`NPCOp_LEN - 1 : 0] NPCOp,
    input [`CmpOut_LEN - 1 : 0] CmpResult,
    input Stall,
    input [31 : 0] JumpRegister,
    input [31 : 0] Instr,
    input [31 : 0] PC,
    input [31 : 0] ID_PC,
    input CmpOut1,

    output reg [31 : 0] NPC,
    output [31 : 0] PCPlus4
);

    wire [31 : 0] branchImm, jumpImm;
    wire [`NPCOp_LEN - 1 : 0] RealNPCOp;
    
    assign PCPlus4 = PC + 4;
    assign RealNPCOp = //(Stall) ? `NPCOp_Stall :
                       NPCOp;

    assign branchImm = ID_PC + 4 + { { 14{Instr[15]} }, {Instr[15 : 0]}, {2'b00}};
    assign jumpImm = {{PC[31:28]}, {Instr[25:0]}, {2'b00}};
    always @(*) begin
        if (Stall) begin
            NPC = PC;
        end
        if (!Stall) begin
            case (RealNPCOp)
                `NPCOp_Normal : begin
                    NPC = PCPlus4;
                end
                `NPCOp_Stall : begin
                    NPC = PC;
                end
                `NPCOp_BranchEq : begin
                    NPC = (CmpResult == `CmpOut_Eq) ? branchImm : 
                                                    PCPlus4;
                end
                `NPCOp_BranchLt : begin
                    NPC = (CmpResult == `CmpOut_Less) ? branchImm :
                                                        PCPlus4;
                end
                `NPCOp_BranchLE : begin
                    NPC = (CmpResult != `CmpOut_Greater) ? branchImm :
                                                        PCPlus4;
                end
                `NPCOp_BranchGt : begin
                    NPC = (CmpResult == `CmpOut_Greater) ? branchImm :
                                                        PCPlus4;
                end
                `NPCOp_BranchGE : begin
                    NPC = (CmpResult != `CmpOut_Less) ? branchImm :
                                                        PCPlus4;
                end
                `NPCOp_BranchNE : begin
                    NPC = (CmpResult != `CmpOut_Eq) ? branchImm :
                                                    PCPlus4;
                end
                `NPCOp_JumpImm  : begin
                    NPC = jumpImm;
                end
                `NPCOp_JumpReg : begin
                    NPC = JumpRegister;
                end
                `NPCOp_BGEZAL :begin
                    NPC = CmpOut1 ? branchImm : PCPlus4;
                end
                default : NPC = PCPlus4;
            endcase
        end
    end
    
endmodule