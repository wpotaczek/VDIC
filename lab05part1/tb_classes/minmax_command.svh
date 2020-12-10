class minmax_command extends random_command;
   `uvm_object_utils(minmax_command)

   constraint minmax_data { A dist {32'h0000_0000:/10, [32'h0000_0001 : 32'hFFFF_FFFE]:/1, 32'hFFFF_FFFF:/10};
                     B dist {32'h0000_0000:/10, [32'h0000_0001 : 32'hFFFF_FFFE]:/1, 32'hFFFF_FFFF:/10};} 
 
   constraint data { op != rst_op;}
   
	function new (string name = "");
   	super.new(name);
   endfunction : new

endclass : minmax_command