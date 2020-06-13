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
-- source name: flanken_detect
-- Datum:       14.06.2020
-------------------------------------------

-------------------------------------------
-- Block code:  flanken_detect.vhd
-- History: 	15.Nov.2017 - 1st version (dqtm)
--                 <date> - <changes>  (<author>)
-- Function: edge detector with rise & fall outputs. 
--           Declaring FFs as a shift-register.
-------------------------------------------

-- Library & Use Statements
LIBRARY ieee;
USE ieee.std_logic_1164.all;

-- Entity Declaration 
ENTITY flanken_detect IS
  PORT( data_in 	: IN    std_logic;
		clock		: IN    std_logic;
		reset_n		: IN    std_logic;
    	steig    	: OUT   std_logic;
		fall     	: OUT   std_logic
    	);
END flanken_detect;


-- Architecture Declaration 
ARCHITECTURE rtl OF flanken_detect IS

	-- Signals & Constants Declaration 
	SIGNAL shiftreg, next_shiftreg: std_logic_vector(1 downto 0);

	
-- Begin Architecture
BEGIN 
    -------------------------------------------
    -- Process for combinatorial logic
	-- OBs.: small logic, could be outside process, 
	--       but doing inside for didactical purposes!
    -------------------------------------------
	comb_proc : PROCESS(data_in, shiftreg)
	BEGIN	
		next_shiftreg <= data_in & shiftreg(1) ;  -- shift direction towards LSB		
	END PROCESS comb_proc;		
	 
	 -------------------------------------------
    -- Process for registers (flip-flops)
    -------------------------------------------
	reg_proc : PROCESS(clock, reset_n)
	BEGIN	
		IF reset_n = '0' THEN
			shiftreg <= (OTHERS => '0');
		ELSIF (rising_edge(clock)) THEN
			shiftreg <= next_shiftreg;
		END IF;
	END PROCESS reg_proc;	
	 
	 -------------------------------------------
    -- Concurrent Assignments  
    -------------------------------------------
	steig <=     shiftreg(1)  AND NOT(shiftreg(0));
	fall  <= NOT(shiftreg(1)) AND     shiftreg(0);
		
	
END rtl;	
