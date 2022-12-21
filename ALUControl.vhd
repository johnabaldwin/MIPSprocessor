library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.MIPS_LIB.all;

entity ALUControl is
   generic (WIDTH : positive := GLOBAL_WIDTH);
	port (
		ALUOp     : in std_logic_vector(5 downto 0);
		Instr     : in std_logic_vector(5 downto 0);
		HI_en     : out std_logic;
		LO_en     : out std_logic;
		ALU_LO_HI : out std_logic_vector(1 downto 0);
		OPSelect  : out std_logic_vector(5 downto 0)
	);
end ALUControl;

architecture arch of ALUControl is
begin

	process (ALUOp, Instr)
	begin
		if ALUOp = RTYPEinstr then
			OPSelect <= Instr;
		else
			OPSelect <= ALUOp;
		end if;
		
		if (Instr = Multiply or Instr = MultiplyU) AND ALUOp = RTYPEinstr then
			HI_en <= '1';
			LO_en <= '1';
		else
			HI_en <= '0';
			LO_en <= '0';
		end if;
		
		if Instr = MoveLo  AND ALUOp = RTYPEinstr then
			ALU_LO_HI <= "01";
		elsif Instr = MoveHi AND ALUOp = RTYPEinstr then
			ALU_LO_HI <= "10";
		else
			ALU_LO_HI <= "00";
		end if;
		
	end process;
	
end architecture;