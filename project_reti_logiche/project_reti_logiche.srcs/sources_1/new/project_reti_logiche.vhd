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
use ieee.std_logic_unsigned.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

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
        minV      : out std_logic_vector(7 downto 0); --as output
        delta     : out std_logic_vector(7 downto 0); --as output
        maxaddress : out std_logic_vector(7 downto 0) --as output
    );
end component;
component stadio2DataPath is 
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
component stadio3DataPath is 
    port (
        i_clk     : in std_logic;
        i_rst     : in std_logic;
        i_data    : in std_logic_vector(7 downto 0);
        delta     : in std_logic_vector(7 downto 0); --as input
        o_address : out std_logic_vector(15 downto 0);
        o_data    : out std_logic_vector (7 downto 0);
        o_en      : out std_logic;
        o_we      : out std_logic;
        minV      : in std_logic_vector(7 downto 0); --as input
        shift_level: in std_logic_vector(7 downto 0); -- as input
        start3    : in std_logic; --as input
        done3     : out std_logic; -- as output       
        maxaddress : in std_logic_vector(7 downto 0) -- as input
    );
    
    -- probabilmente servirà un altro componente per determinare la fine di o_address
end component;
-- signal f1r1_load : STD_LOGIC; f1 prefisso sta per fase 1
-- ...
--##SEGNALI FASE 1
signal REGAddr: std_logic_vector(15 downto 0);
signal MAXPixel: std_logic_vector(7 downto 0);
signal MINPixel: std_logic_vector(7 downto 0);
signal Pixel: std_logic_vector(7 downto 0);
signal flagMIN  : std_logic;
signal flagMAX  : std_logic;
signal f  : std_logic;
signal f1  : std_logic;
signal Sum: std_logic_vector(15 downto 0);
signal OP1: std_logic_vector(7 downto 0);
signal OP2: std_logic_vector(7 downto 0);
signal M: std_logic_vector(7 downto 0);
signal minV: std_logic_vector(7 downto 0);
signal maxaddress: std_logic_vector(7 downto 0);


--##SEGNALI FASE 2
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

--##SEGNALI FASE 3
signal f3r1_load : std_logic;
signal f3r2_load : std_logic;
signal f3r3_load : std_logic;
signal f3r4_load : std_logic;
signal f3r5_load : std_logic;
signal f3r6_load : std_logic;
signal f3r7_load : std_logic;
signal o_f3r1 : std_logic_vector(7 downto 0);
signal o_f3r2 : std_logic_vector(7 downto 0);
signal o_f3r3 : std_logic_vector(7 downto 0);
signal o_f3r4 : std_logic_vector(7 downto 0);
signal o_f3r5 : std_logic_vector(7 downto 0);
signal o_f3r6 : std_logic_vector(7 downto 0);
signal o_f3r7 : std_logic_vector(7 downto 0);
signal o_f3s1 : std_logic;
signal o_f3sub : std_logic_vector(7 downto 0);
signal o_f3shift : std_logic_vector(7 downto 0);
signal o_f3mutex : std_logic_vector(7 downto 0);


-- type S1 is (S10, S11, S12, S13, ... ); -- S10 è lo stato 0 dello  1 
type State is (F1S0,F1S1,F1S2,F1S3,F1S4,F1S5,F1S6,F1S7);
signal current_state_s1: State; 
signal next_state_s1: State; 

type S2 is (F2S0, F2S1, F2S2, F2S3, F2S4, F2S5, F2S6, F2S7); -- F2S0 è lo stato 0 della fase 2 
signal cur_state_S2, next_state_S2 : S2;

type S3 is (F3S0, F3S1, F3S1b, F3S2, F3S6, F3S7, F3S8, F3S9, F3S10, F3S11); -- F2S0 è lo stato 0 della fase 2 
signal cur_state_S3, next_state_S3 : S3;

-- type F is (F0, F1, F2, F3);
-- signal cur_fase, next_fase : F;
begin
-- port map
--    DATAPATH1: stadio1DataPath port map(
--        i_data => i_data,
--        i_start => i_start,
--        i_clk => i_clk,
--        i_rst => i_rst,
--        delta => delta,
--        start2 => start2,
--        done2 => done2,
--        maxaddress => maxaddress,
--        minV => minV,
--        o_en => o_en
--     );  
--    DATAPATH2: stadio2DataPath port map(
--        i_clk => i_clk,
--        i_rst => i_rst,
--        delta => delta,
--        shift_level => shift_level,
--        start2 => start2,
--        start3 => start3,
--        done2 => done2,
--        done3 => done3
--    );
    
 -- ## FASE 1
    
Sum<=REGAddr+"0000000000000001"; -- Somma al Contatore
f<='1' when REGAddr>="0000000000000001" else '0';    -- segnale f: indica che termina lettura di num righe e num colonne
f1<='1' when REGAddr>=M+"00000010" else '0';    -- segnale f1: indica se sono stati passati tutti gli indirizzi

flagMIN <= '1' when Pixel < MINPixel  else '0' ; -- =1 se il valore letto è minimo
flagMAX <= '1' when Pixel > MAXPixel else '0' ; -- =1 se il valore letto è massimo

--Ogni clock controlla se reset=1 (inizio)
 process(i_clk,i_rst)
    begin
    if(i_rst='1') then 
          current_state_s1<=F1S0;
         
    elsif (rising_edge (i_clk)) then 
    current_state_s1<=next_state_s1;
    end if;
    end process;
        
--FSM

 process(current_state_s1,i_start)
    begin   
    next_state_s1<=current_state_s1;    
    case current_state_s1 is
            when F1S0 =>
          if(i_start='1') then
            next_state_s1<=F1S1;
          else
            next_state_s1<=F1S0;
          end if;
        when F1S1 =>
          next_state_s1<=F1S2;
        when F1S2 =>
          if (f='0') then 
            next_state_s1<=F1S1;
          else 
            next_state_s1<=F1S3;
          end if;
        when F1S3 =>
            next_state_s1<=F1S4;
        when F1S4 =>
            next_state_s1<=F1S5;
        when F1S5 => 
            if(f1='1') then
                next_state_s1<=F1S6;
            else 
                next_state_s1<=F1S4;
            end if;
        when F1S6 => 
            next_state_s1<=F1S7;
        when F1S7 => 
            if(done2='1') then
                next_state_s1<=F1S0;
                o_done<='1';
            else 
                next_state_s1<=F1S7;
            end if;  
    end case;
  end process;
    
    
    -- Operazioni
     process(current_state_s1)
    begin
       MinPixel<="11111111";
       MaxPixel<="00000000";
       REGAddr<= "0000000000000000";     
       M<="00000000";
       minV<=MINPixel;
  
    case current_state_s1 is
    
       --Stato 0
    when F1S0 =>
        
       REGAddr<= "0000000000000000";     
       o_en<='1';
       MinPixel<="11111111";
       MaxPixel<="00000000";        
       maxaddress<="00000000"; 
      
       
      --Stato 1  
        when F1S1 =>
         REGAddr<= REGAddr;
         o_address <= REGAddr;
         Pixel<=i_data;
        
     --Stato 2
        when F1S2 =>
        REGAddr<= Sum;
       o_address <= Sum;
       Pixel<=i_data;
      if(f='0') then
         OP1 <= std_logic_vector(RESIZE(unsigned(i_data), OP1'LENGTH));
         else
          OP2 <= std_logic_vector(RESIZE(unsigned(i_data), OP2'LENGTH));
        end if;
       
       --Stato 3 
        when F1S3 =>
      REGAddr<= REGAddr;
       o_address <= REGAddr;
       Pixel<=i_data;
       M<=std_logic_vector(RESIZE(unsigned(OP1*OP2), M'LENGTH));
       
       
       --Stato 4
        when F1S4 =>
        M<=M;
        REGAddr<= REGAddr;
        o_address <= REGAddr;
         Pixel<=i_data;
         MINPixel<= MINPixel;
         MAXPixel<=MAXPixel;
      
       --Stato 5
    when F1S5 => 
    M<=M;
    MINPixel<= MINPixel;
    MAXPixel<=MAXPixel;
    REGAddr<= Sum;
     o_address <= Sum;
     Pixel<=i_data;
       
      if(flagMIN = '1') then
      MINPixel<=Pixel;
      end if;
    
    if(flagMAX = '1') then
      MAXPixel<=Pixel;
      end if;
    
    when F1S6 =>
    MINPixel<= MINPixel;
    MAXPixel<=MAXPixel;
    M<=M;
    delta<=MAXPixel-MINPixel;
    start2<='1';
    REGADDR<="0000000000000000";
    o_address<="0000000000000000";
    maxaddress <= M;
    minV<=MINPixel;
    
   when F1S7 =>
    start2<='0';
    MINPixel<= MINPixel;
    MAXPixel<=MAXPixel;
    M<=M;
    delta<=MAXPixel-MINPixel;
    REGADDR<="0000000000000000";
    o_address<="0000000000000000";
    maxaddress <= M;
    minV<=MINPixel;
        
        end case;
    end process;
    
  --##FASE 2
    process(i_clk, i_rst)
    begin
        if(i_rst = '1') then
            cur_state_S2 <= F2S0;
        elsif i_clk'event and i_clk = '1' then
            cur_state_S2 <= next_state_S2;
        end if;
    end process;

    process(cur_state_S2, done3, start2) -- AUTOMA A STATI DELLA SECONDA FASE
    begin
        next_state_S2 <= cur_state_S2;
        case cur_state_S2 is 
            when F2S0 =>
                if start2='1' then
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
                    next_state_s2 <= F2S6;
            when F2S6 =>
                if done3='1' then
                    next_state_s2 <= F2S7;
                else
                    next_state_s2 <= F2S6;
                end if;
            when F2S7 =>
                    next_state_s2 <= F2S0;
        end case;
    end process;
    
    process(cur_state_S2)
    begin
    f2r1_load <= '0';
    done2 <= '0';
    f2r2_load <= '0';
    start3 <= '0';
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
            when F2S7 =>
                done2 <= '1';
        end case;
    end process;
     
    process (i_clk, i_rst)
    begin
        if (i_rst = '1') then
            o_f2r1 <= "00000000";
        elsif i_clk' event and i_clk = '1' then
            if (f2r1_load = '1') then
                o_f2r1 <= delta;
            end if;
        end if;
    end process;
    
    process (i_clk, o_f2r1)
    begin
        if (i_clk' event and i_clk = '1') then
            CASE o_f2r1 IS
                WHEN "00000000" =>
                o_LUT <= "0000";
                WHEN "00000001" =>
                o_LUT <= "0001";
                WHEN "00000010" =>
                o_LUT <= "0001";
                WHEN "00000011" =>
                o_LUT <= "0010";
                WHEN "00000100" =>
                o_LUT <= "0010";
                WHEN "00000101" =>
                o_LUT <= "0010";
                WHEN "00000110" =>
                o_LUT <= "0010";
                WHEN "00000111" =>
                o_LUT <= "0011";
                WHEN "00001000" =>
                o_LUT <= "0011";
                WHEN "00001001" =>
                o_LUT <= "0011";
                WHEN "00001010" =>
                o_LUT <= "0011";
                WHEN "00001011" =>
                o_LUT <= "0011";
                WHEN "00001100" =>
                o_LUT <= "0011";
                WHEN "00001101" =>
                o_LUT <= "0011";
                WHEN "00001110" =>
                o_LUT <= "0011";
                WHEN "00001111" =>
                o_LUT <= "0100";
                WHEN "00010000" =>
                o_LUT <= "0100";
                WHEN "00010001" =>
                o_LUT <= "0100";
                WHEN "00010010" =>
                o_LUT <= "0100";
                WHEN "00010011" =>
                o_LUT <= "0100";
                WHEN "00010100" =>
                o_LUT <= "0100";
                WHEN "00010101" =>
                o_LUT <= "0100";
                WHEN "00010110" =>
                o_LUT <= "0100";
                WHEN "00010111" =>
                o_LUT <= "0100";
                WHEN "00011000" =>
                o_LUT <= "0100";
                WHEN "00011001" =>
                o_LUT <= "0100";
                WHEN "00011010" =>
                o_LUT <= "0100";
                WHEN "00011011" =>
                o_LUT <= "0100";
                WHEN "00011100" =>
                o_LUT <= "0100";
                WHEN "00011101" =>
                o_LUT <= "0100";
                WHEN "00011110" =>
                o_LUT <= "0100";
                WHEN "00011111" =>
                o_LUT <= "0101";
                WHEN "00100000" =>
                o_LUT <= "0101";
                WHEN "00100001" =>
                o_LUT <= "0101";
                WHEN "00100010" =>
                o_LUT <= "0101";
                WHEN "00100011" =>
                o_LUT <= "0101";
                WHEN "00100100" =>
                o_LUT <= "0101";
                WHEN "00100101" =>
                o_LUT <= "0101";
                WHEN "00100110" =>
                o_LUT <= "0101";
                WHEN "00100111" =>
                o_LUT <= "0101";
                WHEN "00101000" =>
                o_LUT <= "0101";
                WHEN "00101001" =>
                o_LUT <= "0101";
                WHEN "00101010" =>
                o_LUT <= "0101";
                WHEN "00101011" =>
                o_LUT <= "0101";
                WHEN "00101100" =>
                o_LUT <= "0101";
                WHEN "00101101" =>
                o_LUT <= "0101";
                WHEN "00101110" =>
                o_LUT <= "0101";
                WHEN "00101111" =>
                o_LUT <= "0101";
                WHEN "00110000" =>
                o_LUT <= "0101";
                WHEN "00110001" =>
                o_LUT <= "0101";
                WHEN "00110010" =>
                o_LUT <= "0101";
                WHEN "00110011" =>
                o_LUT <= "0101";
                WHEN "00110100" =>
                o_LUT <= "0101";
                WHEN "00110101" =>
                o_LUT <= "0101";
                WHEN "00110110" =>
                o_LUT <= "0101";
                WHEN "00110111" =>
                o_LUT <= "0101";
                WHEN "00111000" =>
                o_LUT <= "0101";
                WHEN "00111001" =>
                o_LUT <= "0101";
                WHEN "00111010" =>
                o_LUT <= "0101";
                WHEN "00111011" =>
                o_LUT <= "0101";
                WHEN "00111100" =>
                o_LUT <= "0101";
                WHEN "00111101" =>
                o_LUT <= "0101";
                WHEN "00111110" =>
                o_LUT <= "0101";
                WHEN "00111111" =>
                o_LUT <= "0110";
                WHEN "01000000" =>
                o_LUT <= "0110";
                WHEN "01000001" =>
                o_LUT <= "0110";
                WHEN "01000010" =>
                o_LUT <= "0110";
                WHEN "01000011" =>
                o_LUT <= "0110";
                WHEN "01000100" =>
                o_LUT <= "0110";
                WHEN "01000101" =>
                o_LUT <= "0110";
                WHEN "01000110" =>
                o_LUT <= "0110";
                WHEN "01000111" =>
                o_LUT <= "0110";
                WHEN "01001000" =>
                o_LUT <= "0110";
                WHEN "01001001" =>
                o_LUT <= "0110";
                WHEN "01001010" =>
                o_LUT <= "0110";
                WHEN "01001011" =>
                o_LUT <= "0110";
                WHEN "01001100" =>
                o_LUT <= "0110";
                WHEN "01001101" =>
                o_LUT <= "0110";
                WHEN "01001110" =>
                o_LUT <= "0110";
                WHEN "01001111" =>
                o_LUT <= "0110";
                WHEN "01010000" =>
                o_LUT <= "0110";
                WHEN "01010001" =>
                o_LUT <= "0110";
                WHEN "01010010" =>
                o_LUT <= "0110";
                WHEN "01010011" =>
                o_LUT <= "0110";
                WHEN "01010100" =>
                o_LUT <= "0110";
                WHEN "01010101" =>
                o_LUT <= "0110";
                WHEN "01010110" =>
                o_LUT <= "0110";
                WHEN "01010111" =>
                o_LUT <= "0110";
                WHEN "01011000" =>
                o_LUT <= "0110";
                WHEN "01011001" =>
                o_LUT <= "0110";
                WHEN "01011010" =>
                o_LUT <= "0110";
                WHEN "01011011" =>
                o_LUT <= "0110";
                WHEN "01011100" =>
                o_LUT <= "0110";
                WHEN "01011101" =>
                o_LUT <= "0110";
                WHEN "01011110" =>
                o_LUT <= "0110";
                WHEN "01011111" =>
                o_LUT <= "0110";
                WHEN "01100000" =>
                o_LUT <= "0110";
                WHEN "01100001" =>
                o_LUT <= "0110";
                WHEN "01100010" =>
                o_LUT <= "0110";
                WHEN "01100011" =>
                o_LUT <= "0110";
                WHEN "01100100" =>
                o_LUT <= "0110";
                WHEN "01100101" =>
                o_LUT <= "0110";
                WHEN "01100110" =>
                o_LUT <= "0110";
                WHEN "01100111" =>
                o_LUT <= "0110";
                WHEN "01101000" =>
                o_LUT <= "0110";
                WHEN "01101001" =>
                o_LUT <= "0110";
                WHEN "01101010" =>
                o_LUT <= "0110";
                WHEN "01101011" =>
                o_LUT <= "0110";
                WHEN "01101100" =>
                o_LUT <= "0110";
                WHEN "01101101" =>
                o_LUT <= "0110";
                WHEN "01101110" =>
                o_LUT <= "0110";
                WHEN "01101111" =>
                o_LUT <= "0110";
                WHEN "01110000" =>
                o_LUT <= "0110";
                WHEN "01110001" =>
                o_LUT <= "0110";
                WHEN "01110010" =>
                o_LUT <= "0110";
                WHEN "01110011" =>
                o_LUT <= "0110";
                WHEN "01110100" =>
                o_LUT <= "0110";
                WHEN "01110101" =>
                o_LUT <= "0110";
                WHEN "01110110" =>
                o_LUT <= "0110";
                WHEN "01110111" =>
                o_LUT <= "0110";
                WHEN "01111000" =>
                o_LUT <= "0110";
                WHEN "01111001" =>
                o_LUT <= "0110";
                WHEN "01111010" =>
                o_LUT <= "0110";
                WHEN "01111011" =>
                o_LUT <= "0110";
                WHEN "01111100" =>
                o_LUT <= "0110";
                WHEN "01111101" =>
                o_LUT <= "0110";
                WHEN "01111110" =>
                o_LUT <= "0110";
                WHEN "01111111" =>
                o_LUT <= "0111";
                WHEN "10000000" =>
                o_LUT <= "0111";
                WHEN "10000001" =>
                o_LUT <= "0111";
                WHEN "10000010" =>
                o_LUT <= "0111";
                WHEN "10000011" =>
                o_LUT <= "0111";
                WHEN "10000100" =>
                o_LUT <= "0111";
                WHEN "10000101" =>
                o_LUT <= "0111";
                WHEN "10000110" =>
                o_LUT <= "0111";
                WHEN "10000111" =>
                o_LUT <= "0111";
                WHEN "10001000" =>
                o_LUT <= "0111";
                WHEN "10001001" =>
                o_LUT <= "0111";
                WHEN "10001010" =>
                o_LUT <= "0111";
                WHEN "10001011" =>
                o_LUT <= "0111";
                WHEN "10001100" =>
                o_LUT <= "0111";
                WHEN "10001101" =>
                o_LUT <= "0111";
                WHEN "10001110" =>
                o_LUT <= "0111";
                WHEN "10001111" =>
                o_LUT <= "0111";
                WHEN "10010000" =>
                o_LUT <= "0111";
                WHEN "10010001" =>
                o_LUT <= "0111";
                WHEN "10010010" =>
                o_LUT <= "0111";
                WHEN "10010011" =>
                o_LUT <= "0111";
                WHEN "10010100" =>
                o_LUT <= "0111";
                WHEN "10010101" =>
                o_LUT <= "0111";
                WHEN "10010110" =>
                o_LUT <= "0111";
                WHEN "10010111" =>
                o_LUT <= "0111";
                WHEN "10011000" =>
                o_LUT <= "0111";
                WHEN "10011001" =>
                o_LUT <= "0111";
                WHEN "10011010" =>
                o_LUT <= "0111";
                WHEN "10011011" =>
                o_LUT <= "0111";
                WHEN "10011100" =>
                o_LUT <= "0111";
                WHEN "10011101" =>
                o_LUT <= "0111";
                WHEN "10011110" =>
                o_LUT <= "0111";
                WHEN "10011111" =>
                o_LUT <= "0111";
                WHEN "10100000" =>
                o_LUT <= "0111";
                WHEN "10100001" =>
                o_LUT <= "0111";
                WHEN "10100010" =>
                o_LUT <= "0111";
                WHEN "10100011" =>
                o_LUT <= "0111";
                WHEN "10100100" =>
                o_LUT <= "0111";
                WHEN "10100101" =>
                o_LUT <= "0111";
                WHEN "10100110" =>
                o_LUT <= "0111";
                WHEN "10100111" =>
                o_LUT <= "0111";
                WHEN "10101000" =>
                o_LUT <= "0111";
                WHEN "10101001" =>
                o_LUT <= "0111";
                WHEN "10101010" =>
                o_LUT <= "0111";
                WHEN "10101011" =>
                o_LUT <= "0111";
                WHEN "10101100" =>
                o_LUT <= "0111";
                WHEN "10101101" =>
                o_LUT <= "0111";
                WHEN "10101110" =>
                o_LUT <= "0111";
                WHEN "10101111" =>
                o_LUT <= "0111";
                WHEN "10110000" =>
                o_LUT <= "0111";
                WHEN "10110001" =>
                o_LUT <= "0111";
                WHEN "10110010" =>
                o_LUT <= "0111";
                WHEN "10110011" =>
                o_LUT <= "0111";
                WHEN "10110100" =>
                o_LUT <= "0111";
                WHEN "10110101" =>
                o_LUT <= "0111";
                WHEN "10110110" =>
                o_LUT <= "0111";
                WHEN "10110111" =>
                o_LUT <= "0111";
                WHEN "10111000" =>
                o_LUT <= "0111";
                WHEN "10111001" =>
                o_LUT <= "0111";
                WHEN "10111010" =>
                o_LUT <= "0111";
                WHEN "10111011" =>
                o_LUT <= "0111";
                WHEN "10111100" =>
                o_LUT <= "0111";
                WHEN "10111101" =>
                o_LUT <= "0111";
                WHEN "10111110" =>
                o_LUT <= "0111";
                WHEN "10111111" =>
                o_LUT <= "0111";
                WHEN "11000000" =>
                o_LUT <= "0111";
                WHEN "11000001" =>
                o_LUT <= "0111";
                WHEN "11000010" =>
                o_LUT <= "0111";
                WHEN "11000011" =>
                o_LUT <= "0111";
                WHEN "11000100" =>
                o_LUT <= "0111";
                WHEN "11000101" =>
                o_LUT <= "0111";
                WHEN "11000110" =>
                o_LUT <= "0111";
                WHEN "11000111" =>
                o_LUT <= "0111";
                WHEN "11001000" =>
                o_LUT <= "0111";
                WHEN "11001001" =>
                o_LUT <= "0111";
                WHEN "11001010" =>
                o_LUT <= "0111";
                WHEN "11001011" =>
                o_LUT <= "0111";
                WHEN "11001100" =>
                o_LUT <= "0111";
                WHEN "11001101" =>
                o_LUT <= "0111";
                WHEN "11001110" =>
                o_LUT <= "0111";
                WHEN "11001111" =>
                o_LUT <= "0111";
                WHEN "11010000" =>
                o_LUT <= "0111";
                WHEN "11010001" =>
                o_LUT <= "0111";
                WHEN "11010010" =>
                o_LUT <= "0111";
                WHEN "11010011" =>
                o_LUT <= "0111";
                WHEN "11010100" =>
                o_LUT <= "0111";
                WHEN "11010101" =>
                o_LUT <= "0111";
                WHEN "11010110" =>
                o_LUT <= "0111";
                WHEN "11010111" =>
                o_LUT <= "0111";
                WHEN "11011000" =>
                o_LUT <= "0111";
                WHEN "11011001" =>
                o_LUT <= "0111";
                WHEN "11011010" =>
                o_LUT <= "0111";
                WHEN "11011011" =>
                o_LUT <= "0111";
                WHEN "11011100" =>
                o_LUT <= "0111";
                WHEN "11011101" =>
                o_LUT <= "0111";
                WHEN "11011110" =>
                o_LUT <= "0111";
                WHEN "11011111" =>
                o_LUT <= "0111";
                WHEN "11100000" =>
                o_LUT <= "0111";
                WHEN "11100001" =>
                o_LUT <= "0111";
                WHEN "11100010" =>
                o_LUT <= "0111";
                WHEN "11100011" =>
                o_LUT <= "0111";
                WHEN "11100100" =>
                o_LUT <= "0111";
                WHEN "11100101" =>
                o_LUT <= "0111";
                WHEN "11100110" =>
                o_LUT <= "0111";
                WHEN "11100111" =>
                o_LUT <= "0111";
                WHEN "11101000" =>
                o_LUT <= "0111";
                WHEN "11101001" =>
                o_LUT <= "0111";
                WHEN "11101010" =>
                o_LUT <= "0111";
                WHEN "11101011" =>
                o_LUT <= "0111";
                WHEN "11101100" =>
                o_LUT <= "0111";
                WHEN "11101101" =>
                o_LUT <= "0111";
                WHEN "11101110" =>
                o_LUT <= "0111";
                WHEN "11101111" =>
                o_LUT <= "0111";
                WHEN "11110000" =>
                o_LUT <= "0111";
                WHEN "11110001" =>
                o_LUT <= "0111";
                WHEN "11110010" =>
                o_LUT <= "0111";
                WHEN "11110011" =>
                o_LUT <= "0111";
                WHEN "11110100" =>
                o_LUT <= "0111";
                WHEN "11110101" =>
                o_LUT <= "0111";
                WHEN "11110110" =>
                o_LUT <= "0111";
                WHEN "11110111" =>
                o_LUT <= "0111";
                WHEN "11111000" =>
                o_LUT <= "0111";
                WHEN "11111001" =>
                o_LUT <= "0111";
                WHEN "11111010" =>
                o_LUT <= "0111";
                WHEN "11111011" =>
                o_LUT <= "0111";
                WHEN "11111100" =>
                o_LUT <= "0111";
                WHEN "11111101" =>
                o_LUT <= "0111";
                WHEN "11111110" =>
                o_LUT <= "0111";
                WHEN "11111111" =>
                o_LUT <= "1111";
                when others => null; 
            END CASE;
        end if;
    end process;
    
    o_SUB <= "1000" - o_LUT;  
    
    process (i_clk, i_rst)
    begin
        if (i_rst = '1') then
            o_f2r2 <= "0000";
        elsif i_clk' event and i_clk = '1' then
            if (f2r2_load = '1') then
                o_f2r2 <= o_SUB;
            end if;
        end if;
    end process;
    shift_level <= "0000" & o_f2r2;    
    
    --# FASE 3
    
    process(cur_state_S3, start3) -- AUTOMA A STATI DELLA SECONDA FASE
    begin
        next_state_S3 <= cur_state_S3;
        case cur_state_S3 is 
            when F3S0 =>
                if start3='1' then
                    next_state_S3 <= F3S1;
                end if;
            when F3S1 =>
                    next_state_S3 <= F3S1b;
            when F3S1b =>
                    next_state_S3 <= F3S2;        
            when F3s2 =>
                    next_state_S3 <= F3S6;
            when F3S6 =>
                    next_state_S3 <= F3S6;
            when F3S7 =>
                    next_state_S3 <= F3S8;
            when F3S8 =>
                    next_state_S3 <= F3S9;
            when F3S9 =>
                    next_state_S3 <= F3S10;
            when F3S10 =>
                    if(o_f3r7 <= maxaddress) then
                        next_state_S3 <= F3S1;
                    else
                        next_state_S3 <= F3S11;
                    end if;
            when F3S11 =>
                    next_state_S3 <= F3S0;
        end case;
    end process;
    
    process(cur_state_S3)
    begin
    f3r1_load <= '0';
    f3r2_load <= '0';
    f3r3_load <= '0';
    f3r4_load <= '0';
    f3r5_load <= '0';
    f3r6_load <= '0';
    f3r7_load <= '0';
    done3 <= '0';
    o_en <= '1';
    o_we <= '1';
        case cur_state_S3 is 
            when F3S0 =>
                o_f3r7 <= "00000010";
                -- f3r1_load <= '1';
            when F3S1 =>
                f3r1_load <= '1';
                f3r2_load <= '1';
                f3r3_load <= '1';
                f3r4_load <= '1';
                f3r7_load <= '1';
            when F3S1b =>
            when F3S2 =>
                f3r5_load <= '1';
            when F3S6 =>
            when F3S7 =>
            when F3S8 =>
                f3r6_load <= '1';
                f3r7_load <= '1';
            when F3S9 =>
                o_we <= '1';
                o_en <= '1';
            when F3S10 =>
            when F3S11 =>
                done3<='1';
        end case;
    end process;
    
    -- /* PARTE COMPUTAZIONALE */
    process (i_clk, i_rst)
    begin
        if (i_rst = '1') then
            o_f3r1 <= "00000000";
            o_f3r2 <= "00000000";
            o_f3r3 <= "00000000";
            o_f3r4 <= "00000000";
            o_f3r5 <= "00000000";
            o_f3r6 <= "00000000";
            o_f3r7 <= "00000000";
            cur_state_S3 <= F3S0;
        elsif i_clk' event and i_clk = '1' then
            cur_state_S3 <= next_state_S3;
            if (f3r1_load = '1') then
                o_f3r1 <= shift_level;
            end if;
            if (f3r3_load = '1') then
                o_en <= '1';
                o_address <= "00000000" & o_f3r7;
                o_f3r2 <= i_data;
            end if;
            if (f3r2_load = '1') then
                o_f3r3 <= minV;
            end if;
            if (f3r4_load = '1') then
                o_f3r4 <= maxaddress;
            end if;
            if (f3r5_load = '1') then
                o_f3r5 <= o_f3sub;
            end if;
            if (f3r6_load = '1') then
                o_f3r6 <= o_f3mutex;
            end if;
            if (f3r7_load = '1') then
                o_f3r7 <= o_f3r7 + 1;
            end if;
        end if;
    end process;
    
    process(i_clk, O_f3r5) -- SHIFT
    begin
        o_f3shift <= std_logic_vector(shift_left(unsigned(o_f3r5), TO_INTEGER(unsigned(shift_level))));
    end process;
    
    process(i_clk, O_f3r5) -- SOTTRAZIONE
    begin
        o_f3sub <= o_f3r3 - o_f3r2;
    end process;
    
    process(i_clk, O_f3r5) -- MUTEX
    begin
        if ( o_f3shift > o_f3r5) then
            o_f3s1 <= '1';
        else
            o_f3s1 <= '0';
        end if;
        if ( o_f3s1 = '1') then
            o_f3mutex <= o_f3shift;
        else
            o_f3mutex <= "11111111";
        end if;
    end process;
    
    process(i_clk, O_f3r6) -- DATA USCITA
    begin
        o_address <= "00000000" & o_f3r7;
        o_data <= o_f3r6;
    end process;
        
end Behavioral;



