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
use WORK.SDRAMJ.all;

entity LabPS2Mem is

	port
	(
		-- External _100MHz_ clock
		clk100	: in	std_logic;
		
		-- Reset switch (active-low)
		swrst	: in	std_logic;
		
		-- PS/2 serial clock
		ps2_clk	: in	std_logic;
		
		-- PS/2 data line
		ps2_dat	: in	std_logic;
		
		-- Flash-memory enable
		fceb	: out	std_logic;
		
		-- Seven-segment display digits
		ls, rs	: out	std_logic_vector(6 downto 0);
		
		-------------------------SDRAM I/O connections------------------------- 
		sclkfb	: in	std_logic;	-- feedback SDRAM clock with PCB delays
		sclk	: out	std_logic;	-- clock to SDRAM
		cke		: out	std_logic;	-- SDRAM clock-enable
		cs_n	: out	std_logic;	-- SDRAM chip-select
		ras_n	: out	std_logic;	-- SDRAM RAS
		cas_n	: out	std_logic;	-- SDRAM CAS
		we_n	: out	std_logic;	-- SDRAM write-enable
		ba		: out	std_logic_vector( 1 downto 0);	-- SDRAM bank-address
		saddr	: out	std_logic_vector(12 downto 0);	-- SDRAM address bus
		sdat	: inout	std_logic_vector(15 downto 0);	-- data bus to SDRAM
		dqmh	: out	std_logic;	-- SDRAM DQMH
		dqml	: out	std_logic	-- SDRAM DQML
	);
	
end LabPS2Mem;

architecture Structural of LabPS2Mem is
	
	-- Internal signals
	-- Project reset; tied high until SDRAM controller clock is locked
	signal reset		: std_logic;
	
	-- Inverted reset switch
	signal swrst_inv	: std_logic;
	
	-- PS/2 reader output
	signal keycode		: std_logic_vector(7 downto 0);
	signal newcode		: std_logic;
	
	-- ASCII converter output
	signal asciiValue	: std_logic_vector(15 downto 0);
	signal convdone		: std_logic;
	
	-- RAM write-controller "reply to converter" line
	signal writedone	: std_logic;
	
	-- Shift-register buffer of last eight characters entered
	signal lastEightChars	: std_logic_vector(63 downto 0);
	
	-- Aliases for LED seven-segment digits
	alias DISPLAY_UPPER	: std_logic_vector(3 downto 0) is
		asciiValue(7 downto 4);
	alias DISPLAY_LOWER	: std_logic_vector(3 downto 0) is
		asciiValue(3 downto 0);
	
	-------------------XSA Board-Type Constants (for SDRAM)--------------------
	constant XSABRD		: integer	:= 200;
	-- SDRAM generics:
	constant FREQ		: integer	:= 100_000;
	constant CLK_DIV	: real		:= 2.0;	-- (100MHz / 2.0) = 50MHz clock
	constant NROWS		: integer	:= int_select((XSABRD = 200), 8192, 4096);
	constant NCOLS		: integer	:= int_select((XSABRD = 50), 256, 512);
	
begin
	
	-- Tie flash controller off (for now)
	fceb <= AL_OFF;
	
	-- Invert reset switch
	swrst_inv <= NOT swrst;
	
	-- Connect reset switch to project reset once DLL lock is established
	reset <= swrst_inv when (lock = AH_ON) else AH_ON;
	
	-- Instantiate keyboard reader
	Keyboard : PS2MakeCodeReader
	port map
	(
		-- Connect PS/2 clock and data
		ps2_clk_AL => ps2_clk,
		ps2_data => ps2_dat,
		
		-- Connect main clock
		clk => masterclk,
		
		-- Connect project reset
		reset => reset,
		
		-- Connect the 'keycode' and 'newcode' outputs to the ASCII converter
		newcode => newcode,
		keycode => keycode
	);
	
	-- Instantiate ASCII converter
	ASCIIConvert: SMCNVRT
	port map
	(
		-- Connect main clock
		sm2clk => masterclk,
		
		-- Connect global reset
		reset => reset,
		
		-- Connect inputs from keyboard make-code reader
		newcode => newcode,
		keycode => keycode,
		
		-- Connect the outputs to the RAM write-controller
		convdone => convdone,
		hdout => asciiValue,
		
		-- Connect 'write done' line to the feedback from the RAM write-controller
		wrdone => writedone
	);
	
	-- Display ASCII value on seven-segment display
	ls <= NibbleToHexDigit(unsigned(DISPLAY_UPPER));
	rs <= NibbleToHexDigit(unsigned(DISPLAY_LOWER));
	
	-- Write ASCII values to a shift register for display via the JTAG interface
	process (convdone, reset)
	begin
		if (reset = AH_ON) then
			lastEightChars <= (others => '0');
		-- Shift out a new character whenever a conversion finishes
		elsif rising_edge(convdone) then
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
	
	-- Instantiate RAM-write-controller
	-- FIXME: WRITEME
	
	--================ Instantiation of SDRAM control module ================--
	URAMCTL: XSASDRAMJ
	generic map
	(
		-- Disable pipelined mode
		PIPE_EN => FALSE,
		
		-- Specify input clock frequency
		FREQ => FREQ,
		
		-- Specify internal clock divisor
		CLK_DIV => CLK_DIV,
		
		-- Specify size of SDRAM array
		NROWS => NROWS,
		NCOLS => NCOLS
	)  	
	port map
	(
		-- Host-side ports (facing us):
		clk		=> clk100,	-- external master clock in 
		rst		=> rst_int,	-- internal reset held high until lock, then switches to project reset.
		clk1x	=> masterclk,	-- divided input clock buffered and sync'ed for use by project as 50Mhz
		clk2x	=> open,	-- sync'ed 100Mhz clock
		rd		=> hrd,		-- host-side SDRAM read control
		wr		=> hwr,		-- host-side SDRAM write control
		lock	=> lock,	-- valid DLL synchronized clocks indicator
		rdPending	=> open,	-- read still in pipeline
		opBegun		=> opBegun,	-- memory read/write begun indicator
		earlyOpBegun	=> open,	-- memory read/write begun (async)
		rdDone	=> open,	-- memory pipelined read done indicator
		done	=> done,	-- memory read/write done indicator
		hAddr	=> hAddr,	-- std_logic 24-bit host-side address from project
		hdIn	=> hdIn,	-- std_logic 16-bit write data from project
		hdOut	=> hdout,	-- std_logic 16-bit  SDRAM data output to project
		-- SDRAM-side ports (top level port signals):
		sclkfb	=> sclkfb,	-- clock from SDRAM after PCB delays
		sclk	=> sclk,	-- SDRAM clock sync'ed to master clock
		cke		=> cke,		-- SDRAM clock enable
		cs_n	=> cs_n,	-- SDRAM chip-select
		ras_n	=> ras_n,	-- SDRAM RAS
		cas_n	=> cas_n,	-- SDRAM CAS
		we_n	=> we_n,	-- SDRAM write-enable
		ba		=> ba,		-- SDRAM bank address
		saddr	=> saddr,	-- SDRAM address
		sdata	=> sdat,	-- SDRAM inout data bus
		dqmh	=> dqmh,	-- SDRAM DQMH
		dqml	=> dqml		-- SDRAM DQML
	);
	--===================== End of SDRAM control module =====================--
	
end Structural;
