`timescale 1ns/1ps
`include "_signal.v"

module E_HILO(
    input clk,
    input reset,
    input [31:0] in_pc,
    input [31:0] in_instr,
    input [31:0] in_num1,
    input [31:0] in_num2,
    input [10:0] in_hiloOp,

    output [31:0] out_hi,
    output [31:0] out_lo,
    output out_hiloBusy
);

    reg [31:0] hi;
	reg	[31:0] lo;
    reg [31:0] Counter;

    function [63:0] mult;
        input [31:0] n1;
        input [31:0] n2;
        reg [63:0] n1Extended;
        reg [63:0] n2Extended;
        begin
            n1Extended = {{32{n1[31]}}, {n1}};
            n2Extended = {{32{n2[31]}}, {n2}};
            mult = $signed(n1Extended) * $signed(n2Extended);
        end
    endfunction

    function [63:0] multu;
        input [31:0] n1;
        input [31:0] n2;
        reg [63:0] n1Extended;
        reg [63:0] n2Extended;
        begin
            n1Extended = {{32'd0}, {n1}};
            n2Extended = {{32'd0}, {n2}};
            multu = n1Extended * n2Extended;
        end
    endfunction
	
    function [63:0] div;
        input [31:0] n1;
        input [31:0] n2;
        begin
            div[31:0] = $signed(n1) / $signed(n2);
            div[63:32] = $signed(n1) % $signed(n2);
        end
    endfunction
	
	function [63:0] divu;
        input [31:0] n1;
        input [31:0] n2;
        begin
            divu[31:0] = (n1) / (n2);
            divu[63:32] = (n1) % (n2);
        end
    endfunction

	wire [63:0] multRes = mult(in_num1, in_num2);
    wire [63:0] multuRes = multu(in_num1, in_num2);
	wire [63:0] divRes  = div(in_num1, in_num2);
	wire [63:0] divuRes  = divu(in_num1, in_num2);

    always @(posedge clk) begin
        if (reset) begin
            hi <= 0;
            lo <= 0;
            Counter <= 0;
        end else if (Counter > 0) begin
            Counter <= Counter - 1;
        end else case (in_hiloOp)
            `Hilo_mult : begin
                hi <= multRes[63:32];
				lo <= multRes[31:0];
				Counter <= 5;
            end
            `Hilo_multu : begin
                hi <= multuRes[63:32];
                lo <= multuRes[31:0];
                Counter <= 5;
            end
            `Hilo_div : begin
                hi <= divRes[63:32];
				lo <= divRes[31:0];
				Counter <= 10;
            end
            `Hilo_divu : begin
                hi <= divuRes[63:32];
				lo <= divuRes[31:0];
				Counter <= 10;
            end
            `Hilo_ToHi : begin
                hi <= in_num1;
            end
            `Hilo_ToLo : begin
                lo <= in_num1;
            end
            default: begin
			end
        endcase
    end
	
	assign out_hiloBusy = (Counter > 0) ? 1 : 0;
    assign out_hi = (out_hiloBusy) ? 0 : hi;
    assign out_lo = (out_hiloBusy) ? 0 : lo;

endmodule