`timescale 1ns/1ps

// invertert usage: y = inv(a) 	   
// used for inputs to the static cmos gates. Derive not(A) and not(H)
module inv (output y, input a);
  supply1 vdd;
  supply0 gnd;
  pmos #1 mp (y, vdd, a);
  nmos #1 mn (y, gnd, a);
endmodule


// nand2, used for timer output with Q8,Q9 as input.
// also used in general for creating the flipflops.
module nand2 (output y, input a, input b);
  supply1 vdd;
  supply0 gnd;
  wire x;
  pmos #1 mpa (y, vdd, a);
  pmos #1 mpb (y, vdd, b);
  nmos #1 mna (y, x,   a);
  nmos    mnb (x, gnd, b);
endmodule

//nand3, used for the flipflops	
module nand3 (output y, input a, input b, input c);
  supply1 vdd;
  supply0 gnd;
  wire x1, x2;
  pmos #1 mpa (y,  vdd, a);
  pmos #1 mpb (y,  vdd, b);
  pmos #1 mpc (y,  vdd, c);
  nmos #1 mna (y,  x1,  a);
  nmos    mnb (x1, x2,  b);
  nmos    mnc (x2, gnd, c);
endmodule


// nor2 P
module nor2 (output P, input nA, input B);
  supply1 vdd;
  supply0 gnd;
  wire x;
  pmos #1 mpb (P, x,   B);
  pmos    mpa (x, vdd, nA);
  nmos #1 mna (P, gnd, nA);
  nmos #1 mnb (P, gnd, B);
endmodule


//NEXT_A a nor4
module next_a (output NEXT_A, input nT, input H, input B, input A);
  supply1 vdd;
  supply0 gnd;
  wire x1, x2, x3;
  pmos #1 mpa (NEXT_A,  x1,  A);
  pmos    mpb (x1, x2,  B);
  pmos    mph (x2, x3,  H);
  pmos    mpt (x3, vdd, nT);
  nmos #1 mnt (NEXT_A, gnd, nT);
  nmos #1 mnh (NEXT_A, gnd, H);
  nmos #1 mnb (NEXT_A, gnd, B);
  nmos #1 mna (NEXT_A, gnd, A);
endmodule



// NEXT_B
module next_b (output NEXT_B, input nH, input nA, input B);
  supply1 vdd;
  supply0 gnd;
  wire xn, xp;
  nmos #1 mnb (NEXT_B, gnd, B);
  nmos #1 mnh (NEXT_B, xn,  nH);
  nmos    mna (xn,     gnd, nA);
  pmos #1 mpb (NEXT_B, xp,  B);
  pmos    mph (xp,     vdd, nH);
  pmos    mpa (xp,     vdd, nA);
endmodule
