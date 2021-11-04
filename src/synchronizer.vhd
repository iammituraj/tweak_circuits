--------------------------------------------------------------------------------------------------------------------
-- Design Name    : Single-bit Synchroniser for Clock Domain Crossing   
-- Description    : To synchronise control signals of one bit between clock domains.
--                  Configurable no. of flip-flops in the synchroniser chain.         
-- Date           : 05-07-2019
-- Designed By    : Mitu Raj, chip@chipmunklogic.com at Chipmunk Logic ™, https://chipmunklogic.com
-- Comments       : Attributes are important for proper FPGA implementation, cross check synthesised design
--------------------------------------------------------------------------------------------------------------------

--------------------------------------------------------------------------------------------------------------------
-- LIBRARIES
--------------------------------------------------------------------------------------------------------------------
Library IEEE                ;
use IEEE.STD_LOGIC_1164.all ;

--------------------------------------------------------------------------------------------------------------------
-- ENTITY DECLARATION
--------------------------------------------------------------------------------------------------------------------
Entity synchronizer is

    Generic (STAGES : natural := 2)     ;     -- Recommended 2 flip-flops for low speed designs; >2 for high speed

    Port ( 
          clk           : in std_logic  ;     -- Clock
          rstn          : in std_logic  ;     -- Synchronous Reset
          async_sig_i   : in std_logic  ;     -- Asynchronous signal in
          sync_sig_o    : out std_logic       -- Synchronized signal out
          ) ;

end synchronizer ;

--------------------------------------------------------------------------------------------------------------------
-- ARCHITECTURE DEFINITION
--------------------------------------------------------------------------------------------------------------------
Architecture behavioral of synchronizer is

--------------------------------------------------------------------------------------------------------------------
-- Synchronisation Chain of Flip-Flops
--------------------------------------------------------------------------------------------------------------------
signal flipflops : std_logic_vector(STAGES-1 downto 0) ;
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

   -- Synchroniser process
   clk_proc: process(clk)
             begin
                if rising_edge(clk) then
                   if (rstn = '0') then
                      flipflops <= (others => '0') ;
                   else                                                        
                      flipflops <= flipflops(flipflops'high-1 downto 0) & async_sig_i;
                   end if;                      
                end if;
             end process;

   -- Synchronised signal out
   sync_sig_o <= flipflops(flipflops'high) ;

end behavioral ;

--------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------