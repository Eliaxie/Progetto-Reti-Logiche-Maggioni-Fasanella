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
        done1     : in std_logic; -- as input
        o_address : out std_logic_vector(15 downto 0);
        o_done    : out std_logic;
        start1    : out std_logic; --as output
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
        start1    : in std_logic; --as input
        start2    : out std_logic; --as output
        done1     : out std_logic; -- as output
        done2     : in std_logic -- as input
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
        start2    : in std_logic; --as input
        done2     : out std_logic -- as output       
    );
    
    -- probabilmente servirà un altro componente per determinare la fine di o_address
end component;
-- signal s1r1_load : STD_LOGIC; s1 prefisso sta per stadio 1
-- ...
-- signal s2r1_load : STD_LOGIC;
-- ...

-- type S1 is (S10, S11, S12, S13, ... ); -- S10 è lo stato 0 dello Stadio 1 
-- type S2 is (S20, S21, S22, S23, ...); -- S10 è lo stato 0 dello Stadio 1 

begin
-- port map ...
-- ASF

end Behavioral;
