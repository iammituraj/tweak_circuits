--------------------------------------------------------------------------------------------------------------------
-- Design Name    : Synchronous Reset Stretcher   
-- Description    : Configurable no. of flip-flops in the stretcher chain.        
-- Date           : 16-02-2021
-- Designed By    : Mitu Raj, iammituraj@gmail.com
-- Comments       : Attributes make sure the flops are placed close to each other on FPGA.
--------------------------------------------------------------------------------------------------------------------

--------------------------------------------------------------------------------------------------------------------
-- LIBRARIES
--------------------------------------------------------------------------------------------------------------------
Library IEEE                ;
use IEEE.STD_LOGIC_1164.all ;

--------------------------------------------------------------------------------------------------------------------
-- ENTITY DECLARATION
--------------------------------------------------------------------------------------------------------------------
Entity reset_stretcher is

    Generic (
               PERIOD      : natural   := 4   ;     -- How many clock cycles to be stretched by
               RST_POL     : std_logic := '1'       -- Polarity of Synchronous Reset   
            ) ;     

    Port    ( 
               clk         : in  std_logic    ;     -- Clock
               rst_i       : in  std_logic    ;     -- Synchronous Reset in
               rst_o       : out std_logic          -- Stretched Synchronous Reset out
            ) ;

end Entity ;

--------------------------------------------------------------------------------------------------------------------
-- ARCHITECTURE DEFINITION
--------------------------------------------------------------------------------------------------------------------
Architecture Behavioral of reset_stretcher is

--------------------------------------------------------------------------------------------------------------------
-- Stretcher Chain : Synchronous Chain of Flip-Flops
--------------------------------------------------------------------------------------------------------------------
signal flipflops : std_logic_vector (PERIOD-1 downto 0) ;
--------------------------------------------------------------------------------------------------------------------

--------------------------------------------------------------------------------------------------------------------
-- These attributes are native to XST and Vivado Synthesisers.
-- They make sure that the synchronisers are not optimised to shift register primitives.
-- They are correctly implemented in the FPGA, by placing them together in the same slice.
-- Maximise MTBF while place and route.
-- Altera has different attributes.
--------------------------------------------------------------------------------------------------------------------
attribute ASYNC_REG              : string           ;
attribute ASYNC_REG of flipflops : signal is "true" ;
--------------------------------------------------------------------------------------------------------------------

begin

process (clk) 
begin
   
   if rising_edge (clk) then
      
      if rst_i = RST_POL then
         flipflops <= (others => RST_POL)                                  ;
      else
         flipflops <= flipflops(flipflops'high-1 downto 0) & (not RST_POL) ;                 
      end if ;

   end if ;

end process ;

-- Stretched Synchronous Reset out
rst_o <= flipflops (flipflops'high) ;

end Architecture ;

--------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------