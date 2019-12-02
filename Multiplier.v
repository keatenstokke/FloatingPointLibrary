`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/11/2018 02:34:42 PM
// Design Name: 
// Module Name: Multiplier
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

module Multiplier(
		input clock,
		input [31:0] Input_1,
		input [31:0] Input_2,
		output reg [31:0] Multiplier_Float    
	);
    
    reg Input_1_sign, Input_2_sign, Multiplier_Float_sign;
    reg [7:0] Input_1_exp, Input_2_exp, Multiplier_Float_exp;
    reg [23:0] Input_1_mnt, Input_2_mnt;
    reg [47:0] Multiplier_Float_mnt, temp_mnt;
	
    integer i_for;
	
    reg [2:0] state = 'b1000110;
    
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
        Input_1_mnt[22:0] = Input_1[22:0];
        Input_2_mnt[22:0] = Input_2[22:0];
		// +1 is for taking into account the leading zeros, 
		// - 126 is -127 + 1
        Multiplier_Float_exp = Input_1_exp + Input_2_exp;
        Multiplier_Float_exp = Multiplier_Float_exp - 8'b01111110;		
        state = 'b1;
    end
    'b1:
    begin
        if (Input_1 != 0 || Input_2 != 0)
        begin
            temp_mnt = Input_1_mnt * Input_2_mnt;	//Mantissa multiplicaiton
            Multiplier_Float_mnt = temp_mnt[47:24];
        end
        state = 'b10;
    end
    'b10:
    begin
        if(Multiplier_Float_mnt == 0)
        begin
            Multiplier_Float = 32'b0;
			//Skip multiplication to the end
            state = 'b100;
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
            state = 'b11;
        end
    end
    'b11:
    begin
        //Normalizing the results for the defined leading "1" in IEEE format
		//Shifting left the mantissa and adjussting the expont while the last bit is "0"
        for(i_for = 12; i_for < 23; i_for = i_for + 1)
            if (Multiplier_Float_mnt[23] == 0)
            begin
                Multiplier_Float_mnt = Multiplier_Float_mnt << 1;
                Multiplier_Float_exp = Multiplier_Float_exp - 1;
            end
        state = 'b100;
    end
    'b100:
    begin
        Multiplier_Float_sign = Input_1_sign ^ Input_2_sign;	//Sign Calculation
        if(Input_1[30:0] == 31'b0 || Input_2[30:0] == 31'b0) 	//If any of inputs is 0, output is 0
            Multiplier_Float = 32'b0;
        else
            Multiplier_Float = {sign, Multiplier_Float_exp, Multiplier_Float_mnt[22:0]};
    end
    endcase 
    end
endmodule