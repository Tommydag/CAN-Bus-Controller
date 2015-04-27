`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Rose-Hulman Institute of Technology
// Tom D'Agostino
// ECE398 CAN Controller Design
// 
// Create Date:    23:00 03/26/2015
// Module Name:    can_tx
// Project Name:   CAN_Controller
// Target Devices: Nexys 3 running a Xilinx Spartan6 XC6LX16-CS324
// Description: Implements the TX portion of the protocol.
//////////////////////////////////////////////////////////////////////////////////
module can_tx(
	output reg tx,
	input rx,
	input[10:0] address,
	input clk,
	input rst,
	input [31:0] data,
	input send_data
	);
	
	parameter idle = 8'h0,  waiting = 8'h1, addressing =8'h2 ,rtr = 8'h3 ,ide = 8'h4, reserve_bit = 8'h5, num_of_bytes = 8'h6 ,
			data_out = 8'h7, crc_out = 8'h8, crc_delimiter = 8'h9 , ack = 8'hA, ack_delimiter =  8'hB, end_of_frame = 8'hC;

	parameter bytes = 4'd4;
	wire baud_clk;

	reg[10:0] count  = 0;
	reg[4:0] address_count = 0, crc_count = 0;
	reg[5:0] data_bit_count = 0;
	reg[2:0] data_byte_cout = 0;
	reg[7:0] c_state=0, n_state=0;
	reg outputting = 0;
	wire[15:0] crc_check;

	BaudGen baud_calc(clk,rst,baud_clk);
	CRC cyclic_red_check(data,1,crc_check,rst,clk);
	
	//Update Logic
	always @ (posedge baud_clk or posedge rst) begin
		if(rst == 1) begin
			c_state <= 32'd0;
		end
		else begin
			c_state <= n_state;
		end
	end

	always @ (posedge baud_clk or posedge rst) begin
		if(rst == 1) begin
			count <= 0;
		end
		else begin
			count <= count + 1;
		end
	end

	//Next State Logic
	always @ (c_state or rx or data or outputting or address_count) begin
		case(c_state)
			idle: begin
				if(outputting) begin
					n_state <= addressing;
				end
				else begin
					n_state <= idle;
				end
			end
			addressing: begin
				if(address_count == 4'd11) begin
					n_state <= rtr;
				end
				else begin
					n_state <= addressing;
				end
			end
			rtr: begin
				n_state <= num_of_bytes;
			end
			ide: begin
				n_state <= num_of_bytes;
			end
			reserve_bit: begin
				n_state <= num_of_bytes;
			end
			num_of_bytes: begin
				if(address_count == 4'd4) begin
					n_state <= data_out;
				end
				else begin
					n_state <= num_of_bytes;
				end
			end
			data_out: begin
				if(address_count == 6'd32) begin
					n_state <= crc_out;
				end
				else begin
					n_state <= data_out;
				end
			end
			crc_out: begin
				if(address_count == 4'd15) begin
					n_state <= crc_delimiter;
				end
				else begin
					n_state <= crc_out;
				end
			end
			crc_delimiter: begin
				n_state <= ack;
			end
			ack: begin
				n_state <= ack_delimiter;
			end
			ack_delimiter: begin
				n_state <= end_of_frame;
			end
			end_of_frame: begin
				if(address_count == 4'd8) begin
					n_state <= idle;
				end
				else begin
					n_state <= end_of_frame;
				end
			end
			default:
			begin
				n_state <= idle;
			end
		endcase
	end

	//Output Logic
	always @(c_state or address_count or data_byte_cout or data_bit_count or crc_count or address or data or crc_check) begin
		case(c_state) 
			idle: begin
				tx <= 0;
			end
			addressing: begin
				tx <= address[address_count];
			end
			rtr: begin
				tx <= 0;
			end
			ide: begin
				tx <= 0;
			end
			reserve_bit: begin
				tx <= 0;
			end
			num_of_bytes: begin
				tx <= bytes[data_byte_cout];
			end
			data_out: begin
				tx <= data[data_bit_count];
			end
			crc_out: begin
				tx <= crc_check[crc_count];
			end
			crc_delimiter: begin
				tx <= 1;
			end
			ack: begin
				tx <= 1;
			end
			ack_delimiter:begin
				tx <= 1;
			end
			end_of_frame: begin
				tx <= 1;
			end
			default: begin
				tx <= 1;
			end
		endcase
	end
		
	//Supporting Logic
	always @ (posedge send_data) begin
		if(send_data == 1) begin
			outputting <= 1;
		end
		else begin
			outputting <= 0;
		end
	end


endmodule
