bind fifo_design fifo_fv_tb f_tb (
                        .clk(clk),
                        .rst(rst),
                        .wr_en(wr_en),
                        .rd_en(rd_en),
                        .data_in(data_in),

                        .data_out(data_out),
                        .empty(empty),
                        .full(full)
);