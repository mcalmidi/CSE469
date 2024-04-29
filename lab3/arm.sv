// Akhila Narayanan and Manasvini Calmidi
// 4/23/2024
// CSE 469
// Lab #3

/* arm is the spotlight of the show and contains the bulk of the datapath and control logic. This module is split into two parts, the datapath and control. 
*/

// clk - system clock
// rst - system reset
// Instr - incoming 32 bit instruction from imem, contains opcode, condition, addresses and or immediates
// ReadData - data read out of the dmem
// WriteData - data to be written to the dmem
// MemWrite - write enable to allowed WriteData to overwrite an existing dmem word
// PC - the current program count value, goes to imem to fetch instruciton
// ALUResult - result of the ALU operation, sent as address to the dmem

module arm (
    input  logic        clk, rst,
    input  logic [31:0] InstrF,
    input  logic [31:0] ReadDataM,
    output logic [31:0] WriteDataM, 
    output logic [31:0] PCF, ALUOutM,
    output logic        MemWrite
);
	 
    // control signals
//    logic PCSrc, MemtoReg, ALUSrc, RegWrite, IsCond, Valid, NoWrite, FlagWrite, RegW;
//    logic [1:0] ALUControl;

    /* The datapath consists of a PC as well as a series of muxes to make decisions about which data words to pass forward and operate on. It is 
    ** noticeably missing the register file and alu, which you will fill in using the modules made in lab 1. To correctly match up signals to the 
    ** ports of the register file and alu take some time to study and understand the logic and flow of the datapath.
    */
    //-------------------------------------------------------------------------------
    //                                      DATAPATH
    //-------------------------------------------------------------------------------
	 
	 // 1) FETCH STAGE
	 
	 // Fetch stage datapath buses and signals
    logic [31:0] PCPrime, PCPlus4F;
	 
	 // Muxes for PCPrime and PCF
	 logic tempF;
	 assign tempF = PCSrcW ? ResultW : PCPlus4F;
    assign PCPrime = BranchTakenE ? ALUResultE : tempF;  // mux, use either default or newly computed value
    assign PCPlus4F = PCF + 'd4;                  // default value to access next instruction
	
    // update the PC, at rst initialize to 0
    always_ff @(posedge clk) begin
        if (rst) PCF <= '0;
        else     PCF <= PCPrime;
    end
	 
	 // Fetch Pipeline Register
	 logic input [31:0] InstrD; 
	 always_ff @(posedge clk) begin
		if (rst) InstrD <= '0;
		else     InstrD <= InstrF;
	 end
	 
	 
	 // 2) DECODE STAGE
	 
	 // Decode stage datapath buses and signals
	 logic [31:0] PCPlus8D;
	 logic [ 3:0] RA1D, RA2D;                  // regfile input addresses
    logic [31:0] RD1D, RD2D;                  // raw regfile outputs
    logic [31:0] ExtImmD, SrcAD, WriteDataD;        // immediate and alu inputs
	 logic [3:0] WA3D;
	 
	 // Decode stage control signals
	 logic PCSrcD, RegWriteD, MemtoRegD, MemWriteD, BranchD, ALUSrcD, FlagWriteD, 
	 logic [1:0] RegSrcD, ImmSrcD, ALUControlD;
	 logic [3:0] CondD; 
	 
	 assign CondD = InstrD[31:28];
	 
	 assign PCPlus8D = PCPlus4F + 'd4;             // value read when reading from reg[15]

    // determine the register addresses based on control signals
    // RegSrc[0] is set if doing a branch instruction
    // RefSrc[1] is set when doing memory instructions
    assign RA1D = RegSrcD[0] ? 4'd15         : InstrD[19:16];
    assign RA2D = RegSrcD[1] ? InstrD[15:12] : InstrD[3:0];

    // Hook up inputs and outputs of reg_file module (from Lab 1) 
    reg_file u_reg_file (
        .clk       (~clk), 
        .wr_en     (RegWriteW),
        .write_data(ResultW),
        .write_addr(WA3W),
        .read_addr1(RA1D), 
        .read_addr2(RA2D),
        .read_data1(RD1D), 
        .read_data2(RD2D)
    );

    // two muxes, put together into an always_comb for clarity
    // determines which set of instruction bits are used for the immediate
    always_comb begin
        if      (ImmSrcD == 'b00) ExtImmD = {{24{InstrD[7]}},InstrD[7:0]};          // 8 bit immediate - reg operations
        else if (ImmSrcD == 'b01) ExtImmD = {20'b0, InstrD[11:0]};                 // 12 bit immediate - mem operations
        else                     ExtImmD = {{6{InstrD[23]}}, InstrD[23:0], 2'b00}; // 24 bit immediate - branch operation
    end
	 
	 assign WriteDataD = (RA2 == 'd15) ? PCPlus8D : RD2D;           // substitute the 15th regfile register for PC 
	 assign SrcAD = (RA1D == 'd15) ? PCPlus8D : RD1D; // substitute the 15th regfile register for PC
	 
	 assign WA3D = InstrD[15:12];
	 
	 // Decode Pipeline Register
	 
	 // Execute stage control signals
	 logic PCSrcE, RegWriteE, MemtoRegE, MemWriteE, BranchE, ALUSrcE, FlagWriteE, 
	 logic [1:0] ALUControlE;
	 logic [3:0] CondE, FlagsE; // ELEPHANT assuming FlagsE is FlagsReg (4 bits)
	 
	 // Execute stage datapath buses
	 logic [31:0] SrcAE, RD2E, ExtImmE, WriteDataE
	 logic [3:0] WA3E;
	 always_ff @(posedge clk) begin
		if (rst) begin
			SrcAE <= '0; 
			RD2E <= '0;
			WriteDataE <= '0;
			WA3E <= 0;
			ExtImmE <= '0;
			
			PCSrcE <= 0;
			RegWriteE <= 0;
			MemtoRegE <= 0;
			MemWriteE <= 0;
			BranchE <= 0;
			ALUSrcE <= 0;
			FlagWriteE <= 0;
			ALUControlE <= '0;
			CondE <= '0;
			FlagsE <= '0;
		end
		else begin
			SrcAE <= RD1D; 
			RD2E <= RD2D;
			WriteDataE <= WriteDataD;
			WA3E <= WA3D;
			ExtImmE <= ExtImmD;
			
			PCSrcE <= PCSrcD;
			RegWriteE <= RegWriteD;
			MemtoRegE <= MemtoRegD;
			MemWriteE <= MemWriteD;
			BranchE <= BranchD;
			ALUSrcE <= ALUSrcD;
			FlagWriteE <= FlagWriteD;
			ALUControlE <= ALUControlD;
			CondE <= CondD;
			FlagsE <= FlagsD;
		end
	 end
	 
	 // EXECUTE STAGE 
	 
	 // Execute stage datapath buses and signals
	 logic [ 3:0] ALUFlags;                  // alu combinational flag outputs
	 logic [3:0] FlagsReg;
	 logic [31:0] ALUResultE;
	 logic [31:0] SrcBE;
    
	 assign SrcBE = ALUSrcE ? ExtImmE : WriteDataE;     // determine alu operand to be either from reg file or from immediate

    // Hook up inputs and outputs of alu module (from Lab 1) 
    alu u_alu (
        .a          (SrcAE), 
        .b          (SrcBE),
        .ALUControl (ALUControlE),
        .Result     (ALUResultE),
        .ALUFlags   (ALUFlags)
    );
	 
	 // Cond Unit
	 
	 // ELEPHANT: what is the purpose of FlagsE and FLagsPrime, which one is the equivalent of FlagsReg?
	 // ELEPHANT: what is CondExE? Is it Valid & IsCond?
	 // Write contents of ALUFlags to FlagsReg if we're executing the CMP command (FlagWrite == 1)
	 always_ff @(posedge clk)
	 begin
		if (rst) FlagsReg <= 4'b0000; // Default
		else if (FlagWriteE) FlagsReg <= ALUFlags;
	 end
	 
	 // Sets IsCond control signal if instruction is conditional
	 always_comb begin
		if (CondE == 4'b1110) IsCond = 1'b0;
		else IsCond = 1'b1;
	 end
	 
	 // Checks the flags to see if the comparison was valid based on the exact instruction
	 always_comb begin
		case (Instr[31:28])
			4'b0000: Valid = FlagsReg[2]; // EQ
			4'b0001: Valid = ~FlagsReg[2]; // NE
			4'b1010: Valid = (~FlagsReg[3] ^ FlagsReg[0]); // GE
			4'b1100: Valid = (~(FlagsReg[2]) & (~(FlagsReg[3] ^ FlagsReg[0]))); // GT
			4'b1101: Valid = FlagsReg[2] | (FlagsReg[3] ^ FlagsReg[0]); // LE
			4'b1011: Valid = (FlagsReg[3] ^ FlagsReg[0]); // LT
			default: Valid = 1'b0;
		endcase
	 end
	 
	 // Execute Pipeline Register
	 logic [31:0] ALUOutM, WriteDataM;
	 logic [3:0] WA3M;
	 always_ff @(posedge clk) begin
		if (rst) begin
			WriteDataM <= 0;
			ALUOutM <= 0;
			WA3M <= 0;
		end
		else
			WriteDataM <= WriteDataE;
			ALUOutM <= ALUResultE;
			WA3M <= WA3E;
		end
	 end
	 
	 
	 // MEMORY STAGE
	 
	 // our outputs (ALUOutM and WriteDataM) become the inputs for dmem module in top
	 // our input ReadDataM is the output of dmem in top
	
	 // Memory Pipeline Register
	 logic [31:0] ALUOutW, ReadDataW;
	 logic [3:0] WA3W;
	 always_ff @(posedge clk) begin
		if (rst) begin
			ReadDataW <= 0;
			ALUOutW <= 0;
			WA3W <= 0;
		end
		else begin
			ReadDataW <= ReadDataM;
			ALUOutW <= ALUOutM;
			WA3W <= WA3M;
		end
	 end
	 
	 // WRITEBACK STAGE

    // determine the result to run back to PC or the register file based on whether we used a memory instruction
    logic [31:0] ResultW;
	 assign ResultW = MemtoReg ? ReadDataW : ALUOutW;    // determine whether final writeback result is from dmemory or alu


    /* The control conists of a large decoder, which evaluates the top bits of the instruction and produces the control bits 
    ** which become the select bits and write enables of the system. The write enables (RegWrite, MemWrite and PCSrc) are 
    ** especially important because they are representative of your processors current state. 
    */
    //-------------------------------------------------------------------------------
    //                                      CONTROL
    //-------------------------------------------------------------------------------
   
	 
	 // Enable ADD, SUB, AND, ORR, LDR, STR, unconditional B, conditional B, and CMP instructions to be executed 
    always_comb begin
        casez (Instr[27:20])

            // ADD (Imm or Reg)
            8'b00?_0100_0 : begin   // note that we use wildcard "?" in bit 25. That bit decides whether we use immediate or reg, but regardless we add
                PCSrc    = 0;
                MemtoReg = 0; 
                MemWrite = 0; 
                ALUSrc   = Instr[25]; // may use immediate
                RegWrite = 1;
                RegSrc   = 'b00;
                ImmSrc   = 'b00; 
                ALUControl = 'b00;
					 FlagWrite = 0;
					 RegW = 1;
					 NoWrite = 0;
            end

            // SUB (Imm or Reg)
            8'b00?_0010_0 : begin   // note that we use wildcard "?" in bit 25. That bit decides whether we use immediate or reg, but regardless we sub
                PCSrc    = 0; 
                MemtoReg = 0; 
                MemWrite = 0; 
                ALUSrc   = Instr[25]; // may use immediate
                RegWrite = 1;
                RegSrc   = 'b00;
                ImmSrc   = 'b00; 
                ALUControl = 'b01;
					 FlagWrite = 0;
					 RegW = 1;
					 NoWrite = 0;
            end

            // AND
            8'b000_0000_0 : begin
                PCSrc    = 0; 
                MemtoReg = 0; 
                MemWrite = 0; 
                ALUSrc   = 0; 
                RegWrite = 1;
                RegSrc   = 'b00;
                ImmSrc   = 'b00;    // doesn't matter
                ALUControl = 'b10; 
					 FlagWrite = 0;
					 RegW = 1;
					 NoWrite = 0; 
            end

            // ORR
            8'b000_1100_0 : begin
                PCSrc    = 0; 
                MemtoReg = 0; 
                MemWrite = 0; 
                ALUSrc   = 0; 
                RegWrite = 1;
                RegSrc   = 'b00;
                ImmSrc   = 'b00;    // doesn't matter
                ALUControl = 'b11;
					 FlagWrite = 0;
					 RegW = 1;
					 NoWrite = 0;
            end

            // LDR
            8'b010_1100_1 : begin
                PCSrc    = 0; 
                MemtoReg = 1; 
                MemWrite = 0; 
                ALUSrc   = 1;
                RegWrite = 1;
                RegSrc   = 'b10;    // msb doesn't matter
                ImmSrc   = 'b01; 
                ALUControl = 'b00;  // do an add
					 FlagWrite = 0;
					 RegW = 1;
					 NoWrite = 0;
            end

            // STR
            8'b010_1100_0 : begin
                PCSrc    = 0; 
                MemtoReg = 0; // doesn't matter
                MemWrite = 1; 
                ALUSrc   = 1;
                RegWrite = 0;
                RegSrc   = 'b10;    // msb doesn't matter
                ImmSrc   = 'b01; 
                ALUControl = 'b00;  // do an add
					 FlagWrite = 0;
					 RegW = 0;
					 NoWrite = 0;
            end

            // B, now has logic for conditional and unconditional branching
            8'b1010_???? : begin
					if (IsCond & Valid) begin // valid conditional branching
                    PCSrc    = 1; 
                    MemtoReg = 0;
                    MemWrite = 0; 
                    ALUSrc   = 1;
                    RegWrite = RegW & ~NoWrite;
                    RegSrc   = 'b01;
                    ImmSrc   = 'b10; 
                    ALUControl = 'b00;  // do an add
						  FlagWrite = 0;
						  RegW = 0;
						  NoWrite = 0;
					 end
					 
					 else if (IsCond & ~Valid) begin // invalid conditional branching
                    PCSrc    = 0; 
                    MemtoReg = 0;
                    MemWrite = 0; 
                    ALUSrc   = 1;
                    RegWrite = RegW & ~NoWrite;
                    RegSrc   = 'b01;
                    ImmSrc   = 'b10; 
                    ALUControl = 'b00;  // do an add
						  FlagWrite = 0;
						  RegW = 0;
						  NoWrite = 0;
					 end
					 
					 else begin // unconditional branching
                    PCSrc    = 1; 
                    MemtoReg = 0;
                    MemWrite = 0; 
                    ALUSrc   = 1;
                    RegWrite = RegW & ~NoWrite;
                    RegSrc   = 'b01;
                    ImmSrc   = 'b10; 
                    ALUControl = 'b00;  // do an add
						  FlagWrite = 0;
						  RegW = 0;
						  NoWrite = 0;
					 end
            end
				
				// CMP
				8'b00?_0010_1 : begin   // note that we use wildcard "?" in bit 25. That bit decides whether we use immediate or reg, but regardless we sub
                PCSrc    = 0; 
                MemtoReg = 0; 
                MemWrite = 0; 
                ALUSrc   = Instr[25]; // may use immediate
                RegWrite = 1;
                RegSrc   = 'b00;
                ImmSrc   = 'b00; 
                ALUControl = 'b01;
					 FlagWrite = 1;
					 RegW = 1;
					 NoWrite = 1;
            end

			default: begin
					PCSrc    = 0; 
				   MemtoReg = 0; // doesn't matter
				   MemWrite = 0; 
				   ALUSrc   = 0;
				   RegWrite = 0;
				   RegSrc   = 'b00;
				   ImmSrc   = 'b00; 
				   ALUControl = 'b00;  // do an add
				   FlagWrite = 0;
				   RegW = 0;
				   NoWrite = 0;
			end
        endcase
    end


endmodule