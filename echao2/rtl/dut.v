module MyDesign (
//---------------------------------------------------------------------------
//Control signals
  input   wire dut_run                    , 
  output  dut_busy                   ,
  input   wire reset_b                    ,  
  input   wire clk                        ,
 
//---------------------------------------------------------------------------
//Input SRAM interface
  output       input_sram_write_enable    ,
  output [11:0] input_sram_write_addresss  ,
  output [15:0] input_sram_write_data      ,
  output [11:0] input_sram_read_address    ,
  input wire [15:0] input_sram_read_data       ,

//---------------------------------------------------------------------------
//Output SRAM interface
  output        output_sram_write_enable    ,
  output [11:0] output_sram_write_addresss  ,
  output [15:0] output_sram_write_data      ,
  output [11:0] output_sram_read_address    ,
  input wire [15:0] output_sram_read_data       ,

//---------------------------------------------------------------------------
//Scratchpad SRAM interface
  output reg        scratchpad_sram_write_enable    ,
  output reg [11:0] scratchpad_sram_write_addresss  ,
  output reg [15:0] scratchpad_sram_write_data      ,
  output reg [11:0] scratchpad_sram_read_address    ,
  input wire [15:0] scratchpad_sram_read_data       ,

//---------------------------------------------------------------------------
//Weights SRAM interface                                                       
  output         weights_sram_write_enable    ,
  output [11:0] weights_sram_write_addresss  ,
  output [15:0] weights_sram_write_data      ,
  output [11:0] weights_sram_read_address    ,
  input wire [15:0] weights_sram_read_data       

);

wire [1:0] input_sel; 					// which bits to choose from [15:8] [7:0]
wire [2:0] weight_sel; 					// where to store into weight matrix
wire [1:0] output_sel; 					// which bits to output [15:8] [7:0]

wire [1:0] read_address_input_sel; 		// line to choose how to read input address
wire [1:0] write_address_output_sel; 	// line to choose how to write output address
wire [1:0] read_address_weight_sel; 	// line to choose how to read weight address

controller U1 (clk, reset_b, dut_run, dut_busy, input_sram_write_enable, weights_sram_write_enable, output_sram_write_enable,
				input_sel, weight_sel, output_sel, read_address_input_sel, write_address_output_sel, read_address_weight_sel);

datapath U2 (clk, reset_b, dut_run, dut_busy, input_sel, weight_sel, output_sel, read_address_input_sel, write_address_output_sel, read_address_weight_sel,
				input_sram_write_enable, weights_sram_write_enable, output_sram_write_enable, input_sram_read_data, weights_sram_read_data,
				output_sram_write_data, input_sram_read_address, weights_sram_read_address, output_sram_write_addresss);

endmodule

module datapath (

	input wire clk,
	input wire reset_b,
	input wire dut_run,
	input wire dut_busy,

	input wire [1:0] input_sel, 					// which bits to choose from [15:8] [7:0]
	input wire [2:0] weight_sel, 					// where to store into weight matrix
	input wire [1:0] output_sel, 					// which bits to output [15:8] [7:0]

	input wire [1:0] read_address_input_sel, 		// line to choose how to read input address
	input wire [1:0] write_address_output_sel, 		// line to choose how to write output address
	input wire [1:0] read_address_weight_sel, 		// line to choose how to read weight address

	input wire input_sram_write_enable, 			// set to low to always read input
	input wire weights_sram_write_enable, 			// set to low to always read weight
	input wire output_sram_write_enable, 			// set to high when want to write output 

	input wire [15:0] input_sram_read_data,
	input wire [15:0] weights_sram_read_data,

	output reg [15:0] output_sram_write_data,

	output reg [11:0] input_sram_read_address,
	output reg [11:0] weights_sram_read_address,
	output reg [11:0] output_sram_write_addresss

);

// input data
reg signed [7:0] input_bits;

// weight data
reg signed [15:0] weight_0_1;
reg signed [15:0] weight_2_3;
reg signed [15:0] weight_4_5;
reg signed [15:0] weight_6_7;
reg signed [15:0] weight_8_9;

// temp registers to make sure bits set as signed
reg signed [7:0] temp0;
reg signed [7:0] temp1;
reg signed [7:0] temp2;
reg signed [7:0] temp3;
reg signed [7:0] temp4;
reg signed [7:0] temp5;
reg signed [7:0] temp6;
reg signed [7:0] temp7;
reg signed [7:0] temp8;

// multiply registers
reg signed [15:0] mult_0;
reg signed [15:0] mult_1;
reg signed [15:0] mult_2;
reg signed [15:0] mult_3;
reg signed [15:0] mult_4;
reg signed [15:0] mult_5;
reg signed [15:0] mult_6;
reg signed [15:0] mult_7;
reg signed [15:0] mult_8;

// accumulate registers
reg signed [19:0] accumulate_0;
reg signed [19:0] accumulate_1;
reg signed [19:0] accumulate_2;
reg signed [19:0] accumulate_3;
reg signed [19:0] accumulate_4;
reg signed [19:0] accumulate_5;
reg signed [19:0] accumulate_6;
reg signed [19:0] accumulate_7;
reg signed [19:0] accumulate_8;

// intermediary stored convolution values
reg signed [19:0] conv_0;
reg signed [19:0] conv_1;
reg signed [19:0] conv_2;
reg signed [19:0] conv_3;
reg signed [19:0] conv_4;
reg signed [19:0] conv_5;
reg signed [19:0] conv_6;
reg signed [19:0] conv_7;
reg signed [19:0] conv_8;

// shift registers
reg signed [19:0] shift_reg_0;
reg signed [19:0] shift_reg_1;
reg signed [19:0] shift_reg_2;
reg signed [19:0] shift_reg_3;
reg signed [19:0] shift_reg_4;
reg signed [19:0] shift_reg_5;
reg signed [19:0] shift_reg_6;
reg signed [19:0] shift_reg_7;
reg signed [19:0] shift_reg_8;
reg signed [19:0] shift_reg_9;
reg signed [19:0] shift_reg_10;
reg signed [19:0] shift_reg_11;
reg signed [19:0] shift_reg_12;
reg signed [19:0] shift_reg_13;
reg signed [19:0] shift_reg_14;
reg signed [19:0] shift_reg_15;
reg signed [19:0] shift_reg_16;
reg signed [19:0] shift_reg_17;
reg signed [19:0] shift_reg_18;
reg signed [19:0] shift_reg_19;
reg signed [19:0] shift_reg_20;
reg signed [19:0] shift_reg_21;
reg signed [19:0] shift_reg_22;
reg signed [19:0] shift_reg_23;
reg signed [19:0] shift_reg_24;
reg signed [19:0] shift_reg_25;

// output data
reg signed [15:0] output_data;
reg signed [7:0] output_temp; 

//--------------------------------------------------------------------------------------------------------

// datapath components

// Input SRAM READ ADDRESS
always @(posedge clk or negedge reset_b) begin
	if (!reset_b)
		input_sram_read_address <= 12'b0; 									// set to 0
	else begin
		if (read_address_input_sel == 2'b0) 								// set to 0
			input_sram_read_address <= 12'b0;
		else if (read_address_input_sel == 2'b01) 							// increment address
			input_sram_read_address <= input_sram_read_address + 12'b1;
		else if (read_address_input_sel == 2'b10) 							// feed back into itself
			input_sram_read_address <= input_sram_read_address;
	end
end

// Weight SRAM READ ADDRESS
always @(posedge clk or negedge reset_b) begin
	if (!reset_b)
		weights_sram_read_address <= 12'b0; 									// set to 0
	else begin
		if (read_address_weight_sel == 2'b0) 									// set to 0
			weights_sram_read_address <= 12'b0;
		else if (read_address_weight_sel == 2'b01) 								// increment address
			weights_sram_read_address <= weights_sram_read_address + 12'b1;
		else if (read_address_weight_sel == 2'b10) 								// feed back into itself
			weights_sram_read_address <= weights_sram_read_address;
	end
end

// Output SRAM WRITE ADDRESS
always @(posedge clk or negedge reset_b) begin
	if (!reset_b)
		output_sram_write_addresss <= 12'b0; 									// set to 0
	else begin
		if (write_address_output_sel == 2'b0) 									// set to 0
			output_sram_write_addresss <= 12'b0;
		else if (write_address_output_sel == 2'b01) 							// increment address
			output_sram_write_addresss <= output_sram_write_addresss + 12'b1;
		else if (write_address_output_sel == 2'b10) 							// feed back into itself
			output_sram_write_addresss <= output_sram_write_addresss;
	end
end

// WRITE OUTPUT SRAM VALUES
always @(posedge clk or negedge reset_b) begin
	if (!reset_b)
		output_sram_write_data <= 16'b0; 						// set to 0
	else begin
		if (output_sram_write_enable) 							// write output data
			output_sram_write_data <= output_data;
		else
			output_sram_write_data <= output_sram_write_data; 	// feed back into itself
	end
end

//--------------------------------------------------------------------------------------------------------

always @(posedge clk or negedge reset_b) begin

	if (!reset_b) begin 

		input_bits <= 0;
	
		weight_0_1 <= 0;
		weight_2_3 <= 0;
		weight_4_5 <= 0;
		weight_6_7 <= 0;
		weight_8_9 <= 0;
		
		temp0 <= 0;
		temp1 <= 0;
		temp2 <= 0;
		temp3 <= 0;
		temp4 <= 0;
		temp5 <= 0;
		temp6 <= 0;
		temp7 <= 0;
		temp8 <= 0;

		mult_0 <= 0;
		mult_1 <= 0;
		mult_2 <= 0;
		mult_3 <= 0;
		mult_4 <= 0;
		mult_5 <= 0;
		mult_6 <= 0;
		mult_7 <= 0;
		mult_8 <= 0;
		
		/*accumulate_0 <= 0;
		accumulate_1 <= 0;
		accumulate_2 <= 0;
		accumulate_3 <= 0;
		accumulate_4 <= 0;
		accumulate_5 <= 0;
		accumulate_6 <= 0;
		accumulate_7 <= 0;
		accumulate_8 <= 0;*/
		
		conv_0 <= 0;
		conv_1 <= 0;
		conv_2 <= 0;
		conv_3 <= 0;
		conv_4 <= 0;
		conv_5 <= 0;
		conv_6 <= 0;
		conv_7 <= 0;
		conv_8 <= 0;
		
		shift_reg_0 <= 0;
		shift_reg_1 <= 0;
		shift_reg_2 <= 0;
		shift_reg_3 <= 0;
		shift_reg_4 <= 0;
		shift_reg_5 <= 0;
		shift_reg_6 <= 0;
		shift_reg_7 <= 0;
		shift_reg_8 <= 0;
		shift_reg_9 <= 0;
		shift_reg_10 <= 0;
		shift_reg_11 <= 0;
		shift_reg_12 <= 0;
		shift_reg_13 <= 0;
		shift_reg_14 <= 0;
		shift_reg_15 <= 0;
		shift_reg_16 <= 0;
		shift_reg_17 <= 0;
		shift_reg_18 <= 0;
		shift_reg_19 <= 0;
		shift_reg_20 <= 0;
		shift_reg_21 <= 0;
		shift_reg_22 <= 0;
		shift_reg_23 <= 0;
		shift_reg_24 <= 0;
		shift_reg_25 <= 0;

		output_data <= 0;
	
	end
	else begin
		
		// input select line to choose an 8 bit word from 16 bit data
		if (input_sel == 2'b01) input_bits <= input_sram_read_data[15:8]; 		// if 1, choose first 8 bits to be calculated upon [15:8]
		else if (input_sel == 2'b10) input_bits <= input_sram_read_data[7:0]; 	// if 2, choose last 8 bits to be calculated upon [7:0]
		else input_bits <= input_bits; 											// feed back into itself
		
		// weight select line to populate weight matrix
		if (weight_sel == 3'b000) weight_0_1 <= weights_sram_read_data; 	// if 0, store into top_left and top_middle of weight matrix
		else weight_0_1 <= weight_0_1;
		
		if (weight_sel == 3'b001) weight_2_3 <= weights_sram_read_data; 	// if 1, store into top_right and middle_left of weight matrix
		else weight_2_3 <= weight_2_3;
		
		if (weight_sel == 3'b010) weight_4_5 <= weights_sram_read_data; 	// if 2, store into middle and middle_right of weight matrix
		else weight_4_5 <= weight_4_5;
		
		if (weight_sel == 3'b011) weight_6_7 <= weights_sram_read_data; 	// if 3, store into bottom_left and bottom_middle of weight matrix
		else weight_6_7 <= weight_6_7;
		
		if (weight_sel == 3'b100) weight_8_9 <= weights_sram_read_data; 	// if 4, store into bottom_right and NULL of weight matrix
		else weight_8_9 <= weight_8_9;
		
		// convolution registers
		conv_0 <= accumulate_0;
		conv_1 <= accumulate_1;
		conv_2 <= accumulate_2;
		conv_3 <= accumulate_3; 
		conv_4 <= accumulate_4;
		conv_5 <= accumulate_5; 
		conv_6 <= accumulate_6;
		conv_7 <= accumulate_7;
		conv_8 <= accumulate_8;
		
		// shift registers for first row
		shift_reg_0 <= conv_2;
		shift_reg_1 <= shift_reg_0;
		shift_reg_2 <= shift_reg_1;
		shift_reg_3 <= shift_reg_2;
		shift_reg_4 <= shift_reg_3;
		shift_reg_5 <= shift_reg_4;
		shift_reg_6 <= shift_reg_5;
		shift_reg_7 <= shift_reg_6;
		shift_reg_8 <= shift_reg_7;
		shift_reg_9 <= shift_reg_8;
		shift_reg_10 <= shift_reg_9;
		shift_reg_11 <= shift_reg_10;
		shift_reg_12 <= shift_reg_11;
		
		// shift registers for second row
		shift_reg_13 <= conv_5;
		shift_reg_14 <= shift_reg_13;
		shift_reg_15 <= shift_reg_14;
		shift_reg_16 <= shift_reg_15;
		shift_reg_17 <= shift_reg_16;
		shift_reg_18 <= shift_reg_17;
		shift_reg_19 <= shift_reg_18;
		shift_reg_20 <= shift_reg_19;
		shift_reg_21 <= shift_reg_20;
		shift_reg_22 <= shift_reg_21;
		shift_reg_23 <= shift_reg_22;
		shift_reg_24 <= shift_reg_23;
		shift_reg_25 <= shift_reg_24;
		
		// output select line to combine 2 8bit outputs together
		if (output_sel == 2'b01) output_data[15:8] <= output_temp; 				// if 1, store final calculated data into first 8 bits [15:8]
		else if (output_sel == 2'b10) output_data[7:0] <= output_temp; 			// if 2, store final calculated data into last 8 bits [7:0]
		else output_data <= output_data; 										// feed back into itself

	end
end
		
always @(*) begin
		
		// multiply registers (make sure bits are 8 bit signed)
		temp0 = weight_0_1[15:8];
		temp1 = weight_0_1[7:0];
		temp2 = weight_2_3[15:8];
		temp3 = weight_2_3[7:0];
		temp4 = weight_4_5[15:8];
		temp5 = weight_4_5[7:0];
		temp6 = weight_6_7[15:8];
		temp7 = weight_6_7[7:0];
		temp8 = weight_8_9[15:8];

		// multiply registers cont.
		mult_0 = temp0 * input_bits;
		mult_1 = temp1 * input_bits;
		mult_2 = temp2 * input_bits; 
		mult_3 = temp3 * input_bits; 
		mult_4 = temp4 * input_bits;
		mult_5 = temp5 * input_bits;
		mult_6 = temp6 * input_bits;
		mult_7 = temp7 * input_bits;
		mult_8 = temp8 * input_bits;
		
		// accumulate registers
		accumulate_0 = 0 + mult_0;
		accumulate_1 = conv_0 + mult_1;
		accumulate_2 = conv_1 + mult_2; 
		accumulate_3 = shift_reg_12 + mult_3;
		
		accumulate_4 = conv_3 + mult_4;
		accumulate_5 = conv_4 + mult_5; 
		accumulate_6 = shift_reg_25 + mult_6; 
		
		accumulate_7 = conv_6 + mult_7;
		accumulate_8 = conv_7 + mult_8;
		
		// ReLu function along with resizing back to 8 bits
		if (conv_8[19] == 1'b1) 								// if negative set to 0
			output_temp = 8'b0000_0000;		
		else if (conv_8 > 20'b0000_0000_0000_0111_1111) 		// if greater than 127, set to 127
			output_temp = 8'b0111_1111;
		else													// else, resize to last 8 bits [7:0]
			output_temp = conv_8[7:0]; 
		
end

endmodule

//-----------------------------------------------------------------------------

// controller
module controller (

	input wire clk,
	input wire reset_b,
	input wire dut_run,

	output reg dut_busy,
	output reg input_sram_write_enable, 		// set to low to always read input
	output reg weights_sram_write_enable, 		// set to low to always read weight
	output reg output_sram_write_enable, 		// set to high when want to write output 

	output reg [1:0] input_sel, 				// which bits to choose from [15:8] [7:0]
	output reg [2:0] weight_sel, 				// where to store into weight matrix
	output reg [1:0] output_sel, 				// which bits to output [15:8] [7:0]

	output reg [1:0] read_address_input_sel, 	// line to choose how to read input address
	output reg [1:0] write_address_output_sel, 	// line to choose how to write output address
	output reg [1:0] read_address_weight_sel 	// line to choose how to read weight address
	
);

parameter [4:0] // states
	
	s0 = 5'b00000, 
	s1 = 5'b00001,
	s2 = 5'b00010,
	s3 = 5'b00011,
	s4 = 5'b00100,
	s5 = 5'b00101,
	s6 = 5'b00110,
	s7 = 5'b00111,
	s8 = 5'b01000,
	s9 = 5'b01001,
	s10 = 5'b01010,
	s11 = 5'b01011,
	s12 = 5'b01100,
	s13 = 5'b01101,
	s14 = 5'b01110,
	s15 = 5'b01111,
	s16 = 5'b10000,
	s17 = 5'b10001,
	s18 = 5'b10010;

// state registers
reg [4:0] current_state, next_state;

// cycle counter
reg [15:0] cycle_counter_wire;
reg [15:0] cycle_counter;
	
always @(posedge clk or negedge reset_b) begin
	if (!reset_b) begin
		current_state <= s0; 	// reset state s0
		cycle_counter <= 0; 	// reset counter to 0
	end
	else begin
		current_state <= next_state; 			// next state
		cycle_counter <= cycle_counter_wire;	// "increment counter"
	end
end

always @(*) begin

	// initiate to prevent latches
	dut_busy = 0; 
	read_address_input_sel = 2'b00;
	read_address_weight_sel = 2'b00; 
	write_address_output_sel = 2'b10; 
	input_sram_write_enable = 0; 
	weights_sram_write_enable = 0;
	output_sram_write_enable = 0; 
	input_sel = 2'b11; 
	weight_sel = 3'b111; 
	output_sel = 2'b11; 

	cycle_counter_wire = cycle_counter;
	
	case(current_state)
		s0: begin // clear everything // starts reading at the address
			
			if(dut_run) begin
				dut_busy = 0; 
				read_address_input_sel = 2'b00; // read from input address 0
				read_address_weight_sel = 2'b01; // read from weight address 0
				write_address_output_sel = 2'b00;
				input_sram_write_enable = 0; 
				weights_sram_write_enable = 0; 
				output_sram_write_enable = 0; 
				input_sel = 2'b00;
				weight_sel = 3'b000;
				output_sel = 2'b00;

				cycle_counter_wire = 16'b0;

				next_state = s1;
			end
			else begin
				next_state = s0;
			end
		end			

		s1: begin // top left and top middle weight matrix populated
		
			dut_busy = 1; 
			read_address_input_sel = 2'b00; 
			read_address_weight_sel = 2'b01; // increment weight address
			input_sram_write_enable = 0; 
			weights_sram_write_enable = 0;
			input_sel = 2'b10; // change later
			weight_sel = 3'b000; // store weight data into top_left and top_middle register
			
			// set to next state
			next_state = s2;
		end

		s2: begin // top right and middle left weight matrix populated
		
			dut_busy = 1; 
			read_address_input_sel = 2'b00; 
			read_address_weight_sel = 2'b01; // increment weight address
			input_sram_write_enable = 0; 
			weights_sram_write_enable = 0;
			input_sel = 2'b01; // change later
			weight_sel = 3'b001; // store weight data into top_right and middle_left register
			
			// set to next state
			next_state = s3;
		end
		
		s3: begin // middle and middle right weight matrix populated
		
			dut_busy = 1;
			read_address_input_sel = 2'b00;
			read_address_weight_sel = 2'b01; // increment weight address
			weights_sram_write_enable = 0;
			input_sel = 2'b10; // change later
			weight_sel = 3'b010; // store weight data into middle and middle_right register
			
			// set to next state
			next_state = s4;
		end
		
		s4: begin // bottom left and bottom middle weight matrix populated
		
			dut_busy = 1;
			read_address_input_sel = 2'b01; // increment read address
			read_address_weight_sel = 2'b01; // increment weight address
			weights_sram_write_enable = 0;
			input_sel = 2'b01; // change later
			weight_sel = 3'b011; // store weight data into bottom_left and bottom_middle register

			// set to next state
			next_state = s5;
		end
		
		s5: begin // bottom right weight matrix populated
		
			dut_busy = 1;
			read_address_input_sel = 2'b10; // read from same address
			read_address_weight_sel = 2'b01; // increment weight address
			weights_sram_write_enable = 0;
			input_sel = 2'b10; // change later
			weight_sel = 3'b100; // store weight data into bottom_right and NULL register

			// set to next state
			next_state = s6;
		end
		
		//-----------------------------------------------------------------------------

		s6: begin // store input data from input address into [15:8]
		
			dut_busy = 1;
			read_address_input_sel = 2'b01; // increment to input address 1
			read_address_weight_sel = 2'b00; // nothing
			weights_sram_write_enable = 1; 
			input_sel = 2'b01; // store input data from input address into [15:8]
			
			// set to next state
			next_state = s7;
		end
		
		s7: begin // store input data from input address into [7:0]
		
			dut_busy = 1;
			read_address_input_sel = 2'b10;
			input_sram_write_enable = 0;
			input_sel = 2'b10; // store input data from input address into [7:0]

			cycle_counter_wire = cycle_counter + 1;

			// set to next state
			if (cycle_counter == 32) // change states so valid convolutions can be written into output
				next_state = s9;
			else
				next_state = s8;
		end
		
		s8: begin 
	
			dut_busy = 1;
			read_address_input_sel = 2'b01;
			input_sram_write_enable = 0;
			input_sel = 2'b01; 
			//size_count_sel = 2'b01;
			cycle_counter_wire = cycle_counter + 1;

			// set to next state
			next_state = s7;
		end
		
		//-----------------------------------------------------------------------------

		s9: begin // following states continue to read input data while outputting data for valid convolutions within the row
		
			dut_busy = 1;
			read_address_input_sel = 2'b01;
			input_sram_write_enable = 0;
			input_sel = 2'b01;

			write_address_output_sel = 2'b10; 
			output_sram_write_enable = 1;
			output_sel = 2'b01;
			
			cycle_counter_wire = cycle_counter + 1;

			// set to next state
			next_state = s10;
		end

		s10: begin
		
			dut_busy = 1;
			read_address_input_sel = 2'b10; 
			input_sram_write_enable = 0;
			input_sel = 2'b10; 

			write_address_output_sel = 2'b10; 
			output_sram_write_enable = 1;
			output_sel = 2'b10; 
			
			cycle_counter_wire = cycle_counter + 1;

			// set to next state
			next_state = s11;
		end

		s11: begin 
		
			dut_busy = 1;
			read_address_input_sel = 2'b01; 
			input_sram_write_enable = 0;
			input_sel = 2'b01; 

			write_address_output_sel = 2'b10;  
			output_sram_write_enable = 1;
			output_sel = 2'b01; 
			
			cycle_counter_wire = cycle_counter + 1;

			// set to next state
			next_state = s12; 
		end

		s12: begin 
		
			dut_busy = 1;
			read_address_input_sel = 2'b10; 
			input_sram_write_enable = 0;
			input_sel = 2'b10; 
			
			write_address_output_sel = 2'b01; 
			output_sram_write_enable = 1; 
			output_sel = 2'b10; 

			cycle_counter_wire = cycle_counter + 1;

			// set to next state
			if (cycle_counter == 256) // if end of output matrix, reset everything 
				next_state = s0; 
			else if (cycle_counter == 46 || cycle_counter == 62 || cycle_counter == 78 || cycle_counter == 94 || 
				cycle_counter == 110 || cycle_counter == 126 || cycle_counter == 142 || cycle_counter == 158 ||
				cycle_counter == 174 || cycle_counter == 190 || cycle_counter == 206 || cycle_counter == 222 ||
				cycle_counter == 238) // if reaches end of viable row, change to next states
				next_state = s13;
			else
				next_state = s11; 
		end

		//-----------------------------------------------------------------------------

		s13: begin // following states continues reading input data while skipping outputs for data that should not be convoluted
		
			dut_busy = 1;
			read_address_input_sel = 2'b01; 
			input_sram_write_enable = 0;
			input_sel = 2'b01;
			
			write_address_output_sel = 2'b10; 
			output_sram_write_enable = 1; 
			output_sel = 2'b01; 
			
			cycle_counter_wire = cycle_counter + 1;

			// set to next state
			next_state = s14;
		end
		
		s14: begin 
		
			dut_busy = 1;
			read_address_input_sel = 2'b10; 
			input_sram_write_enable = 0;
			input_sel = 2'b10; 
			
			write_address_output_sel = 2'b10; 
			output_sram_write_enable = 0; 
			output_sel = 2'b10; 
			
			cycle_counter_wire = cycle_counter + 1;

			// set to next state
			next_state = s15;
		end

		s15: begin 
		
			dut_busy = 1;
			read_address_input_sel = 2'b01; 
			input_sram_write_enable = 0;
			input_sel = 2'b01; 
			
			write_address_output_sel = 2'b10; 
			output_sram_write_enable = 0; 
			output_sel = 2'b01; 
			
			cycle_counter_wire = cycle_counter + 1;

			// set to next state
			next_state = s16;
		end

		s16: begin 
			
			dut_busy = 1;
			read_address_input_sel = 2'b10; 
			input_sram_write_enable = 0;
			input_sel = 2'b10; 

			write_address_output_sel = 2'b01; 
			output_sram_write_enable = 1;
			output_sel = 2'b10; 
			
			cycle_counter_wire = cycle_counter + 1;

			// set to next state
			next_state = s17; 
		end

		s17: begin 
		
			dut_busy = 1;
			read_address_input_sel = 2'b01; 
			input_sram_write_enable = 0;
			input_sel = 2'b01; 

			write_address_output_sel = 2'b10;  
			output_sram_write_enable = 1;
			output_sel = 2'b01; 
			
			cycle_counter_wire = cycle_counter + 1;

			// set to next state
			next_state = s18;
		end

		s18: begin 
		
			dut_busy = 1;
			read_address_input_sel = 2'b10; 
			input_sram_write_enable = 0;
			input_sel = 2'b10; 
			
			write_address_output_sel = 2'b01;
			output_sram_write_enable = 1; 
			output_sel = 2'b10; 
			
			cycle_counter_wire = cycle_counter + 1;

			// set to next state
			next_state = s11; 
		end

		//-----------------------------------------------------------------------------

		default: next_state = s0;

	endcase
end

endmodule