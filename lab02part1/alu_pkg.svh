/******************************************************************************
* (C) Copyright 2013 <Company Name> All Rights Reserved
*
* MODULE:    name
* DEVICE:
* PROJECT:
* AUTHOR:    wpotaczek
* DATE:      2020 4:25:45 PM
*
* ABSTRACT:  You can customize the file content from Window -> Preferences -> DVT -> Code Templates -> "verilog File"
*
*******************************************************************************/

package alu_pkg;
      typedef enum bit[2:0]  {and_op  		= 3'b000,
										or_op   		= 3'b001,
       								add_op   	= 3'b100,
       								sub_op   	= 3'b101,
              						er_data_op	= 3'b010,
       								er_crc_op  	= 3'b011,
       								er_op_op  	= 3'b110} operation_t;
   
   	localparam  DATA_TYPE = 1'b0,
     					CMD_TYPE = 1'b1,
     					ERR_DATA_FRAME = 8'b11001001,
     					ERR_CRC_FRAME = 8'b10100101,
     					ERR_OP_FRAME = 8'b10010011;

endpackage : alu_pkg
