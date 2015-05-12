`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    00:08:02 05/12/2015 
// Design Name: 
// Module Name:    shift_reg 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module shift_reg(
    input rx,
    output [99:0] shifted_bus,
    input rst,
    input baud_clk
    );



	reg [99:0] bitShiftReg;

	always @(posedge baud_clk or posedge rst) begin
		if(rst)
			bitShiftReg <= 100'd0;
		else
			bitShiftReg <= {bitShiftReg[98:0],rx};
	end


assign shifted_bus = bitShiftReg[7];




endmodule
