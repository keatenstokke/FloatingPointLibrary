`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/11/2018 02:34:42 PM
// Design Name: 
// Module Name: Sine
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

module Sine(
    input clock,
	input [31:0] a_in,
	output reg [31:0] sin
    );
    
    reg Input_1_sign, Input_2_sign, Adder_Float_sign, temp_sign;
    reg [7:0] Input_1_exp, Input_2_exp, Adder_Float_exp, Inputs_exp_diff;
    reg [23:0] Input_1_mnt, Input_2_mnt, Larger_Input_mnt, Smallerr_Input_mnt;
    reg [24:0] Adder_Float_mnt;
	reg Multiplier_Float_sign;
    reg [7:0]  Multiplier_Float_exp;
    reg [47:0] Multiplier_Float_mnt, temp_mnt;
	reg [22:0] Divider_Float_mnt;
    reg [7:0]  Divider_Float_exp;
    reg Divider_Float_sign;
    reg [24:0] partial_remainder, temp_remainder;
    reg [8:0] temp_exp; 
    reg [25:0] quotient;
	reg [31:0] Adder_Float, Subtractor_Float, Multiplier_Float, Divider_Float;
	
    reg [31:0] t1, t2, t3;
	
    integer i_for;
    
    reg [4:0] state = 'b11000;
    reg [4:0] temp_state;
    
    always @(posedge clock)
    begin
    case (state)
	'b0:
    begin
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
			state = temp_state;
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
	'b101:
    begin
		//Breaking the inputs into sign, exponent and mantissa based on IEEE format
        Input_1_sign = Input_1[31];
        Input_2_sign = Input_2[31]; 
        Input_1_exp = Input_1[30:23];
        Input_2_exp = Input_2[30:23];
        Input_1_mnt[22:0] = Input_1[22:0];
        Input_2_mnt[22:0] = Input_2[22:0];
		// +1 is for taking into account the leading zeros, 
		// - 126 is -127 + 1
        Multiplier_Float_exp = Input_1_exp + Input_2_exp;
        Multiplier_Float_exp = Multiplier_Float_exp - 8'b01111110;		
        state = 'b110;
    end
    'b110:
    begin
        if (Input_1 != 0 || Input_2 != 0)
        begin
            temp_mnt = Input_1_mnt * Input_2_mnt;	//Mantissa multiplicaiton
            Multiplier_Float_mnt = temp_mnt[47:24];
        end
        state = 'b111;
    end
    'b111:
    begin
        if(Multiplier_Float_mnt == 0)
        begin
            Multiplier_Float = 32'b0;
			//Skip multiplication to the end
            state = 'b1001;
        end
        else
        begin
            //Normalizing the results for the defined leading "1" in IEEE format
			//Shifting left the mantissa and adjussting the expont while the last bit is "0"
            for(i_for = 0; i_for < 12; i_for = i_for + 1)
                if(Multiplier_Float_mnt[23] == 0)
                begin
                    Multiplier_Float_mnt = Multiplier_Float_mnt << 1;
                    Multiplier_Float_exp = Multiplier_Float_exp - 1;
                end
            state = 'b1000;
        end
    end
    'b1000:
    begin
        //Normalizing the results for the defined leading "1" in IEEE format
		//Shifting left the mantissa and adjussting the expont while the last bit is "0"
        for(i_for = 12; i_for < 23; i_for = i_for + 1)
            if (Multiplier_Float_mnt[23] == 0)
            begin
                Multiplier_Float_mnt = Multiplier_Float_mnt << 1;
                Multiplier_Float_exp = Multiplier_Float_exp - 1;
            end
        state = 'b1001;
    end
    'b1001:
    begin
        Multiplier_Float_sign = Input_1_sign ^ Input_2_sign;	//Sign Calculation
        if(Input_1[30:0] == 31'b0 || Input_2[30:0] == 31'b0) 	//If any of inputs is 0, output is 0
            Multiplier_Float = 32'b0;
        else
            Multiplier_Float = {sign, Multiplier_Float_exp, Multiplier_Float_mnt[22:0]};
			state = temp_state;
    end
	'b1010:
    begin
		//Breaking the inputs into sign, exponent and mantissa based on IEEE format
        Input_1_mnt = Input_1[22:0];
        Input_1_exp = Input_1[30:23];
        Input_1_sign = Input_1[31];
        Input_2_mnt = Input_2[22:0];
        Input_2_exp = Input_2[30:23];
        Input_2_sign = Input_2[31];
		
        Divider_Float_sign = Input_1_sign ^ Input_2_sign;	//Sign calculation
		
		//Checking special cases to skip the rest of steps if possible
        if(Input_2_exp == 255)								//Division by infinity
        begin
            Divider_Float_exp = 'b0;
            Divider_Float_mnt = 'b0;
        end
        else if(Input_2_exp == 0 || Input_1_exp == 255)		//Division by zero, Division of infinity
        begin
            Divider_Float_exp = 'b11111111;
            Divider_Float_mnt = 'b0;
        end
        else
        begin
            temp_exp = {{1'b0}, Input_1_exp} - {{1'b0}, Input_2_exp} + 127;
        end
		//Mantissa division is conducted using restoring algorithm for unsigned binary nyumbers
        partial_remainder = {{2'b01}, Input_1_mnt};			//leading "1"
        i_for = 25;
        state = 'b1011;
    end
    'b1011: 
    begin  
		//Normalizing the results for the defined leading "1" in IEEE format
		//Shifting left the mantissa and adjussting the expont while the last bit is "0"
        for(i_for = 25; i_for >= 23; i_for = i_for - 1)
        begin
            temp_remainder = partial_remainder - {{2'b01}, Input_2_mnt};
            if(temp_remainder[24] == 1'b0)
            begin 
                quotient[i_for] = 1'b1;
                partial_remainder = temp_remainder;
            end
            else
            begin
                quotient[i_for] = 1'b0;
            end 
            partial_remainder = {{partial_remainder[23:0]}, {1'b0}};
        end
        state = 'b1100;
    end
    'b1100:
    begin  
		//Normalizing the results for the defined leading "1" in IEEE format
		//Shifting left the mantissa and adjussting the expont while the last bit is "0"
        for(i_for = 22; i_for >= 21; i_for = i_for - 1)
        begin
            temp_remainder = partial_remainder - {{2'b01}, Input_2_mnt};
            if(temp_remainder[24] == 1'b0)
            begin 
                quotient[i_for] = 1'b1;
                partial_remainder = temp_remainder;
            end
            else
            begin
                quotient[i_for] = 1'b0;
            end 
            partial_remainder = {{partial_remainder[23:0]}, {1'b0}};
        end
        state = 'b1101;
    end
    'b1101:
    begin 
		//Normalizing the results for the defined leading "1" in IEEE format
		//Shifting left the mantissa and adjussting the expont while the last bit is "0"
        for(i_for = 20; i_for >= 19; i_for = i_for - 1)
        begin
            temp_remainder = partial_remainder - {{2'b01}, Input_2_mnt};
            if(temp_remainder[24] == 1'b0)
            begin 
                quotient[i_for] = 1'b1;
                partial_remainder = temp_remainder;
            end
            else
            begin
                quotient[i_for] = 1'b0;
            end 
            partial_remainder = {{partial_remainder[23:0]}, {1'b0}};
        end
        state = 'b1110;
    end    
    'b1110:
    begin
		//Normalizing the results for the defined leading "1" in IEEE format
		//Shifting left the mantissa and adjussting the expont while the last bit is "0"
        for(i_for = 18; i_for >= 17; i_for = i_for - 1)
        begin
            temp_remainder = partial_remainder - {{2'b01}, Input_2_mnt};
            if(temp_remainder[24] == 1'b0)
            begin 
                quotient[i_for] = 1'b1;
                partial_remainder = temp_remainder;
            end
            else
            begin
                quotient[i_for] = 1'b0;
            end 
            partial_remainder = {{partial_remainder[23:0]}, {1'b0}};
        end
        state = 'b1111;
    end
    'b1111:
    begin 
		//Normalizing the results for the defined leading "1" in IEEE format
		//Shifting left the mantissa and adjussting the expont while the last bit is "0"
        for(i_for = 16; i_for >= 15; i_for = i_for - 1)
        begin
            temp_remainder = partial_remainder - {{2'b01}, Input_2_mnt};
            if(temp_remainder[24] == 1'b0)
            begin 
                quotient[i_for] = 1'b1;
                partial_remainder = temp_remainder;
            end
            else
            begin
                quotient[i_for] = 1'b0;
            end 
            partial_remainder = {{partial_remainder[23:0]}, {1'b0}};
        end
        state = 'b10000;
    end
    'b10000: 
    begin 
		//Normalizing the results for the defined leading "1" in IEEE format
		//Shifting left the mantissa and adjussting the expont while the last bit is "0"
        for(i_for = 14; i_for >= 13; i_for = i_for - 1)
        begin
            temp_remainder = partial_remainder - {{2'b01}, Input_2_mnt};
            if(temp_remainder[24] == 1'b0)
            begin 
                quotient[i_for] = 1'b1;
                partial_remainder = temp_remainder;
            end
            else
            begin
                quotient[i_for] = 1'b0;
            end 
            partial_remainder = {{partial_remainder[23:0]}, {1'b0}};
        end
        state = 'b10001;
    end  
    'b10001:
    begin 
		//Normalizing the results for the defined leading "1" in IEEE format
		//Shifting left the mantissa and adjussting the expont while the last bit is "0"
        for(i_for = 12; i_for >= 11; i_for = i_for - 1)
        begin
            temp_remainder = partial_remainder - {{2'b01}, Input_2_mnt};
            if(temp_remainder[24] == 1'b0)
            begin 
                quotient[i_for] = 1'b1;
                partial_remainder = temp_remainder;
            end
            else
            begin
                quotient[i_for] = 1'b0;
            end 
            partial_remainder = {{partial_remainder[23:0]}, {1'b0}};
        end
        state = 'b10010;
    end
    'b10010: 
    begin 
		//Normalizing the results for the defined leading "1" in IEEE format
		//Shifting left the mantissa and adjussting the expont while the last bit is "0"
        for(i_for = 10; i_for >= 9; i_for = i_for - 1)
        begin
            temp_remainder = partial_remainder - {{2'b01}, Input_2_mnt};
            if(temp_remainder[24] == 1'b0)
            begin 
                quotient[i_for] = 1'b1;
                partial_remainder = temp_remainder;
            end
            else
            begin
                quotient[i_for] = 1'b0;
            end 
            partial_remainder = {{partial_remainder[23:0]}, {1'b0}};
        end
        state = 'b10011;
    end
    'b10011:
    begin 
		//Normalizing the results for the defined leading "1" in IEEE format
		//Shifting left the mantissa and adjussting the expont while the last bit is "0"
        for(i_for = 8;i_for >= 7;i_for = i_for - 1)
        begin
            temp_remainder = partial_remainder - {{2'b01}, Input_2_mnt};
            if(temp_remainder[24] == 1'b0)
            begin 
                quotient[i_for] = 1'b1;
                partial_remainder = temp_remainder;
            end
            else
            begin
                quotient[i_for] = 1'b0;
            end 
            partial_remainder = {{partial_remainder[23:0]}, {1'b0}};
        end
        state = 'b10100;
    end    
    'b10100:
    begin
		//Normalizing the results for the defined leading "1" in IEEE format
		//Shifting left the mantissa and adjussting the expont while the last bit is "0"
        for(i_for = 6;i_for >= 5;i_for = i_for - 1)
        begin
            temp_remainder = partial_remainder - {{2'b01}, Input_2_mnt};
            if(temp_remainder[24] == 1'b0 )
            begin 
                quotient[i_for] = 1'b1;
                partial_remainder = temp_remainder;
            end
            else
            begin
                quotient[i_for] = 1'b0;
            end 
            partial_remainder = {{partial_remainder[23:0]}, {1'b0}};
        end
        state = 'b10101;
    end
    'b10101:
    begin  
		//Normalizing the results for the defined leading "1" in IEEE format
		//Shifting left the mantissa and adjussting the expont while the last bit is "0"
        for(i_for = 4;i_for >= 3;i_for = i_for - 1)
        begin
            temp_remainder = partial_remainder - {{2'b01}, Input_2_mnt};
            if ( temp_remainder[24]==1'b0 )
            begin 
                quotient[i_for]=1'b1;
                partial_remainder = temp_remainder;
            end
            else
            begin
                quotient[i_for]=1'b0;
            end 
            partial_remainder = {{partial_remainder[23:0]}, {1'b0}};
        end
        state = 'b10110;
    end
    'b10110:
    begin  
		//Normalizing the results for the defined leading "1" in IEEE format
		//Shifting left the mantissa and adjussting the expont while the last bit is "0"
        for(i_for = 2; i_for >= 0; i_for = i_for - 1)
        begin
            temp_remainder = partial_remainder - {{2'b01}, Input_2_mnt};
            if(temp_remainder[24]==1'b0 )
            begin 
                quotient[i_for] = 1'b1;
                partial_remainder = temp_remainder;
            end
            else
            begin
                quotient[i_for]=1'b0;
            end 
            partial_remainder = {{partial_remainder[23:0]}, {1'b0}};
        end
        state = 'b10111;
    end
    'b10111:
    begin
        quotient = quotient + 1;		//round to nearest even
        if(quotient[25] == 1'b1)
        begin 
            Divider_Float_mnt = quotient[24:2];
        end
        else
        begin
            Divider_Float_mnt = quotient[23:1];
            temp_exp = temp_exp - 1;
        end
        state = 'b11000;
    end
    'b11000:
    begin
        if(temp_exp[8] == 1'b1)
        begin
            if(temp_exp[7] == 1'b1)		//underflow
            begin
                Divider_Float_exp = 'b0;
                Divider_Float_mnt = 'b0;
            end
            else						//overflow
            begin
                Divider_Float_exp = 'b11111111;
                Divider_Float_mnt = 'b0;
            end
        end    
        else
        begin
            Divider_Float_exp = temp_exp[7:0];
        end
        Divider_Float[31:0] = {{Divider_Float_sign}, {Divider_Float_exp}, {Divider_Float_mnt}};
		state = temp_state;
    end
    'b11000: //sin
    begin
        //t1 = Multiplier_Float (x, x); //x^2
        Input_1 = a_in;
        Input_2 = a_in;
        a_tmp = a_in;
        state = 'b101; //Multiplier
        temp_state = 'b11001;
    end
    'b11001:
    begin
        t1 = Multiplier_Float;
        //t2 = Multiplier_Float (t1, x); //x^3 t2
        Input_1 = t1;
        Input_2 = a_tmp;
        state = 'b101; //Multiplier
        temp_state = 'b11010;
    end
    'b11010:
    begin
        t2 = Multiplier_Float;
        //t3 = Multiplier_Float (t1, t2); //x^5
        Input_1 = t1;
        Input_2 = t2;
        state = 'b101; //Multiplier
        temp_state = 'b11011;
    end
    'b11011:
    begin
        t3 = Multiplier_Float;
        //t2 = Divider_Float(t2, 32'b01000000110000000000000000000000); //x^3 / 6
        Input_1 = t2;
        Input_2 = 32'b01000000110000000000000000000000;
        state = 'b1010; //Divider
        temp_state = 'b11100;
    end
    'b11100:
    begin
        t2 = Divider_Float;
        //t3 = Divider_Float(t3, 32'b01000010111100000000000000000000); //x^5 / 120
        Input_1 = t3;
        Input_2 = 32'b01000010111100000000000000000000;
        state = 'b1010; //Divider
        temp_state = 'b11101;  
    end
    'b11101:
    begin
        t3 = Divider_Float;
        //t1 = Subtractor_Float(x, t2); //x - x^3/6
        Input_1 = a_tmp;
        Input_2 = t2;
        state = 'b100; //Subtractor
        temp_state = 'b11110;
    end
    'b11110:
    begin
        t1 = Subtractor_Float;
        //sin = Adder_Float(t1, t3);
        Input_1 = t1;
        Input_2 = t3;
        state = 'b0; //Adder
        temp_state = 'b11111;
    end
    'b11111:
    begin
        sin = Adder_Float;
    end   
    endcase
    end //always
endmodule