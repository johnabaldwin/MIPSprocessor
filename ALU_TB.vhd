library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.MIPS_LIB.all;

entity ALU_TB is
end ALU_TB;

architecture TB of ALU_TB is

   constant TIMEOUT : time     := 1 ms;
   constant WIDTH   : positive := 32;

	signal clkEn     : std_logic := '1';
	signal rst       : std_logic := '0'; 
	signal clk       : std_logic := '0'; 
   signal input1    : std_logic_vector(7 downto 0);
	signal input2    : std_logic_vector(7 downto 0);
	signal sel       : std_logic_vector(5 downto 0);
	signal shift     : std_logic_vector(4 downto 0) := "00001";
	signal shiftI    : integer := 1;
	signal result    : std_logic_vector(7 downto 0);
	signal result_hi : std_logic_vector(7 downto 0);
	signal branch    : std_logic;
	
begin

	U_ALU : entity work.ALU
	generic map (
		WIDTH => 8
	)
   port map (
		input1    => input1,
		input2    => input2,
		sel       => sel,
		shift     => shift,
		result    => result,
		result_hi => result_hi,
		branch    => branch
	);

	clk <= not clk and clkEn after 20 ns;
		
   process
		variable mult : std_logic_vector(15 downto 0);
		variable stdI : std_logic_vector(7 downto 0);
		variable stdJ : std_logic_vector(7 downto 0);
	begin
		clkEn <= '1';
		rst   <= '1';
		wait for 10 ns;
		
		rst <= '0';
		
		wait until falling_edge(clk);
		
		for i in 0 to 255 loop
			for j in 0 to 255 loop
				for k in 0 to 11 loop
					case k is
						when 0 =>
							sel <= Add;
						when 1 =>
							sel <= Subtract;
						when 2 =>
							sel <= Multiply;
						when 3 =>
							sel <= MultiplyU;
						when 4 =>
							sel <= ALU_AND;
						when 5 =>
							sel <= ALU_OR;
						when 6 =>
							sel <= ALU_XOR;
						when 7 =>
							sel <= ShiftRightL;
						when 8 =>
							sel <= ShiftLeftL;
						when 9 =>
							sel <= ShiftRightA;
						when 10 =>
							sel <= LessThanS;
						when 11 =>
							sel <= LessThanU;
					end case;
					input1 <= std_logic_vector(to_unsigned(i, 8));
					input2 <= std_logic_vector(to_unsigned(j, 8));
					stdI := std_logic_vector(to_unsigned(i, 8));
					stdJ := std_logic_vector(to_unsigned(j, 8));

					wait until falling_edge(clk);
					
					case k is
						when 0 =>
							assert(result = std_logic_vector(to_unsigned(i + j, 8))) report "Add Incorrect" severity warning;
						when 1 =>
							if i-j >= 0 then
								assert(result = std_logic_vector(to_unsigned(i - j, 8))) report "Subtract Incorrect" severity warning;
							end if;
						when 2 =>
							mult := std_logic_vector(to_signed(i, 8) * to_signed(j, 8));
							assert(result = mult(7 downto 0)) report "Mult Signed Incorrect" severity warning;
							assert(result_hi = mult(15 downto 8)) report "Mult Signed Hi Incorrect" severity warning;
						when 3 =>
							mult := std_logic_vector(to_unsigned(i, 8) * to_unsigned(j, 8));
							assert(result = mult(7 downto 0)) report "Mult Unsigned Incorrect" severity warning;
							assert(result_hi = mult(15 downto 8)) report "Mult Unsigned Hi Incorrect" severity warning;
						when 4 =>
							assert(result = (stdI AND stdJ)) report "AND Incorrect" severity warning;
						when 5 =>
							assert(result = (stdI OR stdJ)) report "AND Incorrect" severity warning;
						when 6 =>
							assert(result = (stdI XOR stdJ)) report "AND Incorrect" severity warning;
						when 7 =>
							assert(result = std_logic_vector(shift_right(unsigned(input2), shiftI))) report "SRL Incorrect" severity warning;
						when 8 =>
							assert(result = std_logic_vector(shift_left(unsigned(input2), shiftI))) report "SLL Incorrect" severity warning;
						when 9 =>
							assert(result = std_logic_vector(shift_right(signed(input2), shiftI))) report "SRA Incorrect" severity warning;
						when 10 =>
							if to_signed(i, 8) < to_signed(j, 8) then 
								assert(result = x"01") report "Less Than Signed Incorrect" severity warning;
							else 
								assert(result = x"00") report "Less Than Signed Incorrect" severity warning; 
							end if;
						when 11 =>
							if to_unsigned(i, 8) < to_unsigned(j, 8) then 
								assert(result = x"01") report "Less Than Unsigned Incorrect" severity warning;
							else 
								assert(result = x"00") report "Less Than Unsigned Incorrect" severity warning; 
							end if;
					end case;
				end loop;
			end loop;
		end loop;
		
		
		clkEn <= '0';
      report "DONE" severity note;

      wait;

	end process;

end TB;
