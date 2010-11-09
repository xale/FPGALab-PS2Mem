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
		-- Input clock from keyboard
		ps2_clk		: in	std_logic;
		
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
	
	-- State machine
	-- "Waiting for make code", "Reading (and storing) make code",
	-- "Waiting for break code", "Reading (and ignoring) break code"
	type KB_READER_SM is (waitMake, readMake, waitBreak, skipBreak);
	signal readerState	: KB_READER_SM;
	signal nextState	: KB_READER_SM;
	
	-- Initialize in "waiting for make code" state
	attribute INIT	: string;
	attribute INIT of readerState : signal is "waitMake";
	
	-- Internal signals
	-- Buffered input clock
	signal bufferedClk		: std_logic;
	
	-- Partial keycode, stored in shift register
	signal keycode_internal	: std_logic_vector(7 downto 0);
	
	-- Output of (rotating) counter storing number of bits read (11 per code)
	signal bitsRead	: std_logic_vector(10 downto 0);
	alias endOfCode	: std_logic	is bitsRead(10);
	
begin
	
	-- PS2-clock-buffer process
	process (clk, reset)
	begin
	
		-- On reset, hold clock low
		if (reset = AH_ON) then
		
			bufferedClk <= AH_OFF;
			
		-- On rising edge of synch clock, latch a value from the PS2 clock
		elsif rising_edge(clk) then
		
			bufferedClk <= ps2_clk;
			
		end if;
		
	end process;
	
	-- Create bit-counter entity
	-- FIXME: WRITEME
	
	-- State-machine process
	process (bufferedClk, reset)
	begin
		
		-- FIXME: WRITEME
		
	end process;
	
	
end Behavioral;
