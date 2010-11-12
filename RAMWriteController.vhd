----------------------------------------------------------------------------------
-- Company:			JHU ECE
-- Engineer:		Alex Heinz
-- 
-- Create Date:		18:35:04 11/11/2010 
-- Design Name:		Lab PS2Mem
-- Module Name:		RAMWriteController - Behavioral 
-- Project Name:	Lab PS2Mem
-- Target Devices:	Xilinx Spartan3 XC3S1000
-- Description:		A state machine entity that moderates the transfer of values
--					between a keycode-to-ASCII converter and the XSA board's SDRAM
--
-- Dependencies:	IEEE standard libraries, AHeinzDeclares package
--
----------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use WORK.AHeinzDeclares.all;

entity RAMWriteController is
	port
	(
		-- Synchronized clock from SDRAM controller
		clk				: in	std_logic;
		
		-- Reset (sets next write index to 0)
		reset			: in	std_logic;
		
		-- Conversion-finished signal from ASCII converter (triggers a write)
		startWrite		: in	std_logic;
		
		-- Request-write signal to SDRAM controller
		writeRequest	: out	std_logic;
		
		-- Address at which to make the next write
		writeAddress	: out	std_logic_vector(23 downto 0);
		
		-- Write-complete signal, from DRAM controller
		writeDone		: in	std_logic
	);
end RAMWriteController;

architecture Behavioral of RAMWriteController is
	
	-- State machine
	type RAM_WRITE_SM is
	(
		WAIT_START,	-- Waiting for startWrite to go high
		WRITING,	-- Write request made; waiting for completion
		WAIT_END	-- Write complete, waiting for startWrite to go low
	);
	signal writeState	: RAM_WRITE_SM;
	attribute init	: string;
	attribute init of writeState	: signal is "WAIT_START";
	
	-- Internal signals
	-- Internal copy of write address
	signal writeAddress_internal	: unsigned(23 downto 0);
	
	-- Two-segment next-state signals
	signal nextState		: RAM_WRITE_SM;
	signal nextWriteRequest	: std_logic;
	signal nextWriteAddress	: unsigned(23 downto 0);
	
begin
	
	-- State-machine process
	process (clk, reset)
	begin
		
		-- On reset, reinitialize state machine
		if (reset = AH_ON) then
			
			writeState <= WAIT_START;
			writeAddress_internal <= (others => '0');
			writeRequest <= AH_OFF;
		
		-- On a clock edge, perform two-segment "advances"
		elsif rising_edge(clk) then
			
			writeState <= nextState;
			writeRequest <= nextWriteRequest;
			writeAddress_internal <= nextWriteAddress;
			
		end if;
		
	end process;
	
	-- Next-state logic
	-- * Start a write when startWrite goes high
	-- * End writing when writeDone goes high
	-- * Return to initial state when startWrite goes low
	nextState <=	WRITING when
						((writeState = WAIT_START) AND (startWrite = AH_ON)) else
					WAIT_END when
						((writeState = WRITING) AND (writeDone = AH_ON)) else
					WAIT_START when
						((writeState = WAIT_END) AND (startWrite = AH_OFF)) else
					writeState;
	
	-- Next-write-request logic
	-- Request a write when writing starts
	nextWriteRequest <=	AH_ON when (writeState = WRITING) else AH_OFF;
	
	-- Next-write-address logic
	-- Increment address after each write cycle
	nextWriteAddress <=	(writeAddress_internal + 1) when
							((writeState = WRITING) AND (writeDone = AH_ON)) else
						writeAddress_internal;
						
	-- Connect writeAddress output to internal address via typecast
	writeAddress <= std_logic_vector(writeAddress_internal);
	
end Behavioral;

