----------------------------------------------------------------------------------
-- Company:			JHU ECE
-- Engineer:		Alex Heinz
-- 
-- Create Date:		16:46 11/12/2010 
-- Design Name:		Lab PS2Mem
-- Module Name:		RAMWriteController_Testbench
-- Project Name:	Lab PS2Mem
-- Target Devices:	N/A (Behavioral Simulation)
-- Description:		Test bench for a RAM-write-controller state-machine entity.
--
-- Dependencies:	IEEE standard libraries, RAMWriteController entity
----------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity RAMWriteController_Testbench is
end RAMWriteController_Testbench;

architecture model of RAMWriteController_Testbench is

	-- Component declaration for Unit Under Test (UUT)
	component RAMWriteController is
	port
	(
		clk				: in	std_logic;
		reset			: in	std_logic;
		startWrite		: in	std_logic;
		writeRequest	: out	std_logic;
		writeAddress	: out	std_logic_vector(23 downto 0);
		writeDone		: in	std_logic
	);
	end component;
	
	-- UUT control clock
	signal clk			: std_logic := '0';
	
	-- Inputs to UUT (w/ initial values)
	constant NUM_INPUTS	: integer := 3;
	signal INPUTS		: std_logic_vector(0 to (NUM_INPUTS - 1)) := "001";
	alias startWrite	: std_logic is INPUTS(0);
	alias writeDone		: std_logic is INPUTS(1);
	alias reset			: std_logic is INPUTS(2); -- Should always start high, to simulate power-on reset
	
	-- Outputs read from UUT
	signal writeRequest	: std_logic;
	signal writeAddress	: std_logic_vector(23 downto 0);
	
	-- Vectors containing input values to test
	constant NUM_VALUES		: integer := 10;
	type InputVector is array(natural range <>) of std_logic_vector(0 to (NUM_INPUTS - 1));
	constant INPUT_VALUES	: InputVector(0 to (NUM_VALUES - 1)) :=
	(
		"000",	"000",	"100",	"010",	"000",	"100",	"110",	"100",	"000",	"001"
	);
	
	-- Clock period
	constant CLK_PERIOD:	time := 20 ns;

begin

	-- Instantiate UUT, mapping inputs and outputs to local signals
	uut: RAMWriteController
	port map
	(
		clk => clk,
		reset => reset,
		startWrite => startWrite,
		writeRequest => writeRequest,
		writeAddress => writeAddress,
		writeDone => writeDone
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
