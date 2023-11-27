----------------------------------------------------------------------------------
-- Engineer: Martin J�rgensen
-- 
-- Create Date: 27.11.2023 10:00:43
-- Design Name: 
-- Module Name: pwm_module - arch
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.NUMERIC_STD.ALL;

entity UltrasonicSensor is
    Port (
        clk : in STD_LOGIC; -- 100MHz clock
        rst : in STD_LOGIC; -- Reset signal
        trigger : out STD_LOGIC; -- TRIG pin for HC-SR04
        echo : in STD_LOGIC; -- ECHO pin from HC-SR04
        threshold : in STD_LOGIC_VECTOR(7 downto 0); -- Threshold for checking if distance is above_limit (0-255)
        above_limit : out STD_LOGIC; -- Distance above limit
        distance : out STD_LOGIC_VECTOR(7 downto 0); -- Distance measured
        write_limit : in STD_LOGIC -- Set the threshold limit when high
    );
end UltrasonicSensor;

architecture Behavioral of UltrasonicSensor is
    signal counter, echo_start, echo_end : INTEGER range 0 to 5000000 := 0;
    signal trigger_signal : STD_LOGIC := '0';
    signal measuring : BOOLEAN := FALSE;
    signal current_threshold : STD_LOGIC_VECTOR(7 downto 0) := (others => '0');
    signal measured_distance : INTEGER range 0 to 255 := 0;
begin

    process(clk, rst)
    begin
        if rst = '1' then
            counter <= 0;
            trigger_signal <= '0';
            measuring <= FALSE;
            distance <= (others => '0');
            current_threshold <= (others => '0');
            measured_distance <= 0;
        elsif rising_edge(clk) then
            if write_limit = '1' then
                current_threshold <= threshold;
            end if;

            if counter < 5000000 then
                counter <= counter + 1;
            else
                counter <= 0;
            end if;

            -- Trigger logic
            if counter = 0 then
                trigger_signal <= '1';
            elsif counter = 1000 then -- 10 microseconds
                trigger_signal <= '0';
            end if;

            -- Echo logic
            if echo = '1' and not measuring then
                echo_start <= counter;
                measuring <= TRUE;
            elsif echo = '0' and measuring then
                echo_end <= counter;
                measuring <= FALSE;
                -- Calculate distance (simplified, assuming sound speed ~ 343 m/s)
                measured_distance <= (echo_end - echo_start) / 58;

                -- Validate the measured distance
                if measured_distance < 2 or measured_distance > 255 then
                    distance <= (others => '0'); -- Error value
                else
                    distance <= std_logic_vector(to_unsigned(measured_distance, 8));
                end if;
            end if;

            -- Check if distance is above the threshold
            if unsigned(distance) > unsigned(current_threshold) then
                above_limit <= '1';
            else
                above_limit <= '0';
            end if;
        end if;
    end process;

    trigger <= trigger_signal;

end Behavioral;


