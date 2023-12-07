----------------------------------------------------------------------------------
-- Engineer: Nikolai Eidheim
--
-- Create Date: 11.2023
-- Module Name: fir filter
-- Project Name: Hardware only solution
-- Additional Comments:
--
----------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity fir_filter is
    Port (
        clk : in STD_LOGIC;
        rst : in STD_LOGIC;
        new_distance_value : in STD_LOGIC;
        input : in STD_LOGIC_VECTOR(8 downto 0);
        result : out STD_LOGIC_VECTOR(8 downto 0)

    );
end fir_filter;

architecture arch of fir_filter is
    -- array to store previous values
    type sample_array is array (0 to 26) of integer;
    signal sample : sample_array := (others => 0);
    -- temporary value for previous input and current sum;
    signal sum : integer := 0;
    signal prev_input : STD_LOGIC_VECTOR(8 downto 0) := (others => '0');
begin

    process(input, rst, clk)
    begin
        if rst = '1' then -- resets component
            sample <= (others => 0);
            sum <= 0;
        elsif new_distance_value = '1' AND rising_edge(clk) then

            -- a shift register that holds the 26 last input values
            -- (only saves values when they are diffrent than the last)
            sample(25) <= sample(24);
            sample(24) <= sample(23);
            sample(23) <= sample(22);
            sample(22) <= sample(21);
            sample(21) <= sample(20);
            sample(20) <= sample(19);
            sample(19) <= sample(18);
            sample(18) <= sample(17);
            sample(17) <= sample(16);
            sample(16) <= sample(15);
            sample(15) <= sample(14);
            sample(14) <= sample(13);
            sample(13) <= sample(12);
            sample(12) <= sample(11);
            sample(11) <= sample(10);
            sample(10) <= sample(9);
            sample(9) <= sample(8);
            sample(8) <= sample(7);
            sample(7) <= sample(6);
            sample(6) <= sample(5);
            sample(5) <= sample(4);
            sample(4) <= sample(3);
            sample(3) <= sample(2);
            sample(2) <= sample(1);
            sample(1) <= sample(0);
            sample(0) <= to_integer(unsigned(input));
            end if;

            if rising_edge(clk) then -- store current input
            prev_input <= input;

            -- sum all values
            sum <= sample(0) + sample(1) + sample(2) +
                   sample(3) + sample(4) + sample(5) +
                   sample(6) + sample(7) + sample(8) +
                   sample(9) + sample(10) + sample(11) + sample(12) +
                   sample(13) + sample(14) + sample(15) +
                   sample(16) + sample(17) + sample(18) +
                   sample(19) + sample(20) + sample(21) + sample(22) +
                   sample(23) + sample(24) + sample(25);

            -- calculates result by dividing and thus finding the average.
            result <= std_logic_vector(to_unsigned(sum / 26, 9));
            end if;
    end process;
end arch;
