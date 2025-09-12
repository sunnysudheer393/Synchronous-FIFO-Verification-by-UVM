class fifo_scoreboard extends uvm_scoreboard #(parmeter Width = 8);
    `uvm_component_utils(fifo_scoreboard)
    //it'll have analysis imp port to get from monitor
    uvm_analysis_imp #(fifo_seq_item,fifo_scoreboard) scb_port;

    fifo_seq_item que[$];
    fifo_seq_item trans;
    /*
    scoreboard has reference model for the DUT to verify the inputs
    so it need signals to store the data and check it with dut output
    it'll have memory fifo and data input signal or output to match with dut

    */
    bit [Width-1:0] mem[$];
    bit [Width-1:0] tx_data;
    bit read_delay_clk;

    function new(string name, uvm_component parent);
        super.new(name,parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        scb_port = new("scb_port",this);
    endfunction

    //write function implementation(push value into the queue)
    function write(fifo_seq_item transaction);
        que.push_back(transaction);
    endfunction

    virtual task run_phase(uvm_phase phase);
    forever begin
        wait(que.size()>0);
        trans = que.pop_front();

        //Write occured
        if(trans.wr_en==1) begin
            mem.push_back(trans.data_in);
        end

        //Read occured
        if(trans.rd_en==1 || (read_delay_clk!=0)) begin
            if(read_delay_clk==0) read_delay_clk=1;
            else begin
                if(trans.rd_en==0) read_delay_clk=0;
                if(mem.size()>0) begin
                    //pop the data from mem which got pushed into tx_data
                    tx_data = mem.pop_front();
                    //check it with current output
                    if(tx_data == trans.data_out) begin
                        `uvm_info("Scoreboard",$sformatf("---Output Matched---"),UVM_MEDIUM)
                        `uvm_info("Scoreboard", $sformatf("Exp Data=%0d, Rec data=%0d", tx_data,trans.data_out), UVM_MEDIUM)
                    end else begin
                        `uvm_info("Scoreboard",$sformatf("--Output Mis-matched---"), UVM_MEDIUM)
                        `uvm_info("Scoreboard",$sformatf("Exp data=%0d, Rec data=%0d",tx_data,trans.data_out),UVM_MEDIUM)
                    end
                end
            end
        end
        else read_delay_clk = 0;
    end

    endtask

endclass
