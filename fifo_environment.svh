class fifo_environment extends uvm_env;
    `uvm_component_utils(fifo_environment)

    //it will have objects for agent and scoreboard
    fifo_agent agnt;
    fifo_scoreboard scb;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    //Build phase
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        //calls constructors for agent and scoreboard
        agnt = fifo_agent::type_id::create("agnt", this);
        scb = fifo_scoreboard::type_id::create("scb",this);

    endfunction

    virtual function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        agnt.mon.mon_port.connect(scb.scb_port);
        uvm_report_info("FIFO ENV", "connect_phase, Monitor connected to scoreboard");
    endfunction

endclass
