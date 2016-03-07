
--
-- Flip-flop.
--

library ieee;
use ieee.std_logic_1164.all;

entity smul_flipflop is
    port (
        clk:    in  std_ulogic;
        clken:  in  std_ulogic;
        d:      in  std_ulogic;
        q:      out std_ulogic );
end entity;

architecture smul_flipflop_arch of smul_flipflop is
begin
    process (clk) is
    begin
        if rising_edge(clk) then
            if to_x01(clken) = '1' then
                q <= d;
            end if;
        end if;
    end process;
end architecture;


--
-- Inverter.
--

library ieee;
use ieee.std_logic_1164.all;

entity smul_inverter is
    port (
        d:      in  std_ulogic;
        q:      out std_ulogic );
end entity;

architecture smul_inverter_arch of smul_inverter is
begin
    q <= not d;
end architecture;


--
-- Half-adder.
--

library ieee;
use ieee.std_logic_1164.all;

entity smul_half_add is
    port (
        x:      in  std_ulogic;
        y:      in  std_ulogic;
        d:      out std_ulogic;
        c:      out std_ulogic );
end entity;

architecture smul_half_add_arch of smul_half_add is
begin
    d <= x xor y;
    c <= x and y;
end architecture;


--
-- Full-adder.
--

library ieee;
use ieee.std_logic_1164.all;

entity smul_full_add is
    port (
        x:      in  std_ulogic;
        y:      in  std_ulogic;
        z:      in  std_ulogic;
        d:      out std_ulogic;
        c:      out std_ulogic );
end entity;

architecture smul_full_add_arch of smul_full_add is
begin
    d <= x xor y xor z;
    c <= (x and y) or (y and z) or (x and z);
end architecture;


--
-- Booth negative flag.
--

library ieee;
use ieee.std_logic_1164.all;

entity smul_booth_neg is
    port (
        p0:     in  std_ulogic;
        p1:     in  std_ulogic;
        p2:     in  std_ulogic;
        f:      out std_ulogic );
end entity;

architecture smul_booth_neg_arch of smul_booth_neg is
begin
    f <= p2 and ((not p1) or (not p0));
end architecture;


--
-- Booth partial product generation.
--

library ieee;
use ieee.std_logic_1164.all;

entity smul_booth_prod is
    port (
        p0:     in  std_ulogic;
        p1:     in  std_ulogic;
        p2:     in  std_ulogic;
        b0:     in  std_ulogic;
        b1:     in  std_ulogic;
        y:      out std_ulogic );
end entity;

architecture smul_booth_prod_arch of smul_booth_prod is
begin
    process (p0, p1, p2, b0, b1) is
        variable p: std_ulogic_vector(2 downto 0);
    begin
        p := (p2, p1, p0);
        case p is
            when "000"  => y <= '0';            -- factor 0
            when "001"  => y <= b1;             -- factor 1
            when "010"  => y <= b1;             -- factor 1
            when "011"  => y <= b0;             -- factor 2
            when "100"  => y <= not b0;         -- factor -2
            when "101"  => y <= not b1;         -- factor -1
            when "110"  => y <= not b1;         -- factor -1
            when others => y <= '0';            -- factor 0
        end case;
    end process;
end architecture;


--
-- Determine carry generate and carry propagate.
--

library ieee;
use ieee.std_logic_1164.all;

entity smul_carry_prop is
    port (
        a:      in  std_ulogic;
        b:      in  std_ulogic;
        g:      out std_ulogic;
        p:      out std_ulogic );
end entity;

architecture smul_carry_prop of smul_carry_prop is
begin
    g <= a and b;
    p <= a xor b;
end architecture;


--
-- Merge two carry propagation trees.
--

library ieee;
use ieee.std_logic_1164.all;

entity smul_carry_merge is
    port (
        g0:     in  std_ulogic;
        p0:     in  std_ulogic;
        g1:     in  std_ulogic;
        p1:     in  std_ulogic;
        g:      out std_ulogic;
        p:      out std_ulogic );
end entity;

architecture smul_carry_merge of smul_carry_merge is
begin
    g <= g1 or (g0 and p1);
    p <= p0 and p1;
end architecture;


--
-- Calculate carry-out through a carry propagation tree.
--

library ieee;
use ieee.std_logic_1164.all;

entity smul_carry_eval is
    port (
        g:      in  std_ulogic;
        p:      in  std_ulogic;
        cin:    in  std_ulogic;
        cout:   out std_ulogic );
end entity;

architecture smul_carry_eval of smul_carry_eval is
begin
    cout <= g or (p and cin);
end architecture;


---
--- 8 x 8 bit signed multiplier
---
--- 0 cycles pipeline delay
---

library ieee;
use ieee.std_logic_1164.all;

entity smul_8_8 is
    port (
        clk:    in  std_ulogic;
        clken:  in  std_ulogic;
        xin:    in  std_logic_vector(7 downto 0);
        yin:    in  std_logic_vector(7 downto 0);
        zout:   out std_logic_vector(15 downto 0) );
end entity;

architecture arch of smul_8_8 is

signal wadd0d: std_ulogic;
signal wadd0c: std_ulogic;
signal wboothprod2: std_ulogic;
signal wboothneg3: std_ulogic;
signal wadd4d: std_ulogic;
signal wadd4c: std_ulogic;
signal wboothprod6: std_ulogic;
signal wcarry7: std_ulogic;
signal wcarry8g: std_ulogic;
signal wcarry8p: std_ulogic;
signal wadd10d: std_ulogic;
signal wadd10c: std_ulogic;
signal wadd12d: std_ulogic;
signal wadd12c: std_ulogic;
signal wboothprod14: std_ulogic;
signal wboothprod15: std_ulogic;
signal wboothneg16: std_ulogic;
signal wcarry17: std_ulogic;
signal wcarry18g: std_ulogic;
signal wcarry18p: std_ulogic;
signal wcarry20g: std_ulogic;
signal wcarry20p: std_ulogic;
signal wadd22d: std_ulogic;
signal wadd22c: std_ulogic;
signal wadd24d: std_ulogic;
signal wadd24c: std_ulogic;
signal wboothprod26: std_ulogic;
signal wboothprod27: std_ulogic;
signal wcarry28: std_ulogic;
signal wcarry29g: std_ulogic;
signal wcarry29p: std_ulogic;
signal wadd31d: std_ulogic;
signal wadd31c: std_ulogic;
signal wadd33d: std_ulogic;
signal wadd33c: std_ulogic;
signal wadd35d: std_ulogic;
signal wadd35c: std_ulogic;
signal wboothprod37: std_ulogic;
signal wboothprod38: std_ulogic;
signal wboothprod39: std_ulogic;
signal wboothneg40: std_ulogic;
signal wcarry41: std_ulogic;
signal wcarry42g: std_ulogic;
signal wcarry42p: std_ulogic;
signal wcarry44g: std_ulogic;
signal wcarry44p: std_ulogic;
signal wcarry46g: std_ulogic;
signal wcarry46p: std_ulogic;
signal wadd48d: std_ulogic;
signal wadd48c: std_ulogic;
signal wadd50d: std_ulogic;
signal wadd50c: std_ulogic;
signal wadd52d: std_ulogic;
signal wadd52c: std_ulogic;
signal wboothprod54: std_ulogic;
signal wboothprod55: std_ulogic;
signal wboothprod56: std_ulogic;
signal wcarry57: std_ulogic;
signal wcarry58g: std_ulogic;
signal wcarry58p: std_ulogic;
signal wadd60d: std_ulogic;
signal wadd60c: std_ulogic;
signal wadd62d: std_ulogic;
signal wadd62c: std_ulogic;
signal wadd64d: std_ulogic;
signal wadd64c: std_ulogic;
signal wboothprod66: std_ulogic;
signal wboothprod67: std_ulogic;
signal wboothprod68: std_ulogic;
signal wadd69d: std_ulogic;
signal wadd69c: std_ulogic;
signal wboothprod71: std_ulogic;
signal wboothneg72: std_ulogic;
signal wcarry73: std_ulogic;
signal wcarry74g: std_ulogic;
signal wcarry74p: std_ulogic;
signal wcarry76g: std_ulogic;
signal wcarry76p: std_ulogic;
signal wadd78d: std_ulogic;
signal wadd78c: std_ulogic;
signal wadd80d: std_ulogic;
signal wadd80c: std_ulogic;
signal wadd82d: std_ulogic;
signal wadd82c: std_ulogic;
signal wadd84d: std_ulogic;
signal wadd84c: std_ulogic;
signal wboothprod86: std_ulogic;
signal wboothprod87: std_ulogic;
signal wboothprod88: std_ulogic;
signal wboothprod89: std_ulogic;
signal wcarry90: std_ulogic;
signal wcarry91g: std_ulogic;
signal wcarry91p: std_ulogic;
signal wadd93d: std_ulogic;
signal wadd93c: std_ulogic;
signal wadd95d: std_ulogic;
signal wadd95c: std_ulogic;
signal wadd97d: std_ulogic;
signal wadd97c: std_ulogic;
signal wadd99d: std_ulogic;
signal wadd99c: std_ulogic;
signal wboothprod101: std_ulogic;
signal wboothprod102: std_ulogic;
signal wboothprod103: std_ulogic;
signal wboothprod104: std_ulogic;
signal wcarry105: std_ulogic;
signal wcarry106g: std_ulogic;
signal wcarry106p: std_ulogic;
signal wcarry108g: std_ulogic;
signal wcarry108p: std_ulogic;
signal wcarry110g: std_ulogic;
signal wcarry110p: std_ulogic;
signal wcarry112g: std_ulogic;
signal wcarry112p: std_ulogic;
signal wadd114d: std_ulogic;
signal wadd114c: std_ulogic;
signal wadd116d: std_ulogic;
signal wadd116c: std_ulogic;
signal wadd118d: std_ulogic;
signal wadd118c: std_ulogic;
signal wadd120d: std_ulogic;
signal wadd120c: std_ulogic;
signal wboothprod122: std_ulogic;
signal wboothprod123: std_ulogic;
signal wboothprod124: std_ulogic;
signal wcarry125: std_ulogic;
signal wcarry126g: std_ulogic;
signal wcarry126p: std_ulogic;
signal wadd128d: std_ulogic;
signal wadd128c: std_ulogic;
signal wadd130d: std_ulogic;
signal wadd130c: std_ulogic;
signal wadd132d: std_ulogic;
signal wadd132c: std_ulogic;
signal wadd134d: std_ulogic;
signal wadd134c: std_ulogic;
signal winv136: std_ulogic;
signal winv137: std_ulogic;
signal wboothprod138: std_ulogic;
signal wboothprod139: std_ulogic;
signal wboothprod140: std_ulogic;
signal wcarry141: std_ulogic;
signal wcarry142g: std_ulogic;
signal wcarry142p: std_ulogic;
signal wcarry144g: std_ulogic;
signal wcarry144p: std_ulogic;
signal wadd146d: std_ulogic;
signal wadd146c: std_ulogic;
signal wadd148d: std_ulogic;
signal wadd148c: std_ulogic;
signal wadd150d: std_ulogic;
signal wadd150c: std_ulogic;
signal wboothprod152: std_ulogic;
signal wboothprod153: std_ulogic;
signal wcarry154: std_ulogic;
signal wcarry155g: std_ulogic;
signal wcarry155p: std_ulogic;
signal wadd157d: std_ulogic;
signal wadd157c: std_ulogic;
signal wadd159d: std_ulogic;
signal wadd159c: std_ulogic;
signal winv161: std_ulogic;
signal wboothprod162: std_ulogic;
signal wboothprod163: std_ulogic;
signal wcarry164: std_ulogic;
signal wcarry165g: std_ulogic;
signal wcarry165p: std_ulogic;
signal wcarry167g: std_ulogic;
signal wcarry167p: std_ulogic;
signal wcarry169g: std_ulogic;
signal wcarry169p: std_ulogic;
signal wadd171d: std_ulogic;
signal wadd171c: std_ulogic;
signal wadd173d: std_ulogic;
signal wadd173c: std_ulogic;
signal wboothprod175: std_ulogic;
signal wcarry176: std_ulogic;
signal wcarry177g: std_ulogic;
signal wcarry177p: std_ulogic;
signal wadd179d: std_ulogic;
signal wadd179c: std_ulogic;
signal winv181: std_ulogic;
signal wboothprod182: std_ulogic;
signal wcarry183: std_ulogic;
signal wcarry184g: std_ulogic;
signal wcarry184p: std_ulogic;
signal wcarry186g: std_ulogic;
signal wcarry186p: std_ulogic;
signal wadd188d: std_ulogic;
signal wadd188c: std_ulogic;
signal wcarry190: std_ulogic;
signal wcarry191g: std_ulogic;
signal wcarry191p: std_ulogic;

begin

u0: entity work.smul_booth_prod port map ( '0', xin(0), xin(1), '0', yin(0), wboothprod2 );
u1: entity work.smul_booth_neg port map ( '0', xin(0), xin(1), wboothneg3 );
u2: entity work.smul_full_add port map ( wboothprod2, wboothneg3, '0', wadd0d, wadd0c );
u3: entity work.smul_booth_prod port map ( '0', xin(0), xin(1), yin(0), yin(1), wboothprod6 );
u4: entity work.smul_carry_prop port map ( wboothprod2, wboothneg3, wcarry8g, wcarry8p );
u5: entity work.smul_carry_eval port map ( wcarry8g, wcarry8p, '0', wcarry7 );
u6: entity work.smul_full_add port map ( wboothprod6, '0', wcarry7, wadd4d, wadd4c );
u7: entity work.smul_booth_prod port map ( '0', xin(0), xin(1), yin(1), yin(2), wboothprod14 );
u8: entity work.smul_booth_prod port map ( xin(1), xin(2), xin(3), '0', yin(0), wboothprod15 );
u9: entity work.smul_booth_neg port map ( xin(1), xin(2), xin(3), wboothneg16 );
u10: entity work.smul_full_add port map ( wboothprod14, wboothprod15, wboothneg16, wadd12d, wadd12c );
u11: entity work.smul_carry_prop port map ( wboothprod6, '0', wcarry20g, wcarry20p );
u12: entity work.smul_carry_merge port map ( wcarry8g, wcarry8p, wcarry20g, wcarry20p, wcarry18g, wcarry18p );
u13: entity work.smul_carry_eval port map ( wcarry18g, wcarry18p, '0', wcarry17 );
u14: entity work.smul_full_add port map ( wadd12d, '0', wcarry17, wadd10d, wadd10c );
u15: entity work.smul_booth_prod port map ( '0', xin(0), xin(1), yin(2), yin(3), wboothprod26 );
u16: entity work.smul_booth_prod port map ( xin(1), xin(2), xin(3), yin(0), yin(1), wboothprod27 );
u17: entity work.smul_full_add port map ( wadd12c, wboothprod26, wboothprod27, wadd24d, wadd24c );
u18: entity work.smul_carry_prop port map ( wadd12d, '0', wcarry29g, wcarry29p );
u19: entity work.smul_carry_eval port map ( wcarry29g, wcarry29p, wcarry17, wcarry28 );
u20: entity work.smul_full_add port map ( wadd24d, '0', wcarry28, wadd22d, wadd22c );
u21: entity work.smul_booth_prod port map ( '0', xin(0), xin(1), yin(3), yin(4), wboothprod37 );
u22: entity work.smul_booth_prod port map ( xin(1), xin(2), xin(3), yin(1), yin(2), wboothprod38 );
u23: entity work.smul_booth_prod port map ( xin(3), xin(4), xin(5), '0', yin(0), wboothprod39 );
u24: entity work.smul_full_add port map ( wboothprod37, wboothprod38, wboothprod39, wadd35d, wadd35c );
u25: entity work.smul_booth_neg port map ( xin(3), xin(4), xin(5), wboothneg40 );
u26: entity work.smul_full_add port map ( wadd24c, wadd35d, wboothneg40, wadd33d, wadd33c );
u27: entity work.smul_carry_prop port map ( wadd24d, '0', wcarry46g, wcarry46p );
u28: entity work.smul_carry_merge port map ( wcarry29g, wcarry29p, wcarry46g, wcarry46p, wcarry44g, wcarry44p );
u29: entity work.smul_carry_merge port map ( wcarry18g, wcarry18p, wcarry44g, wcarry44p, wcarry42g, wcarry42p );
u30: entity work.smul_carry_eval port map ( wcarry42g, wcarry42p, '0', wcarry41 );
u31: entity work.smul_full_add port map ( wadd33d, '0', wcarry41, wadd31d, wadd31c );
u32: entity work.smul_booth_prod port map ( '0', xin(0), xin(1), yin(4), yin(5), wboothprod54 );
u33: entity work.smul_booth_prod port map ( xin(1), xin(2), xin(3), yin(2), yin(3), wboothprod55 );
u34: entity work.smul_booth_prod port map ( xin(3), xin(4), xin(5), yin(0), yin(1), wboothprod56 );
u35: entity work.smul_full_add port map ( wboothprod54, wboothprod55, wboothprod56, wadd52d, wadd52c );
u36: entity work.smul_half_add port map ( wadd35c, wadd52d, wadd50d, wadd50c );
u37: entity work.smul_carry_prop port map ( wadd33d, '0', wcarry58g, wcarry58p );
u38: entity work.smul_carry_eval port map ( wcarry58g, wcarry58p, wcarry41, wcarry57 );
u39: entity work.smul_full_add port map ( wadd33c, wadd50d, wcarry57, wadd48d, wadd48c );
u40: entity work.smul_booth_prod port map ( '0', xin(0), xin(1), yin(5), yin(6), wboothprod66 );
u41: entity work.smul_booth_prod port map ( xin(1), xin(2), xin(3), yin(3), yin(4), wboothprod67 );
u42: entity work.smul_booth_prod port map ( xin(3), xin(4), xin(5), yin(1), yin(2), wboothprod68 );
u43: entity work.smul_full_add port map ( wboothprod66, wboothprod67, wboothprod68, wadd64d, wadd64c );
u44: entity work.smul_booth_prod port map ( xin(5), xin(6), xin(7), '0', yin(0), wboothprod71 );
u45: entity work.smul_booth_neg port map ( xin(5), xin(6), xin(7), wboothneg72 );
u46: entity work.smul_half_add port map ( wboothprod71, wboothneg72, wadd69d, wadd69c );
u47: entity work.smul_full_add port map ( wadd52c, wadd64d, wadd69d, wadd62d, wadd62c );
u48: entity work.smul_carry_prop port map ( wadd33c, wadd50d, wcarry76g, wcarry76p );
u49: entity work.smul_carry_merge port map ( wcarry58g, wcarry58p, wcarry76g, wcarry76p, wcarry74g, wcarry74p );
u50: entity work.smul_carry_eval port map ( wcarry74g, wcarry74p, wcarry41, wcarry73 );
u51: entity work.smul_full_add port map ( wadd50c, wadd62d, wcarry73, wadd60d, wadd60c );
u52: entity work.smul_booth_prod port map ( '0', xin(0), xin(1), yin(6), yin(7), wboothprod86 );
u53: entity work.smul_booth_prod port map ( xin(1), xin(2), xin(3), yin(4), yin(5), wboothprod87 );
u54: entity work.smul_booth_prod port map ( xin(3), xin(4), xin(5), yin(2), yin(3), wboothprod88 );
u55: entity work.smul_full_add port map ( wboothprod86, wboothprod87, wboothprod88, wadd84d, wadd84c );
u56: entity work.smul_full_add port map ( wadd64c, wadd69c, wadd84d, wadd82d, wadd82c );
u57: entity work.smul_booth_prod port map ( xin(5), xin(6), xin(7), yin(0), yin(1), wboothprod89 );
u58: entity work.smul_full_add port map ( wadd62c, wadd82d, wboothprod89, wadd80d, wadd80c );
u59: entity work.smul_carry_prop port map ( wadd50c, wadd62d, wcarry91g, wcarry91p );
u60: entity work.smul_carry_eval port map ( wcarry91g, wcarry91p, wcarry73, wcarry90 );
u61: entity work.smul_full_add port map ( wadd80d, '0', wcarry90, wadd78d, wadd78c );
u62: entity work.smul_booth_prod port map ( '0', xin(0), xin(1), yin(7), yin(7), wboothprod101 );
u63: entity work.smul_booth_prod port map ( xin(1), xin(2), xin(3), yin(5), yin(6), wboothprod102 );
u64: entity work.smul_booth_prod port map ( xin(3), xin(4), xin(5), yin(3), yin(4), wboothprod103 );
u65: entity work.smul_full_add port map ( wboothprod101, wboothprod102, wboothprod103, wadd99d, wadd99c );
u66: entity work.smul_booth_prod port map ( xin(5), xin(6), xin(7), yin(1), yin(2), wboothprod104 );
u67: entity work.smul_full_add port map ( wadd84c, wadd99d, wboothprod104, wadd97d, wadd97c );
u68: entity work.smul_half_add port map ( wadd82c, wadd97d, wadd95d, wadd95c );
u69: entity work.smul_carry_prop port map ( wadd80d, '0', wcarry112g, wcarry112p );
u70: entity work.smul_carry_merge port map ( wcarry91g, wcarry91p, wcarry112g, wcarry112p, wcarry110g, wcarry110p );
u71: entity work.smul_carry_merge port map ( wcarry74g, wcarry74p, wcarry110g, wcarry110p, wcarry108g, wcarry108p );
u72: entity work.smul_carry_merge port map ( wcarry42g, wcarry42p, wcarry108g, wcarry108p, wcarry106g, wcarry106p );
u73: entity work.smul_carry_eval port map ( wcarry106g, wcarry106p, '0', wcarry105 );
u74: entity work.smul_full_add port map ( wadd80c, wadd95d, wcarry105, wadd93d, wadd93c );
u75: entity work.smul_booth_prod port map ( xin(1), xin(2), xin(3), yin(6), yin(7), wboothprod122 );
u76: entity work.smul_booth_prod port map ( xin(3), xin(4), xin(5), yin(4), yin(5), wboothprod123 );
u77: entity work.smul_full_add port map ( wboothprod101, wboothprod122, wboothprod123, wadd120d, wadd120c );
u78: entity work.smul_booth_prod port map ( xin(5), xin(6), xin(7), yin(2), yin(3), wboothprod124 );
u79: entity work.smul_full_add port map ( wadd99c, wadd120d, wboothprod124, wadd118d, wadd118c );
u80: entity work.smul_half_add port map ( wadd97c, wadd118d, wadd116d, wadd116c );
u81: entity work.smul_carry_prop port map ( wadd80c, wadd95d, wcarry126g, wcarry126p );
u82: entity work.smul_carry_eval port map ( wcarry126g, wcarry126p, wcarry105, wcarry125 );
u83: entity work.smul_full_add port map ( wadd95c, wadd116d, wcarry125, wadd114d, wadd114c );
u84: entity work.smul_inverter port map ( wboothprod101, winv136 );
u85: entity work.smul_booth_prod port map ( xin(1), xin(2), xin(3), yin(7), yin(7), wboothprod138 );
u86: entity work.smul_inverter port map ( wboothprod138, winv137 );
u87: entity work.smul_booth_prod port map ( xin(3), xin(4), xin(5), yin(5), yin(6), wboothprod139 );
u88: entity work.smul_full_add port map ( winv136, winv137, wboothprod139, wadd134d, wadd134c );
u89: entity work.smul_booth_prod port map ( xin(5), xin(6), xin(7), yin(3), yin(4), wboothprod140 );
u90: entity work.smul_full_add port map ( wadd120c, wadd134d, wboothprod140, wadd132d, wadd132c );
u91: entity work.smul_half_add port map ( wadd118c, wadd132d, wadd130d, wadd130c );
u92: entity work.smul_carry_prop port map ( wadd95c, wadd116d, wcarry144g, wcarry144p );
u93: entity work.smul_carry_merge port map ( wcarry126g, wcarry126p, wcarry144g, wcarry144p, wcarry142g, wcarry142p );
u94: entity work.smul_carry_eval port map ( wcarry142g, wcarry142p, wcarry105, wcarry141 );
u95: entity work.smul_full_add port map ( wadd116c, wadd130d, wcarry141, wadd128d, wadd128c );
u96: entity work.smul_booth_prod port map ( xin(3), xin(4), xin(5), yin(6), yin(7), wboothprod152 );
u97: entity work.smul_booth_prod port map ( xin(5), xin(6), xin(7), yin(4), yin(5), wboothprod153 );
u98: entity work.smul_full_add port map ( '1', wboothprod152, wboothprod153, wadd150d, wadd150c );
u99: entity work.smul_full_add port map ( wadd132c, wadd134c, wadd150d, wadd148d, wadd148c );
u100: entity work.smul_carry_prop port map ( wadd116c, wadd130d, wcarry155g, wcarry155p );
u101: entity work.smul_carry_eval port map ( wcarry155g, wcarry155p, wcarry141, wcarry154 );
u102: entity work.smul_full_add port map ( wadd130c, wadd148d, wcarry154, wadd146d, wadd146c );
u103: entity work.smul_booth_prod port map ( xin(3), xin(4), xin(5), yin(7), yin(7), wboothprod162 );
u104: entity work.smul_inverter port map ( wboothprod162, winv161 );
u105: entity work.smul_booth_prod port map ( xin(5), xin(6), xin(7), yin(5), yin(6), wboothprod163 );
u106: entity work.smul_full_add port map ( wadd150c, winv161, wboothprod163, wadd159d, wadd159c );
u107: entity work.smul_carry_prop port map ( wadd130c, wadd148d, wcarry169g, wcarry169p );
u108: entity work.smul_carry_merge port map ( wcarry155g, wcarry155p, wcarry169g, wcarry169p, wcarry167g, wcarry167p );
u109: entity work.smul_carry_merge port map ( wcarry142g, wcarry142p, wcarry167g, wcarry167p, wcarry165g, wcarry165p );
u110: entity work.smul_carry_eval port map ( wcarry165g, wcarry165p, wcarry105, wcarry164 );
u111: entity work.smul_full_add port map ( wadd148c, wadd159d, wcarry164, wadd157d, wadd157c );
u112: entity work.smul_booth_prod port map ( xin(5), xin(6), xin(7), yin(6), yin(7), wboothprod175 );
u113: entity work.smul_full_add port map ( wadd159c, '1', wboothprod175, wadd173d, wadd173c );
u114: entity work.smul_carry_prop port map ( wadd148c, wadd159d, wcarry177g, wcarry177p );
u115: entity work.smul_carry_eval port map ( wcarry177g, wcarry177p, wcarry164, wcarry176 );
u116: entity work.smul_full_add port map ( wadd173d, '0', wcarry176, wadd171d, wadd171c );
u117: entity work.smul_booth_prod port map ( xin(5), xin(6), xin(7), yin(7), yin(7), wboothprod182 );
u118: entity work.smul_inverter port map ( wboothprod182, winv181 );
u119: entity work.smul_carry_prop port map ( wadd173d, '0', wcarry186g, wcarry186p );
u120: entity work.smul_carry_merge port map ( wcarry177g, wcarry177p, wcarry186g, wcarry186p, wcarry184g, wcarry184p );
u121: entity work.smul_carry_eval port map ( wcarry184g, wcarry184p, wcarry164, wcarry183 );
u122: entity work.smul_full_add port map ( wadd173c, winv181, wcarry183, wadd179d, wadd179c );
u123: entity work.smul_carry_prop port map ( wadd173c, winv181, wcarry191g, wcarry191p );
u124: entity work.smul_carry_eval port map ( wcarry191g, wcarry191p, wcarry183, wcarry190 );
u125: entity work.smul_full_add port map ( '1', '0', wcarry190, wadd188d, wadd188c );

zout(0) <= wadd0d;
zout(1) <= wadd4d;
zout(2) <= wadd10d;
zout(3) <= wadd22d;
zout(4) <= wadd31d;
zout(5) <= wadd48d;
zout(6) <= wadd60d;
zout(7) <= wadd78d;
zout(8) <= wadd93d;
zout(9) <= wadd114d;
zout(10) <= wadd128d;
zout(11) <= wadd146d;
zout(12) <= wadd157d;
zout(13) <= wadd171d;
zout(14) <= wadd179d;
zout(15) <= wadd188d;

end architecture;
