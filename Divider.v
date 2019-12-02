`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/11/2018 02:34:42 PM
// Design Name: 
// Module Name: Divider
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

module Divider(
		input clock,
		input [31:0] Input_1,
		input [31:0] Input_2,
		output reg [31:0] Divider_Float
    );
    
    reg [22:0] Input_1_mnt, Input_2_mnt, Divider_Float_mnt;
    reg [7:0] Input_1_exp, Input_2_exp, Divider_Float_exp;
    reg Input_1_sign, Input_2_sign, Divider_Float_sign;
    reg [24:0] partial_remainder, temp_remainder;
    reg [8:0] temp_exp; 
    reg [25:0] quotient;
    
    integer i_for;
    
    reg [8:0] state = 'b0;
        
    always @(posedge clock)
    begin
    case (state)
	'b0:
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
        state = 'b1;
    end
    'b1: 
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
        state = 'b10;
    end
    'b10:
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
        state = 'b11;
    end
    'b11:
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
        state = 'b100;
    end    
    'b100:
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
        state = 'b101;
    end
    'b101:
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
        state = 'b110;
    end
    'b110: 
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
        state = 'b111;
    end  
    'b111:
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
        state = 'b1000;
    end
    'b1000: 
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
        state = 'b1001;
    end
    'b1001:
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
        state = 'b1010;
    end    
    'b1010:
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
        state = 'b1011;
    end
    'b1011:
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
        state = 'b1100;
    end
    'b1100:
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
        state = 'b1101;
    end
    'b1101:
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
        state = 'b1110;
    end
    'b1110:
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
    end
    endcase
    end
endmodule