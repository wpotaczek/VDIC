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
	bit t_sin = 1;
	bit t_sout;
	bit done = 1'b0;
	
	reg [10:0] captured_C1 = 0;
   reg [10:0] captured_C2 = 0;
   reg [10:0] captured_C3 = 0;
   reg [10:0] captured_C4 = 0;
	reg [10:0] captured_B1 = 0;
   reg [10:0] captured_B2 = 0;
   reg [10:0] captured_B3 = 0;
   reg [10:0] captured_B4 = 0;
	reg [10:0] captured_A1 = 0;
   reg [10:0] captured_A2 = 0;
   reg [10:0] captured_A3 = 0;
   reg [10:0] captured_A4 = 0;
   reg [10:0] captured_CTL = 0;
   reg [10:0] captured_ERROR = 0;
	
	bit [3:0] op_flags = 0;
	bit [3:0] crc4_err = 0;
	
	bit [7:0] q_sin[$];
	bit [7:0] q_alu_score[$];
	bit [3:0] test = 4'b0000;
	bit [3:0] CRC_test = 0;
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
	
	task wait_for_sof;
	begin
		while(sout == 1)
			@(posedge clk);
	end
	endtask
	
	task wait_for_sin_sof;
	begin
		while(sin == 1)
			@(posedge clk);
	end
	endtask
	
	task capture_c (output bit [31:0] cap_C, output bit [7:0] cap_CTL, output bit done);

	begin
		//wait_for_sof;
		repeat (12)
		begin
			captured_C1 <= {captured_C1[9:0], sout};
			@(negedge clk);
		end
		//@(posedge clk);
		repeat (11)
		begin
			captured_C2 <= {captured_C2[9:0], sout};
			@(negedge clk);
		end
		//@(posedge clk);
		repeat (11)
		begin
			captured_C3 <= {captured_C3[9:0], sout};
			@(negedge clk);
		end
		//@(posedge clk);
		repeat (11)
		begin
			captured_C4 <= {captured_C4[9:0], sout};
			@(negedge clk);
		end
		//@(posedge clk);
		repeat (11)
		begin
			captured_CTL <= {captured_CTL[9:0], sout};
			@(negedge clk);
		end		
		cap_C = {captured_C1[8:1], captured_C2[8:1], captured_C3[8:1], captured_C4[8:1]};
		cap_CTL = captured_CTL[8:1]; 
		done = 1'b1;
	end
	endtask
	
	task sin_to_queue (output bit [31:0] cap_A, output bit [31:0] cap_B, output bit [7:0] cap_CTL, ref [7:0] queue[$]);
		
	begin
		//wait_for_sin_sof;
		repeat (12)
		begin
			captured_B1 <= {captured_B1[9:0], sin};
			@(posedge clk);
		end
		//@(negedge clk);
		repeat (11)
		begin
			captured_B2 <= {captured_B2[9:0], sin};
			@(posedge clk);
		end
		//@(negedge clk);
		repeat (11)
		begin
			captured_B3 <= {captured_B3[9:0], sin};
			@(posedge clk);
		end
		//@(negedge clk);
		repeat (11)
		begin
			captured_B4 <= {captured_B4[9:0], sin};
			@(posedge clk);
		end
		//@(negedge clk);
		repeat (11)
		begin
			captured_A1 <= {captured_A1[9:0], sin};
			@(posedge clk);
		end
		//@(negedge clk);
		repeat (11)
		begin
			captured_A2 <= {captured_A2[9:0], sin};
			@(posedge clk);
		end
		//@(negedge clk);
		repeat (11)
		begin
			captured_A3 <= {captured_A3[9:0], sin};
			@(posedge clk);
		end
		//@(negedge clk);
		repeat (11)
		begin
			captured_A4 <= {captured_A4[9:0], sin};
			@(posedge clk);
		end
		//@(negedge clk);
		repeat (11)
		begin
			captured_CTL <= {captured_CTL[9:0], sin};
			@(posedge clk);
		end
		cap_B = {captured_B1[8:1], captured_B2[8:1], captured_B3[8:1], captured_B4[8:1]};
		cap_A = {captured_A1[8:1], captured_A2[8:1], captured_A3[8:1], captured_A4[8:1]};
		cap_CTL = captured_CTL[8:1];
	end
	endtask
	
	task capture_error;
	begin
		wait_for_sof;
		repeat (11)
		begin
			captured_ERROR <= {captured_ERROR[9:0], t_sout};
			@(posedge clk);
		end
	end
	endtask
		
	task compare_c_results(input [31:0] expected_C, input [7:0] expected_CTL);
		if({captured_C1[8:1], captured_C2[8:1], captured_C3[8:1], captured_C4[8:1], captured_CTL[8:1]} != {expected_C, expected_CTL})
		begin
			$display("Test is failed");
		end else 
		begin
			$display("Test is correct");
		end
	endtask
	
	task compare_error_results(input [7:0] expected_ERROR);
		if(captured_ERROR[8:1] != expected_ERROR)
		begin
			$display("Test is failed");
		end else 
		begin
			$display("Test is correct");
		end
	endtask
	/*
	function [3:0] crc4_generate;
	input [31:0] B;
	input [31:0] A;
	input [2:0] OP;
	reg [71:0] crc_data;
	reg [3:0] reminder;
	   begin
	       crc_data = {B, A, {1'b0, OP, 4'b0000}};
	       reminder = 0;
	       repeat(72)
	       begin
	           reminder = {reminder[2], reminder[1], reminder[3]^reminder[0], reminder[3]^crc_data[71]};
	           crc_data = {crc_data[70:0], 1'b0};
	       end
	       crc4_generate = reminder;
	   end
	endfunction
	*/
	
	//CRC for 68 bits 
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
    input [31:0] C;
    input [3:0] FLAGS;
	reg [39:0] crc_data;
    reg [2:0] reminder;
       begin
           crc_data = {C, {1'b0, FLAGS, 3'b000}};
           reminder = 0;
           repeat(40)
           begin
               reminder = {reminder[1], reminder[2]^reminder[0], reminder[2]^crc_data[39]};
               crc_data = {crc_data[38:0], 1'b0};
           end
           crc3_generate = reminder;
       end
    endfunction
	
	function [31:0] calculate_op;
	input [31:0] B;
	input [31:0] A;
    input [2:0] op;
    reg [31:0] C;
    reg cout;
        begin
            case(op)
                3'b000: {cout, C} = {1'b0, B} & {1'b0, A};
                3'b001: {cout, C} = {1'b0, B} | {1'b0, A};
                3'b100: {cout, C} = {1'b0, B} + {1'b0, A};
                3'b101: {cout, C} = {1'b0, B} - {1'b0, A};
                //default: {cout, C} = {1'b0, C};
            endcase
            calculate_op = C;
            op_flags[3] = cout;
            op_flags[2] = (B[31]&&A[31]&&(!C[31]))||((!B[31])&&(!A[31])&&(C[31]));
            op_flags[1] = (C==0);
            op_flags[0] = C[31];
	   end
	endfunction
    
    function parity;
    input [5:0] data;
    reg result;
        begin
        result = 1'b1^data[5]^data[4]^data[3]^data[2]^data[1]^data[0];
        parity = result;
        end
    endfunction

//------------------------------------------------------------------------------
// DUT instantiation
//------------------------------------------------------------------------------

	mtm_Alu DUT (.clk, .rst_n, .sin, .sout);


//------------------------------------------------------------------------------
// Coverage block
//------------------------------------------------------------------------------



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
			3'b011 : return and_op;//er_data_op;
			3'b110 : return or_op;//er_crc_op;
			3'b111 : return add_op;//er_op_op; 
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
	   //sin = 1'b1;
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
         	/*
         	er_data_op: begin : case_er_data_op        	
	         	send_byte(DATA_TYPE, B[31:24]);
        			send_byte(DATA_TYPE, B[23:16]);
        			send_byte(DATA_TYPE, B[15:8]);
        			send_byte(DATA_TYPE, B[7:0]);
        
        			send_byte(DATA_TYPE, A[31:24]);
        			send_byte(DATA_TYPE, A[23:16]);
        			send_byte(DATA_TYPE, A[15:8]);
        			send_byte(DATA_TYPE, A[7:0]);
	         	
	         	send_byte(DATA_TYPE, {1'b0, add_op, crc4_generate(B, A, add_op)});
         	end
         	er_crc_op: begin : case_er_crc_op
	         	crc4_err = crc4_generate(B, A, op_set) + 1;
        			send_calculation_data(B, A, add_op, crc4_err);
         	end
         	er_op_op: begin : case_er_op_op
	         	op_set = 3'b010;
	         	send_calculation_data(B, A, add_op, crc4_generate(B,A,add_op));
         	end
         	*/
           default: begin	           
	           CRC_test = crc4_generate({B,A,1'b1,op},4'h0);
	           //CRC_test = crc4_generate(B, A, 3'b000);
	           send_calculation_data(B, A, op_set, CRC_test);
           end
         endcase // case (op_set)
         // print coverage after each loop
         // can also be used to stop the simulation when cov=100%
         // $strobe("%0t %0g",$time, $get_coverage());
         #1000;
      end
      $finish;
   end : tester

//------------------------------------------------------------------------------
// Scoreboard
//------------------------------------------------------------------------------

   bit [31:0] cap_A;
   bit [31:0] cap_B;
   bit [31:0] cap_C;
   bit [7:0] cap_CTL_1;
   bit [7:0] cap_CTL_2;
   bit [10:0] sin_temp;
   
   bit [3:0] pred_CRC4;
	shortint predicted_result;
   
   bit [3:0] pred_flags; // {Carry, Overflow, Zero, Negative}
   
   /*
   wait_for_sin_sof;   
   
   jeśli sin 1 -> 0
   	do zmiennej zapisz
   	jeśli potem sin = 0
   		data <= {data[9:0],sin};
   		do zmiennej data zapisz
   	jeśli sin = 1
   		ctl <= {data[9:0],sin};
   		do zmiennej ctl zapisz
	   		
	   przypisanie do kolejki
		   if(dat_a)
			   q_sin_A.push_front(data_A[8:1]);
		   	q_sin_B.push_front(data_B[8:1]);
		   	q_sin_CTL.push_front(data_CTL[8:1]);
		 */  
      

   always @(negedge sin) begin
	sin_to_queue(cap_A,cap_B,cap_CTL_1);
   end
   
   always @(negedge sout) begin
		capture_c(cap_C, cap_CTL_2, done);
   end

   always @(posedge done) begin : scoreboard
	   /*
	   cap_B[31:24] = q_test_score.pop_back();
	   cap_B[23:16] = q_test_score.pop_back();
	   cap_B[15:8] = q_test_score.pop_back();
	   cap_B[7:0] = q_test_score.pop_back();
	  	cap_A[31:24] = q_test_score.pop_back();
	   cap_A[23:16] = q_test_score.pop_back();
	   cap_A[15:8] = q_test_score.pop_back();
	   cap_A[7:0] = q_test_score.pop_back();
	   
	   cap_CTL = q_test_score.pop_back();
	   */
	   //pred_CRC4 = crc4_generate(cap_B, cap_A, cap_CTL[6:4]);
      
      #1;
      case (op_set)
        and_op: predicted_result = A & B;
        or_op: predicted_result = A | B;
        add_op: predicted_result = A + B;
        sub_op: predicted_result = A - B;
	    default: predicted_result = 0;
      endcase // case (op_set)
/*
      case(cap_set)
	      
	      default: begin
		      pred_flags[0] = ;
		      pred_flags[1] = ;
		      pred_flags[2] = ;
		      pred_flags[3] = ;
	      end
      endcase
      
      if (predicted_result != cap_C)
          $error ("FAILED: A: %0h  B: %0h  op: %s result: %0h",
                  A, B, op_set.name(), cap_C);
      */            
      done = 1'b0;
   end : scoreboard
   
endmodule : top
