`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Ratner Surf Designs
// Engineer: James Ratner
// 
// Create Date: 01/29/2019 04:56:13 PM
// Design Name: 
// Module Name: CU_Decoder
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies:
// 
// CU_DCDR my_cu_dcdr(
//   .br_eq     (), 
//   .br_lt     (), 
//   .br_ltu    (),
//   .opcode    (),    //-  ir[6:0]
//   .func7     (),    //-  ir[30]
//   .func3     (),    //-  ir[14:12] 
//   .alu_fun   (),
//   .pcSource  (),
//   .alu_srcA  (),
//   .alu_srcB  (), 
//   .rf_wr_sel ()   );
//
// 
// Revision:
// Revision 1.00 - File Created (02-01-2020) - from Paul, Joseph, & Celina
//          1.01 - (02-08-2020) - removed unneeded else's; fixed assignments
//          1.02 - (02-25-2020) - made all assignments blocking
//          1.03 - (05-12-2020) - reduced func7 to one bit
//          1.04 - (05-31-2020) - removed misleading code
//          1.05 - (05-01-2023) - reindent and fix formatting
// Additional Comments: Modified for Exp. 6
// 
//////////////////////////////////////////////////////////////////////////////////

module CU_DCDR(
    input br_eq, 
    input br_lt, 
    input br_ltu,
    input [6:0] opcode,   //-  ir[6:0]
    input func7,          //-  ir[30]
    input int_taken,
    input [2:0] func3,    //-  ir[14:12] 
    output logic [3:0] alu_fun,
    output logic [2:0] pcSource,
    output logic [1:0] alu_srcA,
    output logic [2:0] alu_srcB, 
    output logic [1:0] rf_wr_sel   );
    
    //- datatypes for RISC-V opcode types
    typedef enum logic [6:0] {
        LUI    = 7'b0110111,
        AUIPC  = 7'b0010111,
        JAL    = 7'b1101111,
        JALR   = 7'b1100111,
        BRANCH = 7'b1100011,
        LOAD   = 7'b0000011,
        STORE  = 7'b0100011,
        OP_IMM = 7'b0010011,
        OP_RG3 = 7'b0110011,
        SYS    = 7'b1110011
    } opcode_t;
    opcode_t OPCODE; //- define variable of new opcode type
    
    assign OPCODE = opcode_t'(opcode); //- Cast input enum 

    //- datatype for func3Symbols tied to values
    typedef enum logic [2:0] {
        //BRANCH labels
        BEQ = 3'b000,
        BNE = 3'b001,
        BLT = 3'b100,
        BGE = 3'b101,
        BLTU = 3'b110,
        BGEU = 3'b111
    } func3_t;    
    func3_t FUNC3; //- define variable of new opcode type
    
    assign FUNC3 = func3_t'(func3); //- Cast input enum 
       
    always_comb begin 
        //- schedule all values to avoid latch
        pcSource = 3'b000; alu_srcB = 3'b000;    rf_wr_sel = 2'b00; 
        alu_srcA = 2'b00;   alu_fun  = 4'b0000;

        if(int_taken == 1'b1)
            pcSource = 3'b100;
        else begin
            case(OPCODE)
                LUI: begin
                    alu_fun = 4'b1001; 
                    alu_srcA = 2'b01; 
                    rf_wr_sel = 2'b11; 
                end

                AUIPC: begin
                    alu_fun = 4'b0000;
                    alu_srcA = 2'b01;
                    alu_srcB = 3'b011;
                    rf_wr_sel = 2'b11;
                end
                JAL: begin
                    rf_wr_sel = 2'b00; 
                    pcSource = 3'b011;
                end

                JALR: begin
                    rf_wr_sel = 2'b00;
                    pcSource = 3'b001;
                end
                
                LOAD: begin
                    alu_fun = 4'b0000; 
                    alu_srcA = 2'b00; 
                    alu_srcB = 3'b001; 
                    rf_wr_sel = 2'b10; 
                end
                
                STORE: begin
                    alu_fun = 4'b0000; 
                    alu_srcA = 2'b00; 
                    alu_srcB = 3'b010; 
                end
                
                OP_IMM: begin
                    pcSource = 3'b000; 
                    alu_srcA = 2'b00; 
                    alu_srcB = 3'b001; 
                    rf_wr_sel = 2'b11;

                    case(FUNC3)
                        3'b000: begin   // instr: ADDI
                            alu_fun = 4'b0000;
                        end

                        3'b010: begin // instr: SLTI
                            alu_fun = 4'b0010;
                        end

                        3'b011: begin // instr: SLTUI
                            alu_fun = 4'b0011;
                        end

                        3'b110: begin // instr: ORI
                            alu_fun = 4'b0110;
                        end

                        3'b100: begin // instr: XORI
                            alu_fun = 4'b0100;
                        end

                        3'b111: begin // instr: ANDI
                            alu_fun = 4'b0111;
                        end

                        3'b001: begin // instr: SLLI
                            alu_fun = 4'b0001;
                        end

                        3'b101: begin
                            case(func7)
                                1'b0: begin // instr: SRLI
                                    alu_fun = 4'b0101; 
                                end

                                1'b1: begin // instr: SRAI
                                    alu_fun = 4'b1101;
                                end

                                default: begin
                                    pcSource = 3'b000; 
                                    alu_fun = 4'b0000;
                                    alu_srcA = 2'b00; 
                                    alu_srcB = 3'b001; 
                                    rf_wr_sel = 2'b11;
                                end
                        endcase                                
                        end 
                        default: begin
                            pcSource = 3'b000; 
                            alu_fun = 4'b0000;
                            alu_srcA = 2'b00; 
                            alu_srcB = 3'b001; 
                            rf_wr_sel = 2'b00; 
                        end
                    endcase                        
                end
                
                OP_RG3: begin
                    pcSource = 3'b000;
                    alu_srcA = 2'b00; 
                    alu_srcB = 3'b000;
                    rf_wr_sel = 2'b11; 
                    case(FUNC3)
                        3'b000: begin
                            case(func7)
                                1'b0: begin // instr: ADD
                                    alu_fun = 4'b0000;
                                end
                                1'b1: begin // instr: SUB
                                    alu_fun = 4'b1000;
                                end

                                default: begin
                                    pcSource = 3'b000; 
                                    alu_fun = 4'b0000;
                                    alu_srcA = 2'b00; 
                                    alu_srcB = 3'b001; 
                                    rf_wr_sel = 2'b11;
                                end
                            endcase
                        end

                        3'b010: begin // instr: SLT
                            alu_fun = 4'b0010;
                        end

                        3'b011: begin // instr: SLTU
                            alu_fun = 4'b0011;
                        end

                        3'b110: begin // instr: OR
                            alu_fun = 4'b0110;
                        end

                        3'b100: begin // instr: XOR
                            alu_fun = 4'b0100;
                        end

                        3'b111: begin // instr: AND
                            alu_fun = 4'b0111;
                        end

                        3'b001: begin // instr: SLL
                            alu_fun = 4'b0001;
                        end

                        3'b101: begin
                            case(func7)
                                1'b0: begin // instr: SRL
                                    alu_fun = 4'b0101; 
                                end

                                1'b1: begin // instr: SRA
                                    alu_fun = 4'b1101;
                                end

                                default: begin
                                    pcSource = 3'b000; 
                                    alu_fun = 4'b0000;
                                    alu_srcA = 2'b00; 
                                    alu_srcB = 3'b00; 
                                    rf_wr_sel = 2'b11;
                                end
                            endcase                                
                        end

                        default: begin
                            pcSource = 3'b000; 
                            alu_fun = 4'b0000;
                            alu_srcA = 2'b00; 
                            alu_srcB = 3'b000; 
                            rf_wr_sel = 2'b00; 
                        end
                    endcase
                end

                BRANCH: begin
                    case(FUNC3)
                        BEQ: begin
                            if (br_eq) pcSource = 3'b010;
                        end
                        
                        BNE: begin
                            if (br_eq == 1'b0)
                                pcSource = 3'b010;
                        end
                        
                        BLT: begin
                            if (br_lt == 1'b1) pcSource = 3'b010;
                        end
                        
                        BGE: begin
                            if (br_lt == 1'b0 || br_eq == 1'b1) pcSource = 3'b010;
                        end
                        
                        BLTU: begin
                             if (br_ltu == 1'b1) pcSource = 3'b010;
                        end
                        
                        BGEU: begin
                            if (br_ltu == 1'b0 || br_eq == 1'b1) pcSource = 3'b010;
                        end

                        default: begin
                            pcSource = 3'b000; 
                            alu_fun = 4'b0000;
                            alu_srcA = 2'b00; 
                            alu_srcB = 3'b000; 
                            rf_wr_sel = 2'b00; 
                        end
                    endcase    
                end

                SYS: begin
                    rf_wr_sel = 2'b01;
                    alu_srcA = 2'b00;
                    alu_srcB = 3'b100;
                    case(FUNC3)
                        3'b001: begin // instr: csrrw
                            alu_fun = 4'b1001;
                        end

                        3'b011: begin // instr: csrrc
                            alu_srcA = 2'b10;
                            alu_fun = 4'b0111;
                        end

                        3'b010: begin // instr: csrrs
                            alu_fun = 4'b0110;
                        end

                        3'b000: begin // instr: mret
                            pcSource = 3'b101;
                        end

                        default: begin
                            pcSource = 3'b000; 
                            alu_srcB = 3'b000; 
                            rf_wr_sel = 2'b00; 
                            alu_srcA = 2'b00; 
                            alu_fun = 4'b0000;
                        end
                    endcase
                end    

                default: begin
                     pcSource = 3'b000; 
                     alu_srcB = 3'b000; 
                     rf_wr_sel = 2'b00; 
                     alu_srcA = 2'b00; 
                     alu_fun = 4'b0000;
                end
            endcase
        end    
    end

endmodule
