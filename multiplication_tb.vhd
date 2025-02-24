library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity multiplier_tb is
end multiplier_tb;

architecture Behavioral of multiplier_tb is
    component multiplier is
        Port (
            x              : in  std_logic_vector(31 downto 0);
            y              : in  std_logic_vector(31 downto 0);
            clk            : in  std_logic;
            reset          : in  std_logic;
            start          : in  std_logic;  
            result         : out std_logic_vector(63 downto 0);
            end_operations : out std_logic
        );
    end component;

    signal x                 : std_logic_vector(31 downto 0) := (others => '0');
    signal y                 : std_logic_vector(31 downto 0) := (others => '0'); 
    signal clk               : std_logic := '0';                               
    signal result            : std_logic_vector(63 downto 0) := (others => '0'); 
    signal end_operations    : std_logic := '0';
    signal start_multiplication : std_logic := '0';
    signal reset             : std_logic := '0';
    constant clk_period      : time := 1 ns; 

begin
    uut: multiplier
        Port Map (
            x => x,
            y => y,
            clk => clk,
            reset => reset,
            start => start_multiplication,
            result => result,
            end_operations => end_operations
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
        wait for 5 ns;
        reset <= '0';

        -- First multiplication: 5 * 3
        x <= std_logic_vector(to_signed(-2147483648,32)); 
        y <= std_logic_vector(to_signed(-11, 32));
        start_multiplication <= '1'; 
        wait until end_operations = '1'; 
        start_multiplication <= '0'; 
        wait for 5 ns;  

 

        -- Second multiplication: (-5) * 3
        x <= std_logic_vector(to_signed(-5, 32));
        y <= std_logic_vector(to_signed(3, 32));
        start_multiplication <= '1'; 
        wait until end_operations = '1'; 
        start_multiplication <= '0'; 
        wait for 2 ns; 



        x <= std_logic_vector(to_signed(-5, 32));
        y <= std_logic_vector(to_signed(-3, 32));
        start_multiplication <= '1';
        wait until end_operations = '1';
        start_multiplication <= '0';
        wait for 2 ns;

     

        wait;  
    end process;

end Behavioral;
