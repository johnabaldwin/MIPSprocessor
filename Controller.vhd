library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.MIPS_LIB.all;

entity Controller is
   generic (WIDTH : positive := GLOBAL_WIDTH);
	port (
		clk         : in std_logic;
		rst         : in std_logic;
		OpCode      : in std_logic_vector(5 downto 0) := (others => '0'); 
		ALUInstruct : in std_logic_vector(5 downto 0) := (others => '0');
		PCWriteCond : out std_logic := '0';
		PCWrite     : out std_logic := '0';
		IorD        : out std_logic := '0';
		MemWrite    : out std_logic := '0';
		MemToReg    : out std_logic := '0';
		IRWrite     : out std_logic := '0';
		JumpAndLink : out std_logic := '0';
		IsSigned    : out std_logic := '0';
		PCSource    : out std_logic_vector(1 downto 0) := (others => '0');
		ALUOp       : out std_logic_vector(5 downto 0) := (others => '0');
		ALUSrcB     : out std_logic_vector(1 downto 0) := (others => '0');
		ALUSrcA     : out std_logic := '0';
		RegWrite    : out std_logic := '0';
		RegDst      : out std_logic := '0'
	);
end Controller;

architecture arch of Controller is

type StateType is (FETCH1, DELAY, FETCH2, DECODE, AddrComp, LOAD, 
	ReadComplete, STORE, EXECUTER, EXECUTEI, BRANCHADD, BRANCHCOMP, JUMP, LINK, RTYPE, ITYPE, HALTED);
signal curState  : StateType := FETCH1;
signal nextState : StateType := DELAY;
signal postDelay : StateType := FETCH2;

begin

	--NEXT STATE PROCESS
	process(clk, rst)
	begin
		if rst = '1' then
			curState <= FETCH1;
		elsif rising_edge(clk) then
			curState <= nextState;
		end if;
	end process;
	
	--OUTPUT PROCESS
	process(curState, clk)
	begin
		if rising_edge(clk) then 
			case curState is
				when FETCH1  =>
					
					IorD        <= '0';
					JumpAndLink <= '0';
					MemWrite    <= '0';
					RegWrite    <= '0';
					IsSigned    <= '0';
					PCWriteCond <= '0';
					PCWrite     <= '0';
					ALUOp       <= ADD;
					
				when DELAY =>
					--DO NOTHING
					PCWrite <= '0';
				
				when FETCH2 =>
				
					ALUSrcA  <= '0';
					IRWrite  <= '1';
					ALUSrcB  <= "01";
					ALUOp    <= ADD;
					PCSource <= "01";
				
				when DECODE =>
					
					IRWrite <= '0';
					ALUSrcA <= '0';
					ALUSrcB <= "11";
					ALUOp   <= "000000";
					PCWrite <= '1';
				
				when AddrComp =>
					
					PCWrite <= '0';
					ALUSrcA <= '1';
					ALUSrcB <= "10";
					ALUOp   <= Add;
				
				when LOAD =>
					
					IorD     <= '1';
					MemWrite <= '0';
					ALUSrcA  <= '1';
					ALUSrcB  <= "10";
					ALUOp    <= Add;
					IsSigned <= '0';
					
				when ReadComplete =>
				
					RegDst   <= '0';
					RegWrite <= '1';
					MemtoReg <= '1';
			
				when STORE =>
					
					MemWrite <= '1';
					IorD     <= '1';
				
				when EXECUTER =>

					ALUSrcA <= '1';
					ALUSrcB <= "00";
					ALUOp   <= RTYPEinstr;
					if ALUInstruct = JumpReg then
						PCWrite <= '1';
						PCSource <= "00";
					else
						PCWrite <= '0';
					end if;
				
				when EXECUTEI =>
				
					PCWrite <= '0';
					ALUSrcA <= '1';
					ALUSrcB <= "10";
					ALUOp   <= OpCode;
					RegDst  <= '0';
					
					if OpCode = XORi or OpCode = ORi or OpCode = ANDi then
						IsSigned <= '0';
					else
						IsSigned <= '1';
					end if;
				
				when ITYPE =>
					
					RegDst <= '0';
					RegWrite <= '1';
					MemtoReg <= '0';
				
				when BRANCHADD =>
					
					PCWrite     <= '0';
					PCWriteCond <= '0';
					ALUSrcA     <= '0';
					ALUSrcB     <= "11";
					ALUOp       <= Add; --Branch;
				
				when BRANCHCOMP =>
					
					PCWriteCond <= '1';
					PCSource    <= "01";
					ALUSrcA     <= '1';
					ALUSrcB     <= "00";
					ALUOp       <= OpCode;
				
				when JUMP =>
				
					PCWrite     <= '1';
					PCSource    <= "10";
					
				when LINK =>
					
					ALUSrcA     <= '0';
					ALUSrcB     <= "01";
					ALUOp       <= LinkReg;
					JumpAndLink <= '1';
					RegWrite    <= '1';
					MemToReg    <= '0';
								
				when RTYPE =>
					
					RegDst <= '1';
					RegWrite <= '1';
					MemtoReg <= '0';
					
				when HALTED =>
					
					PCWrite     <= '0';
					PCWriteCond <= '0';
					IRWrite     <= '0';
					MemWrite    <= '0';
					RegWrite    <= '0';
					
			end case;
		end if;
	
	end process;
	
	
	
	--STATE DEFINITION
	process(curState, postDelay, ALUInstruct, OpCode)
	begin
		nextState <= curState;
		
		case curState is
			when FETCH1  =>
				
				nextState <= DELAY;
				postDelay <= FETCH2;
			
			when DELAY =>
				
				nextState <= postDelay;
				
			when FETCH2 =>
			
				nextState <= DELAY;
				postDelay <= DECODE;
			
			when DECODE =>
				
				if OpCode = StoreWord or OpCode = LoadWord then
				
					nextState <= AddrComp;
				
				elsif OpCode = RTYPEinstr then
				
					nextState <= EXECUTER;
				
				elsif OpCode = BoE or OpCode = BnE or OpCode = BLTE0 or OpCode = BGT0 
							or OpCode = BGTE0 or OpCode = BLT0 then
					
					nextState <= BRANCHADD;
				
				elsif OpCode = JumpAddr then
					
					nextState <= JUMP;
				
				elsif OpCode = JumpLink then
				
					nextState <= LINK;
				
				elsif OpCode = HALT then
				
					nextState <= HALTED;
				
				else
					
					nextState <= EXECUTEI;
				
				end if;
				
				postDelay <= DELAY;
				
			when AddrComp =>
			
				case OpCode is
					when StoreWord =>
						nextState <= STORE;
						postDelay <= DELAY;
					when LoadWord =>
						nextState <= DELAY;
						postDelay <= LOAD;
					when others =>
						nextState <= FETCH1;
						postDelay <= DELAY;
				end case;
			
			when LOAD =>  -- 3
				
				nextState <= DELAY;
				postDelay <= ReadComplete;
			
			when ReadComplete => -- 4
				
				nextState <= FETCH1;
				postDelay <= DELAY;
				
			when STORE => -- 5
				
				nextState <= FETCH1;
				postDelay <= DELAY;
				
			when EXECUTER =>
			
				if ALUInstruct = Multiply OR ALUInstruct = MultiplyU then
					nextState <= DELAY;
					postDelay <= FETCH1;
				else
					nextState <= RTYPE;
				end if;
				postDelay <= DELAY;
			
			when RTYPE =>  -- 7
			
				nextState <= FETCH1;
				postDelay <= DELAY;
				
			when EXECUTEI =>
			
				nextState <= ITYPE;
				postDelay <= DELAY;
				
			when ITYPE =>
				
				nextState <= FETCH1;
				postDelay <= DELAY;
				
			when BRANCHADD =>  -- 8
			
				nextState <= BRANCHCOMP;
				postDelay <= DELAY;
				
			when BRANCHCOMP =>
			
				nextState <= FETCH1;
				postDelay <= DELAY;
				
			when JUMP =>  -- 9
				
				nextState <= FETCH1;
				postDelay <= DELAY;
				
			when LINK =>
				
				nextState <= JUMP;
				postDelay <= DELAY;
				
			when HALTED =>
				
				nextState <= HALTED;
				postDelay <= DELAY;
				
		end case;
	end process;
	
end architecture;