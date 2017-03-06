--------------------------------------------------------------------------------
--
-- Title       : ctrl_pwm.vhd
-- Design      : Example
-- Author      : Kapitanov
-- Company     : InSys
-- 
-- Version     : 1.0
--------------------------------------------------------------------------------
--
-- Description : Pulse-width modulation
--
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity ctrl_pwm is
	port (
		clk            : in  std_logic;  --! clock  
		rst            : in  std_logic;  --! reset

		zoom_cnt	   : in  std_logic;  --! switch counter
		zoom_lvl	   : in  std_logic;	 --! switch level

		log_led        : out std_logic	 --! pulsed LED enable    
	);  
end ctrl_pwm;

architecture ctrl_pwm of ctrl_pwm is
 
constant Nmax		: integer:=15;
constant Ncnt		: integer:=11;
 
signal cnt_dec		: std_logic_vector(Ncnt downto 0);
signal thrsh		: std_logic_vector(Ncnt downto 0); 

signal cnt_big		: std_logic_vector(Nmax downto 0);

signal zoom_cntz	: std_logic;
signal front_cnt	: std_logic;

signal zoom_lvlz	: std_logic;
signal front_lvl	: std_logic;

signal switch_cnt 	: std_logic_vector(2 downto 0);
signal switch_lvl 	: std_logic_vector(2 downto 0);

begin

zoom_cntz <= zoom_cnt when rising_edge(clk);
front_cnt <= zoom_cnt and not zoom_cntz when rising_edge(clk);

zoom_lvlz <= zoom_lvl when rising_edge(clk);
front_lvl <= zoom_lvl and not zoom_lvlz when rising_edge(clk);

pr_cntx: process(clk, rst) is
begin
	if (rst = '0') then	
		switch_cnt <= (others => '0');
	elsif rising_edge(clk) then
		if (front_cnt = '1') then
			switch_cnt <= switch_cnt + '1';
		end if;			
	end if;
end process;		

pr_lvlx: process(clk, rst) is
begin
	if (rst = '0') then	
		switch_lvl <= (others => '0');
	elsif rising_edge(clk) then
		if (front_lvl = '1') then
			switch_lvl <= switch_lvl + '1';
		end if;			
	end if;
end process;

pr_case_cnt: process(clk, rst) is
begin
	if (rst = '0') then	
		cnt_dec <= (others => '0');
	elsif rising_edge(clk) then
		if cnt_dec(Ncnt) = '0' then
			case switch_lvl is 
				when "000"  => cnt_dec <= cnt_dec +  x"1";
				when "001"  => cnt_dec <= cnt_dec +  x"2";
				when "010"  => cnt_dec <= cnt_dec +  x"4";
				when "011"  => cnt_dec <= cnt_dec +  x"8";
				when "100"  => cnt_dec <= cnt_dec +  x"10";
				when "101"  => cnt_dec <= cnt_dec +  x"20";
				when "110"  => cnt_dec <= cnt_dec +  x"40";
				when others => cnt_dec <= cnt_dec +  x"80";
			end case;		
			--cnt_dec <= cnt_dec + '1';
		else
			cnt_dec <= (others => '0');
		end if;
	end if;
end process;

pr_thrs: process(clk, rst) is
begin
	if (rst = '0') then	
		thrsh	<= (others => '0');
	elsif rising_edge(clk) then			
		if cnt_big(Nmax) = '1' then	
			if (thrsh(Ncnt) = '1') then
				thrsh <= (others => '0');
			else
				case switch_lvl is 
					when "000"  => thrsh <= thrsh +  x"1";
					when "001"  => thrsh <= thrsh +  x"2";
					when "010"  => thrsh <= thrsh +  x"4";
					when "011"  => thrsh <= thrsh +  x"8";
					when "100"  => thrsh <= thrsh +  x"10";
					when "101"  => thrsh <= thrsh +  x"20";
					when "110"  => thrsh <= thrsh +  x"40";
					when others => thrsh <= thrsh +  x"80";
				end case;			
			
				--thrsh <= thrsh + '1';
			end if;
		else
			null;
		end if;
	end if;
end process;

pr_case_reg: process(clk, rst) is
begin
	if (rst = '0') then	
		cnt_big <= (others => '0');
	elsif rising_edge(clk) then		
		if (cnt_big(Nmax) = '0') then
			case switch_cnt is 
				when "000"  => cnt_big <= cnt_big +  x"1";
				when "001"  => cnt_big <= cnt_big +  x"2";
				when "010"  => cnt_big <= cnt_big +  x"4";
				when "011"  => cnt_big <= cnt_big +  x"8";
				when "100"  => cnt_big <= cnt_big +  x"10";
				when "101"  => cnt_big <= cnt_big +  x"20";
				when "110"  => cnt_big <= cnt_big +  x"40";
				when others => cnt_big <= cnt_big +  x"80";
			end case;
		else
			cnt_big <= (others => '0');
		end if;
	end if;
end process;
	
log_led <= '0' when unsigned(cnt_dec) < unsigned(thrsh) else '1';

end ctrl_pwm;