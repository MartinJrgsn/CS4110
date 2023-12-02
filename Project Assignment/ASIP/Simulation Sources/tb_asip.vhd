
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
 
ENTITY tb_asip IS
   generic(
      DRDATA_WIDTH: integer:=8;
      SSEG_WIDTH: integer:=7;
      SSEG_AN_WIDTH: integer:=4  
   );
END tb_asip;
 
ARCHITECTURE behavior OF tb_asip IS
 
    -- Component Declaration for the Unit Under Test (UUT) 
    COMPONENT ASIP
    PORT(clk, rst, echo, btnC: in std_logic;
         sw: in std_logic_vector(DRDATA_WIDTH-1 downto 0);
         trig: out std_logic;
         sseg_out: out std_logic_vector(SSEG_WIDTH-1 downto 0);
         out1, out2, out3: out std_logic;     -- ENB_1, IN3_1, IN4_1
         out4, out5, out6: out std_logic;     -- ENA_2, IN1_1, IN2_1
         out7, out8, out9: out std_logic;     -- ENA_1, IN1_1, IN2_1
         out10, out11, out12: out std_logic;  -- ENB_2, IN3_2, IN4_2
         an_out: out std_logic_vector(SSEG_AN_WIDTH-1 downto 0));
    END COMPONENT;
    
   --Inputs
   signal clk : std_logic;
   signal rst : std_logic;
   signal echo: std_logic;
   signal sw: std_logic_vector(DRDATA_WIDTH-1 downto 0);
   signal btnC: std_logic;
 	--Outputs
   signal trig: std_logic;
   signal sseg_out: std_logic_vector(SSEG_WIDTH-1 downto 0);
   --signal m_dir_reg_out: std_logic_vector(DRDATA_WIDTH-1 downto 0);
   signal an_out: std_logic_vector(SSEG_AN_WIDTH-1 downto 0);
   -- Clock period definitions
   constant clk_period : time := 10 ns;
   constant distance_cm : time := 58310 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: ASIP PORT MAP (
          clk => clk,
          rst => rst, 
          echo => echo,
          sw => sw,
          btnC => btnC);

   -- Clock process definitions
   clk_process :process
   begin
		clk <= '0';
		wait for clk_period/2;
		clk <= '1';
		wait for clk_period/2;
   end process;

   -- Stimulus process
   stim_proc: process
   begin		
      rst <= '1';
      btnC <= '0';                  -- Used for manual current_threshold value
      sw <= "00001111";             -- if btnC = '1' then current_threshold <= sw
      
      wait for clk_period;          -- 10 ns in
	  rst <= '0';
	  
	  wait for clk_period/2;         -- 15 ns in
	  echo <= '1';                   -- While echo is high, pwm_module is counting
	  
	  wait for 10*distance_cm;       -- 583125 ns in
	  echo <= '0';                   -- When echo goes low, measured_distance goes to 10 (unsigned decimal)

	  wait for 37416910 ns;          -- 38000025 ns in
	  echo <= '1';

	  wait for 38 ms;                -- 76000025
	  echo <= '0';                   -- When echo is high for more than the threshold, the distance is set to 0.

	  wait for 10 ns;                -- 76000035
	  echo <= '1';
     
	  wait for 38 ms;                -- 114000035 ns in
	  echo <= '0';                   -- When echo is high for more than the threshold, the distance is set to 0.

	  wait for 10 ns;                -- 114000045 ns in
	  echo <= '1';
	  wait;
   end process;

END;
