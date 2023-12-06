----------------------------------------------------------------------------------
-- Engineer / candidate nr: Nikolai Eidheim - 8507
-- 
-- Create Date: 11.2023
-- Module Name: downcounter for right
-- Project Name: Hardware only solution
-- Additional Comments:
        --  based on cnt8bits
        -- "-- USN VHDL 101 course
        -- 8-bit up/down counter
        -- author: josemmf@usn.no"
----------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity down_counter_right is
    Port ( clk, rst, up: in std_logic;
           dout: out std_logic
     );
end down_counter_right;

architecture arch of down_counter_right is
signal ffin, ffout: std_logic_vector (31 downto 0);

begin
-- resets down counter if reset is on
-- else on rising edge updates ffout
process (clk, rst)
   begin
   if (rst = '1') then
      ffout <= std_logic_vector(to_unsigned(200000000, 32)); -- 2 seconds in clk, 32 bits
   elsif rising_edge(clk) then
      ffout <= ffin;
   end if;
end process;

-- ffin is incremeneted if bigger than 0 and control path signal is on.
-- else it stays on the same value.
ffin <= std_logic_vector(unsigned(ffout) - 1) when up='1' AND unsigned(ffout) > 0 else
        ffout;
-- 1 if counter reaches 0
dout <= '1' when (unsigned(ffout) = "00000000000000000000000000000000") else '0';





end arch;
