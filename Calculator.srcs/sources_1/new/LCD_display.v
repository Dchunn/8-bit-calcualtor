`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Name: Daniel Chunn
// Class: ECEN 340
// 
// Create Date: 07/13/2017 09:37:14 AM
// Design Name: 
// Module Name: LCD_display
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module LCD_display(
    CLK,
    display,
    btnr,
    num,
    JA,
	 JB
    );

	// ===========================================================================
	// 										Port Declarations
	// ===========================================================================
    input [3:0] num;
    input display;
    input btnr;								// use BTNR as reset input
    input CLK;									// 100 MHz clock input

   //lcd input signals
   //signal on connector JA
    output reg [7:0] JA;							//output bus, used for data transfer (DB)
   // signal on connector JB
   //JB[4]register selection pin  (RS)
   //JB[5]selects between read/write modes (RW)
   //JB[6]enable signal for starting the data read/write (E)
    output reg [6:4] JB;


	// ===========================================================================
	// 							  Parameters, Regsiters, and Wires
	// ===========================================================================

   //LCD control state machine
	parameter [3:0] stFunctionSet = 0,						// Initialization states
						 stDisplayCtrlSet = 1,
						 stDisplayClear = 2,
						 stPowerOn_Delay = 3,					// Delay states
						 stFunctionSet_Delay = 4,
						 stDisplayCtrlSet_Delay = 5,
						 stDisplayClear_Delay = 6,
						 stInitDne = 7,							// Display characters and perform standard operations
						 stActWr = 8,
						 stCharDelay = 9;							// Write delay for operations
	
	
	/* These constants are used to initialize the LCD pannel.

		--  FunctionSet:
								Bit 0 and 1 are arbitrary
								Bit 2:  Displays font type(0=5x8, 1=5x11)
								Bit 3:  Numbers of display lines (0=1, 1=2)
								Bit 4:  Data length (0=4 bit, 1=8 bit)
								Bit 5-7 are set
		--  DisplayCtrlSet:
								Bit 0:  Blinking cursor control (0=off, 1=on)
								Bit 1:  Cursor (0=off, 1=on)
								Bit 2:  Display (0=off, 1=on)
								Bit 3-7 are set
		--  DisplayClear:
								Bit 1-7 are set	*/
		
	reg [6:0] clkCount = 7'b0000000;
	reg [20:0] count = 21'b000000000000000000000;	// 21 bit count variable for timing delays
	wire delayOK;													// High when count has reached the right delay time
	reg oneUSClk;													// Signal is treated as a 1 MHz clock	
	reg [3:0] stCur = stPowerOn_Delay;						// LCD control state machine
	reg [3:0] stNext;
	reg [5:0] items = 5'b00011;
	reg check_button = 1'b0;
	wire writeDone;											// Command set finish

	reg [9:0] LCD_CMDS[0:23];
    initial
    begin
	   LCD_CMDS[0] = {2'b00, 8'h3C};		// 0, Function Set
	   LCD_CMDS[1] = {2'b00, 8'h0C};		// 1, Display ON, Cursor OFF, Blink OFF
	   LCD_CMDS[2] = {2'b00, 8'h01};		// 2, Clear Display
	   LCD_CMDS[3] = {2'b00, 8'h02};		// 3, Return Home

	end

	reg [5:0] lcd_cmd_ptr;
	always
        begin
        if((display == 1'b1) && (check_button == 1'b0))
        begin
            check_button <= 1'b1;
            if (num == 4'h0)
            begin
               items <= items + 1'b1;
               LCD_CMDS[items] = {2'b10, 8'h30};
            end
            else if (num == 4'h1)
            begin
                items <= items + 1'b1;
                LCD_CMDS[items] = {2'b10, 8'h31};
            end
            else if (num == 4'h2)
            begin
                 LCD_CMDS[items] = {2'b10, 8'h32};
                 items <= items + 1'b1;
            end
            else if (num == 4'h3)
            begin
                 items <= items + 1'b1;
                 LCD_CMDS[items] = {2'b10, 8'h33};
            end
            else if (num == 4'h4)
            begin
                 items <= items + 1'b1;
                 LCD_CMDS[items] = {2'b10, 8'h34};
            end
            else if (num == 4'h5)
            begin
                 items <= items + 1'b1;
                 LCD_CMDS[items] = {2'b10, 8'h35};
            end
            else if (num == 4'h6)
            begin
                 items <= items + 1'b1;
                 LCD_CMDS[items] = {2'b10, 8'h36};
            end
            else if (num == 4'h7)
            begin
                 items <= items + 1'b1;
                 LCD_CMDS[items] = {2'b10, 8'h37};
            end
            else if (num == 4'h8)
            begin
                  items <= items + 1'b1;
                  LCD_CMDS[items] = {2'b10, 8'h38};
            end
            else if (num == 4'h9)
            begin
                  items <= items + 1'b1;
                  LCD_CMDS[items] = {2'b10, 8'h39};
            end
            else if (num == 4'hA)
            begin
                  items <= items + 1'b1;
                  LCD_CMDS[items] = {2'b10, 8'h2B};
            end
            else if (num == 4'hB)
            begin
                  items <= items + 1'b1;
                  LCD_CMDS[items] = {2'b10, 8'h2C};
            end
            else if (num == 4'hC)
            begin
                  items <= items + 1'b1;
                  LCD_CMDS[items] = {2'b10, 8'h2A};
            end
            else if (num == 4'hD)
            begin
                  items <= items + 1'b1;
                  LCD_CMDS[items] = {2'b10, 8'h2F};
            end
            else if (num == 4'hE)
            begin
                  items <= items + 1'b1;
                  LCD_CMDS[items] = {2'b10, 8'h3D};
            end
            else if (num == 4'hF)
            begin
                  items <= 5'b00011;
            end
         end //end if display
         else if ((display == 1'b0) && (check_button == 1'b1))
         begin
            check_button <= 1'b0;
         end
    end// end always
        
        always @(posedge oneUSClk) begin
    
            if(delayOK == 1'b1) begin
                    count <= 21'b000000000000000000000;
            end
            else begin
                    count <= count + 1'b1;
            end
    
    end


	// ===========================================================================
	// 										Implementation
	// ===========================================================================

	// This process counts to 100, and then resets.  It is used to divide the clock signal.
	// This makes oneUSClock peak aprox. once every 1microsecond
	always @(posedge CLK) begin

			if(clkCount == 7'b1100100) begin
					clkCount <= 7'b0000000;
					oneUSClk <= ~oneUSClk;
			end
			else begin
					clkCount <= clkCount + 1'b1;
			end

	end


	// This process increments the count variable unless delayOK = 1.
	always @(posedge oneUSClk) begin
	
			if(delayOK == 1'b1) begin
					count <= 21'b000000000000000000000;
			end
			else begin
					count <= count + 1'b1;
			end
	
	end


	// Determines when count has gotten to the right number, depending on the state.
	assign delayOK = (
				((stCur == stPowerOn_Delay) && (count == 21'b111101000010010000000)) ||				// 2000000	 	-> 20 ms
				((stCur == stFunctionSet_Delay) && (count == 21'b000000000111110100000)) ||		// 4000 			-> 40 us
				((stCur == stDisplayCtrlSet_Delay) && (count == 21'b000000000111110100000)) ||	// 4000 			-> 40 us
				((stCur == stDisplayClear_Delay) && (count == 21'b000100111000100000000)) ||		// 160000 		-> 1.6 ms
				((stCur == stCharDelay) && (count == 21'b000111111011110100000))						// 260000		-> 2.6 ms - Max Delay for character writes and shifts
	) ? 1'b1 : 1'b0;


	// writeDone goes high when all commands have been run	
	assign writeDone = (lcd_cmd_ptr == 5'd23) ? 1'b1 : 1'b0;
	
	// Increments the pointer so the statemachine goes through the commands
	always @(posedge oneUSClk) begin
	        if(lcd_cmd_ptr == items) begin
               lcd_cmd_ptr <= lcd_cmd_ptr;
            end
			if((stNext == stInitDne || stNext == stDisplayCtrlSet || stNext == stDisplayClear) && writeDone == 1'b0) begin
					lcd_cmd_ptr <= lcd_cmd_ptr + 1'b1;
			end
			else if(stCur == stPowerOn_Delay || stNext == stPowerOn_Delay || num == 4'hF) begin
					lcd_cmd_ptr <= 5'b00000;
			end
			else begin
					lcd_cmd_ptr <= lcd_cmd_ptr;
			end
	end
	
	
	// This process runs the LCD state machine
	always @(posedge oneUSClk) begin
			if(btnr == 1'b1) begin
					stCur <= stPowerOn_Delay;
			end
			else begin
					stCur <= stNext;
			end
	end
	

	// This process generates the sequence of outputs needed to initialize and write to the LCD screen
	always @(stCur or delayOK or writeDone or lcd_cmd_ptr) begin
	       if (lcd_cmd_ptr != items)
	       begin
			case (stCur)
				// Delays the state machine for 20ms which is needed for proper startup.
				stPowerOn_Delay : begin
						if(delayOK == 1'b1) begin
							stNext <= stFunctionSet;
						end
						else begin
							stNext <= stPowerOn_Delay;
						end
				end
					
				// This issues the function set to the LCD as follows 
				// 8 bit data length, 1 lines, font is 5x8.
				stFunctionSet : begin
						stNext <= stFunctionSet_Delay;
				end
				
				// Gives the proper delay of 37us between the function set and
				// the display control set.
				stFunctionSet_Delay : begin
						if(delayOK == 1'b1) begin
							stNext <= stDisplayCtrlSet;
						end
						else begin
							stNext <= stFunctionSet_Delay;
						end
				end
				
				// Issuse the display control set as follows
				// Display ON,  Cursor OFF, Blinking Cursor OFF.
				stDisplayCtrlSet : begin
						stNext <= stDisplayCtrlSet_Delay;
				end

				// Gives the proper delay of 37us between the display control set
				// and the Display Clear command. 
				stDisplayCtrlSet_Delay : begin
						if(delayOK == 1'b1) begin
							stNext <= stDisplayClear;
						end
						else begin
							stNext <= stDisplayCtrlSet_Delay;
						end
				end
				
				// Issues the display clear command.
				stDisplayClear	: begin
						stNext <= stDisplayClear_Delay;
				end

				// Gives the proper delay of 1.52ms between the clear command
				// and the state where you are clear to do normal operations.
				stDisplayClear_Delay : begin
						if(delayOK == 1'b1) begin
							stNext <= stInitDne;
						end
						else begin
							stNext <= stDisplayClear_Delay;
						end
				end
				
				// State for normal operations for displaying characters, changing the
				// Cursor position etc.
				stInitDne : begin		
						stNext <= stActWr;
				end

				// stActWr
				stActWr : begin
						stNext <= stCharDelay;
				end
					
				// Provides a max delay between instructions.
				stCharDelay : begin
						if(delayOK == 1'b1) begin
							stNext <= stInitDne;
						end
						else begin
							stNext <= stCharDelay;
						end
				end

				default : stNext <= stPowerOn_Delay;

			endcase
	   end
	end
		
		
	// Assign outputs
	always
	begin
	if(lcd_cmd_ptr != items)
	    begin
	       JB[4] = LCD_CMDS[lcd_cmd_ptr][9];
	       JB[5] = LCD_CMDS[lcd_cmd_ptr][8];
	       JA = LCD_CMDS[lcd_cmd_ptr][7:0];
	       JB[6] = (stCur == stFunctionSet || stCur == stDisplayCtrlSet || stCur == stDisplayClear || stCur == stActWr) ? 1'b1 : 1'b0;
        end
    end
endmodule