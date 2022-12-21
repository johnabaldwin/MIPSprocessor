library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.MIPS_LIB.all; 

entity ALU is
	generic (
		WIDTH : positive := GLOBAL_WIDTH
	);
	port (
		input1    : in std_logic_vector(WIDTH-1 downto 0);
		input2    : in std_logic_vector(WIDTH-1 downto 0);
		sel       : in std_logic_vector(5 downto 0);
		shift     : in std_logic_vector(4 downto 0);
		result    : out std_logic_vector(WIDTH-1 downto 0) := (others => '0');
		result_hi : out std_logic_vector(WIDTH - 1 downto 0) := (others => '0');
		branch    : out std_logic
	);
end ALU;


architecture arch of ALU is

	signal overflow : std_logic;

begin

	process(input1, input2, sel, shift)
		variable ALUadd : std_logic_vector(WIDTH downto 0);
		variable mult   : std_logic_vector((2*WIDTH) - 1 downto 0);
		variable multu  : std_logic_vector((2*WIDTH) - 1 downto 0);
	begin
		
		branch <= '0';
		
		case sel is
			when Add => --adder
				
				ALUadd := '0' & std_logic_vector(unsigned(input1) + unsigned(input2));
				result <= ALUadd(width - 1 downto 0);
				result_hi <= (others => '0');
				overflow <= ALUadd(width);
			
			when ADDi =>
			
				ALUadd := '0' & std_logic_vector(unsigned(input1) + unsigned(input2));
				result <= ALUadd(width - 1 downto 0);
				result_hi <= (others => '0');
				overflow <= ALUadd(width);
			
			when Subtract => --subtractor
				
				ALUadd := '0' & std_logic_vector(unsigned(input1) - unsigned(input2));
				result <= ALUadd(width - 1 downto 0);
				result_hi <= (others => '0');
				overflow <= ALUadd(width);
			
			when SUBi =>
			
				ALUadd := '0' & std_logic_vector(unsigned(input1) - unsigned(input2));
				result <= ALUadd(width - 1 downto 0);	
				result_hi <= (others => '0');
				overflow <= ALUadd(width);
			
			when Multiply => --signed mult
			
				mult := std_logic_vector(signed(input1) * signed(input2));
				result <= mult(WIDTH - 1 downto 0);
				result_hi <= (others => '0');
				result_hi <= mult(2*WIDTH - 1 downto width);
			
			when MultiplyU	=> --unsigned mult
			
				multu := std_logic_vector(unsigned(input1) * unsigned(input2));
				result <= multu(width - 1 downto 0);
				result_hi <= multu(2*WIDTH - 1 downto width);
			
			when ALU_AND => --AND
			
				result <= input1 AND input2;
				result_hi <= (others => '0');

			when ANDi =>
			
				result <= input1 AND input2;
				result_hi <= (others => '0');
				
			when ALU_OR =>
			
				result <= input1 OR input2;
				result_hi <= (others => '0');
				
			when ORi =>
			
				result <= input1 OR input2;
				result_hi <= (others => '0');
			
			when ALU_XOR =>
			
				result <= input1 XOR input2;
				result_hi <= (others => '0');
			
			when XORi =>

				result <= input1 XOR input2;
				result_hi <= (others => '0');
				
			when ShiftRightL => --shift right logical
			
				result <= std_logic_vector(shift_right(unsigned(input2), to_integer(unsigned(shift))));
				result_hi <= (others => '0');
			
			when ShiftLeftL => --shift left logical
			
				result <= std_logic_vector(shift_left(unsigned(input2), to_integer(unsigned(shift))));
				result_hi <= (others => '0');
			
			when ShiftRightA => --shift right arith
				
				result <= std_logic_vector(shift_right(signed(input2), to_integer(unsigned(shift))));
				result_hi <= (others => '0');
			
			when LessThanS => --less than
				
				if signed(input1) < signed(input2) then
					result <= std_logic_vector(to_unsigned(1, WIDTH));
				else
					result <= std_logic_vector(to_unsigned(0, WIDTH));
				end if;
				result_hi <= (others => '0');
				
			when LessThanSi =>
			
				if signed(input1) < signed(input2) then
					result <= std_logic_vector(to_unsigned(1, WIDTH));
				else
					result <= std_logic_vector(to_unsigned(0, WIDTH));
				end if;
				result_hi <= (others => '0');
				
			when LessThanU => --
				
				if unsigned(input1) < unsigned(input2) then
					result <= std_logic_vector(to_unsigned(1, WIDTH));
				else
					result <= std_logic_vector(to_unsigned(0, WIDTH));
				end if;
				result_hi <= (others => '0');
			
			when LessThanUi =>
			
				if unsigned(input1) < unsigned(input2) then
					result <= std_logic_vector(to_unsigned(1, WIDTH));
				else
					result <= std_logic_vector(to_unsigned(0, WIDTH));
				end if;
				result_hi <= (others => '0');
				
			when BoE => --branch if equal
				
				if unsigned(input1) = unsigned(input2) then
					branch <= '1';
				else
					branch <= '0';
				end if;
				result    <= (others => '0');
				result_hi <= (others => '0');
			
			when BnE => --branch not equal
				
				if unsigned(input1) /= unsigned(input2) then
					branch <= '1';
				else
					branch <= '0';
				end if;					
				result    <= (others => '0');
				result_hi <= (others => '0');
				
			when BLTE0 => --branch less than equal 0
				
				if signed(input1) <= 0 then
					branch <= '1';
				else
					branch <= '0';
				end if;
				result    <= (others => '0');
				result_hi <= (others => '0');
			
			when BLT0 => -- branch less than 0
			
				if signed(input1) < 0 then
					branch <= '1';
				else
					branch <= '0';
				end if;
				result    <= (others => '0');
				result_hi <= (others => '0');

				
--			when BGTE0 =>
--				if signed(input1) >= 0 then
--					branch <= '1';
--				end if;

			when BGT0 =>

				if signed(input1) >= 0 then
					branch <= '1';
				else
					branch <= '0';
				end if;
				result    <= (others => '0');
				result_hi <= (others => '0');
			
			when JumpReg =>
				
				result <= input1;
				result_hi <= (others => '0');
			
			when LinkReg =>
				
				result <= input1;
				result_hi <= (others => '0');
				
			when AddBranch =>
				
				result <= std_logic_vector(unsigned(input1) - unsigned(FOUR) + unsigned(input2));
				result_hi <= (others => '0');
				
			when others =>
		
				result <= SYS_ERROR;
				result_hi <= (others => '0');
				overflow <= '0';
		
		end case;
	end process;
end architecture;