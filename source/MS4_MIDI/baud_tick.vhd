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
-- source name: baud_tick
-- Datum:       14.06.2020
-------------------------------------------

-------------------------------------------
-- Block code:  baud_tick.vhd
-- Function: Generates a tick in the middle of each bit of a UART signal
-------------------------------------------

-- Library & Use Statements
-------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;
use ieee.math_real.log2;
use ieee.math_real.ceil;


-- Entity Declaration
-------------------------------------------
ENTITY baud_tick IS
  GENERIC ( baud_rate  : positive := 115_200;
            clock_rate : positive := 50_000_000 );

  PORT( clk,reset_n  : IN    std_logic;
        start_i      : IN    std_logic;
        tick_o       : OUT   std_logic
      );
END baud_tick;


-- Architecture Declaration
-------------------------------------------
ARCHITECTURE rtl OF baud_tick IS
-- Signals & Constants Declaration
-------------------------------------------
constant count_width : integer := integer(ceil(log2(real(clock_rate / baud_rate))));
constant max_count   : unsigned(count_width - 1 downto 0) := to_unsigned(clock_rate / baud_rate, count_width);
constant start_count : unsigned(count_width - 1 downto 0) := to_unsigned(clock_rate / baud_rate / 2, count_width);

signal count, next_count : unsigned(count_width - 1 downto 0);


-- Begin Architecture
-------------------------------------------
BEGIN

  --------------------------------------------------
  -- PROCESS FOR COMBINATORIAL LOGIC
  --------------------------------------------------
  comb_logic: PROCESS(start_i,count)
  BEGIN
    -- start
    IF (start_i = '1') THEN
      next_count <= start_count;
    ELSE
      next_count <= count + 1;
    END IF;

    if (count >= (max_count-1)) then
      next_count <= (others=>'0');
    end if;
  END PROCESS comb_logic;

  --------------------------------------------------
  -- PROCESS FOR REGISTERS
  --------------------------------------------------
  flip_flops : PROCESS(clk, reset_n)
  BEGIN
    IF reset_n = '0' THEN
      count <= (others=>'0');
    ELSIF rising_edge(clk) THEN
      count <= next_count ;
    END IF;
  END PROCESS flip_flops;


  --------------------------------------------------
  -- CONCURRENT ASSIGNMENTS
  --------------------------------------------------
  tick_o <= '1' when (count = 0) else '0';


 -- End Architecture
-------------------------------------------
END rtl;
