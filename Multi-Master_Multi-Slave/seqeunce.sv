class base_seq extends uvm_sequence#(packet_transaction);
    `uvm_object_utils(base_seq)

    packet_transaction tr;
    function new(string path = "base_seq");
        super.new(path);
    endfunction

    virtual task body();
        tr = packet_transaction::type_id::create("tr");
        start_item(tr);
        assert(tr.randomize());
        finish_item(tr);
    endtask
endclass
    

class reset_seq extends base_seq;
    `uvm_object_utils(reset_seq)

    function new(string path = "reset_seq");
        super.new(path);
    endfunction

    virtual task body();
        start_item(tr);
        tr.rst = 1'b1;
        finish_item(tr);

        repeat(10) @(posedge vif.clk); //hold reset

        start_item(tr);
        tr.rst = 1'b0;
        finish_item(tr);
    endtask
endclass

class simple_seq extends base_seq;
    `uvm_object_utils(simple_seq)

    function new(string path = "simple_seq");
        super.new(path);
    endfunction

    virtual task body();
        `uvm_info("SEQ", "Executing Simple Sequence", UVM_NONE);
        repeat(10) begin //send 10 transactions
            start_item(tr);
            assert(tr.randomize());
            finish_item(tr);
        end
    endtask
endclass

class max_words_seq extends base_seq;
    `uvm_object_utils(max_words_seq)

    function new(string path = "max_words_seq");
        super.new(path);
    endfunction

    virtual task body();
        `uvm_info("SEQ", "Executing Max-Words Packet Sequence", UVM_NONE);
        start_item(tr);
        assert(tr.randomize() with { tr.length == 12'h000}); 
        finish_item(tr);
    endtask
endclass

class backpressure_seq extends base_seq;
    `uvm_object_utils(backpressure_seq)

    function new(string path = "backpressure_seq");
        super.new(path);
    endfunction

    virtual task body();
        `uvm_info("SEQ", "Executing Backpressure stress sequence", UVM_NONE);
        start_item(tr);
        assert(tr.randomize());
        tr.ready = $urandom_range(0, 1);
        finish_item(tr);
    endtask
endclass

class random_dest_seq extends base_seq;
    `uvm_object_utils(random_dest_seq)

    function new(string path = "random_dest_seq");
        super.new(path);
    endfunction

    virtual task body();
        `uvm_info("SEQ", "Executing Random Destination Test Sequence", UVM_NONE);
        repeat($urandom_range(5, 15)) begin
            start_item(tr);
            assert(tr.randomize() with {
                tr.dest inside {2'b00, 2'b01, 2'b10}; 
            });
            finish_item(tr);
        end
    endtask
endclass

//master sequences
/*
class M0_seq extends base_seq;
    `uvm_object_utils(M0_seq)

    function new(string path = "M0_seq");
        super.new(path);
    endfunction
endclass

class M1_seq extends base_seq;
    `uvm_object_utils(M1_seq)

    function new(string path = "M1_seq");
        super.new(path);
    endfunction
endclass
*/

