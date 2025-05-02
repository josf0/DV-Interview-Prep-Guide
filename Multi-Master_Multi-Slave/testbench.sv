module testbench;
    logic clk, rst;

    // Generate Clock and Reset
    initial begin
        clk = 0;
        forever #5 clk = ~clk; // 100MHz Clock
    end

    // initial begin
    //     rst_n = 0;
    //     #20 rst_n = 1;
    // end

    // physical interfaces
    M_if m0_if(clk, rst);
    M_if m1_if(clk, rst);
    S_if s0_if(clk, rst);
    S_if s1_if(clk, rst);
    S_if s2_if(clk, rst);
    interconnect inter;

    initial begin
        inter = new(m0_if, m1_if, s0_if, s1_if, s2_if);
        inter.run();
    end
    
    initial begin
        uvm_config_db#(virtual M_if)::set(null, "*", "m0_if", vif);
        uvm_config_db#(virtual M_if)::set(null, "*", "m1_if", vif);
        uvm_config_db#(virtual S_if)::set(null, "*", "s0_if", vif);
        uvm_config_db#(virtual S_if)::set(null, "*", "s1_if", vif);
        uvm_config_db#(virtual S_if)::set(null, "*", "s2_if", vif);
        
        run_test("test");
    end

endmodule
