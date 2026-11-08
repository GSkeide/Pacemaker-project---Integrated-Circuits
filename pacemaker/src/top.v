`timescale 1ns/1ps

module pacemaker_top (output P, output R, output nT,
                      output A, output B, output [9:0] count,
                      input clk, input rst, input H);
  wire rst_n;
 
  inv rst_inverter (rst_n, rst);
 
  timer my_timer (.nT(nT), .q(count), .clk(clk), .R(R), .rst(rst));
 
  fsm   my_fsm   (.P(P), .R(R), .A(A), .B(B),
                  .clk(clk), .rst_n(rst_n), .H(H), .nT(nT));
endmodule
