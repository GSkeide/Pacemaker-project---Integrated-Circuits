`timescale 1ns/1ps
module tb_pacemaker;
   localparam real MS = 1.0e6;          // 1 ms in ns  
   
  reg  clk = 1'b0;
  reg  rst = 1'b1;
  reg  H   = 1'b0;
  integer errors = 0;
 
  wire P, R, nT, A, B;
  wire [9:0] count;
  wire T = ~nT;		
  
  reg  [9:0] expected_count;
 
   
   
     pacemaker_top dut (.P(P), .R(R), .nT(nT), .A(A), .B(B),
                     .count(count), .clk(clk), .rst(rst), .H(H));
   
   
   

	task reset_release;
  // Release reset	
  repeat (3) @(posedge clk);
  #10 rst <= 0;
endtask	  

   // 512 Hz clock: period = 1/512 s = 1 953 125 ns
  always #976562.5 clk = ~clk;
 
  // one heartbeat, H high for 20 ms
  task beat;
    begin
      H = 1'b1;
      #(20*MS);
      H = 1'b0;		 // heartbeat should reset counter
    end
  endtask

 always @(posedge clk)
    if (rst || R) expected_count <= 0;
    else          expected_count <= expected_count + 1;	//testbench counter on every positive edge. should count with timer count

  task check_count;
    begin
      if (rst || R) begin  // reset should set count to 0
        if (count !== 0) begin
          $display("T=%0t ERROR: count is %0d while cleared, expected 0",
                   $time, count);
          errors = errors + 1;
        end
      end else if (count !== expected_count) begin			// if tb count is not the same as timer count, error
        $display("T=%0t ERROR: count is %0d, expected %0d",
                 $time, count, expected_count);
        errors = errors + 1;
      end
    end
  endtask

  // checking count every falling edge since it will be stable then
  always @(negedge clk) check_count;

  initial begin
 
    reset_release;

    #(500*MS);  beat;                  // heartbeat after 0.5 s
    repeat (790) @(posedge clk); 
	
	@(negedge clk);						  // test if it can recover getting into a invalid state (11), should go back to idle (00).
    force dut.my_fsm.nextA = 1'b1;
    force dut.my_fsm.nextB = 1'b1;
    @(posedge clk);                     // flip-flops load 11 here
    #1000;                              // let them settle
    release dut.my_fsm.nextA;           // give control back to the logic
    release dut.my_fsm.nextB;
    repeat (900) @(posedge clk); 	// all states have been tested here, 00, 01, 10, 11		  

    $display("Test complete: %0d errors", errors);
    $finish;
  end

endmodule