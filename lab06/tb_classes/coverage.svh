class coverage extends uvm_subscriber #(sequence_item);
	
	`uvm_component_utils(coverage)

	bit [31:0] A_cov;
	bit [31:0] B_cov;
	operation_t OP_cov;
	
   covergroup op_cov;	   
	   
      option.name = "cg_op_cov";

      coverpoint OP_cov {
         // #A1 test all operations
         bins A1_single_cycle[] = {[and_op : er_op_op]};

         //#A2 two operations in row
         bins A2_twoops[] = ([add_op:sub_op] [* 2]);
	      
	     	//#A3 two errors in row
         bins A3_twoops[] = ([er_data_op:er_op_op] [* 2]);
	      
	      // #A4 test all operations after errors
         bins A4_op_er[] = ([er_data_op:er_op_op] => [and_op:sub_op]);
	      
	      // #A5 test all errors after operations
         bins A5_er_op[] = ([and_op:sub_op] => [er_data_op:er_op_op]);

      }

   endgroup

   covergroup zeros_or_ones_on_ops;

      option.name = "cg_zeros_or_ones_on_ops";

      all_ops : coverpoint OP_cov {
         bins opss = {[and_op : er_op_op]};
      }

      a_leg: coverpoint A_cov {
         bins zeros = {'h0000_0000};
         bins others= {['h0000_0001:'hFFFF_FFFE]};
         bins ones  = {'hFFFF_FFFF};
      }
      
      b_leg: coverpoint B_cov {
         bins zeros = {'h0000_0000};
         bins others= {['h0000_0001:'hFFFF_FFFE]};
         bins ones  = {'hFFFF_FFFF};
      }

      B_op_00_FF:  cross a_leg, b_leg, all_ops {

         // #B1 simulate all zero input for all the operations

         bins B1_and_00 = binsof (all_ops) intersect {and_op} &&
                       (binsof (a_leg.zeros) || binsof (b_leg.zeros));

         bins B1_or_00 = binsof (all_ops) intersect {or_op} &&
                       (binsof (a_leg.zeros) || binsof (b_leg.zeros));

         bins B1_add_00 = binsof (all_ops) intersect {add_op} &&
                       (binsof (a_leg.zeros) || binsof (b_leg.zeros));

         bins B1_sub_00 = binsof (all_ops) intersect {sub_op} &&
                       (binsof (a_leg.zeros) || binsof (b_leg.zeros));
	      
	      bins B1_err_data_00 = binsof (all_ops) intersect {er_data_op} &&
                       (binsof (a_leg.zeros) || binsof (b_leg.zeros));
	      
	      bins B1_err_crc_00 = binsof (all_ops) intersect {er_crc_op} &&
                       (binsof (a_leg.zeros) || binsof (b_leg.zeros));
	      
	    	bins B1_err_op_00 = binsof (all_ops) intersect {er_op_op} &&
                       (binsof (a_leg.zeros) || binsof (b_leg.zeros));

         // #B2 simulate all one input for all the operations

         bins B2_and_FF = binsof (all_ops) intersect {and_op} &&
                       (binsof (a_leg.ones) || binsof (b_leg.ones));

         bins B2_or_FF = binsof (all_ops) intersect {or_op} &&
                       (binsof (a_leg.ones) || binsof (b_leg.ones));

         bins B2_add_FF = binsof (all_ops) intersect {add_op} &&
                       (binsof (a_leg.ones) || binsof (b_leg.ones));

         bins B2_sub_FF = binsof (all_ops) intersect {sub_op} &&
                       (binsof (a_leg.ones) || binsof (b_leg.ones));
	      
         bins B2_err_data_FF = binsof (all_ops) intersect {er_data_op} &&
                       (binsof (a_leg.ones) || binsof (b_leg.ones));
	      
         bins B2_err_crc_FF = binsof (all_ops) intersect {er_crc_op} &&
                       (binsof (a_leg.ones) || binsof (b_leg.ones));
	      
         bins B2_err_op_FF = binsof (all_ops) intersect {er_op_op} &&
                       (binsof (a_leg.ones) || binsof (b_leg.ones));


         ignore_bins others_only =
                                  binsof(a_leg.others) && binsof(b_leg.others);

      }

   endgroup

   function new(string name, uvm_component parent);
	   super.new(name,parent);
	   op_cov = new();
	   zeros_or_ones_on_ops = new();
   endfunction : new
   
	function void write(sequence_item t);
   	A_cov    = t.A;
      B_cov    = t.B;
      OP_cov 	= t.op;
      op_cov.sample();
      zeros_or_ones_on_ops.sample();
	endfunction : write
   
endclass : coverage