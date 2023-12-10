// The actual program counter!
module PC(
    input clk,
    input rst,
    input ld,
    input [31:0] data,
    output reg [31:0] pc
);

    always @(posedge clk or posedge rst)
        if (rst)
            pc <= 0;
        else if (ld)
            pc <= data;
        else
            pc <= pc;

endmodule