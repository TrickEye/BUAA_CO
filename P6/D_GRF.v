`timescale 1ns/1ps

module D_GRF(
    input clk,
    input reset,
    input [4:0]     in_raddr1,
    input [4:0]     in_raddr2,
    input [4:0]     in_waddr,
    input [31:0]    in_wdata,
    input           in_we,
    output reg [31:0]   out_rdata1,
    output reg [31:0]   out_rdata2
);

    reg [31:0] grf [0:31];
    integer i;

    always @(posedge clk) begin
        if (reset) for (i = 0; i < 32; i = i + 1) grf[i] <= 0;
        else if (in_we && in_waddr) grf[in_waddr] <= in_wdata;
    end

    // internal forwarding:
    always @(*) begin
        if (in_raddr1 && in_raddr1 == in_waddr && in_we) out_rdata1 = in_wdata;
        else out_rdata1 = grf[in_raddr1];
        if (in_raddr2 && in_raddr2 == in_waddr && in_we) out_rdata2 = in_wdata;
        else out_rdata2 = grf[in_raddr2];
    end
    // internal forwarding.

endmodule