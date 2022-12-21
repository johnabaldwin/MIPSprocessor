library ieee;
use ieee.std_logic_1164.all;

package MIPS_LIB is


	-----------------------------------------------------------------------------
	-- DEVICE GLOBAL VALUES
	
	constant GLOBAL_WIDTH : positive := 32;
	constant SYS_ERROR    : std_logic_vector(GLOBAL_WIDTH - 1 downto 0) := "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX";
	constant HALT         : std_logic_vector(5 downto 0) := "111111";

	-----------------------------------------------------------------------------
	-- CONSTANTS FOR INPUTS
	constant ZERO_EXTEND  : std_logic_vector(22 downto 0) := (others => '0');
	constant FOUR         : std_logic_vector(GLOBAL_WIDTH - 1 downto 0) := "00000000000000000000000000000100";
	constant JumpLinkAddr : positive := 31;
	
	-----------------------------------------------------------------------------
	--SIGNS
	constant ONES   : std_logic_vector(15 downto 0) := (others => '1');
	constant ZEROES : std_logic_vector(15 downto 0) := (others => '0');

	-----------------------------------------------------------------------------
	--ALU Commands
	constant Add         : std_logic_vector(5 downto 0) := "100001";
	constant Subtract    : std_logic_vector(5 downto 0) := "100011";
	constant Multiply    : std_logic_vector(5 downto 0) := "011000";
	constant MultiplyU   : std_logic_vector(5 downto 0) := "011001";
	constant ALU_AND     : std_logic_vector(5 downto 0) := "100100";
	constant ALU_OR      : std_logic_vector(5 downto 0) := "100101";
	constant ALU_XOR     : std_logic_vector(5 downto 0) := "100110";
	constant ShiftRightL : std_logic_vector(5 downto 0) := "000010";
	constant ShiftLeftL  : std_logic_vector(5 downto 0) := "000000";
	constant ShiftRightA : std_logic_vector(5 downto 0) := "000011";
	constant LessThanS   : std_logic_vector(5 downto 0) := "101010";
	constant LessThanU   : std_logic_vector(5 downto 0) := "101011";
	constant MoveHi      : std_logic_vector(5 downto 0) := "010000";
	constant MoveLo      : std_logic_vector(5 downto 0) := "010010";
	constant JumpReg     : std_logic_vector(5 downto 0) := "001000"; 
	constant LinkReg     : std_logic_vector(5 downto 0) := "110001";
	constant AddBranch   : std_logic_vector(5 downto 0) := "111001";
	
	-----------------------------------------------------------------------------	
	--OP CODES
		--RTYPE & ITYPE
		constant RTYPEinstr : std_logic_vector(5 downto 0) := (others => '0');
		
		--LW/SW
		constant LoadWord   : std_logic_vector(5 downto 0) := "100011";
		constant StoreWord  : std_logic_vector(5 downto 0) := "101011";
				
		--Immediate commands
		constant ANDi       : std_logic_vector(5 downto 0) := "001100";
		constant ORi        : std_logic_vector(5 downto 0) := "001101";
		constant XORi       : std_logic_vector(5 downto 0) := "001110";
		constant ADDi       : std_logic_vector(5 downto 0) := "001001";
		constant SUBi       : std_logic_vector(5 downto 0) := "010000";
		constant LessThanSi : std_logic_vector(5 downto 0) := "001010";
		constant LessThanUi : std_logic_vector(5 downto 0) := "001011";
		
		--branch
		constant BoE        : std_logic_vector(5 downto 0) := "000100";
		constant BnE        : std_logic_vector(5 downto 0) := "000101";
		constant BLTE0      : std_logic_vector(5 downto 0) := "000110";
		constant BGT0       : std_logic_vector(5 downto 0) := "000111";
		constant BLT0       : std_logic_vector(5 downto 0) := "000001";
		constant BGTE0      : std_logic_vector(5 downto 0) := "000001";
		
		--jump
		constant JumpAddr   : std_logic_vector(5 downto 0) := "000010";
		constant JumpLink   : std_logic_vector(5 downto 0) := "000011";
	
end MIPS_LIB;
