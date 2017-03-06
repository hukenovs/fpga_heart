--------------------------------------------------------------------------------
--
-- Title       : top_xc3s500e_heart.vhd
-- Design      : Heart 8.3.17
-- Author      : Kapitanov
-- Company     : ...
-- 
-- Version     : 1.0
--------------------------------------------------------------------------------
--
-- Description : Top level for heart based on Spartan3E Starter Kit
-- 
-- Xilinx Spartan3e - XC3S500E-4FG320C 
--
-- SW<0> - RESET
-- SW<1> - ENABLE PWM
-- SW<2> - HEART MODE
-- SW<3> - RESET LED8x8
--
-- KB<1> - Change Counter #1 (PWM Delay)
-- KB<2> - Change Counter #2 (PWM Freq)
-- KB<3> - Change Counter LED8x8
--
--------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_UNSIGNED.all;

library UNISIM;
use UNISIM.VCOMPONENTS.ALL;

entity top_xc3s500e_heart is
	port(
		---- SWITCHES ----
		RESET	:  in  std_logic;  --! asycnchronous reset: SW(0)
		SW		:  in  std_logic_vector(7 downto 1); -- other switches
		---- CLOCK 50 MHz ----
		CLK		:  in  std_logic;	--! main clock 50 MHz
		---- LED DISPLAY ----
		LED_X	:  out std_logic_vector(7 downto 0);	--! LEDs Y
		LED_Y	:  out std_logic_vector(7 downto 0);	--! LEDs X	
		---- BUTTONS ----
		KB		:  in  std_logic_vector(5 downto 1); --! Five Buttons				
		---- DOORBELL ----
		BELL	:  out std_logic --! BELL (tie to VCC)
	);
end top_xc3s500e_heart;

architecture top_xc3s500e_heart of top_xc3s500e_heart is

---------------- SIGNALS DECLARATION ----------------
signal sys_reset	: std_logic;
signal reset_v		: std_logic;
signal rst			: std_logic;
signal rstz			: std_logic;

signal clk_fb		: std_logic;
signal clk0			: std_logic;
signal clk_in		: std_logic;
signal locked		: std_logic;
signal clk_dv		: std_logic;
signal rst_dcm		: std_logic;

signal led_hearty	: std_logic_vector(7 downto 0);
signal led_heartx   : std_logic_vector(7 downto 0);

signal button 		: std_logic_vector(5 downto 1);

signal clbutton 	: std_logic_vector(5 downto 1);
signal log_led		: std_logic;

signal log_hearty0	: std_logic_vector(7 downto 0);
signal log_heartx0 	: std_logic_vector(7 downto 0);

signal log_hearty1	: std_logic_vector(7 downto 0);
signal log_heartx1 	: std_logic_vector(7 downto 0);

signal xsw			: std_logic_vector(7 downto 1);
signal trig			: std_logic_vector(7 downto 1);

begin

xRESET: ibuf port map(i => RESET, o => rst);
xBELL:	obuf port map(i => '1', o => BELL);

xBUTS: for ii in 1 to 5 generate
	XBTT: ibuf port map(i => KB(ii), o => button(ii));
end generate;

-- LEDS: 
xLED_XY: for ii in 0 to 7 generate
	LEDX: obuf port map(i => led_heartx(ii), o => LED_X(ii));
	LEDY: obuf port map(i => led_hearty(ii), o => LED_Y(ii));
end generate;

xBTN: for ii in 1 to 5 generate 
	xBT: entity work.ctrl_jazz
		port map (
			CLK			=> clk0,	
			BUTTON		=> button(ii),
			RESET		=> rst, 		
			CLRBUTTON	=> clbutton(ii)
		);
end generate; 	
	
xCTRL_PWM : entity work.ctrl_pwm
	port map (
		clk 		=> clk_dv,
		rst 		=> reset_v,
		zoom_cnt	=> clbutton(1),
		zoom_lvl	=> clbutton(2),
		log_led 	=> log_led
	);

x_gen_ledx : for ii in 0 to 7 generate
	process(clk_dv) is
	begin
		if rising_edge(clk_dv) then
			if (xsw(4) = '0') then
				if (xsw(1) = '0') then
					led_heartx(ii) <= log_led or log_heartx0(ii);
				else
					led_heartx(ii) <= log_heartx0(ii);
				end if;
			else
				if (xsw(1) = '0') then
					led_heartx(ii) <= log_led or log_heartx1(ii);
				else
					led_heartx(ii) <= log_heartx1(ii);
				end if;	
			end if;
		end if;	
	end process;
	--led_heartx(ii) <= log_heartx(ii) when xsw(1) = '0' else log_heartx(ii); 
end generate;

x_gen_ledy : for ii in 0 to 7 generate
	process(clk_dv) is
	begin
		if rising_edge(clk_dv) then
			if (xsw(4) = '0') then
				if (xsw(1) = '0') then
					led_hearty(ii) <= log_led or log_hearty0(ii);
				else
					led_hearty(ii) <= log_hearty0(ii);
				end if;
			else
				if (xsw(1) = '0') then
					led_hearty(ii) <= log_led or log_hearty1(ii);
				else
					led_hearty(ii) <= log_hearty1(ii);
				end if;			
			end if;	
		end if;	
	end process;	
	--led_hearty(ii) <= log_led or log_hearty(ii) when xsw(1) = '0' else log_hearty(ii); 
end generate;	
	
-- Switches:
xSWG: for ii in 1 to 7 generate
	xSW: ibuf port map(i => SW(ii), o => trig(ii));
end generate;

xsw <= trig when rising_edge(clk_dv);
	
xCTRL_LED : entity work.ctrl_led8x8_heart 
	port map (
		clk 		=> clk_dv,
		rst 		=> reset_v,
		
		mode		=> xsw(2),
		rst_reg 	=> xsw(3),
		ch_freq		=> clbutton(3),
		
		led_y 		=> log_hearty0,
		led_x 		=> log_heartx0
	);	
	
xCTRL_TEXT : entity work.ctrl_led8x8_text 
	port map (
		clk 		=> clk_dv,
		rst 		=> reset_v,
		
		led_y 		=> log_hearty1,
		led_x 		=> log_heartx1
	);		
	
---------------- DCM CLOCK ----------------
xCLKFB:	bufg port map(i => clk0, o => clk_fb);
xCLKIN:	ibufg port map(i => clk,o => clk_in);

sys_reset <= (rstz and locked) when rising_edge(clk_in);	
reset_v <= sys_reset when rising_edge(clk_in);

---------------- SRL16 RESET DCM ----------------
xSRL_RESET: SRLC16
	generic map (
		init => x"0000"
	)
	port map(
		Q15		=> rstz,
		A0		=> '1',
		A1		=> '1',
		A2		=> '1',
		A3		=> '1',
		CLK		=> clk_in,
		D		=> rst -- '1',
	);	

rst_dcm <= not rst;	
---------------- CLOCK GENERATOR - DCM ----------------
xDCM_CLK_VGA : DCM
generic map(
		--DCM_AUTOCALIBRATION 	=> FALSE,	-- DCM ADV
		CLKDV_DIVIDE 			=> 2.0,		-- clk divide for CLKIN: Fdv = Fclkin / CLK_DIV
		CLKFX_DIVIDE 			=> 2,		-- clk divide for CLKFX and CLKFX180 : Ffx = (Fclkin * MULTIPLY) / CLKFX_DIV
		CLKFX_MULTIPLY 			=> 2,		-- clk multiply for CLKFX and CLKFX180 : Ffx = (Fclkin * MULTIPLY) / CLKFX_DIV
		CLKIN_DIVIDE_BY_2 		=> FALSE,	-- divide clk / 2 before DCM block
		CLKIN_PERIOD 			=> 20.0,	-- clk period in ns (for DRC)
		CLKOUT_PHASE_SHIFT 		=> "NONE",	-- phase shift mode: NONE, FIXED, VARIABLE		
		CLK_FEEDBACK 			=> "1X",	-- freq on the feedback clock: 1x, 2x, None
		DESKEW_ADJUST 			=> "SYSTEM_SYNCHRONOUS",	-- clk delay alignment
		DFS_FREQUENCY_MODE 		=> "LOW",	-- freq mode CLKFX and CLKFX180: LOW, HIGH
		DLL_FREQUENCY_MODE 		=> "LOW",	-- freq mode CLKIN: LOW, HIGH
		DUTY_CYCLE_CORRECTION 	=> TRUE,	-- 50% duty-cycle correction for the CLK0, CLK90, CLK180 and CLK270: TRUE, FALSE
		PHASE_SHIFT			 	=> 0		-- phase shift (with CLKOUT_PHASE_SHIFT): -255 to 255 
	)
	port map(
		clk0 		=> clk0,
--		clk180 		=> clk180,
--		clk270 		=> clk270,
--		clk2x 		=> clk2x,
--		clk2x180 	=> clk2x180,
--		clk90 		=> clk90,
		clkdv 		=> clk_dv,
--		clkfx 		=> clkfx,
--		clkfx180 	=> clkfx180,
		locked 		=> locked,
--		status 		=> status,
--		psdone 		=> psdone,	

		clkfb 		=> clk_fb,
		clkin 		=> clk_in,
--		dssen 		=> dssen,
--		psclk 		=> psclk,
		psen 		=> '0',
		psincdec 	=> '0',
		rst 		=> rst_dcm
	);

end top_xc3s500e_heart;