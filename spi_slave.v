`include "spi_defines.v"
module spi_slave(input sclk,mosi,
                 input [`SPI_SS_NB-1:0] ss_pad_o,
                 output miso);

	reg rx_slave = 1'b0; //rx negedge of SPI core
	reg tx_slave = 1'b0; //tx negedge of SPI core

	reg [127:0] temp1 = {1'b0,{123{1'b0}},4'b0000};
	reg [127:0] temp2 = {1'b0,{123{1'b0}},4'b0000};

	reg miso1 = 1'b0;
	reg miso2 = 1'b0;

//always @(posedge sclk)
//begin
//	if((!ss_pad_o) && rx_slave && !tx_slave) //at posedge of sclk
//	begin
//		temp1 <= {temp1[126:0],mosi};
//	end
//end

//rx negedge = 1, tx negedge = 0. SPI core transmits (slave receives) in posedge.
always @(posedge sclk) // slave receives what spi core transmits at posedge
begin
	if((ss_pad_o != 8'b11111111) && rx_slave && ~tx_slave) //at posedge of sclk
	begin
		temp1 <= {temp1[126:0],mosi};
	end
end

//always @(negedge sclk)
//begin
//	if((!ss_pad_o) && ~rx_slave && tx_slave) //at negedge of sclk
//	begin
//		temp2 <= {temp2[126:0],mosi};
//	end
//end

//rx negedge = 0, tx negedge = 1. SPI core transmits at negedge of sclk and that mosi must be received by slave.
always @(negedge sclk)
begin
	if((ss_pad_o != 8'b11111111) && ~rx_slave && tx_slave) //at posedge of sclk
	begin
		temp2 <= {temp2[126:0],mosi};
	end
end

//always @(posedge sclk)
//begin
//	if(rx_slave && ~tx_slave) // at posedge of sclk
//	begin
//		miso1 <= temp1[127];
//	end
//end

//rx_negedge = 1 and tx_negedge = 0. SPI Core is receiving (slave transmits) at negedge
always @(negedge sclk)//SPI core receives (slave transmits) at negedge
begin
	if(rx_slave && ~tx_slave) // at negedge of sclk
	begin
		miso1 <= temp1[127];
	end
end

//always @(negedge sclk)
//begin
//	if(~rx_slave && tx_slave) // at negedge of sclk
//	begin
//		miso2 <= temp2[127];
//	end
//end

//rx negedge = 0 and tx negedge = 1. spi core receives miso (provided by slave) at posedge of sclk.
always @(posedge sclk)
begin
	if(~rx_slave && tx_slave) // at posedge of sclk
	begin
		miso2 <= temp2[127];
	end
end

assign miso = miso1||miso2;
endmodule
