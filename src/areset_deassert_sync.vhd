--------------------------------------------------------------------------------------------------------------------
-- Design Name    : Synchroniser for de-assertion of Asynchronous Reset   
-- Description    : Synchronises de-assertion of Asynchronous Reset to a clock domain.
--                  Configurable no. of flip-flops in the synchroniser chain, Reset polarity.         
-- Date           : 13-02-2021
-- Designed By    : Mitu Raj, chip@chipmunklogic.com at Chipmunk Logic ™, https://chipmunklogic.com
-- Comments       : Attributes are important for proper FPGA implementation, cross check synthesised design
--------------------------------------------------------------------------------------------------------------------

--------------------------------------------------------------------------------------------------------------------
-- LIBRARIES
--------------------------------------------------------------------------------------------------------------------
Library IEEE                ;
use IEEE.std_logic_1164.all ;

--------------------------------------------------------------------------------------------------------------------
-- ENTITY DECLARATION
--------------------------------------------------------------------------------------------------------------------
Entity areset_deassert_sync is
   
   generic (
              CHAINS      : natural   := 2   ;        -- No. of flip-flops in the synchronization chain; at least
              RST_POL     : std_logic := '1'          -- Polarity of Asynchronous Reset
           ) ;                                        -- same is the pulse width of reset assertion            

   port    (
              clk         : in  std_logic    ;        -- Clock
              async_rst_i : in  std_logic    ;        -- Asynchronous Reset
              sync_rst_o  : out std_logic             -- Asynchronous Reset with de-assertion synchronized
           ) ;

end entity ;

--------------------------------------------------------------------------------------------------------------------
-- ARCHITECTURE DEFINITION
--------------------------------------------------------------------------------------------------------------------
Architecture behav of areset_deassert_sync is

--------------------------------------------------------------------------------------------------------------------
-- Synchronisation Chain of Flip-Flops
--------------------------------------------------------------------------------------------------------------------
signal flipflops : std_logic_vector(CHAINS-1 downto 0) ;
--------------------------------------------------------------------------------------------------------------------

--------------------------------------------------------------------------------------------------------------------
-- These attributes are native to XST and Vivado Synthesisers.
-- They make sure that the synchronisers are not optimised to shift register primitives.
-- They are correctly implemented in the FPGA, by placing them together in the same slice.
-- Maximise MTBF while place and route.
-- Altera has different attributes.
--------------------------------------------------------------------------------------------------------------------
attribute ASYNC_REG : string;
attribute ASYNC_REG of flipflops: signal is "true";
--------------------------------------------------------------------------------------------------------------------

begin

-- Synchronizer process
process (clk, async_rst_i)
begin
   
   if (async_rst_i = RST_POL) then
      flipflops <= (others => RST_POL)                                  ;
   elsif (rising_edge (clk)) then
      flipflops <= flipflops(flipflops'high-1 downto 0) & (not RST_POL) ;
   end if ;

end process ;

-- Reset out with synchronized de-assertion
sync_rst_o <= flipflops(flipflops'high) ;

end Architecture ;

--------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------