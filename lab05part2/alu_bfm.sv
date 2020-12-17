	/******************************************************************************
* (C) Copyright 2013 <Company Name> All Rights Reserved
*
* MODULE:    name
* DEVICE:
* PROJECT:
* AUTHOR:    wpotaczek
* DATE:      2020 4:26:25 PM
*
* ABSTRACT:  You can customize the file content from Window -> Preferences -> DVT -> Code Templates -> "verilog File"
*
*******************************************************************************/

interface alu_bfm;
import alu_pkg::*;

	bit		clk;
	bit		rst_n;
	bit		sin = 1'b1;
	wire		sout;  
			
	
	bit [7:0] q_A[$];
	bit [7:0] q_B[$];
	bit [7:0] q_CTL[$];
	
	reg [10:0] captured_sin = 0;
	reg [10:0] captured_sout = 0;
	bit [7:0] CTL_data;
	
	bit [31:0] A_temp;
	bit [31:0] B_temp;
	operation_t OP_temp;
	bit [3:0] start = 4'b0;
	bit done = 1'b0;
	
		bit [31:0] cap_C;
  	bit [7:0] cap_CTL_sout;
	
	
//------------------------------------------------------------------------------
// Clock generator
//------------------------------------------------------------------------------

	initial begin : clk_gen
		clk = 0;
      forever begin : clk_frv
         #10;
         clk = ~clk;
      end
   end


//------------------------------------------------------------------------------
// Custom Macros/Tasks/Functions
//------------------------------------------------------------------------------
	
	task send_byte(input frame_type, input [7:0] essence);
	begin
		//@(negedge clk)
		sin <= 1'b0;
		@(negedge clk)
		sin <= frame_type;
		@(negedge clk)
		sin = essence[7];
     	@(negedge clk)
      sin = essence[6];
      @(negedge clk)
      sin = essence[5];
      @(negedge clk)
      sin = essence[4];
      @(negedge clk)
      sin = essence[3];
      @(negedge clk)
      sin = essence[2];
      @(negedge clk)
      sin = essence[1];
      @(negedge clk)
      sin = essence[0];
      @(negedge clk)
		sin <= 1'b1;
		@(negedge clk);
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
			@(negedge clk);
		end
		
		if(captured_sout[9] == 1'b0) begin
			cap_C[7:0] = captured_sout[8:1];
			repeat (3)
			begin				
				repeat (11)
				begin
					captured_sout <= {captured_sout[9:0], sout};
					@(negedge clk);
				end
				cap_C <= {cap_C,captured_sout[8:1]};
			end
			
			repeat (11)
			begin
				captured_sout <= {captured_sout[9:0], sout};
				@(negedge clk);
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
			@(posedge clk);
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
				@(posedge clk);
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
				@(posedge clk);
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
				@(posedge clk);
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
				@(posedge clk);
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
				@(posedge clk);
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
				@(posedge clk);
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
   
	task reset_alu();

		rst_n = 1'b0;
		sin = 1'b1;
      @(negedge clk);
      @(negedge clk);
      rst_n = 1'b1;
      @(negedge clk);
      @(negedge clk);	   
      rst_n = 1'b0;
      @(negedge clk);
      @(negedge clk);
      rst_n = 1'b1;
	  endtask : reset_alu

	task send_op(input bit [31:0] A, input bit [31:0] B, operation_t op_set);
		@(negedge clk);
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
         		rst_op: begin :rst_op
	         		reset_alu();
	         		start += 1;
	         	end         		
           		default: begin
	           		send_calculation_data(B, A, op_set, crc4_generate({B,A,1'b1,op_set},4'h0));
           		end
				endcase
	endtask : send_op
	
//------------------------------------------------------------------------------	
	
	command_monitor command_monitor_h;


function operation_t op2enum(operation_t op);
    operation_t opi;
    if( ! $cast(opi,op) )
        $fatal(1, "Illegal operation on op bus");
    return opi;
endfunction : op2enum

always @(posedge clk) begin : op_monitor
    //static bit in_command = 0;
    //if (start) begin : start_high
    //if (!in_command) begin : new_command
    
   forever begin : self_checker
		wait_sin(A_temp, B_temp, OP_temp);   			

    	//command.A  = A_temp;
    	//command.B  = B_temp;
      //command.op = op2enum(OP_temp);
      command_monitor_h.write_to_monitor(A_temp, B_temp, op2enum(OP_temp));
      //in_command = (command.op != no_op);
    end
    //else // start low
    	//in_command            = 0;
	forever begin
   	@(negedge rst_n) begin : rst_monitor
    		//op = rst_op;
    		if (command_monitor_h != null) //guard against VCS time 0 negedge
        		command_monitor_h.write_to_monitor(0,0,rst_op);
   	end : rst_monitor
	end
end : op_monitor



result_monitor result_monitor_h;

initial begin : result_monitor_thread
	bit [39:0] result;
//	bit [31:0] cap_C;
//  	bit [7:0] cap_CTL_sout;
	//reset_alu();
	forever begin
      @(posedge clk) ;
		wait_sout(cap_C, cap_CTL_sout, done);
   	if (done)
	   begin 
	   	result[39:8] = cap_C;
   		result[7:0] = cap_CTL_sout;
			result_monitor_h.write_to_monitor(result);
   		done = 1'b0;
	   end	   
    end
end : result_monitor_thread

endinterface : alu_bfm