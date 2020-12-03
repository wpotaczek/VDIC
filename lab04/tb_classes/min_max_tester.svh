class min_max_tester extends random_tester;

    `uvm_component_utils(min_max_tester)

	function byte get_data_min_max();
		bit zero_ones;
		zero_ones = $random;
		if(zero_ones == 1'b0)
			return 32'h0000_0000;
		else
			return 32'hFFFF_FFFF;
	endfunction : get_data_min_max

    function new (string name, uvm_component parent);
        super.new(name, parent);
    endfunction : new

endclass : min_max_tester
