`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   14:31:35 04/27/2015
// Design Name:   can_tx
// Module Name:   C:/Users/dagosttv.ROSE-HULMAN/Documents/School/ECE/ECE398/CAN-Bus-Controller-/tx_test.v
// Project Name:  CAN_Controller
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: can_tx
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module tx_test;

	// Inputs
	wire rx;
	reg [10:0] address;
	reg clk;
	reg baud_clk;
	reg rst;
	reg [31:0] data;
	reg send_data;

	// Outputs
	wire tx;

	// Instantiate the Unit Under Test (UUT)
	can_tx uut (
		.tx(tx), 
		.rx(rx), 
		.address(address), 
		.clk(clk),
		.baud_clk(baud_clk),
		.rst(rst), 
		.data(data), 
		.send_data(send_data)
	);

	assign rx = tx;
	
	initial begin
		// Initialize Inputs
		address = 11'h28;
		clk = 1'b0;
		baud_clk = 1'b0;
		rst = 1'b1;
		data = 32'd0;
		send_data = 1'b0;
		// Add stimulus here
		#100 rst = 0;
		#100 data = 32'hAAAAAAAA;
		#110 send_data = 1'b1;
		#300 send_data = 1'b0;
		#310000 $stop;
	end
		always #2.5 clk=~clk;
		always #2000 baud_clk=~baud_clk;
endmodule

