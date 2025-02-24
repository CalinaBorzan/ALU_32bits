library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity memory_unit is
    Port (
        addr: in std_logic_vector(3 downto 0); -- Address selection (16 addresses for simplicity)
        data_out: out std_logic_vector(31 downto 0)  -- Data output
    );
end memory_unit;

architecture Behavioral of memory_unit is
    type memory_array is array (15 downto 0) of std_logic_vector(31 downto 0);
    signal mem: memory_array := (
        0  => x"7FFFFFFF",  -- Maximum positive 32-bit integer (+2,147,483,647)
        1  => x"80000000",  -- Minimum negative 32-bit integer (-2,147,483,648)
        2  => x"000F4240",  -- +1,000,000
        3  => x"FFF0BDC0",  -- -1,000,000 (2's complement)
        4  => x"3B9ACA00",  -- +1,000,000,000
        5  => x"C4653600",  -- -1,000,000,000 (2's complement)
        6  => x"000186A5",  -- +100,005
        7  => x"FFFE7960",  -- -100,000 (2's complement)
        8  => x"00002710",  -- +10,000
        9  => x"FFFFD8F0",  -- -10,000 (2's complement)
        10 => x"0000068E",  -- +1,678
        11 => x"FFFFFC18",  -- -1,000 (2's complement)
        12 => x"00000064",  -- +100
        13 => x"FFFFFF9C",  -- -100 (2's complement)
        14 => x"0000000A",  -- +10
        15 => x"FFFFFFF6"   -- -10 (2's complement)
    );
begin
    process(addr)
    begin
        data_out <= mem(conv_integer(addr)); -- Directly output data based on address
    end process;
end Behavioral;
