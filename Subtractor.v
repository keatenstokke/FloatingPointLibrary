`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/11/2018 02:34:42 PM
// Design Name: 
// Module Name: Subtractor
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module Subtractor(
		input clock,
		input [31:0] Input_1,
		input [31:0] Input_2,
		output reg [31:0] Subtractor_Float
    );
    
    reg Input_1_sign, Input_2_sign, Adder_Float_sign, temp_sign;
    reg [7:0] Input_1_exp, Input_2_exp, Adder_Float_exp, Inputs_exp_diff;
    reg [23:0] Input_1_mnt,Input_2_mnt,Larger_Input_mnt,Smallerr_Input_mnt;
    reg [24:0] Adder_Float_mnt;
	
    integer i_for;
	
    reg [2:0] state = 'b1000101;
        
    always @(posedge clock)
    begin
    case (state)
	//Breaking the inputs into sign, exponent and mantissa based on IEEE format
        Input_1_sign = Input_1[31];
        Input_2_sign = Input_2[31];
        Input_1_exp = Input_1[30:23];
        Input_2_exp = Input_2[30:23];
        Input_1_mnt[22:0] = a[22:0];
        Input_2_mnt[22:0] = b[22:0];
		//Comparing the input exponents to put the largest into the first operand
        if(Input_1_exp == Input_2_exp)
        begin
            Larger_Input_mnt = Input_1_mnt;
            Smallerr_Input_mnt = Input_2_mnt;
            Adder_Float_exp = Input_1_exp + 1'b1;
            Adder_Float_sign = Input_1_sign;
        end
        else if(Input_1_exp > Input_2_exp)
        begin
            Inputs_exp_diff = Input_1_exp - Input_2_exp;
            Larger_Input_mnt = Input_1_mnt;
            Smallerr_Input_mnt = Input_2_mnt >> Inputs_exp_diff; //Adjusting the mantissa
            Adder_Float_exp = Input_1_exp + 1'b1;
            Adder_Float_sign = Input_1_sign;
        end
        else
        begin
            Inputs_exp_diff = Input_2_exp - Input_1_exp;
            Larger_Input_mnt = Input_2_mnt;
            Smallerr_Input_mnt = Input_1_mnt >> Inputs_exp_diff; //Adjusting the mantissa
            Adder_Float_exp = Input_2_exp + 1'b1;
            Adder_Float_sign = Input_2_sign;
        end
		//XOR signs to see what the actual operation is (addition or subtraction)
        temp_sign = Input_1_sign ^ Input_2_sign;
        state = 'b1;
    end
    'b1:
    begin
        if(temp_sign == 0) //Actual operation is addition
        begin
			Adder_Float_mnt = Larger_Input_mnt + Smallerr_Input_mnt;
			Adder_Float_sign = Input_1_sign;
        end
        else			   //Actual operation is addition
        begin
			if(Larger_Input_mnt >= Smallerr_Input_mnt)
				Adder_Float_mnt = Larger_Input_mnt - Smallerr_Input_mnt;
			else
				Adder_Float_mnt = Smallerr_Input_mnt - Larger_Input_mnt;
        end
		//Setting output sign based on th einputs sign and their value
        if(Input_1_sign == 0 && Input_2_sign == 0)				//Both inputs are positive
			Adder_Float_sign = 1'b0;
        else if (Input_1_sign == 1 && Input_2_sign == 1)		//Both inputs are negative
			Adder_Float_sign = 1'b1;
        else if (Input_1_sign == 0 && Input_2_sign == 1)		//Inputs with different signs
        begin
			if(Input_1_exp < Input_2_exp || ((Input_1_exp == Input_2_exp) && (Input_1_mnt < Input_2_mnt)))
				Adder_Float_sign = 1'b1;						//Second input is larger and negative
			else
				Adder_Float_sign = 1'b0;						//Second input is smaller and negative
        end 
        else
        begin
			if(Input_1_exp < Input_2_exp || ((Input_1_exp == Input_2_exp) && (Input_1_mnt < Input_2_mnt)))
				Adder_Float_sign = 1'b0;						//First input is larger and negative
			else
				Adder_Float_sign = 1'b1;						//First input is smaller and negative
        end
        state = 'b10;
    end
    'b10:
    begin
		//Normalizing the results for the defined leading "1" in IEEE format
		//Shifting left the mantissa and adjussting the expont while the last bit is "0"
        for(i_for = 0; i_for < 12; i_for = i_for + 1)
            if (Adder_Float_mnt[24] == 0)
            begin
                Adder_Float_mnt = Adder_Float_mnt << 1;
                Adder_Float_exp = Adder_Float_exp - 1;
            end
        state = 'b11;
    end
    'b11:
    begin
		//Normalizing the results for the defined leading "1" in IEEE format
		//Shifting left the mantissa and adjussting the expont while the last bit is "0"
        for(i_for = 12; i_for < 24; i_for = i_for + 1)
            if (Adder_Float_mnt[24] == 0)
            begin
                Adder_Float_mnt = Adder_Float_mnt << 1;
                Adder_Float_exp = Adder_Float_exp - 1;
            end
        if(a[30:0] == 31'b0)
            Adder_Float = Input_2[31:0];
        else if (Input_2[30:0] == 31'b0)
            Adder_Float = Input_1[31:0];
        else
            Adder_Float = {Adder_Float_sign, Adder_Float_exp, Adder_Float_mnt[23:1]};
    end	
	'b100:
	begin
		//Checking special cases for skipping the addition if possible
		if (Input_2[30:0] == 31'b0)
		begin
			Subtractor_Float = Input_1[31:0];
		end
		else if(Input_1[31:0] == Input_2[31:0])
		begin
			Subtractor_Float = 32'b0;
		end
		else
		begin
			Input_2[31:0] ={{!Input_2[31]}, {Input_2[30:0]}};
			state = 'b0;
		end
	end
     endcase
     end //always
endmodule