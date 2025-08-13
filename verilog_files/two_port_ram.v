module two_port_ram(
    input wire [9:0] address,input clock,input reset,
    input wire [7:0] data_in,
    input wire write_enable,
	 input wire read_enable,
    output reg [7:0] data_out
);

reg [7:0] mem [0:1023]; // Declaring a 1024x8 memory block

always @(posedge clock or posedge reset) 
begin
        if (reset) 
	     begin
        //i'll add condition afterwards
		  end 
		  else if (write_enable) 
		  begin
        mem[address] <= data_in; // Writing data
        end 
		  else if (read_enable)
		  begin 
        data_out <= mem[address]; // Reading data 
        end
end

endmodule








/*
//22bec104
//ROM-IMPLEMENTATION
//1028X8
module ram_man(clk,selector,data,address,out,reset);
input selector,clk;
input [7:0]data;
reg [7:0] mem[1023:0];
input [9:0]address;
integer i;
output reg [7:0]out;

initial
begin
for(i=0;i<1024;i=i+1)
mem[i]=i+2;
end

always@(posedge clk or posedge reset)
begin
   if(selector)
	out<=mem[address];
	else
	mem[address]<=data;
end
endmodule
*/