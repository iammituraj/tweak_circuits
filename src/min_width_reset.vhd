--------------------------------------------------------------------------------------------------------------------
-- Design Name    : Minimum Pulse Width Reset Logic   
-- Description    : Ensures minimum pulse width for proper reset assertion and de-assertion at input and output.
--                  Used for glitch filtering.
--                  Configurable reset polarity, Configurable min. pulse width to be recognized at input.        
-- Date           : 16-02-2021
-- Designed By    : Mitu Raj, iammituraj@gmail.com
-- Comments       : Attributes make sure that the sync flops are placed close to each other on FPGA.
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
               MIN_WIDTH   : natural   := 4   ;     -- Minimum pulse width of reset to be recognized, [2-16] 
               RST_POL     : std_logic := '0'       -- Polarity of Synchronous Reset   
            ) ;     

    Port    ( 
               clk         : in  std_logic    ;     -- Clock
               rst_i       : in  std_logic    ;     -- Synchronous Reset in
               rst_o       : out std_logic          -- Synchronous Reset out with min. pulse width assured  
            ) ;

end Entity ;

--------------------------------------------------------------------------------------------------------------------
-- ARCHITECTURE DEFINITION
--------------------------------------------------------------------------------------------------------------------
Architecture behavioral of min_width_reset is

--------------------------------------------------------------------------------------------------------------------
-- Pulse Width Validator Chain : Synchronous Chain of Flip-Flops
--------------------------------------------------------------------------------------------------------------------
signal sync_chain_rg     : std_logic_vector (MIN_WIDTH-1 downto 0) := (others => not RST_POL) ;
--------------------------------------------------------------------------------------------------------------------

-- Temporary signals
signal temp_level0       : std_logic_vector (MIN_WIDTH-1 downto 0) ;
signal temp_level1       : std_logic_vector (MIN_WIDTH-1 downto 0) ;

-- Muxed resets
signal muxed_sync_rst    : std_logic                               ;
signal muxed_sync_rst_rg : std_logic := RST_POL                    ;

--------------------------------------------------------------------------------------------------------------------
-- These attributes are native to XST and Vivado Synthesisers.
-- They make sure that the synchronisers are not optimised to shift register primitives.
-- They are correctly implemented in the FPGA, by placing them together in the same slice.
-- Maximise MTBF while place and route.
-- Altera has different attributes.
--------------------------------------------------------------------------------------------------------------------
attribute ASYNC_REG                  : string           ;
attribute ASYNC_REG of sync_chain_rg : signal is "true" ;
--------------------------------------------------------------------------------------------------------------------

begin

-- Clocked process
process (clk) 
begin
   
   if rising_edge (clk) then
      sync_chain_rg     <= sync_chain_rg(sync_chain_rg'high-1 downto 0) & rst_i ;
      muxed_sync_rst_rg <= muxed_sync_rst                                       ;                       
   end if ;

end process ;

-- Generate statement to self-OR and self-AND all bits of Synchronizer chain */
temp_level0 (0) <= sync_chain_rg (0) ;
temp_level1 (0) <= sync_chain_rg (0) ;

gen: for i in 1 to MIN_WIDTH-1 generate
      
     temp_level1 (i) <= temp_level1 (i-1) and sync_chain_rg (i) ;
     temp_level0 (i) <= temp_level0 (i-1) or sync_chain_rg (i)  ;  

end generate ; 

-- Muxed reset
muxed_sync_rst <= temp_level0 (MIN_WIDTH-1) when muxed_sync_rst_rg else temp_level1 (MIN_WIDTH-1) ;

-- Reset out
rst_o <= muxed_sync_rst_rg ;

end Architecture ;

--------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------
