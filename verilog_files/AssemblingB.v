//Steps:
//>Firstly data_in has to be stacked up in a register and then moved to ram when 8 data bits are recorded
//>Store this data byte into ram and when done start sampling again 
//>when Ram address is the last one then stop sampling and start sending data to uart 
//>When all data sent to UART , Ram sends signal to main saying all done 
//>sampling starts again
//Program stop signal is send then take 1kib data more and transmit it , before stopping the prorgam 

module AssemblingB(data_logic_probe_C1,
						 i_sys_clk,
                   o_Tx_Serial,
                   o_Tx_Done,
						 data_out_ram,
						 start
						 );
//Parameters , ip's and op's partiuclar to UART
parameter CLKS_PER_BIT = 434;
input i_sys_clk,start;
reg i_Tx_DV;
reg [7:0] i_Tx_Byte;
output o_Tx_Serial;
output o_Tx_Done;


uart_tx #(.CLKS_PER_BIT(CLKS_PER_BIT)) UTX (
        .i_sys_clk(i_sys_clk),
        .i_Tx_DV(i_Tx_DV),
        .i_Tx_Byte(i_Tx_Byte),
        .o_Tx_Serial(o_Tx_Serial),
        .o_Tx_Done(o_Tx_Done)  
		  );
    

reg o_Tx_Done_dummy;

//inputs partiuclar to two_port_RAM
reg [9:0]address_to_be_filled;
reg reset_ram;
reg [7:0]data_in_ram_sending_var;
reg [7:0]data_in_ram;
reg [7:0]data_in_ram_UART;//shifted to ram when 8 bits are sampled from the data_logic_probe_C
reg [9:0]address_ram=10'b0000000000;
output [7:0]data_out_ram;
reg WE,RE;


two_port_ram tpr(.address(address_to_be_filled),
                 .clock(i_sys_clk),
					  .reset(reset_ram),
					  .data_in(data_in_ram_sending_var),
					  .write_enable(WE),
					  .read_enable(RE),
					  .data_out(data_out_ram)//Because it will directly go into the UART_tx
                 );

input data_logic_probe_C1;//this will be taken in samples per seconds

parameter SAMPLING_RATE=1000000;//Setting it high to test 
parameter DATA_SAMPLING_PER_X_CC=50000000/SAMPLING_RATE;
parameter LAST_ADDRESS=1022;//one less for safety - give 1022
integer i_sys_clk_counts=0;	
integer data_bits_sampled=0;	


reg i_sys_clk_divided=0;
reg flag_of_ram=0;
reg flag_of_transmission=0;
reg start_UART_transmission=0;
reg [9:0]address_ram_UART=10'b0000000000;
reg first_time_only=0;
reg data_sent_to_TX=0;
always@(posedge i_sys_clk)
begin
i_sys_clk_divided=~i_sys_clk_divided;
end

always@(posedge i_sys_clk_divided)
begin  
     if(start==1)
	  begin
     o_Tx_Done_dummy<=o_Tx_Done;//shlok's idea !
     i_sys_clk_counts<=i_sys_clk_counts+1;
	  if(i_sys_clk_counts==DATA_SAMPLING_PER_X_CC && start_UART_transmission==0)
	  begin
	       i_sys_clk_counts<=0;
			 data_in_ram[data_bits_sampled]<=data_logic_probe_C1;//sampled data
			 data_bits_sampled<=data_bits_sampled+1;
			 if(data_bits_sampled==8)//when 8 bits sampled then send this to uart
			 begin//here in order to directly run the assignment we will have to assign condn as data_bits_sampled==7
			      data_bits_sampled<=0;
					data_in_ram_sending_var<=data_in_ram;
					address_to_be_filled<=address_ram;
					WE<=1;
					flag_of_ram<=1;
					//WE<=0;//won't work , i will have to delay minimum of more than 1 clock cycle
			 end
	  end
	  if(flag_of_ram==1)
	  begin
	       WE<=0;
			 address_ram<=address_ram+1;
			 flag_of_ram<=0;
	  end
	  if(address_to_be_filled==(LAST_ADDRESS-1))//before - 10'b1111111110
	  begin
	       start_UART_transmission<=1;
			 //UART transmission starts and now i don't want to sampled
			 //all i want to do is dump what we have captured to the 
	  end
	  if(flag_of_transmission==1)
	  begin
	       RE<=0;
			 address_ram_UART<=address_ram_UART+1;
	       i_Tx_DV<=0;
			 data_sent_to_TX<=0;
			 flag_of_transmission<=0;
	  end
	  if(address_ram_UART==(LAST_ADDRESS))
	  begin//things to see are read_enable should not get to one again all these variables should get to their address
	       start_UART_transmission<=0;
			 i_sys_clk_counts<=0;
			 address_ram_UART<=10'b0000000000;
			 address_ram<=10'b0000000000;
			 address_to_be_filled<=10'b0000000000;
			 first_time_only<=0;
	  end
	  if(start_UART_transmission==1 && o_Tx_Done_dummy==1 && data_sent_to_TX==1)
	  begin
				     /*uart_tx #(.CLKS_PER_BIT(CLKS_PER_BIT)) UTX (
                             .i_sys_clk(i_sys_clk),
                             .i_Tx_DV(i_Tx_DV),
                             .i_Tx_Byte(i_Tx_Byte),
                             .o_Tx_Serial(o_Tx_Serial),
                             .o_Tx_Done(o_Tx_Done)  
		                       );*/
					  /*
					  
                  //inputs partiuclar to two_port_RAM
                  reg [9:0]address_to_be_filled;
                  reg reset_ram;
                  reg [7:0]data_in_ram_sending_var;
                  reg [7:0]data_in_ram;
                  reg [7:0]data_in_ram_UART;//shifted to ram when 8 bits are sampled from the data_logic_probe_C
                  reg [9:0]address_ram=10'b0000000000;
                  reg WE,RE;

                  two_port_ram tpr(.address(address_to_be_filled),
                 .clock(i_sys_clk),
					  .reset(reset_ram),
					  .data_in(data_in_ram_sending_var),
					  .write_enable(WE),
					  .read_enable(RE),
					  .data_out(data_out_ram)//Because it will directly go into the UART_tx
                 );

					  */
					  //>first retrieve data 
					  //>then send this to uart setting tx_dv=1
					  //>then when the signal tx_done is one then send another bit
					  
					  //retreiveing address
					  //data will be retrived in data_out_ram
					  i_Tx_Byte<=data_out_ram;
					  i_Tx_DV<=1;
					  flag_of_transmission<=1;
	  end//this would probably give data of next address because i am updating it immediately
	
	  if(first_time_only==0 && start_UART_transmission==1 && data_sent_to_TX==1)
	  begin//can be solved by first assign data to data-byte ram and then running this things
	       
     		 //data will be retrived in data_out_ram
			 i_Tx_Byte<=data_out_ram;
			 i_Tx_DV<=1;
			 flag_of_transmission<=1;
	       first_time_only<=1;
	  end
     if(data_sent_to_TX==0 && start_UART_transmission==1 && address_ram_UART!=LAST_ADDRESS)
	  begin
	       address_to_be_filled<=address_ram_UART;
			 RE<=1;
			 data_sent_to_TX<=1;
	  end
	  end
end

//one problem that may arise is that i_Tx_done is up for two clock cycles and not for only one
endmodule

