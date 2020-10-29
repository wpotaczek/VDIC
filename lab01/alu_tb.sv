`timescale 1ns/1ps

module top;

//------------------------------------------------------------------------------
// type and variable definitions
//------------------------------------------------------------------------------

	typedef enum bit[2:0] {and_op			= 3'b000,
							  	  or_op 			= 3'b001,
                       	  add_op 		= 3'b100,
                       	  sub_op 		= 3'b101,
                       	  er_data_op	= 3'b010,
                       	  er_crc_op 	= 3'b011,
                       	  er_op_op 		= 3'b110} operation_t;
	
	
	
	localparam 	DATA_TYPE = 1'b0,
					CMD_TYPE = 1'b1,
					ERR_DATA_FRAME = 8'b11001001,
					ERR_CRC_FRAME = 8'b10100101,
					ERR_OP_FRAME = 8'b10010011;
	
	bit		clk;
	bit		rst_n;
	bit		sin;
	wire		sout;
   	
	
	bit [31:0]    A;
	bit [31:0]    B;
	
	reg [10:0] captured_sin = 0;
	reg [10:0] captured_sout = 0;
			
	logic [7:0] q_sin_A_scor[$];
	logic [7:0] q_sin_B_scor[$];
	logic [7:0] q_sin_CTL_scor[$];	
	logic [7:0] q_sin_A_cov[$];
	logic [7:0] q_sin_B_cov[$];
	logic [7:0] q_sin_CTL_cov[$];

	bit [2:0] op;	   
	operation_t  op_set;

	assign op = op_set;


//------------------------------------------------------------------------------
// Custom Macros/Tasks/Functions
//------------------------------------------------------------------------------
	
	task send_byte(input frame_type, input [7:0] essence);
	begin
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
	
	task automatic sin_to_queue(ref [7:0] q_A[$], ref [7:0] q_B[$], ref [7:0] q_CTL[$]);		
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
	end
	endtask
	
	task automatic decode_sin(ref [7:0] q_A[$], ref [7:0] q_B[$], ref [7:0] q_CTL[$], output [31:0] A_data, output [31:0] B_data, output [2:0] op_data);
	begin
		bit [7:0] CTL_data;
		
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
		   op_data = CTL_data[6:4];	
	   	   
	   	if(CTL_data[3:0] != crc4_generate({B_data,A_data,1'b1,op_data},4'h0))
	   		op_data = er_crc_op;
	   	
	   	else if(CTL_data[5] == 1'b1)
		   	op_data = er_op_op;	   
	   end
	end
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
   
	function [2:0] crc3_generate;

      input [36:0] Data;
      input [2:0] crc;
      reg [36:0] d;
      reg [2:0] c;
      reg [2:0] newcrc;
     begin
      d = Data;
      c = crc;

       newcrc[0] = d[35] ^ d[32] ^ d[31] ^ d[30] ^ d[28] ^ d[25] ^ d[24] ^ d[23] ^ d[21] ^ d[18] ^ d[17] ^ d[16] ^ d[14] ^ d[11] ^ d[10] ^ d[9] ^ d[7] ^ d[4] ^ d[3] ^ d[2] ^ d[0] ^ c[1];
       
       newcrc[1] = d[36] ^ d[35] ^ d[33] ^ d[30] ^ d[29] ^ d[28] ^ d[26] ^ d[23] ^ d[22] ^ d[21] ^ d[19] ^ d[16] ^ d[15] ^ d[14] ^ d[12] ^ d[9] ^ d[8] ^ d[7] ^ d[5] ^ d[2] ^ d[1] ^ d[0] ^ c[1] ^ c[2];
       
       newcrc[2] = d[36] ^ d[34] ^ d[31] ^ d[30] ^ d[29] ^ d[27] ^ d[24] ^ d[23] ^ d[22] ^ d[20] ^ d[17] ^ d[16] ^ d[15] ^ d[13] ^ d[10] ^ d[9] ^ d[8] ^ d[6] ^ d[3] ^ d[2] ^ d[1] ^ c[0] ^ c[2];
       
       crc3_generate = newcrc;
     end
   endfunction
	

//------------------------------------------------------------------------------
// DUT instantiation
//------------------------------------------------------------------------------

	mtm_Alu DUT (.clk, .rst_n, .sin, .sout);


//------------------------------------------------------------------------------
// Coverage block
//------------------------------------------------------------------------------

	reg [31:0] A_cov;
	reg [31:0] B_cov;
	reg [2:0] OP_cov;
	
	always @(negedge sin) begin
		sin_to_queue(q_sin_A_cov,q_sin_B_cov,q_sin_CTL_cov);
	   decode_sin(q_sin_A_cov,q_sin_B_cov,q_sin_CTL_cov, A_cov, B_cov, OP_cov);
   end

   covergroup op_cov;	   
	   
      option.name = "cg_op_cov";

      coverpoint OP_cov {
         // #A1 test all operations
         bins A1_single_cycle[] = {[and_op : er_op_op]};

         //#A2 two operations in row
         bins A2_twoops[] = ([add_op:sub_op] [* 2]);
	      
	     	//#A3 two errors in row
         bins A3_twoops[] = ([er_data_op:er_op_op] [* 2]);
	      
	      // #A4 test all operations after errors
         bins A4_op_er[] = ([er_data_op:er_op_op] => [and_op:sub_op]);
	      
	      // #A5 test all errors after operations
         bins A5_er_op[] = ([and_op:sub_op] => [er_data_op:er_op_op]);

      }

   endgroup

   covergroup zeros_or_ones_on_ops;

      option.name = "cg_zeros_or_ones_on_ops";

      all_ops : coverpoint OP_cov {
         bins opss = {[and_op : er_op_op]};
      }

      a_leg: coverpoint A_cov {
         bins zeros = {'h0000_0000};
         bins others= {['h0000_0001:'hFFFF_FFFE]};
         bins ones  = {'hFFFF_FFFF};
      }
      
      b_leg: coverpoint B_cov {
         bins zeros = {'h0000_0000};
         bins others= {['h0000_0001:'hFFFF_FFFE]};
         bins ones  = {'hFFFF_FFFF};
      }

      B_op_00_FF:  cross a_leg, b_leg, all_ops {

         // #B1 simulate all zero input for all the operations

         bins B1_and_00 = binsof (all_ops) intersect {and_op} &&
                       (binsof (a_leg.zeros) || binsof (b_leg.zeros));

         bins B1_or_00 = binsof (all_ops) intersect {or_op} &&
                       (binsof (a_leg.zeros) || binsof (b_leg.zeros));

         bins B1_add_00 = binsof (all_ops) intersect {add_op} &&
                       (binsof (a_leg.zeros) || binsof (b_leg.zeros));

         bins B1_sub_00 = binsof (all_ops) intersect {sub_op} &&
                       (binsof (a_leg.zeros) || binsof (b_leg.zeros));
	      
	      bins B1_err_data_00 = binsof (all_ops) intersect {er_data_op} &&
                       (binsof (a_leg.zeros) || binsof (b_leg.zeros));
	      
	      bins B1_err_crc_00 = binsof (all_ops) intersect {er_crc_op} &&
                       (binsof (a_leg.zeros) || binsof (b_leg.zeros));
	      
	    	bins B1_err_op_00 = binsof (all_ops) intersect {er_op_op} &&
                       (binsof (a_leg.zeros) || binsof (b_leg.zeros));

         // #B2 simulate all one input for all the operations

         bins B2_and_FF = binsof (all_ops) intersect {and_op} &&
                       (binsof (a_leg.ones) || binsof (b_leg.ones));

         bins B2_or_FF = binsof (all_ops) intersect {or_op} &&
                       (binsof (a_leg.ones) || binsof (b_leg.ones));

         bins B2_add_FF = binsof (all_ops) intersect {add_op} &&
                       (binsof (a_leg.ones) || binsof (b_leg.ones));

         bins B2_sub_FF = binsof (all_ops) intersect {sub_op} &&
                       (binsof (a_leg.ones) || binsof (b_leg.ones));
	      
         bins B2_err_data_FF = binsof (all_ops) intersect {er_data_op} &&
                       (binsof (a_leg.ones) || binsof (b_leg.ones));
	      
         bins B2_err_crc_FF = binsof (all_ops) intersect {er_crc_op} &&
                       (binsof (a_leg.ones) || binsof (b_leg.ones));
	      
         bins B2_err_op_FF = binsof (all_ops) intersect {er_op_op} &&
                       (binsof (a_leg.ones) || binsof (b_leg.ones));


         ignore_bins others_only =
                                  binsof(a_leg.others) && binsof(b_leg.others);

      }

   endgroup

   op_cov oc;
   zeros_or_ones_on_ops c_00_FF;

   initial begin : coverage
   
      oc = new();
      c_00_FF = new();
   
      forever begin : sample_cov
         @(negedge clk);
         oc.sample();
         c_00_FF.sample();
      end
   end : coverage


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
// Tester
//------------------------------------------------------------------------------
//---------------------------------
// Random data generation functions

	function operation_t get_op();
		bit [2:0] op_choice;
      op_choice = $random;
		case (op_choice)
     		3'b000 : return and_op;
        	3'b001 : return or_op;
        	3'b100 : return add_op;
        	3'b101 : return sub_op;
			3'b010 : return er_data_op;
			3'b011 : return er_crc_op;
			3'b110 : return er_op_op;
      endcase // case (op_choice)
   endfunction : get_op

//---------------------------------
   function byte get_data();
      bit [1:0] zero_ones;
      zero_ones = $random;
      if (zero_ones == 2'b00)
        return 32'h0000_0000;
      else if (zero_ones == 2'b11)
        return 32'hFFFF_FFFF;
      else
        return $random;
   endfunction : get_data

//------------------------
// Tester main

	bit [3:0] crc_error;
   bit err_data_rand = 1'b0;   
   
   initial begin : tester
	   sin = 1'b1;
      rst_n = 1'b0;
      @(negedge clk);
      @(negedge clk);
      rst_n = 1'b1;
      @(negedge clk);
      @(negedge clk);	   
      rst_n = 1'b0;
      @(negedge clk);
      @(negedge clk);
      rst_n = 1'b1;
      repeat (1000) begin : tester_main
         @(negedge clk);
         op_set = get_op();
         A = get_data();
         B = get_data();
         @(negedge clk);
         case (op_set) // handle the start signal        	
         	er_data_op: begin : case_er_data_op 
	         	if(err_data_rand) begin
			     		send_byte(CMD_TYPE, {1'b0, add_op, crc4_generate({B,A,1'b1,add_op},4'h0)});
        				send_byte(DATA_TYPE, B[23:16]);
        				send_byte(DATA_TYPE, B[15:8]);
        				send_byte(DATA_TYPE, B[7:0]);
        
        				send_byte(DATA_TYPE, A[31:24]);
        				send_byte(DATA_TYPE, A[23:16]);
        				send_byte(DATA_TYPE, A[15:8]);
			         send_byte(DATA_TYPE, A[7:0]);
	         	
	         		send_byte(CMD_TYPE, {1'b0, add_op, crc4_generate({B,A,1'b1,add_op},4'h0)});
	         		send_byte(1'b1,{8'b11111111});
			         	
			         err_data_rand = 1'b0;
		        	end
	         	else begin	
			     		send_byte(DATA_TYPE, B[31:24]);
        				send_byte(DATA_TYPE, B[23:16]);
        				send_byte(DATA_TYPE, B[15:8]);
        				send_byte(DATA_TYPE, B[7:0]);
        
     					send_byte(DATA_TYPE, A[31:24]);
        				send_byte(DATA_TYPE, A[23:16]);
        				send_byte(DATA_TYPE, A[15:8]);
	         	
	         		send_byte(CMD_TYPE, {1'b0, add_op, crc4_generate({B,A,1'b1,add_op},4'h0)});
	         		send_byte(1'b1,{8'b11111111});
			         	
			         err_data_rand = 1'b1;
		         end
	         end         	
         	er_crc_op: begin : case_er_crc_op
	         	crc_error = (crc4_generate({B,A,1'b1,op},4'h0) + 1'b1);
        			send_calculation_data(B, A, add_op, crc_error);
         	end
         	er_op_op: begin : case_er_op_op
	         	send_calculation_data(B, A, op_set, crc4_generate({B,A,1'b1,op},4'h0));
         	end
           default: begin
	           send_calculation_data(B, A, op_set, crc4_generate({B,A,1'b1,op},4'h0));
           end
         endcase // case (op_set)
         // print coverage after each loop
         // can also be used to stop the simulation when cov=100%
         // $strobe("%0t %0g",$time, $get_coverage());
         //#100;
      end
      $finish;
   end : tester

//------------------------------------------------------------------------------
// Scoreboard
//------------------------------------------------------------------------------

   bit [31:0] A_scor;
   bit [31:0] B_scor;
   bit [31:0] cap_C;
   bit [7:0] cap_CTL_sout;
   bit [7:0] pred_CTL;
   operation_t OP_scor;
   
	shortint predicted_result;
   bit [31:0] pred_C;
   bit [2:0] pred_CRC;
   
   bit [3:0] pred_flags; // {Carry, Overflow, Zero, Negative}
   
   bit done = 1'b0;
   
    

   always @(negedge sin) begin
		sin_to_queue(q_sin_A_scor,q_sin_B_scor,q_sin_CTL_scor);
	   decode_sin(q_sin_A_scor,q_sin_B_scor,q_sin_CTL_scor, A_scor, B_scor, OP_scor);
   end
   
   always @(negedge sout) begin
		capture_sout(cap_C, cap_CTL_sout);
	   done = 1'b1;
   end

   always @(posedge done) begin : scoreboard	   
  
      case (OP_scor)
        and_op: pred_C = A_scor & B_scor;
        or_op: pred_C = A_scor | B_scor;
        add_op: pred_C = A_scor + B_scor;
        sub_op: pred_C = B_scor - A_scor;
	    default: pred_C = 0;
      endcase // case (op_set)  

      case(OP_scor)
	      er_crc_op: pred_CTL = ERR_CRC_FRAME;
	      er_op_op: pred_CTL = ERR_OP_FRAME;
	      er_data_op: pred_CTL = ERR_DATA_FRAME;
	      default: begin
		      pred_flags[0] = pred_C[31];
		      pred_flags[1] = (pred_C == 0);
		      pred_flags[2] = (((OP_scor == add_op) && !(A_scor[31]^B_scor[31]) && (A_scor[31]^pred_C[31])) || ((OP_scor == sub_op) && !(A_scor[31]^pred_C[31]) && (B_scor[31]^pred_C[31])));
		      pred_flags[3] = (((OP_scor == add_op) && ((pred_C < A_scor) || (pred_C < B_scor))) || ((OP_scor == sub_op) && (B_scor < pred_C)));;
		      pred_CRC = crc3_generate({pred_C,1'b0,pred_flags}, 3'b000);
		      pred_CTL = {1'b0,pred_flags,pred_CRC};
	      end
      endcase      
      
		if((pred_C == cap_C) && (pred_CTL == cap_CTL_sout))
			$display ("PASSED: A: %0h  B: %0h  op: %s result: %0h",
                  A, B, OP_scor.name(), cap_C);
	   else
		  	$error ("FAILED: A: %0h  B: %0h  op: %s result: %0h",
                  A, B, OP_scor.name(), cap_C);
 		done = 1'b0;
   end : scoreboard
   
endmodule : top
