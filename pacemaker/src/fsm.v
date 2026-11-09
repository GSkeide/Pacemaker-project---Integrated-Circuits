`timescale 1ns/1ps

module fsm (output P, output R, output A, output B,
            input clk, input rst_n, input H, input nT);
  wire nA, nB, nH;
  wire nextA, nextB;
  

  dff ffA (.q(A), .qn(nA), .d(nextA), .clk(clk), .clr_n(rst_n));
  dff ffB (.q(B), .qn(nB), .d(nextB), .clk(clk), .clr_n(rst_n));
 
  inv   my_inverter (nH, H);
 

  nor2 my_p_gate (.P(P), .nA(nA), .B(B));
 
  next_a my_a_gate (.NEXT_A(nextA), .nT(nT), .H(H), .B(B), .A(A));
 
 	next_b my_b_gate (.NEXT_B(nextB), .A(A), .nA(nA), .nH(nH), .B(B));											
  assign R = B;
endmodule
