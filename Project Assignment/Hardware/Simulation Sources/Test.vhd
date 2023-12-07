----------------------------------------------------------------------------------
-- Engineer: Nikolai Eidheim
--
-- Create Date: 11.2023
-- Module Name: pwm_module - arch
-- Project Name: Hardware only solution
-- Additional Comments:
--  based on a testbench from the napolion cipher, Engineer: Erica Fegri
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity test_tb is
end test_tb;

architecture arch of test_tb is
constant clk_period : time := 10 ns;

Component carController is
    port (
        clk, rst: in STD_LOGIC;
		pwm: in STD_LOGIC; -- echo
        pwm_trigger:  out STD_LOGIC; -- trigger
           out1 : out STD_LOGIC; -- motor controll pins
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
end Component;

signal clk, rst: std_logic;
signal pwm_in, pwm_out: std_logic;

begin
    uut: carController
    Port Map(clk => clk, rst => rst,
              pwm => pwm_in, pwm_trigger => pwm_out);

    clk_process: process -- simulates a clock from the board
            begin
               clk <= '0';
               wait for clk_period/2;
               clk <= '1';
               wait for clk_period/2;
            end process;

     stim: process -- the simulated inputs start to finish
        begin
        pwm_in <= '0';
        rst <= '1';
        wait for clk_period*2;
        rst <= '0';
        wait for clk_period*2;

        wait for 30us;

        pwm_in <= '1';

        wait for 2700us; -- turns echo input on and off for diffrent times to
                         -- check if the logic is able to count and change state based on it
        pwm_in <= '0';

        wait for 30us; -- some delay for the trigger.

        pwm_in <= '1';

        wait for 3200us;
        pwm_in <= '0';

        wait for 30us;

        pwm_in <= '1';

        wait for 3100us;
        pwm_in <= '0';

        wait for 30us;

        pwm_in <= '1';

        wait for 4000us;
        pwm_in <= '0';


        wait for 30us;

        pwm_in <= '1';

        wait for 100us; -- to trigger a reaction to start reversing.
        pwm_in <= '0';

        wait for 1000000ms; -- delay for the backward and turn left.
        end process;
end arch;
