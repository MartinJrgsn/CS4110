----------------------------------------------------------------------------------
-- Engineer: Martin J�rgensen
-- 
-- Create Date: 10.2023
-- Created by Jose M. M. Ferreira
-- Design Name: ASIP
-- Module Name: ASIP - arch
-- Project Name: car_movement_asip
-- Target Devices: Basys 3
-- Description: Top module for Application Specific Instruction-Set Processor
-- The ASIP controls a car with four mecanum wheels, four motors, two L298N
-- motor drivers, one Basys 3 board and one HC-SR04 Ultrasonic Distance Sensor.
-- The instructions for driving the car can be changed through RISC-V assembly
-- in the imem.vhd file.
-- 
-- Revision: 0.02 - Modified ports, signals, components, and muxes
-- Revision 0.01 - Listing 6.3 modified
-- 
----------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ASIP is
   generic(
      PCDATA_WIDTH: integer:=8;
      IMADDR_WIDTH: integer:=5;
      IMDATA_WIDTH: integer:=24;
      DRADDR_WIDTH: integer:=3;
      DRDATA_WIDTH: integer:=8;
      DMADDR_WIDTH: integer:=8;
      DMDATA_WIDTH: integer:=8;
      OPCODE_WIDTH: integer:=7;
      SSEG_AN_WIDTH: integer:=4;
      SSEG_WIDTH: integer:=7
   );
   port(clk, rst: in std_logic;
   echo: in std_logic; --
   trig: out std_logic; --
   sw: in std_logic_vector(DRDATA_WIDTH-1 downto 0); -- 
   btnC: in std_logic; --
   ENB_1, IN3_1, IN4_1: out std_logic;     -- ENB_1, IN3_1, IN4_1
   ENA_2, IN1_2, IN2_2: out std_logic;     -- ENA_2, IN1_1, IN2_1
   ENA_1, IN1_1, IN2_1: out std_logic;     -- ENA_1, IN1_1, IN2_1
   ENB_2, IN3_2, IN4_2: out std_logic;  -- ENB_2, IN3_2, IN4_2
   led: out std_logic_vector(11 downto 0);
   sseg_out: out std_logic_vector(SSEG_WIDTH-1 downto 0); --
   an_out: out std_logic_vector(SSEG_AN_WIDTH-1 downto 0)); --

end ASIP;

architecture arch of ASIP is
    signal btn_wr: std_logic;
    signal btn_mux_ctr: std_logic;
    --signal clr: std_logic; -- maybe not needed
    signal write_limit: std_logic;
    signal above_limit: std_logic_vector(DRDATA_WIDTH-1 downto 0);
    signal dl_mux_ctr: std_logic;
    signal pc_mux_ctr: std_logic;
    signal dreg_mux_ctr: std_logic;
    signal dr_wr_ctr: std_logic; -- dreg_write
    signal cnt_mux_ctr: std_logic;
    signal alu_mux_ctr: std_logic;
    signal dc_load: std_logic;
    signal count_done: std_logic_vector(DRDATA_WIDTH-1 downto 0);
    signal alu_ctr: std_logic_vector(OPCODE_WIDTH-1 downto 0);
    signal alu_zero: std_logic;
    signal alu_dmem_mux_ctr: std_logic;
    signal dm_wr_ctr: std_logic; -- dmem_write
    signal sseg_wr: std_logic;
    signal m_dir_wr: std_logic;
    signal pc_mux_out, pc_out: std_logic_vector(PCDATA_WIDTH-1 downto 0);
    signal opcd_out: std_logic_vector(IMDATA_WIDTH-1 downto 0);
    signal dr1_dout, dr2_dout: std_logic_vector(DRDATA_WIDTH-1 downto 0);
    signal alu_mux_out: std_logic_vector(DRDATA_WIDTH-1 downto 0);
    signal alu_dout: std_logic_vector(DRDATA_WIDTH-1 downto 0);
    signal dm_dout: std_logic_vector(DMDATA_WIDTH-1 downto 0);
    signal dreg_mux_out: std_logic_vector(DMDATA_WIDTH-1 downto 0);
    signal th_mux_out: std_logic_vector(DRDATA_WIDTH-1 downto 0);
    signal dl_mux_out: std_logic_vector(DRDATA_WIDTH-1 downto 0);
    signal cnt_mux_out: std_logic_vector(DRDATA_WIDTH-1 downto 0);
    signal alu_dmem_mux_out: std_logic_vector(DRDATA_WIDTH-1 downto 0);
    signal distance: std_logic_vector(DRDATA_WIDTH-1 downto 0);
    signal sseg_dd_out: std_logic_vector(DRDATA_WIDTH-1 downto 0);
    signal m_dir_reg_out: std_logic_vector(DRDATA_WIDTH-1 downto 0); --


begin

    -- instantiate program counter
    pc: entity work.pc(arch)
    port map(clk=>clk, 
             rst=>rst, 
             reg_d=>pc_mux_out, -- data in
             reg_q=>pc_out);    -- data out

    -- instantiate instruction memory
    imem: entity work.imem(arch)
    port map(im_addr=>pc_out(4 downto 0), 
             im_dout=>opcd_out);

	-- instantiate data registers
    dreg: entity work.dreg(arch)
    port map(clk=>clk, 
             dr_wr_ctr=>dr_wr_ctr, 
             dwr_addr=>opcd_out(9 downto 7),
             dr1_addr=>opcd_out(12 downto 10),
             dr2_addr=>opcd_out(15 downto 13),
		     dwr_din=>dreg_mux_out, 
		     dr1_dout=>dr1_dout, 
		     dr2_dout=>dr2_dout);

	-- instantiate ALU
    alu: entity work.alu(arch)
    port map(alu_din_hi=>dr1_dout,
             alu_din_lo=>alu_mux_out,
		     alu_ctr_in=>alu_ctr,
		     alu_dout=>alu_dout,
		     alu_zero=>alu_zero);

	-- instantiate data memory
    dmem: entity work.dmem(arch)
    port map(clk=>clk, 
             dm_wr_ctr=>dm_wr_ctr,
		     dm_addr=>alu_dout,
		     dm_din=>dr2_dout,
		     dm_dout=>dm_dout);

	-- instantiate FSM control path
    control: entity work.control(arch)
    port map(clk=>clk,
             rst=>rst,
             btn_wr=>btnC,
             --above_limit=>above_limit,
             alu_zero=>alu_zero,
             opcode=>opcd_out(OPCODE_WIDTH-1 downto 0),
             btn_mux_ctr=>btn_mux_ctr,
		     dl_mux_ctr=>dl_mux_ctr,
		     pc_mux_ctr=>pc_mux_ctr,
		     dreg_mux_ctr=>dreg_mux_ctr,
		     cnt_mux_ctr=>cnt_mux_ctr,
		     alu_mux_ctr=>alu_mux_ctr,
		     alu_dmem_mux_ctr=>alu_dmem_mux_ctr,
		     write_limit=>write_limit,
		     dr_wr_ctr=>dr_wr_ctr,
		     dc_load=>dc_load,
		     dm_wr_ctr=>dm_wr_ctr,
		     sseg_wr=>sseg_wr,
		     m_dir_wr=>m_dir_wr,
		     alu_ctr=>alu_ctr);

    -- instantiate output
    sseg_reg: entity work.reg(arch)
    port map(clk=>clk,
             rst=>rst,
             reg_ld=>sseg_wr,
             reg_d=>alu_dout,
             reg_q=>sseg_dd_out);

    sseg_decoder: entity work.sseg_display_decoder(arch)
    port map(clk=>clk,
             din=>sseg_dd_out,
             sseg=>sseg_out,
             an=>an_out);

    motor_dir_reg: entity work.reg(arch)
    port map(clk=>clk,
             rst=>rst,
             reg_ld=>m_dir_wr,
             reg_d=>alu_dout,
             reg_q=>m_dir_reg_out);
             
    pwm_module: entity work.pwm_module(arch)
    port map(clk=>clk,
             rst=>rst,
             trigger=>trig,
             echo=>echo,
             threshold=>th_mux_out,
             above_limit=>above_limit,
             distance=>distance,
             write_limit=>write_limit);
             
    timer_module: entity work.timer_module(arch)
    port map(clk=>clk,
             rst=>rst,
             dc_load=>dc_load,
             dr1_din=>dr1_dout,
             count_done=>count_done);

    -- Glue logic at top level: th_mux
    th_mux_out <= sw when btn_mux_ctr='1' else dr2_dout;    
    
    -- Glue logic at top level: dl_mux
    dl_mux_out <= distance when dl_mux_ctr='1' else above_limit;

	-- Glue logic at top level: pc_mux
	pc_mux_out <= std_logic_vector(unsigned(pc_out) + 1) when pc_mux_ctr='1' else
	         std_logic_vector(unsigned(pc_out) + unsigned(opcd_out(23 downto 16))) when opcd_out(23)='0' else
             std_logic_vector(unsigned(pc_out) - not(unsigned(opcd_out(23 downto 16))-1));

	-- Glue logic at top level: dreg_mux
	dreg_mux_out <= dl_mux_out when dreg_mux_ctr='1' else cnt_mux_out;

	-- Glue logic at top level: cnt_mux
	cnt_mux_out <= count_done when cnt_mux_ctr='1' else alu_dmem_mux_out;

	-- Glue logic at top level: alu_mux
	alu_mux_out <= opcd_out(23 downto 16) when alu_mux_ctr='1' else dr2_dout;

	-- Glue logic at top level: alu_dmem_mux
	alu_dmem_mux_out <= alu_dout when alu_dmem_mux_ctr='1' else dm_dout;
	
	-- Output logic for Motor Directions:
	-----------------------------------------------|
	ENB_1   <=      m_dir_reg_out(7);   -- ENB_1    | Left  F1  B1 --out1
	IN3_1   <=      m_dir_reg_out(6);   -- IN3_1    | Front F1  B0 --out2
	IN4_1   <= not( m_dir_reg_out(6));  -- IN4_1    | Motor F0  B1 --out3
	-----------------------------------------------|
	ENA_2   <=      m_dir_reg_out(5);   -- ENA_2    | Right F1  B1 --out4
	IN1_2   <=      m_dir_reg_out(4);   -- IN1_2    | Front F1  B0 --out5
	IN2_2   <= not( m_dir_reg_out(4));  -- IN2_2    | Motor F0  B1 --out6
	-----------------------------------------------|
	ENA_1   <=      m_dir_reg_out(3);   -- ENA_1    | Left  F1  B1 --out7
	IN1_1   <=      m_dir_reg_out(2);   -- IN1_1    | Rear  F1  B0 --out8
	IN2_1   <= not( m_dir_reg_out(2));  -- IN2_1    | Motor F0  B1 --out9
	-----------------------------------------------|
	ENB_2  <=      m_dir_reg_out(1);   -- ENB_2    | Right F1  B1  --out10
	IN3_2  <=      m_dir_reg_out(0);   -- IN3_2    | Rear  F1  B0  --out11
	IN4_2  <= not( m_dir_reg_out(0));  -- IN4_2    | Motor F0  B1  --out12
	-----------------------------------------------|
	-- Output logic for Motor Directions:
	-----------------------------------------------|
	led(11)   <=      m_dir_reg_out(7);   -- ENB_1    | Left  F1  B1
	led(10)   <=      m_dir_reg_out(6);   -- IN3_1    | Front F1  B0
	led(9)   <= not( m_dir_reg_out(6));  -- IN4_1    | Motor F0  B1
	-----------------------------------------------|
	led(8)   <=      m_dir_reg_out(5);   -- ENA_2    | Right F1  B1
	led(7)   <=      m_dir_reg_out(4);   -- IN1_2    | Front F1  B0
	led(6)   <= not( m_dir_reg_out(4));  -- IN2_2    | Motor F0  B1
	-----------------------------------------------|
	led(5)   <=      m_dir_reg_out(3);   -- ENA_1    | Left  F1  B1
	led(4)   <=      m_dir_reg_out(2);   -- IN1_1    | Rear  F1  B0
	led(3)   <= not( m_dir_reg_out(2));  -- IN2_1    | Motor F0  B1
	-----------------------------------------------|
	led(2)  <=      m_dir_reg_out(1);   -- ENB_2    | Right F1  B1
	led(1)  <=      m_dir_reg_out(0);   -- IN3_2    | Rear  F1  B0
	led(0)  <= not( m_dir_reg_out(0));  -- IN4_2    | Motor F0  B1
	-----------------------------------------------|
end arch;