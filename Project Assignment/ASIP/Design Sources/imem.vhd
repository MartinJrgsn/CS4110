----------------------------------------------------------------------------------
-- Engineer: Martin Jørgensen
--
-- Create Date: 10.2023
-- Created by Jose M. M. Ferreira
-- Design Name: imem
-- Module Name: imem - arch
-- Project Name: car_movement_asip
-- Target Devices: Basys 3
-- Description: Single-port ROM w/ 8-bit addr bus, 24-bit data bus
--
-- Revision: 0.02
-- Revision 0.02 - Modified RISC-V type assembly for operating the car
-- Revision 0.01 - (adapted from) Listing 11.5
--
----------------------------------------------------------------------------------
-- (adapted from) Listing 11.5

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
entity imem is
   generic(
      IMADDR_WIDTH: integer:=5;
      IMDATA_WIDTH: integer:=24
   );
   port(
      im_addr: in std_logic_vector(IMADDR_WIDTH-1 downto 0);
      im_dout: out std_logic_vector(IMDATA_WIDTH-1 downto 0)
    );
end imem;

architecture arch of imem is
   type rom_type is array (0 to 2**IMADDR_WIDTH-1)
        of std_logic_vector(IMDATA_WIDTH-1 downto 0);

   constant instr_opcodes: rom_type:=(
      x"140000",  -- addr 00: S:  LD   R0,20     # 00010100(imm) 000(rs2=  ) 000(rs1=  ) 000(rd=R0) 0000000 = 000101000000000000000000 = 140000
      x"000017",  -- addr 01:     STH  R0        # 00000000(imm) 000(rs2=  ) 000(rs1=  ) 000(rd=R0) 0010111 = 000000000000000000010111 = 000017
      x"FF0000",  -- addr 02:     LD   R0,255    # 11111111(imm) 000(rs2=  ) 000(rs1=  ) 000(rd=R0) 0000000 = 111111110000000000000000 = FF0000
      x"FB0080",  -- addr 03:     LD   R1,251    # 11111011(imm) 000(rs2=  ) 000(rs1=  ) 001(rd=R1) 0000000 = 111110110000000010000000 = FB0080
      x"AA0100",  -- addr 04:     LD   R2,170    # 10101010(imm) 000(rs2=  ) 000(rs1=  ) 010(rd=R2) 0000000 = 101010100000000100000000 = AA0100
      x"FA0280",  -- addr 05:     LD   R5,251    # 11111010(imm) 000(rs2=  ) 000(rs1=  ) 101(rd=R5) 0000000 = 111110100000001010000000 = FA0280
      x"BB0300",  -- addr 06:     LD   R6,187    # 10111011(imm) 000(rs2=  ) 000(rs1=  ) 110(rd=R6) 0000000 = 101110110000001100000000 = BB0300

      x"000011",  -- addr 07: L:  SCD  R0        # 00000000(imm) 000(rs2=  ) 000(rs1=R0) 000(rd=  ) 0010001 = 000000000000000000010001 = 000011
      x"000392",  -- addr 08:     LDD  R7        # 00000000(imm) 000(rs2=  ) 000(rs1=  ) 111(rd=R7) 0010010 = 000000000000001110010010 = 000392
      x"001C13",  -- addr 09:     SSEG R7        # 00000000(imm) 000(rs2=  ) 111(rs1=R7) 000(rd=  ) 0010011 = 000000000001110000010011 = 001C13

      x"000392",  -- addr 11: LF: LDD  R7        # 00000000(imm) 000(rs2=  ) 000(rs1=  ) 111(rd=R7) 0010010 = 000000000000001110010010 = 000392
      x"001C13",  -- addr 12:     SSEG R7        # 00000000(imm) 000(rs2=  ) 111(rs1=R7) 000(rd=  ) 0010011 = 000000000001110000010011 = 001C13
      x"000194",  -- addr 10:     LDL  R3        # 00000000(imm) 000(rs2=  ) 000(rs1=  ) 011(rd=R3) 0010100 = 000000000000000110010100 = 000194
      x"FD0C0C",  -- addr 13:     JRZ R3,LF      # 11111101(imm) 000(rs2=  ) 011(rs1=R3) 000(rd=  ) 0001100 = 111111010000110000001100 = FD0C0C

      x"000415",  -- addr 14:     SCNT R1        # 00000000(imm) 000(rs2=  ) 001(rs1=R1) 000(rd=  ) 0010101 = 000000000000010000010101 = 000415
      x"000811",  -- addr 15:     SCD  R2        # 00000000(imm) 000(rs2=  ) 010(rs1=R2) 000(rd=  ) 0010001 = 000000000000100000010001 = 000811

      x"000392",  -- addr 17: LB: LDD  R7        # 00000000(imm) 000(rs2=  ) 000(rs1=  ) 111(rd=R7) 0010010 = 000000000000001110010010 = 000392
      x"001C13",  -- addr 18:     SSEG R7        # 00000000(imm) 000(rs2=  ) 111(rs1=R7) 000(rd=  ) 0010011 = 000000000001110000010011 = 001C13
      x"000216",  -- addr 16:     LDC  R4        # 00000000(imm) 000(rs2=  ) 000(rs1=  ) 100(rd=R4) 0010110 = 000000000000001000010110 = 000216
      x"FD100D",  -- addr 19:     JRNZ R4,LB     # 11111101(imm) 000(rs2=  ) 100(rs1=R4) 000(rd=  ) 0001101 = 111111010001000000001101 = FD100D

      x"001415",  -- addr 20:     SCNT R5        # 00000000(imm) 000(rs2=  ) 101(rs1=R5) 000(rd=  ) 0010101 = 000000000001010000010101 = 001415
      x"001811",  -- addr 21:     SCD  R6        # 00000000(imm) 000(rs2=  ) 110(rs1=R6) 000(rd=  ) 0010001 = 000000000001100000010001 = 001811

      x"000392",  -- addr 23: LR: LDD  R7        # 00000000(imm) 000(rs2=  ) 000(rs1=  ) 111(rd=R7) 0010010 = 000000000000001110010010 = 000392
      x"001C13",  -- addr 24:     SSEG R7        # 00000000(imm) 000(rs2=  ) 111(rs1=R7) 000(rd=  ) 0010011 = 000000000001110000010011 = 001C13
      x"000216",  -- addr 22:     LDC  R4        # 00000000(imm) 000(rs2=  ) 000(rs1=  ) 100(rd=R4) 0010110 = 000000000000001000010110 = 000216
      x"FD100D",  -- addr 25:     JRNZ R4,LR     # 11111101(imm) 000(rs2=  ) 100(rs1=R4) 000(rd=  ) 0001101 = 111111010001000000001101 = FD100D

      x"ED000E",  -- addr 26:     J L            # 11101101(imm) 000(rs2=  ) 000(rs1=  ) 000(rd=  ) 0001110 = 111011010000000000001110 = ED000E

	  x"FFFFFF",  -- addr 27: (void)
	  x"FFFFFF",  -- addr 28: (void)
	  x"FFFFFF",  -- addr 29: (void)
	  x"FFFFFF",  -- addr 30: (void)
	  x"FFFFFF"   -- addr 31: (void)
   );
begin
   im_dout <= instr_opcodes(to_integer(unsigned(im_addr)));
end arch;