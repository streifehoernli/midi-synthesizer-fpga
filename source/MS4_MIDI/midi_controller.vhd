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
-- source name: midi_controller
-- Datum:       14.06.2020
-------------------------------------------

-------------------------------------------
-- Block code:  midi_controller_fsm.vhd
-- Function:
-------------------------------------------

-- Library & Use Statements
-------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;
use ieee.math_real.log2;
use ieee.math_real.ceil;

use work.tone_gen_pkg.all;


-- Entity Declaration
-------------------------------------------
ENTITY midi_controller IS
  PORT( clk,reset_n  : IN  std_logic;
        data_valid_i : IN  std_logic;
        midi_data_i  : IN  std_logic_vector(7 downto 0);
        modulation_o : OUT std_logic_vector(6 downto 0);
        data_entry_o : OUT std_logic_vector(6 downto 0);
				note_o			 : OUT t_tone_array;
				velocity_o	 : OUT t_tone_array;
				note_on_o 	 : OUT t_note_on
      );
END midi_controller;


-- Architecture Declaration
-------------------------------------------
ARCHITECTURE rtl OF midi_controller IS
-- Signals & Constants Declaration
-------------------------------------------
	component midi_controller_fsm is
  PORT( clk,reset_n  : IN    std_logic;
        data_valid_i : IN    std_logic;
        midi_data_i  : IN    std_logic_vector(7 downto 0);
				new_data_o	 : OUT	 std_logic;
				sel_status_o : OUT	 std_logic;
				sel_data1_o  : OUT	 std_logic;
				sel_data2_o  : OUT	 std_logic
      );
	end component midi_controller_fsm;

	signal new_data_s	  : std_logic;
	signal sel_status_s : std_logic;
	signal sel_data1_s  : std_logic;
	signal sel_data2_s  : std_logic;
	signal reg_data1, next_reg_data1							:	std_logic_vector(6 downto 0);
	signal reg_data2, next_reg_data2							:	std_logic_vector(6 downto 0);
	signal reg_status, next_reg_status						: std_logic_vector(2 downto 0);
	signal reg_data_entry, next_reg_data_entry		:	std_logic_vector(6 downto 0);
	signal reg_modulation, next_reg_modulation		:	std_logic_vector(6 downto 0);
	signal reg_note, next_reg_note								: t_tone_array;
	signal reg_velocity, next_reg_velocity				: t_tone_array;
	signal reg_note_on, next_reg_note_on					: t_note_on;
	
	constant DEL_NOTE : std_logic_vector(2 downto 0) := "000";
	constant SET_NOTE : std_logic_vector(2 downto 0) := "001";
	constant VALUE_CHG : std_logic_vector(2 downto 0) := "011";


-- Begin Architecture
-------------------------------------------
BEGIN

  --Port Map
	
	fsm: midi_controller_fsm
		PORT MAP( 
				clk          => clk,
				reset_n  		 => reset_n,
        data_valid_i => data_valid_i,
        midi_data_i  => midi_data_i,
				new_data_o	 => new_data_s,
				sel_status_o => sel_status_s,
				sel_data1_o  => sel_data1_s,
				sel_data2_o  => sel_data2_s
      );


  --------------------------------------------------
  -- PROCESS FOR COMBINATORIAL LOGIC
  --------------------------------------------------
	comb_logic: PROCESS(all)
	BEGIN
		
		next_reg_data_entry <= reg_data_entry;
		next_reg_modulation <= reg_modulation;
	
		if(new_data_s = '1' AND reg_status = VALUE_CHG) then
			case reg_data1 is
				when "0000001" => next_reg_modulation <= reg_data2;
				when "0000111" => next_reg_data_entry <= reg_data2;
				when others => null;
			end case;
		end if;
	end PROCESS comb_logic;
	
	
  fill_tone_register: PROCESS(all)
  variable note_available, note_written: std_logic;
  BEGIN
	
		next_reg_note <= reg_note;
		next_reg_note_on <= reg_note_on;
		next_reg_velocity <= reg_velocity;
	
		if(new_data_s = '1') THEN
			note_available := '0';
			note_written   := '0';
		
			-- Delete Note if not used anymore
			FOR i IN 0 TO 9 LOOP
				if reg_note(i) = reg_data1 AND reg_note_on(i) = '1' THEN 
					note_available := '1';
				
					if reg_status = DEL_NOTE THEN
					  next_reg_note_on(i) <= '0';
					elsif reg_status = SET_NOTE AND reg_data2 = "0000000" THEN
					  next_reg_note_on(i) <= '0';
					end IF;
				END IF;
			END LOOP;
			
			
			--Write note to available register
			--If no register is free the last register will be overwritten
			IF note_available = '0' THEN
			 FOR i IN 0 TO 9 LOOP
				if note_written = '0' then
					if (reg_note_on(i) = '0' OR i=9) AND reg_status = SET_NOTE then 
						next_reg_note(i) <= reg_data1;
						next_reg_velocity(i) <= reg_data2;
						next_reg_note_on(i) <= '1';
						note_written := '1';
					END IF;
				End IF;
			 END LOOP;
			END if;
			
		end if;
		
  END PROCESS fill_tone_register;
	
	flip_flops : PROCESS(clk, reset_n)
  BEGIN
    IF reset_n = '0' THEN
				reg_note 		 <= (others=>(others=>'0'));
				reg_velocity <= (others=>(others=>'0'));
				reg_note_on  <= (others=>'0');
				reg_data1		 <= (others=>'0');
				reg_data2		 <= (others=>'0');
				reg_status	 <= (others=>'0');
				reg_data_entry	 <= (others=>'0');
				reg_modulation	 <= (others=>'0');
    ELSIF rising_edge(clk) THEN
      reg_note <= next_reg_note;
			reg_velocity <= next_reg_velocity;
			reg_note_on <= next_reg_note_on; 
			reg_data1 <= next_reg_data1;
			reg_data2 <= next_reg_data2;
			reg_status <= next_reg_status;
			reg_data_entry <= next_reg_data_entry;
			reg_modulation <= next_reg_modulation;
    END IF;
  END PROCESS flip_flops;


	next_reg_data1 <= midi_data_i(6 downto 0) when sel_data1_s = '1'
									ELSE	reg_data1 when sel_data1_s = '0';
	next_reg_data2 <= midi_data_i(6 downto 0) when sel_data2_s = '1'
									ELSE	reg_data2 when sel_data2_s = '0';
	next_reg_status <= midi_data_i(6 downto 4) when sel_status_s = '1'
									ELSE	reg_status when sel_status_s = '0';
	
	note_o <= reg_note;
	velocity_o <= reg_velocity;
	note_on_o  <= reg_note_on;
	modulation_o <= reg_modulation;
	data_entry_o <= reg_data_entry;

 -- End Architecture
-------------------------------------------
END rtl;
