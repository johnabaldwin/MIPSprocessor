library ieee;
use ieee.std_logic_1164.all;
use work.MIPS_LIB.all;

entity top_level is
    port (
        clk50MHz : in  std_logic;
        switch   : in  std_logic_vector(9 downto 0);
        button   : in  std_logic_vector(1 downto 0);
        led0     : out std_logic_vector(6 downto 0);
        led0_dp  : out std_logic;
        led1     : out std_logic_vector(6 downto 0);
        led1_dp  : out std_logic;
        led2     : out std_logic_vector(6 downto 0);
        led2_dp  : out std_logic;
        led3     : out std_logic_vector(6 downto 0);
        led3_dp  : out std_logic;
        led4     : out std_logic_vector(6 downto 0);
        led4_dp  : out std_logic;
        led5     : out std_logic_vector(6 downto 0);
        led5_dp  : out std_logic
	);
end top_level;

architecture STR of top_level is
	
	
	
	signal rst : std_logic;
	
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
	signal LED_OUT     : std_logic_vector(GLOBAL_WIDTH - 1 downto 0);
	signal PORT_OUT    : std_logic_vector(GLOBAL_WIDTH - 1 downto 0);
begin  -- STR

	rst <= NOT button(1);

	U_Datapath : entity work.Datapath
	generic map (
		WIDTH => GLOBAL_WIDTH
	)
   port map (
		clk         => clk50MHz,
		rst         => rst,
		switch      => switch,
      button      => button,
		PCWriteCond => PCwriteCond,
		PCWrite     => PCWrite,
		IorD        => IorD,
		MemWrite    => MemWrite,
		MemToReg    => MemToReg,
		IRWrite     => IRWrite,
		JumpAndLink => JumpAndLink,
		IsSigned    => IsSigned,
		PCSource    => PCSource,
		ALUOp       => ALUOp,
		ALUSrcB     => SrcB,
		ALUSrcA     => SrcA,
		RegWrite    => RegWrite,
		RegDst      => RegDst,
		PORT_OUT    => PORT_OUT,
		LED_OUT     => LED_OUT,
		OpCode      => OpCode,
		ALUInstruct => instruction
	);

	U_Controller : entity work.Controller
   generic map (
		WIDTH => GLOBAL_WIDTH
	)
   port map (
		clk         => clk50MHz,
		rst         => rst,
		OpCode      => OpCode,
		ALUInstruct => instruction,
		PCWriteCond => PCWriteCond,
		PCWrite     => PCWrite,
		IorD        => IorD,
		MemWrite    => MemWrite,
		MemToReg    => MemToReg,
		IRWrite     => IRWrite,
		JumpAndLink => JumpAndLink,
		IsSigned    => IsSigned,
		PCSource    => PCSource,
		ALUOp       => ALUOp,
		ALUSrcB     => SrcB,
		ALUSrcA     => SrcA,
		RegWrite    => RegWrite,
		RegDst      => RegDst
	);


	U_LED5 : entity work.decode7seg port map (
		input  => LED_OUT(3 downto 0),
      output => led0);
		
	U_LED4 : entity work.decode7seg port map (
		input  => LED_OUT(7 downto 4),
      output => led1);
    
	U_LED3 : entity work.decode7seg port map (
		input  => LED_OUT(11 downto 8),
      output => led2);
		
	U_LED2 : entity work.decode7seg port map (
		input  => PORT_OUT(3 downto 0),
      output => led3);

	U_LED1 : entity work.decode7seg port map (
		input  => LED_OUT(19 downto 16),
      output => led4);

	U_LED0 : entity work.decode7seg port map (
		input  => LED_OUT(23 downto 20),
      output => led5);
    

	led5_dp <= '1';
   led4_dp <= '1';
   led3_dp <= '1';
   led2_dp <= switch(9) AND NOT button(0);
   led1_dp <= NOT switch(9) AND NOT button(0);
   led0_dp <= rst;

end STR;
