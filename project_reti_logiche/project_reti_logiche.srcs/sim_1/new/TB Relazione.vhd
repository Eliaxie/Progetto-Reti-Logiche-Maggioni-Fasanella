-- Test per Progetto di Elia Maggioni e Marco Fasanella
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;

entity project_tb is
end project_tb;

architecture projecttb of project_tb is
constant c_CLOCK_PERIOD         : time := 15 ns;
signal   tb_done                : std_logic;
signal   mem_address            : std_logic_vector (15 downto 0) := (others => '0');
signal   tb_rst                 : std_logic := '0';
signal   tb_start               : std_logic := '0';
signal   tb_clk                 : std_logic := '0';
signal   mem_o_data,mem_i_data  : std_logic_vector (7 downto 0);
signal   enable_wire            : std_logic;
signal   mem_we                 : std_logic;

type ram_type is array (65535 downto 0) of std_logic_vector(7 downto 0);

signal i: std_logic_vector(3 downto 0) := "0000";


signal RAM: ram_type := (
			 0 => std_logic_vector(to_unsigned(  2  , 8)),
			 1 => std_logic_vector(to_unsigned(  3  , 8)),
			 2 => std_logic_vector(to_unsigned(  255  , 8)),
			 3 => std_logic_vector(to_unsigned(  0  , 8)),
			 4 => std_logic_vector(to_unsigned(  1  , 8)),
			 5 => std_logic_vector(to_unsigned(  1 , 8)),
			 6 => std_logic_vector(to_unsigned(  0  , 8)),
			 7 => std_logic_vector(to_unsigned(  255  , 8)),
                         others => (others =>'0'));         
			 -- delta=255 shift=0  
			 -- Test con Delta maggiore possibile 

signal RAM1: ram_type := (
			  0 => std_logic_vector(to_unsigned(  2  , 8)),
			 1 => std_logic_vector(to_unsigned(  3  , 8)),
			 2 => std_logic_vector(to_unsigned(  0 , 8)),
			 3 => std_logic_vector(to_unsigned(  0 , 8)),
			 4 => std_logic_vector(to_unsigned(  0  , 8)),
			 5 => std_logic_vector(to_unsigned(  0  , 8)),
			 6 => std_logic_vector(to_unsigned(  0  , 8)),
			 7 => std_logic_vector(to_unsigned(  0 , 8)),
                         others => (others =>'0')); 
             -- delta=0 shift=8   
             -- Test con tutti zero  

signal RAM2: ram_type := (
			  0 => std_logic_vector(to_unsigned(  2  , 8)),
			 1 => std_logic_vector(to_unsigned(  3  , 8)),
			 2 => std_logic_vector(to_unsigned(  255  , 8)),
			 3 => std_logic_vector(to_unsigned(  255 , 8)),
			 4 => std_logic_vector(to_unsigned(  255  , 8)),
			 5 => std_logic_vector(to_unsigned(  255  , 8)),
			 6 => std_logic_vector(to_unsigned(  255  , 8)),
			 7 => std_logic_vector(to_unsigned(  255  , 8)),
                         others => (others =>'0'));  
             -- delta=0 shift=8    
             -- Test con tutti 255

signal RAM3: ram_type := (
			  0 => std_logic_vector(to_unsigned(  2  , 8)),
			 1 => std_logic_vector(to_unsigned(  3  , 8)),
			 2 => std_logic_vector(to_unsigned(  128  , 8)),
			 3 => std_logic_vector(to_unsigned(  128  , 8)),
			 4 => std_logic_vector(to_unsigned(  128  , 8)),
			 5 => std_logic_vector(to_unsigned(  128  , 8)),
			 6 => std_logic_vector(to_unsigned(  128  , 8)),
			 7 => std_logic_vector(to_unsigned(  128  , 8)),
                         others => (others =>'0'));
             -- delta=0 shift=8 
             --Test con delta minore possibile (tutti 128) in modo da controllare anche lo shift
						 
signal RAM4: ram_type := (
			  0 => std_logic_vector(to_unsigned(  2  , 8)),
			 1 => std_logic_vector(to_unsigned(  3  , 8)),
			 2 => std_logic_vector(to_unsigned(  255 , 8)), --MAX
			 3 => std_logic_vector(to_unsigned(  132  , 8)),
			 4 => std_logic_vector(to_unsigned( 254  , 8)),
			 5 => std_logic_vector(to_unsigned(  2  , 8)),
			 6 => std_logic_vector(to_unsigned(  2 , 8)),
			 7 => std_logic_vector(to_unsigned(  1 , 8)), --MIN
                         others => (others =>'0')); 	
             -- delta=254 shift=1
             --Test con Massimo e Minimo agli estremi di lettura						

signal RAM5: ram_type := (
			  0 => std_logic_vector(to_unsigned(  2  , 8)),
			 1 => std_logic_vector(to_unsigned(  0  , 8)),
			 2 => std_logic_vector(to_unsigned(  110  , 8)),
			 3 => std_logic_vector(to_unsigned(  115  , 8)),
			 4 => std_logic_vector(to_unsigned(  124  , 8)),
			 5 => std_logic_vector(to_unsigned(  110  , 8)),
			 6 => std_logic_vector(to_unsigned(  111  , 8)),
			 7 => std_logic_vector(to_unsigned(  120  , 8)),
                         others => (others =>'0')); 	
             --Immagine con lunghezza 0	(posizione 1)					

signal RAM6: ram_type := (
			 0 => std_logic_vector(to_unsigned(  0  , 8)),
			 1 => std_logic_vector(to_unsigned(  3  , 8)),
			 2 => std_logic_vector(to_unsigned(  110  , 8)),
			 3 => std_logic_vector(to_unsigned(  115  , 8)),
			 4 => std_logic_vector(to_unsigned(  125  , 8)),
			 5 => std_logic_vector(to_unsigned(  110  , 8)),
			 6 => std_logic_vector(to_unsigned(  111  , 8)),
			 7 => std_logic_vector(to_unsigned(  120  , 8)),
                         others => (others =>'0')); 	
              --Immagine con lunghezza (posizione 0)							 

signal RAM7: ram_type := (
			 0 => std_logic_vector(to_unsigned(  2  , 8)),
			 1 => std_logic_vector(to_unsigned(  3  , 8)),
			 2 => std_logic_vector(to_unsigned(  200  , 8)), --Max
			 3 => std_logic_vector(to_unsigned(  199  , 8)),
			 4 => std_logic_vector(to_unsigned(  170  , 8)), --Min
			 5 => std_logic_vector(to_unsigned(  177  , 8)),
			 6 => std_logic_vector(to_unsigned(  180  , 8)),
			 7 => std_logic_vector(to_unsigned(  171  , 8)),
                         others => (others =>'0')); 
             -- delta=30 shift=4

signal RAM8: ram_type := (
			  0 => std_logic_vector(to_unsigned(  2  , 8)),
			 1 => std_logic_vector(to_unsigned(  3  , 8)),
			 2 => std_logic_vector(to_unsigned(  201  , 8)), --Max
			 3 => std_logic_vector(to_unsigned(  199  , 8)),
			 4 => std_logic_vector(to_unsigned(  170  , 8)), --Min
			 5 => std_logic_vector(to_unsigned(  177  , 8)),
			 6 => std_logic_vector(to_unsigned(  180  , 8)),
			 7 => std_logic_vector(to_unsigned(  171  , 8)),
                         others => (others =>'0')); 	
             -- delta=31 shift=3

component project_reti_logiche is
port (
      i_clk         : in  std_logic;
      i_start       : in  std_logic;
      i_rst         : in  std_logic;
      i_data        : in  std_logic_vector(7 downto 0);
      o_address     : out std_logic_vector(15 downto 0);
      o_done        : out std_logic;
      o_en          : out std_logic;
      o_we          : out std_logic;
      o_data        : out std_logic_vector (7 downto 0)
      );
end component project_reti_logiche;


begin
UUT: project_reti_logiche
port map (
          i_clk      	=> tb_clk,
          i_start       => tb_start,
          i_rst      	=> tb_rst,
          i_data    	=> mem_o_data,
          o_address  	=> mem_address,
          o_done      	=> tb_done,
          o_en   	=> enable_wire,
          o_we 		=> mem_we,
          o_data    	=> mem_i_data
          );

p_CLK_GEN : process is
begin
    wait for c_CLOCK_PERIOD/2;
    tb_clk <= not tb_clk;
end process p_CLK_GEN;


MEM : process(tb_clk)
begin
if tb_clk'event and tb_clk = '1' then
    if enable_wire = '1' then
			if i = "0000" then
				if mem_we = '1' then
					RAM(conv_integer(mem_address))  <= mem_i_data;
					mem_o_data                      <= mem_i_data after 1 ns;
				else
					mem_o_data <= RAM(conv_integer(mem_address)) after 1 ns;
				end if;
			elsif i ="0001" then
				if mem_we = '1' then
					RAM1(conv_integer(mem_address))  <= mem_i_data;
					mem_o_data                      <= mem_i_data after 1 ns;
				else
					mem_o_data <= RAM1(conv_integer(mem_address)) after 1 ns;
				end if;
			elsif i = "0010" then 
				if mem_we = '1' then
					RAM2(conv_integer(mem_address))  <= mem_i_data;
					mem_o_data                      <= mem_i_data after 1 ns;
				else
					mem_o_data <= RAM2(conv_integer(mem_address)) after 1 ns;
				end if;
			elsif i = "0011" then
				if mem_we = '1' then
					RAM3(conv_integer(mem_address))  <= mem_i_data;
					mem_o_data                      <= mem_i_data after 1 ns;
				else
					mem_o_data <= RAM3(conv_integer(mem_address)) after 1 ns;
				end if;
			elsif i ="0100" then
				if mem_we = '1' then
					RAM4(conv_integer(mem_address))  <= mem_i_data;
					mem_o_data                      <= mem_i_data after 1 ns;
				else
					mem_o_data <= RAM4(conv_integer(mem_address)) after 1 ns;
				end if;
			elsif i = "0101" then 
				if mem_we = '1' then
					RAM5(conv_integer(mem_address))  <= mem_i_data;
					mem_o_data                      <= mem_i_data after 1 ns;
				else
					mem_o_data <= RAM5(conv_integer(mem_address)) after 1 ns;
				end if;
			elsif i = "0110" then
				if mem_we = '1' then
					RAM6(conv_integer(mem_address))  <= mem_i_data;
					mem_o_data                      <= mem_i_data after 1 ns;
				else
					mem_o_data <= RAM6(conv_integer(mem_address)) after 1 ns;
				end if;
			elsif i ="0111" then
				if mem_we = '1' then
					RAM7(conv_integer(mem_address))  <= mem_i_data;
					mem_o_data                      <= mem_i_data after 1 ns;
				else
					mem_o_data <= RAM7(conv_integer(mem_address)) after 1 ns;
				end if;
			elsif i = "1000" then 
				if mem_we = '1' then
					RAM8(conv_integer(mem_address))  <= mem_i_data;
					mem_o_data                      <= mem_i_data after 1 ns;
				else
					mem_o_data <= RAM8(conv_integer(mem_address)) after 1 ns;
				end if;
			end if;
    end if;
end if;
end process;


test : process is
begin 
    wait for 100 ns;
    wait for c_CLOCK_PERIOD;
    tb_rst <= '1';
    wait for c_CLOCK_PERIOD;
    wait for 100 ns;
    tb_rst <= '0';
    wait for c_CLOCK_PERIOD;
    wait for 100 ns;
    tb_start <= '1';
    wait for c_CLOCK_PERIOD;
    wait until tb_done = '1';
    wait for c_CLOCK_PERIOD;
    tb_start <= '0';
    wait until tb_done = '0';
    wait for 100 ns;
    i <= "0001";

    
    wait for 100 ns;
    tb_start <= '1';
    wait for c_CLOCK_PERIOD;
    wait until tb_done = '1';
    wait for c_CLOCK_PERIOD;
    tb_start <= '0';
    wait until tb_done = '0';
    wait for 100 ns;
    i <= "0010";

wait for 100 ns;
    tb_start <= '1';
    wait for c_CLOCK_PERIOD;
    wait until tb_done = '1';
    wait for c_CLOCK_PERIOD;
    tb_start <= '0';
    wait until tb_done = '0';
    wait for 100 ns;
    i <= "0011";
	
	wait for 100 ns;
    tb_start <= '1';
    wait for c_CLOCK_PERIOD;
    wait until tb_done = '1';
    wait for c_CLOCK_PERIOD;
    tb_start <= '0';
    wait until tb_done = '0';
    wait for 100 ns;
    i <= "0100";
	
	wait for 100 ns;
    tb_start <= '1';
    wait for c_CLOCK_PERIOD;
    wait until tb_done = '1';
    wait for c_CLOCK_PERIOD;
    tb_start <= '0';
    wait until tb_done = '0';
    wait for 100 ns;
    i <= "0101";
    
		wait for 100 ns;
    tb_start <= '1';
    wait for c_CLOCK_PERIOD;
    wait until tb_done = '1';
    wait for c_CLOCK_PERIOD;
    tb_start <= '0';
    wait until tb_done = '0';
    wait for 100 ns;
    i <= "0110";
	
			wait for 100 ns;
    tb_start <= '1';
    wait for c_CLOCK_PERIOD;
    wait until tb_done = '1';
    wait for c_CLOCK_PERIOD;
    tb_start <= '0';
    wait until tb_done = '0';
    wait for 100 ns;
    i <= "0111";
    
			wait for 100 ns;
    tb_start <= '1';
    wait for c_CLOCK_PERIOD;
    wait until tb_done = '1';
    wait for c_CLOCK_PERIOD;
    tb_start <= '0';
    wait until tb_done = '0';
    wait for 100 ns;
    i <= "1000";
	
				wait for 100 ns;
    tb_start <= '1';
    wait for c_CLOCK_PERIOD;
    wait until tb_done = '1';
    wait for c_CLOCK_PERIOD;
    tb_start <= '0';
    wait until tb_done = '0';
    wait for 100 ns;
    
    --0
	assert RAM(8) = std_logic_vector(to_unsigned( 255 , 8)) report " TEST FALLITO (WORKING ZONE). Expected  255  found " & integer'image(to_integer(unsigned(RAM(6))))  severity failure; 
	assert RAM(9) = std_logic_vector(to_unsigned( 0 , 8)) report " TEST FALLITO (WORKING ZONE). Expected  0  found " & integer'image(to_integer(unsigned(RAM(7))))  severity failure; 
	assert RAM(10) = std_logic_vector(to_unsigned( 1 , 8)) report " TEST FALLITO (WORKING ZONE). Expected  1  found " & integer'image(to_integer(unsigned(RAM(8))))  severity failure; 
	assert RAM(11) = std_logic_vector(to_unsigned( 1 , 8)) report " TEST FALLITO (WORKING ZONE). Expected  1  found " & integer'image(to_integer(unsigned(RAM(9))))  severity failure;
	assert RAM(12) = std_logic_vector(to_unsigned( 0 , 8)) report " TEST FALLITO (WORKING ZONE). Expected  0  found " & integer'image(to_integer(unsigned(RAM(10))))  severity failure; 
	assert RAM(13) = std_logic_vector(to_unsigned( 255 , 8)) report " TEST FALLITO (WORKING ZONE). Expected  255  found " & integer'image(to_integer(unsigned(RAM(11))))  severity failure;
    --1
	assert RAM1(8) = std_logic_vector(to_unsigned( 0 , 8)) report " TEST FALLITO (WORKING ZONE). Expected  0  found " & integer'image(to_integer(unsigned(RAM1(6))))  severity failure; 
	assert RAM1(9) = std_logic_vector(to_unsigned( 0 , 8)) report " TEST FALLITO (WORKING ZONE). Expected  0  found " & integer'image(to_integer(unsigned(RAM1(7))))  severity failure; 
	assert RAM1(10) = std_logic_vector(to_unsigned( 0 , 8)) report " TEST FALLITO (WORKING ZONE). Expected  0  found " & integer'image(to_integer(unsigned(RAM1(8))))  severity failure; 
	assert RAM1(11) = std_logic_vector(to_unsigned( 0 , 8)) report " TEST FALLITO (WORKING ZONE). Expected  0  found " & integer'image(to_integer(unsigned(RAM1(9))))  severity failure;
	assert RAM1(12) = std_logic_vector(to_unsigned( 0 , 8)) report " TEST FALLITO (WORKING ZONE). Expected  0  found " & integer'image(to_integer(unsigned(RAM1(10))))  severity failure; 
	assert RAM1(13) = std_logic_vector(to_unsigned( 0 , 8)) report " TEST FALLITO (WORKING ZONE). Expected  0  found " & integer'image(to_integer(unsigned(RAM1(11))))  severity failure;
    --2
	assert RAM2(8) = std_logic_vector(to_unsigned( 0 , 8)) report " TEST FALLITO (WORKING ZONE). Expected  0  found " & integer'image(to_integer(unsigned(RAM2(6))))  severity failure; 
	assert RAM2(9) = std_logic_vector(to_unsigned( 0 , 8)) report " TEST FALLITO (WORKING ZONE). Expected  0  found " & integer'image(to_integer(unsigned(RAM2(7))))  severity failure; 
	assert RAM2(10) = std_logic_vector(to_unsigned( 0 , 8)) report " TEST FALLITO (WORKING ZONE). Expected  0  found " & integer'image(to_integer(unsigned(RAM2(8))))  severity failure; 
	assert RAM2(11) = std_logic_vector(to_unsigned( 0 , 8)) report " TEST FALLITO (WORKING ZONE). Expected  0  found " & integer'image(to_integer(unsigned(RAM2(9))))  severity failure;
	assert RAM2(12) = std_logic_vector(to_unsigned( 0 , 8)) report " TEST FALLITO (WORKING ZONE). Expected  0  found " & integer'image(to_integer(unsigned(RAM2(10))))  severity failure; 
	assert RAM2(13) = std_logic_vector(to_unsigned( 0 , 8)) report " TEST FALLITO (WORKING ZONE). Expected  0  found " & integer'image(to_integer(unsigned(RAM2(11))))  severity failure;
    --3
	assert RAM3(8) = std_logic_vector(to_unsigned( 0 , 8)) report " TEST FALLITO (WORKING ZONE). Expected  0  found " & integer'image(to_integer(unsigned(RAM3(6))))  severity failure; 
	assert RAM3(9) = std_logic_vector(to_unsigned( 0 , 8)) report " TEST FALLITO (WORKING ZONE). Expected  0  found " & integer'image(to_integer(unsigned(RAM3(7))))  severity failure; 
	assert RAM3(10) = std_logic_vector(to_unsigned( 0 , 8)) report " TEST FALLITO (WORKING ZONE). Expected  0  found " & integer'image(to_integer(unsigned(RAM3(8))))  severity failure; 
	assert RAM3(11) = std_logic_vector(to_unsigned( 0 , 8)) report " TEST FALLITO (WORKING ZONE). Expected  0  found " & integer'image(to_integer(unsigned(RAM3(9))))  severity failure;
	assert RAM3(12) = std_logic_vector(to_unsigned( 0 , 8)) report " TEST FALLITO (WORKING ZONE). Expected  0  found " & integer'image(to_integer(unsigned(RAM3(10))))  severity failure; 
	assert RAM3(13) = std_logic_vector(to_unsigned( 0 , 8)) report " TEST FALLITO (WORKING ZONE). Expected  0  found " & integer'image(to_integer(unsigned(RAM3(11))))  severity failure;
    --4
	assert RAM4(8) = std_logic_vector(to_unsigned( 255 , 8)) report " TEST FALLITO (WORKING ZONE). Expected  255  found " & integer'image(to_integer(unsigned(RAM2(6))))  severity failure; 
	assert RAM4(9) = std_logic_vector(to_unsigned( 255 , 8)) report " TEST FALLITO (WORKING ZONE). Expected  264  found " & integer'image(to_integer(unsigned(RAM2(7))))  severity failure; 
	assert RAM4(10) = std_logic_vector(to_unsigned( 255 , 8)) report " TEST FALLITO (WORKING ZONE). Expected  255  found " & integer'image(to_integer(unsigned(RAM2(8))))  severity failure; 
	assert RAM4(11) = std_logic_vector(to_unsigned( 2 , 8)) report " TEST FALLITO (WORKING ZONE). Expected  4  found " & integer'image(to_integer(unsigned(RAM2(9))))  severity failure;
	assert RAM4(12) = std_logic_vector(to_unsigned( 2 , 8)) report " TEST FALLITO (WORKING ZONE). Expected  4  found " & integer'image(to_integer(unsigned(RAM(10))))  severity failure; 
	assert RAM4(13) = std_logic_vector(to_unsigned( 0 , 8)) report " TEST FALLITO (WORKING ZONE). Expected  2  found " & integer'image(to_integer(unsigned(RAM(11))))  severity failure;
    --5
    assert RAM6(2) = std_logic_vector(to_unsigned( 110 , 8)) report " TEST FALLITO (WORKING ZONE). Expected  110  found " & integer'image(to_integer(unsigned(RAM2(2))))  severity failure;
	assert RAM5(3) = std_logic_vector(to_unsigned( 115 , 8)) report " TEST FALLITO (WORKING ZONE). Expected  115  found " & integer'image(to_integer(unsigned(RAM2(3))))  severity failure; 
	assert RAM5(4) = std_logic_vector(to_unsigned( 124 , 8)) report " TEST FALLITO (WORKING ZONE). Expected  124  found " & integer'image(to_integer(unsigned(RAM2(4))))  severity failure; 
	assert RAM5(5) = std_logic_vector(to_unsigned( 110 , 8)) report " TEST FALLITO (WORKING ZONE). Expected  110  found " & integer'image(to_integer(unsigned(RAM2(5))))  severity failure;
	assert RAM5(6) = std_logic_vector(to_unsigned( 111 , 8)) report " TEST FALLITO (WORKING ZONE). Expected  111  found " & integer'image(to_integer(unsigned(RAM(6))))  severity failure; 
	assert RAM5(7) = std_logic_vector(to_unsigned( 120 , 8)) report " TEST FALLITO (WORKING ZONE). Expected  120  found " & integer'image(to_integer(unsigned(RAM(7))))  severity failure;
    --6
    assert RAM6(2) = std_logic_vector(to_unsigned( 110 , 8)) report " TEST FALLITO (WORKING ZONE). Expected  110  found " & integer'image(to_integer(unsigned(RAM2(2))))  severity failure;
	assert RAM6(3) = std_logic_vector(to_unsigned( 115 , 8)) report " TEST FALLITO (WORKING ZONE). Expected  115  found " & integer'image(to_integer(unsigned(RAM2(3))))  severity failure; 
	assert RAM6(4) = std_logic_vector(to_unsigned( 125 , 8)) report " TEST FALLITO (WORKING ZONE). Expected  125  found " & integer'image(to_integer(unsigned(RAM2(4))))  severity failure; 
	assert RAM6(5) = std_logic_vector(to_unsigned( 110 , 8)) report " TEST FALLITO (WORKING ZONE). Expected  110  found " & integer'image(to_integer(unsigned(RAM2(5))))  severity failure;
	assert RAM6(6) = std_logic_vector(to_unsigned( 111 , 8)) report " TEST FALLITO (WORKING ZONE). Expected  111  found " & integer'image(to_integer(unsigned(RAM(6))))  severity failure; 
	assert RAM6(7) = std_logic_vector(to_unsigned( 120 , 8)) report " TEST FALLITO (WORKING ZONE). Expected  120  found " & integer'image(to_integer(unsigned(RAM(7))))  severity failure;
    --7
	assert RAM7(8) = std_logic_vector(to_unsigned( 255 , 8)) report " TEST FALLITO (WORKING ZONE). Expected  255  found " & integer'image(to_integer(unsigned(RAM2(6))))  severity failure; 
	assert RAM7(9) = std_logic_vector(to_unsigned( 255 , 8)) report " TEST FALLITO (WORKING ZONE). Expected  255  found " & integer'image(to_integer(unsigned(RAM2(7))))  severity failure; 
	assert RAM7(10) = std_logic_vector(to_unsigned( 0 , 8)) report " TEST FALLITO (WORKING ZONE). Expected  0  found " & integer'image(to_integer(unsigned(RAM2(8))))  severity failure; 
	assert RAM7(11) = std_logic_vector(to_unsigned( 112 , 8)) report " TEST FALLITO (WORKING ZONE). Expected  112  found " & integer'image(to_integer(unsigned(RAM2(9))))  severity failure;
	assert RAM7(12) = std_logic_vector(to_unsigned( 160 , 8)) report " TEST FALLITO (WORKING ZONE). Expected  160  found " & integer'image(to_integer(unsigned(RAM(10))))  severity failure; 
	assert RAM7(13) = std_logic_vector(to_unsigned( 16 , 8)) report " TEST FALLITO (WORKING ZONE). Expected  16  found " & integer'image(to_integer(unsigned(RAM(11))))  severity failure;
    --8
	assert RAM8(8) = std_logic_vector(to_unsigned( 248 , 8)) report " TEST FALLITO (WORKING ZONE). Expected  248  found " & integer'image(to_integer(unsigned(RAM2(6))))  severity failure; 
	assert RAM8(9) = std_logic_vector(to_unsigned( 232 , 8)) report " TEST FALLITO (WORKING ZONE). Expected  232  found " & integer'image(to_integer(unsigned(RAM2(7))))  severity failure; 
	assert RAM8(10) = std_logic_vector(to_unsigned( 0 , 8)) report " TEST FALLITO (WORKING ZONE). Expected  0  found " & integer'image(to_integer(unsigned(RAM2(8))))  severity failure; 
	assert RAM8(11) = std_logic_vector(to_unsigned( 56 , 8)) report " TEST FALLITO (WORKING ZONE). Expected  56  found " & integer'image(to_integer(unsigned(RAM2(9))))  severity failure;
	assert RAM8(12) = std_logic_vector(to_unsigned( 80 , 8)) report " TEST FALLITO (WORKING ZONE). Expected  80  found " & integer'image(to_integer(unsigned(RAM(10))))  severity failure; 
	assert RAM8(13) = std_logic_vector(to_unsigned( 8 , 8)) report " TEST FALLITO (WORKING ZONE). Expected  8  found " & integer'image(to_integer(unsigned(RAM(11))))  severity failure;
   



    assert false report "Simulation Ended! TEST PASSATO" severity failure;
end process test;

end projecttb; 


