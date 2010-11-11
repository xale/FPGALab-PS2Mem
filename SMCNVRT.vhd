----------------------------------------------------------------------------------
-- Company:			JHU ECE
-- Engineer:		R. E. Jenkins and Alex Heinz
-- 
-- Create Date:		16:17:01 11/02/2010 
-- Design Name:		Lab PS2Mem
-- Module Name:		SMCNVRT - Behavioral 
-- Project Name:	Lab PS2Mem
-- Target Devices:	Xilinx Spartan3 XC3S1000
-- Description:		State-machine-based keycode-to-ASCII converter.
--
-- Dependencies:	IEEE standard libraries, AHeinzDeclares package
--
----------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use WORK.AHeinzDeclares.all;

entity SMCNVRT is
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
end SMCNVRT;

architecture Behavioral of SMCNVRT is
	
	-- State machine declarations
	type SMC is (WAITC, LATCHC, PAUSEC);
	signal SMCNVRT	: SMC;
	attribute INIT	: string;
	attribute INIT of SMCNVRT :	signal is "WAITC";	--we power-up in WAITC state

	-- Internal signals
	-- Output of ROM
	signal char		: std_logic_vector(7 downto 0);
	
begin
	
	---State machine
	SM2: process (sm2clk, reset, SMCNVRT, newcode, wrdone)
	begin
		
		-- On reset, go to initial state
		if (reset = AH_ON) then
		
			SMCNVRT <= WAITC;	--start in wait state
			convdone <= AH_OFF;
		
		-- On clock edge, check for the circumstances to advance the state machine
		elsif rising_edge(sm2clk) then
		
			case SMCNVRT is
			
				when WAITC =>
				
					--wait till newcode goes high
					if (newcode = AH_ON) then
						SMCNVRT <= LATCHC;
					else
						SMCNVRT <= WAITC;	--not needed, but clear
					end if;
					
				when LATCHC =>
					
					 --wait till a new keycode starts
					if (newcode = AH_OFF) then
						hdout(7 downto 0) <= char;
						convdone <= AH_ON;	-- request a write
						SMCNVRT <= PAUSEC;	-- go wait for write
					end if;
					
				when PAUSEC =>
					
					--wait till write completes
					if (wrdone = AH_ON) then
						convdone <= AH_OFF;
						SMCNVRT <= WAITC;
					end if;
					
				when others =>
					
					--Just in case...
					SMCNVRT<= WAITC;
					
			end case;
			
		end if;
		
	end process SM2;

	-- logic external to state machine:
	
	-- use keycode as ROM address for ASCII value lookup
	char <= std_logic_vector(TO_UNSIGNED(
				PS2_KEYCODE_ASCII(TO_INTEGER(unsigned(keycode))), 8));
	
	-- tie upper memory byte to 0
	hdout(15 downto 8) <= (others=>'0');
	
end Behavioral;

