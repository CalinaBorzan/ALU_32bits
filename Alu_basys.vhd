library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity ALU_Top is
    Port (
        clk       : in  std_logic;
        reset     : in  std_logic;
        switches  : in  std_logic_vector(14 downto 0);
        next_btn  : in  std_logic;  
        debug_btn : in  std_logic; 
        leds      : out std_logic_vector(3 downto 0);
        an        : out std_logic_vector(3 downto 0);
        cat       : out std_logic_vector(6 downto 0)
    );
end ALU_Top;

architecture Behavioral of ALU_Top is

  
    signal addr1, addr2, op_select : std_logic_vector(3 downto 0);
    signal CIN, load_acc, start    : std_logic;

    signal result                  : std_logic_vector(31 downto 0);
    signal overflow_flag           : std_logic;
    signal carry_out_flag          : std_logic;
    signal div_by_zero_flag        : std_logic;

    signal debug_operand1          : std_logic_vector(31 downto 0);
    signal debug_operand2          : std_logic_vector(31 downto 0);

    signal debug_btn_debounced     : std_logic;
    signal next_btn_debounced      : std_logic;

    signal debug_select            : std_logic := '0';

    signal display_select          : std_logic := '0';

    signal display_data            : std_logic_vector(31 downto 0);

    signal digit0, digit1, digit2, digit3 : std_logic_vector(3 downto 0);

begin
  
    addr2     <= switches(3 downto 0);
    addr1     <= switches(7 downto 4);
    op_select <= switches(11 downto 8);
    CIN       <= switches(12);
    load_acc  <= switches(14);
    start     <= switches(13);

   
    db_debug_btn : entity work.debouncer
        port map (
            clk => clk,
            btn => debug_btn,
            en  => debug_btn_debounced
        );

    db_next_btn : entity work.debouncer
        port map (
            clk => clk,
            btn => next_btn,
            en  => next_btn_debounced
        );

  
    alu_inst : entity work.ALU_top_unit
        port map (
            clk              => clk,
            reset            => reset,
            addr1            => addr1,
            addr2            => addr2,
            op_select        => op_select,
            CIN              => CIN,
            start            => start,

            overflow_flag    => overflow_flag,
            carry_out_flag   => carry_out_flag,
            div_by_zero_flag => div_by_zero_flag,
            load_acc         => load_acc,
            result           => result,

            debug_operand1   => debug_operand1,
            debug_operand2   => debug_operand2
        );

  
    leds(0) <= overflow_flag;
    leds(1) <= carry_out_flag;
    leds(2) <= div_by_zero_flag;
    leds(3) <= display_select; 

  
    process(clk)
    begin
        if rising_edge(clk) then
            if debug_btn_debounced = '1' then
                debug_select <= not debug_select;
            end if;
        end if;
    end process;

   
    process(clk)
    begin
        if rising_edge(clk) then
            if next_btn_debounced = '1' then
                display_select <= not display_select;
            end if;
        end if;
    end process;


    process(debug_select, debug_operand1, debug_operand2)
    begin
        if debug_select = '0' then
            display_data <= debug_operand1;
        else
            display_data <= debug_operand2;
        end if;
    end process;

    
    digit0 <= display_data( 3 downto 0)   when (display_select='0')
               else display_data(19 downto 16);

    digit1 <= display_data( 7 downto 4)   when (display_select='0')
               else display_data(23 downto 20);

    digit2 <= display_data(11 downto 8)   when (display_select='0')
               else display_data(27 downto 24);

    digit3 <= display_data(15 downto 12)  when (display_select='0')
               else display_data(31 downto 28);

   
    display_7seg_inst : entity work.display_7seg
        port map (
            digit0 => digit0,   
            digit1 => digit1,
            digit2 => digit2,
            digit3 => digit3,   
            clk    => clk,
            cat    => cat,
            an     => an
        );

end Behavioral;

