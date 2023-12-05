----------------------------------------------------------------------------------
-- Company: 
-- Engineer: Erica Fegri
-- 
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity template_tb is
   -- Port (); 
end template_tb;

architecture arch of template_tb is
constant clk_period : time := 10 ns;



Component carController is
    port ( 
        clk, rst: in STD_LOGIC;
		pwm: in STD_LOGIC;
        pwm_trigger:  out STD_LOGIC;
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
end Component;

signal clk, rst: std_logic;
signal pwm_in, pwm_out: std_logic;

begin

    uut: carController
    Port Map(clk => clk, rst => rst, 
              pwm => pwm_in, pwm_trigger => pwm_out);
    
    clk_process: process 
            begin
               clk <= '0';
               wait for clk_period/2;
               clk <= '1';
               wait for clk_period/2;
            end process; 
        
     stim: process
        begin
        pwm_in <= '0';
        rst <= '1';
        wait for clk_period*2;
        rst <= '0';
        wait for clk_period*2;
        
        wait for 30us;
        
        pwm_in <= '1';
        
        wait for 2700us;
        pwm_in <= '0';
        
        wait for 30us;
        
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
        
        wait for 100us;
        pwm_in <= '0';

        wait for 1000000ms;
        end process;

end arch;
