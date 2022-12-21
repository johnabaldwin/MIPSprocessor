LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
USE work.MIPS_LIB.ALL;

ENTITY MEMORY IS
   GENERIC (
		WIDTH : POSITIVE := GLOBAL_WIDTH);
   PORT (
		clk         : IN STD_LOGIC;
		rst         : IN STD_LOGIC;
		addr        : in STD_LOGIC_VECTOR(WIDTH - 1 DOWNTO 0);
		input       : IN STD_LOGIC_VECTOR(WIDTH - 1 DOWNTO 0);
		port1_en    : IN STD_LOGIC;
		port2_en    : IN STD_LOGIC;
		mem_write   : IN STD_LOGIC;
		write_data  : IN STD_LOGIC_VECTOR(WIDTH - 1 DOWNTO 0);
      output      : OUT STD_LOGIC_VECTOR(WIDTH - 1 DOWNTO 0);
		LED_OUT     : OUT STD_LOGIC_VECTOR(WIDTH - 1 DOWNTO 0)
	);
END MEMORY;

ARCHITECTURE arch OF MEMORY IS

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
	
	component MIPS_RAM2 is
		port (
			address  : IN STD_LOGIC_VECTOR (7 DOWNTO 0);
			clock		: IN STD_LOGIC  := '1';
			data		: IN STD_LOGIC_VECTOR (31 DOWNTO 0);
			wren		: IN STD_LOGIC ;
			q		: OUT STD_LOGIC_VECTOR (31 DOWNTO 0)
		);
	end component;

	
	--MEMORY CONTROL
	signal read_sel   : std_logic_vector(1 downto 0) := (others => '0');
	signal write_en   : std_logic;
	signal outport_en : std_logic;

	--MEMORY OUTPUT
	signal port1_out : std_logic_vector(width - 1 downto 0);
	signal port2_out : std_logic_vector(width - 1 downto 0);
	signal RAM_out   : std_logic_vector(width - 1 downto 0);

BEGIN
	
	U_port1 : reg
	GENERIC MAP (
		WIDTH => WIDTH
	)
	PORT MAP (
		clk => clk,
		rst => '0',
		enable => port1_en,
		input  => input,
		output => port1_out
	);
	
	U_port2 : reg
	GENERIC MAP (
		WIDTH => WIDTH
	)
	PORT MAP (
		clk => clk,
		rst => '0',
		enable => port2_en,
		input  => input,
		output => port2_out
	);
	
	U_outport : reg
	GENERIC MAP (
		WIDTH => WIDTH
	)
	PORT MAP (
		clk => clk,
		rst => rst,
		enable => outport_en,
		input  => write_data,
		output => LED_OUT
	);
	
	U_RAM : MIPS_RAM2
	PORT MAP (
		address => addr(9 downto 2),
		clock   => clk,
		data    => input,
		wren    => write_en,
		q       => RAM_out
	);
	
	
	--READ CONTROL
	process(addr, port1_out, port2_out, RAM_out)
	begin
		if addr(15 downto 0) < "10000000000" then
			read_sel <= "00";
		elsif addr(15 downto 0) = x"FFF8" then
			read_sel <= "01";
		elsif addr(15 downto 0) = x"FFFC" then
			read_sel <= "10";
		else
			read_sel <= "11";
		end if;
				
		case read_sel is
			when "00" =>
				output <= RAM_out;
			when "01" =>
				output <= port1_out;
			when "10" =>
				output <= port2_out;
			when others =>
				output <= (others => 'X');
		end case;
	end process;
	
	--WRITE CONTROL
	process(addr, mem_write)
	begin
		if mem_write = '1' AND addr(15 downto 0) < "10000000000" then
			write_en <= '1';
		else
			write_en <= '0';
		end if;
		
		if mem_write = '1' AND addr(15 downto 0) = x"FFFC" then
			outport_en <= '1';
		else
			outport_en <= '0';
		end if;
	end process;
	
	
END arch;