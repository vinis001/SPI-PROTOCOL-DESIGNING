`include "spi_defines.v"
module clk_gen_tb;

	reg wb_clk_in; // wishbone clock
	reg wb_rst; // wishbone reset
	reg tip; // transfer in progress
	reg go; // start transfer
	reg last_clk; // last clock
	reg [`SPI_DIVIDER_LEN-1:0] divider; // clock divider value
	wire sclk_out; // output serial clock
	wire cpol_0; // pulse marking positive edge of sclk_out
	wire cpol_1; // pulse marking negative edge of sclk_out

	spi_clgen DUT1 (wb_clk_in,wb_rst,go,tip,last_clk,divider,sclk_out,cpol_0,cpol_1);

	task delay(); // wishbone clock period
	begin
		#5;
	end
	endtask

	task initialize_divider();
	begin
		//tip <= 1'b1;
		//go <= 1'b0;
		divider <= 8'd1;
	end
	endtask

	task init_go();
	begin
		go <= 1'b1;
		delay;
		delay;
		tip <=1'b1;
		last_clk <=1'b0;
		
	end
	endtask


	task spi_rst();
	begin
		wb_rst <= 1'b1;
		#10;
		wb_rst <= 1'b0;
	end
	endtask

	initial
	begin
		wb_clk_in=1'b0;
		forever
		begin
			delay;
			wb_clk_in = ~wb_clk_in;
		end
	end

	initial
	begin
		spi_rst;
		initialize_divider;
		delay;
		init_go;
		#200 $finish;
	end
endmodule
