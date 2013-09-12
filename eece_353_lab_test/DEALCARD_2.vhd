
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

ENTITY DEALCARD_2 IS
	PORT(
		CLOCK, RESET : in std_logic;
	   CARD         : out std_logic_vector(3 downto 0) -- value of next card
		);
END;


architecture behavioural of DEALCARD_2 is
begin
	process (CLOCK, RESET)
		variable VALUE : std_logic_vector(3 downto 0) := x"1";
	begin
		if(RESET = '1') then
			VALUE := X"1";
		elsif(rising_edge(CLOCK)) then
			if(VALUE < x"6") then
			-- keep counting until 6
				VALUE := VALUE + x"1";
			else
				VALUE := x"1";
			end if;
			CARD <= VALUE;
		end if;
	end process;
end behavioural;

