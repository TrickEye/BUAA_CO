`timescale 1ns/1ps
`include "Head.v"
module DM(
    input clk,
    input reset,
    input [31 : 0] PC,
    input [31 : 0] Addr,
    input [31 : 0] WriteData,
    input [`MemWrite_LEN-1 : 0] MemType,
    input WE,

    output [31 : 0] ReadData
);

    function [31:0] Hout;
        input [31:0] Data;
        input [31:0] RD;
    begin
        Hout = RD;
        Hout[15 + 16 * Addr[1] -: 16] = Data[15:0];
    end
    endfunction

    function [31:0] Bout;
        input [31:0] Data;
        input [31:0] RD;
    begin
        Bout = RD;
        Bout[7 + 8 * Addr[1:0] -: 8] = Data[7:0];
    end    
    endfunction

    reg [31 : 0] DataMem [0 : 3071];

    integer i;

    always @(posedge clk) begin
        if (reset == 1) begin
            for (i = 0; i < 3072; i = i + 1) begin
                DataMem[i] = 0;
            end
        end
        else if (WE) begin
            if (MemType == `MemWrite_W) begin
                DataMem[Addr[13 : 2]] <= WriteData;
                $display("%d@%h: *%h <= %h", $time, PC, Addr, WriteData);
            end
            else if (MemType == `MemWrite_H) begin
                DataMem[Addr[13 : 2]][16 + 15 * Addr[1] -: 16] <= WriteData[15:0];
                $display("%d@%h: *%h <= %h", $time, PC, Addr[31:2]<<2, Hout(WriteData, ReadData));
            end
            else if (MemType == `MemWrite_B) begin
                DataMem[Addr[13 : 2]][7 + 8 * Addr[1:0] -: 8] <= WriteData[7:0];
                $display("%d@%h: *%h <= %h", $time, PC, Addr[31:2]<<2, Bout(WriteData, ReadData));
            end
        end
    end


    assign ReadData = (MemType == `MemWrite_W) ? DataMem[Addr[13 : 2]] :
                      (MemType == `MemWrite_H) ? {{16{DataMem[Addr[13 : 2]][15 + 16 * Addr[1]]}}, {DataMem[Addr[13 : 2]][15 * Addr[1] -: 16]}} :
                      (MemType == `MemWrite_B) ? {{24{DataMem[Addr[13 : 2]][7 + 8 * Addr[1:0]]}}, {DataMem[Addr[13 : 2]][7 * Addr[1:0] -: 8]}} :
                      0;
endmodule