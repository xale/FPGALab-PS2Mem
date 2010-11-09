----------------------------------------------------------------------------------
-- Company:			JHU ECE
-- Engineer:		Alex Heinz
-- 
-- Create Date:		15:17:58 11/02/2010 
-- Design Name:		Lab PS2Mem
-- Module Name:		GenericShiftCounter - Behavioral 
-- Project Name:	Lab PS2Mem
-- Target Devices:	Xilinx Spartan3 XC3S1000
-- Description:		Generic shift-register-based counter.
--
-- Dependencies:	IEEE standard libraries, AHeinzDeclares package
--
----------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;

use WORK.AHeinzDeclares.all;

entity GenericShiftCounter is
	generic
	(
		-- Number of values counter can hold
		-- Defaults to eight (i.e., 0 through 7)
		SIZE	: natural := 8
	);
	port
	(
		-- Counter-increment clock
		clk			: in	std_logic;
		
		-- Clock enable
		clkEnable	: in	std_logic;
		
		-- Counter clear
		reset		: in	std_logic;
		
		-- Counter value
		value		: out	std_logic_vector((SIZE - 1) downto 0)
	);
end GenericShiftCounter;

architecture Behavioral of GenericShiftCounter is
	
	-- Internal signals
	-- Internal counter value
	signal value_internal	: std_logic_vector((SIZE - 1) downto 0);
	
	-- Next counter value
	signal nextValue		: std_logic_vector((SIZE - 1) downto 0);
	
begin
	
	-- Clock/reset process
	process(clk, reset)
	begin
		-- On reset, intialize the value with a 1 in the first index only
		if (reset = AH_ON) then
			value_internal <= (0 => '1', others => '0');
		-- On a clock edge, (if enabled) rotate the value
		elsif rising_edge(clk) then
			if (clkEnable = AH_ON) then
				value_internal <= nextValue;
			end if;
		end if;
	end process;
	
	-- Next-value logic
	-- Rotates contents of value left
	nextValue <= value_internal((SIZE - 2) downto 0) & value_internal((SIZE - 1));
	
	-- Connect internal value to output
	value <= value_internal;
	
end Behavioral;
