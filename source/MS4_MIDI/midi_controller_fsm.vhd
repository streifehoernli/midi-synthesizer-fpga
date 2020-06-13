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
-- source name: midi_controller_fsm
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


-- Entity Declaration
-------------------------------------------
ENTITY midi_controller_fsm IS
  PORT( clk,reset_n  : IN    std_logic;
        data_valid_i : IN    std_logic;
        midi_data_i  : IN    std_logic_vector(7 downto 0);
				new_data_o	 : OUT	 std_logic;
				sel_status_o : OUT	 std_logic;
				sel_data1_o  : OUT	 std_logic;
				sel_data2_o  : OUT	 std_logic
      );
END midi_controller_fsm;


-- Architecture Declaration
-------------------------------------------
ARCHITECTURE rtl OF midi_controller_fsm IS
-- Signals & Constants Declaration
-------------------------------------------
  type t_state is (s_wait_status, s_wait_data1, s_wait_data2);
  signal state, next_state : t_state;


-- Begin Architecture
-------------------------------------------
BEGIN

  --------------------------------------------------
  -- PROCESS FOR COMB-INPUT LOGIC
  --------------------------------------------------
  fsm_drive: PROCESS(data_valid_i,state,midi_data_i)
  BEGIN
    -- Default statement
    next_state <= state;
		new_data_o   <= '0';	 

    case state is
      when s_wait_status =>
        if (data_valid_i = '1') then
					if (midi_data_i(7) = '0') then
						next_state <= s_wait_data2;
					else 
						next_state <= s_wait_data1;
					end if;
				end if;
      when s_wait_data1 =>
        if (data_valid_i = '1') then
          next_state <= s_wait_data2;
        end if;
      when s_wait_data2 =>
			if (data_valid_i = '1') then
          next_state <= s_wait_status;
					new_data_o <= '1';
        end if;
      when others =>
        next_state <= s_wait_status;
    end case;
  END PROCESS fsm_drive;

  --------------------------------------------------
  -- PROCESS FOR COMBINATORIAL LOGIC
  --------------------------------------------------
  comb_logic: PROCESS(state)
  BEGIN
		sel_status_o <= '0';
		sel_data1_o  <= '0';
		sel_data2_o  <= '0';
		
		case state is
      when s_wait_status =>
        sel_status_o <= '1';
      when s_wait_data1 =>
        sel_data1_o  <= '1';
      when s_wait_data2 =>
				sel_data2_o  <= '1';
      when others => NULL;
    end case;
		
			

  END PROCESS comb_logic;

  --------------------------------------------------
  -- PROCESS FOR REGISTERS
  --------------------------------------------------
  flip_flops : PROCESS(clk, reset_n)
  BEGIN
    IF reset_n = '0' THEN
      state <= s_wait_status;
    ELSIF rising_edge(clk) THEN
      state <= next_state;
    END IF;
  END PROCESS flip_flops;


 -- End Architecture
-------------------------------------------
END rtl;
