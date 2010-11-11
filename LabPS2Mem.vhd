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

use ieee.numeric_std.all;

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
	
	-- Internal signals
	-- Inverted reset switch
	signal swrst_inv	: std_logic;
	
	-- PS/2 reader output
	signal keycode		: std_logic_vector(7 downto 0);
	alias KEYCODE_UPPER	: std_logic_vector(3 downto 0) is
		keycode(7 downto 4);
	alias KEYCODE_LOWER	: std_logic_vector(3 downto 0) is
		keycode(3 downto 0);
	
begin
	
	-- Tie flash controller off (for now)
	fceb <= AL_OFF;
	
	-- Invert reset switch
	swrst_inv <= NOT swrst;
	
	-- Instantiate keyboard reader
	Keyboard : PS2MakeCodeReader
	port map
	(
		-- Connect PS/2 clock and data
		ps2_clk_AL => ps2_clk,
		ps2_data => ps2_dat,
		
		-- Connect main clock
		clk => clk50,
		
		-- Connect inverted reset switch
		reset => swrst_inv,
		
		-- Leave the 'newcode' line disconnected
		newcode => open,
		
		-- Connect the 'keycode' bus to a local line
		keycode => keycode
	);
	
	-- Connect keycode bus to seven-segment display, via hex lookup table
	ls <= NibbleToHexDigit(unsigned(KEYCODE_UPPER));
	rs <= NibbleToHexDigit(unsigned(KEYCODE_LOWER));
	
end Structural;
