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

begin

	-- FIXME: WRITEME
	
end Behavioral;

