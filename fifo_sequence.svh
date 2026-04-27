//................R A N D O M    S E Q U E N C E.............//
//.................W R I T E     S E Q U E N C E................//
//.................R E A D     S E Q U E N C E................//
//.................W R I T E   R E A D   BACK TO BACK    S E Q U E N C E................//
//.................W R I T E   THEN    R E A D    S E Q U E N C E.................//
//..................OVERFLOW SEQUENCE....................//
//....................UNDERFLOW SEQUENCE......................//


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
      this.set_response_queue_depth(0);
        repeat(100) begin
            req = fifo_seq_item::type_id::create("req");
            start_item(req);
            req.randomize();
            finish_item(req);
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
          req = fifo_seq_item::type_id::create("req");
          start_item(req);
          req.randomize() with { req.wr_en==0; req.rd_en==1;};
          finish_item(req);
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
          req = fifo_seq_item::type_id::create("req");
            /*start_item(war);
            war.randomize() with { war.wr_en==1; war.rd_en==1;};
            finish_item(war);*/
          `uvm_do_with(req,{req.wr_en==1; req.rd_en==0;})
          `uvm_do_with(req,{req.wr_en==0; req.rd_en==1;})
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
          	req = fifo_seq_item::type_id::create("req");
            start_item(req);
            assert(req.randomize() with {req.wr_en==1;req.rd_en==0;});
            finish_item(req);
       end
        
       repeat(8) begin
            req = fifo_seq_item::type_id::create("req");
            start_item(req);
            assert(req.randomize() with {req.wr_en==1;req.rd_en==1;});
            finish_item(req);
        end
    endtask
endclass

//..................OVERFLOW SEQUENCE....................//
class fifo_overflow_seq extends uvm_sequence #(fifo_seq_item);
  `uvm_object_utils(fifo_overflow_seq)

  parameter DEPTH = 16;

  task body();
    fifo_seq_item item;
    // Write DEPTH + extra to trigger overflow condition
    repeat(DEPTH + 4) begin
      item = fifo_seq_item::type_id::create("item");
      start_item(item);
      if (!item.randomize() with {
        wr_en == 1; rd_en == 0;
        //delay_cycles == 0;
      }) `uvm_fatal("RAND_FAIL", "Randomization failed")
      finish_item(item);
    end
  endtask
endclass

//....................UNDERFLOW SEQUENCE......................//
class fifo_underflow_seq extends uvm_sequence #(fifo_seq_item);
  `uvm_object_utils(fifo_seq_item)

  task body();
    fifo_seq_item item;
    // Read from empty FIFO
    repeat(8) begin
      item = fifo_seq_item::type_id::create("item");
      start_item(item);
      if (!item.randomize() with {
        wr_en == 0; rd_en == 1;
        //delay_cycles == 0;
      }) `uvm_fatal("RAND_FAIL", "Randomization failed")
      finish_item(item);
    end
  endtask
endclass
