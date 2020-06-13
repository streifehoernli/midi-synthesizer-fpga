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
-- source name: uart_controller_fsm
-- Datum:       14.06.2020
-------------------------------------------

-------------------------------------------
-- Block code:  uart_controller_fsm.vhd
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
ENTITY uart_controller_fsm IS
  PORT( clk,reset_n  : IN    std_logic;
        baud_tick_i  : IN    std_logic;
        start_i      : IN    std_logic;
        uart_data_i  : IN    std_logic_vector(9 downto 0);
        start_bit_o  : OUT   std_logic;
        data_valid_o : OUT   std_logic;
        shift_enable : OUT   std_logic
      );
END uart_controller_fsm;


-- Architecture Declaration
-------------------------------------------
ARCHITECTURE rtl OF uart_controller_fsm IS
-- Signals & Constants Declaration
-------------------------------------------
  type t_state is (s_idle, s_receiving, s_checking);
  signal state, next_state : t_state;
  signal count, next_count : unsigned(3 downto 0);


-- Begin Architecture
-------------------------------------------
BEGIN

  --------------------------------------------------
  -- PROCESS FOR COMB-INPUT LOGIC
  --------------------------------------------------
  fsm_drive: PROCESS(start_i,state,count)
  BEGIN
    -- Default statement
    next_state <= state;

    case state is
      when s_idle =>
        if (start_i = '1') then
          next_state <= s_receiving;
        end if;
      when s_receiving =>
        if (count >= 10) then  -- 8 maybe as constant, signal Data length
          next_state <= s_checking;
        end if;
      when s_checking =>
        next_state <= s_idle;
      when others =>
        next_state <= s_idle;
    end case;
  END PROCESS fsm_drive;

  --------------------------------------------------
  -- PROCESS FOR COMBINATORIAL LOGIC
  --------------------------------------------------
  comb_logic: PROCESS(count,state,baud_tick_i)
  BEGIN
      next_count <= count;
    -- start
    IF (state = s_receiving) THEN
      if (baud_tick_i = '1') then
        next_count <= count + 1;
      end if;
    else
      next_count <= (others=>'0');
    END IF;

  END PROCESS comb_logic;

  --------------------------------------------------
  -- PROCESS FOR REGISTERS
  --------------------------------------------------
  flip_flops : PROCESS(clk, reset_n)
  BEGIN
    IF reset_n = '0' THEN
      count <= (others=>'0');
      state <= s_idle;
    ELSIF rising_edge(clk) THEN
      count <= next_count;
      state <= next_state;
    END IF;
  END PROCESS flip_flops;


  --------------------------------------------------
  -- CONCURRENT ASSIGNMENTS
  --------------------------------------------------
  start_bit_o  <= '1' when(state = s_idle AND start_i = '1') else '0';
  shift_enable <= '1' when(state = s_receiving and baud_tick_i = '1') else '0';
  data_valid_o <= '1' when(state = s_checking AND uart_data_i(9) = '1' AND uart_data_i(0) = '0') else '0';
  


 -- End Architecture
-------------------------------------------
END rtl;
