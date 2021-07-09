`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   01:58:48 06/16/2021
// Design Name:   Final_p
// Module Name:   D:/verilog test/final_project/Final_project/final_p_tb.v
// Project Name:  Final_project
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: Final_p
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module final_p_tb;

	// Inputs
	reg [3:0] rowk;
	reg [3:0] columnk;
	reg equal;
	reg clk;
	reg rst;

	// Outputs
	wire [15:0] quotient;
	wire [15:0] remainder;
	wire [15:0] dividend;
	wire [15:0] divisor;
	wire [31:0] reg_remainder;

	// Instantiate the Unit Under Test (UUT)
	Final_p uut (
		.quotient(quotient), 
		.remainder(remainder), 
		.reg_remainder(reg_remainder), 
		.rowk(rowk), 
		.columnk(columnk), 
		.divisor(divisor),
		.dividend(dividend),
		.equal(equal), 
		.clk(clk), 
		.rst(rst)
	);
	always #5 clk = ~clk;
	initial begin
		// Initialize Inputs
		rowk = 0;
		columnk = 0;
		equal = 0;
		clk = 0;
		rst = 0;
		#10 rst = 1;
		#10 rst = 0;
			//=============================//
		#20 columnk = 2;
			rowk = 2;
		#20 columnk = 0;
			rowk = 0;
		#20 columnk = 1;
			rowk = 1;
		#20 columnk = 0;
			rowk = 0;
		#20 columnk = 2;
			rowk = 2;
		#20 columnk = 0;
			rowk = 0;
		#20 columnk = 2;
			rowk = 2;
		#20 columnk = 0;
			rowk = 0;	
		
		#20 columnk = 2;
			rowk = 1;
		#20 columnk = 0;
			rowk = 0;
		#20 columnk = 2;
			rowk = 4;
		#20 columnk = 0;
			rowk = 0;
		#20 columnk = 1;
			rowk = 1;
		#20 columnk = 0;
			rowk = 0;
		#20 columnk = 2;
			rowk = 2;
		#20 columnk = 0;
			rowk = 0;
		

		#20 equal = 1;
		// Wait 100 ns for global reset to finish
		#100;
        
		// Add stimulus here

	end
      
endmodule

