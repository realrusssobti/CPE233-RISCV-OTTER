// Module for the Branch Address Generator
`timescale 1ns / 1ns

// // Branch Address Generator
// BRANCH_ADDRESS_GENERATOR branch_addr_gen(
//     .pc(pc4),
//     .jal(jal),
//     .jalr(jalr),
//     .branch(branch),
//     .j_type(j_type_imm),
//     .b_type(b_type_imm),
//     .i_type(i_type_imm),
//     .rs(8'h0000000C)
// );

module BRANCH_ADDRESS_GENERATOR(
    input [31:0] pc, // PC-4 in
    input [31:0] j_type, //J-type Immediate
    input [31:0] b_type, //B-type Immediate
    input [31:0] i_type, //I-type Immediate
    input [31:0] rs, // Register address, fixed for now
    output logic [31:0] jal, //JAL address for PC
    output logic [31:0] jalr, //JALR address for PC
    output logic [31:0] branch //Branch address for PC
);

// Branch Address Generator
always_comb begin
        jalr = rs + i_type;    // jalr immediate
        branch = pc + b_type;          // branch immediate
        jal = pc + j_type;             //jal immediate 
    end
endmodule
