`timescale 1ns/1ps
module tb_pacemaker;
   localparam real MS = 1.0e6;          // 1 ms in ns  
   
  reg  clk = 1'b0;
  reg  rst = 1'b1;
  reg  H   = 1'b0;
  integer errors = 0;  
  integer paces_seen = 0;
 
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
  repeat (2) @(negedge clk);
  if (count == 0)
	  $display("PASS: Heartbeat reset count to 0.");
  else begin
	  $display("FAIL: Heartbeat did not reset count. Count is still %0d", count);
	  errors = errors + 1;
  end;	
  #(20*MS - 2*1953125); // task beats for 20 ms
  H = 1'b0;		 // heartbeat should reset counter	 
  @(posedge clk); // Reset state, so count is 0 here and starts counting up
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
  
  
  
task expect_pace(); // Test pacing when timer exceed 768. Should give a 2 ms pace pulse.
begin		  
    $display("Values before expect_pace() : State = %b%b, Pace = %0d, Reset = %0d, Count = %0d", A,B, P, R, count);
    repeat (768) @(posedge clk); // T = 1: if cycles = 768 or more	 	 			   
    paces_seen = 0;
    if (P == 1) paces_seen = paces_seen + 1;
	if (count == 768)
		$display("PASS: expect_pace() - Count is %0d; Expected: 768.", count);	  
	else begin			 
		$display("FAIL: expect_pace() - Count is %0d; Expected: 768.",count);
		errors = errors + 1;
	end
	@(posedge clk);
	if (P == 1) paces_seen = paces_seen + 1;
	@(posedge clk);
	if (P == 1) paces_seen = paces_seen + 1;
	if (({A,B} === 2'b01) && (R == 1)) // if stage is idle stage, correct!
		$display("PASS: expect_pace() - Finished pacing and is now in the reset state. State is %b%b, Reset = 1, count = %0d", A,B, count);	
	else begin			 
		$display("FAIL: expect_pace() - Expected Reset pulse here. State = %b%b, Pace = %0d, Reset = %0d, Count = %0d",A,B, P, R, count);
		errors = errors + 1;
	end
	if (paces_seen == 1)
		$display("PASS: expect_pace() - Pace pulse lasted 2 ms");
	else begin
		$display("FAIL: expect_pace() - Pace pulse lasted %0d ms", paces_seen*2);
		errors = errors + 1;
	end
  end
endtask
  
task invalidState11();
begin
    @(negedge clk);						  // test if it can recover getting into a invalid state (11), should go back to idle (00).
    force dut.my_fsm.nextA = 1'b1;
    force dut.my_fsm.nextB = 1'b1; 
    @(posedge clk);                     // flip-flops load 11 here			
    #1000;                              // let them settle	
	if ({A, B} === 2'b11)
		$display("PASS: invalidstate11() - State was succesfully forced to = %b%b, Timer = %0d", A, B, count);
	else begin
		$display("FAIL: invalidstate11() - Unable to force state to 11. State = %b%b, R = %0d", A, B, R);
		errors = errors + 1;
	end
	if (count == 0) 		  
		$display("PASS: invalidstate11() - The invalid state (11) succesfully resets count to 0. R = %0d", R);	
	else begin
		$display("FAIL: invalidstate11() - The invalid state (11) did not trigger reset to the counter! Count = %0d. R = %0d", count, R);
	    errors = errors + 1;
	end
    release dut.my_fsm.nextA;           // give control back to the logic
    release dut.my_fsm.nextB;			// Should reset counter and go back to state 00 automaticly.	
	@(posedge clk);                     // flip-flops load 00 here			
    #1000;                              // let them settle	
	if ({A, B} === 2'b00)
		$display("PASS: invalidstate11() - State was automaticly sent back to 00 after being in the invalid state");	 
	else begin
		$display("FAIL: invalidstate11() - State was not sent back to IDLE (00)!! State = %b%b, R = %0d", A, B, R);
		errors = errors + 1;
	end
end 
endtask
	  

  initial begin
 
    reset_release;

    #(150*MS);  beat;                  // heartbeat after 0.15 s	 
	
    expect_pace(); 					   // Test pacing by letting timer exceed 768  
	@(posedge clk);					   
	@(posedge clk);
	invalidState11;
	
    repeat (900) @(posedge clk);	  

    $display("Test complete: %0d errors", errors);
    $finish;
  end

endmodule