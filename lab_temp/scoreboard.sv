module scoreboard(alu_bfm bfm);
import alu_pkg::*;

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
   
    

   always @(negedge bfm.sin) begin
		bfm.sin_to_queue(q_sin_A_scor,q_sin_B_scor,q_sin_CTL_scor);
	   bfm.decode_sin(q_sin_A_scor,q_sin_B_scor,q_sin_CTL_scor, A_scor, B_scor, OP_scor);
   end
   
   always @(negedge bfm.sout) begin
		bfm.capture_sout(cap_C, cap_CTL_sout);
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
			passed += 1;
	   else
		  	$error ("FAILED: A: %0h  B: %0h  op: %s result: %0h",
                  A, B, OP_scor.name(), cap_C);
		failed += 1;
 		done = 1'b0;
		if((passed < 1000) | (failed > 1))
			$error ("FAILED!!!");
		else
			$display ("PASSED!!!");
   end : scoreboard
   
endmodule : scoreboard