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
-- source name: tone_generator
-- Datum:       14.06.2020
-------------------------------------------

-------------------------------------------

-- Library & Use Statements
-------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.tone_gen_pkg.all;

-- Entity Declaration 
-------------------------------------------
entity tone_generator is
  port(
		clk_12m	    	 : in     std_logic;
		reset_n      	 : in     std_logic;
		tone_on_i			 : in     std_logic;
		load_i      	 : in     std_logic;
		note_array  	 : in     t_tone_array;
		velocity_array : in     t_tone_array;
		note_on_array  : in 		t_note_on;
		instr_sel_i 	 : in     std_logic_vector(3 downto 0);
		modulation_i 	 : in 		std_logic_vector(6 downto 0);
		data_entry_i 	 : in 		std_logic_vector(6 downto 0);
		dds_o       	 : out    std_logic_vector(N_AUDIO-1 downto 0));
end tone_generator;

-- Architecture Declaration
-------------------------------------------
architecture rtl of tone_generator is

 component dds is
    port (
      clk_12m	    : in     std_logic;
			reset_n     : in     std_logic;
			phi_incr_i  : in     std_logic_vector(N_CUM-1 downto 0);
			tone_on_i		: in     std_logic;
			load_i      : in     std_logic;
			attenu_i		: in     std_logic_vector(2 downto 0);
			instr_sel_i : in     std_logic_vector(3 downto 0);
			dds_o       : out    std_logic_vector(N_AUDIO-1 downto 0));
  end component dds;
	
	-- TODO: create attenuator MS3 page 15
	
	type t_dds_o_array is array(0 to 9) of std_logic_vector(N_AUDIO-1 downto 0);
	type t_phi_incr_array is array(0 to 9) of std_logic_vector(N_CUM-1 downto 0);
	
	signal dds_o_array: t_dds_o_array;
	signal dds_modul_array: t_dds_o_array;
	signal phi_incr_carrier: t_phi_incr_array;
	signal phi_incr_modulator: t_phi_incr_array;
	
	constant MODUL_FREQ_DIV : natural := 5; -- Divide Carrier Frequency by 2^MODUL_FREQ

-------------------------------------------
-- Begin Architecture
-------------------------------------------
begin

	tone_sum : process(all)
	variable dds_sum		: unsigned(N_AUDIO-1 downto 0);
  begin
	
	dds_sum := (others => '0'); 
		For i IN 0 TO 9 LOOP
			IF note_on_array(i) = '1' THEN
					dds_sum := dds_sum + unsigned(dds_o_array(i));
			END IF;
		END LOOP;
	dds_o <= std_logic_vector(dds_sum);
  end process tone_sum;
  
	calc_incr : process(all)
	variable car_incr : std_logic_vector(23 downto 0);
	variable mod_incr : std_logic_vector(25 downto 0);
	begin
		For i IN 0 TO 9 LOOP
		
			car_incr := std_logic_vector(to_signed(to_integer(unsigned(LUT_midi2dds(to_integer(unsigned(note_array(i)))))),N_CUM+1) + (shift_right(signed(dds_modul_array(i)),8)*to_signed(to_integer(unsigned(modulation_i)), 8)));
			phi_incr_carrier(i) <= car_incr(N_CUM-1 downto 0);
			
			mod_incr := std_logic_vector(shift_right(unsigned(LUT_midi2dds(to_integer(unsigned(note_array(i))))), MODUL_FREQ_DIV) * unsigned(data_entry_i));
			phi_incr_modulator(i) <= mod_incr(N_CUM-1 downto 0);
		END LOOP;
	end process calc_incr;
	 
  -- Port Maps -----
  
dds_carrier_gen: for i in 0 to 9 generate
		carrier_dds: dds
			port map(clk_12m        => clk_12m,
							 reset_n		=> reset_n,
							 tone_on_i  => tone_on_i,
							 phi_incr_i	=> phi_incr_carrier(i), 
							 load_i			=> load_i, 
							 attenu_i		=> "000", 
							 dds_o			=> dds_o_array(i),
							 instr_sel_i => instr_sel_i
							);
	end generate dds_carrier_gen;
	
	dds_modulator_gen: for j in 0 to 9 generate
		modulator_dds: dds
			port map(clk_12m    => clk_12m,
							 reset_n		=> reset_n,
							 tone_on_i  => '1',
							 phi_incr_i	=> phi_incr_modulator(j),
							 load_i			=> load_i, 
							 attenu_i		=> "000", 
							 dds_o			=> dds_modul_array(j),
							 instr_sel_i => "0000"
							);
	end generate dds_modulator_gen;

-- End Architecture 
------------------------------------------- 
end rtl;

