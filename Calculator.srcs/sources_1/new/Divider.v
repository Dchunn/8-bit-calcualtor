`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/27/2017 11:36:27 AM
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
    input clk,
    input [15:0]sw,
    input btnC,
   output reg [7:0] Q,
   output reg [7:0] R,
   output wire [6:0] seg,
   output dp,
   output [3:0] an
   );
    
    parameter Init = 2'b00;
    parameter SL   = 2'b01;
    parameter LD   = 2'b10;
    parameter Done = 2'b11;

   // reg [7:0] Q;
   // reg [7:0] R;
    reg [7:0] D;
    reg [1:0] state, next_state;
    reg [3:0] C;
    reg Init_Reg, EN_SL, EN_LD, Sel_Diff, EN_SQ;

    wire N_GTE_D; //Numerator greater than equal to denominator
    wire [7:0] Diff;
    wire [7:0] T;
    wire [15:0] divide;
    assign divide = {8'h00, Q} ;
    ssegx4top V (.sw(divide), .clk(clk), .seg(seg), .an(an), .dp(dp));

initial state = 2'b11;
  always @ (posedge clk)
  begin
    state <= next_state;
  end
//Given Code
always @ (state, btnC, N_GTE_D, C)
  begin
  	case (state)
  		Init:
  		begin     
  		      if (!btnC && !N_GTE_D)           next_state = SL;
  		      else if (!btnC && N_GTE_D)             next_state = LD;
  		      else next_state = Init; 
        end
  		
  		SL:
  		begin
  		      if (!N_GTE_D && C!=4'b0000) next_state = SL;
  		      else if (!N_GTE_D && C==4'b0000) next_state = Done;
  		      else if (N_GTE_D  && C!=4'b0000) next_state = LD;
  		      else if (N_GTE_D  && C==4'b0000) next_state = Done;
  		      else next_state = Done; 
  		      end
  		
  		LD:
  		begin
  		         if (!N_GTE_D && C!=4'b0000) next_state = SL;  
  		      else if (!N_GTE_D && C==4'b0000) next_state = Done;
  		      else if (N_GTE_D  && C!=4'b0000) next_state = LD;  
  		      else if (N_GTE_D  && C==4'b0000) next_state = Done;
  		      else next_state = Done;
  		end      
  		
  		Done:
  		begin
  		   if (!btnC) next_state = Done;
  		      else next_state = Init;
  		      end
  	endcase
  end

  always @ (next_state)
  begin
  	case (next_state)
  		Init:     begin  Init_Reg = 1'b1; EN_SL = 1'b0; EN_LD = 1'b1; Sel_Diff = 1'b0; EN_SQ = 1'b0; end
   		SL:       begin  Init_Reg = 1'b0; EN_SL = 1'b1; EN_LD = 1'b0; Sel_Diff = 1'b0; EN_SQ = 1'b1; end
  		LD:      begin  Init_Reg = 1'b0; EN_SL = 1'b0; EN_LD  = 1'b1; Sel_Diff = 1'b1; EN_SQ = 1'b1; end
  		Done: begin  Init_Reg = 1'b0; EN_SL  = 1'b0; EN_LD = 1'b0; Sel_Diff = 1'b0; EN_SQ = 1'b0; end
  	endcase
  end
//Mux
always @ (posedge clk)
  begin
    if (EN_LD && !Sel_Diff) R <= 8'h00;
    else if (EN_LD && Sel_Diff) R <= Diff;
    else if (EN_SL) R <= {R[6:0], Q[7]};
    else R <= R;
  end
//setting up the remainder
      always @ (posedge clk)
          begin
              if (EN_LD && !Sel_Diff) //set to 0
                  R <= 8'h00; 
              else if (EN_LD && Sel_Diff) //use Diff if subraction is possible
                  R <= Diff;
              else if (EN_SL) //shift quotient MSB in
                  R <= {R[6:0], Q[7]};
              else //stay the same 
                  R <= R;
          end
      
      //setting up the Dividend and Quotient
      always @ (posedge clk)
          begin
              if (Init_Reg) //get data from switches
                  Q <= sw[7:0];
              else if (EN_SQ) //shift in N_GTE_D
                  Q <= {Q[6:0], N_GTE_D};
              else //stay the same
                  Q <= Q;
          end
  
      //Divisor Register
      always @ (posedge clk)
          begin
              if (Init_Reg) //get data from switches
                  D <= sw[15:8];
              else //stay the same 
                  D <= D;
          end
      
      //count down
      always @ (posedge clk)
          begin
              if (Init_Reg)
                  C <= 4'h8; // start at 8
              else if (C != 0)
                  C <= C - 1; //decrement
          end
  
      //adder
      assign {N_GTE_D, Diff} = {R[6:0], Q[7]} + T[7:0]; //N_GTE_D gets the overflow bit if negative
      assign T = ~D[7:0] + 1; //create 2's compliment of D (Divisor)


endmodule
