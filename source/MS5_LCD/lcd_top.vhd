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
-- source name: lcd_top
-- Datum:       14.06.2020
-------------------------------------------

-------------------------------------------
-- Block code:  lcd_top.vhd
-- Function:
-------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.tone_gen_pkg.all;
use work.lcd_pkg.all;                   -- Enthaelt LCD Konstanten

-------------------------------------------------------------------------------

-- Entity Declaration 
entity lcd_top is
  port(
    clk      : in  std_logic;                      -- 12.5 MHz Clock
    reset_n  : in  std_logic;                      -- Reset
    switch_i : in  std_logic_vector(17 downto 0);  -- Schalterstellung
    lcdRS    : out std_logic;                      -- LCD Ausgang RS
    lcdE     : out std_logic;                      -- LCD Ausgang Enable
    lcdData  : out std_logic_vector(3 downto 0)    -- LCD Daten Ausgang
    );
end lcd_top;

-------------------------------------------------------------------------------

architecture rtl of lcd_top is

-----------------------------------------------------------------------------
-- Component declarations
-----------------------------------------------------------------------------
  component lcd_driver
    generic (CLK_FREQ : positive := 12_500_000);  -- Clockfrequenz
    port(
      clk_12m : in std_logic;                     -- 12.5 MHz Clock
      reset_n : in std_logic;                     -- Reset

      -- Display Buffer Interface   
      wEn     : in std_logic;           -- Write Enable       
      charNum : in std_logic_vector(4 downto 0);  -- wird intern zu integer gewandelt range 0 to 31; 
      dIn     : in std_logic_vector(7 downto 0);  -- Data in

      -- LCD Interface
      lcdRS   : out std_logic;                    -- LCD RS
      lcdE    : out std_logic;                    -- LCD Enable
      lcdData : out std_logic_vector(3 downto 0)  -- LCD Data
      );
  end component;

  component lcd_controller
    port(
      clk_12m     : in  std_logic;      -- 12.5 MHz Clock
      reset_n     : in  std_logic;      -- Reset
      char_i      : in  char_i_array_type;  -- Char-Array, welches auf den LCD geschrieben werden soll
      update_o    : out std_logic;      -- Aktualisierung des Displays
      char_num_o  : out std_logic_vector(4 downto 0);  -- Char Pos 0-31 (welcher Index)
      char_data_o : out std_logic_vector(7 downto 0)  -- Char Wert (welcher Buchstabe)
      );
  end component;

  component lcd_ui
    port (
      clk_12m  : in  std_logic;         -- 12.5 MHz Clock
      reset_n  : in  std_logic;         -- Reset
      switch_i : in  std_logic_vector(17 downto 0);  -- Schalterstellung
      char_o   : out char_i_array_type  -- Char-Array, welches auf den LCD geschrieben werden soll
      );
  end component;

-----------------------------------------------------------------------------
-- Internal signal declarations
-----------------------------------------------------------------------------
  signal update_tick : std_logic;
  signal char_num    : std_logic_vector(4 downto 0);
  signal data_in     : std_logic_vector(7 downto 0);
  signal char_data   : char_i_array_type;

begin
-----------------------------------------------------------------------------
-- Component instantiations
-----------------------------------------------------------------------------
  inst1_lcd_driver : lcd_driver
    generic map (CLK_FREQ => 12_500_000)
    port map(
      clk_12m => clk,
      reset_n => reset_n,
      wEn     => update_tick,
      charNum => char_num,
      dIn     => data_in,
      lcdData => lcdData,
      lcdRS   => lcdRS,
      lcdE    => lcdE
      );

  inst1_lcd_controller : lcd_controller
    port map(
      clk_12m     => clk,
      reset_n     => reset_n,
      char_i      => char_data,
      update_o    => update_tick,
      char_num_o  => char_num,
      char_data_o => data_in
      );

  inst1_lcd_ui : lcd_ui
    port map(
      clk_12m  => clk,
      reset_n  => reset_n,
      switch_i => switch_i,
      char_o   => char_data
      );

end rtl;
