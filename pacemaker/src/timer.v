`timescale 1ns/1ps
module timer (output nT, output [9:0] q, input clk, input R, input rst); // R = from FSM, rst = global reset
  wire       clr_n;
  wire [9:0] qn; // not used outside the timer so
 
  nor2 u_clr (clr_n, R, rst);
 
  dff ff0 (.q(q[0]), .qn(qn[0]), .d(qn[0]), .clk(clk),   .clr_n(clr_n));
  dff ff1 (.q(q[1]), .qn(qn[1]), .d(qn[1]), .clk(qn[0]), .clr_n(clr_n));
  dff ff2 (.q(q[2]), .qn(qn[2]), .d(qn[2]), .clk(qn[1]), .clr_n(clr_n));
  dff ff3 (.q(q[3]), .qn(qn[3]), .d(qn[3]), .clk(qn[2]), .clr_n(clr_n));
  dff ff4 (.q(q[4]), .qn(qn[4]), .d(qn[4]), .clk(qn[3]), .clr_n(clr_n));
  dff ff5 (.q(q[5]), .qn(qn[5]), .d(qn[5]), .clk(qn[4]), .clr_n(clr_n));
  dff ff6 (.q(q[6]), .qn(qn[6]), .d(qn[6]), .clk(qn[5]), .clr_n(clr_n));
  dff ff7 (.q(q[7]), .qn(qn[7]), .d(qn[7]), .clk(qn[6]), .clr_n(clr_n));
  dff ff8 (.q(q[8]), .qn(qn[8]), .d(qn[8]), .clk(qn[7]), .clr_n(clr_n));
  dff ff9 (.q(q[9]), .qn(qn[9]), .d(qn[9]), .clk(qn[8]), .clr_n(clr_n));
 
  nand2 nT_gate (nT, q[8], q[9]);
endmodule
