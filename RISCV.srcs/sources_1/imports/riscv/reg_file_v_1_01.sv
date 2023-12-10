`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Ratner Engineering
// 
// Create Date: 01/29/2020 12:28:22 PM
// Design Name: 
// Module Name: RegFile
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: RIsC-V OTTER Register File Model: 32 x 32
//
//
//  //- Register file instantiation template 
//  RegFile my_regfile (
//    .wd   (),
//    .clk  (), 
//    .en   (),
//    .adr1 (),
//    .adr2 (),
//    .wa   (),
//    .rs1  (), 
//    .rs2  ()  );
//    
// 
// Dependencies: 
// 
// Revision:
// Revision 1.00 - File Created
//          1.01 - (10-14-2020): added instantiation template in comments
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module RegFile(
    input [31:0] wd,
    input clk, 
    input en,
    input [4:0] adr1,
    input [4:0] adr2,
    input [4:0] wa,
    output logic [31:0] rs1, 
    output logic [31:0] rs2     );
    
    logic [31:0] reg_file [0:31];
    
    //- init registers to zero
    initial
    begin
        int i;
        for (i=0; i<32; i++)
            reg_file[i] = 0;
    end
    
    always_ff @( posedge clk)
    begin
        if ( (en == 1) && (wa != 0) )
            reg_file[wa] <= wd;       
    end
    
    //- asynchronous reads
    assign rs1 = reg_file[adr1];
    assign rs2 = reg_file[adr2];
    
endmodule
