`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    15:31:35 06/09/2021 
// Design Name: 
// Module Name:    Final_project 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module Final_p(quotient, remainder, reg_remainder, rowk, columnk, equal, clk, rst);


output[15:0] quotient,remainder;			//商+餘數
output[31:0] reg_remainder;

input equal,clk,rst;
input[3:0] rowk, columnk;

wire[3:0] value;
wire[15:0] dividend, divisor;
wire enable;



keypad keypad_main(value ,enable ,rowk ,columnk ,clk ,rst);
FSM FSM_main(dividend, divisor, enable, value, clk, rst);
divider divider_main(dividend, divisor, quotient,remainder,reg_remainder, clk, rst, equal);

endmodule
//=======================value in==========================//
module FSM(out_dividend, out_divisor, keyevent, keyvalue, clk, rst);
output reg [15:0] out_dividend, out_divisor ;
input[3:0]keyvalue;
input keyevent,clk,rst;

reg[3:0]state;
reg[4:0]keycount;

reg[3:0]buffer[7:0];


integer i ;

parameter init 		= 2'd0;
parameter waitkey 	= 2'd1;
parameter checkinput = 2'd2;
parameter out_value	= 2'd3;


//meely
always@(posedge clk or posedge rst)begin
	if(rst)begin
		state <= init;
		keycount <= 4'd0;
		for(i = 0;i<8;i = i+1)
			buffer[i]<=4'd0;
	end
	
	else begin
		case(state)
			init:begin
					state<=waitkey;
				end
				
			waitkey:begin
				if(keyevent)begin
					buffer[keycount] <= keyvalue;
					keycount <= keycount+1;
					state<=checkinput;
				end
				else
					state <= waitkey;
			end
					
			checkinput:begin
				if(keycount < 4'd8 && ~keyevent)
					state<=waitkey;
				else if(keycount == 4'd8)begin
					state<=out_value;
					keycount <= 4'd0;
				end
				else
					state<=checkinput;
				end
				
			out_value:begin
				out_dividend <= {buffer[0],buffer[1],buffer[2],buffer[3]};
				out_divisor <= {buffer[4],buffer[5],buffer[6],buffer[7]};
				end
			default:begin
				keycount <= 4'd0;
				out_dividend <= 16'd0;
				out_divisor	<= 16'd0;
			end
		endcase
	end
end
endmodule

//========================keypad===========================//

module keypad(value ,enable ,rowk ,columnk ,clk ,rst);
output reg[3:0] value;
output reg enable;
input [3:0] rowk,columnk;
input clk,rst;

always@(posedge clk or posedge rst)
begin
	if(rst)begin
		value <= 4'd0;
		enable <= 1'd0;
	end
	else begin
		case(rowk)
		4'd8:begin
			case(columnk)
				4'd8:begin value<=4'd15; enable<=1; end
				4'd4:begin value<=4'd14; enable<=1; end
				4'd2:begin value<=4'd13; enable<=1; end
				4'd1:begin value<=4'd12; enable<=1; end
				default:begin value<=4'd0; enable<=0; end
			endcase
		end
		4'd4:begin
			case(columnk)
				4'd8:begin value<=4'd11; enable<=1; end
				4'd4:begin value<=4'd10; enable<=1; end
				4'd2:begin value<=4'd0; enable<=1; end
				4'd1:begin value<=4'd9; enable<=1; end
				default:begin value<=4'd0; enable<=0; end
			endcase
		end
		4'd2:begin
			case(columnk)
				4'd8:begin value<=4'd8; enable<=1; end
				4'd4:begin value<=4'd7; enable<=1; end
				4'd2:begin value<=4'd6; enable<=1; end
				4'd1:begin value<=4'd5; enable<=1; end
				default:begin value<=4'd0; enable<=0; end
			endcase
		end
		4'd1:begin
			case(columnk)
				4'd8:begin value<=4'd4; enable<=1; end
				4'd4:begin value<=4'd3; enable<=1; end
				4'd2:begin value<=4'd2; enable<=1; end
				4'd1:begin value<=4'd1; enable<=1; end
				default:begin value<=4'd0; enable<=0; end
			endcase
		end
		default:
			begin
				value<=value;
				enable<=0;
			end
		endcase
	end
end

endmodule


module divider(dividend, divisor, quotient,remainder,reg_remainder, clk, rst, equal);

input clk,rst,equal;
input [15:0] divisor;								//除數
input [15:0] dividend;								//被除數

output reg[15:0] quotient,remainder;			//商+餘數

output reg[31:0] reg_remainder;
//reg signed[31:0] reg_remainder;					//16_0+16被除數=>16餘數+16商

reg[3:0] c_state;
reg[4:0] counter_r;

parameter Idle          =4'd0;
parameter Set				=4'd1;
parameter Prepare			=4'd2;
parameter SUB           =4'd3;
parameter Control_R0_S	=4'd4;
parameter ADD           =4'd5;
parameter Control_R0_A	=4'd6;
parameter Finish        =4'd7;
parameter Load        	=4'd8;


//=======================state=============================//
always@(posedge clk or posedge rst)begin
	if(rst)
		c_state<=Idle;
		
	else begin
		case(c_state)
			Idle:begin	
				if(equal)
					c_state <= Set;
				else
					c_state <= c_state;
			end
			
			Set:begin	
				c_state <= Prepare;
			end
			
			Prepare:begin
				c_state <= SUB;
			end
			
			SUB:begin
				if(reg_remainder[31])
					c_state <= ADD;
				else
					c_state <= Control_R0_S	;
			end	
			
			Control_R0_S:begin
				if(counter_r == 16)
					c_state <= Finish;
				else
					c_state <= SUB;
			
			end
			
			ADD:begin
				c_state <= Control_R0_A;
			end
			
			Control_R0_A:begin
				if(counter_r == 16)
					c_state <= Finish;
				else
					c_state <= SUB;
			end
			
			Finish:begin
					c_state <= Load;
			end
			
			Load:begin
				if(~equal)
					c_state <= Idle;
				else
					c_state <= c_state;
			end
			
			default: c_state <= Idle;
			
		endcase
	end
		
end

//===================value======================//

always@(c_state)begin
	case(c_state)
		
		Idle:begin	
			reg_remainder <= 32'd0;
			counter_r <= 5'd0;
			remainder <= 16'd0;
			quotient <= 16'd0;
		end
		
		Set:begin	
			reg_remainder <= reg_remainder + dividend;
		end

		Prepare:begin
			reg_remainder <= reg_remainder<<1;
		end
		
		SUB:begin
			reg_remainder[31:16] <= reg_remainder[31:16] - divisor;				
		end
		
		Control_R0_S:begin
			reg_remainder <= {reg_remainder[30:0] , 1'b1};
			counter_r <= counter_r + 1;
		end
		
		ADD:begin
			reg_remainder[31:16] <= reg_remainder[31:16] + divisor;
		end
		
		Control_R0_A:begin
			reg_remainder <= {reg_remainder[30:0] , 1'b0};
			counter_r <= counter_r + 1;
		end
		
		Finish:begin
			reg_remainder[31:16] <= reg_remainder[31:16]>>1;
		end
		
		Load:begin
			remainder <= reg_remainder[31:16];
			quotient <= reg_remainder[15:0];
		end
		
		default:begin
			remainder <= 16'd0;
			quotient <= 16'd0;
		end
	endcase

end
endmodule



