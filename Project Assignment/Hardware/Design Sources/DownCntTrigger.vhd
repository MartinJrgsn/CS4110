library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity down_counter_trigger is
    Port ( clk, rst, up: in std_logic;
           dout: out std_logic
     );
end down_counter_trigger;

architecture arch of down_counter_trigger is
signal ffin, ffout: std_logic_vector (31 downto 0);

begin
-- state register section
process (clk, rst)
   begin
   if (rst = '1') then
      ffout <= std_logic_vector(to_unsigned(1000, 32));
   elsif rising_edge(clk) then
      ffout <= ffin;
   end if;
end process;

-- outputs section
ffin <= std_logic_vector(unsigned(ffout) - 1) when up='1' AND unsigned(ffout) > 0 else
        ffout;

dout <= '1' when (unsigned(ffout) = "00000000000000000000000000000000") else '0';





end arch;