library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity DicePig is
	port(
		CLOCK_50 : in std_logic;
		key : in std_logic_vector(3 downto 0);
		HEX0, HEX4, HEX5 : out std_logic_vector(6 downto 0);
		HEX2, HEX6, HEX7 : out std_logic_vector(6 downto 0);
		HEX1, HEX3 : out std_logic_vector(6 downto 0);
		LEDR : out std_logic_vector(17 downto 0)
	);
end entity;

architecture behavioural of DicePig is
	component DEALCARD_2 is
		port(
			CLOCK, RESET : in std_logic;
			CARD         : out std_logic_vector(3 downto 0) -- value of next card
		);
	end component;
	component CARD7SEG is
		port(
	   	CARD : in  std_logic_vector(3 downto 0); -- value of card
	   	SEG7 : out std_logic_vector(6 downto 0)  -- 7-seg LED pattern
		);
	end component;
	component SUMADDER is 
		port(
			clk : in std_logic;
			input : in std_logic_vector(3 downto 0);
			output : out std_logic_vector(7 downto 0)
		);
	end component;
	
	signal card_sig : std_logic_vector(3 downto 0);
	signal p1card_sig, p2card_sig : std_logic_vector(3 downto 0);
	signal p1sum_sig, p2sum_sig : std_logic_vector(7 downto 0);
	
	signal p1roll_sig, p2roll_sig : std_logic;
begin
	-- instanciating components
	dice : DEALCARD_2 port map(CLOCK => CLOCK_50, RESET => not key(3), card => card_sig);
	
--	p1sum_count : SUMADDER port map(clk => CLOCK_50, input => p1card_sig, output => p1sum_sig);
--	p2sum_count : SUMADDER port map(clk => CLOCK_50, input => p2card_sig, output => p2sum_sig);
	
	p1card_dis : CARD7SEG port map(CARD => p1card_sig, SEG7 => HEX0);
	p1sum1_dis : CARD7SEG port map(CARD => p1sum_sig(3 downto 0), SEG7 => HEX4);
	p1sum2_dis : CARD7SEG port map(CARD => p1sum_sig(7 downto 4), SEG7 => HEX5);
	p2card_dis : CARD7SEG port map(CARD => p2card_sig, SEG7 => HEX2);
	p2sum1_dis : CARD7SEG port map(CARD => p2sum_sig(3 downto 0), SEG7 => HEX6);
	p2sum2_dis : CARD7SEG port map(CARD => p2sum_sig(7 downto 4), SEG7 => HEX7);
	
	-------------------------------------------------------------
	-- WE NEED TWO SEQUENTIAL PROCESSES!!!! One for each player
	-------------------------------------------------------------
	process(key(0), key(3))
		variable p1_rolls : std_logic_vector(3 downto 0) := "0000";
		variable p1roll : std_logic := '0';
	begin
		if(key(3) = '0') then
			p1sum_sig <= "00000000";
			p1card_sig <= "0000";
			p1_rolls := "0000";
			p1roll := '0';
			p1roll_sig <= p1roll;
		elsif(falling_edge(key(0))) then
			p1roll_sig <= p1roll;
			p1_rolls := p1_rolls + '1';
			if(p1_rolls < "1010") then
				p1roll := '1';
				p1card_sig <= card_sig;
				
				-- sum adder part
				if(p1card_sig = "0001") then
					p1sum_sig <= "00000000";
				elsif(p1sum_sig < x"3C") then
					p1sum_sig <= p1sum_sig + p1card_sig;
				else
					p1sum_sig <= x"3C";
				end if;
				
			end if;
		end if;
	end process;
	process(key(0), key(3))
		variable p2_rolls : std_logic_vector(3 downto 0) := "0000";
		variable p2roll : std_logic := '0';
	begin
		if(key(3) = '0') then
			p2sum_sig <= "00000000";
			p2card_sig <= "0000";
			p2_rolls := "0000";
			p2roll := '0';
			p2roll_sig <= p2roll;
		elsif(falling_edge(key(2))) then
			p2roll := '1';
			p2roll_sig <= p2roll;
			if(p2_rolls < "1010") then
				p2_rolls := p2_rolls + '1';
				p2card_sig <= card_sig;
				
				-- sum adder part
				if(p2card_sig = "0001") then
					p2sum_sig <= "00000000";
				elsif(p2sum_sig < x"3C") then
					p2sum_sig <= p2sum_sig + p2card_sig;
				else
					p2sum_sig <= x"3C";
				end if;
				
			end if;
		end if;
	end process;
	
	-- We need another process to determine the winner
	process(p1sum_sig, p2sum_sig, p1roll_sig, p2roll_sig)
	begin
		if(p1roll_sig = '1' and p2roll_sig = '1')then
			if(p1sum_sig = p2sum_sig) then
				LEDR(6) <= '0';
				LEDR(9) <= '0';
			elsif(p1sum_sig > p2sum_sig) then
				LEDR(6) <= '1';
				LEDR(9) <= '0';
			else
				LEDR(6) <= '0';
				LEDR(9) <= '1';
			end if;
		else
			LEDR(6) <= '0';
			LEDR(9) <= '0';
		end if;
	end process;
	
	-- just to turn off these two LEDS
	HEX1 <= "1111111";
	HEX3 <= "1111111";
end behavioural;