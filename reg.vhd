library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.MIPS_LIB.all;

entity reg is
   generic (WIDTH : positive := GLOBAL_WIDTH);
	port (
		clk    : in std_logic;
		rst    : in std_logic;
		enable : in std_logic;
		input  : in std_logic_vector(WIDTH - 1 downto 0) := (others => '0');
		output : out std_logic_vector(WIDTH - 1 downto 0) := (others => '0')
	);
end reg;

architecture arch of reg is
begin

	process (clk, rst)
	begin
		if rst = '1' then
			output <= (others => '0');
		elsif rising_edge(clk) then
			if enable = '1' then
				output <= input;
			end if;
		end if;
	end process;
	
end architecture;