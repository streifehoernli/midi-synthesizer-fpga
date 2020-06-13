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
-- source name: shiftreg_p2s
-- Datum:       14.06.2020
-------------------------------------------

-- Library & Use shiftregments
-------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;


-- Entity Declaration 
-------------------------------------------
ENTITY shiftreg_p2s IS
  generic (width : positive := 5);
  PORT( clk     		: IN    std_logic;
  		load_i			: IN    std_logic;
  		shift_i			: IN    std_logic;
  		enable_i	    : IN    std_logic;
    	par_i 	     	: IN    std_logic_vector(width-1 downto 0);
    	ser_o       	: OUT   std_logic
    	);
END shiftreg_p2s;


-- Architecture Declaration?
-------------------------------------------
ARCHITECTURE rtl OF shiftreg_p2s IS
-- Signals & Constants Declaration
-------------------------------------------
SIGNAL 		shiftreg, next_shiftreg: 	std_logic_vector(width-1 downto 0);	 


-- Begin Architecture
-------------------------------------------
BEGIN

  --------------------------------------------------
  -- PROCESS FOR COMBINATORIAL LOGIC
  --------------------------------------------------
  comb_logic: PROCESS(all)
  BEGIN	
	next_shiftreg <= shiftreg;
	-- load	
	IF (load_i = '1') THEN
		next_shiftreg <= par_i;
  	-- shift
  	ELSIF enable_i = '1' AND shift_i = '1' then
		next_shiftreg <= shiftreg(width-2 downto 0) & '1';
	END IF;
	
  END PROCESS comb_logic;   
  
  --------------------------------------------------
  -- PROCESS FOR REGISTERS
  --------------------------------------------------
  flip_flops : PROCESS(clk)
  BEGIN	
    IF rising_edge(clk) THEN
		shiftreg <= next_shiftreg ;
    END IF;
  END PROCESS flip_flops;		
  
  
  ser_o <= shiftreg(width-1);
  
  
 -- End Architecture 
------------------------------------------- 
END rtl;

