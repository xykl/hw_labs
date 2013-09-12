library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.all;

entity SysClk is
	port(
		CLK : in std_logic; -- the clock signal going to be slowed down
		OUTPUT : out std_logic -- the slowed down clock
	);
end entity;

architecture behavioural of SysClk is
begin
	process(CLK)
		constant max : std_logic_vector(17 downto 0) := "110010110111011110"; -- 208350
		constant min : std_logic_vector(17 downto 0) := "000000000000000000";
		variable value : std_logic_vector(17 downto 0) := min;
		variable sig : std_logic := '0';
	begin
		if(rising_edge(CLK)) then
			if(value <= max) then 
				value := value + '1';
			else
				value := min;
				sig := NOT sig; -- alter the signal
				OUTPUT <= sig;
			end if;
		end if;
	end process;
end behavioural;