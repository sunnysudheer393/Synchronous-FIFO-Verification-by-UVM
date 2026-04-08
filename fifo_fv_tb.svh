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

logic [7:0] d1_in, d2_in;
logic sample_in_d1, sampled_in_d1, arbiter_window;
logic sample_in_d2, sampled_in_d2;
logic d1_out, d2_out, sampled_out_d1, sampled_out_d2;

assume property (@(posedge clk) disable iff(rst) $stable(d1_in) && $stable(d2_in));
assume property (@(posedge clk) disable iff(rst) d1_in != d2_in);
//assume property (@(posedge clk) disable iff(rst) sampled_in_d2 |-> sampled_in_d1);
assume property (@(posedge clk) disable iff(rst) !sampled_in_d1 |-> !sampled_in_d2);

//assign arbiter_window = sampled_in_d1;

assign sample_in_d1 = wr_en && (data_in == d1_in) && arbiter_window;

always_ff @( posedge clk ) begin
    if(rst) sampled_in_d1 <= 1'b0;
    else sampled_in_d1 <= (sample_in_d1 || sampled_in_d1);
end

assign sample_in_d2 = wr_en && (data_in == d2_in);

always_ff @( posedge clk ) begin
    if(rst) sampled_in_d2 <= 1'b0;
    else sampled_in_d2 <= (sample_in_d2 || sampled_in_d2);
end



assign d1_out = rd_en && sampled_in_d1 ;//&& (data_out == d1_in);

always_ff @( posedge clk ) begin
    if(rst) sampled_out_d1 <= 1'b0;
    else sampled_out_d1 <= (d1_out || sampled_out_d1);
end

assign d2_out = rd_en && sampled_in_d2 ;//&& (data_out == d2_in);

always_ff @( posedge clk ) begin
    if(rst) sampled_out_d2 <= 1'b0;
    else sampled_out_d2 <= (d2_out || sampled_out_d2);
end

assert property (@(posedge clk) disable iff(rst) sampled_in_d1 && sampled_in_d2 && !sampled_out_d1 |-> !sampled_out_d2);
//assert property (@(posedge clk) disable iff(rst) sampled_out_d2 |-> sampled_out_d1);

logic incr_count, dcr_count;
logic [7:0] d_in;
logic sample_in, sample_symb, sample_out, sampled_in, sampled_out;
logic [3:0] count;

assume property (@(posedge clk) disable iff(rst) $stable(d_in));
//assume property (@(posedge clk) disable iff(rst) $rose(sampled_in)|-> sample_symb);

assign incr_count = wr_en && !sampled_in && !full;
assign dcr_count = rd_en && !sampled_out && !empty;

always_ff @( posedge clk ) begin 
    if(rst) count <= '0;
    else count <= count + incr_count -dcr_count;
end

//assign sample_in = (data_in == d_in) && incr_count && sample_symb;


always_ff @( posedge clk ) begin 
    if(rst) sampled_in <= 1'b0;
    else if((data_in == d_in) && incr_count && sample_symb) sampled_in <= 1'b1;
end

assign sample_out = sampled_in && dcr_count && (count == 1);

always_ff @( posedge clk ) begin 
    if(rst) sampled_out <= 1'b0;
    else if(sample_out) sampled_out<= 1'b1;
end

assume property(@(posedge clk) disable iff(rst) sample_out |=> $stable(rd_en));

assert property (@(posedge clk) disable iff(rst) sample_out |->  ##1 (data_out == d_in));
//assert property (@(posedge clk) disable iff(rst) sampled_in |-> ##[0:$] sampled_out);
	



endmodule
