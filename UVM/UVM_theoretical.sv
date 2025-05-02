/*
Q: How do predictor, monitor, and scoreboard work together in UVM?

A:

The driver sends input to the DUT.
The predictor taps into the same input and models what the DUT should do, sending expected results to the scoreboard. 
Meanwhile, the monitor observes the DUT’s output from the interface and sends actual transactions to the scoreboard. 
The scoreboard then compares expected vs actual to detect mismatches.

*/

/*
Q: Could you explain the objection mechanism in UVM and the process to conclude a test?

UVM uses an objection mechanism to control when simulation phases (like run_phase) end.
Components raise objections when they need simulation time, and drop them when done.
The phase continues running until all objections are dropped, making it a clean way to synchronize activity in large testbenches.

*/

/*
Q: create() vs new()

🧠 Summary (Short Points)
	•	create() enables use of UVM factory
	•	Factory allows dynamic overrides without changing source
	•	new() does not support factory override — less flexible
	•	create() supports testbench reuse, configurability, and scalability
*/
