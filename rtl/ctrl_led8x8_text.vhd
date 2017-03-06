-------------------------------------------------------------------------------
--
-- Title       : ctrl_led8x8_text
-- Author      : Alexander Kapitanov
-- Company     : Instrumental Systems
-- E-mail      : kapitanov@insys.ru
--
-- Version     : 1.0
--
-------------------------------------------------------------------------------
--
-- Description : Controller for LED Matrix	
-- 					
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity ctrl_led8x8_text is
	port (
		clk    		: in std_logic;                    		--! clock
		rst    		: in std_logic;                    		--! reset

		led_y  		: out std_logic_vector(7 downto 0);		--! LED Y    
		led_x  		: out std_logic_vector(7 downto 0) 		--! LED X
	);  
end ctrl_led8x8_text;

architecture ctr_led8x8 of ctrl_led8x8_text is

constant Nled		: integer:=12; 
signal cnt_led 		: std_logic_vector(Nled downto 0);
signal cnt_cmd		: std_logic_vector(2 downto 0);

signal led_cmd 		: std_logic_vector(2 downto 0);

signal data_led		: std_logic_vector(7 downto 0);
signal en_xhdl 		: std_logic_vector(7 downto 0);

signal case_cnt		: std_logic_vector(3 downto 0);

constant Na			: integer:=27;
signal addr_txt		: std_logic_vector(Na-1 downto 0);

type rom_type is array (7 downto 0) of std_logic_vector(7 downto 0);
type rom_8x8 is array (0 to 7) of rom_type;

constant ROM_TEXT: rom_8x8:=( 
(  
"11000011",
"10011001",
"00111101",
"00111111",
"00111111",
"00111101",
"10011001",
"11000011"),
(  
"11100111",
"10011001",
"10011001",
"11100111",
"10011001",
"10011001",
"10011001",
"11100111"),
(  
"00111100",
"00011000",
"00000000",
"00100100",
"00111100",
"00111100",
"00111100",
"00111100"),
(  
"11100111", 
"11000011", 
"10011001", 
"00111100", 
"00000000", 
"00111100", 
"00111100", 
"00111100"),
(  
"00000011", 
"10011001", 
"10011001", 
"10011001", 
"10000011", 
"10011111", 
"10011111", 
"00001111"),
(  
"00000000", 
"00100100", 
"01100110", 
"11100111", 
"11100111", 
"11100111", 
"11100111", 
"11000011"),
(  
"11100111", 
"11000011", 
"10011001", 
"00111100", 
"00000000", 
"00111100", 
"00111100", 
"00111100"),
(
"11100111", 
"11100111", 
"11100111", 
"11100111", 
"11100111", 
"11100111", 
"11111111",  
"11100111")

);

begin

led_x <= data_led when rising_edge(clk);
led_y <= en_xhdl when rising_edge(clk);

pr_cnt: process(clk, rst) is
begin 
	if (rst = '0') then
		cnt_led <= (others => '0');
	elsif rising_edge(clk) then
		cnt_led <= cnt_led + '1';
	end if;
end process;
cnt_cmd	<= cnt_led(Nled downto Nled-2);

pr_3x8: process(cnt_cmd) is
begin
	case cnt_cmd is
		when	"000"	=> en_xhdl	<=	"11111110";
		when	"001"	=> en_xhdl	<=	"11111101";
		when	"010"	=> en_xhdl	<=	"11111011";
		when	"011"	=> en_xhdl	<=	"11110111";
		when	"100"	=> en_xhdl	<=	"11101111";
		when	"101"	=> en_xhdl	<=	"11011111";
		when	"110"	=> en_xhdl	<=	"10111111";
		when	others	=> en_xhdl	<=	"01111111";
	end case;
end process;

pr_8x4: process(en_xhdl) is
begin
	case en_xhdl is
		when "11111110"	=> led_cmd	<= "000";
		when "11111101"	=> led_cmd	<= "001";
		when "11111011"	=> led_cmd	<= "010";
		when "11110111"	=> led_cmd	<= "011";
		when "11101111"	=> led_cmd	<= "100";
		when "11011111"	=> led_cmd	<= "101";
		when "10111111"	=> led_cmd	<= "110";
		when others	=> led_cmd		<= "111";
	end case;
end process;

pr_addr: process(clk, rst) is
begin 
	if (rst = '0') then
		addr_txt <= (others => '0');
	elsif rising_edge(clk) then
		addr_txt <= addr_txt + '1';
	end if;
end process;

pr_8x8: process(clk, rst) is
-- variable addr_text:	integer;
-- variable addr_ledx:	integer;
begin 
	if (rst = '0') then
		data_led <= (others => '0');
	elsif rising_edge(clk) then
		-- addr_text := CONV_INTEGER(addr_txt(Na-1 downto Na-3));
		-- addr_ledx := CONV_INTEGER(led_cmd);
		data_led <= ROM_TEXT(CONV_INTEGER(addr_txt(Na-1 downto Na-3)))(CONV_INTEGER(led_cmd));
	end if;
end process;

--data_led <= ROM_TEXT(CONV_INTEGER(addr_txt(Na-1 downto Na-3)))(CONV_INTEGER(led_cmd));

end ctr_led8x8;