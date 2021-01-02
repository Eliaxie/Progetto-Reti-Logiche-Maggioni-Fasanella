----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 02.01.2021 12:18:45
-- Design Name: 
-- Module Name: project_reti_logiche - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity project_reti_logiche is
    port (
        i_clk     : in std_logic;
        i_rst     : in std_logic;
        i_start   : in std_logic;
        i_data    : in std_logic_vector(7 downto 0);
        o_address : out std_logic_vector(15 downto 0);
        o_done    : out std_logic;
        o_en      : out std_logic;
        o_we      : out std_logic;
        o_data    : out std_logic_vector (7 downto 0)
    );
end project_reti_logiche;


-- il nome del modulo deve essere project_reti_logiche
-- ?i_clk è il segnale di CLOCK in ingresso generato dal TestBench;
-- ?i_rst è il segnale di RESET che inizializza la macchina pronta per ricevere il primosegnale di START;
-- ?i_start è il segnale di START generato dal Test Bench;
-- ?i_data è il segnale (vettore) che arriva dalla memoria in seguito ad una richiesta dilettura;
-- ?o_address è il segnale (vettore) di uscita che manda l'indirizzo alla memoria;
-- ?o_done è il segnale di uscita che comunica la fine dell'elaborazione e il dato di uscitascritto in memoria;
-- ?o_en è il segnale di ENABLE da dover mandare alla memoria per poter comunicare(sia in lettura che in scrittura);
-- ?o_we è il segnale di WRITE ENABLE da dover mandare alla memoria (=1) per poterscriverci. Per leggere da memoria esso deve essere 0;
-- ?o_data è il segnale (vettore) di uscita dal componente verso la memoria. 

-- Progetto di Elia Maggioni e Marco Fasanella


architecture Behavioral of project_reti_logiche is
component stadio1DataPath is 
    port (
        i_clk     : in std_logic;
        i_rst     : in std_logic;
        i_start   : in std_logic;
        i_data    : in std_logic_vector(7 downto 0);
        done2     : in std_logic; -- as input
        o_address : out std_logic_vector(15 downto 0);
        o_done    : out std_logic;
        start2    : out std_logic; --as output
        o_en      : out std_logic;
        o_we      : out std_logic;
        minV      : out std_logic_vector(7 downto 0); --as output
        delta     : out std_logic_vector(7 downto 0) --as output
    );
end component;
component stadio2DataPath is 
    port (
        i_clk     : in std_logic;
        i_rst     : in std_logic;
        delta     : in std_logic_vector(7 downto 0); --as input
        minV      : in std_logic_vector(7 downto 0); --as input
        shift_level: out std_logic_vector(7 downto 0); -- as output
        start2    : in std_logic; --as input
        start3    : out std_logic; --as output
        done2     : out std_logic; -- as output
        done3     : in std_logic; -- as input
        f2r1_load : in std_logic; --as input
        f2r2_load : in std_logic -- as input
    );
end component;
component stadio3DataPath is 
    port (
        i_clk     : in std_logic;
        i_rst     : in std_logic;
        i_data    : in std_logic_vector(7 downto 0);
        delta     : in std_logic_vector(7 downto 0); --as input
        o_address : out std_logic_vector(15 downto 0);
        o_data    : out std_logic_vector (7 downto 0);
        shift_level: in std_logic_vector(7 downto 0); -- as input
        start3    : in std_logic; --as input
        done3     : out std_logic -- as output       
    );
    
    -- probabilmente servirà un altro componente per determinare la fine di o_address
end component;
-- signal f1r1_load : STD_LOGIC; f1 prefisso sta per fase 1
-- ...
signal f2r1_load : std_logic;
signal f2r2_load : std_logic;
signal delta     : std_logic_vector(7 downto 0);
signal minV      : std_logic_vector(7 downto 0); 
signal shift_level:  std_logic_vector(7 downto 0); 
signal start2    : std_logic; 
signal start3    : std_logic; 
signal done2     : std_logic;
signal done3     : std_logic; 

-- type S1 is (S10, S11, S12, S13, ... ); -- S10 è lo stato 0 dello  1 
type S2 is (F2S0, F2S1, F2S2, F2S3, F2S4, F2S5, F2S6); -- F2S0 è lo stato 0 della fase 2 
signal cur_state_S2, next_state_S2 : S2;
-- type F is (F0, F1, F2, F3);
-- signal cur_fase, next_fase : F;
begin
-- port map
    DATAPATH2: stadio2DataPath port map(
        i_clk => i_clk,
        i_rst => i_rst,
        delta => delta,
        minV => minV,
        shift_level => shift_level,
        start2 => start2,
        start3 => start3,
        done2 => done2,
        done3 => done3,
        f2r1_load => f2r1_load,
        f2r2_load => f2r2_load
    );
    process(i_clk, i_rst)
    begin
        if(i_rst = '1') then
            cur_state_S2 <= F2S0;
        elsif i_clk'event and i_clk = '1' then
            cur_state_S2 <= next_state_S2;
        end if;
    end process;

    process(cur_state_S2, done2, start3) -- AUTOMA A STATI DELLA SECONDA FASE
    begin
        next_state_S2 <= cur_state_S2;
        case cur_state_S2 is 
            when F2S0 =>
                if start3='1' then
                    next_state_s2 <= F2S1;
                end if;
            when F2S1 =>
                    next_state_s2 <= F2S2;
            when F2S2 =>
                    next_state_s2 <= F2S3;
            when F2S3 =>
                    next_state_s2 <= F2S4;
            when F2S4 =>
                    next_state_s2 <= F2S5;
            when F2S5 =>
                if done2='1' then
                    next_state_s2 <= F2S6;
                else
                    next_state_s2 <= F2S5;
                end if;
            when F2S6 =>
                    next_state_s2 <= F2S0;
        end case;
    end process;
    
    process(cur_state_S2)
    begin
    f2r1_load <= '0';
    done2 <= '0';
    f2r2_load <= '0';
        case cur_state_S2 is 
            when F2S0 =>
            when F2S1 =>
                f2r1_load <= '1';
            when F2S2 =>
            when F2S3 =>
            when F2S4 =>
                f2r2_load <= '1';
            when F2S5 =>
                start3 <= '1';
            when F2S6 =>
                done2 <= '1';
        end case;
    end process;
    
end Behavioral;