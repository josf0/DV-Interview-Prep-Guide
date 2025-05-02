/*
Question:
What is gray code and 8b10b encoding, and why they are useful
*/

/*
Answer:
Gray code is a binary numeral system where only one bit changes between successive values.

  Why is it useful?
	•	Used in asynchronous FIFOs and clock domain crossing to avoid glitches during transition.
	•	In regular binary, multiple bits might change at once (e.g., 011 → 100 changes 3 bits), leading to metastability issues.
	•	Gray code reduces this risk because only one bit flips at a time, making it easier to synchronize safely between different clock domains.

8b/10b encoding maps 8 bits of data to a 10-bit transmission code.
	•	Used in high-speed serial protocols like PCIe, SATA, USB 3.0, etc.
	•	Ensures:
	•	DC balance (equal 1s and 0s over time)
	•	Enough transitions for the receiver to recover the clock (clock/data recovery)

  Why is it useful?
	•	Prevents long runs of 0s or 1s → helps with clock synchronization.
	•	Maintains a neutral average voltage level → DC balance is important for signal integrity.
	•	Adds special control characters in the extra 2 bits (e.g., for start-of-frame, end-of-frame, idle).
*/

/////////////////////////////////////////////////////////////////////////////////

/*
Q: How would you describe clock domain crossing and its associated challenges?


Clock Domain Crossing refers to transferring data or control signals between two asynchronous clock domains.
The main challenges are metastability, data corruption, and glitches.
Common solutions include 2-FF synchronizers for single-bit signals, handshake protocols, and asynchronous FIFOs for multi-bit data.
CDC verification involves formal tools, assertions, and corner-case simulations.

A signal (async_signal) is toggled in one domain (clk_src, ~71 MHz).
	•	It’s safely synchronized into another clock domain (clk_dest, 50 MHz).
	•	You’ll observe sync_signal changing with a couple of cycle delays — this is intentional, due to the 2-FF sync.
*/

//-------------------------------------
// cdc_sync.v - 2-FF Synchronizer Module
//-------------------------------------
module cdc_sync (
  input  logic clk_dest,
  input  logic async_signal,
  output logic sync_signal
);
  logic sync_ff1, sync_ff2;

  always_ff @(posedge clk_dest) begin
    sync_ff1 <= async_signal;
    sync_ff2 <= sync_ff1;
  end

  assign sync_signal = sync_ff2;
endmodule
