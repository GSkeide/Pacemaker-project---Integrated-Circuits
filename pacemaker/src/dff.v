`timescale 1ns/1ps
module dff (output q, output qn, input d, input clk, input clr_n);
  wire p1, p2, p3, p4;
 
  nand2 g1 (p3, p4,  p1);
  nand3 g2 (p1, clk, p3, clr_n);
  nand3 g3 (p2, clk, p1, p4);
  nand3 g4 (p4, d,   p2, clr_n);  
  nand2 g5 (q,  p1,  qn);
  nand3 g6 (qn, q,   p2, clr_n);
endmodule
