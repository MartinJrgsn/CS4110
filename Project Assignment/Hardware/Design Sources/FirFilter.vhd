library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity fir_filter is
    Port (
        clk : in STD_LOGIC;
        rst : in STD_LOGIC;
        input : in STD_LOGIC_VECTOR(8 downto 0);  -- Assuming 16-bit input
        result : out STD_LOGIC_VECTOR(8 downto 0) -- 16-bit output
    );
end fir_filter;

architecture arch of fir_filter is
    -- Internal signals for storing past samples
    type sample_array is array (0 to 26) of integer;
    signal sample : sample_array := (others => 0);
    --signal prev_input : STD_LOGIC_VECTOR(8 downto 0);
    signal sum : integer := 0;
    signal prev_input : STD_LOGIC_VECTOR(8 downto 0) := (others => '0');
begin

    process(input, rst, clk)
    begin
        if rst = '1' then
            -- Reset logic
            sample <= (others => 0);
            sum <= 0;
        elsif input /= prev_input AND rising_edge(clk)  then
            -- Shift register logic
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
            
            if rising_edge(clk) then
            prev_input <= input;
            
            -- Summation logic
            sum <= sample(0) + sample(1) + sample(2) + 
                   sample(3) + sample(4) + sample(5) + 
                   sample(6) + sample(7) + sample(8) + 
                   sample(9) + sample(10) + sample(11) + sample(12) + 
                   sample(13) + sample(14) + sample(15) + 
                   sample(16) + sample(17) + sample(18) + 
                   sample(19) + sample(20) + sample(21) + sample(22) + 
                   sample(23) + sample(24) + sample(25);
            
            -- Calculate average (be aware of potential truncation error)
            result <= std_logic_vector(to_unsigned(sum / 26, 9));
            
            end if;
    end process;

end arch;
