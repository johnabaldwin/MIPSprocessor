LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
USE work.MIPS_LIB.ALL;

ENTITY Datapath IS
	GENERIC (
		WIDTH : POSITIVE := GLOBAL_WIDTH);
   PORT (
		clk         : in std_logic;
		rst         : in std_logic;
		switch      : in std_logic_vector(9 downto 0);
      button      : in std_logic_vector(1 downto 0);
		PCWriteCond : in std_logic := '0';
		PCWrite     : in std_logic := '0';
		IorD        : in std_logic := '0';
		MemWrite    : in std_logic := '0';
		MemToReg    : in std_logic := '0';
		IRWrite     : in std_logic := '0';
		JumpAndLink : in std_logic := '0';
		IsSigned    : in std_logic := '0';
		PCSource    : in std_logic_vector(1 downto 0) := (others => '0');
		ALUOp       : in std_logic_vector(5 downto 0) := (others => '0');
		ALUSrcB     : in std_logic_vector(1 downto 0) := (others => '0');
		ALUSrcA     : in std_logic := '0';
		RegWrite    : in std_logic := '0';
		RegDst      : in std_logic := '0';
		PORT_OUT    : out std_logic_vector(width - 1 downto 0) := (others => '0');
		LED_OUT     : out std_logic_vector(width - 1 downto 0) := (others => '0');
		OpCode      : out std_logic_vector(5 downto 0) := (others => '0');
		ALUInstruct : out std_logic_vector(5 downto 0) := (others => '0')
	);
END Datapath;

ARCHITECTURE arch OF Datapath IS

	component MEMORY is
		GENERIC (
			WIDTH : POSITIVE := GLOBAL_WIDTH);
		PORT (
			clk         : IN STD_LOGIC;
			rst         : IN STD_LOGIC;
			addr        : IN STD_LOGIC_VECTOR(WIDTH - 1 DOWNTO 0);
			input       : IN STD_LOGIC_VECTOR(WIDTH - 1 DOWNTO 0);
			port1_en    : IN STD_LOGIC;
			port2_en    : IN STD_LOGIC;
			mem_write   : IN STD_LOGIC;
			write_data  : IN STD_LOGIC_VECTOR(WIDTH - 1 DOWNTO 0);
			output      : OUT STD_LOGIC_VECTOR(WIDTH - 1 DOWNTO 0);
			LED_OUT     : OUT STD_LOGIC_VECTOR(WIDTH - 1 DOWNTO 0)
		);
	end component;
	
	component reg is
		generic (WIDTH : positive := GLOBAL_WIDTH);
		port (
			clk    : in std_logic;
			rst    : in std_logic;
			enable : in std_logic;
			input  : in std_logic_vector(WIDTH - 1 downto 0);
			output : out std_logic_vector(WIDTH - 1 downto 0)
		);
	end component;

	component register_file is
		port (
			clk : in std_logic;
			rst : in std_logic;
			rd_addr0 : in std_logic_vector(4 downto 0);
			rd_addr1 : in std_logic_vector(4 downto 0);
			wr_addr : in std_logic_vector(4 downto 0);
			wr_en : in std_logic;
			wr_data : in std_logic_vector(WIDTH - 1 downto 0);
			jumpANDlink : in std_logic;
			rd_data0 : out std_logic_vector(WIDTH - 1 downto 0);
			rd_data1 : out std_logic_vector(WIDTH - 1 downto 0)
		);
	end component;
	
	
	component ALUControl is
   generic (
		WIDTH : positive := GLOBAL_WIDTH
	);
	port (
		ALUOp     : in std_logic_vector(5 downto 0);
		Instr     : in std_logic_vector(5 downto 0);
		HI_en     : out std_logic;
		LO_en     : out std_logic;
		ALU_LO_HI : out std_logic_vector(1 downto 0);
		OPSelect  : out std_logic_vector(5 downto 0)
	);
	end component;
	
	component ALU is
		generic (
			WIDTH : positive := GLOBAL_WIDTH
		);
		port (
			input1    : in std_logic_vector(WIDTH-1 downto 0);
			input2    : in std_logic_vector(WIDTH-1 downto 0);
			sel       : in std_logic_vector(5 downto 0);
			shift     : in std_logic_vector(4 downto 0);
			result    : out std_logic_vector(WIDTH-1 downto 0);
			result_hi : out std_logic_vector(WIDTH - 1 downto 0);
			branch    : out std_logic
		);
	end component;

	--PROGRAM COUNTER
	signal PC_en  : std_logic := '0';
	signal PC_out : std_logic_vector(WIDTH - 1 downto 0) := (others => '0');
	signal new_PC : std_logic_vector(WIDTH - 1 downto 0) := (others => '0');
	
	--PORT CONTROL
	signal port1_en : std_logic := '0';
	signal port2_en : std_logic := '0';
	
	--MEMORY
	signal mem_out    : std_logic_vector(WIDTH - 1 downto 0) := (others => '0');
	signal mem_reg    : std_logic_vector(WIDTH - 1 downto 0) := (others => '0');
	signal write_data : std_logic_vector(WIDTH - 1 downto 0) := (others => '0');
	signal input      : std_logic_vector(WIDTH - 1 downto 0) := (others => '0');
	signal address    : std_logic_vector(WIDTH - 1 downto 0);
	
	--DECODE
	signal IR_reg    : std_logic_vector(WIDTH - 1 downto 0) := (others => '0');
	signal read_reg1 : std_logic_vector(4 downto 0) := (others => '0');
	signal read_reg2 : std_logic_vector(4 downto 0) := (others => '0');
	signal write_reg : std_logic_vector(4 downto 0) := (others => '0');
	
	--REGISTER FILE
	signal read_data1 : std_logic_vector(WIDTH - 1 downto 0) := (others => '0');
	signal read_data2 : std_logic_vector(WIDTH - 1 downto 0) := (others => '0');
	signal regA_out   : std_logic_vector(WIDTH - 1 downto 0) := (others => '0');
	signal regB_out   : std_logic_vector(WIDTH - 1 downto 0) := (others => '0');
	
	--ALU
	signal ALU_in1   : std_logic_vector(WIDTH - 1 downto 0) := (others => '0');
	signal ALU_in2   : std_logic_vector(WIDTH - 1 downto 0) := (others => '0');
	signal result    : std_logic_vector(WIDTH - 1 downto 0) := (others => '0');
	signal result_hi : std_logic_vector(WIDTH - 1 downto 0) := (others => '0');
	signal branch    : std_logic := '0';
	signal HI_en     : std_logic := '0';
	signal LOW_en    : std_logic := '0';
	signal ALULow_out : std_logic_vector(WIDTH - 1 downto 0) := (others => '0');
	signal ALUHi_out  : std_logic_vector(WIDTH - 1 downto 0) := (others => '0');
	signal ALU_out    : std_logic_vector(WIDTH - 1 downto 0) := (others => '0');
	signal ALU_LO_HI  : std_logic_vector(1 downto 0) := (others => '0');
	signal ALU_final  : std_logic_vector(WIDTH - 1 downto 0) := (others => '0');
	signal OPSelect   : std_logic_vector(5 downto 0) := (others => '0');

	--MEMORY SHIFT
	signal mem_mux : std_logic_vector(WIDTH - 1 downto 0) := (others => '0');
	
	--SIGN AND SHIFT
	signal sign_out  : std_logic_vector(WIDTH - 1 downto 0) := (others => '0');
	signal shift_out : std_logic_vector(WIDTH - 1 downto 0) := (others => '0');
	
BEGIN

	PC_en <= (PCWriteCond AND branch) OR PCWrite; 
	
	U_Program_Counter : reg
	GENERIC MAP (
		WIDTH => WIDTH
	)
	PORT MAP (
		clk => clk,
		rst => rst,
		enable => PC_en,
		input  => mem_mux,
		output => PC_out
	);
	
	
	--PORT ENABLE
	port1_en <= switch(9) AND NOT button(0);
	port2_en <= NOT switch(9) AND NOT button(0);
	input    <= ZERO_EXTEND & switch(8 downto 0);
	
	address  <= PC_out when IorD = '0' else
					ALU_out when IorD = '1' else
					SYS_ERROR;
	
	U_MIPS_MEM : MEMORY
	GENERIC MAP (
		WIDTH => WIDTH
	)
	PORT MAP (
		clk        => clk,
		rst        => rst,
		addr       => address,
		input      => input,
		port1_en   => port1_en,
		port2_en   => port2_en,
		mem_write  => MemWrite,
		write_data => regB_out,
		output     => mem_out,
		LED_OUT    => LED_OUT
	);
	PORT_OUT <= mem_out;
	
	
	U_MEMORY_REG : reg
	GENERIC MAP (
		WIDTH => WIDTH
	)
	PORT MAP (
		clk => clk,
		rst => rst,
		enable => '1',
		input  => mem_out,
		output => mem_reg
	);
	
	U_INSTRUCTION_REG : reg
	GENERIC MAP (
		WIDTH => WIDTH
	)
	PORT MAP (
		clk => clk,
		rst => rst,
		enable => IRWrite,
		input  => mem_reg,
		output => IR_reg
	);
	OpCode      <= IR_reg(31 downto 26);
	ALUInstruct <= IR_reg(5 downto 0);
	
	process(MemToReg, mem_reg, ALU_final)
	begin
		case MemToReg is
			when '0' =>
				write_data <= ALU_final;
			when '1' =>
				write_data <= mem_reg;
			when others =>
				write_data <= (others => '0');
		end case;
	end process;
	
	
	process(RegDst, IR_reg)
	begin
		case RegDst is
			when '0' =>
				write_reg <= IR_reg(20 downto 16);
			when '1' =>
				write_reg <= IR_reg(15 downto 11);
			when others =>
				write_reg <= (others => '0');
		end case;
	end process;
	
	U_RegisterFile : register_file
	PORT MAP (
		clk         => clk,
		rst         => rst,
		rd_addr0    => IR_reg(25 downto 21),
		rd_addr1    => IR_reg(20 downto 16),
		wr_addr     => write_reg,
		wr_en       => RegWrite,
		wr_data     => write_data,
		jumpANDlink => JumpAndLink,
		rd_data0    => read_data1,
		rd_data1    => read_data2
	);
	
	U_RegA : reg
	GENERIC MAP (
		WIDTH => WIDTH
	)
	PORT MAP (
		clk => clk,
		rst => rst,
		enable => '1',
		input  => read_data1,
		output => regA_out
	);
	
	
	U_RegB : reg
	GENERIC MAP (
		WIDTH => WIDTH
	)
	PORT MAP (
		clk => clk,
		rst => rst,
		enable => '1',
		input  => read_data2,
		output => regB_out
	);
	
	process(ALUSrcA, regA_out, PC_out, ALUSrcB, regB_out, sign_out, shift_out)
	begin
		case ALUSrcA is
			when '0' =>
				ALU_in1 <= PC_out;
			when '1' =>
				ALU_in1 <= regA_out;
			when others =>
				ALU_in1 <= (others => '0');
		end case;
		
		case ALUSrcB is
			when "00" =>
				ALU_in2 <= regB_out;
			when "01" =>
				ALU_in2 <= FOUR;
			when "10" =>
				ALU_in2 <= sign_out;
			when "11" =>
				ALU_in2 <= shift_out;
			when others =>
				ALU_in2 <= (others => '0');
		end case;
	end process;
	
	U_ALUControl : ALUControl
	GENERIC MAP (
		WIDTH => WIDTH
	)
	PORT MAP (
		ALUOp     => ALUOp,
		Instr     => IR_reg(5 downto 0),
		HI_en     => HI_en,
		LO_en     => LOW_en,
		ALU_LO_HI => ALU_LO_HI,
		OPSelect  => OPSelect
	);
	
	U_ALU : ALU
	GENERIC MAP (
		WIDTH => WIDTH
	)
	PORT MAP (
		input1    => ALU_in1,
		input2    => ALU_in2,
		sel       => OPSelect,
		shift     => mem_reg(10 downto 6),
		result    => result,
		result_hi => result_hi,
		branch    => branch
	);
	
	U_ALUOut : reg
	GENERIC MAP (
		WIDTH => WIDTH
	)
	PORT MAP (
		clk => clk,
		rst => rst,
		enable => '1',
		input  => result,
		output => ALU_out
	);
	
	U_ALULow : reg
	GENERIC MAP (
		WIDTH => WIDTH
	)
	PORT MAP (
		clk => clk,
		rst => rst,
		enable => LOW_en,
		input  => result,
		output => ALULow_out
	);
	
	U_ALUHi : reg
	GENERIC MAP (
		WIDTH => WIDTH
	)
	PORT MAP (
		clk => clk,
		rst => rst,
		enable => HI_en,
		input  => result_hi,
		output => ALUHi_out
	);
	
	process(ALU_LO_HI, ALUHi_out, ALULow_out, ALU_out)
	begin
		case ALU_LO_HI is
			when "00" =>
				ALU_final <= ALU_out;
			when "01" =>
				ALU_final <= ALULow_out;
			when "10" =>
				ALU_final <= ALUHi_out;
			when others =>
				ALU_final <= SYS_ERROR;
		end case;
	end process;

	new_PC <= PC_out(WIDTH - 1 downto 28) & IR_reg(25 downto 0) & "00"; 
	process(PCSource, new_PC, result, ALU_out)
	begin
		case PCSource is
			when "00" =>
				mem_mux <= result;
			when "01" =>
				mem_mux <= ALU_out;
			when "10" =>
				mem_mux <= new_PC;
			when others =>
				mem_mux <= (others => '0');
		end case;
	end process;
	
	process(IsSigned, IR_reg)
	begin
		if IsSigned = '1' AND IR_reg(15) = '1' then
			sign_out <= ONES & IR_reg(15 downto 0);
		else
			sign_out <= ZEROES & IR_reg(15 downto 0);
		end if;
	end process;
	shift_out <= sign_out(29 downto 0) & "00";

	
END arch;