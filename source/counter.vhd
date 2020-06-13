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
-- source name: counter
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

-- Entity Declaration 
-------------------------------------------
entity counter is
  generic (width : positive := 5);
  port(clk 		 : in  std_logic;
	   clk_count : in  std_logic;
	   reset_n   : in  std_logic;
       counter   : out std_logic_vector(width-1 downto 0)
       );
end counter;

-- Architecture Declaration 
-------------------------------------------
architecture rtl of counter is
-- Signals & Constants Declaration 
-------------------------------------------
  signal count, next_count : unsigned(width-1 downto 0) := (others => '0');
-- Begin Architecture
-------------------------------------------
begin

  --------------------------------------------------
  -- PROCESS FOR COMBINATORIAL LOGIC
  --------------------------------------------------
  comb_logic : process(count,clk_count)
  begin
	next_count <= count;
    
	-- increment        
	if clk_count = '1' then 
		next_count <= count + 1;
	end if;
  end process comb_logic;

  --------------------------------------------------
  -- PROCESS FOR REGISTERS
  --------------------------------------------------
  flip_flops : process(clk, reset_n)
  begin
    if reset_n = '0' then
      count <= to_unsigned(0, width);
    elsif rising_edge(clk) then
		count <= next_count;
    end if;
  end process flip_flops;

  --------------------------------------------------
  -- CONCURRENT ASSIGNMENTS
  --------------------------------------------------
	counter <= std_logic_vector(count);

-- End Architecture 
------------------------------------------- 
end rtl;

