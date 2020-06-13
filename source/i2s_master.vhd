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
-- source name: i2s_master
-- Datum:       14.06.2020
-------------------------------------------


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-------------------------------------------------------------------------------

entity i2s_master is

  port (
    clk_12m	    : in     std_logic;
    dacdat_pl_i : in     std_logic_vector(15 downto 0);
    dacdat_pr_i : in     std_logic_vector(15 downto 0);
    dacdat_s_o  : out    std_logic;
    reset_n     : in     std_logic;
    adcdat_pl_o : out    std_logic_vector(15 downto 0);
    adcdat_pr_o : out    std_logic_vector(15 downto 0);
    load_o      : out    std_logic;
    adcdat_s_i  : in     std_logic;
    bclk_o      : out    std_logic;
    ws_o        : out    std_logic
    );

end entity i2s_master;

-------------------------------------------------------------------------------

architecture rtl of i2s_master is
  --SIGNALS
  signal BCLK_INT   : std_logic;
  signal load       : std_logic;
  signal shift_l    : std_logic;
  signal shift_r    : std_logic;
  signal bit_count	: std_logic_vector(6 downto 0);
  signal dacdat_s_r : std_logic;
  signal dacdat_s_l : std_logic;


  --COMPONENTS
  component modulo_divider is
    generic (
      width      : positive);
    port (
      clk, reset_n : IN  std_logic;
      clk_12m      : OUT std_logic);
  end component modulo_divider;
  
  component counter is
    generic (
      width      : positive);
    port (
      clk 		: in  std_logic;
	  clk_count : in  std_logic;
	  reset_n   : in  std_logic;
      counter   : out std_logic_vector(width-1 downto 0));
  end component counter;
  
  component i2s_decoder is
    port (
      bit_cntr_i 	: in  std_logic_vector(6 downto 0);
      shift_l       : out std_logic;
      shift_r       : out std_logic;
      load	        : out std_logic;
      ws	        : out std_logic);
  end component i2s_decoder;
  
  component shiftreg_p2s is
    generic (
      width      : positive);
	PORT( 
	  clk     		: IN    std_logic;
	  load_i		: IN    std_logic;
	  shift_i		: IN    std_logic;
  	  enable_i	    : IN    std_logic;
	  par_i 	    : IN    std_logic_vector(width-1 downto 0);
	  ser_o       	: OUT   std_logic
	);
  end component shiftreg_p2s;
  
  component shiftreg_s2p is
    generic (
      width      : positive);
	PORT( 
	  clk     		: IN    std_logic;
	  shift_i		: IN    std_logic;
  	  enable_i	    : IN    std_logic;
	  ser_i       	: IN    std_logic;
	  par_o 	    : OUT   std_logic_vector(width-1 downto 0)
	);
  end component shiftreg_s2p;
  
  
begin  -- architecture rtl

  --PROCESSES
  
  -- PORTMAPS
  bclk_gen: modulo_divider
    generic map (
      width      => 1 )
    port map (
      clk     => clk_12m,
      reset_n => reset_n,
      clk_12m => BCLK_INT);
	  
  bit_cntr: counter
    generic map (
      width      => 7 )
    port map (
      clk       => clk_12m,
      clk_count => BCLK_INT,
      reset_n   => reset_n,
      counter   => bit_count);
	  
  i2s_decoder_1: i2s_decoder
    port map (
      bit_cntr_i => bit_count,
      shift_l  	=> shift_l,
      shift_r   => shift_r,
      ws    	=> ws_o,
      load    	=> load);
	  
  p2s_l: shiftreg_p2s
    generic map (
      width      => 16 )
    port map (
      clk       => clk_12m,
      load_i 	=> load,
      shift_i 	=> shift_l,
      enable_i 	=> BCLK_INT,
      par_i     => dacdat_pl_i,
      ser_o     => dacdat_s_l);
	  
  p2s_r: shiftreg_p2s
    generic map (
      width      => 16 )
    port map (
      clk       => clk_12m,
      load_i 	=> load,
      shift_i 	=> shift_r,
      enable_i 	=> BCLK_INT,
      par_i     => dacdat_pr_i,
      ser_o     => dacdat_s_r);
	  
  s2p_l: shiftreg_s2p
    generic map (
      width      => 16 )
    port map (
      clk       => clk_12m,
      shift_i 	=> shift_l,
      enable_i 	=> BCLK_INT,
      par_o     => adcdat_pl_o,
      ser_i     => adcdat_s_i);
	  
  s2p_r: shiftreg_s2p
    generic map (
      width      => 16 )
    port map (
      clk       => clk_12m,
      shift_i 	=> shift_r,
      enable_i 	=> BCLK_INT,
      par_o     => adcdat_pr_o,
      ser_i     => adcdat_s_i);
	  
-- Concurrent Assignments

	  load_o     <= load;
	  bclk_o     <= BCLK_INT;
	  dacdat_s_o <=      dacdat_s_l when ws_o = '0'
				    else dacdat_s_r;
  
end architecture rtl;

-------------------------------------------------------------------------------
