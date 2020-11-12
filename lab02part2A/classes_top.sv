virtual class shape;
	protected real width;
	protected real height;
	
	function new(real w, real h);
		width = w;
		height = h;
	endfunction : new
	
	pure virtual function real get_area();
	
	pure virtual function void print();
endclass

class rectangle extends shape;
	
	function new(real w, real h);
		super.new(w,h);
	endfunction : new
	
	function real get_area();
		return (width*height);
	endfunction : get_area
	
	function void print();
		$display("Rectangle w=%g h=%g area=%g", width, height, get_area());
	endfunction : print
	
endclass

class square extends shape;
	
	function new(real w, real h);
		super.new(w,w);
	endfunction :new
	
	function real get_area();
		return (width*width);
	endfunction : get_area
	
	function void print();
		$display("Square w=%g area=%g", width, get_area());
	endfunction : print
	
endclass

class triangle extends shape;
	
	function new(real w, real h);
		super.new(w,h);
	endfunction : new
	
	function real get_area();
		return (0.5*width*height);
	endfunction : get_area
	
	function void print();
		$display("Triangle w=%g h=%g area=%g", width, height, get_area());
	endfunction : print
	
endclass

class shape_factory;
	
	static function shape make_shape(string shape_type, real w, real h);
		rectangle rectangle;
		square square;
		triangle triangle;
		
		case(shape_type)
			"rectangle" : begin
				rectangle = new(w,h);
				return rectangle;
			end
			"square" : begin
				square = new(w,h);
				return square;
			end			
			"triangle" : begin
				triangle = new(w,h);
				return triangle;
			end
			default :
				$fatal(1, {"No such shape: ", shape_type});
		endcase
	endfunction
endclass : shape_factory

class shape_reporter #(type T = shape);
	
	protected static T shape_storage[$];
	
	static function collect_shapes(T l);
		shape_storage.push_back(l);
	endfunction : collect_shapes
	
	static function void report_shapes();
		real area_sum = 0;
		foreach(shape_storage[i])
		begin
			shape_storage[i].print();
			area_sum += shape_storage[i].get_area();
		end
		$display("Total area: %g\n", area_sum);
	endfunction : report_shapes
endclass : shape_reporter		
			
			
module top;
	 
	initial begin
		shape shape_h;
		rectangle rectangle_h;
		square square_h;
		triangle triangle_h;
		
		bit cast_ok;
		 
		int file_h;
		real width;
		real height;
		string shape_name;
		 
		file_h = $fopen("lab02part2A_shapes.txt", "r");
		 
		while($fscanf(file_h,"%s %g %g", shape_name, width, height) == 3) begin
			 
			shape_h = shape_factory::make_shape(shape_name, width, height);
			 
			case(shape_name)
				"rectangle" : begin
				cast_ok = $cast(rectangle_h, shape_h);
				if(!cast_ok)
					$fatal(1, "Failed to cast shape_h to rectangle_h");
				shape_reporter#(rectangle)::collect_shapes(rectangle_h);
			end
			"square" : begin
				cast_ok = $cast(square_h, shape_h);
				if(!cast_ok)
					$fatal(1, "Failed to cast shape_h to square_h");
				shape_reporter#(square)::collect_shapes(square_h);
			end
			"triangle" : begin
				cast_ok = $cast(triangle_h, shape_h);
				if(!cast_ok)
					$fatal(1, "Failed to cast shape_h to rectangle_h");
				shape_reporter#(triangle)::collect_shapes(triangle_h);
			end
			default : 
				$fatal (1, {"No such shape: ", shape_name});
			endcase
		end
		shape_reporter#(rectangle)::report_shapes();
		shape_reporter#(square)::report_shapes();
		shape_reporter#(triangle)::report_shapes();
	end			 
endmodule
