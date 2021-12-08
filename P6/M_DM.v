`timescale 1ns/1ps
`include "_signal.v"

module M_DM(
    input clk, 
    input reset,
    input [31:0] in_pc,
    input [31:0] in_instr,
    input [31:0] in_wdata,
    input [10:0] in_dmop,

    input [31:0] in_addr,

    output reg [31:0] m_data_addr,
    output reg [31:0] m_data_wdata,
    output reg [3 :0] m_data_byteen,
    output reg [31:0] m_inst_addr,

    input [31:0] m_data_rdata,
    output reg [31:0] out_dmout
);

    function [31:0] LoadBit;
        input [1:0] bitSel;
        input [31:0] readData;
        begin
            LoadBit[7:0] = readData[8 * bitSel + 7 -: 8];
            LoadBit[31:8] = {24{readData[8 * bitSel + 7]}};
        end    
    endfunction

    function [31:0] LoadBitU;
        input [1:0] bitSel;
        input [31:0] readData;
        begin
            LoadBitU[7:0] = readData[8 * bitSel + 7 -: 8];
            LoadBitU[31:8] = {24'd0};
        end    
    endfunction

    function [31:0] LoadHalf;
        input [1:0] bitSel;
        input [31:0] readData;
        begin
            LoadHalf[15:0] = readData[16 * bitSel[1] + 15 -: 16];
            LoadHalf[31:16] = {16{readData[16 * bitSel[1] + 15]}};
        end    
    endfunction

    function [31:0] LoadHalfU;
        input [1:0] bitSel;
        input [31:0] readData;
        begin
            LoadHalfU[15:0] = readData[16 * bitSel[1] + 15 -: 16];
            LoadHalfU[31:16] = {16'd0};
        end    
    endfunction

    function [31:0] StoreByte;
        input [31:0] in_wdata;
        input [31:0] in_addr;
        input [31:0] m_data_rdata;
        reg [31:0] temp ;
        reg [31:0] temp1;
        begin
            temp = {{24'b0}, {in_wdata[7:0]}} << ({{30'd0}, {in_addr[1:0]}} << 3);
            temp1 = {{24'd0}, {8'hff}} << ({{30'd0}, {in_addr[1:0]}} << 3);
            temp1 = ~temp1;
            StoreByte = m_data_rdata && temp1;
            StoreByte = StoreByte | temp;
        end
        
    endfunction

    always @(*)begin
        case (in_dmop)
            `dm_B   : begin
                m_data_addr = {{in_addr[31:2]}, {2'b00}};
                m_data_wdata = 0;
                m_data_byteen = 4'b0000;
                m_inst_addr = in_pc;

                out_dmout = LoadBit(in_addr[1:0], m_data_rdata);
            end
            `dm_H   : begin
                m_data_addr = {{in_addr[31:2]}, {2'b00}};
                m_data_wdata = 0;
                m_data_byteen = 4'b0000;
                m_inst_addr = in_pc;

                out_dmout = LoadHalf(in_addr[1:0], m_data_rdata);
            end
            `dm_W   : begin
                m_data_addr = {{in_addr[31:2]}, {2'b00}};
                m_data_wdata = 0;
                m_data_byteen = 4'b0000;
                m_inst_addr = in_pc;

                out_dmout = m_data_rdata;
            end
            `dm_BU  : begin
                m_data_addr = {{in_addr[31:2]}, {2'b00}};
                m_data_wdata = 0;
                m_data_byteen = 4'b0000;
                m_inst_addr = in_pc;

                out_dmout = LoadBitU(in_addr[1:0], m_data_rdata);
            end
            `dm_HU  : begin
                m_data_addr = {{in_addr[31:2]}, {2'b00}};
                m_data_wdata = 0;
                m_data_byteen = 4'b0000;
                m_inst_addr = in_pc;

                out_dmout = LoadHalfU(in_addr[1:0], m_data_rdata);
            end
            `dm_SB  : begin
                m_data_addr = {{in_addr[31:2]}, {2'b00}};
                m_data_wdata = {{24'b0}, {in_wdata[7:0]}} << ({{30'd0}, {in_addr[1:0]}} << 3);//StoreByte(in_wdata, in_addr, m_data_rdata);//
                m_data_byteen = (in_addr[1:0] == 2'b00) ? 4'b0001 : 
                                (in_addr[1:0] == 2'b01) ? 4'b0010 :
                                (in_addr[1:0] == 2'b10) ? 4'b0100 :
                                (in_addr[1:0] == 2'b11) ? 4'b1000 : 4'b0000;
                m_inst_addr = in_pc;
                out_dmout = 0;
            end
            `dm_SH  : begin
                m_data_addr = {{in_addr[31:2]}, {2'b00}};
                m_data_wdata = {{16'b0}, {in_wdata[15:0]}} << ({{31'd0}, {in_addr[1]}} << 4);
                m_data_byteen = (in_addr[1] == 0) ? 4'b0011 : 
                                (in_addr[1] == 1) ? 4'b1100 : 4'b0000;
                m_inst_addr = in_pc;
                out_dmout = 0;
            end
            `dm_SW  : begin
                m_data_addr = {{in_addr[31:2]}, {2'b00}};
                m_data_wdata = in_wdata;
                m_data_byteen = 4'b1111;
                m_inst_addr = in_pc;
                out_dmout = 0;
            end
            default: begin
                m_data_addr = 0;
                m_data_wdata = 0;
                m_data_byteen = 4'b0000;
                m_inst_addr = in_pc;
                out_dmout = 0;
            end
        endcase
    end

endmodule