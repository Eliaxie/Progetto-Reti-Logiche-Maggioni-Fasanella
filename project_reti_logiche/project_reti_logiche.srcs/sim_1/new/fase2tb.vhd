library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;
use IEEE.std_logic_unsigned.ALL;

entity fase2tb is
 -- PORT ( );
end fase2tb;

architecture Behavioral of fase2tb is 
    component project_reti_logiche is 
        port (
            i_clk     : in std_logic;
            i_rst     : in std_logic;
            delta     : in std_logic_vector(7 downto 0); --as input
            shift_level: out std_logic_vector(7 downto 0); -- as output
            start2    : in std_logic; --as input
            start3    : out std_logic; --as output
            done2     : out std_logic; -- as output
            done3     : in std_logic -- as input
        );
    end component;

signal i_clk     : std_logic;
signal i_rst     : std_logic;
signal f2r1_load : std_logic;
signal f2r2_load : std_logic;
signal delta     : std_logic_vector(7 downto 0);
signal shift_level:  std_logic_vector(7 downto 0); 
signal start2    : std_logic; 
signal start3    : std_logic; 
signal done2     : std_logic;
signal done3     : std_logic; 
signal o_f2r1    : std_logic_vector(7 downto 0);
signal o_f2r2    : std_logic_vector(3 downto 0);
signal o_LUT    : std_logic_vector(3 downto 0);
signal o_SUB    : std_logic_vector(3 downto 0);


begin
    TOP0: project_reti_logiche port map(
    i_clk => i_clk,
    i_rst => i_rst,
    start2 => start2,
    start3 => start3,
    done2 => done2,
    done3 => done3,
    delta => delta,
    shift_level=> shift_level
    );
    
    delta <= "00101010";
    
    process 
    begin
        wait for 10 ns;
        i_clk <= '1';
        wait for 10 ns;
        i_clk <= '0';
    end process;
    
    process
    begin
        start2 <= '0';
        i_rst <= '1';
        wait for 10 ns;
        i_rst <= '0';
        wait for 20 ns;
        start2 <= '1';
        wait for 20 ns;
        start2 <= '0';
        wait for 200 ns;
        assert false report "simulation ended" severity failure;
    end process;

end Behavioral;