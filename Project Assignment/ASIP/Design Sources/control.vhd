----------------------------------------------------------------------------------
-- Engineer: Martin Jørgensen
--
-- Create Date: 10.2023
-- Created by Jose M. M. Ferreira
-- Design Name: Control
-- Module Name: control - arch
-- Project Name: car_movement_asip
-- Target Devices: Basys 3
-- Description: Instruction and execution control
--
-- Revision: 0.03
-- Revision 0.03 - Add OPCODE for setting distance threshold
-- Revision 0.02 - Modified OPCODES and output logic
-- Revision 0.01 - File Created
--
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity control is
   generic(
      OPCODE_WIDTH: integer:=7
   );
   port(
      clk: in std_logic;
      rst: in std_logic;
      btn_wr: in std_logic;
      --above_limit: in std_logic;
      --count_done: in std_logic;
      alu_zero: in std_logic;
      opcode: in std_logic_vector(OPCODE_WIDTH-1 downto 0);
      btn_mux_ctr: out std_logic;
      dl_mux_ctr: out std_logic;
      pc_mux_ctr: out std_logic;
      dreg_mux_ctr: out std_logic;
      cnt_mux_ctr: out std_logic;
      alu_mux_ctr: out std_logic;
      alu_dmem_mux_ctr: out std_logic;
      write_limit: out std_logic;
      dr_wr_ctr: out std_logic;
      dc_load: out std_logic;
      dm_wr_ctr: out std_logic;
      sseg_wr: out std_logic;
      m_dir_wr: out std_logic;
      alu_ctr: out std_logic_vector(OPCODE_WIDTH-1 downto 0)
   );
end control;

architecture arch of control is
-- constant declaration for instruction opcodes:
   constant LD_Ri_imm:     std_logic_vector(OPCODE_WIDTH-1 downto 0) :="0000000";

--   constant LD_Ri_Rj:      std_logic_vector(OPCODE_WIDTH-1 downto 0) :="0000001";
--   constant LD_Ri_X_Rj:    std_logic_vector(OPCODE_WIDTH-1 downto 0) :="0000010";
--   constant ST_Ri_X_Rj:    std_logic_vector(OPCODE_WIDTH-1 downto 0) :="0000011";
--   constant DEC_Ri:        std_logic_vector(OPCODE_WIDTH-1 downto 0) :="0000100";
--   constant INC_Ri:        std_logic_vector(OPCODE_WIDTH-1 downto 0) :="0000101";
--   constant ADD_Ri_Rj_Rk:  std_logic_vector(OPCODE_WIDTH-1 downto 0) :="0000110";
--   constant SUB_Ri_Rj_Rk:  std_logic_vector(OPCODE_WIDTH-1 downto 0) :="0000111";
--   constant ORR_Ri_Rj_Rk:  std_logic_vector(OPCODE_WIDTH-1 downto 0) :="0001000";
--   constant ORI_Ri_Rj_imm: std_logic_vector(OPCODE_WIDTH-1 downto 0) :="0001001";
--   constant ANR_Ri_Rj_Rk:  std_logic_vector(OPCODE_WIDTH-1 downto 0) :="0001010";
--   constant ANI_Ri_Rj_imm: std_logic_vector(OPCODE_WIDTH-1 downto 0) :="0001011";
   constant JRZ_Ri_imm:    std_logic_vector(OPCODE_WIDTH-1 downto 0) :="0001100";
   constant JRNZ_Ri_imm:   std_logic_vector(OPCODE_WIDTH-1 downto 0) :="0001101";
   constant J_imm:         std_logic_vector(OPCODE_WIDTH-1 downto 0) :="0001110";

--   constant LD_Ri_IN:      std_logic_vector(OPCODE_WIDTH-1 downto 0) :="0001111";
--   constant ST_Ri_OUT:     std_logic_vector(OPCODE_WIDTH-1 downto 0) :="0010000";

-- NEW OPCODES BELOW:
   constant SCD_Ri:        std_logic_vector(OPCODE_WIDTH-1 downto 0) :="0010001";
   constant LDD_Ri:        std_logic_vector(OPCODE_WIDTH-1 downto 0) :="0010010";
   constant SSEG_Ri:       std_logic_vector(OPCODE_WIDTH-1 downto 0) :="0010011";
   constant LDL_Ri:        std_logic_vector(OPCODE_WIDTH-1 downto 0) :="0010100";
   constant SCNT_Ri:       std_logic_vector(OPCODE_WIDTH-1 downto 0) :="0010101";
   constant LDC_Ri:        std_logic_vector(OPCODE_WIDTH-1 downto 0) :="0010110";
   constant STH_Ri:        std_logic_vector(OPCODE_WIDTH-1 downto 0) :="0010111";

   type state_type is (s0);
   signal st_reg, st_next: state_type;

begin
   -- state register
   process(clk,rst)
   begin
      if (rst='1') then
         st_reg <= s0;
      elsif rising_edge(clk) then
         st_reg <= st_next;
      end if;
   end process;

   -- next-state/output logic
   process(opcode, alu_zero)
   begin
      st_next <= st_reg;  -- default back to same state

      -- Default output logic
      btn_mux_ctr <= btn_wr;
      write_limit <= btn_wr;
      pc_mux_ctr <= '0';
      dl_mux_ctr <= '0';
	  dreg_mux_ctr <= '0';
	  dr_wr_ctr <= '0';
      cnt_mux_ctr <= '0';
      dc_load <= '0';
      alu_mux_ctr <= '0';
      alu_ctr <= opcode;
      alu_dmem_mux_ctr <= '0';
      dm_wr_ctr <= '0';
      sseg_wr <= '0';
      m_dir_wr <= '0';

      -- State descriptions for opcodes
      case st_reg is
         when s0 =>
            if opcode=LD_Ri_imm then -- LD Ri,<imm> (load Ri with an immediate value)
                pc_mux_ctr <= '1';
	            dr_wr_ctr <= '1';
                alu_mux_ctr <= '1';
	            alu_dmem_mux_ctr <= '1';

--	         elsif opcode=LD_Ri_Rj then -- LD Ri,Rj (copy the value of Rj into Ri)
--                pc_mux_ctr <= '1';
--	            dr_wr_ctr <= '1';
--	            alu_dmem_mux_ctr <= '1';
--	         elsif opcode=LD_Ri_X_Rj then -- LD Ri,X(Rj) (load Ri from data memory)
--                pc_mux_ctr <= '1';
--	            dr_wr_ctr <= '1';
--                alu_mux_ctr <= '1';
--	         elsif opcode=ST_Ri_X_Rj then -- ST Ri,X(Rj) (store Ri into data memory)
--                pc_mux_ctr <= '1';
--                alu_mux_ctr <= '1';
--	            dm_wr_ctr <= '1';
--	         elsif opcode=DEC_Ri then -- DEC Ri (decrement Ri)
--                pc_mux_ctr <= '1';
--	            dr_wr_ctr <= '1';
--	            alu_dmem_mux_ctr <= '1';
--	         elsif opcode=INC_Ri then -- INC Ri (increment Ri)
--                pc_mux_ctr <= '1';
--	            dr_wr_ctr <= '1';
--	            alu_dmem_mux_ctr <= '1';
--	         elsif opcode=ADD_Ri_Rj_Rk then -- ADD Ri,Rj,Rk (Ri = Rj + Rk))
--                pc_mux_ctr <= '1';
--	            dr_wr_ctr <= '1';
--	            alu_dmem_mux_ctr <= '1';
--	         elsif opcode=SUB_Ri_Rj_Rk then -- SUB Ri,Rj,Rk (Ri = Rj - Rk))
--                pc_mux_ctr <= '1';
--	            dr_wr_ctr <= '1';
--	            alu_dmem_mux_ctr <= '1';
--	         elsif opcode=ORR_Ri_Rj_Rk then -- ORR Ri,Rj,Rk (Ri = Rj OR Rk)
--                pc_mux_ctr <= '1';
--	            dr_wr_ctr <= '1';
-- 	            alu_dmem_mux_ctr <= '1';
--	         elsif opcode=ORI_Ri_Rj_imm then -- ORI Ri,Rj,<imm> (Ri = Rj OR <imm>)
--                pc_mux_ctr <= '1';
--	            dr_wr_ctr <= '1';
--                alu_mux_ctr <= '1';
--	            alu_dmem_mux_ctr <= '1';
--	         elsif opcode=ANR_Ri_Rj_Rk then -- ANR Ri,Rj,Rk (Ri = Rj AND Rk)
--                -- pc_mux_ctr <= '1';
--	            -- dr_wr_ctr <= '1';
--	            -- alu_dmem_mux_ctr <= '1';
--	         elsif opcode=ANI_Ri_Rj_imm then -- ANI Ri,Rj,<imm> (Ri = Rj AND <imm>)
--                -- pc_mux_ctr <= '1';
--	            -- dr_wr_ctr <= '1';
--                -- alu_mux_ctr <= '1';
--	            -- alu_dmem_mux_ctr <= '1';
	         elsif opcode=JRZ_Ri_imm then -- JRZ Ri,<imm> (jump if Ri is zero)
                 pc_mux_ctr <= alu_zero;

	         elsif opcode=JRNZ_Ri_imm then -- JRNZ Ri,<imm> (jump if Ri is not zero)
                pc_mux_ctr <= not(alu_zero);
             elsif opcode=J_imm then -- J <imm> (unconditional jump)

                -- no signals to activate in this case
--             elsif opcode=LD_Ri_IN then -- LD Ri,IN (load Ri from digital inputs)
--                -- pc_mux_ctr <= '1';
--	            -- dr_wr_ctr <= '1';
--	            -- in_mux_ctr <= '1';
--	         elsif opcode=ST_Ri_OUT then -- ST Ri,OUT (store Ri into digital outputs)
--                -- pc_mux_ctr <= '1';
--	            -- out_reg_write <= '1';

	         elsif opcode=SCD_Ri then -- SCD Ri (store Ri into motor control register)
                pc_mux_ctr <='1';
                m_dir_wr <='1';
	         elsif opcode=LDD_Ri then -- ST Ri,OUT (store Ri into digital outputs)
                pc_mux_ctr <='1';
                dl_mux_ctr <='1';
                dreg_mux_ctr <='1';
                dr_wr_ctr <='1';
	         elsif opcode=SSEG_Ri then -- ST Ri,OUT (store Ri into digital outputs)
                pc_mux_ctr <='1';
                sseg_wr <='1';
	         elsif opcode=LDL_Ri then -- ST Ri,OUT (store Ri into digital outputs)
                pc_mux_ctr <='1';
                dreg_mux_ctr <='1';
                dr_wr_ctr <='1';
	         elsif opcode=SCNT_Ri then -- ST Ri,OUT (store Ri into digital outputs)
                pc_mux_ctr <= '1';
                dc_load <='1';
	         elsif opcode=LDC_Ri then -- ST Ri,OUT (store Ri into digital outputs)
                pc_mux_ctr <='1';
                dr_wr_ctr <='1';
                cnt_mux_ctr <='1';
             elsif opcode=STH_Ri then -- STH Ri (Set Ri as distance threshold for pwm_module)
                pc_mux_ctr <='1';
                write_limit <= '1';
	         end if;
      end case;

   end process;

end arch;