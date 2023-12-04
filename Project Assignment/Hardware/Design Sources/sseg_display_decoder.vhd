----------------------------------------------------------------------------------
-- Engineer: Martin Jørgensen
-- 
-- Create Date: 28.11.2023 11:57:57
-- Design Name: 
-- Module Name: sseg_display_decoder - arch
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Revision: 0.01
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity sseg_display_decoder is
    generic(
      DRDATA_WIDTH: integer:=9;
      SSEG_WIDTH: integer:=7;
      SSEG_AN_WIDTH: integer:=4
   );
    Port (
        clk : in STD_LOGIC;
        din : in STD_LOGIC_VECTOR (DRDATA_WIDTH-1 downto 0);
        sseg : out STD_LOGIC_VECTOR (SSEG_WIDTH-1 downto 0);
        an  : out STD_LOGIC_VECTOR (SSEG_AN_WIDTH-1 downto 0)
    );
end sseg_display_decoder;

architecture arch of sseg_display_decoder is

    -- Function to convert binary to 7-segment display encoding
    function bin_to_7seg(binary : STD_LOGIC_VECTOR(SSEG_AN_WIDTH-1 downto 0)) return STD_LOGIC_VECTOR is
    begin
        case binary is
            when "0000" => return "1000000"; -- '0'
            when "0001" => return "1111001"; -- '1'
            when "0010" => return "0100100"; -- '2'
            when "0011" => return "0110000"; -- '3'
            when "0100" => return "0011001"; -- '4'
            when "0101" => return "0010010"; -- '5'
            when "0110" => return "0000010"; -- '6'
            when "0111" => return "1111000"; -- '7'
            when "1000" => return "0000000"; -- '8'
            when "1001" => return "0010000"; -- '9'
            when others => return "0111111"; -- Dash
        end case;
    end bin_to_7seg;
    -- Signal declarations for counters
    signal refresh_rate_counter : integer range 0 to 1000 := 0;
    signal display_counter : integer range 0 to 2 := 0;

    -- Signal declarations for values
    signal digit0, digit1, digit2 : STD_LOGIC_VECTOR (3 downto 0); -- To hold individual digits
    signal decimal_value : integer range 0 to 400; -- To hold decimal equivalent of bin_value 

begin

    process(clk)
    begin
        if rising_edge(clk) then
            -- Convert 8-bit value to decimal
            decimal_value <= conv_integer(din);

            -- Extract individual digits
            digit0 <= conv_std_logic_vector(decimal_value mod 10, 4);
            digit1 <= conv_std_logic_vector((decimal_value / 10) mod 10, 4);
            digit2 <= conv_std_logic_vector((decimal_value / 100) mod 10, 4);

            -- Refresh rate control
            if refresh_rate_counter < (1000 - 1) then
                refresh_rate_counter <= refresh_rate_counter + 1;
            else
                refresh_rate_counter <= 0;

                if din = "00000000" then
                    -- Display dashes on all four displays
                    sseg <= "0111111"; -- Dash
                    an <= "0000";    -- Activating all displays with dashes
                -- Cycle through the digits
                elsif display_counter = 0 then
                    sseg <= bin_to_7seg(digit0);
                    an <= "1110"; -- Activate first digit
                elsif display_counter = 1 then
                    sseg <= bin_to_7seg(digit1);
                    an <= "1101"; -- Activate second digit
                else
                    sseg <= bin_to_7seg(digit2);
                    an <= "1011"; -- Activate third digit
                end if;

                -- Increment the display counter
                if display_counter < 2 then
                    display_counter <= display_counter + 1;
                else
                    display_counter <= 0;
                end if;
            end if;
        end if;
    end process;
end arch;