library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity rotate_register is
    Port (
        clk         : in  std_logic;                
        rst         : in  std_logic;                
        data_in     : in  std_logic_vector(31 downto 0);  
        shift_amount : in  std_logic_vector(4 downto 0); 
        direction   : in  std_logic;               
        data_out    : out std_logic_vector(31 downto 0)  
    );
end rotate_register;

architecture Behavioral of rotate_register is
begin
    process(rst,direction,data_in)
    begin
        if rst = '1' then
            data_out <= (others => '0');
        elsif direction = '0' then --right
                data_out <= data_in(0) & data_in(31 downto 1);  
            elsif direction = '1' then  --left
                data_out <= data_in(30 downto 0) & data_in(31);  
            end if;
    end process;
end Behavioral;
