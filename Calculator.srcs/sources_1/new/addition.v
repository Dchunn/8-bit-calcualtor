`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/06/2017 10:21:35 AM
// Design Name: 
// Module Name: addition
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


module addition(
    input [7:0] num1,
    input [7:0] num2,
    output [15:0] out
    );
    //still need to delay the output
    assign out = num1 + num2;
    
endmodule
