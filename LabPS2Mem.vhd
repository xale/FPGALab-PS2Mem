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
--					FPGALabDeclares package, JTAG_IFC entity,
--					PS2MakeCodeReader entity, SMCNVRT entity
--
----------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;

use ieee.numeric_std.all;

use WORK.AHeinzDeclares.all;
use WORK.FPGALabDeclares.JTAG_IFC;
use WORK.FPGALabDeclares.SMCNVRT;

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
	signal newcode		: std_logic;
	
	-- ASCII converter output
	signal asciiValue	: std_logic_vector(15 downto 0);
	
	-- Shift-register buffer of last eight characters entered
	signal lastEightChars	: std_logic_vector(63 downto 0);
	
	-- Aliases for LED seven-segment digits
	alias DISPLAY_UPPER	: std_logic_vector(3 downto 0) is
		asciiValue(7 downto 4);
	alias DISPLAY_LOWER	: std_logic_vector(3 downto 0) is
		asciiValue(3 downto 0);
	
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
		
		-- Connect the 'keycode' and 'newcode' outputs to the ASCII converter
		newcode => newcode,
		keycode => keycode
	);
	
	-- Instantiate ASCII converter
	ASCIIConvert: SMCNVRT
	port map
	(
		-- Connect global clock
		sm2clk => clk50,
		
		-- Connect global reset
		reset => swrst_inv,
		
		-- Connect inputs from keyboard make-code reader
		newcode => newcode,
		keycode => keycode,
		
		-- Leave the 'conversion done' flag disconnected
		convdone => open,
		
		-- Connect the output bus
		hdout => asciiValue,
		
		-- Tie the 'write done' line high, since we don't need to delay
		wrdone => '1'
	);
	
	-- Display ASCII value on seven-segment display
	ls <= NibbleToHexDigit(unsigned(DISPLAY_UPPER));
	rs <= NibbleToHexDigit(unsigned(DISPLAY_LOWER));
	
	-- Write ASCII values to a shift register for display via the JTAG interface
	process (convdone)
	begin
		-- Shift out a new character whenever a conversion finishes
		if rising_edge(convdone) then
			lastEightChars <=	lastEightChars(55 downto 0) &
								asciiValue(7 downto 0);
		end if;
	end process;
	
	-- Instantiate JTAG interface component
	PCBridge: JTAG_IFC
	port map
	(
		bscan => open,
		dat_to_pc => lastEightChars,
		dat_from_pc => open
	);
	
end Structural;
