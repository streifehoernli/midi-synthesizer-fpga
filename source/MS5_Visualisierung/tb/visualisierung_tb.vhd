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
-- source name: visualisierung
-- Datum:       14.06.2020
-------------------------------------------


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.all;
use std.textio.all;
use work.simulation_pkg.all;
use work.standard_driver_pkg.all;
use work.user_driver_pkg.all;


-------------------------------------------------------------------------------

entity visualisierung_tb is

end entity visualisierung_tb;

-------------------------------------------------------------------------------

architecture struct of visualisierung_tb is

	component visualisierung is
		port(
				 audiodata_i : in  std_logic_vector(15 downto 0);
				 led_o      : out std_logic_vector(17 downto 0);
				 switch			 : in	std_logic
		);
	end component visualisierung;
	
	
  signal SW           : std_logic_vector(17 downto 0);
  signal switch 		  : std_logic_vector(31 downto 0);
	signal audio_data_s : std_logic_vector(15 downto 0);
	signal led_signal_s : std_logic_vector(17 downto 0);
	
	constant clock_freq   : natural := 50_000_000;
  constant clock_period : time    := 1000 ms/clock_freq;
	
begin

DUT: visualisierung
    port map (
      audiodata_i => audio_data_s,
      led_o       => led_signal_s,
      switch 		  => SW(17)
);
	
	
	readcmd : process
    -- This process loops through a file and reads one line
    -- at a time, parsing the line to get the values and
    -- expected result.

    variable cmd          : string(1 to 7);  --stores test command
    variable line_in      : line; --stores the to be processed line     
    variable tv           : test_vect; --stores arguments 1 to 4
    variable lincnt       : integer := 0;  --counts line number in testcase file
    variable fail_counter : integer := 0;--counts failed tests



  begin
    -------------------------------------
    -- Open the Input and output files
    -------------------------------------
    FILE_OPEN(cmdfile, "../testcase.dat", read_mode);
    FILE_OPEN(outfile, "../results.dat", write_mode);

    -------------------------------------
    -- Start the loop
    -------------------------------------


    loop

      --------------------------------------------------------------------------
      -- Check for end of test file and print out results at the end
      --------------------------------------------------------------------------


      if endfile(cmdfile) then          -- Check EOF
        end_simulation(fail_counter);
        exit;
      end if;

      --------------------------------------------------------------------------
      -- Read all the argumnents and commands
      --------------------------------------------------------------------------

      readline(cmdfile, line_in);       -- Read a line from the file
      lincnt := lincnt + 1;


      next when line_in'length = 0;     -- Skip empty lines
      next when line_in.all(1) = '#';   -- Skip lines starting with #

      read_arguments(tv, line_in, cmd);
      tv.clock_period := clock_period;
	
	
			if cmd = string'("run_sim") then
        run_sim(tv);
      elsif cmd = string'("gpi_sim") then
        gpi_sim(tv, switch);
			elsif cmd = string'("vis_sim") then
        vis_sim(tv, audio_data_s);
			else
        assert false
          report "Unknown Command"
          severity failure;
      end if;

      if tv.fail_flag = true then --count failures in tests
        fail_counter := fail_counter + 1;
      else fail_counter := fail_counter;
      end if;

    end loop; --finished processing command line

    wait; -- to avoid infinite loop simulator warning

  end process;
	
	SW <= switch(17 downto 0);

end architecture struct;
