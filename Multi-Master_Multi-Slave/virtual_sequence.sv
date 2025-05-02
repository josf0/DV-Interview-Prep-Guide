class virtual_sequence extends uvm_sequence#(packet_transaction);
    `uvm_object_utils(virtual_sequence)

    `uvm_declare_p_sequencer(virtual_sequencer)

    reset_seq rst_seq;
    simple_seq si_seq;
    max_words_seq max_seq;
    backpressure_seq back_seq;
    random_dest_seq dest_seq;

    function new(string path = "virtual_sequence");
        super.new(path);
    endfunction


    virtual task body();
        if (p_sequencer == null) begin
            `uvm_fatal("VSEQ", "p_sequencer is NULL! Ensure virtual_sequencer is properly assigned.");
        end
        
        rst_seq = reset_seq::type_id::create("rst_seq");
        si_seq = simple_seq::type_id::create("si_seq");
        max_seq = max_words_seq::type_id::create("max_seq");
        back_seq = backpressure_seq::type_id::create("back_seq");
        dest_seq = random_dest_seq::type_id::create("dest_seq");

        `uvm_info("VSEQ", "Virtual Sequence started", UVM_NONE);

        fork
            `uvm_do_on(rst_seq, p_sequencer.m0_seqr);
            `uvm_do_on(rst_seq, p_sequencer.m1_seqr);
        join
        #10;

        fork
            begin
                `uvm_do_on(si_seq, p_sequencer.m0_seqr);
                `uvm_do_on(max_seq, p_sequencer.m0_seqr);
            end
            begin
                `uvm_do_on(si_seq, p_sequencer.m1_seqr);
                `uvm_do_on(max_seq, p_sequencer.m1_seqr);
            end
        join
        #10;

        fork
            begin
                `uvm_do_on(back_seq, p_sequencer.m0_seqr);
                `uvm_do_on(dest_seq, p_sequencer.m0_seqr);
            end
            begin
                `uvm_do_on(back_seq, p_sequencer.m1_seqr);
                `uvm_do_on(dest_seq, p_sequencer.m1_seqr);
            end
        join

        `uvm_info("VSEQ", "Virtual sequence completed", UVM_NONE);

    endtask

endclass