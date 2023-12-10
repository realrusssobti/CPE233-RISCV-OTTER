//Top Level Module of RISC-V for Exp. 7

module OTTER_MCU (
  input RST,
  input intr,
  input clk,
  input logic [31:0] iobus_in,
  output logic [31:0] iobus_out,
  output logic [31:0] iobus_addr,
  output logic iobus_wr
);

//PC signals
 logic [31:0] PC, pcIn;
 logic [2:0] pcSource;
 logic PCWrite, reset;

//Memory signals
 logic [31:0] ir, data_out;
 logic memRDEN1, memRDEN2, memWE2;

//REG_FILE signals
 logic [31:0] wd, rs1, rs2;
 logic [1:0] rf_wr_sel;
 logic regWrite;

//IMMED_GEN signals
 logic [31:0] u_type, i_type, s_type;

//BRANCH GEN signals
 logic [31:0] b_type, j_type, jal, jalr, branch;

//ALU signals
 logic [31:0] srcA, srcB, alu_result;
 logic [3:0] alu_fun;
 logic [2:0] alu_srcB;
 logic [1:0] alu_srcA;
 
//BRANCH COND signals
 logic eq, lt, ltu;

//CSR signals
 logic [31:0] mepc, mvtec, csr_RD;
 logic mret_exec, int_taken, csr_WE, mstatus;

 //assign outputs
 assign iobus_out = rs2;
 assign iobus_addr = alu_result;

 //MUXing into modules
 always_comb begin
  //8:1 MUX into PC
  case (pcSource)
    3'b000: pcIn = PC + 4;
    3'b001: pcIn = jalr;
    3'b010: pcIn = branch;
    3'b011: pcIn = jal;
    3'b100: pcIn = mvtec;
    3'b101: pcIn = mepc;

    default: pcIn = 32'hDEAD_BEEF;
  endcase
  
  //4:1 MUX into REG_FILE
  case (rf_wr_sel)
    2'b00: wd = PC + 4;
    2'b01: wd = csr_RD;
    2'b10: wd = data_out;
    2'b11: wd = alu_result;

    default: wd = 32'hDEAD_BEEF;
  endcase
  
  //4:1 MUX for alu_srcA
  case (alu_srcA)
    2'b00: srcA = rs1;
    2'b01: srcA = u_type;
    2'b10: srcA = ~rs1;

    default: srcA = 32'hDEAD_BEEF;
  endcase
  
  //8:1 MUX for alu_srcB
  case (alu_srcB)
    3'b000: srcB = rs2;
    3'b001: srcB = i_type;
    3'b010: srcB = s_type;
    3'b011: srcB = PC;
    3'b100: srcB = csr_RD;

    default: srcB = 32'hDEAD_BEEF;
  endcase
 end 

 PC OTTER_PC (
    .clk    (clk),
    .rst    (reset),
    .ld     (PCWrite),
    .data   (pcIn),
    .pc     (PC) ); 

 Memory OTTER_MEMORY (
    .MEM_CLK   (clk),
    .MEM_RDEN1 (memRDEN1), 
    .MEM_RDEN2 (memRDEN2), 
    .MEM_WE2   (memWE2),
    .MEM_ADDR1 (PC[15:2]),
    .MEM_ADDR2 (alu_result),
    .MEM_DIN2  (rs2),  
    .MEM_SIZE  (ir[13:12]),
    .MEM_SIGN  (ir[14]),
    .IO_IN     (iobus_in),
    .IO_WR     (iobus_wr),
    .MEM_DOUT1 (ir),
    .MEM_DOUT2 (data_out)  );

  RegFile REG_FILE (
    .wd   (wd),
    .clk  (clk), 
    .en   (regWrite),
    .adr1 (ir[19:15]),
    .adr2 (ir[24:20]),
    .wa   (ir[11:7]),
    .rs1  (rs1), 
    .rs2  (rs2)  );

  IMMEDIATE_GENERATOR IMMED_GEN (
    .ir           ({ir[31:7], 7'h0}),
    .u_type_imm   (u_type),
    .s_type_imm   (s_type),
    .i_type_imm   (i_type),
    .b_type_imm   (b_type),
    .j_type_imm   (j_type)  );
  
  BRANCH_ADDRESS_GENERATOR BRANCH_ADDR_GEN ( 
    .pc           (PC),
    .j_type       (j_type),
    .b_type       (b_type),
    .i_type       (i_type),
    .rs           (rs1),
    .jal          (jal),
    .jalr         (jalr),
    .branch       (branch)    );

  alu OTTER_ALU (
    .op_1     (srcA),
    .op_2     (srcB),
    .alu_fun  (alu_fun),
    .result   (alu_result)  );

  CSR OTTER_CSR (
    .CLK        (clk),
    .RST        (reset),
    .MRET_EXEC  (mret_exec),
    .INT_TAKEN  (int_taken),
    .ADDR       (ir[31:20]),
    .PC         (PC),
    .WD         (alu_result),
    .WR_EN      (csr_WE),
    .RD         (csr_RD),
    .CSR_MEPC   (mepc),
    .CSR_MTVEC  (mvtec),
    .CSR_MSTATUS_MIE (mstatus)    ); 

 BRANCH_COND_GEN BRANCH_COND (
    .rs1      (rs1),
    .rs2      (rs2),
    .br_eq    (eq),
    .br_lt    (lt),
    .br_ltu   (ltu)       );  

  CU_FSM OTTER_FSM (
    .intr      (intr && mstatus),
    .clk       (clk),
    .RST       (RST),
    .opcode    (ir[6:0]),
    .func3     (ir[14:12]),
    .pcWrite   (PCWrite),
    .regWrite  (regWrite),
    .memWE2    (memWE2),
    .memRDEN1  (memRDEN1),
    .memRDEN2  (memRDEN2),
    .reset     (reset),
    .csr_WE    (csr_WE),
    .int_taken (int_taken),
    .mret_exec (mret_exec)   );

  CU_DCDR OTTER_DCDR (
    .br_eq     (eq), 
    .br_lt     (lt), 
    .br_ltu    (ltu),
    .opcode    (ir[6:0]),
    .func7     (ir[30]),
    .int_taken (int_taken),
    .func3     (ir[14:12]),
    .alu_fun   (alu_fun),
    .pcSource  (pcSource),
    .alu_srcA  (alu_srcA),
    .alu_srcB  (alu_srcB), 
    .rf_wr_sel (rf_wr_sel)   );

endmodule





