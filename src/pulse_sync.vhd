--------------------------------------------------------------------------------------------------------------------
-- Design Name    : Handshake-based Pulse/Toggle Synchroniser for Clock Domain Crossing   
-- Description    : - Synchronises single-cycle pulse from Clock domain A to Clock domain B
--                  - Handshake-based synchroniser for safe and reliable transfers
--                  - Configurable no. of flip-flops in the synchroniser chains         
-- Date           : 13-02-2021
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
Entity pulse_sync is

    Generic (   
               STAGES        : natural := 2         -- Recommended = 2 flops; >2 for high speed 
            ) ;     
             
    Port    ( 
               clk_a         : in  std_logic  ;     -- Clock of Domain-A
               rstn_a        : in  std_logic  ;     -- Synchronous Reset of Domain-A
               clk_b         : in  std_logic  ;     -- Clock of Domain-B
               rstn_b        : in  std_logic  ;     -- Synchronous Reset of Domain-B
               pulseA_i      : in  std_logic  ;     -- Pulse originated at Domain-A
               pulseB_o      : out std_logic  ;     -- Synchronized pulse generated at Domain-B
               busy_o        : out std_logic        -- Busy processing the pulse from Domain-A
            );

end Entity;

--------------------------------------------------------------------------------------------------------------------
-- ARCHITECTURE DEFINITION
--------------------------------------------------------------------------------------------------------------------
Architecture Behavioral of pulse_sync is

--------------------------------------------------------------------------------------------------------------------
-- Synchronisation Chain of Flip-Flops
--------------------------------------------------------------------------------------------------------------------
signal flipflops_a   : std_logic_vector (STAGES-1 downto 0) ;        -- At Domain-A
signal flipflops_b   : std_logic_vector (STAGES-1 downto 0) ;        -- At Domain-B
--------------------------------------------------------------------------------------------------------------------

-- Other signals/registers
signal pulseA_regA   : std_logic  ;        -- Pulse sampled at Domain-A
signal busyB         : std_logic  ;        -- Busy signal from Domain-B
signal busyB_delayed : std_logic  ;        -- Busy signal from Domain-B cycle-delayed
signal busyB_syncA   : std_logic  ;        -- Busy signal from Domain-B synchronised to Domain-A

--------------------------------------------------------------------------------------------------------------------
-- These attributes are native to XST and Vivado Synthesisers.
-- They make sure that the synchronisers are not optimised to shift register primitives.
-- They are correctly implemented in the FPGA, by placing them together in the same slice.
-- Maximise MTBF while place and route.
-- Altera has different attributes.
--------------------------------------------------------------------------------------------------------------------
attribute ASYNC_REG : string                          ;
attribute ASYNC_REG of flipflops_a : signal is "true" ;
attribute ASYNC_REG of flipflops_b : signal is "true" ;
--------------------------------------------------------------------------------------------------------------------

begin

-- Synchroniser at Domain-A that synchronises the busy signal generated at Domain-B
process (clk_a)
begin
   
   if rising_edge (clk_a) then 

      if (rstn_a = '0') then
         flipflops_a <= (others => '0')                                   ;
      else
         flipflops_a <= flipflops_a (flipflops_a'high-1 downto 0) & busyB ;              	         
      end if ;

   end if ;

end process ;

-- Pulse sampler at Domain-A, converts the pulse to level based on the busy status from Domain-B
process (clk_a)
begin
   
   if rising_edge (clk_a) then 

      if (rstn_a = '0') then
         pulseA_regA <= '0'                                             ;
      else
         pulseA_regA <= pulseA_i or (pulseA_regA and (not busyB_syncA)) ;              	         
      end if ;

   end if ;

end process ;

-- Synchroniser at Domain-B that synchronises the sampled pulse from Domain-A
process (clk_b)
begin
   
   if rising_edge (clk_b) then 

      if (rstn_b = '0') then
         flipflops_b   <= (others => '0')                                         ;
         busyB_delayed <= '0'                                                     ;
      else
         flipflops_b   <= flipflops_b (flipflops_b'high-1 downto 0) & pulseA_regA ;
         -- Generate the delayed busyB signal
         busyB_delayed <= flipflops_b (flipflops_b'high)                          ;              	         
      end if ;     

   end if ;

end process ;

-- Concurrent assignments
busyB       <= flipflops_b (flipflops_b'high) ;
busyB_syncA <= flipflops_a (flipflops_a'high) ;
busy_o      <= busyB_syncA or pulseA_regA     ;
pulseB_o    <= busyB and (not busyB_delayed)  ;

end Architecture ;

--------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------