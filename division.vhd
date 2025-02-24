library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity restoring_division is
    Port (
        Q               : in  std_logic_vector(31 downto 0);
        M               : in  std_logic_vector(31 downto 0);
        start           : in  std_logic;  
        clk             : in  std_logic;
        reset           : in  std_logic;
        Q_out           : out std_logic_vector(31 downto 0);
        A               : out std_logic_vector(31 downto 0);
        end_division    : out std_logic;
        division_by_zero: out std_logic
    );
end entity restoring_division;

architecture Behavioral of restoring_division is

    type state_t is (
        initial_state,
        negate_M,
        negate_M_wait,
        negate_Q,
        negate_Q_wait,
        check_zero,
        setup_division,
        iteration_prepare,
        iteration_shift,
        subtract_M,
        subtract_M_wait,
        check_remainder_sign,
        restore_A,
        restore_A_wait,
        decrement_N_setup,
        decrement_N_wait,
        final_check,
        negate_Q_final,
        negate_Q_final_wait,
        negate_A_final,
        negate_A_final_wait,
        delay_setup,
        delay_wait,
        done_state
    );

    signal state                 : state_t := initial_state;
    signal A_temp, Q_temp        : std_logic_vector(31 downto 0) := (others => '0');
    signal abs_M, abs_Q          : std_logic_vector(31 downto 0);
    signal not_M, not_Q          : std_logic_vector(31 downto 0);
    signal result_sign           : std_logic := '0';
    signal flag_div_by_zero      : std_logic := '0';
    signal N                     : std_logic_vector(5 downto 0) := (others => '0');

    signal adder_in1, adder_in2  : std_logic_vector(31 downto 0) := (others => '0');
    signal adder_op              : std_logic := '0';
    signal adder_cin             : std_logic := '0';
    signal adder_sum             : std_logic_vector(31 downto 0) := (others => '0');
    signal adder_cout            : std_logic;
    signal adder_overflow        : std_logic;

    component carry_lookahead_adder_32bit is
        Port (
            A             : in std_logic_vector(31 downto 0);
            B             : in std_logic_vector(31 downto 0);
            OP            : in std_logic; 
            CIN           : in std_logic;
            COUT          : out std_logic;
            S             : out std_logic_vector(31 downto 0);
            overflow_flag : out std_logic
        );
    end component;

begin

    single_adder: carry_lookahead_adder_32bit
        port map(
            A => adder_in1,
            B => adder_in2,
            OP => adder_op,
            CIN => adder_cin,
            COUT => adder_cout,
            S => adder_sum,
            overflow_flag => adder_overflow
        );

    process(clk, reset)
        variable N_extended : std_logic_vector(31 downto 0);
    begin
        if reset = '1' then
            state                 <= initial_state;
            Q_out                 <= (others => '0');
            A                     <= (others => '0');
            N                     <= (others => '0');
            A_temp                <= (others => '0');
            Q_temp                <= (others => '0');
            division_by_zero      <= '0';
            end_division           <= '0';
            flag_div_by_zero      <= '0';
            result_sign           <= '0';
        elsif rising_edge(clk) then
            case state is

                when initial_state =>
                    division_by_zero <= '0';
                    end_division <= '0';
                    flag_div_by_zero <= '0';
                    result_sign <= Q(31) xor M(31);
                    
                    if start = '1' then
                        if M(31) = '1' then
                            adder_in1 <= not(M);
                            adder_in2 <= (others => '0');
                            adder_op  <= '0'; 
                            adder_cin <= '1';
                            state <= negate_M;
                        else
                            abs_M <= M;
                            state <= negate_Q; 
                        end if;
                    else
                        state <= initial_state;
                    end if;
                    
                when negate_M =>
                    abs_M <= adder_sum;
                    state <= negate_M_wait;
                    
                when negate_M_wait =>
                    state <= negate_Q;
                    
                when negate_Q=>
                    if Q(31) = '1' then
                        adder_in1 <= not(Q);
                        adder_in2 <= (others => '0');
                        adder_op  <= '0';
                        adder_cin <= '1';
                        state <= negate_Q_wait;
                    else
                        abs_Q <= Q;
                        state <= check_zero;
                    end if;
                    
                when negate_Q_wait =>
                    abs_Q <= adder_sum;
                    state <= check_zero;
                    
                when check_zero =>
                    if abs_M = x"00000000" then
                        flag_div_by_zero <= '1';
                        state <= final_check;
                    else
                        A_temp <= (others => '0');
                        Q_temp <= abs_Q;
                        N <= "100000";
                        state <= iteration_prepare;
                    end if;
                    
                when iteration_prepare =>
                    if N = "000000" then
                        state <= final_check;
                    else
                        state <= iteration_shift;
                    end if;
                    
                when iteration_shift =>
                    
                    A_temp <= A_temp(30 downto 0) & Q_temp(31);
                    Q_temp <= Q_temp(30 downto 0) & '0';
                    state <= subtract_M;
                    
                when subtract_M =>
                    
                    adder_in1 <= A_temp;
                    adder_in2 <= abs_M;
                    adder_op  <= '1'; 
                    adder_cin <= '0';
                    state <= subtract_M_wait;
                    
                when subtract_M_wait =>
                    A_temp <= adder_sum;
                    state <=check_remainder_sign;
                    
                when check_remainder_sign =>
                    if A_temp(31) = '1' then
                        adder_in1 <= A_temp;
                        adder_in2 <= abs_M;
                        adder_op  <= '0'; 
                        adder_cin <= '0';
                        state <= restore_A;
                    else
                        Q_temp(0) <= '1';
                        state <= decrement_N_setup;
                    end if;
                    
                when restore_A =>
                    adder_in1 <= A_temp;
                    adder_in2 <= abs_M;
                    adder_op  <= '0'; 
                    adder_cin <= '0';
                    state <= restore_A_wait;
                    
                when restore_A_wait =>
                    A_temp <= adder_sum;
                    Q_temp(0) <= '0';
                    state <= decrement_N_setup;
                    
                when decrement_N_setup =>
                    N_extended := (others => '0');
                    N_extended(5 downto 0) := N;
                    adder_in1 <= N_extended;
                    adder_in2 <= x"00000001"; 
                    adder_op  <= '1'; 
                    adder_cin <= '0';
                    state <= decrement_N_wait;
                    
                when decrement_N_wait =>
                    N <= adder_sum(5 downto 0);
                    state <= iteration_prepare;
                    
                when final_check =>
                    if flag_div_by_zero = '1' then
                        Q_out <= (others => '0');
                        A     <= (others => '0');
                        division_by_zero <= '1';
                        state <= delay_setup;
                    else
                        result_sign <= M(31) xor Q(31);
                        if result_sign = '1' then
                            adder_in1 <= not(Q_temp);
                            adder_in2 <= (others => '0');
                            adder_op  <= '0'; 
                            adder_cin <= '1';
                            state <= negate_Q_final;
                        else
                            Q_out <= Q_temp;
                            A     <= A_temp;
                            division_by_zero <= '0';
                            state <= delay_setup;
                        end if;
                    end if;
                    
                when negate_Q_final =>
                    state <= negate_Q_final_wait;
                    
                when negate_Q_final_wait =>
                    Q_out <= adder_sum;
                    adder_in1 <= not(A_temp);
                    adder_in2 <= (others => '0');
                    adder_op  <= '0'; 
                    adder_cin <= '1';
                    state <= negate_A_final;
                    
                when negate_A_final =>
                    state <= negate_A_final_wait;
                    
                when negate_A_final_wait =>
                    A <= adder_sum;
                    division_by_zero <= '0';
                    state <= delay_setup;
                    
                when delay_setup =>
                    state <= delay_wait;
                    
                when delay_wait =>
                     if N = "000000" then
                        end_division <= '1';
                    state <= done_state;
                     else
                        state <= delay_setup;
                    end if;

                    
                when done_state =>
                    if start = '0' then
                        state <= initial_state;
                    else
                        state <= done_state;
                    end if;
                    
                when others =>
                    state <= initial_state;
                    
            end case;
        end if;
    end process;

end Behavioral;
