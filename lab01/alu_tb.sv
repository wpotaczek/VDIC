`timescale 1ns/1ps

module top;

//------------------------------------------------------------------------------
// type and variable definitions
//------------------------------------------------------------------------------

typedef enum bit[2:0] {and_op			= 3'b000,
							  or_op 			= 3'b001,
                       add_op 		= 3'b100,
                       sub_op 		= 3'b101,
                       no_op 			= 3'b010,
                       er_data_op	= 3'b011,
                       er_crc_op 	= 3'b110,
                       er_op_op 		= 3'b111} operation_t;
	
	
	
	localparam 	DATA_TYPE = 1'b0,
					CMD_TYPE = 1'b1;
	
	logic		clk;
	logic		rst_n;
	bit		sin;
	bit		sout;
   	
	
	bit [31:0]    A;
	bit [31:0]    B;
	bit [31:0]    C;
	
	reg [10:0] captured_sin1 = 0;
   reg [10:0] captured_sin2 = 0;
   reg [10:0] captured_sin3 = 0;
   reg [10:0] captured_sin4 = 0;
	reg [10:0] captured_sin5 = 0;
	reg [10:0] captured_sin6 = 0;
	reg [10:0] captured_sin7 = 0;
	reg [10:0] captured_sin8 = 0;
	reg [10:0] captured_sin9 = 0;
	reg [10:0] captured_sout1 = 0;
   reg [10:0] captured_sout2 = 0;
   reg [10:0] captured_sout3 = 0;
   reg [10:0] captured_sout4 = 0;
   reg [10:0] captured_sout5 = 0;
		
	logic [7:0] q_sin_A_scor[$];
	logic [7:0] q_sin_B_scor[$];
	logic [7:0] q_sin_CTL_scor[$];	
	
	bit [3:0] CRC_test;
	bit [3:0] crc_error;
	
	bit done = 1'b0;
	
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
	
	task capture_c (output bit [31:0] cap_C, output bit [7:0] cap_CTL, output bit done);
	begin
			repeat (12)
			begin
				captured_sout1 <= {captured_sout1[9:0], sout};
				@(negedge clk);
			end
			if(captured_sout1[9] == 1'b0) begin
			repeat (11)
			begin
				captured_sout2 <= {captured_sout2[9:0], sout};
				@(negedge clk);
			end
			repeat (11)
			begin
				captured_sout3 <= {captured_sout3[9:0], sout};
				@(negedge clk);
			end
			repeat (11)
			begin
				captured_sout4 <= {captured_sout4[9:0], sout};
				@(negedge clk);
			end	
			repeat (11)
			begin
				captured_sout5 <= {captured_sout5[9:0], sout};
				@(negedge clk);
			end		
			cap_C = {captured_sout1[8:1], captured_sout2[8:1], captured_sout3[8:1], captured_sout4[8:1]};
			cap_CTL = captured_sout5[8:1]; 
			end
			else begin
				cap_C = 1'b0;
				cap_CTL = captured_sout1[8:1];
			end				
			//done = 1'b1;
		end
	endtask
	
	task automatic sin_to_queue(ref [7:0] q_sin_A_scor[$], ref [7:0] q_sin_B_scor[$], ref [7:0] q_sin_CTL_scor[$]);		
	begin
		repeat (12)
		begin
			captured_sin1 <= {captured_sin1[9:0], sin};
			@(posedge clk);
		end
		repeat (11)
		begin
			captured_sin2 <= {captured_sin2[9:0], sin};
			@(posedge clk);
		end
		repeat (11)
		begin
			captured_sin3 <= {captured_sin3[9:0], sin};
			@(posedge clk);
		end
		repeat (11)
		begin
			captured_sin4 <= {captured_sin4[9:0], sin};
			@(posedge clk);
		end		
		if((captured_sin1[9] == 1'b1) | (captured_sin2[9] == 1'b1) | (captured_sin3[9] == 1'b1) |(captured_sin4[9] == 1'b1)) begin
			q_sin_B_scor.push_front(captured_sin1[8:1]);
			q_sin_B_scor.push_front(captured_sin2[8:1]);
			q_sin_B_scor.push_front(captured_sin3[8:1]);
			q_sin_CTL_scor.push_front(captured_sin4[8:1]);
		end
		else begin
			q_sin_B_scor.push_front(captured_sin1[8:1]);
			q_sin_B_scor.push_front(captured_sin2[8:1]);
			q_sin_B_scor.push_front(captured_sin3[8:1]);
			q_sin_B_scor.push_front(captured_sin4[8:1]);
		end
		//q_sin_B_scor.push_front({captured_sin1[8:1], captured_sin2[8:1], captured_sin3[8:1], captured_sin4[8:1]});
		repeat (11)
		begin
			captured_sin5 <= {captured_sin5[9:0], sin};
			@(posedge clk);
		end
		repeat (11)
		begin
			captured_sin6 <= {captured_sin6[9:0], sin};
			@(posedge clk);
		end
		repeat (11)
		begin
			captured_sin7 <= {captured_sin7[9:0], sin};
			@(posedge clk);
		end
		repeat (11)
		begin
			captured_sin8 <= {captured_sin8[9:0], sin};
			@(posedge clk);
		end
		if((captured_sin5[9] == 1'b1) | (captured_sin6[9] == 1'b1) | (captured_sin7[9] == 1'b1) |(captured_sin8[9] == 1'b1)) begin
			q_sin_A_scor.push_front(captured_sin5[8:1]);
			q_sin_A_scor.push_front(captured_sin6[8:1]);
			q_sin_A_scor.push_front(captured_sin7[8:1]);
			q_sin_CTL_scor.push_front(captured_sin8[8:1]);
		end
		else begin
			q_sin_A_scor.push_front(captured_sin5[8:1]);
			q_sin_A_scor.push_front(captured_sin6[8:1]);
			q_sin_A_scor.push_front(captured_sin7[8:1]);
			q_sin_A_scor.push_front(captured_sin8[8:1]);
		end			
		//q_sin_A_scor.push_front(captured_sin1[8:1]);
		//q_sin_A_scor.push_front(captured_sin2[8:1]);
		//q_sin_A_scor.push_front(captured_sin3[8:1]);
		//q_sin_A_scor.push_front(captured_sin4[8:1]);
		//q_sin_A_scor.push_front({captured_sin1[8:1], captured_sin2[8:1], captured_sin3[8:1], captured_sin4[8:1]});
		repeat (11)
		begin
			captured_sin9 <= {captured_sin9[9:0], sin};
			@(posedge clk);
		end
		q_sin_CTL_scor.push_front(captured_sin9[8:1]);
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
/*
   covergroup op_cov;

      option.name = "cg_op_cov";

      coverpoint op_set {
         // #A1 test all operations
         bins A1_single_cycle[] = {[add_op : xor_op], rst_op,no_op};
         bins A1_multi_cycle = {mul_op};

         // #A2 test all operations after reset
         bins A2_rst_opn[] = (rst_op => [add_op:mul_op]);

         // #A3 test reset after all operations
         bins A3_opn_rst[] = ([add_op:mul_op] => rst_op);

         // #A4 multiply after single-cycle operation
         bins A4_sngl_mul[] = ([add_op:xor_op],no_op => mul_op);

         // #A5 single-cycle operation after multiply
         bins A5_mul_sngl[] = (mul_op => [add_op:xor_op], no_op);

         // #A6 two operations in row
         bins A6_twoops[] = ([add_op:mul_op] [* 2]);

         // bins manymult = (mul_op [* 3:5]);
      }

   endgroup

   covergroup zeros_or_ones_on_ops;

      option.name = "cg_zeros_or_ones_on_ops";

      all_ops : coverpoint op_set {
         ignore_bins null_ops = {rst_op, no_op};
      }

      a_leg: coverpoint A {
         bins zeros = {'h00};
         bins others= {['h01:'hFE]};
         bins ones  = {'hFF};
      }

      b_leg: coverpoint B {
         bins zeros = {'h00};
         bins others= {['h01:'hFE]};
         bins ones  = {'hFF};
      }

      B_op_00_FF:  cross a_leg, b_leg, all_ops {

         // #B1 simulate all zero input for all the operations

         bins B1_add_00 = binsof (all_ops) intersect {add_op} &&
                       (binsof (a_leg.zeros) || binsof (b_leg.zeros));

         bins B1_and_00 = binsof (all_ops) intersect {and_op} &&
                       (binsof (a_leg.zeros) || binsof (b_leg.zeros));

         bins B1_xor_00 = binsof (all_ops) intersect {xor_op} &&
                       (binsof (a_leg.zeros) || binsof (b_leg.zeros));

         bins B1_mul_00 = binsof (all_ops) intersect {mul_op} &&
                       (binsof (a_leg.zeros) || binsof (b_leg.zeros));

         // #B2 simulate all one input for all the operations

         bins B2_add_FF = binsof (all_ops) intersect {add_op} &&
                       (binsof (a_leg.ones) || binsof (b_leg.ones));

         bins B2_and_FF = binsof (all_ops) intersect {and_op} &&
                       (binsof (a_leg.ones) || binsof (b_leg.ones));

         bins B2_xor_FF = binsof (all_ops) intersect {xor_op} &&
                       (binsof (a_leg.ones) || binsof (b_leg.ones));

         bins B2_mul_FF = binsof (all_ops) intersect {mul_op} &&
                       (binsof (a_leg.ones) || binsof (b_leg.ones));

         bins B2_mul_max = binsof (all_ops) intersect {mul_op} &&
                        (binsof (a_leg.ones) && binsof (b_leg.ones));

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
*/

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
	     	3'b010 : return no_op;
			3'b011 : return er_data_op;
			3'b110 : return er_crc_op;
			3'b111 : return er_op_op;
      endcase // case (op_choice)
   endfunction : get_op

//---------------------------------
   function byte get_data();
      bit [7:0] zero_ones;
      zero_ones = $random;
      if (zero_ones == 8'h00)
        return 32'h0000_0000;
      else if (zero_ones == 8'hFF)
        return 32'hFFFF_FFFF;
      else
        return $random;
   endfunction : get_data

//------------------------
// Tester main
   
   initial begin : tester
	   sin = 1'b1;
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
         	no_op: begin: case_no_op
              @(posedge clk);  	
         	end         	
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
	         	crc_error = (crc4_generate({B,A,1'b1,op},4'h0) + 1'b1);
        			send_calculation_data(B, A, add_op, crc_error);
         	end
         	er_op_op: begin : case_er_op_op
	         	send_calculation_data(B, A, op_set, crc4_generate({B,A,1'b1,op},4'h0));
         	end
           default: begin	           
	           CRC_test = crc4_generate({B,A,1'b1,op},4'h0);
	           send_calculation_data(B, A, op_set, CRC_test);
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

   bit [31:0] cap_A;
   bit [31:0] cap_B;
   bit [31:0] cap_C;
   bit [7:0] cap_CTL_sin;
   bit [7:0] cap_CTL_sout;
   bit [7:0] pred_CTL;
   bit [10:0] sin_temp;
   operation_t cap_OP;
   
	shortint predicted_result;
   bit [31:0] pred_C;
   bit [2:0] pred_CRC;
   
   bit [3:0] pred_flags; // {Carry, Overflow, Zero, Negative}
   
    

   always @(negedge sin) begin
		sin_to_queue(q_sin_A_scor,q_sin_B_scor,q_sin_CTL_scor);
   end
   
   always @(negedge sout) begin
		capture_c(cap_C, cap_CTL_sout, done);
	   done = 1'b1;
   end

   always @(posedge done) begin : scoreboard
	   
	   if((q_sin_A_scor.size() < 4) | (q_sin_B_scor.size() < 4) | (q_sin_CTL_scor.size() < 1)) begin
			cap_OP = er_data_op;
		   q_sin_A_scor.delete();
		   q_sin_B_scor.delete();
		   q_sin_CTL_scor.delete();
	   end
	   
	   else begin
	   	cap_A[31:24] = q_sin_A_scor.pop_back();
	   	cap_A[23:16] = q_sin_A_scor.pop_back();
	   	cap_A[15:8] = q_sin_A_scor.pop_back();
	   	cap_A[7:0] = q_sin_A_scor.pop_back();
	   
	  		cap_B[31:24] = q_sin_B_scor.pop_back();
	   	cap_B[23:16] = q_sin_B_scor.pop_back();
	   	cap_B[15:8] = q_sin_B_scor.pop_back();
	   	cap_B[7:0] = q_sin_B_scor.pop_back();
	   	//cap_A = q_sin_A_scor.pop_back();
	   	//cap_B = q_sin_B_scor.pop_back();
	   	cap_CTL_sin = q_sin_CTL_scor.pop_back();
		   cap_OP = cap_CTL_sin[6:4];	
	   	   
	   	if(cap_CTL_sin[5] == 1'b1)
		   	cap_OP = er_op_op;
	   
	   	else if(cap_CTL_sin[3:0] != crc4_generate({cap_B,cap_A,1'b1,cap_OP},4'h0))
	   		cap_OP = er_crc_op;
	   end
	   
      case (cap_OP)
        and_op: pred_C = cap_A & cap_B;
        or_op: pred_C = cap_A | cap_B;
        add_op: pred_C = cap_A + cap_B;
        sub_op: pred_C = cap_B - cap_A;
	    default: pred_C = 0;
      endcase // case (op_set)  

      case(cap_OP)
	      er_crc_op: pred_CTL = 8'b10100101;
	      er_op_op: pred_CTL = 8'b10010011;
	      er_data_op: pred_CTL = 8'b11001001;
	      default: begin
		      pred_flags[0] = pred_C[31];
		      pred_flags[1] = (pred_C == 0);
		      pred_flags[2] = (((cap_OP == add_op) && !(cap_A[31]^cap_B[31]) && (cap_A[31]^pred_C[31])) || ((cap_OP == sub_op) && !(cap_A[31]^pred_C[31]) && (cap_B[31]^pred_C[31])));
		      pred_flags[3] = (((cap_OP == add_op) && ((pred_C < cap_A) || (pred_C < cap_B))) || ((cap_OP == sub_op) && (cap_B < pred_C)));;
		      pred_CRC = crc3_generate({pred_C,1'b0,pred_flags}, 3'b000);
		      pred_CTL = {1'b0,pred_flags,pred_CRC};
	      end
      endcase
      
      
      if(op_set != no_op) begin
	   	if((pred_C == cap_C) && (pred_CTL == cap_CTL_sout))
		   	$display ("PASSED!!!");
	   	else
		   	$error ("FAILED: A: %0h  B: %0h  op: %s result: %0h",
                  A, B, op_set.name(), cap_C);
      end   
      #5;
 	done = 1'b0;
   end : scoreboard
   
endmodule : top
