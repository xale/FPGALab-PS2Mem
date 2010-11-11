----------------------------------------------------------------------------------
-- Company:			JHU ECE
-- Engineer:		Alex Heinz
-- 
-- Create Date:		14:44:56 11/09/2010 
-- Design Name:		Lab PS2Mem
-- Module Name:		PS2MakeCodeReader - Behavioral 
-- Project Name:	Lab PS2Mem
-- Target Devices:	Xilinx Spartan3 XC3S1000
-- Description:		Serial reader for one-byte PS2 keyboard make-codes.
--
-- Dependencies:	IEEE standard libraries, AHeinzDeclares package
--
----------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;

use WORK.AHeinzDeclares.all;

entity PS2MakeCodeReader is
	
	port
	(
		-- Input clock from keyboard (active-low)
		ps2_clk_AL	: in	std_logic;
		
		-- Input (serial) data line from keyboard
		ps2_data	: in	std_logic;
		
		-- Main synchronization clock
		clk			: in	std_logic;
		
		-- Reset
		reset		: in	std_logic;
		
		-- Read-complete (i.e., "new keycode latched") flag
		newcode		: out	std_logic;
		
		-- One-byte keycode output
		keycode		: out	std_logic_vector(7 downto 0)
	);
	
end PS2MakeCodeReader;

architecture Behavioral of PS2MakeCodeReader is
	
	-- Constants
	-- Bits per make/break code (start + (8 * data) + parity + stop)
	constant CODE_LENGTH	: integer	:= 11;
	constant LAST_BIT		: integer	:= (CODE_LENGTH - 1);
	
	-- Indexes of interesting bits in the code at the time when a keycode is
	-- latched to the output
	constant DATA_0_INDEX		: integer	:= 8;
	constant DATA_7_INDEX		: integer	:= 1;
	
	-- State machine
	type KB_READER_SM is
	(
		WAIT_MAKE,		-- "Waiting for make code"
		READ_MAKE,		-- "Reading (and storing) make code"
		WAIT_BREAK_1,	-- "Waiting for first byte of break code"
		SKIP_BREAK_1,	-- "Reading (and ignoring) first byte of break code"
		WAIT_BREAK_2,	-- "Waiting for second byte of break code"
		SKIP_BREAK_2	-- "Reading (and ignoring) first byte of break code"
	);
	signal readerState	: KB_READER_SM;
	signal nextState	: KB_READER_SM;
	
	-- Initialize in "waiting for make code" state
	attribute INIT	: string;
	attribute INIT of readerState : signal is "WAIT_MAKE";
	
	-- Internal signals
	-- Synched/inverted PS2 clock
	signal bufferedClk		: std_logic;
	
	-- Input bit sequence, stored in shift register
	signal currentCode		: std_logic_vector(0 to (CODE_LENGTH - 1));
	signal nextCodeShift	: std_logic_vector(0 to (CODE_LENGTH - 1));
	
	-- Currently-latched output keycode
	signal keycode_internal	: std_logic_vector(7 downto 0);
	signal nextKeycode		: std_logic_vector(7 downto 0);
	
	-- Next-clock state for 'newcode' signal
	signal nextNewcode		: std_logic;
	
	-- Current parity state
	signal codeParity		: std_logic;
	signal nextParity		: std_logic;
	
	-- Rotating counter storing number of bits read (11 per code)
	signal bitNum		: std_logic_vector((CODE_LENGTH - 1) downto 0);
	signal rotBitNum	: std_logic_vector((CODE_LENGTH - 1) downto 0);
	
begin
	
	-- PS2-clock-buffer process
	process (clk, reset)
	begin
	
		-- On reset, hold clock low
		if (reset = AH_ON) then
		
			bufferedClk <= AH_OFF;
			
		-- On rising edge of synch clock, sample (and invert) from the PS2 clock
		elsif rising_edge(clk) then
		
			bufferedClk <= NOT ps2_clk_AL;
			
		end if;
		
	end process;
	
	-- State-machine process
	process (bufferedClk, reset)
	begin
		
		-- On reset, reinitialize state machine
		if (reset = AH_ON) then
			
			readerState <= WAIT_MAKE;
			currentCode <= (others => '0');
			codeParity <= '0';
			keycode_internal <= (others => '0');
			newcode <= AH_OFF;
			bitNum <= (0 => '1', others => '0');
		
		-- On PS2 clock edge, read bits/change state
		elsif rising_edge(bufferedClk) then
			
			-- Advance to next state (if applicable)
			readerState <= nextState;
			
			-- Shift-in next bit from PS2 data line
			currentCode <= nextCodeShift;
			
			-- Accumulate parity
			codeParity <= nextParity;
			
			-- Latch new make keycode if finished
			keycode_internal <= nextKeycode;
			newcode <= nextNewcode;
			
			-- Advance to next bit index
			bitNum <= rotBitNum;
				
		end if;
		
	end process;
	
	-- Rotating bit-counter logic
	rotBitNum <=	bitNum((LAST_BIT - 1) downto 0) & bitNum(LAST_BIT);
	
	-- State-machine logic
	-- Advances on a clock edge if the current state is a "waiting" state, or if
	-- the current state is a read/skip state, but the last bit is done
	nextState <=	READ_MAKE when
						(readerState = WAIT_MAKE) else
					WAIT_BREAK_1 when
						((readerState = READ_MAKE) AND
						(bitNum(LAST_BIT)) = '1') else
					SKIP_BREAK_1 when
						(readerState = WAIT_BREAK_1) else
					WAIT_BREAK_2 when
						((readerState = SKIP_BREAK_1) AND
						(bitNum(LAST_BIT) = '1')) else
					SKIP_BREAK_2 when
						(readerState = WAIT_BREAK_2) else
					WAIT_MAKE when
						((readerState = SKIP_BREAK_2) AND
						(bitNum(LAST_BIT) = '1')) else
					readerState;
	
	-- Serial-read logic
	-- Continually shifts in bits from the PS2 data line
	nextCodeShift <= ps2_data & currentCode(0 to (CODE_LENGTH - 2));
	
	-- Parity-check logic
	-- XORs incoming bits; should be '1' when bit 10 is received
	nextParity <=	(codeParity XOR ps2_data) when
						(readerState = READ_MAKE) else
					'0';
	
	-- Output code logic
	-- Holds a value until the end of a READ_MAKE state, then checks parity and,
	-- if the new code is valid, latches it
	nextKeycode <=	currentCode(DATA_7_INDEX to DATA_0_INDEX) when
						((readerState = READ_MAKE) AND
						(bitNum(LAST_BIT) = '1') AND
						(codeParity = '1')) else
					keycode_internal;
	
	-- 'newcode' logic
	-- Holds at zero until the end of a READ_MAKE state, then checks parity and,
	-- if the new code is valid, pulses
	nextNewcode <=	AH_ON when
						((readerState = READ_MAKE) AND
						(bitNum(LAST_BIT) = '1') AND
						(codeParity = '1')) else
					AH_OFF;
	
	-- Connect outputs to internal copies
	keycode <= keycode_internal;
	
end Behavioral;
