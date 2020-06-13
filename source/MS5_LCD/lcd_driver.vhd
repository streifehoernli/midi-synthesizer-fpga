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
-- source name: lcd_driver
-- Datum:       14.06.2020
-------------------------------------------

-- LCD Driver Module for driving HD44780 Controller
-- A. Greensted, July 2010
-- H.Gelke, April 2013 : adapted for 32 characters (initially was 40 characters)
-- M.Tavares, April 2015: adapted for clk12M5, reset_n low active
-- M.Tavares, May 2015: tick_max value needs to be the divider ratio! 
--						warm-up & init delay reduced (compromise datasheet vs. HW check)
-- M.Tavares, April 2016: few clean ups to avoid synthesis warnings. Remains: charRAM read-during-write behaviour.
-- 
--     OPEN:  support for data-length 8-Bit
--            more transparent code with split reg/comb processes for tickGen and FSM-process
--		                   

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-------------------------------------------------------------------------------

entity lcd_driver is
  generic (CLK_FREQ : positive := 12_500_000);  -- Frequency of clk input in Hz
  port (clk_12m : in std_logic;
        reset_n : in std_logic;

        -- Screen Buffer Interface
        wEn     : in std_logic;         -- Write Enable
        charNum : in std_logic_vector(4 downto 0);  -- convert internally to integer range 0 to 31; 
        dIn     : in std_logic_vector(7 downto 0);  -- Data in


        -- LCD Interface
        lcdRS   : out std_logic;
        lcdE    : out std_logic;
        lcdData : out std_logic_vector(3 downto 0)
        );
end lcd_driver;

-------------------------------------------------------------------------------

architecture Structural of lcd_driver is

  -- LCD interface constants
  constant DATA_CODE : std_logic := '1';
  constant INST_CODE : std_logic := '0';

  -- Tick Generation, generates a tick pulse every 10us => 100KHz
  -- the value of TICK_MAX needs to correspond to the divider ratio
  constant TICK_MAX : integer := CLK_FREQ / 100_000;  -- in the case of clk_12M5, the ratio = 125
  signal tick       : std_logic;

  -- Delay times in units of 10 us
  constant WARMUP_DELAY : integer := 500;  -- 5ms
  constant INIT_DELAY   : integer := 20;   -- 200us
  constant CHAR_DELAY   : integer := 10;   -- 100us

  signal timer : integer range 0 to WARMUP_DELAY;

  type INIT_ROM_TYPE is array (0 to 11) of std_logic_vector(3 downto 0);
  constant initROM : INIT_ROM_TYPE := (b"0011",  -- Init
                                       b"0011",  -- Init
                                       b"0011",  -- Init
                                       b"0010",  -- Init

                                       b"0010", b"1000",  -- Function Set: 4 bit, 2 lines, 5x7 characters
                                       b"0000", b"1000",  -- Display On/Off Control: Display off, Cursor off, Blink off
                                       b"0000", b"1100",  -- Display On/Off Control: Display on, Cursor off, Blink off
                                       b"0000", b"0110");  -- Entry Mode Set: Auto increment cursor, don't shift display

  type CHAR_RAM_TYPE is array(0 to 31) of std_logic_vector(7 downto 0);
  signal charRAM : CHAR_RAM_TYPE := (0      => x"A0", 1 => x"A0", 2 => x"A0", 3 => x"A0", 4 => x"2D", 5 => x"2D",
                                     6      => x"5A", 7 => x"48", 8 => x"41", 9 => x"57",  --ZHAW
                                     10     => x"2D", 11 => x"2D", 12 => x"A0", 13 => x"A0", 14 => x"A0", 15 => x"A0",
                                     16     => x"A0", 17 => x"A0", 18 => x"A0", 19 => x"A0", 20 => x"A0", 21 => x"A0",
                                     22     => x"44", 23 => x"54", 24 => x"50", 25 => x"32",
                                     26     => x"A0", 27 => x"A0", 28 => x"A0", 29 => x"A0", 30 => x"A0", 31 => x"A0",
                                     others => x"A0");

  signal setLine      : std_logic;
  signal lineNum      : integer range 0 to 1;
  signal initialising : std_logic;
  signal nibble       : std_logic;

  signal initROMPointer : integer range 0 to INIT_ROM_TYPE'high;
  signal charRAMPointer : integer range 0 to CHAR_RAM_TYPE'high;

  type STATE_TYPE is (DELAY, STAGE1, STAGE2, STAGE3);
  signal state : STATE_TYPE;

begin

  TickGen : process(clk_12m, reset_n)
    variable tickCount : integer range 0 to TICK_MAX-1;
  begin
    if rising_edge(clk_12m) then
      if (reset_n = '0') then           -- synchronous reset
        tickCount := 0;
        tick      <= '0';

      elsif (tickCount = TICK_MAX-1) then
        tickCount := 0;
        tick      <= '1';

      else
        tickCount := tickCount + 1;
        tick      <= '0';

      end if;
    end if;
  end process;

  CharRAMWrite : process(clk_12m, charNum)
    variable charNumInt : integer range 0 to 31;
  begin
    charNumInt := to_integer(unsigned(charNum));
    if rising_edge(clk_12m) then
      if (wEn = '1') then
        charRAM(charNumInt) <= dIn;
      end if;
    end if;
  end process;

  Controller : process (clk_12m, reset_n, charRAM)
  begin
    if rising_edge(clk_12m) then

      if (reset_n = '0') then
        timer          <= WARMUP_DELAY;
        initROMPointer <= 0;
        charRAMPointer <= 0;

        lcdRS   <= INST_CODE;
        lcdE    <= '0';
        lcdData <= (others => '0');

        nibble       <= '0';
        initialising <= '1';
        setLine      <= '0';
        lineNum      <= 0;
        state        <= DELAY;

      elsif (tick = '1') then

        case state is

          -- Provide delay to allow instruction to execute
          when DELAY =>
            if (timer = 0) then
              state <= STAGE1;
            else
              timer <= timer - 1;
            end if;

          -- Set the LCD data
          -- Set the LCD RS
          -- Initialise the timer with the required delay
          when STAGE1 =>
            if (initialising = '1') then
              timer   <= INIT_DELAY;
              lcdRS   <= INST_CODE;
              lcdData <= initROM(initROMPointer);

            elsif (setLine = '1') then
              timer <= CHAR_DELAY;
              lcdRS <= INST_CODE;

              if (nibble = '0') then
                case lineNum is
                  when 0 => lcdData <= b"1000";  -- Write Line 0
                  when 1 => lcdData <= b"1100";  -- Write Line 1
                end case;
              else
                lcdData <= b"0000";
              end if;

            else
              timer <= CHAR_DELAY;
              lcdRS <= DATA_CODE;

              if (nibble = '0') then
                lcdData <= charRAM(charRAMPointer)(7 downto 4);
              else
                lcdData <= charRAM(charRAMPointer)(3 downto 0);
              end if;
            end if;

            state <= STAGE2;

-- Set lcdE (latching RS and RW)
          when STAGE2 =>
            if (initialising = '1') then
              if (initROMPointer = INIT_ROM_TYPE'high) then
                initialising <= '0';
              else
                initROMPointer <= initROMPointer + 1;
              end if;

            elsif (nibble = '1') then
              nibble <= '0';

              if (setLine = '1') then
                setLine <= '0';

              else

                if (charRAMPointer = 15) then
                  setLine <= '1';
                  lineNum <= 1;

                elsif (charRAMPointer = 31) then
                  setLine <= '1';
                  lineNum <= 0;
                end if;

                if (charRAMPointer = CHAR_RAM_TYPE'high) then
                  charRAMPointer <= 0;
                else
                  charRAMPointer <= charRAMPointer + 1;
                end if;

              end if;

            else
              nibble <= '1';

            end if;

            lcdE  <= '1';
            state <= STAGE3;

          -- Clear lcdE (latching data)
          when STAGE3 =>
            lcdE <= '0';

                                        -- No delay required between nibbles
            if (nibble = '1') then
              state <= STAGE1;
            else
              state <= DELAY;
            end if;

        end case;
      end if;
    end if;
  end process;

end Structural;
