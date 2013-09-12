LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

ENTITY card7seg IS
	PORT(
		card : IN  STD_LOGIC_VECTOR(3 DOWNTO 0);  -- card type (Ace, 2..10, J, Q, K)
		seg7 : OUT STD_LOGIC_VECTOR(6 DOWNTO 0)   -- top seg 'a' = bit0, proceed clockwise
	);
END;


ARCHITECTURE behavioral OF card7seg IS
BEGIN

	PROCESS( card )
	BEGIN
			IF    card = "0000" THEN  seg7 <= "1000000"; -- 0/blank
			ELSIF card = "0001" THEN  seg7 <= "1111001"; -- 1
			--ELSIF card = "0001" THEN  seg7 <= "0001000"; -- A,    "1111001"; -- 1
			ELSIF card = "0010" THEN  seg7 <= "0100100"; -- 2
			ELSIF card = "0011" THEN  seg7 <= "0110000"; -- 3
			ELSIF card = "0100" THEN  seg7 <= "0011001"; -- 4
			ELSIF card = "0101" THEN  seg7 <= "0010010"; -- 5
			ELSIF card = "0110" THEN  seg7 <= "0000010"; -- 6
			ELSIF card = "0111" THEN  seg7 <= "1111000"; -- 7
			ELSIF card = "1000" THEN  seg7 <= "0000000"; -- 8
			ELSIF card = "1001" THEN  seg7 <= "0010000"; -- 9
			--ELSIF card = "1010" THEN  seg7 <= "1000000"; -- 0
			elsif card = "1010" THEN seg7 <= "0001000"; -- A
			--ELSIF card = "1011" THEN  seg7 <= "1100001"; -- J
			--ELSIF card = "1100" THEN  seg7 <= "0011000"; -- q
			--ELSIF card = "1101" THEN  seg7 <= "0001001"; -- K
			--ELSIF card = "1110" THEN  seg7 <= "0000110"; -- F n/a
			--ELSE                      seg7 <= "0001110"; -- F n/a
			ELSIF card = "1011" THEN  seg7 <= "0000011"; -- B
			ELSIF card = "1100" THEN  seg7 <= "1000110"; -- C
			ELSIF card = "1101" THEN  seg7 <= "0100001"; -- D
			ELSIF card = "1110" THEN  seg7 <= "0000110"; -- E
			ELSE                   seg7 <= "0001110"; -- F
			END IF;
	END PROCESS;

END;
