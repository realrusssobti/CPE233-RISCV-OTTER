`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Names: Armaan Oberai and Russ Sobti
// Lab Activity: Experiment #3
// Create Date: 04/16/2023 03:28:29 PM
// Module Name: exp_3_alu
// Description: The Arithmetic Logic Unit (ALU) is 
// part of the RISC-V CPU architecture, and essentially
// crunches bits for certain RISC-V instructions
//////////////////////////////////////////////////////////////////////////////////

module alu(
    input [31:0] op_1,
    input [31:0] op_2,
    input [3:0] alu_fun,
    output reg [31:0] result
    );

    //combinatoral always block
    always @(*)
    begin
       case(alu_fun) //instruction select
           4'b0000: result <= op_1 + op_2; //add
           4'b1000: result <= op_1 - op_2; //sub
           4'b0110: result <= op_1 | op_2; //or
           4'b0111: result <= op_1 & op_2; //and
           4'b0100: result <= op_1 ^ op_2; //xor
           4'b0101: result <= op_1 >> op_2[4:0]; //srl
           4'b0001: result <= op_1 << op_2[4:0]; //sll
           4'b1101: result <= $signed(op_1) >>> op_2[4:0]; //sra
           4'b0010: result <= ($signed(op_1) < $signed(op_2)) ? 32'd1 : 32'd0; //slt
           4'b0011: result <= (op_1 < op_2) ? 32'd1 : 32'd0; //sltu
           4'b1001: result <= op_1; //lui

           default: result <= 32'hDEAD_BEEF; //for invalid alu_fun input
        endcase
    end
endmodule
