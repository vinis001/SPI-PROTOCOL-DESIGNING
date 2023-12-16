// WB CLK, SCLK, CPOL-0 AND CPOL-1 WORK. RECEIVING DATA FROM MISO WORKS. TRANSMISSION FROM MASTER DATA TO MOSI DURING TX_CLK WORKS.
`include "spi_defines.v"
module spi_shiftreg_tb;
	reg rx_negedge,tx_negedge,wb_clk_in,wb_rst,go,miso,lsb,sclk,cpol_0,cpol_1;
	reg [3:0] byte_sel,latch;
	reg [`SPI_CHAR_LEN_BITS - 1:0] len;
	reg [31:0] p_in;

	wire [`SPI_MAX_CHAR - 1:0] p_out;
	wire tip,mosi;
	wire last;

	spi_shift_reg DUT1 (rx_negedge,tx_negedge,byte_sel,latch,len,p_in,wb_clk_in,wb_rst,go,miso,lsb,sclk,cpol_0,cpol_1,p_out,last,mosi,tip);

	task delay(); // wishbone clock period
	begin
		#5;
	end
	endtask

//Initialize spi reset
	task spi_rst();
		begin
			wb_rst <= 1'b1;
			#10;
			wb_rst <= 1'b0;
		end
		endtask
//task to initialize length, lsb, tx and rx negedge

	task initialize();
	begin
		len <= 4;
		lsb <= 1'b1;
		rx_negedge <= 1'b0;
		tx_negedge <= 1'b1;
		latch <= 4'b0001;
		byte_sel <= 4'b0001;
	end
	endtask

//initialize go

	task begin_comm();
	begin
		go <= 1'b1;
	end
	endtask
// Generate wishbone clock
	initial
	begin
		wb_clk_in=1'b0;
		forever
		begin
			delay;
			wb_clk_in = ~wb_clk_in;
		end
	end

//Generate serial clock
	initial
	begin
		sclk=1'b0;
		delay;
		forever
		begin
			delay;
			delay;
			delay;
			delay;
			sclk <= ~sclk;
		end
	end

//Generate cpol_0 and cpol_1
	initial
	begin
		cpol_0 <= 1'b0;
		cpol_1 <= 1'b0;
	end
always @(posedge sclk)
begin
	delay;
	delay;		
	cpol_1 <= 1'b1;
	delay;
	delay;
	cpol_1 <= 1'b0;
end
always @(negedge sclk)
begin
	delay;
	delay;		
	cpol_0 <= 1'b1;
	delay;
	delay;
	cpol_0 <= 1'b0;
end

//generating a miso to check functionality
initial
begin
	miso <= 1'b1;
	forever
	begin
		#5
		miso <= 1'b0;
		#3;
		delay;
		miso <= 1'b1;
	end
end

//providing p_in
initial
begin
	p_in = 32'd13;
end

//checking waveforms
initial
begin
	spi_rst;
	initialize;
	#50 begin_comm;
	#400 $finish;
end
endmodule
