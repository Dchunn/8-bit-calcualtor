`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/09/2017 11:43:00 AM
// Design Name: 
// Module Name: multiplexer
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


module multiplexer(
    input [15:0] sw,
    output [15:0] led
    );
    wire [7:0] p0;
    wire [8:0] p1;
    wire [9:0] p2;
    wire [10:0] p3;
    wire [11:0] p4;
    wire [12:0] p5;
    wire [13:0] p6;
    wire [14:0] p7;
    wire [7:0] a;
    wire [7:0] b;
    
    assign a = sw[7:0];
    assign b = sw[15:8];
    
    assign p0[7:0] = {8{a[0]}} & b[7:0];
    assign p1[8:0] = {({8{a[1]}} & b[7:0]), 1'h00};
    assign p2[9:0] = {({8{a[2]}} & b[7:0]), 2'h00};
    assign p3[10:0] = {({8{a[3]}} & b[7:0]), 3'h00};
    assign p4[11:0] = {({8{a[4]}} & b[7:0]), 4'h00};
    assign p5[12:0] = {({8{a[5]}} & b[7:0]), 5'h00};
    assign p6[13:0] = {({8{a[6]}} & b[7:0]), 6'h00};
    assign p7[14:0] = {({8{a[7]}} & b[7:0]), 7'h00};
    assign led[15:0] = p0+p1+p2+p3+p4+p5+p6+p7; 
endmodule
