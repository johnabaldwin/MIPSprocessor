library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity decode7seg is
	port (
		input  : in std_logic_vector(3 downto 0);
		output : out std_logic_vector(6 downto 0)
	);
end decode7seg; 

architecture arch of decode7seg is
begin
 output <= "1000000" when input = "0000" else
			"1111001" when input = "0001" else
			"0100100" when input = "0010" else
			"0110000" when input = "0011" else
			"0011001" when input = "0100" else
			"0010010" when input = "0101" else
			"0000010" when input = "0110" else
			"1111000" when input = "0111" else
			"0000000" when input = "1000" else
			"0011000" when input = "1001" else
			"0001000" when input = "1010" else
			"0000011" when input = "1011" else
			"1000110" when input = "1100" else
			"0100001" when input = "1101" else
			"0000110" when input = "1110" else
			"0001110";
end architecture; 