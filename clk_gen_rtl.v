`include "spi_defines.v"
module spi_clgen(wb_clk_in,wb_rst,go,tip,last_clk,divider,sclk_out,cpol_0,cpol_1);

	input wb_clk_in; // wishbone clock
	input wb_rst; // wishbone reset
	input tip; // transfer in progress
	input go; // start transfer
	input last_clk; // last clock
	input [`SPI_DIVIDER_LEN-1:0] divider; // clock divider value
	output sclk_out; // output serial clock
	output cpol_0; // pulse marking positive edge of sclk_out
	output cpol_1; // pulse marking negative edge of sclk_out

	reg sclk_out;
	reg cpol_0;
	reg cpol_1;
	reg [`SPI_DIVIDER_LEN-1:0] cnt; //count to divide clock freq

//counter counts half period
always @(posedge wb_clk_in or posedge wb_rst)
begin
	if(wb_rst)
		cnt <= {{`SPI_DIVIDER_LEN{1'b0}},1'b1};
	else if(tip)
	begin
		if(cnt == (divider+1))
			cnt <= {{`SPI_DIVIDER_LEN{1'b0}},1'b1};
		else
			cnt <= cnt + 1;
	end
	else if(cnt==0)
		cnt <= {{`SPI_DIVIDER_LEN{1'b0}},1'b1};
end

//Generate serial clock
always @(posedge wb_clk_in or posedge wb_rst)
begin
	if(wb_rst)
		begin
			sclk_out <= 1'b0;
		end
	else if(tip)
		begin
			if(cnt == (divider+1))
			begin
				if(!last_clk||sclk_out)
					sclk_out <= ~sclk_out;
			end
		end
end

//Posedge and negedge detection of sclk_out
always @(posedge wb_clk_in or posedge wb_rst)
begin
	if(wb_rst)
	begin
		cpol_0 <= 1'b0;
		cpol_1 <= 1'b0;
	end
	else
	begin
		cpol_0 <=1'b0;
		cpol_1 <=1'b0;
		if (tip)
		begin
			if(~sclk_out)
			begin
				if(cnt==divider)
				begin
					cpol_0 <=1'b1;
				end
			end
		end
		if (tip)
		begin
			if(sclk_out)
			begin
				if(cnt==divider)
				begin
					cpol_1 <=1'b1;
				end
			end
		end
	end
end
endmodule
