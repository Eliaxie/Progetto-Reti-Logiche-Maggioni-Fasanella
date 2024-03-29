----------------------------------------------------------------------------------
-- Engineer: Maggioni, Fasanella
-- 
-- Create Date: 09-03-2021
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
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE ieee.std_logic_unsigned.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
USE IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;
ENTITY project_reti_logiche IS
	PORT (
		i_clk : IN STD_LOGIC;
		i_rst : IN STD_LOGIC;
		i_start : IN STD_LOGIC;
		i_data : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
		o_address : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
		o_done : OUT STD_LOGIC;
		o_en : OUT STD_LOGIC;
		o_we : OUT STD_LOGIC;
		o_data : OUT STD_LOGIC_VECTOR (7 DOWNTO 0)
	);
END project_reti_logiche;
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
ARCHITECTURE Behavioral OF project_reti_logiche IS

	COMPONENT stadio1DataPath IS
		PORT (
			i_clk : IN STD_LOGIC;
			i_rst : IN STD_LOGIC;
			i_start : IN STD_LOGIC;
			i_data : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
			done2 : IN STD_LOGIC; -- as input
			o_address : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
			o_done : OUT STD_LOGIC;
			start2 : OUT STD_LOGIC; --as output
			o_en : OUT STD_LOGIC;
			minV : OUT STD_LOGIC_VECTOR(7 DOWNTO 0); --as output
			delta : OUT STD_LOGIC_VECTOR(7 DOWNTO 0); --as output
			maxaddress : OUT STD_LOGIC_VECTOR(15 DOWNTO 0) --as output
		);
	END COMPONENT;
	COMPONENT stadio2DataPath IS
		PORT (
			i_clk : IN STD_LOGIC;
			i_rst : IN STD_LOGIC;
			delta : IN STD_LOGIC_VECTOR(7 DOWNTO 0); --as input
			shift_level : OUT STD_LOGIC_VECTOR(7 DOWNTO 0); -- as output
			start2 : IN STD_LOGIC; --as input
			start3 : OUT STD_LOGIC; --as output
			done2 : OUT STD_LOGIC; -- as output
			done3 : IN STD_LOGIC -- as input
		);
	END COMPONENT;
	COMPONENT stadio3DataPath IS
		PORT (
			i_clk : IN STD_LOGIC;
			i_rst : IN STD_LOGIC;
			i_data : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
			delta : IN STD_LOGIC_VECTOR(7 DOWNTO 0); --as input
			o_address : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
			o_data : OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
			o_en : OUT STD_LOGIC;
			o_we : OUT STD_LOGIC;
			minV : IN STD_LOGIC_VECTOR(7 DOWNTO 0); --as input
			shift_level : IN STD_LOGIC_VECTOR(7 DOWNTO 0); -- as input
			start3 : IN STD_LOGIC; --as input
			done3 : OUT STD_LOGIC; -- as output       
			maxaddress : IN STD_LOGIC_VECTOR(15 DOWNTO 0) -- as input
		);

	END COMPONENT;
	--##SEGNALI FASE 1
	SIGNAL REGAddr : STD_LOGIC_VECTOR(15 DOWNTO 0);
	SIGNAL MAXPixel : STD_LOGIC_VECTOR(7 DOWNTO 0);
	SIGNAL MINPixel : STD_LOGIC_VECTOR(7 DOWNTO 0);
	SIGNAL Pixel : STD_LOGIC_VECTOR(7 DOWNTO 0);
	SIGNAL flagMIN : STD_LOGIC;
	SIGNAL flagMAX : STD_LOGIC;
	SIGNAL f : STD_LOGIC;
	SIGNAL f1 : STD_LOGIC;
	SIGNAL Sum : STD_LOGIC_VECTOR(15 DOWNTO 0);
	SIGNAL OP1 : STD_LOGIC_VECTOR(15 DOWNTO 0);
	SIGNAL OP2 : STD_LOGIC_VECTOR(15 DOWNTO 0);
	SIGNAL M : STD_LOGIC_VECTOR(15 DOWNTO 0);
	SIGNAL minV : STD_LOGIC_VECTOR(7 DOWNTO 0);
	SIGNAL maxaddress : STD_LOGIC_VECTOR(15 DOWNTO 0);
	SIGNAL o_f1s3 : STD_LOGIC;
	SIGNAL o_f1s2 : STD_LOGIC;
	SIGNAL o_op1 : STD_LOGIC;
	SIGNAL o_op2 : STD_LOGIC;
	SIGNAL o_mul : STD_LOGIC;
	SIGNAL o_f1s4 : STD_LOGIC;
	SIGNAL o_f1s5 : STD_LOGIC;
	SIGNAL o_f3addr_read : STD_LOGIC;
	SIGNAL o_f3addr_write : STD_LOGIC;
	SIGNAL o_m : STD_LOGIC; --alto segnale moltiplicazione
	SIGNAL endof : STD_LOGIC; --end of image processing

	--##SEGNALI FASE 2
	SIGNAL f2r1_load : STD_LOGIC;
	SIGNAL f2r2_load : STD_LOGIC;
	SIGNAL delta : STD_LOGIC_VECTOR(7 DOWNTO 0);
	SIGNAL shift_level : STD_LOGIC_VECTOR(7 DOWNTO 0);
	SIGNAL start2 : STD_LOGIC;
	SIGNAL start3 : STD_LOGIC;
	SIGNAL done2 : STD_LOGIC;
	SIGNAL done3 : STD_LOGIC;
	SIGNAL o_f2r1 : STD_LOGIC_VECTOR(7 DOWNTO 0);
	SIGNAL o_f2r2 : STD_LOGIC_VECTOR(3 DOWNTO 0);
	SIGNAL o_LUT : STD_LOGIC_VECTOR(3 DOWNTO 0);
	SIGNAL o_SUB : STD_LOGIC_VECTOR(3 DOWNTO 0);

	--##SEGNALI FASE 3
	SIGNAL f3r1_load : STD_LOGIC;
	SIGNAL f3r2_load : STD_LOGIC;
	SIGNAL f3r3_load : STD_LOGIC;
	SIGNAL f3r4_load : STD_LOGIC;
	SIGNAL f3r5_load : STD_LOGIC;
	SIGNAL f3r6_load : STD_LOGIC;
	SIGNAL f3r7_load : STD_LOGIC;
	SIGNAL o_f3r1 : STD_LOGIC_VECTOR(7 DOWNTO 0);
	SIGNAL o_f3r2 : STD_LOGIC_VECTOR(7 DOWNTO 0);
	SIGNAL o_f3r3 : STD_LOGIC_VECTOR(7 DOWNTO 0);
	SIGNAL o_f3r4 : STD_LOGIC_VECTOR(15 DOWNTO 0);
	SIGNAL o_f3r5 : STD_LOGIC_VECTOR(7 DOWNTO 0);
	SIGNAL o_f3r6 : STD_LOGIC_VECTOR(7 DOWNTO 0);
	SIGNAL o_f3r7 : STD_LOGIC_VECTOR(15 DOWNTO 0);
	SIGNAL o_f3s1 : STD_LOGIC;
	SIGNAL o_f3sub : STD_LOGIC_VECTOR(7 DOWNTO 0);
	SIGNAL o_f3shiftslave : STD_LOGIC_VECTOR(15 DOWNTO 0);
	SIGNAL o_f3shift : STD_LOGIC_VECTOR(15 DOWNTO 0);
	SIGNAL o_f3mutex : STD_LOGIC_VECTOR(7 DOWNTO 0);
	SIGNAL o_wAddress : STD_LOGIC_VECTOR(15 DOWNTO 0);
	SIGNAL o_rAddress : STD_LOGIC_VECTOR(15 DOWNTO 0);

	-- type S1 is (S10, S11, S12, S13, ... ); -- S10 è lo stato 0 dello  1 
	TYPE S1 IS (F1S0, F1S1, F1S2, F1S1b, F1S2b, F1S3, F1S3b, F1S4, F1S4a, F1S5, F1S6, F1S7, F1S8, F1S9);
	SIGNAL cur_state_S1, next_state_s1 : S1;

	TYPE S2 IS (F2S0, F2S1, F2S2, F2S3, F2S4, F2S5, F2S6, F2S7); -- F2S0 è lo stato 0 della fase 2 
	SIGNAL cur_state_S2, next_state_S2 : S2;

	TYPE S3 IS (F3S0, F3S0b, F3S0c, F3S1, F3S2, F3S3, F3S4, F3S5, F3S6, F3S6b, F3S7, F3S7b, F3S8, F3S9); -- F2S0 è lo stato 0 della fase 2 
	SIGNAL cur_state_S3, next_state_S3 : S3;

BEGIN
	-- SIGNALS AND OPERATIONS
	Sum <= REGAddr + "0000000000000001"; -- Somma al Contatore
	MinV <= MINPixel;
	maxaddress <= M; -- Maximum address 
	f <= '1' WHEN REGAddr >= "0000000000000001" ELSE '0'; -- segnale f: indica che termina lettura di num righe e num colonne
	f1 <= '1' WHEN REGAddr > M + "0000000000000010" ELSE '0'; -- segnale f1: indica se sono stati passati tutti gli indirizzi
	delta <= MAXPixel - MINPixel; --delta value
	flagMIN <= '1' WHEN pixel < MINPixel ELSE '0'; -- =1 se il valore letto è minimo
	flagMAX <= '1' WHEN pixel > MAXPixel ELSE '0'; -- =1 se il valore letto è massimo
	o_SUB <= "1000" - o_LUT;
	shift_level <= "0000" & o_f2r2;

	-- /* GENERAL PROCESSES */

	SIGNAL_HANDLER : PROCESS (cur_state_S1, cur_state_S2, cur_state_S3, i_clk, O_F3R6)
	BEGIN

		o_f1s2 <= '0';
		o_done <= '0';
		o_f1s3 <= '0';
		o_f1s4 <= '0';
		o_f1s5 <= '0';
		o_f1s2 <= '0';
		start2 <= '0';
		o_op1 <= '0';
		o_op2 <= '0';
		o_m <= '0';
		o_en <= '1';
		endof <= '0';

		CASE cur_state_S1 IS

			WHEN F1S0 =>
				o_en <= '0';

			WHEN F1S1 =>
				o_f1s4 <= '1';
				o_op1 <= '1';
				o_op2 <= '0';

			WHEN F1S2 =>
				o_op1 <= '1';
				o_op2 <= '0';
				o_f1s2 <= '1';
				o_f1s3 <= '0';
				o_f1s4 <= '0';

			WHEN F1S1b =>
				o_f1s4 <= '1';
				o_op1 <= '0';
				o_op2 <= '1';
			WHEN F1S2b =>
				o_op1 <= '0';
				o_op2 <= '1';
				o_f1s2 <= '1';
				o_f1s3 <= '0';
				o_f1s4 <= '0';

			WHEN F1S3 =>
				o_f1s4 <= '0';
				o_f1s2 <= '0';
				o_f1s3 <= '1';
				o_m <= '0';

			WHEN F1S3b =>
				o_m <= '1';
				o_f1s4 <= '0';
				o_f1s2 <= '0';
				o_f1s3 <= '1';

			WHEN F1S4 =>
				o_m <= '0';
				o_f1s4 <= '1';
				o_f1s3 <= '0';
				o_f1s5 <= '0';

			WHEN F1S4a =>
				o_f1s4 <= '0';
				o_f1s3 <= '0';
				o_f1s5 <= '0';
			WHEN F1S5 =>
				o_f1s4 <= '0';
				o_f1s3 <= '0';
				o_f1s5 <= '1';

			WHEN F1S6 =>
				o_f1s5 <= '0';
				start2 <= '1';
			WHEN F1S7 =>
				start2 <= '0';

			WHEN F1S8 =>
				o_done <= '1';
				endof <= '1';
			WHEN F1S9 =>
		END CASE;
		f2r1_load <= '0';
		f2r2_load <= '0';
		start3 <= '0';
		CASE cur_state_S2 IS
			WHEN F2S0 =>
				done2 <= '0';
			WHEN F2S1 =>
				done2 <= '0';
				f2r1_load <= '1';
			WHEN F2S2 =>
				done2 <= '0';
			WHEN F2S3 =>
				done2 <= '0';
			WHEN F2S4 =>
				done2 <= '0';
				f2r2_load <= '1';
			WHEN F2S5 =>
				done2 <= '0';
				start3 <= '1';
			WHEN F2S6 =>
				done2 <= '0';

			WHEN F2S7 =>
				done2 <= '1';
		END CASE;
		f3r1_load <= '0';
		f3r2_load <= '0';
		f3r3_load <= '0';
		f3r4_load <= '0';
		f3r5_load <= '0';
		f3r6_load <= '0';
		f3r7_load <= '0';
		done3 <= '0';
		o_we <= '0';
		o_data <= "00000000";
		o_f3addr_write <= '0';
		o_f3addr_read <= '0';
		CASE cur_state_S3 IS
			WHEN F3S0 =>
				o_f3addr_read <= '0';
			WHEN F3S0b =>
				o_f3addr_read <= '1';
			WHEN F3S0c =>
				o_f3addr_read <= '0';
			WHEN F3S1 =>
				f3r1_load <= '1';
				f3r2_load <= '1';
				f3r3_load <= '1';
				f3r4_load <= '1';
			WHEN F3S2 =>
			WHEN F3S3 =>
				f3r5_load <= '1';
			WHEN F3S4 =>
			WHEN F3S5 =>
			WHEN F3S6 =>
				f3r6_load <= '1';
				o_f3addr_write <= '0';
			WHEN F3S6b =>
				o_f3addr_write <= '1';

			WHEN F3S7 =>
				o_f3addr_write <= '0';
				o_we <= '1';
				o_data <= o_f3r6;
			WHEN F3S7b =>
				f3r7_load <= '1';
				o_we <= '0';
			WHEN F3S8 =>
			WHEN F3S9 =>
				done3 <= '1';
		END CASE;
	END PROCESS;

	ADDR_HANDLER : PROCESS (i_clk, i_rst, o_f3addr_read, endof)
	BEGIN
		IF (i_rst = '1' OR endof = '1') THEN
			REGAddr <= "0000000000000000";
			o_address <= "0000000000000000";

		ELSIF (rising_edge (i_clk)) THEN
			IF (o_f1s4 = '1') THEN
				REGAddr <= Sum;
				o_address <= Sum;
				Pixel <= i_data;
			END IF;
			IF (o_f3addr_read = '1') THEN
				o_address <= o_f3r7 + 2;
			END IF;
			IF (o_f3addr_write = '1') THEN
				o_address <= o_f3r4 + o_f3r7;
			END IF;
		END IF;
	END PROCESS;

	-- /* FASE 1 PROCESSES */

	FSM1 : PROCESS (cur_state_S1, i_start, done2, OP1, OP2, F1)
	BEGIN
		next_state_s1 <= cur_state_S1;
		CASE cur_state_S1 IS
			WHEN F1S0 =>
				IF (i_start = '1') THEN
					next_state_s1 <= F1S1;
				ELSE
					next_state_s1 <= F1S0;
				END IF;
			WHEN F1S1 =>
				next_state_s1 <= F1S2;
			WHEN F1S2 =>
				next_state_s1 <= F1S1b;

			WHEN F1S1b => next_state_s1 <= F1S2b;
			WHEN F1S2b =>
				IF (OP1 > 0)
					THEN
					next_state_s1 <= F1S3;
				ELSE next_state_s1 <= F1S8;
				END IF;
			WHEN F1S3 =>
				IF (OP2 > 0) THEN
					next_state_s1 <= F1S3b;
				ELSE
					next_state_s1 <= F1S4;
				END IF;

			WHEN F1S3b =>
				next_state_s1 <= F1S3;

			WHEN F1S4 =>
				next_state_s1 <= F1S4a;
			WHEN F1S4a =>
				next_state_s1 <= F1S5;

			WHEN F1S5 =>
				IF (f1 = '1') THEN
					next_state_s1 <= F1S6;
				ELSE
					next_state_s1 <= F1S4;
				END IF;
			WHEN F1S6 =>
				next_state_s1 <= F1S7;
			WHEN F1S7 =>
				IF (done2 = '1') THEN
					next_state_s1 <= F1S8;
				ELSE
					next_state_s1 <= F1S7;
				END IF;
			WHEN F1S8 =>

				IF (i_start = '0') THEN
					next_state_s1 <= F1S9;
				ELSE
					next_state_s1 <= F1S8;
				END IF;

			WHEN F1S9 =>
				IF (i_start = '0') THEN
					next_state_s1 <= F1S0;
				ELSE
					next_state_s1 <= F1S9;
				END IF;
		END CASE;
	END PROCESS;

	PROCESS (i_clk, i_rst)
	BEGIN
		IF (i_rst = '1') THEN
			cur_state_S1 <= F1S0;
		ELSIF (rising_edge (i_clk)) THEN
			cur_state_S1 <= next_state_s1;

		END IF;
	END PROCESS;

	MULT : PROCESS (o_m, i_clk, i_rst, o_op1, o_op2, o_f1s2, endof)
	BEGIN
		IF (i_rst = '1' OR endof = '1') THEN
			M <= "0000000000000000";

		ELSIF (rising_edge (i_clk)) THEN
			IF o_op1 = '1' THEN
				OP1 <= STD_LOGIC_VECTOR(resize(unsigned(i_data), OP1'length));
			ELSIF o_op2 = '1' THEN
				OP2 <= STD_LOGIC_VECTOR(resize(unsigned(i_data), OP2'length));
			ELSIF (o_m = '1') THEN
				M <= M + OP1;
				OP2 <= OP2 - 1;
			END IF;
		END IF;
	END PROCESS;
	
	MINeMAX : PROCESS (i_clk, o_f1s5, flagMAX, flagMIN, i_rst, f1, endof)
	BEGIN
		IF (i_rst = '1' OR endof = '1') THEN
			MaxPixel <= "00000000";
			MinPixel <= "11111111";
		ELSIF rising_edge(i_clk) AND o_f1s5 = '1' AND f1 = '0' THEN

			IF (flagMIN = '1') THEN
				MINPixel <= Pixel;
			END IF;

			IF (flagMAX = '1') THEN
				MAXPixel <= Pixel;
			END IF;
		END IF;
	END PROCESS;

	-- /* FASE 2 PROCESSES */
	FSM2 : PROCESS (cur_state_S2, done3, start2)
	BEGIN
		next_state_S2 <= cur_state_S2;
		CASE cur_state_S2 IS
			WHEN F2S0 =>
				IF start2 = '1' THEN
					next_state_s2 <= F2S1;
				END IF;
			WHEN F2S1 =>
				next_state_s2 <= F2S2;
			WHEN F2S2 =>
				next_state_s2 <= F2S3;
			WHEN F2S3 =>
				next_state_s2 <= F2S4;
			WHEN F2S4 =>
				next_state_s2 <= F2S5;
			WHEN F2S5 =>
				next_state_s2 <= F2S6;
			WHEN F2S6 =>
				IF done3 = '1' THEN
					next_state_s2 <= F2S7;
				ELSE
					next_state_s2 <= F2S6;
				END IF;
			WHEN F2S7 =>
				next_state_s2 <= F2S0;
		END CASE;
	END PROCESS;

	PROCESS (i_clk, i_rst)
	BEGIN
		IF (i_rst = '1') THEN
			cur_state_S2 <= F2S0;
		ELSIF rising_edge (i_clk) THEN
			cur_state_S2 <= next_state_S2;
		END IF;
	END PROCESS;

	LUT : PROCESS (i_clk, o_f2r1)
	BEGIN
		IF (rising_edge (i_clk)) THEN
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
					o_LUT <= "1000";
				WHEN OTHERS => NULL;
			END CASE;
		END IF;
	END PROCESS;

	Fase2Delta : PROCESS (i_clk, i_rst)
	BEGIN
		IF (i_rst = '1') THEN
			o_f2r1 <= "00000000";
		ELSIF rising_edge (i_clk) THEN
			IF (f2r1_load = '1') THEN
				o_f2r1 <= delta;
			END IF;
		END IF;
	END PROCESS;

	SUB : PROCESS (i_clk, i_rst, endof)
	BEGIN
		IF (i_rst = '1' OR endof = '1') THEN
			o_f2r2 <= "0000";
		ELSIF rising_edge (i_clk) THEN
			IF (f2r2_load = '1') THEN
				o_f2r2 <= o_SUB;
			END IF;
		END IF;
	END PROCESS;

	-- /* FASE 3 PROCESSES */
	FSM3 : PROCESS (cur_state_S3, start3, o_f3r7, o_f3r4)
	BEGIN
		next_state_S3 <= cur_state_S3;
		CASE cur_state_S3 IS
			WHEN F3S0 =>
				IF start3 = '1' THEN
					next_state_S3 <= F3S0b;
				END IF;
			WHEN F3S0b =>
				next_state_S3 <= F3S0c;
			WHEN F3S0c =>
				next_state_S3 <= F3S1;
			WHEN F3S1 =>
				next_state_S3 <= F3S2;
			WHEN F3S2 =>
				next_state_S3 <= F3S3;
			WHEN F3s3 =>
				next_state_S3 <= F3S4;
			WHEN F3S4 =>
				next_state_S3 <= F3S5;
			WHEN F3S5 =>
				next_state_S3 <= F3S6;
			WHEN F3S6 =>
				next_state_S3 <= F3S6b;
			WHEN F3S6b =>
				next_state_S3 <= F3S7;
			WHEN F3S7 =>
				next_state_S3 <= F3S7b;
			WHEN F3S7b =>
				next_state_S3 <= F3S8;
			WHEN F3S8 =>
				IF ((o_f3r7 + 2) < o_f3r4) THEN
					next_state_S3 <= F3S0b;
				ELSE
					next_state_S3 <= F3S9;
				END IF;
			WHEN F3S9 =>
				next_state_S3 <= F3S0;
		END CASE;
	END PROCESS;

	PROCESS (i_clk, i_rst, endof)
	BEGIN
		IF (i_rst = '1' OR endof = '1') THEN
			o_f3r1 <= "00000000";
			o_f3r2 <= "00000000";
			o_f3r3 <= "00000000";
			o_f3r4 <= "0000000000000000";
			o_f3r5 <= "00000000";
			o_f3r6 <= "00000000";
			o_f3r7 <= "0000000000000000";
			cur_state_S3 <= F3S0;
		ELSIF rising_edge (i_clk) THEN
			cur_state_S3 <= next_state_S3;
			IF (f3r1_load = '1') THEN
				o_f3r1 <= shift_level;
			END IF;
			IF (f3r3_load = '1') THEN
				o_f3r3 <= i_data;
			END IF;
			IF (f3r2_load = '1') THEN
				o_f3r2 <= minV;
			END IF;
			IF (f3r4_load = '1') THEN
				o_f3r4 <= maxaddress + 2;
			END IF;
			IF (f3r5_load = '1') THEN
				o_f3r5 <= o_f3sub;
			END IF;
			IF (f3r6_load = '1') THEN
				o_f3r6 <= o_f3mutex;
			END IF;
			IF (f3r7_load = '1') THEN
				o_f3r7 <= o_f3r7 + 1;
			END IF;
		END IF;
	END PROCESS;

	SHIFT : PROCESS (i_clk, O_f3r5, SHIFT_LEVEL, o_f3shiftslave) -- SHIFT # STATO S4
	BEGIN
		o_f3shiftslave <= "00000000" & o_f3r5;
		o_f3shift <= STD_LOGIC_VECTOR(shift_left(unsigned(o_f3shiftslave), TO_INTEGER(unsigned(shift_level))));
	END PROCESS;

	SUBTRACTONS2 : PROCESS (i_clk, O_f3r3, o_f3r2)
	BEGIN
		o_f3sub <= o_f3r3 - o_f3r2;
	END PROCESS;

	MUTEX : PROCESS (i_clk, o_f3shift, o_f3r5, o_f3s1)
	BEGIN
		IF (o_f3shift > 255) THEN
			o_f3s1 <= '1';
		ELSE
			o_f3s1 <= '0';
		END IF;
		IF (o_f3s1 = '1') THEN
			o_f3mutex <= "11111111";
		ELSE
			o_f3mutex <= o_f3shift(7 DOWNTO 0);
		END IF;
	END PROCESS;

END Behavioral;

---Versione final.1
