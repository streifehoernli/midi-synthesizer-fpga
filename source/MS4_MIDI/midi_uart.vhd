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
-- source name: midi_uart
-- Datum:       14.06.2020
-------------------------------------------

-------------------------------------------------------------------------------
-- Title      : Midi UART Controller
-- Project    : 
-------------------------------------------------------------------------------
-- File       : midi_uart.vhd
-- Author     :   <Admin@LAPTOP-4OQR1GUI>
-- Company    : 
-- Created    : 2020-02-20
-- Last update: 2020-02-27
-- Platform   : 
-- Standard   : VHDL'08
-------------------------------------------------------------------------------
-- Description: This entity controlls the midi_uart interface
-------------------------------------------------------------------------------
-- Copyright (c) 2020 
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2020-02-20  1.0      Admin	Created
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

-------------------------------------------------------------------------------

entity midi_uart is

  port (
    clk 					: in std_logic;
    reset_n     	: in std_logic;
    ser_data_i  	: in std_logic;
		data_valid_o	: out std_logic;
		par_data_o		: out std_logic_vector(7 downto 0)
    );

end entity midi_uart;

-------------------------------------------------------------------------------

architecture str of midi_uart is

  -----------------------------------------------------------------------------
  -- Internal signal declarations
  -----------------------------------------------------------------------------
  signal shift_enable           : std_logic;
  signal bit_o                  : std_logic;
  signal data_valid             : std_logic;
  signal baud_tick_t            : std_logic;
  signal start_bit              : std_logic;
  signal fall                   : std_logic;
  signal steig                  : std_logic;
  signal uart_data              : std_logic_vector(9 downto 0);

  -----------------------------------------------------------------------------
  -- Component declarations
  -----------------------------------------------------------------------------

  component baud_tick is
    generic (
      baud_rate  : positive;
      clock_rate : positive);
    port (
      clk, reset_n : IN  std_logic;
      start_i      : IN  std_logic;
      tick_o       : OUT std_logic);
  end component baud_tick;

  component flanken_detect is
    port (
      data_in : IN  std_logic;
      clock   : IN  std_logic;
      reset_n : IN  std_logic;
      steig   : OUT std_logic;
      fall    : OUT std_logic);
  end component flanken_detect;

  component shiftreg_s2p_ms4 is
    generic (
      width : positive);
    port (
      clk, reset_n, enable_i, ser_i : IN  std_logic;
      par_o                         : OUT std_logic_vector(width - 1 downto 0));
  end component shiftreg_s2p_ms4;

  component uart_controller_fsm is
    port (
      clk, reset_n : IN  std_logic;
      baud_tick_i  : IN  std_logic;
      start_i      : IN  std_logic;
      uart_data_i  : IN  std_logic_vector(9 downto 0);
      start_bit_o  : OUT std_logic;
      data_valid_o : OUT std_logic;
      shift_enable : OUT std_logic);
  end component uart_controller_fsm;

begin  -- architecture str

  -----------------------------------------------------------------------------
  -- Component instantiations
  -----------------------------------------------------------------------------
  
  -- instance "baud_tick_1"
  baud_tick_1: baud_tick
    generic map (
      baud_rate  => 31_250,
      clock_rate => 12_500_000)
    port map (
      clk     => clk,
      reset_n => reset_n,
      start_i => start_bit,
      tick_o  => baud_tick_t);

  -- instance "flanken_detect_1"
  flanken_detect_1: flanken_detect
    port map (
      data_in => ser_data_i,
      clock   => clk,
      reset_n => reset_n,
      steig   => steig,
      fall    => fall);

  -- instance "shiftreg_s2p"
  shiftreg_s2p:	 shiftreg_s2p_ms4
    generic map (
      width => 10)
    port map (
      clk      => clk,
      reset_n  => reset_n,
      enable_i => shift_enable,
      ser_i    => ser_data_i,
      par_o    => uart_data);

  -- instance "uart_controller_fsm_1"
  uart_controller_fsm_1: uart_controller_fsm
    port map (
      clk          => clk,
      reset_n      => reset_n,
      baud_tick_i  => baud_tick_t,
      start_i      => fall,
      uart_data_i  => uart_data,
      start_bit_o  => start_bit,
      data_valid_o => data_valid_o,
      shift_enable => shift_enable);
			
		par_data_o <= uart_data(8 downto 1); -- truncate start and stop bit

end architecture str;

-------------------------------------------------------------------------------

