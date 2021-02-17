--------------------------------------------------------------------------------------------------------------------
-- Design Name    : Mux-based Data Synchroniser for Clock Domain Crossing   
-- Description    : - To synchronise data between clock domains using data ready synchroniser + mux
--                  - Configurable no. of flip-flops in the synchroniser chain         
-- Date           : 17-02-2021
-- Designed By    : Mitu Raj, iammituraj@gmail.com
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
Entity data_sync is

   Generic (
              STAGES : natural := 2 ;          -- Recommended 2 flip-flops for low speed designs; >2 for high speed
              DWIDTH : natural := 8            -- Data width
           ) ;     

   Port    ( 
               clk      : in  std_logic                            ;     -- Clock
               rstn     : in  std_logic                            ;     -- Synchronous Reset               
               din      : in  std_logic_vector (DWIDTH-1 downto 0) ;     -- Asynchronous Data in
               dready_i : in  std_logic                            ;     -- Asynchronous Data ready in
               dout     : out std_logic_vector (DWIDTH-1 downto 0) ;     -- Synchronous Data out
               dready_o : out std_logic                                  -- Synchronous Data ready out  
            ) ;

end Entity ;

--------------------------------------------------------------------------------------------------------------------
-- ARCHITECTURE DEFINITION
--------------------------------------------------------------------------------------------------------------------
Architecture Behavioral of data_sync is

--------------------------------------------------------------------------------------------------------------------
-- Synchronisation Chain of Flip-Flops for Data ready
--------------------------------------------------------------------------------------------------------------------
signal flipflops : std_logic_vector (STAGES-1 downto 0) ;
--------------------------------------------------------------------------------------------------------------------

-- Data ready signal synchronised
signal dready_sync : std_logic ;

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

   -- Synchroniser process for Data ready
   clk_proc: process (clk)
             begin

                if rising_edge (clk) then

                   if rstn = '0' then
                      flipflops <= (others => '0') ;
                   else                                                        
                      flipflops <= flipflops(flipflops'high-1 downto 0) & dready_i ;
                   end if ;  

                end if ;

             end process ;

   -- Register process for Data in
   reg_proc: process (clk)
             begin

                if rising_edge (clk) then

                   if rstn = '0' then

                      dout     <= (others => '0') ;
                      dready_o <= '0'             ;

                   else

                      if dready_sync = '1' then
                         dout  <= din             ;    -- Mux + register logic
                      end if ; 

                      dready_o <= dready_sync     ;

                   end if ;

                end if ;

             end process ;

   -- Synchronised signal out
   dready_sync <= flipflops(flipflops'high) ;

end Behavioral ;

--------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------