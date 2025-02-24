library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

ENTITY TEST IS
END TEST;

ARCHITECTURE behavior OF TEST IS 

    COMPONENT restoring_division
        PORT(
            Q               : IN  std_logic_vector(31 downto 0);
            M               : IN  std_logic_vector(31 downto 0);
            start           : IN  std_logic;  
            Q_out           : OUT std_logic_vector(31 downto 0);
            A               : OUT std_logic_vector(31 downto 0);
            end_division    : OUT std_logic;
            division_by_zero: OUT std_logic;  
            clk             : IN  std_logic;
            reset           : IN std_logic
        );
    END COMPONENT;   
    
    signal Q               : std_logic_vector(31 downto 0) := (others => '0');
    signal M               : std_logic_vector(31 downto 0) := (others => '0');
    signal clk             : std_logic := '0';
    signal reset           : std_logic := '0';
    signal start           : std_logic := '0';  
    
    signal A               : std_logic_vector(31 downto 0) := (others => '0');
    signal Q_out           : std_logic_vector(31 downto 0) := (others => '0');
    signal end_division    : std_logic := '0';
    constant clk_period    : time := 1 ns;
    signal division_by_zero: std_logic := '0';

BEGIN

    uut: restoring_division PORT MAP (
        Q               => Q,
        M               => M,
        start           => start,    
        Q_out           => Q_out,
        A               => A,
        division_by_zero=> division_by_zero,
        end_division    => end_division,
        clk             => clk,
        reset           => reset
    );

    clk_process : process
    begin
        clk <= '0';
        wait for clk_period / 2;
        clk <= '1';
        wait for clk_period / 2;
    end process;

    stim_proc: process
    begin
        reset <= '1';
        wait for 1 ns;
        reset <= '0';
        wait for 1 ns;
        
              -- Test 2: Q=5, M=0 (division by zero)
        Q <= std_logic_vector(to_signed(10, 32)); 
        M <= std_logic_vector(to_signed(0, 32));
        wait for 5 ns;
        start <= '1';
        wait for 5 ns;
        start <= '0';
        wait until end_division = '1';
        
        -- Test 1: Q=5, M=3
        Q <= std_logic_vector(to_signed(5, 32)); 
        M <= std_logic_vector(to_signed(3, 32));
        wait for 5 ns;        
        start <= '1';  
        wait for 5 ns;
        start <= '0';  
        wait until end_division = '1';

        
        Q <= std_logic_vector(to_signed(5, 32)); 
        M <= std_logic_vector(to_signed(-3, 32));
        wait for 5 ns;        
        start <= '1'; 
        wait for 5 ns;
        start <= '0';  
        wait until end_division = '1';
        
        Q <= std_logic_vector(to_signed(-5, 32)); 
        M <= std_logic_vector(to_signed(-3, 32));
        wait for 5 ns;        
        start <= '1';  
        wait for 5 ns;
        start <= '0';  
        wait until end_division = '1';
  
        
 

        wait; 
    end process;

END behavior;
