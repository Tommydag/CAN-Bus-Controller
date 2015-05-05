`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    19:14:03 04/27/2015 
// Design Name: 
// Module Name:    tx_container 
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
module tx_container(
	output reg tx,
	input rx,
	input[10:0] address,
	input clk,
	input baud_clk,
	input rst,
	input [63:0] data,
	input send_data
    );


	parameter  init = 2'h0,  ones = 2'h1, zeros = 2'h2;
	
	reg bit_stuffing = 0;
	reg[1:0] c_state=0, n_state=0, p_state = 0;
	reg[31:0] bit_stuffing_count = 0;
	wire can_bitstuff;
	can_tx tx_block(tx_buf,can_bitstuff,rx,address,clk,baud_clk,rst,data,send_data,tx);
		
	always @ (posedge clk or posedge rst) begin
		if(rst) begin
			bit_stuffing_count<= 0;
			bit_stuffing <= 0;
		end
		else begin
			if(n_state != c_state) begin
				bit_stuffing_count<= 0;
				bit_stuffing <= 0;
			end
			else if(!can_bitstuff) begin
				bit_stuffing_count <= 0;
				bit_stuffing <= 0;
			end 
			else if(bit_stuffing_count >= 5000)begin
				bit_stuffing_count <= 0;
				bit_stuffing <= 0;
			end
			else if(bit_stuffing_count >= 4000)begin
				bit_stuffing_count <= bit_stuffing_count + 1;
				bit_stuffing <= 1;
			end
			else begin
				bit_stuffing_count <= bit_stuffing_count +1;
				bit_stuffing <= 0;
			end
		end
	end

	always @ (negedge clk) begin
		c_state <= n_state;
	end

	always @ (tx_buf) begin
		if(tx_buf == 1) begin
			n_state<= ones;
		end
		else begin
			n_state <= zeros;
		end
	end

	always @ (bit_stuffing or tx_buf) begin
		if(bit_stuffing) begin
			tx <= ~tx_buf;
		end
		else begin
			tx <= tx_buf;
		end
	end
endmodule
