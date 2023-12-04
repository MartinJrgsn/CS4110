library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity edgeDetector is
    Port (clk, echo_pwm, clear_done : in std_logic;
           echo_done, echo_active: out std_logic
	 );
end edgeDetector;

architecture arch of edgeDetector is
    signal echo_pwm_prev: std_logic;
    signal falling_edge_detected: std_logic;

begin
    

    process(clk)
    begin
        if rising_edge(clk) then
            -- Falling edge detection for echo_pwm
            if echo_pwm_prev = '1' and echo_pwm = '0' then
                echo_done <= '1';
            elsif clear_done = '1' then
                echo_done <= '0';
            end if;

            -- Update the previous state of echo_pwm
            echo_pwm_prev <= echo_pwm;
            echo_active <= echo_pwm;
        end if;
    end process;
end arch;

