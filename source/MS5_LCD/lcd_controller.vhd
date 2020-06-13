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
-- source name: lcd_controller
-- Datum:       14.06.2020
-------------------------------------------

-------------------------------------------
-- Block code:  lcd_controller.vhd
-- Function:
-------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.reg_table_pkg.all;             -- Enthaelt Initialisierungsliste
use work.lcd_pkg.all;                   -- Enthaelt LCD Konstanten

-------------------------------------------------------------------------------

-- Entity Declaration 
entity lcd_controller is
  port (
    clk_12m     : in  std_logic;        -- 12.5 MHz Clock
    reset_n     : in  std_logic;        -- Reset
    char_i      : in  char_i_array_type;  -- Char-Array, welches auf den LCD geschrieben werden soll
    update_o    : out std_logic;        -- Aktualisierung des Displays
    char_num_o  : out std_logic_vector(4 downto 0);  -- Char Pos 0-31 (welcher Index)
    char_data_o : out std_logic_vector(7 downto 0)  -- Char Wert (welcher Buchstabe)
    );
end entity lcd_controller;

-------------------------------------------------------------------------------

architecture rtl of lcd_controller is

-----------------------------------------------------------------------------
-- Internal signal declarations
-----------------------------------------------------------------------------
  signal char_num, next_char_num : integer range 0 to 31;

begin

-------------------------------------------
-- Prozess fuer Clock
-------------------------------------------
  clk_proc : process(all)
  begin
    if (reset_n = '0') then  -- Asynchroner Reset => Starteinstellungen wiederherstellen
      char_num <= 0;
    elsif (rising_edge(clk_12m)) then  -- Zustand weitergeben, bei positiver Flanke des Clocks
      char_num <= next_char_num;
    end if;
  end process clk_proc;

-------------------------------------------
-- Prozess fuer Tick (zaehlt Index rauf)
-------------------------------------------
  -- Dieser Prozess zaehlt den Index der zu uebertragenden Buchstaben auf den Display
  counter_proc : process(all)
  begin
    next_char_num <= char_num;
    update_o      <= '0';
    if(char_num < 31) then
      update_o      <= '1';
      next_char_num <= char_num + 1;    -- Zaehler hochzaehlen
    else
      update_o      <= '1';
      next_char_num <= 0;               -- Zaehler zuruecksetzen
    end if;
  end process counter_proc;

-------------------------------------------
-- Concurrent assignments  
-------------------------------------------
  char_data_o <= char_i(char_num);                            -- Buchstabe
  char_num_o  <= std_logic_vector(to_unsigned(char_num, 5));  -- Index

end architecture rtl;
-------------------------------------------------------------------------------
