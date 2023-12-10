// Immediate Generator: Takes in the instruction and outputs the immediate values for the U,I,S,B,J type instructions.

module IMMEDIATE_GENERATOR(
    input [31:0] ir,
    output logic [31:0] u_type_imm,
    output logic [31:0] s_type_imm,
    output logic [31:0] i_type_imm,
    output logic [31:0] b_type_imm,
    output logic [31:0] j_type_imm
);

// Immediate Generator
always_comb
    begin
        u_type_imm = { ir[31:12], 12'b000000000000 };                           // UType 
        i_type_imm = { {21{ir[31]}}, ir[30:25],ir[24:20] };                     // IType
        s_type_imm = { {21{ir[31]}}, ir[30:25], ir[11:7] };                     // SType
        b_type_imm = { {20{ir[31]}}, ir[7], ir[30:25], ir[11:8], 1'b0 };        // BType
        j_type_imm = { {12{ir[31]}}, ir[19:12], ir[20], ir[30:21], 1'b0 };      // JType   
    end

endmodule