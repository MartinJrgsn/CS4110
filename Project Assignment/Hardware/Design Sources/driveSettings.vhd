library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity driveSettings is
    Port ( clk : in STD_LOGIC;
           state : in STD_LOGIC_vector (2 downto 0);
           out1 : out STD_LOGIC;
           out2 : out STD_LOGIC;
           out3 : out STD_LOGIC;
           out4 : out STD_LOGIC;
           out5 : out STD_LOGIC;
           out6 : out STD_LOGIC;
           out7 : out STD_LOGIC;
           out8 : out STD_LOGIC;
           out9 : out STD_LOGIC;
           out10 : out STD_LOGIC;
           out11 : out STD_LOGIC;
           out12 : out STD_LOGIC);
end driveSettings;

architecture arch of driveSettings is

begin
    process(state)
    begin
        case state is
            when "001" =>
                out1 <= '1';
                out2 <= '1';
                out3 <= '0';
                out4 <= '1';
                out5 <= '1';
                out6 <= '0';
                out7 <= '1';
                out8 <= '1';
                out9 <= '0';
                out10 <= '1';
                out11 <= '1';
                out12 <= '0';

            when "010" =>
                out1 <= '1';
                out2 <= '0';
                out3 <= '1';
                out4 <= '1';
                out5 <= '0';
                out6 <= '1';
                out7 <= '1';
                out8 <= '0';
                out9 <= '1';
                out10 <= '1';
                out11 <= '0';
                out12 <= '1';
            when "011" =>
                out1 <= '1';
                out2 <= '0';
                out3 <= '1';
                out4 <= '1';
                out5 <= '1';
                out6 <= '0';
                out7 <= '1';
                out8 <= '0';
                out9 <= '1';
                out10 <= '1';
                out11 <= '1';
                out12 <= '0';
            when others =>
                out1 <= '0';
                out2 <= '0';
                out3 <= '0';
                out4 <= '0';
                out5 <= '0';
                out6 <= '0';
                out7 <= '0';
                out8 <= '0';
                out9 <= '0';
                out10 <= '0';
                out11 <= '0';
                out12 <= '0'; 
                
        end case;
    end process;
end arch;
