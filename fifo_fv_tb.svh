module fifo_fv_tb(
    input logic clk, 
    input logic rst,
    input logic wr_en,
    input logic rd_en,
    input logic [7:0] data_in,
    input logic [7:0] data_out,
    input logic empty,
    input logic full
);

//after reset fifo can't be full and be empty at the same time
//assume property (@(posedge clk) rst |-> !full);
//assume property (@(posedge clk) rst |-> empty);

//Valid data range assumption
//assume property (@(posedge clk) disable iff(rst) wr_en |-> (data_in inside {[0:100]}));

//Cover full and empty conditions
cover property (@(posedge clk) disable iff(rst) full);
cover property (@(posedge clk) disable iff(rst) empty);
cover property (@(posedge clk) disable iff(rst) wr_en && !full && rd_en && !empty);
cover property (@(posedge clk) disable iff(rst) (rd_en && empty));
cover property (@(posedge clk) disable iff(rst) (wr_en && full));



//Formal Verificaion, assertions to prove correctness of FIFO
//Check that data read is same as data written in FIFO
//Using a simple FIFO model for comparison
logic [7:0] model_fifo [0:7];
logic [3:0] model_wr_ptr = 4'b0000;
logic [3:0] model_rd_ptr = 4'b0000;
logic [3:0] count = 4'b0000;
always @(posedge clk) begin
    if (rst) begin
        model_wr_ptr <= '0;
        model_rd_ptr <= '0;
        count <= '0;
    end else begin
	//model_wr_ptr <= '0;
	//model_rd_ptr <= '0;
        case({wr_en && !full, rd_en && !empty})
            2'b10: begin // Write only
                model_fifo[model_wr_ptr[2:0]] <= data_in;
                model_wr_ptr <= model_wr_ptr + 1'b1;
                count <= count + 1'b1;
            end
            2'b01: begin // Read only
                model_rd_ptr <= model_rd_ptr + 1'b1;
                count <= count - 1'b1;
            end
            2'b11: begin // Simultaneous write and read
                model_fifo[model_wr_ptr[2:0]] <= data_in;
                model_wr_ptr <= model_wr_ptr + 1'b1;
                model_rd_ptr <= model_rd_ptr + 1'b1;
                // count remains the same
            end
            default: begin
                // No operation
		model_wr_ptr <= model_wr_ptr;
		model_rd_ptr <= model_rd_ptr;
            end
        endcase
    end
end


//Assertion to check data integrity
assert property (@(posedge clk) disable iff(rst) (rd_en && !empty) |=> (data_out == model_fifo[$past(model_rd_ptr[2:0])]));

//can't be empty and full at the same time
assert property (@(posedge clk) disable iff(rst) !(empty && full));

//can't write to full fifo
assert property (@(posedge clk) disable iff(rst) (full && wr_en) |=> $stable(model_wr_ptr));

//can't read from empty fifo
assert property (@(posedge clk) disable iff(rst) (empty && rd_en) |=> $stable(model_rd_ptr));

//No data loss: number of writes equals number of reads
assert property (@(posedge clk) disable iff(rst) (count == (model_wr_ptr - model_rd_ptr)));

//Stability of empty and full signals
assert property (@(posedge clk) disable iff(rst) (empty && !wr_en) |=> empty);
assert property (@(posedge clk) disable iff(rst) (empty && wr_en) |=> !empty);
assert property (@(posedge clk) disable iff(rst) (full && !rd_en) |=> full);
assert property (@(posedge clk) disable iff(rst) (full && rd_en) |=> !full);   

//when count is 0, fifo is empty
assert property (@(posedge clk) disable iff(rst) (count == 0) |-> empty);

//when count is max, fifo is full
assert property (@(posedge clk) disable iff(rst) (count == 8) |-> full);

//empty to full need minimum writes
assert property (@(posedge clk) disable iff(rst) empty |-> ##[8:$] full && (count == 8));

//full to empty requires minimum reads
assert property (@(posedge clk) disable iff(rst) full |-> ##[8:$] empty && (count == 0));

//empty eventually follows full
assert property (@(posedge clk) disable iff(rst) full |-> ##[1:$] empty);

//full eventually follows empty
assert property (@(posedge clk) disable iff(rst) empty |-> ##[1:$] full);

//Data written is eventually read
assert property (@(posedge clk) disable iff(rst) wr_en && !full |-> ##[1:$] (rd_en && !empty && (data_out == data_in)));

//Bounded FIFO depth
assert property (@(posedge clk) disable iff(rst) count <= 8);



endmodule
