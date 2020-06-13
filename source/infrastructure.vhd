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
-- source name: infrastructure
-- Datum:       14.06.2020
-------------------------------------------

-------------------------------------------
-- Block code:  infrastructure.vhd
-- Function: Synchronises the signal to the clock
-------------------------------------------

-- Library & Use Statements
-------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.all;


-- Entity Declaration
-------------------------------------------
ENTITY infrastructure IS
  PORT( clk_50         : IN    std_logic;
        key_0_i        : IN    std_logic;
        key_1_i        : IN    std_logic;
        sw_17_0_i      : IN    std_logic_vector(17 downto 0);
        gpio_26_i      : IN    std_logic;
        clk_12m_o      : OUT   std_logic;
        reset_n_o      : OUT   std_logic;
        key_1_sync_o   : OUT   std_logic;
        gpio_26_sync_o : OUT   std_logic;
        sw_17_0_sync_o : OUT   std_logic_vector(17 downto 0)
      );
END infrastructure;


-- Architecture Declaration
-------------------------------------------
ARCHITECTURE rtl OF infrastructure IS
-- Signals & Constants Declaration
-------------------------------------------
  signal clk_12m_int : std_logic;

  component modulo_divider is
    generic (
      width      : positive);
    port (
      clk, reset_n : IN  std_logic;
      clk_12m      : OUT std_logic);
  end component modulo_divider;
  
  component synchronize is
    generic (
      width      : positive);
    port (
      signal_i : in  std_logic_vector(width-1 downto 0);
      clk_12m  : in  std_logic;
      signal_o : out std_logic_vector(width-1 downto 0)
    );
  end component synchronize;

-- Begin Architecture
-------------------------------------------
BEGIN
  
  takt_inst: modulo_divider
    generic map (
      width      => 2 )
    port map (
      clk     => clk_50,
      reset_n => '1',
      clk_12m => clk_12m_int);

  sync_inst_1: synchronize
    generic map (
      width      => 1 )
    port map (
      signal_i(0) => key_0_i,
      signal_o(0) => reset_n_o,
      clk_12m  => clk_12m_int);

  sync_inst_2: synchronize
    generic map (
      width      => 1 )
    port map (
      signal_i(0) => not(key_1_i),
      signal_o(0) => key_1_sync_o,
      clk_12m  => clk_12m_int);

  sync_inst_3: synchronize
    generic map (
      width      => 18 )
    port map (
      signal_i => sw_17_0_i,
      signal_o => sw_17_0_sync_o,
      clk_12m  => clk_12m_int);

  sync_inst_4: synchronize
    generic map (
      width      => 1 )
    port map (
      signal_i(0) => gpio_26_i,
      signal_o(0) => gpio_26_sync_o,
      clk_12m  => clk_12m_int);
  

  clk_12m_o <= clk_12m_int;

 -- End Architecture
-------------------------------------------
END rtl;
