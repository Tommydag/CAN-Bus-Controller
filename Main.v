`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Rose-Hulman Institute of Technology
// Tom D'Agostino
// ECE398 CAN Controller Design
// 
// Create Date:    23:00 03/26/2015
// Module Name:    main
// Project Name:   CAN_Controller
// Target Devices: Nexys 3 running a Xilinx Spartan6 XC6LX16-CS324
// Description: Implements the CAN Bus protocol.
//////////////////////////////////////////////////////////////////////////////////
module Main(
	output CAN_TX,
	input CAN_RX,
	input RESET,
	input CLOCK_SIGNAL_IN,
	input send_data,
	input[7:0] transmit_data
	);
	
	wire[31:0] tx_data;
	
	assign tx_data = {4{transmit_data}};
	
	//Device address
	parameter address = 11'h25;
	
	//Clock Generator
	Clock_gen clock_block(CLOCK_SIGNAL_IN,clk);
	BaudGen baud_calc(clk,RESET,baud_clk);
	
	//Tx Block
	can_tx tx_block(CAN_TX,CAN_RX,address,clk,baud_clk,RESET,tx_data,send_data);
	
	//tx_container tx_can(CAN_TX,CAN_RX,address,clk,baud_clk,RESET,transmit_data, send);

endmodule
