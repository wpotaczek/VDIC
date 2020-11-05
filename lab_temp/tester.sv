module tester(alu_bfm bfm);
import alu_pkg::*;

	bit [3:0] crc_error;
   bit err_data_rand = 1'b0; 
   
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

  
   
   initial begin : tester
	  byte         unsigned        A;
      byte         unsigned        B;
      operation_t                  op_set;
	  sin = 1'b1;

		bfm.reset_alu();
      repeat (1000) begin : tester_main
         @(negedge clk);
         op_set = get_op();
         A = get_data();
         B = get_data();
         @(negedge clk);
			bfm.send_op(A,B,op_set);
         // print coverage after each loop
         // can also be used to stop the simulation when cov=100%
         // $strobe("%0t %0g",$time, $get_coverage());
         //#100;
      end
      $finish;
   end : tester
   
endmodule : tester