--------------------------------------------------------------------------------------------------------------------
-- Design Name    : Clock Divider   
-- Description    : Configurable Clock Divider         
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
Entity clock_divider is

    Generic (
               DV            : natural := 4         -- Clock division factor > 1, multiples of 2
            ) ;     

    Port    ( 
               clk           : in  std_logic  ;     -- Clock
               rstn          : in  std_logic  ;     -- Synchronous Reset
               clk_o         : out std_logic        -- Divided Clock out
            ) ;

end Entity ;

--------------------------------------------------------------------------------------------------------------------
-- ARCHITECTURE DEFINITION
--------------------------------------------------------------------------------------------------------------------
Architecture Behavioral of clock_divider is

-- Internal signals/registers
signal clk_rg : std_logic               ;        -- Clock out register
signal count  : integer range 0 to DV/2 ;        -- Counter

begin

-- Clock divider process
process (clk)
begin
   
   if rising_edge (clk) then
      
      if rstn = '0' then
         
         clk_rg <= '0';
         count  <= 0  ;

      else    

         if (count = DV/2) then
            count  <= 1          ;
            clk_rg <= not clk_rg ;
         else
            count  <= count + 1  ;                              	                     
         end if ;

      end if ;
      
   end if ;

end process ;

-- Clock out
clk_o <= clk_rg ;

end Architecture ;

--------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------