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
-- source name: i2s_decoder
-- Datum:       14.06.2020
-------------------------------------------

-------------------------------------------
-- Block code:  i2s_decoder.vhd
-- Function:    i2s Master, listens to a counter and decides which register needs to be
--				written to / read from.
-------------------------------------------

-- Library & Use Statements
-------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- Entity Declaration 
-------------------------------------------
entity i2s_decoder is
  port(bit_cntr_i 	: in  std_logic_vector(6 downto 0);
       shift_l      : out std_logic;
       shift_r      : out std_logic;
       load	        : out std_logic;
       ws	        : out std_logic
       );
end i2s_decoder;

-- Architecture Declaration�
-------------------------------------------
architecture rtl of i2s_decoder is
-- Signals & Constants Declaration�
-------------------------------------------
signal count 		: integer;
-- Begin Architecture
-------------------------------------------
begin

  --------------------------------------------------
  -- PROCESS FOR COMBINATORIAL LOGIC
  --------------------------------------------------
  comb_logic : process(bit_cntr_i, count)				-- bst -- added count to sensitivity list 
  begin
	count <= to_integer(unsigned(bit_cntr_i));
  
    -- default assignments
	shift_l <= '0';
	shift_r <= '0';
	load 	<= '0';
	
	case count is
	when 0 => load <= '1';
	when 1 to 16  => shift_l <= '1';
	when 65 to 80 => shift_r <= '1';
	when others => null;
	end case;
	
	
	if count < 64 then 
		ws <= '0';
	else 
		ws <= '1';
	end if;
	
  end process comb_logic;



  --------------------------------------------------
  -- CONCURRENT ASSIGNMENTS
  --------------------------------------------------


-- End Architecture 
------------------------------------------- 
end rtl;

