----------------------------------------------------------------------------------
-- Company:			JHU ECE
-- Engineer:		R. E. Jenkins and Alex Heinz
-- Create Date:		13:22 11/11/2010 
-- Design Name:		Lab PS2Mem
-- Module Name:		SMCNVRT_2Seg - Behavioral 
-- Project Name:	Lab PS2Mem
-- Target Devices:	Xilinx Spartan3 XC3S1000
-- Description:		Two-segment version of a state-machine-based keycode-to-ASCII
--					converter.
-- Dependencies:	IEEE standard libraries
----------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity SMCNVRT_2Seg is
    port
	(
		-- State-machine clock
		sm2clk		: in	std_logic;
		-- Reset
		reset		: in	std_logic;
		
		-- Input-ready signal (assert to start conversion)
		newcode		: in	std_logic;
		-- Input bus (one byte)
		keycode		: in	std_logic_vector(7 downto 0);
		
		-- Conversion-done signal (asserted when ready for read)
		convdone	: out	std_logic;
		-- Output bus (two bytes)
		hdout		: out	std_logic_vector(15 downto 0);
		
		-- Write-done signal (assert when converted value has been read)
		wrdone		: in	std_logic
	);
end SMCNVRT_2Seg;

architecture Behavioral of SMCNVRT_2Seg is
	
	-- State machine declarations
	type SMC is (WAITC, LATCHC, PAUSEC);
	signal SMCNVRT		: SMC;
	signal nextSMCNVRT	: SMC;
	attribute INIT	: string;
	attribute INIT of SMCNVRT :	signal is "WAITC";	--we power-up in WAITC state

	-- Internal signals
	-- Internal copy of lower output byte
	signal hdout_internal	: std_logic_vector(7 downto 0);
	
	-- Two-segment next-state signals
	signal nextHdout	: std_logic_vector(7 downto 0);
	signal nextConvdone	: std_logic;
	
	-- Output of ROM
	signal char		: std_logic_vector(7 downto 0);
	
begin
	
	---State machine
	SM2: process (sm2clk, reset)
	begin
		
		-- On reset, go to initial state
		if (reset = '1') then
		
			SMCNVRT <= WAITC;	--start in wait state
			convdone <= '0';
		
		-- On clock edge, advance the state machine/outputs
		elsif rising_edge(sm2clk) then
			
			SMCNVRT <= nextSMCNVRT;
			hdout_internal <= nextHdout;
			convdone <= nextConvdone;
			
		end if;
		
	end process SM2;
	
	-- Next-state logic
	-- - Latches a new value if newcode goes high while waiting
	-- - Pauses after newcode goes low until write is complete
	-- - Returns to waiting state when wrdone goes high
	nextSMCNVRT <=	LATCHC when
						((SMCNVRT = WAITC) AND (newcode = '1')) else
					PAUSEC when
						((SMCNVRT = LATCHC) AND (newcode = '0')) else
					WAITC when
						((SMCNVRT = PAUSEC) AND (wrdone = '1')) else
					SMCNVRT;
	
	-- Next-output logic
	-- Updates with a new value when a character conversion is finished
	nextHdout <=	char when ((SMCNVRT = LATCHC) AND (newcode = '0')) else
					hdout_internal;
	
	-- Next-conversion-finished-signal logic
	-- Low until a new keycode is latched and decoded
	nextConvdone <=	'1' when ((SMCNVRT = LATCHC) AND (newcode = '0')) else
					'0';
					
	-- use keycode as ROM address for ASCII value lookup
	char <= ASCII_LC(TO_INTEGER(unsigned(keycode)));
	
	-- connect lower memory byte to the latched output character
	hdout(7 downto 0) <= hdout_internal;
	
	-- tie upper memory byte to 0
	hdout(15 downto 8) <= (others=>'0');
	
end Behavioral;
