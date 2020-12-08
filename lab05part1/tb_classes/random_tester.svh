class random_tester extends base_tester;
    
    `uvm_component_utils (random_tester)

    function new (string name, uvm_component parent);
        super.new(name, parent);
    endfunction : new

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
			3'b111 : return add_op;
		endcase
	endfunction : get_op

endclass : random_tester
