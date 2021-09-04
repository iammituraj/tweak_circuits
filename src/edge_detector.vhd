--------------------------------------------------------------------------------------------------------------------
-- Design Name    : Edge Detector   
-- Description    : Rising and Falling edge detector.        
-- Date           : 05-07-2019
-- Designed By    : Mitu Raj, iammituraj@gmail.com
-- Comments       : NIL
--------------------------------------------------------------------------------------------------------------------

--------------------------------------------------------------------------------------------------------------------
-- LIBRARIES
--------------------------------------------------------------------------------------------------------------------
library IEEE                ;
use IEEE.std_logic_1164.all ;

--------------------------------------------------------------------------------------------------------------------
-- ENTITY DECLARATION
--------------------------------------------------------------------------------------------------------------------
entity edge_detector is

port ( 
        -- Global signals
        clk               : in  std_logic ;      -- Clock
        rst               : in  std_logic ;      -- Sync active-low Reset       
              
        sig_in            : in  std_logic ;      -- Signal in 
        
        -- Cycle-delayed edge detectors
        sig_out_r         : out std_logic ;      -- Rising edge detector
        sig_out_f         : out std_logic ;      -- Falling edge detector
        sig_out_rf        : out std_logic ;      -- Rising edge detector

        -- Zero-cycle-delay edge detectors
        sig_out_r_imm     : out std_logic ;      -- Rising edge detector
        sig_out_f_imm     : out std_logic ;      -- Falling edge detector
        sig_out_rf_imm    : out std_logic ;      -- Either edge detector

        -- Zero-cycle-delay edge detectors which are cycle-glitch-free on reset
        sig_out_r_imm_gl  : out std_logic ;      -- Rising edge detector      
        sig_out_rf_imm_gl : out std_logic       -- Either edge detector
     ) ;

end entity ;

--------------------------------------------------------------------------------------------------------------------
-- ARCHITECTURE DEFINITION
--------------------------------------------------------------------------------------------------------------------
architecture archi of edge_detector is

-- Internal signals/registers
signal sig_in_delayed : std_logic ;

begin
process (clk) 
begin
   if rising_edge(clk) then
   
      if rst = '0' then
         sig_out_r      <= '0' ;
         sig_out_f      <= '0' ;
         sig_out_rf     <= '0' ;
         sig_in_delayed <= '0' ;
      else
         
         -- Pulse for only one cycle
         sig_out_r      <= '0' ;
         sig_out_f      <= '0' ;
         sig_out_rf     <= '0' ;  

         -- Generate one cycle delayed version of sig_in       
         sig_in_delayed <= sig_in ;
         
         -- Detect rising edge of sig_in      
         if sig_in_delayed = '0' and sig_in = '1' then
            sig_out_r  <= '1' ;
            sig_out_rf <= '1' ;
         end if ;

         -- Detect falling edge of sig_in
         if sig_in_delayed = '1' and sig_in = '0' then
            sig_out_f  <= '1' ;
            sig_out_rf <= '1' ;
         end if ;
         
      end if ;

   end if ;   

end process ;

-- Zero-cycle-delay edge detectors
sig_out_r_imm  <= sig_in and (not sig_in_delayed) ;  
sig_out_f_imm  <= (not sig_in) and sig_in_delayed ;
sig_out_rf_imm <= sig_in xor sig_in_delayed       ;

-- Zero-cycle-delay edge detectors cycle-glitch-free on reset
sig_out_r_imm_gl  <= sig_in and (not sig_in_delayed) and rst  ;    
sig_out_rf_imm_gl <=  (sig_in xor sig_in_delayed) and rst     ;

end archi ;

--------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------