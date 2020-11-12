/******************************************************************************
* (C) Copyright 2013 <Company Name> All Rights Reserved
*
* MODULE:    name
* DEVICE:
* PROJECT:
* AUTHOR:    wpotaczek
* DATE:      2020 4:23:53 PM
*
* ABSTRACT:  You can customize the file content from Window -> Preferences -> DVT -> Code Templates -> "verilog File"
*
*******************************************************************************/

class tester;
	
	virtual alu_bfm bfm;
	
	function new(virtual alu_bfm b);
		bfm = b;
	endfunction : new
	 
   
	protected function operation_t get_op();
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
   protected function byte get_data();
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
   
   task execute();
		bit [31:0] A;
      bit [31:0] B;
      operation_t op_set;
	   bit [3:0] crc_test;
	   bit err_data_rand = 1'b0;
		bfm.sin = 1'b1;
	   
	   begin
			bfm.reset_alu();
      	repeat (1000) begin : tester_main
         	@(negedge bfm.clk);
         	op_set = get_op();
         	A = get_data();
         	B = get_data();
	      	bfm.send_op(A, B, op_set);         	
         	// print coverage after each loop
         	// can also be used to stop the simulation when cov=100%
         	// $strobe("%0t %0g",$time, $get_coverage());
         	//#100;
      	end
      	$finish;
	   end
   endtask      
endclass : tester