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
-- source name: lcd_ui
-- Datum:       14.06.2020
-------------------------------------------

-------------------------------------------
-- Block code:  lcd_ui.vhd
-- Function:
-------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.lcd_pkg.all;                   -- Enthaelt LCD Konstanten
use work.tone_gen_pkg.all;              -- Enthaelt Tasten

-------------------------------------------------------------------------------

-- Entity Declaration  
entity lcd_ui is
  port (
    clk_12m  : in  std_logic;           -- 12.5 MHz Clock
    reset_n  : in  std_logic;           -- Reset
    switch_i : in  std_logic_vector(17 downto 0);  -- Schalterstellung
    char_o   : out char_i_array_type  -- Char-Array, welches auf den LCD geschrieben werden soll
    );

end entity lcd_ui;

-------------------------------------------------------------------------------

architecture rtl of lcd_ui is

-----------------------------------------------------------------------------
-- Internal signal declarations
-----------------------------------------------------------------------------
  signal path_control            : std_logic;
  signal lut_instrument          : std_logic_vector(3 downto 0);
  signal config                  : std_logic_vector(2 downto 0);
  signal char_out, next_char_out : char_i_array_type;

begin
-------------------------------------------
-- Prozess fuer Clock
-------------------------------------------
  clk_proc : process(all)
  begin
    if (reset_n = '0') then  -- Asynchroner Reset => Starteinstellungen wiederherstellen
      for i in 0 to 9 loop
        char_out(i) <= (others => '0');
      end loop;
    elsif (rising_edge(clk_12m)) then  -- Zustand weitergeben bei positiver Flanke des Clocks
      char_out <= next_char_out;
    end if;
  end process clk_proc;

-------------------------------------------
-- Prozess fuer UI
-------------------------------------------
  ui_proc : process(all)
  begin
    -- Default Statements
	 
    next_char_out(0)  <= LET_M;
    next_char_out(1)  <= LET_so;
    next_char_out(2)  <= LET_sd;
    next_char_out(3)  <= LET_se;
    next_char_out(4)  <= COLON;
    next_char_out(5)  <= SPACE;
	 next_char_out(6)  <= SPACE;
	 next_char_out(7)  <= SPACE;
	 next_char_out(8)  <= SPACE;
	 next_char_out(9)  <= SPACE;
	 next_char_out(10) <= SPACE;
	 next_char_out(11) <= SPACE;
	 next_char_out(12) <= SPACE;
	 next_char_out(13) <= SPACE;
	 next_char_out(14) <= SPACE;
	 next_char_out(15) <= SPACE;
    
	next_char_out(16) <= LET_L;
	next_char_out(17) <= LET_U;
	next_char_out(18) <= LET_T;
	next_char_out(19) <= COLON;
	next_char_out(20) <= SPACE;
	next_char_out(21) <= SPACE;
	next_char_out(22) <= SPACE;
	next_char_out(23) <= SPACE;
	next_char_out(24) <= SPACE;
	next_char_out(25) <= SPACE;
	next_char_out(26) <= SPACE;
	next_char_out(27) <= SPACE;
	next_char_out(28) <= SPACE;
	next_char_out(29) <= SPACE;
	next_char_out(30) <= SPACE;
	next_char_out(31) <= SPACE;


    case(config) is                     -- Konfiguration auslesen
      when "001" =>                     -- C_W8731_ANALOG_BYPASS
        next_char_out(6)  <= LET_B;
        next_char_out(7)  <= LET_sy;
        next_char_out(8)  <= LET_sp;
        next_char_out(9)  <= LET_sa;
        next_char_out(10) <= LET_ss;
        next_char_out(11) <= LET_ss;
      when "011" =>                     -- C_W8731_ANALOG_MUTE_RIGHT
        next_char_out(6)  <= LET_M;
		  next_char_out(7)  <= LET_su;
		  next_char_out(8)  <= LET_st;
		  next_char_out(9)  <= LET_se;
		  
        next_char_out(11) <= LET_R;
        next_char_out(12) <= LET_si;
        next_char_out(13) <= LET_sg;
        next_char_out(14) <= LET_sh;
		  next_char_out(15) <= LET_st;
      when "101" =>                     -- C_W8731_ANALOG_MUTE_LEFT
        next_char_out(6)  <= LET_M;
		  next_char_out(7)  <= LET_su;
		  next_char_out(8)  <= LET_st;
		  next_char_out(9)  <= LET_se;
		  
        next_char_out(11) <= LET_L;
        next_char_out(12) <= LET_se;
        next_char_out(13) <= LET_sf;
        next_char_out(14) <= LET_st;
      when "111" =>                     -- C_W8731_ANALOG_MUTE_BOTH
        next_char_out(6)  <= LET_M;
		  next_char_out(7)  <= LET_su;
		  next_char_out(8)  <= LET_st;
		  next_char_out(9)  <= LET_se;
		  
        next_char_out(11) <= LET_B;
        next_char_out(12) <= LET_so;
        next_char_out(13) <= LET_st;
        next_char_out(14) <= LET_sh;
      when others =>                    -- C_W8731_ADC_DAC_0DB_48K
        next_char_out(6) <= LET_D;
        next_char_out(7) <= LET_D;
        next_char_out(8) <= LET_S;

        if path_control = '1' then  -- Ist Codec geloopt? Digital Audio Loop
			 next_char_out(10) <= LET_L;
			 next_char_out(11) <= LET_O;
			 next_char_out(12) <= LET_O;
          next_char_out(13) <= LET_P;
        end if;

    end case;
        
      case(lut_instrument) is
        when "0001" =>                   -- Viola --- Bratsche
          next_char_out(21) <= LET_B;
          next_char_out(22) <= LET_sr;
          next_char_out(23) <= LET_sa;
          next_char_out(24) <= LET_st;
          next_char_out(25) <= LET_ss;
          next_char_out(26) <= LET_sc;
          next_char_out(27) <= LET_sh;
          next_char_out(28) <= LET_se;
        when "0010" =>                   -- Bassoon --- Fagott
          next_char_out(21) <= LET_F;
          next_char_out(22) <= LET_sa;
          next_char_out(23) <= LET_sg;
          next_char_out(24) <= LET_so;
          next_char_out(25) <= LET_st;
          next_char_out(26) <= LET_st;
        when "0011" =>                   -- Clarinet --- Klarinette
          next_char_out(21) <= LET_C;
          next_char_out(22) <= LET_sl;
          next_char_out(23) <= LET_sa;
          next_char_out(24) <= LET_sr;
          next_char_out(25) <= LET_si;
          next_char_out(26) <= LET_sn;
          next_char_out(27) <= LET_se;
          next_char_out(28) <= LET_st;
          next_char_out(29) <= LET_st;
			 next_char_out(30) <= LET_se;
        when "0100" =>                   -- English Horn --- Eng. Horn
          next_char_out(21) <= LET_E;
          next_char_out(22) <= LET_sn;
          next_char_out(23) <= LET_sg;
          next_char_out(24) <= POINT;
          next_char_out(25) <= SPACE;
          next_char_out(26) <= LET_H;
          next_char_out(27) <= LET_so;
          next_char_out(28) <= LET_sr;
          next_char_out(29) <= LET_sn;
        when "0101" =>                   -- Trumpet --- Trompete
          next_char_out(21) <= LET_T;
          next_char_out(22) <= LET_sr;
          next_char_out(23) <= LET_so;
          next_char_out(24) <= LET_sm;
          next_char_out(25) <= LET_sp;
          next_char_out(26) <= LET_se;
          next_char_out(27) <= LET_st;
          next_char_out(28) <= LET_se;
        when "0110" =>                   -- Piano
          next_char_out(21) <= LET_P;
          next_char_out(22) <= LET_si;
          next_char_out(23) <= LET_sa;
          next_char_out(24) <= LET_sn;
          next_char_out(25) <= LET_so;
		when "0111" =>                   -- Organ --- Orgel
          next_char_out(21) <= LET_O;
          next_char_out(22) <= LET_sr;
          next_char_out(23) <= LET_sg;
          next_char_out(24) <= LET_se;
          next_char_out(25) <= LET_sl;
		when "1000" =>                   -- Oboe
          next_char_out(21) <= LET_O;
          next_char_out(22) <= LET_sb;
          next_char_out(23) <= LET_so;
          next_char_out(24) <= LET_se;
		when "1001" =>                   -- Flute --- Floete
          next_char_out(21) <= LET_F;
          next_char_out(22) <= LET_sl;
          next_char_out(23) <= LET_so;
          next_char_out(24) <= LET_se;
          next_char_out(25) <= LET_st;
          next_char_out(26) <= LET_se;
		when "1010" =>                   -- Violin --- Violine
          next_char_out(21) <= LET_V;
          next_char_out(22) <= LET_si;
          next_char_out(23) <= LET_so;
          next_char_out(24) <= LET_sl;
          next_char_out(25) <= LET_si;
          next_char_out(26) <= LET_sn;
          next_char_out(27) <= LET_se;
		when "1011" =>                   -- Tuba
          next_char_out(21) <= LET_T;
          next_char_out(22) <= LET_su;
          next_char_out(23) <= LET_sb;
          next_char_out(24) <= LET_sa;
		when "1100" =>                   -- Piccolo
          next_char_out(21) <= LET_P;
          next_char_out(22) <= LET_si;
          next_char_out(23) <= LET_sc;
          next_char_out(24) <= LET_sc;
          next_char_out(25) <= LET_so;
          next_char_out(26) <= LET_sl;
          next_char_out(27) <= LET_so;
		when "1101" =>                   -- Open
          next_char_out(21) <= NUM_1;
		when "1110" =>                   -- Open
          next_char_out(21) <= NUM_2;
		when "1111" =>                   -- Open
          next_char_out(21) <= NUM_3;
        when others =>                  -- Others
          next_char_out(21) <= LET_S;
          next_char_out(22) <= LET_si;
          next_char_out(23) <= LET_sn;
          next_char_out(24) <= LET_su;
          next_char_out(25) <= LET_ss;
      end case;
  end process ui_proc;

-------------------------------------------
-- Concurrent assignments  
-------------------------------------------

  -- Schalter auslesen, um uebersichlichere case-Statements zu machen
  path_control   <= switch_i(3);
  lut_instrument <= switch_i(7 downto 4);
  config         <= switch_i(2 downto 0);


  -- Ausgangszuweisung
  char_o <= char_out;

end architecture rtl;
