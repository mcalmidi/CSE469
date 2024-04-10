// Akhila Narayanan and Manasvini Calmidi
// 4/4/2024
// CSE 469
// Lab #1, Task 3

// alu takes 2-bit ALUControl and 32-bit a and b as inputs and returns 32-bit Result 
// and 4-bit ALUFlags as outputs. It can perform addition, subtraction, logical &, and 
// logical |. Depending on the value of ALUControl (which represents the operation 
// being performed), Result will be driven by the actual logical operation (&/|), or
// an intermediate bus called addResult. ALUFlags tells us whether the following has 
// occurred: Result is negative, Result is zero, an addition/subtraction operation 
// caused a carry bit past 32-bits, and whether an addition/subtration operation caused
// an overflow. 

module alu (a, b, ALUControl, Result, ALUFlags);
	input logic [31:0] a, b;
	input logic [1:0] ALUControl;
	output logic [31:0] Result;
	output logic [3:0] ALUFlags;
	
	// Performs an addition operation on a and b. 
	
	// Intermediary buses:
	// 
	// "bout": Since a subtration operation is just adding by the two's complement of b, 
	// we made an intermediary bus which will hold the two's complement of b (we named 
   // this "tb") if we are subtracting
	//
	// "couts": We made a 32-bit bus that saves the value of each current instance of
	// the fullAdder module's "cout" at index "i". This is because we needed each 
	// instance of fullAdder to take in the previous value of "cout" as its "cin".
	// This is also why we needed to instantiate the 0th instance of the fullAdder module 
	// by itself because there is no previous "cout" we could use. We needed to hard-code 
	// 1'b0 as the "cin"
	//
	// "addRes": since we could not call the generate statements inside the always_comb, 
	// we cannot check if ALUControl has indicated that it was an addition/subtraction 
	// operation before performing the addition. Thus, every instance of alu will always 
	// add the 32-bits of a and b regardless of the value ALUControl. So, since Result 
	// cannot have multiple drivers, we saved the sum in an intermediary bus called "addRes". 
	// Later on, in the always_comb block, we can determine whether Result will hold addRes.
	logic [31:0] couts, bout, tb, addRes;
	assign tb = ~b + 1'b1;
	
	// Our fullAdder module only adds 1 bit at a time, so we used a generate statement
	// to add all 32 bits.
	logic cin;
	fullAdder m_add_0(.A(a[0]), .B(bout[0]), .cin(1'b0), .sum(addRes[0]), .cout(couts[0]));
	genvar i;
	generate 
		for (i = 1; i < 32; i++) begin : add
			fullAdder m_add(.A(a[i]), .B(bout[i]), .cin(couts[i-1]), .sum(addRes[i]), .cout(couts[i]));
		end
	endgenerate
	
	// Combinational logic responsible for determining which operation has occurred.
	always_comb begin
		// Set bout to two's complement if we are subtracting
		if (ALUControl[0] == 1'b0) bout = b;
		else bout = tb;
		
		// And
		if (ALUControl == 2'b10) Result = a & b;
		
		// Or
		else if (ALUControl == 2'b11) Result = a | b;
		
		// Add/Subtract
		else Result = addRes;
		
		// Flags
		
		// Negative
		ALUFlags[3] = Result[31];
		
		// Zero
		ALUFlags[2] = (Result == 0);
		
		// Carry
		ALUFlags[1] = couts[31] & ~ALUControl[1];
		
		// Overflow
		ALUFlags[0] = ~ALUControl[1] & (Result[31] ^ a[31]) & ~(ALUControl[0] ^ a[31] ^ b[31]);
	end
endmodule // alu

