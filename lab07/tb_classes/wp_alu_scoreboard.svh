class wp_alu_scoreboard extends uvm_scoreboard; //uvm_subscriber #(wp_alu_item);
	`uvm_component_utils(wp_alu_scoreboard)

	uvm_tlm_analysis_fifo #(wp_alu_item) cmd_f;
	uvm_tlm_analysis_fifo #(wp_alu_item) cmd_out;

    function new (string name, uvm_component parent);
        super.new(name, parent);
    endfunction : new

	function void build_phase(uvm_phase phase);
		cmd_f = new ("cmd_f", this);
		cmd_out = new ("cmd_out", this);
   endfunction : build_phase

	bit [10:0] failed = 1'b0;
	bit [31:0] cap_C;
  	bit [7:0] cap_CTL_sout;
  	bit [7:0] pred_CTL;
   
	shortint predicted_result;
  	bit [31:0] pred_C;
  	bit [2:0] pred_CRC;
	bit [3:0] pred_flags; // {Carry, Overflow, Zero, Negative}
   
	//bit done = 1'b0;
	
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
		
	function wp_alu_item calc_pred_values(wp_alu_item cmd);
		wp_alu_item predicted;
		predicted = new("predicted");
		
		case (cmd.op)
     		and_op:	pred_C = cmd.A & cmd.B;
     		or_op: 	pred_C = cmd.A | cmd.B;
       	add_op: 	pred_C = cmd.A + cmd.B;
        	sub_op: 	pred_C = cmd.B - cmd.A;
	    	default: pred_C = 0;			
      endcase // case (op_set)		
      
      case(cmd.op)
	   	er_crc_op: pred_CTL = ERR_CRC_FRAME;
	      er_op_op: pred_CTL = ERR_OP_FRAME;
	      er_data_op: pred_CTL = ERR_DATA_FRAME;
	  		default: begin
		   	pred_flags[0] = pred_C[31];
		     	pred_flags[1] = (pred_C == 0);
		     	pred_flags[2] = (((cmd.op == add_op) && !(cmd.A[31]^cmd.B[31]) && (cmd.A[31]^pred_C[31])) || ((cmd.op == sub_op) && !(cmd.A[31]^pred_C[31]) && (cmd.B[31]^pred_C[31])));
		     	pred_flags[3] = (((cmd.op == add_op) && ((pred_C < cmd.A) || (pred_C < cmd.B))) || ((cmd.op == sub_op) && (cmd.B < pred_C)));;
		     	pred_CRC = crc3_generate({pred_C,1'b0,pred_flags}, 3'b000);
		     	pred_CTL = {1'b0,pred_flags,pred_CRC};
	      end
      endcase
      predicted.result[39:8] = pred_C;
      predicted.result[7:0] = pred_CTL;
      return predicted;
	endfunction : calc_pred_values

	function void write();
		
		string data_str;
		wp_alu_item cmd;	
		wp_alu_item cmd_o;
		wp_alu_item predicted;
		predicted = new("predicted");
			
		do
			if (!cmd_f.try_get(cmd))
         	$fatal(1, "Missing command in self checker");
     	while (cmd.op == rst_op);

		void'(cmd_out.try_get(cmd_o));
     		
	  	predicted = calc_pred_values(cmd);
	  	//predicted.result[7:0] = calc_pred_flags(cmd);
		/*
		data_str  = { cmd.convert2string(),
      " ==>  Actual " , t.convert2string(),
      "/Predicted ",predicted.convert2string()};
*/
        if (!predicted.compare(cmd_o)) begin
            //`uvm_error("SELF CHECKER", {"FAIL: ",data_str})
            failed += 1;
        end
        //else
          //  `uvm_info ("SELF CHECKER", {"PASS: ", data_str}, UVM_HIGH)
			
endfunction


	function void report_phase(uvm_phase phase);
		begin
			if(failed > 1)
				$error ("############################# FAILED!!! #############################");
			else
				$display ("############################# PASSED!!! #############################");
		end
	endfunction : report_phase

endclass : wp_alu_scoreboard
