/*
Q: How would you design an SVA in System Verilog to verify a signal switches from 0 to 1 prior to another signal's transition from 1 to 0?
*/

assert property (@(posedge clk) disable iff(rst) 
    (sig1 == 0 && sig2 == 1) |=> ##[0:$] (sig1 == 1) ##[0:$] (sign2 == 0)
);

/*
“On every rising edge of clk, as long as rst is not asserted,
if sig1 is 0 and sig2 is 1,
then eventually (sig1 == 1) must happen (after 0 or more cycles),
and after that, eventually (sign2 == 0) must happen (after 0 or more cycles).”
*/

/////////////////////////////////////////////////////////////////////////////

/*
Q:What's the importance of using assertions?

Assertions are statements in SystemVerilog that verify that something must always (or never) happen in your design.
 If the assertion fails, it flags an error during simulation or formal verification.

 Assertions are like embedded runtime rules that help you:
	•	Catch bugs
	•	Check protocol/timing
	•	Document expectations
	•	Improve verification quality
*/

/////////////////////////////////////////////////////////////////////////////


//Q: When write address channel is completed, next clock cycle write data started or not

assert property (@(posedge clk) disable iff(rst) (awvalid == 1 && awready == 1) |-> ##[0:$] (wvalid == 1));

//Q: bvalid must eventually come after wlast

assert property (@(posedge clk) disable iff(rst) (wlast == 1) |=> ##[0:$] (bready == 1'b1));

//Q: when response comes then master must be ready to accept it

assert property (@(posedge clk) disable iff(rst) (bvalid) |-> bready);

//Q: If streched_scl goes low, it must eventually go high again (i.e., slave must not stretch forever).

assert property (@(posedge clk) disable iff(rst) streched_scl == 0 |=> ##[0:$] streched_scl == 1);


////////////////////////////////////////////////////////////

//Q: full and empty condition assertions in FIFO

//full
assert property (@(posedge clk) (wptr_gray[3] != rptr_sync[3]) && (wptr_gray[2:0] == rptr_sync[2:0]) |-> (wfull == 1'b1));

//empty condition assertion
assert property (@(posedge clk) (wptr_sync == rptr_gray) |-> (rempty == 1'1b));

//////////////////////////////////////////////////////////////

//Q: assertions in APB

assert property (@(posedge PCLK) disable iff(!PRESETn) (PSEL && PENABLE) |=> PREADY);

//if pready is low penable must remain high until pready is high

assert property (@(posedge PCLK) disable iff(!PRESETn) (PSEL && PENABLE && !PREADY) |=> PENABLE);