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

module tester(alu_bfm bfm);
import alu_pkg::*;
	
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
		bit [31:0] A;
      bit [31:0] B;
      operation_t op_set;
	   bit [3:0] crc_test;
		bfm.sin = 1'b1;

		bfm.reset_alu();
      repeat (1000) begin : tester_main
         @(negedge bfm.clk);
         op_set = get_op();
         A = get_data();
         B = get_data();
         @(negedge bfm.clk);
			case (op_set) // handle the start signal        	
         	er_data_op: begin : case_er_data_op 
	         	if(err_data_rand) begin
			     		bfm.send_byte(CMD_TYPE, {1'b0, add_op, bfm.crc4_generate({B,A,1'b1,add_op},4'h0)});
        				bfm.send_byte(DATA_TYPE, B[23:16]);
        				bfm.send_byte(DATA_TYPE, B[15:8]);
        				bfm.send_byte(DATA_TYPE, B[7:0]);
        
        				bfm.send_byte(DATA_TYPE, A[31:24]);
        				bfm.send_byte(DATA_TYPE, A[23:16]);
        				bfm.send_byte(DATA_TYPE, A[15:8]);
			         bfm.send_byte(DATA_TYPE, A[7:0]);
	         	
	         		bfm.send_byte(CMD_TYPE, {1'b0, add_op, bfm.crc4_generate({B,A,1'b1,add_op},4'h0)});
	         		bfm.send_byte(1'b1,{8'b11111111});
			         	
			         err_data_rand = 1'b0;
		        	end
	         	else begin
			     		bfm.send_byte(DATA_TYPE, B[31:24]);
        				bfm.send_byte(DATA_TYPE, B[23:16]);
        				bfm.send_byte(DATA_TYPE, B[15:8]);
        				bfm.send_byte(DATA_TYPE, B[7:0]);
        
     					bfm.send_byte(DATA_TYPE, A[31:24]);
        				bfm.send_byte(DATA_TYPE, A[23:16]);
        				bfm.send_byte(DATA_TYPE, A[15:8]);
	         	
	         		bfm.send_byte(CMD_TYPE, {1'b0, add_op, bfm.crc4_generate({B,A,1'b1,add_op},4'h0)});
	         		bfm.send_byte(1'b1,{8'b11111111});
			         	
			         err_data_rand = 1'b1;
		         end
	         end         	
         	er_crc_op: begin : case_er_crc_op
	         	//crc_error = (bfm.crc4_generate({B,A,1'b1,op},4'h0) + 1'b1);
        			bfm.send_calculation_data(B, A, add_op, (bfm.crc4_generate({B,A,1'b1,op_set},4'h0) + 1'b1));
         	end
         	er_op_op: begin : case_er_op_op
	         	bfm.send_calculation_data(B, A, op_set, bfm.crc4_generate({B,A,1'b1,op_set},4'h0));
         	end
           default: begin
	           bfm.send_calculation_data(B, A, op_set, bfm.crc4_generate({B,A,1'b1,op_set},4'h0));
           end
         endcase
         // print coverage after each loop
         // can also be used to stop the simulation when cov=100%
         // $strobe("%0t %0g",$time, $get_coverage());
         //#100;
      end
      $finish;
   end : tester
   
endmodule : tester
