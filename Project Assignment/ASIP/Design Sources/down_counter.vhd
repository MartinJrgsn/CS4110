----------------------------------------------------------------------------------
-- Engineer: Martin J�rgensen
-- 
-- Create Date: 24.11.2023 10:20:01
-- Design Name: Timer
-- Module Name: down_counter - arch
-- Project Name: car_movement_asip
-- Target Devices: Basys 3
-- Description: Down counter loaded with 23-bit value that signals when it has completed
-- 
-- Revision:
-- Revision 0.01 - File Created
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity down_counter is
    generic(N: integer := 23);  -- Set N to 23 for 23-bit vector
    port(
        clk, rst: in std_logic;
        dc_load: in std_logic;
        dr1_din: in std_logic_vector(N-1 downto 0);  -- 23-bit input vector
        count_done: buffer std_logic  -- Changed 'out' to 'buffer'
    );
end down_counter;

architecture arch of down_counter is
    signal r_reg: unsigned(N-1 downto 0);
    signal r_next: unsigned(N-1 downto 0);
    signal dc_en: std_logic;  -- Internal enable signal
    signal just_loaded: std_logic := '0';  -- Signal to track the load event

begin
    -- Counter enable logic
    dc_en <= not(count_done) or just_loaded;

    -- register
    process(clk, rst)
    begin
        if rst = '1' then
            r_reg <= (others => '0');  -- Reset to 0 or another suitable value
            just_loaded <= '0';
        elsif rising_edge(clk) then
            if dc_load = '1' then
                just_loaded <= '1';  -- Set just_loaded when dr1_din is loaded
            else
                just_loaded <= '0';  -- Reset just_loaded on the next clock cycle
            end if;
            r_reg <= r_next;
        end if;
    end process;

    -- next-state logic
    r_next <= 
        r_reg - 1 when dc_en = '1' and r_reg /= 0 else
        unsigned(dr1_din) when dc_load = '1' else  -- Load the value from dr1_din
        r_reg;

    -- count completion signal
    count_done <= '1' when r_reg = 0 else '0';

end arch;