`timescale 1ns/1ps
`include "_signal.v"
module D_NPC(
    input clk,
    input reset,
    input [31:0] in_instr,
    input [31:0] in_Fpc,
    input [31:0] in_Dpc,
    input [10:0]  in_npcop,
    input        in_stall,
    input [31:0] in_jrdata,
    input [7:0]  in_cmpresult,

    output reg [31:0] out_pc
);

    wire [31:0] brIm = in_Dpc + 4 + {{14{in_instr[15]}}, {in_instr[15:0]}, {2'b00}};
    wire [31:0] jpIm = {{in_Dpc[31:28]}, {in_instr[25:0]}, {2'b00}};
    wire [31:0] pc4 = in_Fpc + 4;

    always @(*) begin
        if (reset) out_pc = 32'h0000_3000;
        else if (in_stall) out_pc = in_Fpc;
        else begin
            case (in_npcop)
                `NPC_normal: begin
                    out_pc = pc4;
                end
                `NPC_beq   : begin
                    out_pc = ((in_cmpresult & `AEqualB) == `AEqualB) ? brIm : pc4;
                end
                `NPC_bne   : begin
                    out_pc = ((in_cmpresult & `AEqualB) != `AEqualB) ? brIm : pc4;
                end
                `NPC_bgt   : begin
                    out_pc = (in_cmpresult & `ALargerThanB) ? brIm : pc4;
                end
                `NPC_bge   : begin
                    out_pc = ((in_cmpresult & `AEqualB) || (in_cmpresult & `ALargerThanB)) ? brIm : pc4;
                end
                `NPC_blt   : begin
                    out_pc = (in_cmpresult & `ALessThanB) ? brIm : pc4;
                end
                `NPC_ble   : begin
                    out_pc = ((in_cmpresult & `AEqualB) || (in_cmpresult & `ALessThanB)) ? brIm : pc4;
                end
                `NPC_j     : begin
                    out_pc = jpIm;
                end
                `NPC_jr    : begin
                    out_pc = in_jrdata;
                end
                `NPC_blez  : begin
                    out_pc = ((in_cmpresult & `ALargerThan0) == 0) ? brIm : pc4;
                end
                `NPC_bgtz  : begin
                    out_pc = (in_cmpresult & `ALargerThan0) ? brIm : pc4;
                end
                `NPC_bez   : begin
                    out_pc = (in_cmpresult & `AEqual0) ? brIm : pc4;
                end
                `NPC_bnez  : begin
                    out_pc = ((in_cmpresult & `AEqual0) == 0) ? brIm : pc4;
                end
                `NPC_bltz  : begin
                    out_pc = ((in_cmpresult & `ALargerThan0) == 0 || (in_cmpresult & `AEqual0) == 0) ? brIm : pc4;
                end
                `NPC_bgez  : begin
                    out_pc = ((in_cmpresult & `AEqual0) || (in_cmpresult & `ALargerThan0)) ? brIm : pc4;
                end
                default: begin
				end
            endcase
        end
    end

endmodule