-------------------------------------------------------------------------------
--
-- Title       : ctrl_led8x8_heart
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

entity ctrl_led8x8_heart is
	port (
		clk    		: in std_logic;                    		--! clock
		rst    		: in std_logic;                    		--! reset
		
		mode		: in std_logic;							--! heart mode
		
		rst_reg		: in std_logic;                    		--! count reset
		ch_freq		: in std_logic;                    		--! change frequency
		
		led_y  		: out std_logic_vector(7 downto 0);		--! LED Y    
		led_x  		: out std_logic_vector(7 downto 0) 		--! LED X
	);  
end ctrl_led8x8_heart;

architecture ctr_led8x8 of ctrl_led8x8_heart is

constant Nled		: integer:=17; -- 12

signal cnt_led 		: std_logic_vector(Nled downto 0);
signal cnt_cmd		: std_logic_vector(2 downto 0);

signal led_cmd 		: std_logic_vector(2 downto 0);

signal data_led0 	: std_logic_vector(7 downto 0);
signal data_led1	: std_logic_vector(7 downto 0);
signal en_xhdl 		: std_logic_vector(7 downto 0);

signal ch_freqz		: std_logic;
signal ch_freqx		: std_logic;

signal case_cnt		: std_logic_vector(3 downto 0);

begin

ch_freqz <= ch_freq when rising_edge(clk);
ch_freqx <= ch_freq and not ch_freqz when rising_edge(clk);

pr_mode: process(clk) is
begin 
	if rising_edge(clk) then
		if (mode = '0') then
			led_x <= data_led0;
		else
			led_x <= data_led1;
		end if;
	end if;
end process;

-- led_y <= data_led;
led_y <= en_xhdl when rising_edge(clk);

pr_cnt: process(clk, rst) is
begin 
	if (rst = '0') then
		cnt_led <= (others => '0');
	elsif rising_edge(clk) then
		if (rst_reg = '0') then
			cnt_led <= (others => '0');
		else
			cnt_led <= cnt_led + '1';
		end if;
	end if;
end process;

pr_case: process(clk, rst) is
begin 
	if (rst = '0') then
		case_cnt <= (others => '0');
	elsif rising_edge(clk) then
		if (rst_reg = '0') then
			case_cnt <= (others => '0');
		elsif ch_freqx = '1' then	
			case_cnt <= case_cnt + '1';
		end if;
	end if;
end process;

pr_cmd: process(clk) is
begin
	if rising_edge(clk) then
		case case_cnt is
			when	"0000"	=> cnt_cmd	<=	cnt_led(Nled-0 downto Nled-2-0);
			when	"0001"	=> cnt_cmd	<=	cnt_led(Nled-1 downto Nled-2-1);
			when	"0010"	=> cnt_cmd	<=	cnt_led(Nled-2 downto Nled-2-2);
			when	"0011"	=> cnt_cmd	<=	cnt_led(Nled-3 downto Nled-2-3);
			when	"0100"	=> cnt_cmd	<=	cnt_led(Nled-4 downto Nled-2-4);
			when	"0101"	=> cnt_cmd	<=	cnt_led(Nled-5 downto Nled-2-5);
			when	"0110"	=> cnt_cmd	<=	cnt_led(Nled-6 downto Nled-2-6);
			when	"0111"	=> cnt_cmd	<=	cnt_led(Nled-7 downto Nled-2-7);			
			when	"1000"	=> cnt_cmd	<=	cnt_led(Nled-8 downto Nled-2-8);
			when	"1001"	=> cnt_cmd	<=	cnt_led(Nled-9 downto Nled-2-9);
			when	"1010"	=> cnt_cmd	<=	cnt_led(Nled-10 downto Nled-2-10);
			when	"1011"	=> cnt_cmd	<=	cnt_led(Nled-11 downto Nled-2-11);
			when	"1100"	=> cnt_cmd	<=	cnt_led(Nled-12 downto Nled-2-12);
			when	"1101"	=> cnt_cmd	<=	cnt_led(Nled-13 downto Nled-2-13);
			when	"1110"	=> cnt_cmd	<=	cnt_led(Nled-14 downto Nled-2-14);			
			when	others	=> cnt_cmd	<=	cnt_led(Nled-15 downto Nled-2-15);
		end case;
	end if;
end process;

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

pr_mode0: process(led_cmd) is
begin
	case led_cmd is		
		when "000" => data_led0 <= "11111111";    
		when "001" => data_led0 <= "11100111";    
		when "010" => data_led0 <= "11011011";    
		when "011" => data_led0 <= "10111101";    
		when "100" => data_led0 <= "01111110";    
		when "101" => data_led0 <= "01100110";    
		when "110" => data_led0 <= "10011001";    
		when others => data_led0 <= "11111111";        
	end case;
end process;

pr_mode1: process(led_cmd) is
begin
	case led_cmd is		
		when "000" => data_led1 <= "11111111";    
		when "001" => data_led1 <= "11100111";    
		when "010" => data_led1 <= "11000011";    
		when "011" => data_led1 <= "10000001";    
		when "100" => data_led1 <= "00000000";    
		when "101" => data_led1 <= "00000000";    
		when "110" => data_led1 <= "10011001";    
		when others => data_led1 <= "11111111";        
	end case;
end process;

end ctr_led8x8;