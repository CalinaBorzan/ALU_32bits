library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity logical_op_tb is
end logical_op_tb;

architecture Behavioral of logical_op_tb is

    component logical_op is
        Port (
            operand1       : in std_logic_vector(31 downto 0); 
            operand2       : in std_logic_vector(31 downto 0);  
            sel            : in std_logic_vector(2 downto 0);  
            start          : in  std_logic;                  
            ready          : out std_logic;                
            result         : out std_logic_vector(31 downto 0);
            clk            : in std_logic
        );
    end component;

    signal operand1    : std_logic_vector(31 downto 0) := (others => '0');
    signal operand2    : std_logic_vector(31 downto 0) := (others => '0');
    signal sel         : std_logic_vector(2 downto 0) := "000";
    signal result      : std_logic_vector(31 downto 0):=x"00000000";
    signal clk         : std_logic := '0';  
    signal start, ready : std_logic := '0';

begin

    uut: logical_op
        Port map (
            operand1 => operand1,
            operand2 => operand2,
            sel      => sel,
            result   => result,
            start    => start,
            ready    => ready,
            clk      => clk
        );

    clk_process: process
    begin
        clk <= '0';
        wait for 5 ns;  
        clk <= '1';
        wait for 5 ns;
    end process;

    stim_proc: process
    begin
        wait for 20 ns;
        
        operand1 <= x"00000005"; 
        operand2 <= x"00000003"; 

        wait for 10 ns;
        
        -- Test AND operation
        sel <= "001";
        start <= '1';
        wait for 1 ns;
        start <= '0';
        wait for 10 ns;

--        -- Test OR operation
--        sel <= "010"; 
--        start <= '1'; 
--        wait for 1 ns;
--        start <= '0';
--        wait for 10 ns;

--        -- Test NOT operation (only operand1 is used)
--        sel <= "011";
--        start <= '1';
--        wait for 1 ns;
--        start <= '0';
--        wait for 10 ns;

--        -- Test Increment operation
--        sel <= "100";
--        start <= '1';  
--        wait for 1 ns;
--        start <= '0';
--        wait for 10 ns;

--        -- Test Decrement operation
--        sel <= "101";
--        start <= '1';  
--        wait for 1 ns;
--        start <= '0';
--        wait for 10 ns;

--        -- Test Negation operation
--        sel <= "111";
--        start <= '1';  
--        wait for 1 ns;
--        start <= '0';  
--        wait for 10 ns;

        wait;
    end process;

end Behavioral;
