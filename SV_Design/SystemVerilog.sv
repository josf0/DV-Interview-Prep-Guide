// ====================================
// 1. FSM Design - Moore and Mealy FSM
// ====================================

// Moore FSM: Sequence Detector for "101"
module moore_fsm(input logic clk, reset, data_in, output logic seq_detected);
    typedef enum logic [1:0] {IDLE, S1, S10, S101} state_t;
    state_t state, next_state;

    always_ff @(posedge clk or posedge reset) begin
        if (reset)
            state <= IDLE;
        else
            state <= next_state;
    end

    always_comb begin
        case (state)
            IDLE: next_state = data_in ? S1 : IDLE;
            S1:   next_state = data_in ? S1 : S10;
            S10:  next_state = data_in ? S101 : IDLE;
            S101: next_state = data_in ? S1 : IDLE;
            default: next_state = IDLE;
        endcase
    end

    assign seq_detected = (state == S101);
endmodule

// Mealy FSM: Sequence Detector for "110"
module mealy_fsm(input logic clk, reset, data_in, output logic seq_detected);
    typedef enum logic [1:0] {IDLE, S1, S11} state_t;
    state_t state, next_state;

    always_ff @(posedge clk or posedge reset) begin
        if (reset)
            state <= IDLE;
        else
            state <= next_state;
    end

    always_comb begin
        case (state)
            IDLE: next_state = data_in ? S1 : IDLE;
            S1:   next_state = data_in ? S11 : IDLE;
            S11:  next_state = data_in ? S11 : IDLE;
            default: next_state = IDLE;
        endcase
    end

    assign seq_detected = (state == S11 && !data_in);
endmodule

// ==============================
// 2. Divide-by-2 Clock Generator
// ==============================

module divide_by_2(input logic clk, reset, output logic clk_out);
    always_ff @(posedge clk or posedge reset) begin
        if (reset)
            clk_out <= 0;
        else
            clk_out <= ~clk_out;  // Toggle FF behavior
    end
endmodule

// ==============================
// 3. sequence detector Mealy
// ==============================

module sequence_detector(
    input logic clk,
    input logic reset,
    input logic data_in,
    output logic out
    );
    //state encoding
    typedef enum logic [1:0] {IDLE, S1, S11, S110} state_t;

    state_t state, next;

    always_ff @(posedge clk or posedge reset) begin
        if(reset) state <= IDLE;
        else state <= next;
    end

    always_comb begin
        next = IDLE;
        out = 0;
        case(state)
            IDLE: begin
                next = (data_in == 1) ? S1: IDLE;
            end

            S1: begin
                next = (data_in == 1) ? S11: IDLE;
            end

            S11: begin
                next = (data_in == 1) ? S11 : S110;
            end

            S110: begin
                next = (data_in == 1) ? S1 : IDLE;
                out = data_in ? 1: 0;
            end
            default: begin
                next = IDLE;
                out = 0;
            end
        endcase
    end
endmodule

// ==============================
// 7. sequence detector Moore
// ==============================

module sequence_detector (
    input logic clk,
    input logic reset,
    input logic data_in,
    output logic out
    );

    typedef enum logic [2:0] {IDLE, S1, S11, S110, S1101} state_t;

    state_t state, next;

    always_ff @(posedge clk) begin
        if(reset) state <= IDLE;
        else state <= next;
    end

    always_comb begin
        next = IDLE;
        case(state)
            IDLE: next = (data_in) ? S1: IDLE;

            S1: next = (data_in) ? S11 : IDLE;

            S11: next = (data_in) ? S11 : S110;

            S110: next = (data_in) ? S1101 : IDLE;

            default: next = IDLE;
        endcase
    end

    assign out = (state == S1101);
endmodule


///////////////////////////////////////////////////////////////////////////////

//Q: design question - design a system to identify if input bitstream is divisible by 5 - taking a 16bit stream

module div_by_5();
	logic [15:0] number;

	always_ff @(posedge clk) begin
		if(reset)
			number <= 0;
		else begin
				number <= (number << 1) | bit_in;
		end	
	end

	assign div_by_5 = (last && number % 5 == 0);
endmodule

//best approach (works for all modulo questions)
module div_by_5_checker ();

  logic [2:0] rem; //max value is 4 (since num is 5)

	always_ff @(posedge clk) begin
		if(reset) begin
			rem <= 0;
		end
		else begin
			rem <= (rem * 2 + bit_in) % 5; // apply divisible by 5 at every step of reminder and it is enough to check
		end
	end

	assign div_by_5 = (last && rem == 0);
endmodule

////////////////////////////////////////////////////////////
// ==============================
// 6. FIFO - synchronous
// ==============================
module FIFO(input clk, rst, wr, rd, 
        input [7:0] din,output reg [7:0] dout,
        output  empty, full);

    reg [3:0] wptr = 0,rptr = 0;
    //reg [4:0] cnt = 0;
    reg [7:0] mem [15:0];

    always@(posedge clk)
    begin
    if(rst== 1'b1)
    begin
    wptr <= 0;
    rptr <= 0;
    //cnt  <= 0;
    end
    else if(wr && !full)
    begin
        mem[wptr] <= din;
        wptr      <= wptr + 1;
        //cnt       <= cnt + 1;
        end
    else if (rd && !empty)
    begin
    dout <= mem[rptr];
    rptr <= rptr + 1;
    //cnt  <= cnt  - 1;
    end
    end 


    // assign empty = (cnt == 0)    ? 1'b1 : 1'b0;
    // assign full  = (cnt == 16)   ? 1'b1 : 1'b0;
    //alternative and best approach
    assign empty = (wptr == rptr) ? 1'b1: 1'b0;
    assign full = ((wptr + 1) == rptr) ? 1'b1: 1'b0;

endmodule

/////////////////////////////////////////////////////////////

//-------------------------------------
// ASynchronizer Module
//-------------------------------------

module synchronizer(
    input logic clk,
    input logic rst_n,
    input logic [3:0] d_in,
    output logic [3:0] d_out
    );

        logic [3:0] d_temp;

        always_ff @(posedge clk) begin
            if(!rst_n) begin
                d_temp <= 4'b0;
                d_out <= 4'b0;
            end
            else begin
                d_temp <= d_in;
                d_out <= d_temp;
            end
        end
endmodule

module wptr_handler (
    input  logic        wclk, 
    input  logic        wrst_n,
    input  logic        w_en,
    input  logic [3:0]  rptr_sync,
    output logic [3:0]  wptr,
    output logic [3:0]  wptr_grey,
    output logic        wfull
);

    logic [3:0] wptr_next;
    logic [3:0] wptr_grey_next;

    // Compute next binary and gray pointers
    assign wptr_next      = wptr + (w_en & ~wfull);
    assign wptr_grey_next = (wptr_next >> 1) ^ wptr_next;

    // Full condition (inverted top two bits of rptr_sync)
    assign wfull = (wptr_grey_next == {~rptr_sync[3:2], rptr_sync[1:0]});

    always_ff @(posedge wclk or negedge wrst_n) begin
        if (!wrst_n) begin
            wptr       <= 4'b0;
            wptr_grey  <= 4'b0;
        end
        else if (w_en && !wfull) begin
            wptr      <= wptr_next;
            wptr_grey <= wptr_grey_next;
        end
    end

endmodule

module rptr_handler (
    input  logic        rclk,
    input  logic        rrst_n,
    input  logic        r_en,
    input  logic [3:0]  wptr_sync,
    output logic [3:0]  rptr,
    output logic [3:0]  rptr_grey,
    output logic        rempty
);

    logic [3:0] rptr_next;
    logic [3:0] rptr_grey_next;

    // Compute next binary and gray pointers
    assign rptr_next      = rptr + (r_en & !rempty);
    assign rptr_grey_next = (rptr_next >> 1) ^ rptr_next;

    // Empty when next read pointer equals synchronized write pointer
    assign rempty = (rptr_grey_next == wptr_sync);

    always_ff @(posedge rclk or negedge rrst_n) begin
        if (!rrst_n) begin
            rptr       <= 4'b0;
            rptr_grey  <= 4'b0;
        end
        else if (r_en && !rempty) begin
            rptr      <= rptr_next;
            rptr_grey <= rptr_grey_next;
        end
    end

endmodule

module fifo_mem(
        input logic wclk,
        input logic w_en,
        input logic [3:0] b_wptr, //extra bit for overflow checks
        input logic [7:0] wdata,
        input logic full, empty,
        input logic rclk,
        input logic r_en,
        input logic [3:0] b_rptr,
        output logic [7:0] rdata
    );

        logic [7:0] mem[0:7];

        always_ff @(posedge wclk) begin
            if(w_en && !full) begin
                mem[b_wptr[2:0]] <= wdata;
            end
        end

        always_ff @(posedge rclk) begin
            if(r_en && !empty) begin
                rdata <= mem[b_rptr[2:0]];
            end
        end
endmodule

module async_fifo_top (
    input  logic         wclk,
    input  logic         wrst_n,
    input  logic         w_en,
    input  logic [7:0]   wdata,
    output logic         wfull,
  
    input  logic         rclk,
    input  logic         rrst_n,
    input  logic         r_en,
    output logic [7:0]   rdata,
    output logic         rempty
  );
  
    // Binary and Gray pointers
    logic [3:0] b_wptr, b_rptr;
    logic [3:0] g_wptr, g_rptr;
  
    // Synchronized pointers across clock domains
    logic [3:0] g_rptr_sync, g_wptr_sync;
  
    // Instantiate write pointer handler
    wptr_handler wptr_inst (
      .wclk       (wclk),
      .wrst_n     (wrst_n),
      .w_en       (w_en),
      .rptr_sync  (g_rptr_sync),
      .wptr       (b_wptr),
      .wptr_gray  (g_wptr),
      .wfull      (wfull)
    );
  
    // Instantiate read pointer handler
    rptr_handler rptr_inst (
      .rclk       (rclk),
      .rrst_n     (rrst_n),
      .r_en       (r_en),
      .wptr_sync  (g_wptr_sync),
      .rptr       (b_rptr),
      .rptr_gray  (g_rptr),
      .rempty     (rempty)
    );
  
    // Synchronize Gray read pointer into write clock domain
    synchronizer sync_rptr (
      .clk    (wclk),
      .rst_n  (wrst_n),
      .d_in   (g_rptr),
      .d_out  (g_rptr_sync)
    );
  
    // Synchronize Gray write pointer into read clock domain
    synchronizer sync_wptr (
      .clk    (rclk),
      .rst_n  (rrst_n),
      .d_in   (g_wptr),
      .d_out  (g_wptr_sync)
    );
  
    // FIFO memory
    fifo_mem mem_inst (
      .wclk     (wclk),
      .w_en     (w_en),
      .b_wptr   (b_wptr),
      .wdata    (wdata),
      .full     (wfull),
      .rclk     (rclk),
      .r_en     (r_en),
      .b_rptr   (b_rptr),
      .empty    (rempty),
      .rdata    (rdata)
    );
  
endmodule

//assertions and functional coverage
    //synchronous fifo
    assert property (@(posedge clk) (wptr + 1) == rptr |-> wfull );
    //asynchronous fifo
    assert property (@(posedge clk) (wptr_sync[3] != rptr_sync[3]) && (wptr_sync[2:0] == rptr_sync[2:0]) |-> (wfull == 1'b1));


    //empty condition assertion
    assert property (@(posedge clk) (wptr_sync == rptr_sync) |-> (rempty == 1'b1));

///////////////////////////////////////////////////////////////////////////

//Q: given a binary move all 1's bit to the MSB. Assume the number is 1001001111001..

function int [13:0] move_ones_to_msb(input [13:0] in);
    int count = 0;

    for(int i = 0; i < 14; i++) begin
        if(in[i])
            count++; 
    end

    return {count{1'b1}, {14 - count{1'b0}} };
endfunction

////////////////////////////////////////////////////////////////////////////
