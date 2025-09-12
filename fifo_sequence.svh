//................R A N D O M    S E Q U E N C E.............//
//.................W R I T E     S E Q U E N C E................//
//.................R E A D     S E Q U E N C E................//
//.................W R I T E   R E A D   BACK TO BACK    S E Q U E N C E................//
//.................W R I T E   THEN    R E A D    S E Q U E N C E.................//




//................R A N D O M    S E Q U E N C E.............//
class fifo_sequence extends uvm_sequence #(fifo_seq_item);//we'll have seq item as argument in sequence
    `uvm_object_utils(fifo_sequence)

    function new(string name = "fifo_sequence");
        super.new(name);
    endfunction

    //generates random sequences, randomizes and send request, wait for item done from driver
    //in body task it uses seq_item to generate random stimulus
    //every sequence has body task and called start method in test class

    virtual task body();
        repeat(10) begin
            req = fifo_seq_item::type_id::create("req");
            //wait for driver to grant and then randomize
            wait_for_grant();//start_item(req);
            assert(req.randomize());//if randomization fails it'll report error
            send_request(req);//no need if using the other two
            wait_for_item_done();//finish_item(req);
        end
    endtask

endclass

//.................W R I T E     S E Q U E N C E................//
class fifo_write_sequence extends uvm_sequence #(fifo_seq_item);
    `uvm_object_utils(fifo_write_sequence)

    function new(string name = "fifo_write_sequence");
        super.new(name);
    endfunction

    virtual task body();
        repeat(10) begin
            req = fifo_seq_item::type_id::create("req");
            start_item(req);
            req.randomize() with { req.wr_en==1; req.rd_en==0;};
            finish_item(req);
        end
    endtask
endclass

//.................R E A D     S E Q U E N C E................//
class fifo_read_sequence extends uvm_sequence #(fifo_seq_item);
    `uvm_object_utils(fifo_read_sequence)

    function new(string name = "fifo_read_sequence");
        super.new(name);
    endfunction

    virtual task body();
        repeat(10) begin
            read = fifo_seq_item::type_id::create("read");
            start_item(read);
            read.randomize() with { read.wr_en==0; read.rd_en==1;};
            finish_item(read);
        end
    endtask
endclass

//.................W R I T E   R E A D   BACK TO BACK    S E Q U E N C E................//
class fifo_write_read_sequence extends uvm_sequence #(fifo_seq_item);
    `uvm_object_utils(fifo_write_read_sequence)

    function new(string name = "fifo_write_read_sequence");
        super.new(name);
    endfunction

    virtual task body();
        repeat(10) begin
            wr = fifo_seq_item::type_id::create("wr");
            /*start_item(war);
            war.randomize() with { war.wr_en==1; war.rd_en==1;};
            finish_item(war);*/
            `uvm_do_with(wr,{wr.wr_en==1; wr.rd_en==0;})
            `uvm_do_with(wr,{wr.wr_en==0; wr.rd_en==1;})
        end
    endtask
endclass

//.................W R I T E   THEN    R E A D    S E Q U E N C E.................//
class fifo_write_then_read_sequence extends uvm_sequence #(fifo_seq_item);
    `uvm_object_utils(fifo_write_then_read_sequence)

    fifo_read_sequence rd_seq;
    fifo_write_sequence wr_seq;

    function new(string name = "fifo_write_then_read_sequence");
        super.new(name);
    endfunction

    virtual task body();
        repeat(10) begin
            wr_seq = fifo_seq_item::type_id::create("wr_seq");
            rd_seq = fifo_seq_item::type_id::create("rd_seq");
            /*start_item(war);
            war.randomize() with { war.wr_en==1; war.rd_en==1;};
            finish_item(war);
            `uvm_do_with(war,{war.wr_en==1; war.rd_en==0;})
            `uvm_do_with(war,{war.wr_en==0; war.rd_en==1;})*/
            //SINCE WE NEED TO WRITE FIRST AND READ AFTER WRITING COMPLETELY
            //WE'LL USE WRITE SEQ AND READ SEQ
            `uvm_do(wr_seq)
            `uvm_do(rd_seq)
        end
    endtask
endclass
