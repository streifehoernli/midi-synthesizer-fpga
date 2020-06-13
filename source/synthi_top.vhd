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
-- source name: synthi_top
-- Datum:       14.06.2020
-------------------------------------------

-------------------------------------------------------------------------------
-- Title      : synthi_top
-- Project    : 
-------------------------------------------------------------------------------
-- File       : synthi_top.vhd
-- Author     :   <beats@SURFACE>
-- Company    : 
-- Created    : 2020-03-05
-- Last update: 2020-03-05
-- Platform   : 
-- Standard   : VHDL'93/02
-------------------------------------------------------------------------------
-- Description: 
-------------------------------------------------------------------------------
-- Copyright (c) 2020 
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2020-03-05  1.0      beats	Created
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.tone_gen_pkg.all;

-------------------------------------------------------------------------------

entity synthi_top is


  port (
    CLOCK_50  	: in     std_logic;
    GPIO_26   	: in     std_logic;
    KEY_0     	: in     std_logic;
    KEY_1     	: in     std_logic;
    SW	      	: in     std_logic_vector(17 downto 0);
    AUD_XCK   	: out    std_logic;
    I2C_SDAT  	: inout  std_logic;
    I2C_SCLK  	: out    std_logic;
		AUD_BCLK  	: out	 std_logic;
		AUD_DACLRCK : out	 std_logic;
		AUD_ADCLRCK : out	 std_logic;	
		load_o			: out    std_logic;
		AUD_DACDAT  : out	 std_logic;
		AUD_ADCDAT  : in	 std_logic;
		
		LEDR		: out	std_logic_vector(17 downto 0);
		
	 LCD_DATA : out std_logic_vector(7 downto 4);  -- Buchstaben, welche angezeigt werden sollen
    LCD_RS   : out std_logic;
    LCD_EN   : out std_logic;           -- Enable des LCD
    LCD_RW   : out std_logic;           -- Read/Write des LCD
    LCD_ON   : out std_logic            -- LCD einschalten
    );

end entity synthi_top;

-------------------------------------------------------------------------------

architecture str of synthi_top is

  -----------------------------------------------------------------------------
  -- Internal signal declarations
  -----------------------------------------------------------------------------

  signal key_1_sync      : std_logic;
  signal sw_sync         : std_logic_vector(17 downto 0);
  signal reset_n_s       : std_logic;
  signal gpio_26_sync    : std_logic;
  signal clock_12m_s     : std_logic;
  signal write_s         : std_logic;
  signal write_data      : std_logic_vector(15 downto 0);
  signal write_done      : std_logic;
  signal ack_error       : std_logic;
  signal ws		          : std_logic;
  signal load_s          : std_logic;
  signal dacdat_pl		 : std_logic_vector(15 downto 0);
  signal dacdat_pr		 : std_logic_vector(15 downto 0);
  signal adcdat_pl		 : std_logic_vector(15 downto 0);
  signal adcdat_pr		 : std_logic_vector(15 downto 0);
  
  -- Milestone 3
  signal dds_l		 	 : std_logic_vector(15 downto 0) := (others => '0');
  signal dds_r		 	 : std_logic_vector(15 downto 0) := (others => '0');
	
	--Milestone 4
	signal midi_data_s    			: std_logic_vector(7 downto 0);
	signal modulation_s    			: std_logic_vector(6 downto 0);
	signal data_entry_s    			: std_logic_vector(6 downto 0);
	signal midi_data_valid_s    : std_logic;
	signal note_array						: t_tone_array;
	signal velocity_array				: t_tone_array;
	signal note_on_array				: t_note_on;
  
  component codec_controller is
    port (
      clk          : IN  std_logic;
      initialize_i : IN  std_logic;
      reset_n      : IN  std_logic;
      write_done_i : IN  std_logic;
      ack_error_i  : IN  std_logic;
      sw_sync_i    : IN  std_logic_vector(2 downto 0);
      write_o      : OUT std_logic;
      write_data_o : OUT std_logic_vector(15 downto 0);
      mute_o       : OUT std_logic);
  end component codec_controller;

  component infrastructure is
    port (
      clk_50         : IN  std_logic;
      key_0_i        : IN  std_logic;
      key_1_i        : IN  std_logic;
      sw_17_0_i      : IN  std_logic_vector(17 downto 0);
      gpio_26_i      : IN  std_logic;
      clk_12m_o      : OUT std_logic;
      reset_n_o      : OUT std_logic;
      key_1_sync_o   : OUT std_logic;
      gpio_26_sync_o : OUT std_logic;
      sw_17_0_sync_o : OUT std_logic_vector(17 downto 0));
  end component infrastructure;

  component i2c_master is
    port (
      clk          : in    std_logic;
      reset_n      : in    std_logic;
      write_i      : in    std_logic;
      write_data_i : in    std_logic_vector(15 downto 0);
      sda_io       : inout std_logic;
      scl_o        : out   std_logic;
      write_done_o : out   std_logic;
      ack_error_o  : out   std_logic);
  end component i2c_master;
  
  component i2s_master is
    port (
      clk_12m	  	: in     std_logic;
			dacdat_pl_i : in     std_logic_vector(15 downto 0);
      dacdat_pr_i : in     std_logic_vector(15 downto 0);
      dacdat_s_o  : out    std_logic;
      reset_n     : in     std_logic;
      adcdat_pl_o : out    std_logic_vector(15 downto 0);
      adcdat_pr_o : out    std_logic_vector(15 downto 0);
      load_o      : out    std_logic;
      adcdat_s_i  : in     std_logic;
      bclk_o      : out    std_logic;
      ws_o        : out    std_logic);
  end component i2s_master;
  
  component path_control is
    port (
      loop_back_i	  	: IN    std_logic;
			dds_l_i 	      : IN    std_logic_vector(15 downto 0);
      dds_r_i 	      : IN    std_logic_vector(15 downto 0);
      adcdat_pl_i 	  : IN    std_logic_vector(15 downto 0);
      adcdat_pr_i 	  : IN    std_logic_vector(15 downto 0);
      dacdat_pl_o     : OUT   std_logic_vector(15 downto 0);
      dacdat_pr_o     : OUT   std_logic_vector(15 downto 0));
  end component path_control;
	
	component tone_generator is
    port (
      clk_12m	    	 : in     std_logic;
			reset_n     	 : in     std_logic;
			tone_on_i			 : in     std_logic;
			load_i      	 : in     std_logic;
			note_array  	 : in     t_tone_array;
			velocity_array : in     t_tone_array;
			note_on_array  : in 		t_note_on;
			instr_sel_i 	 : in     std_logic_vector(3 downto 0);
			modulation_i 	 : in 		std_logic_vector(6 downto 0);
			data_entry_i 	 : in 		std_logic_vector(6 downto 0);
			dds_o       	 : out    std_logic_vector(N_AUDIO-1 downto 0));
  end component tone_generator;
	
	component midi_controller IS
  PORT( clk,reset_n  : IN  std_logic;
        midi_data_i  : IN  std_logic_vector(7 downto 0);
        data_valid_i : IN  std_logic;
				modulation_o : OUT std_logic_vector(6 downto 0);
				data_entry_o : OUT std_logic_vector(6 downto 0);
				note_o			 : OUT t_tone_array;
				velocity_o	 : OUT t_tone_array;
				note_on_o 	 : OUT t_note_on
      );
	END component midi_controller;

	component midi_uart is
  port (
    clk 					: in std_logic;
    reset_n     	: in std_logic;
    ser_data_i  	: in std_logic;
		data_valid_o	: out std_logic;
		par_data_o		: out std_logic_vector(7 downto 0)
  );
	end component midi_uart;
	
	component lcd_top
    port(
      clk  : in  std_logic;
      reset_n  : in  std_logic;
      switch_i : in  std_logic_vector(17 downto 0);
      lcdRS    : out std_logic;
      lcdE     : out std_logic;
      lcdData  : out std_logic_vector(7 downto 4)
      );
  end component;
  
  component Visualisierung
	port(
	   audiodata_i : in  std_logic_vector(15 downto 0);
      led_o       : out std_logic_vector(17 downto 0);
		switch		: in	std_logic
		);
	end component;


begin  -- architecture str

  -----------------------------------------------------------------------------
  -- Component instantiations
  -----------------------------------------------------------------------------
  
  -- instance "i2s_master_1"
  i2s_master_1: i2s_master
    port map (
      clk_12m      	=> clock_12m_s,
      dacdat_pl_i 	=> dacdat_pl,
      dacdat_pr_i   => dacdat_pr,
      dacdat_s_o 	=> AUD_DACDAT,
      reset_n  		=> reset_n_s,
      adcdat_pl_o   => adcdat_pl,
      adcdat_pr_o   => adcdat_pr,
      load_o 		=> load_s,
      bclk_o 		=> AUD_BCLK,
      ws_o 			=> ws,
      adcdat_s_i    => AUD_ADCDAT);
	  
  -- instance "path_control_1"
  path_control_1: path_control
    port map (
      loop_back_i   => sw_sync(3),
      dds_l_i 		=> dds_l,
      dds_r_i   	=> dds_r,
      adcdat_pl_i	=> adcdat_pl,
      adcdat_pr_i  	=> adcdat_pr,
      dacdat_pl_o  	=> dacdat_pl,
      dacdat_pr_o  	=> dacdat_pr);
  
  -- instance "codec_controller_1"
  codec_controller_1: codec_controller
    port map (
      clk          => clock_12m_s,
      initialize_i => key_1_sync,
      reset_n      => reset_n_s,
      write_done_i => write_done,
      ack_error_i  => ack_error,
      sw_sync_i    => sw_sync(2 downto 0),
      write_o      => write_s,
      write_data_o => write_data,
      mute_o       => OPEN);

  -- instance "infrastructure_1"
  infrastructure_1: infrastructure
    port map (
      clk_50         => CLOCK_50,
      key_0_i        => KEY_0,
      key_1_i        => KEY_1,
      sw_17_0_i      => SW,
      gpio_26_i      => GPIO_26,
      clk_12m_o      => clock_12m_s,
      reset_n_o      => reset_n_s,
      key_1_sync_o   => key_1_sync,
      gpio_26_sync_o => gpio_26_sync,
      sw_17_0_sync_o => sw_sync);

  -- instance "i2c_master_1"
  i2c_master_1: i2c_master
    port map (
      clk          => clock_12m_s,
      reset_n      => reset_n_s,
      write_i      => write_s,
      write_data_i => write_data,
      sda_io       => I2C_SDAT,
      scl_o        => I2C_SCLK,
      write_done_o => write_done,
      ack_error_o  => ack_error);
			
	tone_gen: tone_generator
    port map (
      clk_12m    			=> clock_12m_s,
      reset_n    			=> reset_n_s,
      tone_on_i  			=> sw_sync(15),
      load_i     			=> load_s,
			note_array  	 	=> note_array,
			velocity_array	=> velocity_array,
			note_on_array  	=> note_on_array,
			modulation_i    => modulation_s,
			data_entry_i		=> data_entry_s,
			instr_sel_i			=> sw_sync(7 downto 4),
      dds_o 	   			=> dds_r);
			
	midi_ctr: midi_controller
		port map( 
			clk						=> clock_12m_s,
			reset_n  			=> reset_n_s,
      data_valid_i  => midi_data_valid_s,
      midi_data_i 	=> midi_data_s,
			note_o				=> note_array,
			velocity_o		=> velocity_array,
			note_on_o 		=> note_on_array,
			modulation_o  => modulation_s,
			data_entry_o  => data_entry_s
      );

	midi_uart1: midi_uart
		port map(
    clk 					=> clock_12m_s,
    reset_n     	=> reset_n_s,
    ser_data_i  	=> gpio_26_sync,
		data_valid_o	=> midi_data_valid_s,
		par_data_o		=> midi_data_s
		);
		
	lcd_top1 : lcd_top
    port map(
      clk 		=> clock_12m_s,
      reset_n  => reset_n_s,
      switch_i => sw_sync,
      lcdRS    => LCD_RS,
      lcdE     => LCD_EN,
      lcdData  => LCD_DATA
      );
		
	visual : Visualisierung
		port map(
	   audiodata_i => dacdat_pl(15 downto 0),
      led_o       => LEDR(17 downto 0),
		switch		=> sw_sync(17)
		);
		

			
	  
		-- linker kanal hat immer das gleiche wie rechts
		dds_l				<= dds_r;
	  AUD_XCK 	  <= clock_12m_s;
	  AUD_DACLRCK <= ws;
	  AUD_ADCLRCK <= ws;
	  load_o 	  <= load_s;

	  
	  LCD_RW         <= '0';
	  LCD_ON         <= '1';

end architecture str;

-------------------------------------------------------------------------------
