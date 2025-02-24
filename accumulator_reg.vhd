library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity accumulator_reg is
    Port (
        clk      : in std_logic; -- Clock signal
        reset    : in std_logic; -- Asynchronous reset
        load     : in std_logic; -- Load control signal
        data_in  : in std_logic_vector(31 downto 0); -- Input data
        data_out : out std_logic_vector(31 downto 0) -- Output data
    );
end accumulator_reg;

architecture Behavioral of accumulator_reg is
    signal acc : std_logic_vector(31 downto 0) := (others => '0');
begin
    process (clk, reset)
    begin
        if reset = '1' then
            acc <= (others => '0'); -- Reset the register
        elsif rising_edge(clk) then
            if load = '1' then
                acc <= data_in; -- Load new data on the rising clock edge
            end if;
        end if;
    end process;

    data_out <= acc; -- Output the current value of the register
end Behavioral;
