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
      DRDATA_WIDTH: integer:=8;
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

begin

    process(clk)
    begin
        if rising_edge(clk) then
            if din = "00000000" then
                -- Display dashes on all four displays
                sseg <= "0111111"; -- Dash
                an <= "1110";    -- Activating only the first display for simplicity
            else
                -- Display the corresponding value
                -- You need to split 'din' into four 2-bit groups and convert each to 7-segment code
                -- For simplicity, let's just display the least significant digit
                sseg <= bin_to_7seg(din(3 downto 0));
                an <= "1110"; -- Activate the first display
            end if;
        end if;
    end process;

end arch;