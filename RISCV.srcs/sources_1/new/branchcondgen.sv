`timescale 1ns/1ps
// Branch Condition Generator

module BRANCH_COND_GEN(
    input [31:0] rs1, //Input 1
    input [31:0] rs2, //Input 2
    output logic br_eq, //Branch if Equal
    output logic br_lt,//Branch if less than
    output logic br_ltu //Unsigned - Branch if less than
    );
    
    always_comb begin
        
        // br_eq: Branch when the two values are equal
        if (rs1 == rs2) br_eq = 1;
        else br_eq = 0;
       
        // br_lt: Check if the (signed) value of the first register is less than the second
        if ($signed(rs1) < $signed(rs2)) br_lt = 1;
        else br_lt = 0;
        
        // br_ltu: Like br_lt but unsigned arithmetic
        if (rs1 < rs2) br_ltu = 1;
        else br_ltu = 0;
        
    end
endmodule
