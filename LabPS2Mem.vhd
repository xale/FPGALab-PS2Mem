----------------------------------------------------------------------------------
-- Company:			JHU ECE
-- Engineer:		Alex Heinz
-- 
-- Create Date:		03:56:47 11/11/2010 
-- Design Name:		Lab PS2Mem
-- Module Name:		LabPS2Mem - Structural 
-- Project Name:	Lab PS2Mem
-- Target Devices:	Xilinx Spartan3 XC3S1000
-- Description:		Top-level entity for a PS/2 keyboard reader to ASCII flash
--					memory writer
--
-- Dependencies:	IEEE standard libraries, AHeinzDeclares package,
--					PS2MakeCodeReader entity, SMCNVRT entity
--
----------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;

use WORK.AHeinzDeclares.all;

entity LabPS2Mem is

	port
	(
		-- Input 50 MHz clock
		clk50	: in	std_logic;
		
		-- Reset switch (active-low)
		swrst	: in	std_logic;
		
		-- PS/2 serial clock
		ps2_clk	: in	std_logic;
		
		-- PS/2 data line
		ps2_dat	: in	std_logic;
		
		-- Flash-memory enable
		fceb	: out	std_logic;
		
		-- Seven-segment display digits
		ls, rs	: out	std_logic_vector(6 downto 0)
	);
	
end LabPS2Mem;

architecture Structural of LabPS2Mem is
	
begin
	
end Structural;

