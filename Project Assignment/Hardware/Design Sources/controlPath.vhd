library ieee;
use ieee.std_logic_1164.all;
use IEEE.numeric_std.ALL;

entity controlPath is
   port ( clk, rst: in std_logic;
          limit_reached, echo_done, echo_active,  down_done_trigger, 
           down_done_echo, down_done_reverse, down_done_right: in std_logic;
           
          clear_cnt, start_cnt, trigger_ctr, rst_down_cnt_echo, clear_echo_done, 
          start_down_cnt_echo, rst_down_cnt_reverse, start_down_cnt_reverse,
          rst_down_cnt_right, start_down_cnt_right,
          start_down_cnt_trigger, rst_down_cnt_trigger: out std_logic;
          
          cnt_limit: out std_logic_vector(31 downto 0);
          
          current_state: out std_logic_vector(2 downto 0)
	    );
end controlPath;

architecture arch of controlPath is
type state is (S0, S1, S2, S3);
signal st_now, st_next : state; -- current state, next state
signal trigger_is_on, next_state_check_done: std_logic;
signal trigger_is_on_now, dont_check, state_mode, down_done_temp: std_logic;



begin
-- state register 
process (clk, rst)
begin 
   if (rst = '1') then
	  st_now <= S0; -- initial state
   elsif rising_edge(clk) then
	  st_now <= st_next;
   end if;
end process;

process (clk)
begin
        --rst_down_cnt <= '0';
        --clear_cnt <= '0';
        --clear_echo_done <= '0';
   
   case st_now is
      when S0 =>
      start_down_cnt_echo <= '0';
      rst_down_cnt_echo  <= '1'; 

      start_down_cnt_right <= '0';
      rst_down_cnt_right  <= '1'; 

      start_down_cnt_reverse <= '0';
      rst_down_cnt_reverse  <= '1'; 
      
      start_down_cnt_trigger <= '0';
      rst_down_cnt_trigger  <= '1'; 
      
      current_state <= "001";
      state_mode <= '1';
      st_next <= S1; 
      clear_echo_done <= '1';

      when S1 =>
        current_state <= "001";
        if (down_done_echo = '1') then
            st_next <= S2;
        else
            st_next <= S1;
        end if;
 
      when S2 =>
        current_state <= "010";
          start_down_cnt_reverse <= '1';
          rst_down_cnt_reverse  <= '0'; 
        if down_done_reverse = '1' then
            st_next <= S3;
                  start_down_cnt_trigger <= '0';
      rst_down_cnt_trigger  <= '1';   
        else
           st_next <= S2;  
        end if;   
        

 
      when S3 =>
        current_state <= "011";
          start_down_cnt_right <= '1';
          rst_down_cnt_right  <= '0'; 
        if down_done_right = '1' then
            st_next <= S0; 
        else
            
            st_next <= S3; 
                     
        end if;
        
end case;
end process;


end arch;