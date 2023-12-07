----------------------------------------------------------------------------------
-- Engineer: Nikolai Eidheim
--
-- Create Date: 11.2023
-- Module Name: Top file
-- Project Name: Hardware only solution
-- Additional Comments:
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

entity carController is
    generic (
        DATA_WIDTH: integer := 9
        );
    port (
        clk, rst: in STD_LOGIC;
		pwm: in STD_LOGIC; -- echo input (from sensor)
        pwm_trigger:  out STD_LOGIC; -- trigger output (to sensor)
           out1 : out STD_LOGIC; -- 12 outputs sent to the two motor drivers
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
           out12 : out STD_LOGIC;
           led : out STD_LOGIC_VECTOR(11 downto 0); -- leds
           sseg_out: out STD_LOGIC_VECTOR(6 downto 0); -- display value
           an_out : out STD_LOGIC_VECTOR(3 downto 0)); -- display enabler
end carController;

-- signals for connecting the components
architecture arch of carController is
    signal cnt_value, cnt_limit: std_logic_vector(31 downto 0);
    signal current_state: std_logic_vector(2 downto 0);
    signal clear_echo_done, PWM_in, echo_done, echo_active, clear_cnt, start_cnt: std_logic;
    signal limit_reached, PWM_out, down_done_echo, start_down_cnt_echo, rst_down_cnt_echo,
    down_done_reverse, start_down_cnt_reverse, rst_down_cnt_reverse, down_done_trigger, start_down_cnt_trigger, rst_down_cnt_trigger,
    down_done_left, start_down_cnt_left, rst_down_cnt_left: std_logic;
    signal distance: std_logic_vector(DATA_WIDTH-1 downto 0);
    signal load_sseg: std_logic := '1';
    signal sseg_reg_dout: std_logic_vector(DATA_WIDTH-1 downto 0);
    signal fir_result: std_logic_vector(DATA_WIDTH-1 downto 0);
    signal fir_input: std_logic_vector(DATA_WIDTH-1 downto 0);


----------------------------------------------------------------------------------
begin

    pwm_module: entity work.pwm_module(arch)
        port map ( clk=>clk, rst=>rst,
        echo=>pwm, trig=>pwm_trigger, dout=>down_done_echo, distance=>distance );

    fir_filter: entity work.fir_filter(arch)
        port map (  rst=>rst, clk=>clk,
        result=>fir_result, input=>distance );


    down_counter_reverse: entity work.down_counter_reverse(arch)
        port map ( clk=>clk, rst=>rst_down_cnt_reverse, up=>start_down_cnt_reverse, dout=>down_done_reverse );

    down_counter_left: entity work.down_counter_left(arch)
        port map ( clk=>clk, rst=>rst_down_cnt_left, up=>start_down_cnt_left, dout=>down_done_left );


    driveSettings: entity work.driveSettings(arch)
        port map (clk=>clk, state=>current_state, out1=>out1,
        out2=>out2,out3=>out3,out4=>out4,out5=>out5,
        out6=>out6,out7=>out7,out8=>out8,out9=>out9,
        out10=>out10,out11=>out11,out12=>out12, led=>led);

    sseg_reg: entity work.reg(arch)
        port map(clk=>clk,
            rst=>rst,
            reg_ld=>load_sseg,
            reg_d=>fir_result,
            reg_q=>sseg_reg_dout);

    sseg_decoder: entity work.sseg_display_decoder(arch)
        port map(clk=>clk,
            din=>sseg_reg_dout,
            sseg=>sseg_out,
            an=>an_out);

    controlPath: entity work.controlPath(arch)
        port map (clk=>clk, rst=>rst, limit_reached=>limit_reached,
        echo_done=>echo_done, echo_active=>echo_active,
        clear_cnt=>clear_cnt, start_cnt=>start_cnt,
        cnt_limit=>cnt_limit, current_state=>current_state, clear_echo_done => clear_echo_done,
        down_done_echo=>down_done_echo, start_down_cnt_echo=>start_down_cnt_echo, rst_down_cnt_echo=>rst_down_cnt_echo,
    down_done_reverse=>down_done_reverse, start_down_cnt_reverse=>start_down_cnt_reverse, rst_down_cnt_reverse=>rst_down_cnt_reverse,
    down_done_trigger=>down_done_trigger,
    start_down_cnt_trigger=>start_down_cnt_trigger, rst_down_cnt_trigger=>rst_down_cnt_trigger,
    down_done_left=>down_done_left, start_down_cnt_left=>start_down_cnt_left, rst_down_cnt_left=>rst_down_cnt_left);





end arch;