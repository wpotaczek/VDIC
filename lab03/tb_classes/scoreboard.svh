class scoreboard extends uvm_component;

    `uvm_component_utils(scoreboard)

    virtual alu_bfm bfm;

    function new (string name, uvm_component parent);
        super.new(name, parent);
    endfunction : new

    function void build_phase(uvm_phase phase);
        if(!uvm_config_db #(virtual alu_bfm)::get(null, "*","bfm", bfm))
            $fatal(1,"Failed to get BFM");
    endfunction : build_phase

	bit [10:0] failed = 1'b0;
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
	
	task calc_pred_value();
		case (OP_scor)
     		and_op: pred_C = A_scor & B_scor;
     		or_op: pred_C = A_scor | B_scor;
       	add_op: pred_C = A_scor + B_scor;
        	sub_op: pred_C = B_scor - A_scor;
	    	default: pred_C = 0;
      endcase // case (op_set)		
	endtask : calc_pred_value
	
	task calc_pred_flags();
		case(OP_scor)
	   	er_crc_op: pred_CTL = ERR_CRC_FRAME;
	      er_op_op: pred_CTL = ERR_OP_FRAME;
	      er_data_op: pred_CTL = ERR_DATA_FRAME;
	  		default: begin
		   	pred_flags[0] = pred_C[31];
		     	pred_flags[1] = (pred_C == 0);
		     	pred_flags[2] = (((OP_scor == add_op) && !(A_scor[31]^B_scor[31]) && (A_scor[31]^pred_C[31])) || ((OP_scor == sub_op) && !(A_scor[31]^pred_C[31]) && (B_scor[31]^pred_C[31])));
		     	pred_flags[3] = (((OP_scor == add_op) && ((pred_C < A_scor) || (pred_C < B_scor))) || ((OP_scor == sub_op) && (B_scor < pred_C)));;
		     	pred_CRC = bfm.crc3_generate({pred_C,1'b0,pred_flags}, 3'b000);
		     	pred_CTL = {1'b0,pred_flags,pred_CRC};
	      end
		endcase
	endtask : calc_pred_flags
		
	task run_phase(uvm_phase phase);

		forever begin : self_checker
			bfm.wait_sin(A_scor, B_scor, OP_scor);
			bfm.wait_sout(cap_C, cap_CTL_sout, done);
   			
  			@(posedge done)
  			begin
	  			calc_pred_value();
	  			calc_pred_flags();
				if((pred_C != cap_C) && (pred_CTL != cap_CTL_sout))
					failed += 1;	
 				done = 1'b0;
   		end   			
		end :self_checker
	endtask : run_phase
	
	function void print_results();
		begin
			if(failed > 1)
				$error ("############################# FAILED!!! #############################");
			else
				$display ("############################# PASSED!!! #############################");
		end
	endfunction : print_results

endclass : scoreboard