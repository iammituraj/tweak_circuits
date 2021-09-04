--------------------------------------------------------------------------------------------------------------------
-- Design Name    : Minimum Width Reset Validator and Generator   
-- Description    : Reset is asserted only if a minimum width reset pulse is applied at the input.
--                  Configurable no. of flip-flops in the stretcher chain.        
-- Date           : 16-02-2021
-- Designed By    : Mitu Raj, iammituraj@gmail.com
-- Comments       : Attributes make sure that the flops are placed close to each other on FPGA.
--------------------------------------------------------------------------------------------------------------------

--------------------------------------------------------------------------------------------------------------------
-- LIBRARIES
--------------------------------------------------------------------------------------------------------------------
Library IEEE                ;
use IEEE.STD_LOGIC_1164.all ;

--------------------------------------------------------------------------------------------------------------------
-- ENTITY DECLARATION
--------------------------------------------------------------------------------------------------------------------
Entity min_width_reset is

    Generic (
               PERIOD      : natural   := 4   ;     -- Min. no. of cycles reset has to be asserted
               RST_POL     : std_logic := '1'       -- Polarity of Synchronous Reset   
            ) ;     

    Port    ( 
               clk         : in  std_logic    ;     -- Clock
               rst_i       : in  std_logic    ;     -- Synchronous Reset in
               rst_o       : out std_logic          -- Synchronous Reset out
            ) ;

end Entity ;

--------------------------------------------------------------------------------------------------------------------
-- ARCHITECTURE DEFINITION
--------------------------------------------------------------------------------------------------------------------
Architecture behavioral of min_width_reset is

--------------------------------------------------------------------------------------------------------------------
-- Stretcher Chain : Synchronous Chain of Flip-Flops
--------------------------------------------------------------------------------------------------------------------
signal flipflops : std_logic_vector (PERIOD-1 downto 0) ;
--------------------------------------------------------------------------------------------------------------------

-- Temporary signal
signal temp : std_logic_vector (PERIOD-1 downto 0) ;

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

-- Clocked process
process (clk) 
begin
   
   if rising_edge (clk) then
      flipflops <= flipflops(flipflops'high-1 downto 0) & rst_i ;                 
   end if ;

end process ;

   temp (0) <= flipflops (0) ;

   gen: for i in 1 to PERIOD-1 generate

        ACTV_HIGH_RST : if RST_POL == 1 generate   
                           temp (i) <= temp (i-1) and flipflops (i) ;
                        end generate ;

        ACTV_LOW_RST  : if RST_POL == 0 generate   
                           temp (i) <= temp (i-1) or flipflops (i)  ;
                        end generate ;   

   end generate ; 

   rst_o <= temp (N-1) ;

end Architecture ;

--------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------