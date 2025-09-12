class fifo_agent extends uvm_agent;
    `uvm_component_utils(fifo_agent)

    //create handles for seqr, monitor, and driver
    fifo_sequencer seqr;
    fifo_driver driv;
    fifo_monitor mon;

    function new(string name, uvm_component parent);
        super.new(name,parent);
    endfunction

    //Build phase
    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        //create objects for seqr, driv and mon
        seqr = fifo_sequencer::type_id::create("seqr",this);
        driv = fifo_driver::type_id::create("driv",this);
        mon = fifo_monitor::type_id::create("mon",this);
    endfunction

    //connect seqr and driver
    virtual function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        driv.seq_item_port.connect(seqr.seq_item_export);
    endfunction
endclass
