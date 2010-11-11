		----------------------------------------------------------------------------------
-- Company:			JHU ECE
-- Engineer:		Alex Heinz
-- 
-- Create Date:		02:26 11/11/2010 
-- Design Name:		Lab PS2Mem
-- Module Name:		PSMakeCodeReader_Testbench
-- Project Name:	Lab PS2Mem
-- Target Devices:	N/A (Behavioral Simulation)
-- Description:		Test bench for a PS2 keyboard make-code reader.
--
-- Dependencies:	IEEE standard libraries, PS2MakeCodeReader entity
----------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity PS2MakeCodeReader_Testbench is
end PS2MakeCodeReader_Testbench;

architecture model of PS2MakeCodeReader_Testbench is

	-- Component declaration for Unit Under Test (UUT)
	component PS2MakeCodeReader is
	port
	(
		ps2_clk_AL	: in	std_logic;
		ps2_data	: in	std_logic;
		clk			: in	std_logic;
		reset		: in	std_logic;
		newcode		: out	std_logic;
		keycode		: out	std_logic_vector(7 downto 0)
	);

	end component;
	
	-- UUT control clock
	signal clk			: std_logic := '0';
	
	-- Inputs to UUT (w/ initial values)
	constant NUM_INPUTS	: integer := 3;
	signal INPUTS		: std_logic_vector(0 to (NUM_INPUTS - 1)) := "111";
	alias ps2_clk_AL	: std_logic is INPUTS(0);
	alias ps2_data		: std_logic is INPUTS(1);
	alias reset			: std_logic is INPUTS(2); -- Should always start high, to simulate power-on reset
	
	-- Outputs read from UUT
	signal newcode	: std_logic;
	signal keycode	: std_logic_vector(7 downto 0);
	
	-- Vectors containing input values to test
	constant NUM_VALUES		: integer := 210;
	type InputVector is array(natural range <>) of std_logic_vector(0 to (NUM_INPUTS - 1));
	constant INPUT_VALUES	: InputVector(0 to (NUM_VALUES - 1)) :=
	(
		-- Make 1:	01010101
		--		START			0				1				2				3
		"100",	"000",	"110",	"010",	"100",	"000",	"110",	"010",	"100",	"000",
		
		--		4				5				6				7				P
		"110",	"010",	"100",	"000",	"110",	"010",	"100",	"000",	"110",	"010",
		
		--		STOP			
		"110",	"010",	"100",	"100",	"100",	"100",	"100",	"100",	"100",	"100",
		
		-- First byte of break 1
		--		START			0				1				2				3
		"100",	"000",	"100",	"000",	"100",	"000",	"110",	"010",	"100",	"000",
		
		--		4				5				6				7				P
		"110",	"010",	"100",	"000",	"110",	"010",	"100",	"000",	"110",	"010",
		
		--		STOP			
		"110",	"010",	"100",	"100",	"100",	"100",	"100",	"100",	"100",	"100",
		
		-- Second byte of break 1
		--		START			0				1				2				3
		"100",	"000",	"100",	"000",	"110",	"010",	"110",	"010",	"100",	"000",
		
		--		4				5				6				7				P
		"110",	"010",	"100",	"000",	"110",	"010",	"100",	"000",	"110",	"010",
		
		--		STOP			
		"110",	"010",	"100",	"100",	"100",	"100",	"100",	"100",	"100",	"100",
		
		-- Make 2:	11110000 (bad parity)
		--		START			0				1				2				3
		"100",	"000",	"100",	"000",	"100",	"000",	"100",	"000",	"100",	"000",
		
		--		4				5				6				7				P
		"110",	"010",	"110",	"010",	"110",	"010",	"110",	"010",	"100",	"000",
		
		--		STOP			
		"110",	"010",	"100",	"100",	"100",	"100",	"100",	"100",	"100",	"100",
		
		-- First byte of break 2
		--		START			0				1				2				3
		"100",	"000",	"110",	"010",	"100",	"000",	"100",	"000",	"100",	"000",
		
		--		4				5				6				7				P
		"110",	"010",	"110",	"010",	"110",	"010",	"110",	"010",	"100",	"000",
		
		--		STOP							
		"110",	"010",	"100",	"100",	"100",	"100",	"100",	"100",	"100",	"100",
		
		-- Second byte of break 2
		--		START			0				1				2				3
		"100",	"000",	"110",	"010",	"100",	"000",	"100",	"000",	"100",	"000",
		
		--		4				5				RESET			(7)				(P)
		"110",	"010",	"110",	"010",	"110",	"101",	"100",	"100",	"100",	"100",
		
		--		(STOP)															
		"100",	"100",	"100",	"100",	"100",	"100",	"100",	"100",	"100",	"100",
		
		-- Make 3:	11100000
		--		START			0				1				2				3
		"100",	"000",	"110",	"010",	"110",	"010",	"110",	"010",	"100",	"000",
		
		--		4				5				6				7				P
		"100",	"000",	"100",	"000",	"100",	"000",	"100",	"000",	"100",	"000",
		
		--		STOP			
		"110",	"010",	"100",	"100",	"100",	"100",	"100",	"100",	"100",	"100"
	);
	
	-- Clock period
	constant CLK_PERIOD:	time := 20 ns;

begin

	-- Instantiate UUT, mapping inputs and outputs to local signals
	uut: PS2MakeCodeReader
	port map
	(
		ps2_clk_AL => ps2_clk_AL,
		ps2_data => ps2_data,
		clk => clk,
		reset => reset,
		newcode => newcode,
		keycode => keycode
	);
	
	-- Clock tick process
	process is begin
	
		-- Clock low for half period
		clk <= '0';
		wait for (CLK_PERIOD / 2);
	
		-- Clock high for half period
		clk <= '1';
		wait for (CLK_PERIOD / 2);
	
		-- (Repeats forever)
		
	end process;
	
	-- Main model process
	tb : process

		-- Process-local variables
		-- Loop counter
		variable valueIndex: integer := 0;

	begin

		-- Allow time for global reset
		wait for 100 ns;
		
		-- Loop over all test signal values
		for valueIndex in 0 to (NUM_VALUES - 1) loop
					-- Read next set of input values from constant list
			INPUTS <= INPUT_VALUES(valueIndex);
		
			-- Pause to allow state to settle
			wait for CLK_PERIOD;
		
		end loop;
		
		-- End of test; wait for simulation to finish
		wait;
		
	end process;

end model;
