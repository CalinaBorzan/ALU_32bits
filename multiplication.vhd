library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity multiplier is
    Port (
        x              : in  std_logic_vector(31 downto 0);
        y              : in  std_logic_vector(31 downto 0);
        clk            : in  std_logic;
        reset          : in  std_logic;
        start          : in  std_logic; 
        result         : out std_logic_vector(63 downto 0);
        end_operations : out std_logic
    );
end entity multiplier;

architecture Behavioral of multiplier is

    type state_t is (
        initial_state,
        check_sign_x,
        negate_x_wait,
        check_sign_y,
        negate_y_wait,
        setup_multiplier,
        add_shift,
        add_lower,
        add_lower_wait,
        add_upper,
        add_upper_wait,
        shift_B,
        shift_Q,
        decrement_counter,
        decrement_N_start,
        finalize_result,
        negate_64bit_lower_start,
        negate_64bit_lower_wait,
        negate_64bit_upper_start,
        before_delay_state,
        delay_state,
        delay_decrement_wait,
        done_state
    );

    signal state             : state_t := initial_state;
    signal abs_x, abs_y      : std_logic_vector(31 downto 0);
    signal negated_x, negated_y : std_logic_vector(31 downto 0); 
    signal result_sign       : std_logic;
    signal A, B              : std_logic_vector(63 downto 0) := (others => '0');
    signal Q                 : std_logic_vector(31 downto 0) := (others => '0');
    signal N                 : std_logic_vector(5 downto 0) := "011111";
    signal not_X, not_Y      : std_logic_vector(31 downto 0);
    signal not_A_full        : std_logic_vector(63 downto 0);

    signal adder_in1, adder_in2 : std_logic_vector(31 downto 0) := (others => '0');
    signal adder_op             : std_logic := '0';
    signal adder_cin            : std_logic := '0';
    signal adder_sum            : std_logic_vector(31 downto 0) := (others => '0');
    signal adder_cout           : std_logic;
    signal adder_overflow       : std_logic;

    signal stored_carry         : std_logic := '0';
    signal temp_lower, temp_upper : std_logic_vector(31 downto 0) := (others => '0');

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

    not_X <= not(x);
    not_Y <= not(y);

    abs_x <= x when x(31) = '0' else negated_x;
    abs_y <= y when y(31) = '0' else negated_y;

    result_sign <= x(31) xor y(31);

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

    process(clk, reset, x, y)
        variable N_extended : std_logic_vector(31 downto 0);
    begin
        if reset = '1' then
            state <= initial_state;
            A <= (others => '0');
            B <= (others => '0');
            Q <= (others => '0');
            N <= "011111";
            end_operations <= '0';
            result <= (others => '0');
            negated_x <= x;
            negated_y <= y;
            temp_lower <= (others => '0');
            temp_upper <= (others => '0');
        
        elsif rising_edge(clk) then
            case state is
                when initial_state =>
                    end_operations <= '0';
                    if start = '1' then
                        state <= check_sign_x;
                    else
                        state <= initial_state;
                    end if;

                when check_sign_x =>
                    if x(31) = '1' then
                        adder_in1 <= not_X;
                        adder_in2 <= (others => '0');
                        adder_op  <= '0';
                        adder_cin <= '1';
                        state <= negate_x_wait;
                    else
                        negated_x <= x;
                        state <= check_sign_y;
                    end if;

                when negate_x_wait =>
                    negated_x <= adder_sum;
                    state <= check_sign_y;

                when check_sign_y =>
                    if y(31) = '1' then
                        adder_in1 <= not_Y;
                        adder_in2 <= (others => '0');
                        adder_op  <= '0';
                        adder_cin <= '1';
                        state <= negate_y_wait;
                    else
                        negated_y <= y;
                        state <= setup_multiplier;
                    end if;

                when negate_y_wait =>
                    negated_y <= adder_sum;
                    state <= setup_multiplier;

                when setup_multiplier =>
                    N <= "100000";
                    A <= (others => '0');
                    B <= x"00000000" & abs_x;
                    Q <= abs_y;
                    end_operations <= '0';
                    state <= add_shift;

                when add_shift =>
                    if Q(0) = '1' then
                        adder_in1 <= A(31 downto 0);
                        adder_in2 <= B(31 downto 0);
                        adder_op  <= '0';
                        adder_cin <= '0';
                        state <= add_lower_wait;
                    else
                        state <= shift_B;
                    end if;

                when add_lower_wait =>
                    state <= add_lower;

                when add_lower =>
                    temp_lower <= adder_sum;
                    stored_carry <= adder_cout;
                    adder_in1 <= A(63 downto 32);
                    adder_in2 <= B(63 downto 32);
                    adder_op  <= '0';
                    adder_cin <= stored_carry;
                    state <= add_upper_wait;

                when add_upper_wait =>
                    state <= add_upper;

                when add_upper =>
                    temp_upper <= adder_sum;
                    A <= temp_upper & temp_lower;
                    state <= shift_B;

                when shift_B =>
                    B <= B(62 downto 0) & '0';
                    state <= shift_Q;

                when shift_Q =>
                    Q <= '0' & Q(31 downto 1);
                    state <= decrement_counter;

                when decrement_counter =>
                    N_extended := (others => '0');
                    N_extended(5 downto 0) := N;
                    adder_in1 <= N_extended;
                    adder_in2 <= x"00000001";
                    adder_op  <= '1'; 
                    adder_cin <= '0';
                    state <= decrement_N_start;

                when decrement_N_start =>
                    N <= adder_sum(5 downto 0);
                    if N = "000000" then
                        state <= finalize_result;
                    else
                        state <= add_shift;
                    end if;

                when finalize_result =>
                    if result_sign = '1' then
                        not_A_full <= not(A);
                        state <= negate_64bit_lower_start;
                    else
                        result <= A;
                        N <= "011111";
                        state <= delay_state;
                    end if;

                when negate_64bit_lower_start =>
                    adder_in1 <= not_A_full(31 downto 0);
                    adder_in2 <= (others => '0');
                    adder_op  <= '0';
                    adder_cin <= '1';
                    state <=negate_64bit_lower_wait;

                when negate_64bit_lower_wait =>
                    temp_lower <= adder_sum;
                    stored_carry <= adder_cout;
                    adder_in1 <= not_A_full(63 downto 32);
                    adder_in2 <= (others => '0');
                    adder_op  <= '0';
                    adder_cin <= stored_carry;
                    state <= negate_64bit_upper_start;

                when negate_64bit_upper_start =>
                    temp_upper <= adder_sum;
                    state <= before_delay_state;
                    
                when before_delay_state =>
                   result <= temp_upper & temp_lower;
                   state<=delay_state;

                when delay_state =>
                    N_extended := (others => '0');
                    N_extended(5 downto 0) := N;
                    adder_in1 <= N_extended;
                    adder_in2 <= x"00000001";
                    adder_op  <= '1';
                    adder_cin <= '0';
                    state <= delay_decrement_wait;

                when delay_decrement_wait =>
                    N <= adder_sum(5 downto 0);
                    if N = "000000" then
                        end_operations <= '1';
                        state <= done_state;
                    else
                        state <= delay_state;
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
