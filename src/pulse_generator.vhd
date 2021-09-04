--------------------------------------------------------------------------------------------------------------------
-- Design Name    : Pulse Generator   
-- Description    : Generates a pulse of one cycle at user defined intervals.     
-- Date           : 14-02-2021
-- Designed By    : Mitu Raj, iammituraj@gmail.com
-- Comments       : -
--------------------------------------------------------------------------------------------------------------------

--------------------------------------------------------------------------------------------------------------------
-- LIBRARIES
--------------------------------------------------------------------------------------------------------------------
Library IEEE                ;
use IEEE.STD_LOGIC_1164.all ;

--------------------------------------------------------------------------------------------------------------------
-- ENTITY DECLARATION
--------------------------------------------------------------------------------------------------------------------
Entity pulse_generator is

    Generic (
               PERIOD        : natural := 4         -- Interval of how many clock cycles, > 1
            ) ;     

    Port    ( 
               clk           : in  std_logic  ;     -- Clock
               rstn          : in  std_logic  ;     -- Synchronous Reset
               pulse_o       : out std_logic        -- Pulse out
            ) ;

end Entity ;

--------------------------------------------------------------------------------------------------------------------
-- ARCHITECTURE DEFINITION
--------------------------------------------------------------------------------------------------------------------
Architecture behavioral of pulse_generator is

-- Internal signals/registers
signal pulse_rg : std_logic                   ;        -- Pulse out register
signal count    : integer range 0 to PERIOD-1 ;        -- Counter

begin

-- Pulse generator process
process (clk)
begin
   
   if rising_edge (clk) then
      
      if rstn = '0' then
         
         pulse_rg <= '0';
         count    <= 0  ;

      else    
         
         if (count = PERIOD-1) then
            count    <= 0         ;
            pulse_rg <= '1'       ;
         else
            pulse_rg <= '0'       ;         
            count    <= count + 1 ;                              	                     
         end if ;

      end if ;
      
   end if ;

end process ;

-- Pulse out
pulse_o <= pulse_rg ;

end Architecture ;

--------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------