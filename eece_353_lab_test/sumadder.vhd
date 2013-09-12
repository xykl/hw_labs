library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity SUMADDER is
	port(
		clk : in std_logic;
		input : in std_logic_vector(3 downto 0);
		output : out std_logic_vector(7 downto 0)
	);
end entity;

architecture behavioural of SUMADDER is
	signal sum : std_logic_vector(7 downto 0);
begin
	process(clk) -- process to update the sum
	begin
		if(rising_edge(clk)) then
			if(input = "0001") then
			-- clearing it back to 0
				sum <= x"0";
			elsif( sum < x"3C") then
				sum <=  sum + input;
			else
			-- in our rule, sum will not really exceed 60
				sum <= sum;
			end if;
		end if;
	end process;
	
	-- process for outputing the sum
	output <= sum;
end behavioural;