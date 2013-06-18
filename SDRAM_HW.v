module SDRAM_HW (
  CLOCK_50,
  KEY,
  SW,
  LEDG,
  HEX0,
  HEX1,
  HEX2,
  HEX3,

  //SDRAM side
  DRAM_ADDR,
  DRAM_DQ,
  DRAM_BA,
  DRAM_RAS_N,
  DRAM_CAS_N,
  DRAM_CKE,
  DRAM_CLK,
  DRAM_WE_N,
  DRAM_CS_N,
  DRAM_LDQM,
  DRAM_UDQM
);



input        CLOCK_50;
input  [2:0] KEY;
input  [9:0] SW;
output [9:0] LEDG;
output [6:0] HEX0,
				 HEX1,
				 HEX2,
				 HEX3;

  //SDRAM side
output [11:0] DRAM_ADDR;
inout  [15:0] DRAM_DQ;
output [1:0]  DRAM_BA;
output        DRAM_RAS_N;
output        DRAM_CAS_N;
output        DRAM_CKE;
output        DRAM_CLK;
output        DRAM_WE_N;
output        DRAM_CS_N;
output        DRAM_LDQM;
output        DRAM_UDQM;



wire        RESET_n = KEY[0];
wire        DONE;     // write / read done
reg  [22:0] addr;     // address regitster
reg  [22:0] next_addr;
reg         read,     // read enable register
            write;    // write enable register
reg  [3:0]  state;    // FSM state register
reg  [3:0]  next_state;

reg  [15:0] data_in;  // data input register
wire [15:0] DATA_OUT; // data output
reg  [15:0] data_out; // data output register

assign LEDG = trial_counter;

reg [36:0] i;
reg [36:0] p;
reg [36:0] pTemp;
reg [36:0] pDelay;
reg [36:0] pInc;
reg [36:0] pIncA;
reg [36:0] pIncB;

reg next_flag;
reg [15:0] init_wait;
reg [6:0] write_control;
reg [6:0] write_counter;
reg [6:0] read_control;
reg [6:0] read_counter;

reg [7:0] trial_counter;
reg [7:0] trial_control;
reg [6:0] trial_AddrRAM_offset;
//signal for onchip ram 128(8 bits row address)*8bits datawidth

reg				myram_write;
reg	[15:0]	myram_data_in;
wire	[15:0]	myram_data_out;
reg	[13:0]   myram_addr;
reg	[22:0]	myram_addr_temp;
reg				Fail;
reg				myram_flag;
reg	[6:0] 	myram_control;

reg				AddrRAM_write;
reg				AddrRAM_read;
reg	[22:0]	AddrRAM_data_in;
wire	[22:0]	AddrRAM_data_out;
reg	[7:0]		AddrRAM_addr;
reg				AddrRAM_flag;
reg 	[3:0]		AddrRAM_control;
reg   [3:0]		AddrRAM_wait;

Sdram_Controller u0 (
  // HOST
  .REF_CLK(CLOCK_50), //system clock
  .RESET_N(RESET_n),  //system reset
  .ADDR(addr),     //address for controller request
  .WR(write),         //write request
  .RD(read),          //read request
  .LENGTH(8'h01),     //request data length
  .ACT(),             //SDRAM ACK(acknowledge)
  .DONE(DONE),        //write/read done
  .DATAIN(data_in),   //Data input
  .DATAOUT(DATA_OUT), //Data output
  .IN_REQ(),          //input data request
  .OUT_VALID(),       //output data vilid
  .DM(2'b00),         //Data mask input
  // SDRAM
  .SA(DRAM_ADDR),
  .BA(DRAM_BA),
  .CS_N(DRAM_CS_N),
  .CKE(DRAM_CKE),
  .RAS_N(DRAM_RAS_N),
  .CAS_N(DRAM_CAS_N),
  .WE_N(DRAM_WE_N),
  //.DQ(dq[15:0]),
  .DQ(DRAM_DQ),
  .DQM({DRAM_UDQM,DRAM_LDQM}),
  .SDR_CLK(DRAM_CLK)
);

SEG7_LUT_8 u1 (
  .oSEG0(HEX0),      // output SEG0
  .oSEG1(HEX1),      // output SEG1
  .oSEG2(HEX2),      // output SEG2
  .oSEG3(HEX3),      // output SEG3
  .iDIG(data_out),   // input data
  .iWR(1'b1),        // write enable
  .iCLK(CLOCK_50),   // clock
  .iRESET_n(RESET_n) // RESET
);



myram u2(
	.address(myram_addr),
	.clock(CLOCK_50),
	.data(myram_data_in),
	.wren(myram_write),
	.q(myram_data_out)
);
	
AddrRAM1	u3 (
	.address ( AddrRAM_addr ),
	.clock ( CLOCK_50 ),
	.data ( AddrRAM_data_in ),
	.rden ( AddrRAM_read ),
	.wren ( AddrRAM_write ),
	.q ( AddrRAM_data_out )
);	
							
always @(posedge CLOCK_50 or negedge RESET_n)
begin
  if (!RESET_n) begin
    addr    		<= 0; // address register
	 next_addr 		<= 0;
    read    		<= 0; // read enable register
    write   		<= 0; // write enale register
    state   		<= 0; // FSM state register
	 next_state 	<= 0;
    data_in 		<= 0; // data input register
	 data_out		<= 0;
	 
	 p      			<= 0;
	 pTemp			<= 0;

	 //pDelay <= 8'hFF;	//short delay for pretesting and simulating code use
	 //pDelay <= 37'h1DCD6500; //10s
	 //pDelay <= 37'hEE6B280; //5s 75DEGREE BASE TIME
	 //pDelay <= 28'h5F5E200; //2s
	 //pDelay <= 37'hFFFFFFFF0; //(22mins)
	 //pDelay <= 37'hAFFFFFFF0; //(15mins?)
	 //pDelay <= 37'h37E11D600; //(5mins)
	 //pDelay <= 37'h3D77A0500;//(5.5mins)
	 //pDelay <= 37'h218711A00; //(3mins)
	 //pDelay <= 37'h165A0BC00;//(2mins)
	 pDelay <= 37'hB2D05E00;//1mins ROOM TEMP BASE TIME
	 //pDelay <= 37'h10C388D00;//1.5mins
	 //pDelay	<= 37'h12A05F200;//100sec
	 //pDelay 	<= 37'h147D35700;//110sec
	 //pDelay		<=37'hDF8475800;//20MINS
	 //pDelay		<= 37'h11E1A300;//6 sec
	// pDelay		<= 37'h3B9ACA00;//20 SEC _50 DEGREE BASE TIME

	 //75 DEGREE GRANULARITY
	// pIncA	<= 37'h2FAF080;//1s
	// pIncB	<= 37'hEE6B280;//5sec
	 
	 //ROOM TEMP GRANULARITY
	 //pIncA	<= 37'hEE6B280;//5sec
	 //pIncB	<= 37'h218711A00; //(3mins)
	 
	 //Larger granularity for pre-testing use
	 pIncA		<= 37'hB2D05E00;//1mins
	 pIncB		<= 37'h165A0BC00;//(2mins)
	 
	 //50 DEGREE GRANULARITY
	// pIncA		<= 37'h5F5E200; //2s
	 //pIncB		<= 37'h59682F00;//30 SEC
	 
	 next_flag 		<= 0;
	 i        		<= 0;
	 init_wait 		<= 0;
	 //write_control <= 7'h7F;//128
	 write_control <= 7'h07;
	 write_counter <= 7'h00;
	 //read_control  <= 7'h7F;//128
	 read_control  <= 7'h07;
	 read_counter  <= 7'h00;
	 
	 //Control number of trials going to execute 
	 trial_counter <= 0;
	 //trial_control <= 8'h35;//54 samples ROOM TEMP
	 //trial_control <= 8'h32;//50 degree 
	 //trial_control <= 8'h29;//75 DEGREE 
	 trial_control <= 8'h07; //8 samples for testing use
	 trial_AddrRAM_offset <= 0;
	 
	 myram_write	<=	0;
	 myram_data_in	<=	0;
	 myram_addr		<=	0;
	 myram_addr_temp	<=0;
	 Fail				<=	0;
	 myram_flag		<=	0;
	 myram_control <=	0;
	 
	 AddrRAM_write 	<= 0;
	 AddrRAM_read		<= 0;
	 AddrRAM_addr		<= 8'd0;
	 AddrRAM_control 	<= 3'h2;
	 AddrRAM_wait  	<= 0;
  end
  else
  begin
    case (state)
      // state 0 : prepare write
      0: begin
		  if (init_wait < 16'h2FB2)
		  begin
			init_wait 	<= init_wait +1;
			state 		<= 0;
		  end
		  else
		  begin  
			write_counter 	<= 7'h00;
			read_counter <= 7'h00;
			state 			<= 1; // next state
			myram_write		<= 0;
			myram_data_in	<= 0;
			myram_control	<= 0;
			
			//AddressRAM
			AddrRAM_read <= 1;
			AddrRAM_addr <= write_counter + trial_AddrRAM_offset;
			next_flag	 <= 1;
		  end
      end
      
		1: begin
			state 			<= 2;
			AddrRAM_wait <= 0;
		end			
		
      2: begin
		  next_state <= 4;
		  state 		 <= 3;
      end
				
		3: begin		
			if (i < p)
			begin
					i 		<= i + 1'h1;
					state <= 3; 			
			end
			else
			begin	
				if (next_flag) begin
					addr <= AddrRAM_data_out;
					next_flag <= 0;
					if((myram_flag)&&(Fail))
					begin
						myram_flag	<= 0;
						myram_data_in	<= {{Fail},{myram_addr_temp[22:8]}};
						myram_write		<=1;
						myram_addr	<= myram_addr + 1'h1;								
					end
				end
				i 				<= 0;
				Fail			<= 0;
				AddrRAM_read <= 0; // close Address read
				state 		<= next_state;
			end						
		end
		
		4: begin
			read  <= 0; // read disable
			write <= 1; // write enable			
			state <= 5; // next state	
			
			//get next write address ready
			if (write_counter < write_control)
			begin
				data_in <= 16'h5555;
				pTemp <= 8'hA;
				
				AddrRAM_read <= 1;
				AddrRAM_addr <= write_counter + 1'h1 +trial_AddrRAM_offset;
			end else 
			begin  //for first read address
				AddrRAM_read <= 1;
				AddrRAM_addr <= read_counter + trial_AddrRAM_offset;
			end
					
			if ((write_counter == write_control)&&(write_counter!=3'h0))
			begin
				data_in <= 16'h5555;
				if (trial_counter <= trial_control)
				begin
					//pDelay <= (trial_counter >= 8'h1) ? ((trial_counter >= 8'h30)? (pDelay+pIncB):(pDelay+pIncA)): pDelay;//ROOM
					//pDelay <= (trial_counter >= 8'h1) ? ((trial_counter >= 8'h28)? (pDelay+pIncB):(pDelay+pIncA)): pDelay;//50
					//pDelay <= (trial_counter >= 8'h1) ? ((trial_counter >= 8'h19)? (pDelay+pIncB):(pDelay+pIncA)): pDelay;//75
					pDelay <= (trial_counter >= 8'h1) ? ((trial_counter >= 8'h04)? (pDelay+pIncB):(pDelay+pIncA)): pDelay; //testing use
				end
			end
		end
		
      // state 3 : read SDRAM & write to SEG7
      5: begin
		  AddrRAM_wait <= 0;
        if (DONE)  // prepared done
        begin
			 read <= 0;
			 write <= 0;

			 if (write_counter <= write_control)
			 begin
				if (write_counter != write_control)
				begin
					p <= pTemp;	
					write_counter <= write_counter + 1'h1;
					next_state <=4;
					next_flag <= 1;					
					state <= 3;				
				end else					
				begin 						
					write_counter <= write_counter + 1'h1;
					next_state <=6;	
					next_flag <= 1;
					read_counter <= 0;
					state <= 3;
					p <= pDelay;
				end
			end
		 end
      end

		6: begin
			read  <= 1; // read disable
			write <= 0; // write enable				
			state <= 7; // next state	
			
			//prepare for next read address
			if (read_counter < read_control)
			begin
				AddrRAM_read <= 1;
				AddrRAM_addr <= read_counter + 1'h1 + trial_AddrRAM_offset;
			end					
		end
		
      7: begin
		  data_out <= DATA_OUT;
		  myram_write	<= 0;
		  myram_addr_temp <= addr;
		  
		  AddrRAM_wait <= 0;		  
		  
        if (DONE) begin         
          read     <= 0;          // read disable
          write    <= 0;          // write disable
			 data_in  <= 0;
			 
			 //READ LOOP  
			 if (read_counter < read_control)
			 begin
					//p <= 28'h5F5E200; //2s
					p <= 8'h32; //50clk cycle
					read_counter	<= read_counter + 1'h1;
					next_state  	<=6;
					next_flag    	<=1;
					state        	<=3;

					Fail 				<= ((data_out == 16'h5555)? 0:1);
					myram_flag 		<= 1;
					myram_control  <= read_counter;				 
			end			 
			else
			begin
				 init_wait 			<= 16'h2F80;
				 next_flag 			<= 0;
				 state 				<= 8; 
				 p 					<= 8'h32; //50clk cycle
				 Fail 				<= ((data_out == 16'h5555)? 0:1);
				 myram_flag 		<= 1;
				 myram_addr			<= myram_addr + 1;
			end
        end
      end
		
		8: begin
			if (i < p)
			begin	
				i 		<= i +1;
				state <= 8;
			end
			else begin
				if ((myram_flag)&&(Fail))
				begin					
					 myram_data_in		<= {{Fail},{myram_addr_temp[22:8]}};
					 myram_write		<=1;	
					 myram_flag			<=0;
					 state 				<=9;
					 i						<=0;
				end else
				begin
					 state 				<=9;
					 i						<=0;
				end
			end
		end
		
		//for multiple trial testing use
		9: begin
			myram_write			<=	0;
			if (trial_counter < trial_control)
			begin			
				myram_write 	<= 1;
				myram_data_in 	<= {trial_counter,{8'hFF}};
				myram_addr  	<= myram_addr + 1'h1;
				
				trial_counter <= trial_counter + 1'h1;				
				state <= 0;
			end
			else
			begin
				if (trial_counter == trial_control)
				begin
					trial_counter <= trial_counter + 1'h1;	
				end
				state 			<= 9;
			end			
		end
	endcase
  end  
end
endmodule
