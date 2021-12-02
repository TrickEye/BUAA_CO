`timescale 1ns/1ps
`include "Head.v"

module CMP(
    input [31 : 0] DataA,
    input [31 : 0] DataB,

    output [`CmpOut_LEN - 1 : 0] CmpOut,
    output CmpOut1
);

    assign CmpOut = (DataA < DataB) ? `CmpOut_Less : 
                    (DataA == DataB) ? `CmpOut_Eq : 
                    (DataA > DataB) ? `CmpOut_Greater : 
                    `CmpOut_Undefined;

    assign CmpOut1 = ($signed(DataA) >= 0) ? 1 : 0;

endmodule