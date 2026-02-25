//`define DRIV_IF vif.Driver.driver_cb //macro to get vif driver ports
class fifo_driver extends uvm_driver #(fifo_seq_item);
    `uvm_component_utils(fifo_driver)
    fifo_seq_item trans;
    virtual fifo_interface vif;

    function new(string name, uvm_component parent);
        super.new(name,parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        //get interface from configuration database, if not raise an error
        if(!uvm_config_db#(virtual fifo_interface)::get(this, "*","vif",vif)) begin
            `uvm_fatal("No VIF",{"virtual interface must be set for :", get_full_name(),"vif"});
        end
    endfunction

    virtual task run_phase(uvm_phase phase);
        super.run_phase(phase);
        $display("Starting UVM Driver Run phase...");

        trans = fifo_seq_item ::type_id::create("trans");
        forever begin
            seq_item_port.get_next_item(trans);//tlm port to get next transaction item from sequencer
            //drive_task();
            @(posedge vif.clk);
              vif.wr_en <= trans.wr_en;
              vif.rd_en <= trans.rd_en;

           // if(trans.wr_en) begin
                vif.data_in <= trans.data_in;
           // end
            //or connect seq item signals to drv.vif signals
            seq_item_port.item_done();
        end
      
    endtask
  
endclass
