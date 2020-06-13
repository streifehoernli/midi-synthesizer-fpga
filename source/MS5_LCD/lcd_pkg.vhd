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
-- source name: lcd_pkg
-- Datum:       14.06.2020
-------------------------------------------

-------------------------------------------
-- Block code:  lcd_pkg.vhd
-- Function:
-------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package lcd_pkg is

  type char_i_array_type is array (0 to 31) of std_logic_vector(7 downto 0);

  constant SPACE        : std_logic_vector(7 downto 0) := x"20";  --
  constant EXCLAMATION  : std_logic_vector(7 downto 0) := x"21";  -- !
  constant QUOTE        : std_logic_vector(7 downto 0) := x"22";  -- "
  constant HASH         : std_logic_vector(7 downto 0) := x"23";  -- #
  constant DOLLER       : std_logic_vector(7 downto 0) := x"24";  -- $
  constant PERCENT      : std_logic_vector(7 downto 0) := x"25";  -- %
  constant ANDSIGN      : std_logic_vector(7 downto 0) := x"26";  -- &
  constant APOSTROPHE   : std_logic_vector(7 downto 0) := x"27";  -- '
  constant BRACKETLEFT  : std_logic_vector(7 downto 0) := x"28";  -- (
  constant BRACKETRIGHT : std_logic_vector(7 downto 0) := x"29";  -- )
  constant CDOT         : std_logic_vector(7 downto 0) := x"2A";  -- *
  constant PLUS         : std_logic_vector(7 downto 0) := x"2B";  -- +
  constant COMMA        : std_logic_vector(7 downto 0) := x"2C";  -- ,
  constant HYPHEN       : std_logic_vector(7 downto 0) := x"2D";  -- -
  constant POINT        : std_logic_vector(7 downto 0) := x"2E";  -- .
  constant SLASHRIGHT   : std_logic_vector(7 downto 0) := x"2F";  -- /

  constant NUM_0     : std_logic_vector(7 downto 0) := x"30";  -- 0
  constant NUM_1     : std_logic_vector(7 downto 0) := x"31";  -- 1
  constant NUM_2     : std_logic_vector(7 downto 0) := x"32";  -- 2
  constant NUM_3     : std_logic_vector(7 downto 0) := x"33";  -- 3
  constant NUM_4     : std_logic_vector(7 downto 0) := x"34";  -- 4
  constant NUM_5     : std_logic_vector(7 downto 0) := x"35";  -- 5
  constant NUM_6     : std_logic_vector(7 downto 0) := x"36";  -- 6
  constant NUM_7     : std_logic_vector(7 downto 0) := x"37";  -- 7
  constant NUM_8     : std_logic_vector(7 downto 0) := x"38";  -- 8
  constant NUM_9     : std_logic_vector(7 downto 0) := x"39";  -- 9
  constant COLON     : std_logic_vector(7 downto 0) := x"3A";  -- :
  constant SEMICOLON : std_logic_vector(7 downto 0) := x"3B";  -- ;
  constant SMALLER   : std_logic_vector(7 downto 0) := x"3C";  -- <
  constant EQUAL     : std_logic_vector(7 downto 0) := x"3D";  -- =
  constant GREATRER  : std_logic_vector(7 downto 0) := x"3E";  -- >
  constant QUESTION  : std_logic_vector(7 downto 0) := x"3F";  -- ?

  constant at    : std_logic_vector(7 downto 0) := x"40";  -- @
  constant LET_A : std_logic_vector(7 downto 0) := x"41";  -- A
  constant LET_B : std_logic_vector(7 downto 0) := x"42";  -- B
  constant LET_C : std_logic_vector(7 downto 0) := x"43";  -- C
  constant LET_D : std_logic_vector(7 downto 0) := x"44";  -- D
  constant LET_E : std_logic_vector(7 downto 0) := x"45";  -- E
  constant LET_F : std_logic_vector(7 downto 0) := x"46";  -- F
  constant LET_G : std_logic_vector(7 downto 0) := x"47";  -- G
  constant LET_H : std_logic_vector(7 downto 0) := x"48";  -- H
  constant LET_I : std_logic_vector(7 downto 0) := x"49";  -- I
  constant LET_J : std_logic_vector(7 downto 0) := x"4A";  -- J
  constant LET_K : std_logic_vector(7 downto 0) := x"4B";  -- K
  constant LET_L : std_logic_vector(7 downto 0) := x"4C";  -- L
  constant LET_M : std_logic_vector(7 downto 0) := x"4D";  -- M
  constant LET_N : std_logic_vector(7 downto 0) := x"4E";  -- N
  constant LET_O : std_logic_vector(7 downto 0) := x"4F";  -- O

  constant LET_P       : std_logic_vector(7 downto 0) := x"50";  -- P
  constant LET_Q       : std_logic_vector(7 downto 0) := x"51";  -- Q
  constant LET_R       : std_logic_vector(7 downto 0) := x"52";  -- R
  constant LET_S       : std_logic_vector(7 downto 0) := x"53";  -- S
  constant LET_T       : std_logic_vector(7 downto 0) := x"54";  -- T
  constant LET_U       : std_logic_vector(7 downto 0) := x"55";  -- U
  constant LET_V       : std_logic_vector(7 downto 0) := x"56";  -- V
  constant LET_W       : std_logic_vector(7 downto 0) := x"57";  -- W
  constant LET_X       : std_logic_vector(7 downto 0) := x"58";  -- X
  constant LET_Y       : std_logic_vector(7 downto 0) := x"59";  -- Y
  constant LET_Z       : std_logic_vector(7 downto 0) := x"5A";  -- Z
  constant SQUARELEFT  : std_logic_vector(7 downto 0) := x"5B";  -- [
  constant SLASHLEFT   : std_logic_vector(7 downto 0) := x"5C";  -- \
  constant SQUARERIGHT : std_logic_vector(7 downto 0) := x"5D";  -- ]
  constant CARET       : std_logic_vector(7 downto 0) := x"5E";  -- ^
  constant UNDERLINE   : std_logic_vector(7 downto 0) := x"5F";  -- _

  constant GRAVE  : std_logic_vector(7 downto 0) := x"60";  -- `
  constant LET_sa : std_logic_vector(7 downto 0) := x"61";  -- a
  constant LET_sb : std_logic_vector(7 downto 0) := x"62";  -- b
  constant LET_sc : std_logic_vector(7 downto 0) := x"63";  -- c
  constant LET_sd : std_logic_vector(7 downto 0) := x"64";  -- d
  constant LET_se : std_logic_vector(7 downto 0) := x"65";  -- e
  constant LET_sf : std_logic_vector(7 downto 0) := x"66";  -- f
  constant LET_sg : std_logic_vector(7 downto 0) := x"67";  -- g
  constant LET_sh : std_logic_vector(7 downto 0) := x"68";  -- h
  constant LET_si : std_logic_vector(7 downto 0) := x"69";  -- i
  constant LET_sj : std_logic_vector(7 downto 0) := x"6A";  -- j
  constant LET_sk : std_logic_vector(7 downto 0) := x"6B";  -- k
  constant LET_sl : std_logic_vector(7 downto 0) := x"6C";  -- l
  constant LET_sm : std_logic_vector(7 downto 0) := x"6D";  -- m
  constant LET_sn : std_logic_vector(7 downto 0) := x"6E";  -- n
  constant LET_so : std_logic_vector(7 downto 0) := x"6F";  -- o

  constant LET_sp     : std_logic_vector(7 downto 0) := x"70";  -- p
  constant LET_sq     : std_logic_vector(7 downto 0) := x"71";  -- q
  constant LET_sr     : std_logic_vector(7 downto 0) := x"72";  -- r
  constant LET_ss     : std_logic_vector(7 downto 0) := x"73";  -- s
  constant LET_st     : std_logic_vector(7 downto 0) := x"74";  -- t
  constant LET_su     : std_logic_vector(7 downto 0) := x"75";  -- u
  constant LET_sv     : std_logic_vector(7 downto 0) := x"76";  -- v
  constant LET_sw     : std_logic_vector(7 downto 0) := x"77";  -- w
  constant LET_sx     : std_logic_vector(7 downto 0) := x"78";  -- x
  constant LET_sy     : std_logic_vector(7 downto 0) := x"79";  -- y
  constant LET_sz     : std_logic_vector(7 downto 0) := x"7A";  -- z
  constant BRACELEFT  : std_logic_vector(7 downto 0) := x"7B";  -- {
  constant BAR        : std_logic_vector(7 downto 0) := x"7C";  -- |
  constant BRACERIGHT : std_logic_vector(7 downto 0) := x"7D";  -- }
  constant ARROWRIGHT : std_logic_vector(7 downto 0) := x"7E";  -- ->
  constant ARROWLEFT  : std_logic_vector(7 downto 0) := x"7F";  -- <-

end package lcd_pkg;

package body lcd_pkg is

end package body lcd_pkg;
