/******************************************************************************
* DVT CODE TEMPLATE: interface
* Created by wpotaczek on Jan 22, 2021
* uvc_company = wp, uvc_name = alu
*******************************************************************************/

//------------------------------------------------------------------------------
//
// INTERFACE: wp_alu_if
//
//------------------------------------------------------------------------------

// Just in case you need them
`include "uvm_macros.svh"

interface wp_alu_if(clock,reset);

	// Just in case you need it
	import uvm_pkg::*;
	import wp_alu_pkg::*;

	// Clock and reset signals
	input clock;
	input reset;

	// Flags to enable/disable assertions and coverage
	bit checks_enable=1;
	bit coverage_enable=1;

	// TODO Declare interface signals here
	
	bit		sin = 1'b1;
	bit		sout;  
	
	logic [7:0] q_A[$];
	logic [7:0] q_B[$];
	logic [7:0] q_CTL[$];
	
	reg [10:0] captured_sin = 0;
	reg [10:0] captured_sout = 0;
	bit [7:0] CTL_data;
	
//	logic valid;
//	logic[7:0] data;

//	//You can add covergroups in interfaces
//	covergroup signal_coverage@(posedge clock);
//		//add coverpoints here
//	endgroup
//	// You must instantiate the covergroup to collect coverage
//	signal_coverage sc=new;
//
//	// You can add SV assertions in interfaces
//	my_assertion:assert property (
//			@(posedge clock) disable iff (reset === 1'b0 || !checks_enable)
//			valid |-> (data!==8'bXXXX_XXXX)
//		)
//	else
//		`uvm_error("ERR_TAG","Error")

	task send_byte(input frame_type, input [7:0] essence);
	begin
		//@(negedge clock)
		sin <= 1'b0;
		@(negedge clock)
		sin <= frame_type;
		@(negedge clock)
		sin = essence[7];
     	@(negedge clock)
      sin = essence[6];
      @(negedge clock)
      sin = essence[5];
      @(negedge clock)
      sin = essence[4];
      @(negedge clock)
      sin = essence[3];
      @(negedge clock)
      sin = essence[2];
      @(negedge clock)
      sin = essence[1];
      @(negedge clock)
      sin = essence[0];
      @(negedge clock)
		sin <= 1'b1;
		@(negedge clock);
	end
	endtask

	task send_calculation_data (input [31:0] B, input [31:0] A, input [2:0] OP, input [3:0] CRC);
	begin
		send_byte(DATA_TYPE, B[31:24]);
		send_byte(DATA_TYPE, B[23:16]);
		send_byte(DATA_TYPE, B[15:8]);
		send_byte(DATA_TYPE, B[7:0]);
		
		send_byte(DATA_TYPE, A[31:24]);
		send_byte(DATA_TYPE, A[23:16]);
		send_byte(DATA_TYPE, A[15:8]);
		send_byte(DATA_TYPE, A[7:0]);		
	
		send_byte(CMD_TYPE, {1'b0, OP, CRC});
	end	
	endtask
	
	task capture_sout (output bit [31:0] cap_C, output bit [7:0] cap_CTL);
	begin	
		
		repeat (12)
		begin
			captured_sout <= {captured_sout[9:0], sout};
			@(negedge clock);
		end
		
		if(captured_sout[9] == 1'b0) begin
			cap_C[7:0] = captured_sout[8:1];
			repeat (3)
			begin				
				repeat (11)
				begin
					captured_sout <= {captured_sout[9:0], sout};
					@(negedge clock);
				end
				cap_C <= {cap_C,captured_sout[8:1]};
			end
			
			repeat (11)
			begin
				captured_sout <= {captured_sout[9:0], sout};
				@(negedge clock);
			end			
			cap_CTL = captured_sout[8:1]; 
		end
		
		else begin
			cap_C = 1'b0;
			cap_CTL = captured_sout[8:1];
		end
	end
	endtask
	
	task automatic sin_to_queue();		
	begin	
		repeat (12)
		begin
			captured_sin <= {captured_sin[9:0], sin};
			@(posedge clock);
		end
		if(captured_sin[9] == 1'b1)
			q_CTL.push_front(captured_sin[8:1]);
		else
			q_B.push_front(captured_sin[8:1]);
		repeat (3)
		begin
			repeat (11)
			begin
				captured_sin <= {captured_sin[9:0], sin};
				@(posedge clock);
			end
			if(captured_sin[9] == 1'b1)
				q_CTL.push_front(captured_sin[8:1]);
			else begin
				q_B.push_front(captured_sin[8:1]);				
			end
		end
		repeat (4)
		begin
			repeat (11)
			begin
				captured_sin <= {captured_sin[9:0], sin};
				@(posedge clock);
			end
			if(captured_sin[9] == 1'b1)
				q_CTL.push_front(captured_sin[8:1]);
			else begin
				q_A.push_front(captured_sin[8:1]);				
			end
		end
		repeat (11)
			begin
				captured_sin <= {captured_sin[9:0], sin};
				@(posedge clock);
			end
		q_CTL.push_front(captured_sin[8:1]);
		/*
		if(captured_sin[9] == 1'b1)
			q_CTL.push_front(captured_sin[8:1]);
		else
			q_B.push_front(captured_sin[8:1]);
		repeat (3)
		begin
			repeat (11)
			begin
				captured_sin <= {captured_sin[9:0], sin};
				@(posedge clock);
			end
			if(captured_sin[9] == 1'b1)
				q_CTL.push_front(captured_sin[8:1]);
			else begin
				q_B.push_front(captured_sin[8:1]);				
			end
		end
		repeat (4)
		begin
			repeat (11)
			begin
				captured_sin <= {captured_sin[9:0], sin};
				@(posedge clock);
			end
			if(captured_sin[9] == 1'b1)
				q_CTL.push_front(captured_sin[8:1]);
			else begin
				q_A.push_front(captured_sin[8:1]);				
			end
		end
		repeat (11)
			begin
				captured_sin <= {captured_sin[9:0], sin};
				@(posedge clock);
			end			
		q_CTL.push_front(captured_sin[8:1]);
		*/
	end
	endtask
	
	task automatic decode_sin(output [31:0] A_data, output [31:0] B_data, operation_t op_data);
	begin
		if((q_A.size() < 4) | (q_B.size() < 4) | (q_CTL.size() > 1)) begin

			op_data = er_data_op;
		   q_A.delete();
		   q_B.delete();
		   q_CTL.delete();
	   end
	   
	   else begin
	   	A_data[31:24] = q_A.pop_back();
	   	A_data[23:16] = q_A.pop_back();
	   	A_data[15:8] = q_A.pop_back();
	   	A_data[7:0] = q_A.pop_back();
	   
	  		B_data[31:24] = q_B.pop_back();
	   	B_data[23:16] = q_B.pop_back();
	   	B_data[15:8] = q_B.pop_back();
	   	B_data[7:0] = q_B.pop_back();
		   
	   	CTL_data = q_CTL.pop_back();
		   //op_data = CTL_data[6:4];
		   $cast(op_data, CTL_data[6:4]);	
	   	   
	   	if(CTL_data[3:0] != crc4_generate({B_data,A_data,1'b1,op_data},4'h0))
	   		op_data = er_crc_op;
	   	
	   	else if(CTL_data[5] == 1'b1)
		   	op_data = er_op_op;	   
	   end
	end
	endtask		

	task automatic wait_sin(output [31:0] A_data, output [31:0] B_data, operation_t op_data);
		@(negedge sin)
			sin_to_queue();
	  		decode_sin(A_data, B_data, op_data);
	endtask
	
	task automatic wait_sout(output bit [31:0] cap_C, output bit [7:0] cap_CTL, output bit done);
		@(negedge sout)
	   	capture_sout(cap_C, cap_CTL);
		done = 1'b1;
	endtask

   function [3:0] crc4_generate;
   // polynomial: x^4 + x^1 + 1
    input [67:0] Data;
    input [3:0] crc;
    reg [67:0] d;
    reg [3:0] c;
    reg [3:0] newcrc;
    begin
        d = Data;
        c = crc;
   
       newcrc[0] = d[66] ^ d[64] ^ d[63] ^ d[60] ^ d[56] ^ d[55] ^ d[54] ^ d[53] ^ d[51] ^ d[49] ^ d[48] ^ d[45] ^ d[41] ^ d[40] ^ d[39] ^ d[38] ^ d[36] ^ d[34] ^ d[33] ^ d[30] ^ d[26] ^ d[25] ^ d[24] ^ d[23] ^ d[21] ^ d[19] ^ d[18] ^ d[15] ^ d[11] ^ d[10] ^ d[9] ^ d[8] ^ d[6] ^ d[4] ^ d[3] ^ d[0] ^ c[0] ^ c[2];
       
       newcrc[1] = d[67] ^ d[66] ^ d[65] ^ d[63] ^ d[61] ^ d[60] ^ d[57] ^ d[53] ^ d[52] ^ d[51] ^ d[50] ^ d[48] ^ d[46] ^ d[45] ^ d[42] ^ d[38] ^ d[37] ^ d[36] ^ d[35] ^ d[33] ^ d[31] ^ d[30] ^ d[27] ^ d[23] ^ d[22] ^ d[21] ^ d[20] ^ d[18] ^ d[16] ^ d[15] ^ d[12] ^ d[8] ^ d[7] ^ d[6] ^ d[5] ^ d[3] ^ d[1] ^ d[0] ^ c[1] ^ c[2] ^ c[3];
       
       newcrc[2] = d[67] ^ d[66] ^ d[64] ^ d[62] ^ d[61] ^ d[58] ^ d[54] ^ d[53] ^ d[52] ^ d[51] ^ d[49] ^ d[47] ^ d[46] ^ d[43] ^ d[39] ^ d[38] ^ d[37] ^ d[36] ^ d[34] ^ d[32] ^ d[31] ^ d[28] ^ d[24] ^ d[23] ^ d[22] ^ d[21] ^ d[19] ^ d[17] ^ d[16] ^ d[13] ^ d[9] ^ d[8] ^ d[7] ^ d[6] ^ d[4] ^ d[2] ^ d[1] ^ c[0] ^ c[2] ^ c[3];
       
       newcrc[3] = d[67] ^ d[65] ^ d[63] ^ d[62] ^ d[59] ^ d[55] ^ d[54] ^ d[53] ^ d[52] ^ d[50] ^ d[48] ^ d[47] ^ d[44] ^ d[40] ^ d[39] ^ d[38] ^ d[37] ^ d[35] ^ d[33] ^ d[32] ^ d[29] ^ d[25] ^ d[24] ^ d[23] ^ d[22] ^ d[20] ^ d[18] ^ d[17] ^ d[14] ^ d[10] ^ d[9] ^ d[8] ^ d[7] ^ d[5] ^ d[3] ^ d[2] ^ c[1] ^ c[3];
       
       crc4_generate = newcrc;
    end
   endfunction :crc4_generate 
   
//	task reset_alu();
//
//		reset = 1'b0;
//		sin = 1'b1;
//      @(negedge clock);
//      @(negedge clock);
//      reset = 1'b1;
//      @(negedge clock);
//      @(negedge clock);	   
//      reset = 1'b0;
//      @(negedge clock);
//      @(negedge clock);
//      reset = 1'b1;
//	  endtask : reset_alu

	task send_op(input bit [31:0] A, input bit [31:0] B, operation_t op_set);
		@(negedge clock);
				case (op_set) // handle the start signal        	
         		er_data_op: begin : case_er_data_op 
	         		send_byte(DATA_TYPE, B[31:24]);
        				send_byte(DATA_TYPE, B[23:16]);
        				send_byte(DATA_TYPE, B[15:8]);
        				send_byte(DATA_TYPE, B[7:0]);
        
  						send_byte(DATA_TYPE, A[31:24]);
     					send_byte(DATA_TYPE, A[23:16]);
        				send_byte(DATA_TYPE, A[15:8]);
	         	
	         		send_byte(CMD_TYPE, {1'b0, add_op, crc4_generate({B,A,1'b1,add_op},4'h0)});
	         		send_byte(1'b1,{8'b11111111});
	         	end         	
         		er_crc_op: begin : case_er_crc_op
	         		//crc_error = (bfm.crc4_generate({B,A,1'b1,op},4'h0) + 1'b1);
        				send_calculation_data(B, A, and_op, (crc4_generate({B,A,1'b1,op_set},4'h0) + 1'b1));
         		end
         		er_op_op: begin : case_er_op_op
	         		send_calculation_data(B, A, op_set, crc4_generate({B,A,1'b1,op_set},4'h0));
         		end
//         		rst_op: begin :rst_op
//	         		reset_alu();
//	         	end         		
           		default: begin
	           		send_calculation_data(B, A, op_set, crc4_generate({B,A,1'b1,op_set},4'h0));
           		end
				endcase
	endtask : send_op

endinterface : wp_alu_if
