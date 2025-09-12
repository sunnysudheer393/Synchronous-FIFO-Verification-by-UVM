class fifo_test extends uvm_test;
    `uvm_component_utils(fifo_test)

    //create object for env and sequence class
    fifo_environment env;
    fifo_sequence fifo_seq;//Random Sequence

    //constructor to create the objects and make it for parent
    function new(string name, uvm_component parent);
        super.new(name,parent);
    endfunction

    //Build phase
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        //create objects for environment class

        env = fifo_environment::type_id::create("env",this);//calls constructor of env class
        //constructor expects 2 things string name and parent
        //here name is env and parent is this which is test class


    endfunction

    //we can print the topology
    virtual function void end_of_elaboration();
        print();//prints the topology(top-down hierarchy)
    endfunction

    //run_phase is a task(consumes simulation time)
    task run_phase(uvm_phase phase);
        //we can create objects for the sequence here
        fifo_seq = fifo_sequence::type_id::create("fifo_seq", this);

        //to know what is happening we use objections before and after randomizartions
        phase.raise_objection(this);//all run phases called parallely

        //start the sequence using the start method and the path to the sequencer
        //can also do this using `uvm_do macros and pass the seqr path
        //which calls start method(seq) or start_item(seq_item)
        fifo_seq.start(env.agnt.seqr);

        //drop the objection
        phase.drop_objection(this);

    endtask

endclass
