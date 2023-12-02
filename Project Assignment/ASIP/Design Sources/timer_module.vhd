----------------------------------------------------------------------------------
-- Engineer: Martin Jørgensen
-- 
-- Create Date: 24.11.2023 10:20:01
-- Design Name: Timer
-- Module Name: timer_module - arch
-- Project Name: car_movement_asip
-- Target Devices: Basys 3
-- Description: Timer loaded with 8-bit value that signals when it has completed.
-- The 8-bit value is separated into the five leftmost and the three rightmost bits
-- to calculate a percentage of seconds.
-- 11111111 = ((11111*111)/11111) * 100M = (31*7)/31 * 100M = 7,00 * 100M cycles
-- 01111101 = ((01111*101)/11111) * 100M = (15*5)/31 * 100M = 2,42 * 100M cycles
-- The basys 3 board runs at 100MHz, which means that 700M cycles equals 7 seconds,
-- and 242M cycles equals 2,42 seconds.
-- 
-- Revision: 0.02
-- Revision 0.02 - Changed to timer_module.
-- Revision 0.01 - File Created
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity timer_module is
    generic(N: integer := 8);  -- 8-bit vector for input
    port(
        clk, rst: in std_logic;
        dc_load: in std_logic;
        dr1_din: in std_logic_vector(N-1 downto 0);  -- 8-bit input vector
        count_done: out std_logic_vector(N-1 downto 0)
    );
end timer_module;

architecture arch of timer_module is
    -- Constants
    constant clock_rate: natural := 100000000;  -- 100 MHz clock
    constant max_percentage: natural := 31;     -- Maximum percentage value (5-bit max)

    -- Signals
    signal r_reg, r_next: unsigned(29 downto 0);  -- Timer count (30-bit for up to 1,073,741,823)
    signal percentage: unsigned(4 downto 0);     -- 5-bit percentage
    signal seconds: unsigned(2 downto 0);        -- 3-bit seconds
    signal dc_en: std_logic;                     -- Internal enable signal
    signal just_loaded: std_logic := '0';        -- Signal to track the load event
    signal count_done_internal: std_logic := '0';

begin
    -- Counter enable logic
    dc_en <= not(count_done_internal) or just_loaded;

    -- register
    process(clk, rst)
    begin
        if rst = '1' then
            r_reg <= (others => '0');  -- Reset to 0
            just_loaded <= '0';
        elsif rising_edge(clk) then
            if dc_load = '1' then
                -- Extract percentage and seconds from input
                percentage <= unsigned(dr1_din(7 downto 3));
                seconds <= unsigned(dr1_din(2 downto 0));

                -- Directly update r_reg with the calculated timer value
                r_reg <= unsigned(to_unsigned(to_integer(percentage * unsigned(to_unsigned(to_integer(seconds), percentage'length)) * clock_rate), r_reg'length) / max_percentage);
                just_loaded <= '1';  -- Set just_loaded when dr1_din is loaded
            else
                if dc_en = '1' and r_reg /= 0 then
                    r_next <= r_reg - 1;
                else
                    r_next <= r_reg;
                end if;
                just_loaded <= '0';  -- Reset just_loaded on the next clock cycle
                r_reg <= r_next;
            end if;
        end if;
    end process;

    -- count completion signal
    count_done_internal <= '1' when r_reg = 0 else '0';
    count_done <= (others => '1') when r_reg = 0 else (others => '0');

end arch;