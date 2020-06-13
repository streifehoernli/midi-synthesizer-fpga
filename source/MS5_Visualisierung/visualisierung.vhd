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
-- source name: visualisierung
-- Datum:       14.06.2020
-------------------------------------------

-------------------------------------------
-- Block code:  counter.vhd
-- Function: counter with generic width.
-------------------------------------------

-- Library & Use Statements
-------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.tone_gen_pkg.all;

-- Entity Declaration 
-------------------------------------------
entity visualisierung is
  port(
	   audiodata_i : in  std_logic_vector(15 downto 0);
      led_o       : out std_logic_vector(17 downto 0);
		switch		: in	std_logic
       );
end visualisierung;

-- Architecture Declaration 
-------------------------------------------
architecture rtl of visualisierung is
-- Signals & Constants Declaration 
-------------------------------------------
	signal data_s : signed(N_AUDIO-1 downto 0);

-- Begin Architecture
-------------------------------------------
begin
	
  --------------------------------------------------
  -- CONCURRENT ASSIGNMENT
  --------------------------------------------------
	data_s <= signed(audiodata_i);
	
	led_o <=		"111111111111111111" WHEN (data_s >= 36000 OR data_s <= -36000) AND switch = '1'
			 ELSE "011111111111111111" WHEN (data_s >= 34000 OR data_s <= -34000) AND switch = '1'
			 ELSE "001111111111111111" WHEN (data_s >= 32000 OR data_s <= -32000) AND switch = '1'
			 ELSE	"000111111111111111" WHEN (data_s >= 30000 OR data_s <= -30000) AND switch = '1'
			 ELSE	"000011111111111111" WHEN (data_s >= 28000 OR data_s <= -28000) AND switch = '1'
			 ELSE	"000001111111111111" WHEN (data_s >= 26000 OR data_s <= -26000) AND switch = '1'
			 ELSE	"000000111111111111" WHEN (data_s >= 24000 OR data_s <= -24000) AND switch = '1'
			 ELSE	"000000011111111111" WHEN (data_s >= 22000 OR data_s <= -22000) AND switch = '1'
			 ELSE	"000000001111111111" WHEN (data_s >= 20000 OR data_s <= -20000) AND switch = '1'
			 ELSE	"000000000111111111" WHEN (data_s >= 18000 OR data_s <= -18000) AND switch = '1'
			 ELSE	"000000000011111111" WHEN (data_s >= 16000 OR data_s <= -16000) AND switch = '1'
			 ELSE	"000000000001111111" WHEN (data_s >= 14000 OR data_s <= -14000) AND switch = '1'
			 ELSE	"000000000000111111" WHEN (data_s >= 12000 OR data_s <= -12000) AND switch = '1'
			 ELSE	"000000000000011111" WHEN (data_s >= 10000 OR data_s <= -10000) AND switch = '1'
			 ELSE	"000000000000001111" WHEN (data_s >=  8000 OR data_s <= -8000)  AND switch = '1'
			 ELSE	"000000000000000111" WHEN (data_s >=  6000 OR data_s <= -6000)  AND switch = '1'
			 ELSE	"000000000000000011" WHEN (data_s >=  4000 OR data_s <= -4000)  AND switch = '1'
			 ELSE	"000000000000000001" WHEN (data_s >=  2000 OR data_s <= -2000)  AND switch = '1'
			 
			 ELSE "111111111111111111" WHEN (data_s >= 5000 OR data_s <= -5000) AND switch = '0'
			 ELSE "011111111111111111" WHEN (data_s >= 4500 OR data_s <= -4500) AND switch = '0'
			 ELSE "001111111111111111" WHEN (data_s >= 4000 OR data_s <= -4000) AND switch = '0'
			 ELSE	"000111111111111111" WHEN (data_s >= 3750 OR data_s <= -3750) AND switch = '0'
			 ELSE	"000011111111111111" WHEN (data_s >= 3500 OR data_s <= -3500) AND switch = '0'
			 ELSE	"000001111111111111" WHEN (data_s >= 3250 OR data_s <= -3250) AND switch = '0'
			 ELSE	"000000111111111111" WHEN (data_s >= 3000 OR data_s <= -3000) AND switch = '0'
			 ELSE	"000000011111111111" WHEN (data_s >= 2750 OR data_s <= -2700) AND switch = '0'
			 ELSE	"000000001111111111" WHEN (data_s >= 2500 OR data_s <= -2500) AND switch = '0'
			 ELSE	"000000000111111111" WHEN (data_s >= 2250 OR data_s <= -2250) AND switch = '0'
			 ELSE	"000000000011111111" WHEN (data_s >= 2000 OR data_s <= -2000) AND switch = '0'
			 ELSE	"000000000001111111" WHEN (data_s >= 1750 OR data_s <= -1750) AND switch = '0'
			 ELSE	"000000000000111111" WHEN (data_s >= 1500 OR data_s <= -1500) AND switch = '0'
			 ELSE	"000000000000011111" WHEN (data_s >= 1250 OR data_s <= -1250) AND switch = '0'
			 ELSE	"000000000000001111" WHEN (data_s >= 1000 OR data_s <= -1000) AND switch = '0'
			 ELSE	"000000000000000111" WHEN (data_s >=  750 OR data_s <= -750)  AND switch = '0'
			 ELSE	"000000000000000011" WHEN (data_s >=  500 OR data_s <= -500)  AND switch = '0'
			 ELSE	"000000000000000001" WHEN (data_s >=  250 OR data_s <= -250)  AND switch = '0'
			 ELSE	"000000000000000000";		 

-- End Architecture 
------------------------------------------- 
end rtl;

