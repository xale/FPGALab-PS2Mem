----------------------------------------------------------------------------------
-- Company:			JHU ECE
-- Engineer:		Alex Heinz
-- Create Date:		13:46:33 11/11/2010 
-- Design Name:		Lab PS2Mem
-- Module Name:		OneShot - Behavioral 
-- Project Name:	Lab PS2Mem
-- Target Devices:	Xilinx Spartan3 XC3S1000
-- Description:		One-shot pulse generator.
-- Dependencies:	IEEE standard libraries
----------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;

entity OneShot is
	port (
		-- Synchronization clock
		clk		: in	std_logic;
		
		-- Reset (prepares the one-shot to fire on next synch clock edge)
		reset	: in	std_logic;
		
		-- Output pulse
		pulse	: out	std_logic);
end OneShot;

architecture Behavioral of OneShot is
	-- State machine
	type OneShotState is (PRIMED, FIRED);
	signal state		: OneShotState;
	attribute INIT	: string;
	attribute INIT of state	: signal is "PRIMED";
	
	-- Two-segment next-pulse signal
	signal nextOutputValue	: std_logic;
begin
	-- Main process
	process (clk, reset)
	begin
		if (reset = '1') then
			-- Return state machine to "primed" state
			state <= PRIMED;
			-- Clear output (if not already low)
			pulse <= '0';
		elsif rising_edge(clk) then
			state <= FIRED;
			pulse <= nextOutputValue;
		end if;
	end process;
	
	-- Next-output-value logic
	-- Pulses the output when transitioning from "primed" to "fired" state
	nextOutputValue	<=	'1' when (state = PRIMED) else
						'0';
end Behavioral;
