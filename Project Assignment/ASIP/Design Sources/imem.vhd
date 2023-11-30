-- josemmf@usn.no | 2023.10
-- Single-port ROM w/ 8-bit addr bus, 24-bit data bus
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
      x"FF0000",  -- addr 00: S:  LD   R0,255    # 11111111(imm) 000(rs2=  ) 000(rs1=  ) 000(rd=R0) 0000000 = 111111110000000000000000 = FF0000
      x"FD0080",  -- addr 01:     LD   R1,253    # 11111101(imm) 000(rs2=  ) 000(rs1=  ) 001(rd=R1) 0000000 = 111111010000000010000000 = FD0080
      x"AA0100",  -- addr 02:     LD   R2,170    # 10101010(imm) 000(rs2=  ) 000(rs1=  ) 010(rd=R2) 0000000 = 101010100000000100000000 = AA0100
      x"EB0280",  -- addr 03:     LD   R5,251    # 11101011(imm) 000(rs2=  ) 000(rs1=  ) 101(rd=R5) 0000000 = 111010110000001010000000 = EB0280
      x"BB0300",  -- addr 04:     LD   R6,187    # 10111110(imm) 000(rs2=  ) 000(rs1=  ) 110(rd=R6) 0000000 = 101110110000001100000000 = BB0300

      x"000011",  -- addr 05: L:  SCD  R0        # 00000000(imm) 000(rs2=  ) 000(rs1=R0) 000(rd=  ) 0010001 = 000000000000000000010001 = 000011
      x"000392",  -- addr 06:     LDD  R7        # 00000000(imm) 000(rs2=  ) 000(rs1=  ) 111(rd=R7) 0010010 = 000000000000001110010010 = 000392
      x"001C13",  -- addr 07:     SSEG R7        # 00000000(imm) 000(rs2=  ) 111(rs1=R7) 000(rd=  ) 0010011 = 000000000001110000010011 = 001C13

      x"000194",  -- addr 08: LF: LDL  R3        # 00000000(imm) 000(rs2=  ) 000(rs1=  ) 011(rd=R3) 0010100 = 000000000000000110010100 = 000194
      x"000392",  -- addr 09:     LDD  R7        # 00000000(imm) 000(rs2=  ) 000(rs1=  ) 111(rd=R7) 0010010 = 000000000000001110010010 = 000392
      x"001C13",  -- addr 10:     SSEG R7        # 00000000(imm) 000(rs2=  ) 111(rs1=R7) 000(rd=  ) 0010011 = 000000000001110000010011 = 001C13
      x"FD0C0D",  -- addr 11:     JRNZ R3,LF     # 11111101(imm) 000(rs2=  ) 011(rs1=R3) 000(rd=  ) 0001101 = 111111010000110000001101 = FD0C0D

      x"000415",  -- addr 12:     SCNT R1        # 00000000(imm) 000(rs2=  ) 001(rs1=R1) 000(rd=  ) 0010101 = 000000000000010000010101 = 000415
      x"000811",  -- addr 13:     SCD  R2        # 00000000(imm) 000(rs2=  ) 010(rs1=R2) 000(rd=  ) 0010001 = 000000000000100000010001 = 000811
      x"000216",  -- addr 14: LB: LDC  R4        # 00000000(imm) 000(rs2=  ) 000(rs1=  ) 100(rd=Ri) 0010110 = 000000000000001000010110 = 000216
      x"000392",  -- addr 15:     LDD  R7        # 00000000(imm) 000(rs2=  ) 000(rs1=  ) 111(rd=R7) 0010010 = 000000000000001110010010 = 000392
      x"001C13",  -- addr 16:     SSEG R7        # 00000000(imm) 000(rs2=  ) 111(rs1=R7) 000(rd=  ) 0010011 = 000000000001110000010011 = 001C13
      x"FD020D",  -- addr 17:     JRNZ R4 LB     # 11111101(imm) 000(rs2=  ) 000(rs1=  ) 100(rd=R4) 0001101 = 111111010000001000001101 = FD020D

      x"001415",  -- addr 18:     SCNT R5        # 00000000(imm) 000(rs2=  ) 101(rs1=R5) 000(rd=  ) 0010101 = 000000000001010000010101 = 001415
      x"001811",  -- addr 19:     SCD  R6        # 00000000(imm) 000(rs2=  ) 110(rs1=R6) 000(rd=  ) 0010001 = 000000000001100000010001 = 001811

      x"000216",  -- addr 20: LF: LDC  R4        # 00000000(imm) 000(rs2=  ) 000(rs1=  ) 100(rd=Ri) 0010110 = 000000000000001000010110 = 000216
      x"000392",  -- addr 21:     LDD  R7        # 00000000(imm) 000(rs2=  ) 000(rs1=  ) 111(rd=R7) 0010010 = 000000000000001110010010 = 000392
      x"001C13",  -- addr 22:     SSEG R7        # 00000000(imm) 000(rs2=  ) 111(rs1=R7) 000(rd=  ) 0010011 = 000000000001110000010011 = 001C13
      x"FD100D",  -- addr 23:     JRNZ R4 LF     # 11111101(imm) 000(rs2=  ) 100(rs1=R4) 000(rd=  ) 0001101 = 111111010001000000001101 = FD100D

      x"ED000E",  -- addr 24:     J L            # 11101101(imm) 000(rs2=  ) 000(rs1=  ) 000(rd=  ) 0001110 = 111011010000000000001110 = ED000E

	  x"FFFFFF",  -- addr 25: (void)
	  x"FFFFFF",  -- addr 26: (void)
	  x"FFFFFF",  -- addr 27: (void)
	  x"FFFFFF",  -- addr 28: (void)
	  x"FFFFFF",  -- addr 29: (void)
	  x"FFFFFF",  -- addr 30: (void)
	  x"FFFFFF"   -- addr 31: (void)
   );
begin
   im_dout <= instr_opcodes(to_integer(unsigned(im_addr)));
end arch;