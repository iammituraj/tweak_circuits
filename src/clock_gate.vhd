--------------------------------------------------------------------------------------------------------------------
-- Design Name    : Clock Gate  
-- Description    : Latch-based circuit to gate input clock and generate a gated clock.       
-- Date           : 16-02-2021
-- Designed By    : Mitu Raj, chip@chipmunklogic.com at Chipmunk Logic ™, https://chipmunklogic.com
-- Comments       : Not recommended to synthesise on FPGAs.
--------------------------------------------------------------------------------------------------------------------

--------------------------------------------------------------------------------------------------------------------
-- LIBRARIES
--------------------------------------------------------------------------------------------------------------------
Library IEEE                ;
use IEEE.STD_LOGIC_1164.all ;

--------------------------------------------------------------------------------------------------------------------
-- ENTITY DECLARATION
--------------------------------------------------------------------------------------------------------------------
Entity clock_gate is

    Port    ( 
               clk_i    : in  std_logic  ;     -- Clock in
               en_i     : in  std_logic  ;     -- Gate enable 
               clk_o    : out std_logic        -- Gated Clock out
            ) ;

end Entity ;

--------------------------------------------------------------------------------------------------------------------
-- ARCHITECTURE DEFINITION
--------------------------------------------------------------------------------------------------------------------
Architecture behavioral of clock_gate is

-- Latched Gate Enable signal
signal en_latched : std_logic ;

begin

-- Combinational logic to generate gated clock
en_latched <= en_i when clk_i = '0' ;
clk_o      <= clk_i and en_latched  ;

end Architecture ;

--------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------