----------------------------------------------------------------------------------
-- Engineer: Martin Jørgensen
--
-- Create Date: 27.11.2023 10:00:43
-- Design Name: pwm_module
-- Module Name: pwm_module - arch
-- Project Name: Hardware only solution
-- Target Devices: Basys 3
-- Description: Module for reading sensor data from HC-SR04
-- Ultrasonic Distance Sensor
--
-- Revision: 0.03
-- Revision 0.03 - Linting and removed signal
-- Revision 0.02 - 38ms period mod n up counter
-- Revision 0.01 - File Created
--
-- Modification: - Change to 9 bit data width
--
----------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

entity pwm_module is
    generic(
        DATA_WIDTH: integer:=9;
        PWM_PERIOD : integer := 3800000 -- 3.8M Cycles = 38 ms at 100MHz
    );
    Port (
        clk : in STD_LOGIC; -- 100MHz clock
        rst : in STD_LOGIC; -- Reset signal
        trig : out STD_LOGIC; -- TRIG pin for HC-SR04
        echo : in STD_LOGIC; -- ECHO pin from HC-SR04
        dout : out STD_LOGIC; -- Distance above limit
        distance : buffer STD_LOGIC_VECTOR(DATA_WIDTH-1 downto 0) -- Distance measured
    );
end pwm_module;

architecture arch of pwm_module is
    signal counter, echo_start, echo_end : INTEGER range 0 to PWM_PERIOD := 0;
    signal trigger_signal : STD_LOGIC := '0';
    signal measuring : BOOLEAN := FALSE;
    signal THRESHOLD : STD_LOGIC_VECTOR(7 downto 0) := std_logic_vector(to_unsigned(12, 8));
    signal measured_distance : INTEGER range 0 to 400 := 0;
begin

    process(clk, rst)
    begin
        if rst = '1' then
            counter <= 0;
            trigger_signal <= '0';
            measuring <= FALSE;
            distance <= (others => '0');
            measured_distance <= 0;
        elsif rising_edge(clk) then


            if counter < PWM_PERIOD then
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
                -- Calculate distance for speed of sound in air ~ 343 m/s)
                measured_distance <= (counter - echo_start) / 5831;
                measuring <= FALSE;

                -- Validate the measured distance
                if measured_distance < 2 or measured_distance > 400 then
                    distance <= (others => '0'); -- Error value
                else
                    distance <= std_logic_vector(to_unsigned(measured_distance, 9));
                end if;
            end if;

            -- Check if distance is above the threshold
            if unsigned(distance) > unsigned(THRESHOLD) then
                dout <= '0';
            else
                dout <= '1';
            end if;
        end if;
    end process;

    trig <= trigger_signal;

end arch;