library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity down_counter_echo is
    Generic (
           COUNTER_SIZE : INTEGER := 23
    );
    Port ( clk, rst, echo: in std_logic;
           trig, dout: out std_logic;
           distance : out std_logic_vector(8 downto 0)
     );
end down_counter_echo;

architecture arch of down_counter_echo is
signal counter, counter_next: std_logic_vector (COUNTER_SIZE-1 downto 0);
signal measured_distance : std_logic_vector(8 downto 0);

constant CM : INTEGER := 5831;
constant THRESHOLD : INTEGER := 12*CM;
constant PWM_PERIOD : INTEGER := 3800000;

begin
-- state register section
process (clk, rst)
   begin
   if (rst = '1') then
      counter <= (others => '0');
      distance <= (others => '0');
   elsif rising_edge(clk) then
      counter <= counter_next;
      if (measured_distance >= std_logic_vector(to_unsigned(2, 9)) and 
          measured_distance <= std_logic_vector(to_unsigned(400, 9))) then
          distance <= measured_distance;
      else
          distance <= (others => '0');
      end if;
   end if;
   
end process;

counter_next <= std_logic_vector(unsigned(counter) + 1) when unsigned(counter) < PWM_PERIOD else (others => '0');
trig <= '1' when unsigned(counter) < 1000 else '0';
-- outputs section
dout <= '1' when (unsigned(counter) > THRESHOLD) and echo = '1' else '0'; -- Set dout to 1 if distance > threshold, else 0
measured_distance <= std_logic_vector(to_unsigned(to_integer(unsigned(counter)) / CM, distance'length)) when echo = '0';

end arch;
