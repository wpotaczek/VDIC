module alu_tester_module(alu_bfm bfm);
   import alu_pkg::*;

	function operation_t get_op();
		bit [2:0] op_choice;
		op_choice = $random;
		case(op_choice)
			3'b000 : return and_op;
			3'b001 : return or_op;
			3'b100 : return add_op;
			3'b101 : return sub_op;
			3'b010 : return er_data_op;
			3'b011 : return er_crc_op;
			3'b110 : return er_op_op;
		endcase
	endfunction : get_op

	function byte get_data();
		bit [1:0] zero_ones;
		zero_ones = $random;
		if(zero_ones == 2'b00)
			return 32'h0000_0000;
		else if(zero_ones == 2'b11)
			return 32'hFFFF_FFFF;
		else
			return $random;
	endfunction : get_data
   
   initial begin
   	bit [31:0] A;
		bit [31:0] B;
		operation_t op_set;
      
      bfm.reset_alu();
	      repeat (100) begin : random_loop
				op_set = get_op();
			A = get_data();
			B = get_data();
			bfm.send_op(A, B, op_set);
		   #500;
      end : random_loop
   end // initial begin
   
endmodule : alu_tester_module






