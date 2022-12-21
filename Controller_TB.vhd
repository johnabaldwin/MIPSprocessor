library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.MIPS_LIB.all;

entity Controller_TB is
end Controller_TB;

architecture TB of Controller_TB is

   constant TIMEOUT : time     := 1 ms;
   constant WIDTH   : positive := 32;

   signal clkEn       : std_logic := '1';
   signal clk         : std_logic := '0';
   signal rst         : std_logic := '1';
	signal OpCode      : std_logic_vector(5 downto 0);
	signal instruction : std_logic_vector(5 downto 0);
	signal PCWriteCond : std_logic;
	signal PCWrite     : std_logic;
	signal IorD        : std_logic;
	signal MemWrite    : std_logic;
	signal MemToReg    : std_logic;
	signal IRWrite     : std_logic;
	signal JumpAndLink : std_logic;
	signal IsSigned    : std_logic;
	signal PCSource    : std_logic_vector(1 downto 0);
	signal ALUOp       : std_logic_vector(5 downto 0);
	signal SrcB        : std_logic_vector(1 downto 0);
	signal SrcA        : std_logic;
	signal RegWrite    : std_logic;
	signal RegDst      : std_logic;
	
	signal switch_in : std_logic_vector(9 downto 0) := (others => '0');
	signal button_in : std_logic_vector(1 downto 0);
	
	signal LED0 : std_logic_vector(6 downto 0);
	signal LED1 : std_logic_vector(6 downto 0);
	signal LED2 : std_logic_vector(6 downto 0);
	signal LED3 : std_logic_vector(6 downto 0);
	signal LED4 : std_logic_vector(6 downto 0);
	signal LED5 : std_logic_vector(6 downto 0);
	
begin

	U_TopLevel : entity work.top_level
	port map(
        clk50MHz => clk,
        switch   => switch_in,
        button   => button_in,
        led0     => LED0,
        led0_dp  => open,
        led1     => LED1,
        led1_dp  => open,
        led2     => LED2,
        led2_dp  => open,
        led3     => LED3,
        led3_dp  => open,
        led4     => LED4,
        led4_dp  => open,
        led5     => LED5,
        led5_dp  => open
	);

	clk <= not clk and clkEn after 20 ns;
		
   process
	begin
		clkEn <= '1';
		button_in <= "00";
		wait for 10 ns;
		
		switch_in <= "1000000110";
		button_in <= "10";
		wait for 200 ns;
		button_in <= "01";
		wait for 20 ns;
		
		button_in <= "11";
		
		switch_in <= "0000000100";
		
		wait for 20 ns;
		
		button_in <= "00";
		
		wait for 200 ns;
		
		button_in <= "00";
		wait for 200 ns;
		button_in <= "10";
		
		wait for TIMEOUT;
		
		clkEn <= '0';
      report "DONE" severity note;

      wait;

	end process;

end TB;
