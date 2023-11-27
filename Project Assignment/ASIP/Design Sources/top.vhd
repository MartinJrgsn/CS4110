-- josemmf@usn.no | 2023.10
-- Listing 6.3 modified

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity OneCycleCPUwithIO is
   generic(
      PCDATA_WIDTH: integer:=8;
      IMADDR_WIDTH: integer:=5;
      IMDATA_WIDTH: integer:=24;
      DRADDR_WIDTH: integer:=3;
      DRDATA_WIDTH: integer:=8;
      DMADDR_WIDTH: integer:=8;
      DMDATA_WIDTH: integer:=8;
      OPCODE_WIDTH: integer:=7      
   );
   port(clk, rst: in std_logic;
   dig_in: in std_logic_vector(DRDATA_WIDTH-1 downto 0);
   dig_out: out std_logic_vector(DRDATA_WIDTH-1 downto 0));
end OneCycleCPUwithIO;

architecture arch of OneCycleCPUwithIO is
   signal dr_wr_ctr, dm_wr_ctr, alu_zero: std_logic;
   signal pc_mux_ctr, alu_mux_ctr, dreg_mux_ctr: std_logic;
   signal pc_in, pc_out: std_logic_vector(PCDATA_WIDTH-1 downto 0);
   signal opcd_out: std_logic_vector(IMDATA_WIDTH-1 downto 0); 
   signal dr1_dout, dr2_dout: std_logic_vector(DRDATA_WIDTH-1 downto 0);
   signal alu_mux_out, alu_dout: std_logic_vector(DRDATA_WIDTH-1 downto 0);
   signal dm_dout, dr_mux_out: std_logic_vector(DMDATA_WIDTH-1 downto 0);
   signal alu_ctr_in: std_logic_vector(OPCODE_WIDTH-1 downto 0);
   signal in_mux_ctr, out_reg_wr: std_logic;
   signal in_mux_out: std_logic_vector(DRDATA_WIDTH-1 downto 0);

begin

    -- instantiate program counter
    pc: entity work.pc(arch)
    port map(clk=>clk, rst=>rst, reg_d=>pc_in, 
             reg_q=>pc_out);
   
    -- instantiate instruction memory
    imem: entity work.imem(arch)
    port map(im_addr=>pc_out(4 downto 0), im_dout=>opcd_out);
	
	-- instantiate data registers
    dreg: entity work.dreg(arch)
    port map(clk=>clk, dr_wr_ctr=>dr_wr_ctr, dwr_addr=>opcd_out(9 downto 7), 
		     dr1_addr=>opcd_out(12 downto 10), dr2_addr=>opcd_out(15 downto 13),              
		     dwr_din=>in_mux_out, dr1_dout=>dr1_dout, dr2_dout=>dr2_dout);
	
	-- instantiate ALU
    alu: entity work.alu(arch)
    port map(alu_din_hi=>dr1_dout, alu_din_lo=>alu_mux_out,             
		     alu_ctr_in=>alu_ctr_in, alu_dout=>alu_dout, alu_zero=>alu_zero);
	
	-- instantiate data memory
    dmem: entity work.dmem(arch)
    port map(clk=>clk, dm_wr_ctr=>dm_wr_ctr, 
		     dm_addr=>alu_dout, dm_din=>dr2_dout, dm_dout=>dm_dout);              
		                       
	-- instantiate FSM control path
    control: entity work.control(arch)
    port map(clk=>clk, rst=>rst, alu_zero=>alu_zero, 
		     pc_mux_ctr=>pc_mux_ctr, alu_mux_ctr=>alu_mux_ctr, dreg_mux_ctr=>dreg_mux_ctr, in_mux_ctr=>in_mux_ctr, out_reg_write=>out_reg_wr,
		     opcode=>opcd_out(OPCODE_WIDTH-1 downto 0), dreg_write=>dr_wr_ctr, dmem_write=>dm_wr_ctr, alu_ctr=>alu_ctr_in);
		     
    -- instantiate output register
    out_reg: entity work.reg(arch)
    port map(clk=>clk, rst=>rst, reg_ld=>out_reg_wr, 
             reg_d=>dr2_dout, reg_q=>dig_out);
    
	
	-- Glue logic at top level: pc_mux
	pc_in <= std_logic_vector(unsigned(pc_out) + 1) when pc_mux_ctr='1' else 
	         std_logic_vector(unsigned(pc_out) + unsigned(opcd_out(23 downto 16))) when opcd_out(23)='0' else
             std_logic_vector(unsigned(pc_out) - not(unsigned(opcd_out(23 downto 16))-1))  ;
             
	-- Glue logic at top level: alu_mux
	alu_mux_out <= opcd_out(23 downto 16) when alu_mux_ctr='1' else dr2_dout;     

	-- Glue logic at top level: dr_mux
	dr_mux_out <= alu_dout when dreg_mux_ctr='1' else dm_dout;  
	
	-- Glue logic at top level: in_mux
	in_mux_out <= dig_in when in_mux_ctr='1' else dr_mux_out;  

		
end arch;