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
   reg [10:0] captured_CTL = 0;
   reg [10:0] captured_ERROR = 0;
	
	bit [3:0] op_flags = 0;
	bit [3:0] crc4_err = 0;
	
	bit [7:0] q_test_score[$];
	bit [7:0] q_alu_score[$];
	   
	operation_t  op_set;

	assign op = op_set;


//------------------------------------------------------------------------------
// Custom Macros/Tasks/Functions
//------------------------------------------------------------------------------
	
	task send_byte(input frame_type, input [7:0] essence, inout [7:0] queue[$]);
	begin
		sin <= 1'b0;
		@(posedge clk)
		sin <= frame_type;
		@(posedge clk)
		sin = essence[7];
     	@(posedge clk)
      sin = essence[6];
      @(posedge clk)
      sin = essence[5];
      @(posedge clk)
      sin = essence[4];
      @(posedge clk)
      sin = essence[3];
      @(posedge clk)
      sin = essence[2];
      @(posedge clk)
      sin = essence[1];
      @(posedge clk)
      sin = essence[0];
      @(posedge clk)
		sin <= 1'b1;
		@(posedge clk);
		queue.push_front(essence[7:0]);
	end
	endtask

	task send_calculation_data (input [31:0] B, input [31:0] A, input [2:0] OP, input [3:0] CRC, inout [7:0] queue[$]);
	begin
		send_byte(DATA_TYPE, B[31:24], queue);
		send_byte(DATA_TYPE, B[23:16], queue);
		send_byte(DATA_TYPE, B[15:8], queue);
		send_byte(DATA_TYPE, B[7:0], queue);
		
		send_byte(DATA_TYPE, A[31:24], queue);
		send_byte(DATA_TYPE, A[23:16], queue);
		send_byte(DATA_TYPE, A[15:8], queue);
		send_byte(DATA_TYPE, A[7:0], queue);		
	
		send_byte(CMD_TYPE, {1'b0, OP, CRC}, queue);
		
	end	
	endtask
	
	task wait_for_sof;
	begin
		while(t_sout == 1)
			@(posedge clk);
	end
	endtask
	
	task capture_c (output bit [31:0] cap_C, output bit [7:0] cap_CTL, output bit done);
		
	begin
		wait_for_sof;
		repeat (11)
		begin
			captured_C1 <= {captured_C1[9:0], t_sout};
			@(posedge clk);
		end
		@(posedge clk);
		repeat (11)
		begin
			captured_C2 <= {captured_C2[9:0], t_sout};
			@(posedge clk);
		end
		@(posedge clk);
		repeat (11)
		begin
			captured_C3 <= {captured_C3[9:0], t_sout};
			@(posedge clk);
		end
		@(posedge clk);
		repeat (11)
		begin
			captured_C4 <= {captured_C4[9:0], t_sout};
			@(posedge clk);
		end
		@(posedge clk);
		repeat (11)
		begin
			captured_CTL <= {captured_CTL[9:0], t_sout};
			@(posedge clk);
		end		
		cap_C = {captured_C1[8:1], captured_C2[8:1], captured_C3[8:1], captured_C4[8:1]};
		cap_CTL = captured_CTL[8:1]; 
		done = 1'b1;
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
      rst_n = 1'b0;
      @(negedge clk);
      @(negedge clk);
      rst_n = 1'b1;
      repeat (1000) begin : tester_main
         @(negedge clk);
         op_set = get_op();
         A = get_data();
         B = get_data();
         case (op_set) // handle the start signal
         	no_op: begin: case_no_op
              @(posedge clk);  	
         	end 
         	
         	er_data_op: begin : case_er_data_op        	
	         	send_byte(DATA_TYPE, B[31:24], q_test_score);
        			send_byte(DATA_TYPE, B[23:16], q_test_score);
        			send_byte(DATA_TYPE, B[15:8], q_test_score);
        			send_byte(DATA_TYPE, B[7:0], q_test_score);
        
        			send_byte(DATA_TYPE, A[31:24], q_test_score);
        			send_byte(DATA_TYPE, A[23:16], q_test_score);
        			send_byte(DATA_TYPE, A[15:8], q_test_score);
        			send_byte(DATA_TYPE, A[7:0], q_test_score);
	         	
	         	send_byte(DATA_TYPE, {1'b0, add_op, crc4_generate(B, A, add_op)}, q_test_score);
         	end
         	er_crc_op: begin : case_er_crc_op
	         	crc4_err = crc4_generate(B, A, op_set) + 1;
        			send_calculation_data(B, A, add_op, crc4_err, q_test_score);
         	end
         	er_op_op: begin : case_er_op_op
	         	op_set = 3'b010;
	         	send_calculation_data(B, A, add_op, crc4_generate(B,A,add_op), q_test_score);
         	end
         	
           default: begin
	           send_calculation_data(B, A, op_set, crc4_generate(B,A,op_set), q_test_score);
           end
         endcase // case (op_set)
         // print coverage after each loop
         // can also be used to stop the simulation when cov=100%
         // $strobe("%0t %0g",$time, $get_coverage());
      end
      $finish;
   end : tester

//------------------------------------------------------------------------------
// Scoreboard
//------------------------------------------------------------------------------

   bit [31:0] cap_A;
   bit [31:0] cap_B;
   bit [31:0] cap_C;
   bit [7:0] cap_CTL;
   
   bit [3:0] pred_CRC4;
	shortint predicted_result;
   
   bit [3:0] pred_flags; // {Carry, Overflow, Zero, Negative}
   
   

   always @(posedge clk) begin
		capture_c(cap_C, cap_CTL, done);
   end

   always @(posedge done) begin : scoreboard
	   
	   cap_B[31:24] = q_test_score.pop_back();
	   cap_B[23:16] = q_test_score.pop_back();
	   cap_B[15:8] = q_test_score.pop_back();
	   cap_B[7:0] = q_test_score.pop_back();
	  	cap_A[31:24] = q_test_score.pop_back();
	   cap_A[23:16] = q_test_score.pop_back();
	   cap_A[15:8] = q_test_score.pop_back();
	   cap_A[7:0] = q_test_score.pop_back();
	   
	   cap_CTL = q_test_score.pop_back();
	   
	   pred_CRC4 = crc4_generate(cap_B, cap_A, cap_CTL[6:4]);
      
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
