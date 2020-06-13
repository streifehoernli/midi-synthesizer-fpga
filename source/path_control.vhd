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
-- source name: path_control
-- Datum:       14.06.2020
-------------------------------------------

-- Library & Use Statements
-------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;


-- Entity Declaration 
-------------------------------------------
ENTITY path_control IS
  PORT( 
    	loop_back_i	    : IN    std_logic;
    	dds_l_i 	    : IN    std_logic_vector(15 downto 0);
    	dds_r_i 	    : IN    std_logic_vector(15 downto 0);
    	adcdat_pl_i 	: IN    std_logic_vector(15 downto 0);
    	adcdat_pr_i 	: IN    std_logic_vector(15 downto 0);
    	dacdat_pl_o     : OUT   std_logic_vector(15 downto 0);
    	dacdat_pr_o     : OUT   std_logic_vector(15 downto 0)
    	);
END path_control;


-- Architecture Declaration?
-------------------------------------------
ARCHITECTURE rtl OF path_control IS
-- Signals & Constants Declaration
-------------------------------------------

-- Begin Architecture
-------------------------------------------
BEGIN
	
	dacdat_pl_o <= 		adcdat_pl_i WHEN loop_back_i = '1'
				   ELSE dds_l_i;
					   
	dacdat_pr_o <= 		adcdat_pr_i WHEN loop_back_i = '1'
				   ELSE dds_r_i;
  
 -- End Architecture 
------------------------------------------- 
END rtl;

