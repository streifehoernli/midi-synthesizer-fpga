-------------------------------------------
-- ZHAW School of Engineering
-- Technikumstrasse 9
-- 8401 Winterthur
--
-- Autoren:
-- Beat Sturzenegger
-- Markus Bodenmann
-- Tharmelan Theivanesan
--
-- source name: shiftreg_s2p
-- Datum:       14.06.2020
-------------------------------------------

LIBRARY ieee;
USE ieee.std_logic_1164.all;


ENTITY shiftreg_s2p IS
GENERIC (width		: positive  := 4 );
	PORT( clk				: IN   std_logic;
		  shift_i			: IN   std_logic;
		  enable_i			: IN   std_logic;
		  ser_i 		    : IN   std_logic;
	      par_o             : OUT  std_logic_vector(width - 1 downto 0)
	    );
END shiftreg_s2p;


ARCHITECTURE rtl OF shiftreg_s2p IS
signal data, next_data: std_logic_vector(width-1 downto 0);

BEGIN

	comb_logic : PROCESS(all)
	BEGIN
		if (enable_i = '1') AND (shift_i = '1') then
			next_data <=  data(width-2 downto 0) & ser_i;
		else
			next_data <= data;
		end if;
	END PROCESS;


	flip_flops : PROCESS(all)
	BEGIN
		if (rising_edge(clk)) then
			data <= next_data;
		end if;

	END PROCESS;

    par_o <= data;

END rtl;
