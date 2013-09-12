-- Xi Yuan Kevin Liu
-- 11304128
-- EECE 353 L1A
-- May 2nd 2013

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.all;

entity lab4_test is
	port(	 
		CLOCK_50	: in std_logic;
		KEY : in std_logic_vector(3 downto 0);
		SW  : in std_logic_vector(17 downto 0);
		VGA_R, VGA_G, VGA_B : out std_logic_vector(9 downto 0);
		VGA_HS : out std_logic;
		VGA_VS : out std_logic;
		VGA_BLANK : out std_logic;
		VGA_SYNC : out std_logic;
		VGA_CLK  : out std_logic
	);
end lab4_test;

architecture rtl of lab4_test is
	---- Component from the Verilog file: vga_adapter.v
	component vga_adapter 
		generic(RESOLUTION: string);
		port (	
			resetn : in std_logic;
			clock : in std_logic;
			colour : in std_logic_vector(2 downto 0);
			x : in std_logic_vector(7 downto 0);
			y : in std_logic_vector(6 downto 0);
			plot : in std_logic;
			VGA_R, VGA_G, VGA_B : out std_logic_vector(9 downto 0);
			VGA_HS, VGA_VS, VGA_BLANK, VGA_SYNC, VGA_CLK : out std_logic
		);
	end component;
	component SysClk 
		port(
			CLK : in std_logic;
			OUTPUT : out std_logic 
		);
	end component;

	signal resetn_sig : std_logic;
	signal x_sig : std_logic_vector(7 downto 0);
	signal y_sig : std_logic_vector(6 downto 0);
	signal delta_x : std_logic_vector(7 downto 0);
	signal delta_y : std_logic_vector(6 downto 0);
	signal colour_sig : std_logic_vector(2 downto 0);
	signal plot : std_logic;
	
begin
	resetn_sig <= KEY(3);
	delta_x <= SW(7 downto 0);
	delta_y <= SW(14 downto 8);
--	colour_sig <= SW(17 downto 15);
--	plot <= NOT key(0);
	vga_u0 : vga_adapter 
		---- Sets the resolution of display (as per vga_adapter.v description):
		generic map(RESOLUTION => "160x120")		
		port map(
			resetn => resetn_sig, 
			clock => CLOCK_50, 
			colour => colour_sig, 
			x => x_sig, 
			y => y_sig, 
			plot => plot, 
			VGA_R => VGA_R, 
			VGA_G => VGA_G, 
			VGA_B => VGA_B, 
			VGA_HS => VGA_HS, 
			VGA_VS => VGA_VS, 
			VGA_BLANK => VGA_BLANK, 
			VGA_SYNC => VGA_SYNC, 
			VGA_CLK => VGA_CLK
		);
	systemclk : SysClk port map ( CLK => CLOCK_50, OUTPUT => plot );

	process(plot, key(3))
		-- variables for ball 1:
		variable old_x1 : std_logic_vector(7 downto 0); -- some random x location
		variable new_x1 : std_logic_vector(7 downto 0) := "00111011";
		variable old_y1 : std_logic_vector(6 downto 0); -- some random y location
		variable new_y1 : std_logic_vector(6 downto 0) := "1001111";
		-- variables for ball 2:
		variable old_x2 : std_logic_vector(7 downto 0); 
		variable new_x2 : std_logic_vector(7 downto 0) := "10000000";
		variable old_y2 : std_logic_vector(6 downto 0); 
		variable new_y2 : std_logic_vector(6 downto 0) := "1000000";
		
		--Boundaries of the screen
		constant MAX_X : std_logic_vector(7 downto 0) := x"9E"; -- HEX 9F = DEC 158
		constant MIN_X : std_logic_vector(7 downto 0) := "00000001";
		constant MAX_Y : std_logic_vector(6 downto 0) := "1110110"; -- = DEC 118
		constant MIN_Y : std_logic_vector(6 downto 0) := "0000001";
		
--		type DIRECTION is (FORTH, BACK);
		variable dir_x1 : std_logic := '1'; -- 1 means forthward
		variable dir_y1 : std_logic := '1';
		variable dir_x2 : std_logic := '1';
		variable dir_y2 : std_logic := '1';
		
		-- variables for drawing edges:
		variable edge_x : std_logic_vector(7 downto 0) := "00000000";
		variable edge_y : std_logic_vector(6 downto 0) := "0000000";
		
		-- variables for status of two particles
		type LIVENESS is (LIVE, DEAD);
		variable dead_1 : LIVENESS := LIVE;
		variable dead_2 : LIVENESS := LIVE;
		
		type STATES is (	PREPARE_upperX, PREPARE_lowerX, PREPARE_leftY, PREPARE_rightY,
								ERASE1, DRAW1, ERASE2, DRAW2);
		variable PRESENT_STATE : STATES := ERASE1;
	begin
		if(key(3) = '0') then
			PRESENT_STATE := PREPARE_upperX;
			new_x1 := "00111011";
			new_y1 := "1001111";
			new_x2 := "10000000";
			new_y2 := "1000000";
			dir_x1 := '1';
			dir_y1 := '1';
			dir_x2 := '1';
			dir_y2 := '1';
			edge_x := "00000000";
			edge_y := "0000000";
			dead_1 := LIVE;
			dead_2 := LIVE;
		
		elsif(rising_edge(plot)) then
			case PRESENT_STATE is
				-- Preparing the boundaries
				when PREPARE_upperX =>	if(edge_x <= x"3B") then -- x"3B" = 59
													x_sig <= edge_x;
													y_sig <= "0000000";
													colour_sig <= "001"; -- "001" is blue
													edge_x := edge_x + '1';
												elsif (edge_x > x"3B" AND edge_x < x"63") then -- x"63" = 99
													edge_x := x"63";
												elsif (edge_x >= x"63" AND edge_x <= x"9F") then
													x_sig <= edge_x;
													y_sig <= "0000000";
													colour_sig <= "001";
													edge_x := edge_x + '1';
												else
													PRESENT_STATE := PREPARE_lowerX;
													edge_x := "00000000";
												end if;
				when PREPARE_lowerX =>	if(edge_x <= x"3B") then -- x"3B" = 59
													x_sig <= edge_x;
													y_sig <= "1110111";
													colour_sig <= "001"; -- "001" is blue
													edge_x := edge_x + '1';
												elsif (edge_x > x"3B" AND edge_x < x"63") then -- x"63" = 99
													edge_x := x"63";
												elsif (edge_x >= x"63" AND edge_x <= x"9F") then
													x_sig <= edge_x;
													y_sig <= "1110111";
													colour_sig <= "001";
													edge_x := edge_x + '1';
												else
													PRESENT_STATE := PREPARE_leftY;
													edge_x := "00000000";
												end if;
				when PREPARE_leftY =>	if(edge_y <= x"27") then
													x_sig <= "00000000";
													y_sig <= edge_y;
													colour_sig <= "001";
													edge_y := edge_y + '1';
												elsif(edge_y > x"27" AND edge_y < x"4F") then
													edge_y := "1001111";
												elsif(edge_y >= x"4F" AND edge_y <= x"77") then
													x_sig <= "00000000";
													y_sig <= edge_y;
													colour_sig <= "001";
													edge_y := edge_y + '1';
												else
													PRESENT_STATE := PrePARE_rightY;
													edge_y := "0000000";
												end if;
				when PREPARE_rightY =>	if(edge_y <= x"27") then
													x_sig <= x"9F";
													y_sig <= edge_y;
													colour_sig <= "001";
													edge_y := edge_y + '1';
												elsif(edge_y > x"27" AND edge_y < x"4F") then
													edge_y := "1001111";
												elsif(edge_y >= x"4F" AND edge_y <= x"77") then
													x_sig <= x"9F";
													y_sig <= edge_y;
													colour_sig <= "001";
													edge_y := edge_y + '1';
												else
													PRESENT_STATE := ERASE1;
													edge_y := "0000000";
												end if;
												
				-- logic for bouncing particles
				when ERASE1 =>	old_x1 := new_x1;
									old_y1 := new_y1;
									colour_sig <= "000"; -- "erasing" by setting the color of the old pixel to black
									x_sig <= old_x1;
									y_sig <= old_y1;
									PRESENT_STATE := DRAW1;
				when DRAW1 =>	-- if particle 1 is live, then draw it,
									if(dead_1 = LIVE) then
										-- deciding the direction of the particle
										if(old_x1 >= MAX_X) then
											dir_x1 := NOT dir_x1;
										elsif(old_x1 <= MIN_X) then
											dir_x1 := NOT dir_x1;
										end if; -- missing else case means keeping the previous state of dir_x1
										if(old_y1 >= MAX_Y) then
											dir_y1 := NOT dir_y1;
										elsif(old_y1 <= MIN_Y) then
											dir_y1 := NOT dir_y1;
										end if;
										
										-- with the direction decided, drawing it
										if(dir_x1 = '1') then
											-- normal condition
											new_x1 := old_x1 + delta_x;
										else
											-- bounce back condition:
											new_x1 := old_x1 + NOT (delta_x) + '1'; -- 2's complement
										end if;
										if(dir_y1 = '1') then
											new_y1 := old_y1 + delta_y;
										else
											new_y1 := old_y1 + NOT (delta_y) + '1';
										end if;
										
										-- deciding the status of this particle
										if((new_x1 = "00000001" AND (new_y1 > "100111" AND new_y1 < "1001111")) OR
											(new_y1 = "0000001" AND (new_x1 > "111011" AND new_x1 < "1100011")) OR
											(new_x1 = "10011110" AND (new_y1 > "100111" AND new_y1 < "1001111")) OR
											(new_y1 = "1110110" AND (new_x1 > "111011" AND new_x1 < "1100011"))
											) then
											-- dead condition
											dead_1 := DEAD;
										end if;
									
										if(dead_1 = LIVE) then
											-- last, set the color, output the variable to signal, update state:
											colour_sig <= SW(17 downto 15);
											x_sig <= new_x1;
											y_sig <= new_y1;
											PRESENT_STATE := ERASE2;
										else
											colour_sig <= "000";
											x_sig <= new_x1;
											y_sig <= new_y1;
											PRESENT_STATE := ERASE1;
										end if;
									-- if it is dead, then move to next state
									else
										PRESENT_STATE := ERASE2;
									end if;
				when ERASE2 =>	old_x2 := new_x2;
									old_y2 := new_y2;
									colour_sig <= "000"; -- "erasing" by setting the color of the old pixel to black
									x_sig <= old_x2;
									y_sig <= old_y2;
									PRESENT_STATE := DRAW2;
				when others =>	if(dead_2 = LIVE) then
										if(old_x2 >= MAX_X) then
											dir_x2 := NOT dir_x2;
										elsif(old_x2 <= MIN_X) then
											dir_x2 := NOT dir_x2;
										end if;
										if(old_y2 >= MAX_Y) then
											dir_y2 := NOT dir_y2;
										elsif(old_y2 <= MIN_Y) then
											dir_y2 := NOT dir_y2;
										end if;
										
										if(dir_x2 = '1') then
											new_x2 := old_x2 + delta_x;
										else
											-- bounce back condition:
											new_x2 := old_x2 + NOT (delta_x) + '1'; -- 2's complement
										end if;
										if(dir_y2 = '1') then
											new_y2 := old_y2 + delta_y;
										else
											new_y2 := old_y2 + NOT (delta_y) + '1';
										end if;
										
										if((new_x2 = "00000001" AND (new_y2 > "100111" AND new_y2 < "1001111")) OR
											(new_y2 = "0000001" AND (new_x2 > "111011" AND new_x2 < "1100011")) OR
											(new_x2 = "10011110" AND (new_y2 > "100111" AND new_y2 < "1001111")) OR
											(new_y2 = "1110110" AND (new_x2 > "111011" AND new_x2 < "1100011"))
											) then
											-- dead condition
											dead_2 := DEAD;
										end if;
										
										if(dead_2 = LIVE) then
											-- last, set the color, output the variable to signal, update state:
											colour_sig <= SW(17 downto 15);
											x_sig <= new_x2;
											y_sig <= new_y2;
											PRESENT_STATE := ERASE1;
										else
											colour_sig <= "000";
											x_sig <= new_x2;
											y_sig <= new_y2;
											PRESENT_STATE := ERASE1;
										end if;
									else
										PRESENT_STATE := ERASE1;
									end if;
			end case;
		end if;
	end process;	
end rtl;
