# MB-6890 Service Manual: circuit explanation (printed pp.41-81)

Source: Hitachi "Personal Computer MB-6890 Service Manual" (English, 1981). Pages are manualslib
images in `ref/docs/service/MB-6890-service-manual/manualslib-pages/pNNN.jpg`. **Image number =
printed page + 2.** Citations are `[SVC p.N]` with N = the printed page. The image number is given
once per section as (img pNNN).

This note covers images p043-p083. The pages before p043 (general, specs, IC list, block
explanations) and after p083 (adjustment, switches, troubleshooting, schematics, parts) are covered
in other notes.

---

## 1. Block overview (img p043-p044)

- The MPU runs from EXTAL = 4.032 MHz ("4.032MCK"), which the timing signal generator supplies
  [SVC p.41].
- **Interrupt use** [SVC p.41]:
  - NMI is the BREAK interrupt, from the **trace counter** and the **keyboard**.
  - IRQ detects keyboard input.
  - **"FIRQ pin is for Timer interrupt."**
- A low on DMA/BREQ from outside stops the MPU and floats its address and data buses [SVC p.41].
- **Clocks:** the 32.256 MHz crystal is divided to 16.128, 8.064, 4.032 and 2.016 MHz. 16.128 MHz is
  for the timing signal generator. 4.032 MHz is EXTAL and the video clock. From E (1.008 MHz) and
  16.128 MHz the system signal generator makes RAS/CAS for the DRAM and CHRCK (the CRTC master
  clock) [SVC p.41].
- **RAM** is 32 KB of program/"store" RAM (16K×1 ×16) plus 16K×5 colour RAM. Colour RAM shares
  addresses with program RAM, and the CPU reaches it only through the **colour register** [SVC p.41].
- **Video:** store-RAM data goes through the character generator or graphic generator, is
  serialised, and is mixed with the colour-RAM colour. A separate circuit makes monochrome
  composite [SVC p.41].
- **Keyboard:** a hardware scan. A counter driven by HP (the horizontal sync frequency) feeds the
  decoder IC86 (HD74159P) and the multiplexer IC90 (HD74LS151P). A keypress raises IRQ [SVC p.41].
- **Cassette:**
  - The ACIA output is turned into FSK using **1.2 kHz and 2.4 kHz, divided from E**.
  - Load goes through a PLL to the ACIA [SVC p.42].
- **RS-232C:** the ACIA clock is divided from 16.128 MHz [SVC p.42].
- **Light pen:** when the pen is ON this is detected by IRQ, and LP STB goes to the CRTC [SVC p.42].
- **Sound:** a class-B push-pull amplifier, used for the key click and beep [SVC p.42].

---

## 2. Internal register map (Table 6-1, img p045) [SVC p.43]

`O` = allowed, `x` = not allowed. Bits are D7..D0; `-` = unused.

| Addr | Name | D7 | D6 | D5 | D4 | D3 | D2 | D1 | D0 | R | W | Function | IC |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| $FFC8 | KBNMI | BK | - | - | - | - | - | - | - | O | x | BK=1: BREAK NMI | IC98 |
| $FFC9 | DIPSW | D7 | D6 | D5 | D4 | D3 | D2 | D1 | D0 | O | x | DIP switch setting | IC19, IC20 |
| $FFCA | TIMER | T | - | - | - | - | - | - | - | O | x | T=1: timer IRQ (pending flag) | IC16 |
| $FFCB | LPFLG | LP | - | - | - | - | - | - | - | O | x | LP=1: light-pen IRQ | IC24 |
| $FFD0 | MODE SEL | W | HR | C | - | - | GB | RB | BB | x | O | Table 6-2 | IC39 |
| $FFD1 | TRACE | - | - | - | - | - | - | - | - | x | O | a write starts the trace counter | IC14 |
| $FFD2 | REMOTE | RM | - | - | - | - | - | - | - | x | O | RM=1: relay ON | IC126 |
| $FFD3 | MUSIC SEL | MS | - | - | - | - | - | - | - | x | O | speaker bit | IC93 |
| $FFD4 | TIME MASK | TM | - | - | - | - | - | - | - | x | O | TM=1: prohibit timer IRQ | IC17 |
| $FFD5 | LPENBL | LE | - | - | - | - | - | - | - | x | O | LE=1: light-pen operation enabled | IC24 |
| $FFD6 | INTERLACE SEL | - | - | - | - | IS | - | - | - | x | O | IS=1 interlace, IS=0 non-interlace | IC130 |
| $FFD8 | C-REG-SEL | MK | - | - | GC | RV | G | R | B | O | O | Table 6-3 | IC78, IC79 |
| $FFE0 | KB (write) | BM | SS | - | - | UE | SL | HR | KN | - | O | Table 6-4 | IC89 |
| $FFE0 | KB (read) | D7..D0 key code | | | | | | | | O | - | key code | IC88 |

- The DIPSW register is read-only. It sets the initial conditions of BASIC at power-on [SVC p.43].
- **$FFD7 is missing from Table 6-1.** The memory-map figure on p.81 names it **BANK SEL** (§12).

### Table 6-2 MODE SEL ($FFD0, write-only) [SVC p.43]

| W | HR | Mode |
|---|---|---|
| 0 | 0 | 40 ch, high resolution |
| 0 | 1 | 40 ch, normal |
| 1 | 0 | 80 ch, high resolution |
| 1 | 1 | 80 ch, normal |

| C | ACIA routed to |
|---|---|
| 0 | Cassette |
| 1 | RS-232C |

| GB RB BB | Background colour |
|---|---|
| 000 | Black |
| 001 | Blue |
| 010 | Red |
| 011 | Magenta |
| 100 | Green |
| 101 | Cyan |
| 110 | Yellow |
| 111 | White |

MODE SEL also drives HRSO-SW (the hi-res select) from IC39 pin 2 [SVC p.60] and the RS/C SW line
[SVC p.65].

### Table 6-3 C-REG-SEL ($FFD8, read/write) [SVC p.45]

| Bit | Name | Meaning |
|---|---|---|
| 7 | MK | 0 = "enable write", 1 = "prohibit write" (see §6.2) |
| 4 | GC | 0 = character, 1 = graphic |
| 3 | RV | 0 = normal, 1 = reverse |
| 2-0 | G R B | display (foreground) colour, same coding as the background table |

### Table 6-4 KB ($FFE0, write) [SVC p.45]

| Bit | Name | 0 | 1 |
|---|---|---|---|
| 7 | BM | keyboard NMI prohibited | keyboard NMI possible |
| 6 | SS | keyboard IRQ prohibited | keyboard IRQ possible |
| 3 | UE | scan counter (IC102) runs | scan counter stopped |
| 2 | SL | | SHIFT-mode LED (see note) |
| 1 | HR | | Hiragana-mode LED |
| 0 | KN | | Katakana-mode LED |

The printed LED table has rows `SL HR KN = 000` → SHIFT LED on, `010` → Hiragana LED on and
`001` → Katakana LED on. The first row is almost certainly a typo for `100`, i.e. each LED is on
when its bit is 1. MAME agrees: bit 2 caps/shift, bit 1 hiragana, bit 0 katakana.

---

## 3. MPU circuit (Fig 6-2, img p046) [SVC p.44]

- **IC1** is an HD6809P / MC6809L, with EXTAL = 4.032 MHz.
- **IC6** (SN74LS245N) buffers the data bus to the RAM3/RAM4 connectors and the I/F-1..I/F-6
  slots. ROM, RAM, PIA, ACIA and CRTC sit directly on D0-D7.
- **IC7-IC9** (74LS367AP) buffer the address bus to the slots, RAM, ROM and the address decoders.
  IC9/IC25 (74LS08) also make VMA from BA and BS.
- R/W goes through IC24 (74LS125AP). E goes out as ETTL through IC41 (74LS367AP). Q goes to the
  slots through IC10.
- **Reset:** the reset switch goes through IC21/IC22 to RES, and IC10 sends the reset to the slots.
  HALT, MRDY and DMA are pulled up and run to the slots.
- **Interrupt wiring.** Each source goes through an open-collector 74LS05 into a wired-OR line with
  a pull-up. The zoomed figure is unambiguous:

  | CPU pin | Sources |
  |---|---|
  | NMI | Trace counter (IC22), keyboard BREAK (IC95), and slots I/F-1..6 |
  | FIRQ | **Timer interrupt (IC22)**, and slots I/F-1..6 |
  | IRQ | Light-pen interrupt (IC22), keyboard interrupt (IC95), and slots I/F-1..6. The PIA IRQA/IRQB (§9) and the ACIA IRQ (§8) also go to IRQ |

- The CRTC returns the light-pen position to the MPU over the data bus [SVC p.44].

---

## 4. Address decoding (img p047-p050) [SVC p.45-p48]

### 4.1 ROM decoder (Fig 6-3, Table 6-5)

- **IC11** (74LS139P) decodes AB13 and AB14. It is enabled by IC26 = NAND(AB15, R/W), so **the ROMs
  are selected only on reads from $8000-$FFFF**. Writes go to whatever RAM sits below, which in a
  standard machine means nothing.
- Y0..Y3 select $8000, $A000, $C000 and $E000 (8 KB blocks). Each drives pin 20 (CS) of IC2..IC5
  through IC21/IC28/IC29/IC26 gating.
- **ROM KIL** (IC138, an AND of I/F pin 29, RAM3 pin 23 and RAM4 pin 23) is active low. While it is
  low, all ROM selects are disabled.
- The IC5 select is also gated by IC33's "$FF00-$FFEF" output, so IC5 does not respond in the
  system I/O range [SVC p.45, p.47].

Table 6-5, ROM allocated addresses [SVC p.46]:

| IC | ROM | Address | Function |
|---|---|---|---|
| IC2 | (none fitted) | $8000-$9FFF | BASIC expansion (empty socket) |
| IC3 | µPD2364C-330 | $A000-$BFFF | BASIC |
| IC4 | µPD2364C-331 | $C000-$DFFF | BASIC |
| IC5 | µPD2364C-332 | $E000-$FEFF | BASIC |
| IC5 | (same chip) | $FFF0-$FFFF | Monitor (vectors) |

- Fig 6-47 labels IC4 as "$A000-$DFFF". That is a typo for $C000-$DFFF [SVC p.77].
- The ROMs are 8 KB mask ROMs (µPD2364). MAME's ROM labels (598 p16611 / 599 p16561 / 600 p16681)
  do not match these µPD2364C-330/331/332 part numbers. They may be a later revision (Mark II/5);
  the CRCs need checking.

### 4.2 System I/O decoder (Fig 6-4, Table 6-6) [SVC p.45, p.47]

- **IC30** (74LS30) is an 8-input NAND of AB8-AB15, so it is active for $FFxx.
- **IC12** (74LS138P) takes A=AB3, B=AB4 and C=AB5. G1 = AB6, and G2A/G2B come from IC30 and
  AB7 (via IC31).
- IC11 and IC13 then decode AB2-AB0 into the individual register strobes.

| IC12 output | Address | Use |
|---|---|---|
| Y0 | $FFC0-$FFC7 | **IN LSI SEL**: PIA, ACIA, CRTC |
| Y1 | $FFC8-$FFCF | KBNMI, DIPSW, TIMER, LPFLG |
| Y2 | $FFD0-$FFD7 | MODE SEL ... BANK SEL |
| Y3 | $FFD8-$FFDF | C-REG-SEL |
| Y4 | $FFE0-$FFE7 | KB |
| Y5 | $FFE8-$FFEF | (unused on MB-6890) |
| Y6 | $FFF0-$FFF7 | (vectors; ROM) |
| Y7 | $FFF8-$FFFF | (vectors; ROM) |

$FF00-$FFBF is not decoded internally. It is left to the expansion slots.

### 4.3 RAM decoder (Fig 6-5, Table 6-7) [SVC p.46, p.48]

- **IC33** decodes AB15 and AB14:
  - **RAM1 SEL** is low for $0000-$3FFF.
  - **RAM2 SEL** is low for $4000-$7FFF.
- **IC137** (74LS139P) decodes AB15-AB11 for the RAM expansion connectors, so expansion cards need
  no decoder of their own.

| Signal | Connector | Address |
|---|---|---|
| A89-SEL | RAM3 | $8000-$9FFF |
| AAB-SEL | RAM3 | $A000-$BFFF |
| ACD-SEL | RAM4 | $C000-$DFFF |
| AE-SEL (AEF-SEL) | RAM4 | $E000-$EFFF |

---

## 5. Clock generator and system signals (img p050-p053) [SVC p.48-p51]

### 5.1 Frequencies (Fig 6-6, "6-4-1 System clock specification") [SVC p.48]

| Symbol | Frequency | Derivation |
|---|---|---|
| fx | 32.256 MHz | crystal X1 |
| fD80 | 16.128 MHz | 80-ch dot clock = 80 ch × 8 dots / 39.68 µs |
| fD40 | 8.064 MHz | 40-ch dot clock = 40 × 8 / 39.68 µs |
| fEXTL | 4.032 MHz | 6809 EXTAL |
| fC80 | 2.016 MHz | 80-ch character clock = fD80 / 8 |
| fC40 | 1.008 MHz | 40-ch character clock = fD40 / 8 |
| fE | 1.008 MHz | MPU E clock (EXTAL / 4) |
| fH | 15.75 kHz | fC80 / 128 = fC40 / 64 |
| fV | 60 Hz | fH / 262.5 |

- The horizontal display period is **39.68 µs** [SVC p.48].
- **Circuit (Fig 6-6, 6-7):**
  - IC43 (74S04P) is a 3rd-overtone crystal oscillator with an LC tank (L1, C201) [SVC p.49].
  - **IC37** (74S163N) divides it:
    - QA (pin 14) = 16.128 MHz
    - QB (pin 13) = 8.064 MHz
    - QC (pin 12) = 4.032 MHz
    - QD (pin 11) = 2.016 MHz
  - 16.128 MHz is used three ways:
    - by the system signal generator
    - as the 80-ch DOTCK
    - as the RS-232C clock
  - 8.064 MHz is the 40-ch DOTCK, and 4.032 MHz goes to EXTAL and the display clock.
- **IC38** (74LS157P) switches the 40/80-ch versions of DOTCK, LOAD, CHRCK and GRENBL. SELECT = L
  gives 40-ch, H gives 80-ch [SVC p.52].

**MAME check (bml3.h, "p.48"):** MAME's clocks are MASTER 32.256 MHz, D80 = /2, D40 = /4,
EXTAL = /8, CPU = /32, C80 = EXTAL/2 and H = C80/128. **This matches the manual.**

### 5.2 System signal generator (Fig 6-8, 6-9, text 6-4-3) [SVC p.50-p51]

- **IC42** (74LS164P) is a shift register. It shifts the E signal with the 16.128 MHz clock;
  outputs QA..QH are 62.5 ns taps.
- The system signals are gates of those taps:
  - **CHRCK:** 40-ch = IC42 QC (pin 5). 80-ch = QC combined with QG (IC35 pin 8).
  - **LOAD** (latches store and colour RAM data into the video shift register IC117 HD74LS166P):
    40-ch = QD & QH (IC45 pin 6). 80-ch = QF & QG (IC35 pin 6).
  - **GRENBL** (graphic-generator enable, which prevents character/graphic overlap): 40-ch = QH
    (IC42 pin 13). 80-ch = QC & QG (IC34 pin 10).
  - **CAS φ1** (IC28 pin 8): DRAM CAS during the display period (E low). Made from QB, QE and QG.
  - **CAS φ2** (IC46 pin 13): DRAM CAS during the MPU period (E high). Made from E and QD.
  - **RAS** (IC46 pin 1): from QA, QC and QG. It also switches the row/column address.
  - **MPU DISP SW** (IC46 pin 4): from QB and QG. It switches the RAM address between CRTC and MPU.
- **Time chart (Fig 6-9)** [SVC p.50]:

  | Signal | Timing |
  |---|---|
  | 80DOTCK | 62.5 ns period |
  | 40DOTCK | 125 ns |
  | 4 MHz | 250 ns |
  | E | 1 µs; the low half is the "display period", the high half the "MPU period" |
  | 40CHRCK | 1 µs |
  | 80CHRCK | 500 ns |
  | LOAD (40-mode) | 140 ns low pulse every 1 µs |
  | LOAD (80-mode) | 70 ns low pulse every 500 ns |
  | RAS | 120 / 260 / 120 / 500 ns segments |
  | CAS φ2 | 280 / 720 ns |
  | CAS φ1 | 500, 180, 140, 180 ns |
  | MPU DISP SW | 320 / 680 ns |

---

## 6. RAM block and colour RAM (img p059-p061) [SVC p.57-p59]

### 6.1 DRAM organisation

- The DRAMs are **HM4716AP-1** (16K×1, 7 multiplexed address bits) [SVC p.57]:
  - Program/store RAM: IC56-IC63 (first 16 KB) and IC69-IC76 (second 16 KB).
  - Colour RAM: IC64-IC68 (5 bits).
- **Bus sharing:** in the E-low (display) period the CRTC address drives the RAM; in the E-high
  period the MPU does. MPU DISP SW switches between them [SVC p.57].
- **80-column mode reads two consecutive display addresses per 1 µs MPU cycle**, using DRAM page
  mode with the same row address. 40-col needs one per cycle [SVC p.57, p.59].
- Table 6-10, CAS outputs [SVC p.58]:

  | RAM | Signal | MPU period | Display period |
  |---|---|---|---|
  | First RAM (IC56-63) | CAS1 | $0000-$3FFF | $0400-$3FFF |
  | Second RAM (IC69-76) | CAS2 | $4000-$7FFF | $4000-$43FF |
  | Colour RAM (IC64-68) | CASCR | $0400-$43FF | $0400-$43FF |

### 6.2 Colour RAM and the colour register

These are Figs 6-11, 6-12 and 6-20 with the text of 6-5-2 [SVC p.57-p59].

Colour RAM, 5 bits per cell:

| Bit | 4 | 3 | 2 | 1 | 0 |
|---|---|---|---|---|---|
| H | Graphic | Reverse | Green on | Red on | Blue on |
| L | Character | Normal | Green off | Red off | Blue off |
| IC | IC68 | IC67 | IC66 | IC65 | IC64 |

Displayed colour code = bits 2-0 (G R B):

| Code | 0 | 1 | 2 | 3 | 4 | 5 | 6 | 7 |
|---|---|---|---|---|---|---|---|---|
| Colour | Black | Blue | Red | Magenta | Green | Cyan | Yellow | White |

- The colour register is **IC77** (HD74LS174P), a bidirectional tri-state latch. IC78 and IC79
  (HD74LS367AP) buffer it in each direction [SVC p.58-p59].
- **Operation** [SVC p.59]:
  1. In the display period, store-RAM and colour-RAM data both go to the video generator.
  2. When the MPU **reads** the display area, it gets the store-RAM byte, and the colour-RAM value
     at that address is loaded into the colour register.
  3. When the MPU **writes** the display area, the byte goes to store RAM and **the colour
     register's contents are written into colour RAM at the same time**.
  4. **Mask bit (MK):** with MK = H, the colour register keeps its contents even when store RAM is
     read. With MK = L, an MPU read loads the colour register from colour RAM. The stated purpose
     is that code or data kept in the display-RAM area can run without destroying the colour
     register.
- Colour RAM is valid only for accesses to the display area $0400-$43FF.
- **Interpretation:** Table 6-3 calls MK "write enable / prohibit write", but the text describes
  MK only as gating the *read-back into the register*. The text says nothing about it gating
  colour-RAM writes.
  - **MAME** does the same: `vram_r` latches only when bit 7 = 0, and `vram_w` always writes ARAM.
    MAME's comment says gating the write breaks HI-WRITER. So the manual text agrees with MAME.
    The table caption is ambiguous.

---

## 7. CRTC and video (img p054-p066) [SVC p.52-p64]

### 7.1 CRTC connection (Fig 6-10) [SVC p.52-p53]

- **IC36** HD46505SP:
  - CS = CRTC-SEL, RS = AB0, E = ETTL, CLK = CHRCK (1.008 MHz in 40-col, 2.016 MHz in 80-col).
  - D0-D7 sit on the MPU bus, and LPSTB comes from the light-pen circuit.
  - MA0-MA13 go to the RAM address mux, RA0-RA3 to the raster circuit, and DISPTMG, CUDISP, HSYNC
    and VSYNC to the video generator.
- IC47, IC49 and IC50 (74LS74/00/08) make the CRTC output a valid address at power-on in 80-ch
  mode [SVC p.55].
- Fig 6-8 is the standard 6845 register table, R0-R17 [SVC p.52]. R12-R15 are read/write. R16 and
  R17 (light pen) are read-only. R0-R11 are write-only. **No register values are given on these
  pages.**

### 7.2 Timing (Fig 6-11, 6-27) [SVC p.53, p.64]

**Horizontal:**

- Total 128 characters (80-col) or 64 (40-col) = **63.5 µs (15.75 kHz)**.
- Display 80 or 40 characters = 39.68 µs.
- After display: about 10 µs, then a **4 µs horizontal sync**, then about 10 µs.
- **The horizontal sync on the video connector is regenerated:** IC134 (74LS93) and IC135 count
  E, synchronised to the CRTC HSYNC, giving a fixed **4 µs** pulse at IC96 pin 8 [SVC p.63].

**Vertical (Fig 6-27, "Display spec of the screen"):**

- Display: 25 lines = **12.7 ms**.
- Then a **"raster return period" of 2.4 ms** (labelled "4 Line").
- Then the **vertical synchronous signal, 1.43 ms**.
- Total **16.7 ms (60 Hz)**.
- In Fig 6-11, VSYNC is about 500 µs and the DISPTMG vertical blank is about 2.4 ms [SVC p.53, p.64].

**Character cell:** 8×8 dots non-interlace, 8×16 dots interlace [SVC p.64].

**Cursor (CUDISP):** a 1 µs pulse in 40-col and 0.5 µs in 80-col, once per frame [SVC p.53].

**Refresh address (Fig 6-12):**

- 40-col: MA0 has a 1 µs period (2 µs for MA1, and so on).
- 80-col: the MA0 period is 500 ns.

**Raster address (Fig 6-13)** [SVC p.53]:

- Non-interlace: RA0-RA2 count 63.5 µs, 127 µs, 254 µs.
- Interlace: RA0 changes per field, and RA1-RA3 carry the line count.

**MAME check (p.64):** MAME says "raster return period 2.4 ms". **Confirmed.**

### 7.3 Interlace switch ($FFD6) (Fig 6-14, 6-15) [SVC p.54-p55]

- **On the rising edge of INTERLACE SEL, MPU D3 is latched in IC130** (74LS74AP).
- IC130 Q drives IC141 (74LS157P):
  - Q = H (interlace) selects input B.
  - Q = L (non-interlace) selects input A.
- The circuit remaps CRTC RA0-RA3 into RAA1-RAA3 so that the downstream raster address is "equal
  in both modes". After the switch, RAA1, RAA2 and RAA3 have periods of 63.5 µs, 127 µs and 254 µs,
  and one character row lasts 508 µs [SVC p.54].
- IC141 1Y goes to character ROM IC107 pin 8 (labelled A0). IC136 ANDs IC130 Q with something
  (DD7 is shown) to drive IC107 pin 19 (labelled "A11"). So in interlace mode the extra raster bit
  and code bit 7 choose the 16-byte interlace glyph area (see 7.5).
- Interlace is actually switched by reprogramming the CRTC (R8 and the raster count). The $FFD6 bit
  only remaps the raster/ROM addressing [SVC p.55].

### 7.4 Display address conversion (hi-res) (Fig 6-16, 6-9 table, 6-17, 6-18) [SVC p.54-p56]

- IC51 (74LS157P): SELECT = 80/40, and /G = HRSO-SW.
- IC40 (74LS283P) adds IC51's output to MA10-MA13, giving MAA10-MAA13.

**IC51 output (the "Fig 6-9" table, p.54):**

| | 40 ch | 80 ch |
|---|---|---|
| S input | L | H |
| 1Y | RAA1 | L |
| 2Y | RAA2 | RAA1 |
| 3Y | RAA3 | RAA2 |
| 4Y | L | RAA3 |

- **Normal mode** (HRSO-SW = H): IC51 outputs are L, so MA13-MA10 pass straight through.
- **Hi-res mode** (HRSO-SW = L), so the display address is:
  - 40-col: MA + (raster×1024)
  - 80-col: MA + (raster×2048)

**CRT addresses (Fig 6-17, 6-18)** [SVC p.55]:

| Mode | Rows | Addresses |
|---|---|---|
| 40-col normal | 25 rows of 40 | $0400-$0427 ... $07C0-$07E7 |
| 80-col normal | 25 rows of 80 | $0400-$044F ... $0B80-$0BCF |
| 40-col hi-res | char row 0, raster 0..7 | $0400, $0800, $0C00, ... $2000 (+$27 each row) |
| 40-col hi-res | last row | $07C0 ... $23C0-$23E7 |
| 80-col hi-res | char row 0, raster 0..7 | $0400, $0C00, $1400, ... $3C00 (to +$4F) |
| 80-col hi-res | last row | $0B80 ... $4380-$43CF |

### 7.5 Character generator (Fig 6-22, 6-23, text 6-6-1) [SVC p.60-p62]

- **IC107** is a **µPD2332C-328**, a **4 KB** mask ROM.
  - /CS = G/C (colour-RAM bit 4), so it is enabled only for character cells.
  - Address: A1-A3 = RAA1-RAA3, A4-A11 = DD0-DD7 (the store-RAM byte, as drawn). A0 and A11 are
    modified by the interlace circuit.
  - D1-D8 go to IC117 (the shift register).
- **ROM organisation (Fig 6-23):**

  | Area | Size | Contents |
  |---|---|---|
  | 1 | 2 KB | **Interlace area**: 128 characters × 16 bytes (the "complicated" glyphs such as kana) |
  | 2 | 1 KB | **Non-interlace area**: 128 characters × 8 bytes |
  | 3 | 1 KB | **Common area**: 128 characters × 8 bytes, shared by both modes |

- **Non-interlace** uses areas 2 and 3 only.
- **Interlace:**
  - Characters in area 3 have each 8-byte pattern read in both the odd and even fields, so they are
    line-doubled to 16 rows.
  - The 128 complex characters use the true 16-row patterns of area 1.
- **Core implication:** the real font ROM is 4 KB in this layout. MAME's "handcrafted" font cannot
  be relied on for interlace glyphs.

### 7.6 Graphic generator (Fig 6-24, 6-25, Table 6-13) [SVC p.60-p63]

- Used when GC = 1. GR ENBL and G/C (IC129) enable IC113 and IC114 (74LS257P).
- Their select input is **HRSO-SW**: H = hi-res (input A, which is IC112's output... as drawn, A =
  direct DD bits), L = normal mode (input B).
- **Normal ("semi-graphic") mode:** IC112 (74LS153P, dual 4:1) is selected by RAA2/RAA3. Each
  character cell is a 2 × 4 block grid, each block 4 dots wide × 2 rasters tall (Fig 6-25a):

  | Block row | Left | Right |
  |---|---|---|
  | 0 (top) | DD4 | DD0 |
  | 1 | DD5 | DD1 |
  | 2 | DD6 | DD2 |
  | 3 (bottom) | DD7 | DD3 |

- **Hi-res mode:** one character area is 8 × 8 dots. Each raster row is its own byte; DD7 is the
  leftmost dot and DD0 the rightmost (Fig 6-25b).
- **Table 6-13** [SVC p.63]:

  | Graphic mode | Chars | Resolution | Display RAM |
  |---|---|---|---|
  | Normal | 40 | 80 × 100 | 1000 B |
  | Normal | 80 | 160 × 100 | 2000 B |
  | High resolution | 40 | 320 × 200 | 8000 B |
  | High resolution | 80 | 640 × 200 | 16000 B |

### 7.7 Video signal path (Fig 6-21, 6-26, text 6-6-3) [SVC p.60-p64]

1. The character-generator or graphic-generator byte is loaded into **IC117** (SN74LS166N) on LOAD
   and shifted out at DOTCK as the "brightness" signal.
2. The colour-RAM bits (REV, G, R, B) and CUR DISP and DISP TMG are latched each character by
   **IC115** (74LS174P, clocked by LOAD), then each dot by **IC116** (74LS175P, DOTCK).
3. The brightness signal is combined with **REV** (IC136) and then with **CUR DISP** (IC131,
   74LS86 XOR). **The hardware cursor inverts the cell.**
4. **IC118** (74LS158P) picks one of two colours per dot:
   - the background colour R-BK/G-BK/B-BK from MODE SEL
   - the foreground R/G/B from colour RAM
   Its outputs are inverted by IC132 (74S05) to the **colour (RGB TTL) connector**.
5. Monochrome: R, G and B are mixed with sync by IC132 and IC135 in a simple D/A, then Q5
   (2SC1213) drives the monochrome composite output.
6. The sync outputs (IC135) are HSYNC (the regenerated 4 µs pulse), VSYNC and PEDSTL (pedestal).

---

## 8. Keyboard (Fig 6-28, text 6-7, img p067-p068) [SVC p.65-p66]

**Parts:**

| Part | Function |
|---|---|
| IC101 | X counter (74LS93P) |
| IC102 | X counter and Y counter (74LS93P) |
| IC86 | decoder (HD74159P, 4→16): drives the 16 X columns |
| IC90 | multiplexer (HD74LS151P, 8→1): reads the 8 Y rows, with pull-ups |
| IC97 | HP gate (74LS32P) |
| IC99 | counter-stop flip-flop (74LS74P) |
| IC96 | IRQ AND with the IRQ mask (74LS08P) |
| IC88, IC98 | key-code tri-state buffers (74LS367AP, 74LS125AP) |

The matrix is 16 × 8, so a key code is 7 bits.

**Operation** [SVC p.65]:

1. The scan clock is **HP = horizontal pulse, 15.75 kHz**, into the X counter. Each count drives one
   decoder output low.
2. The X counter's carry clocks the Y counter, whose value selects a row in the multiplexer.
3. When the key at (x0, y0) is down, the multiplexer output goes L when the scan reaches it.
4. The counter-stop circuit (IC99 pin 5) goes H, the HP gate (IC97) closes so the counters stop,
   and **IRQ** is raised. It is gated by the IRQ MASK, which is $FFE0 bit SS.
5. The MPU IRQ routine reads **$FFE0**. The keyboard read signal (IC97 pin 6) goes L, and IC98 and
   IC88 put the X/Y counter state (the key code) on the bus. Software converts it to a character.
6. When the read ends, the buffers float, **IRQ is released**, and the HP gate opens so scanning
   resumes.

**Derived timing:** one full scan is 128 positions × 63.5 µs = **8.13 ms**.

**MAME check (p.65):** "keyboard timer is driven by the horizontal video sync clock". **Confirmed.**
MAME's model (one scan code per hsync, then latch with bit 7 set and raise IRQ) matches the
circuit, but:
- MAME scans only codes below 96 (32×3). The hardware matrix has 128 positions.
- MAME's UE (counter disable) handling, `scancode &= 7`, has no basis in this text. The manual
  just says UE = 1 stops counter IC102.

---

## 9. Interfaces

### 9.1 Cassette / RS-232C switching and clocks (Fig 6-29, Table 6-14, img p067/p069) [SVC p.65, p.67]

- **IC84** (HD46850P, the ACIA) is shared by cassette and RS-232C.
- **IC111** (74LS157P) switches the paths with **RS/C SW** (from MODE SEL bit 5, "C"):
  - L = cassette
  - H = RS-232C
- The clock source is E (1.008 MHz) for cassette and 16.128 MHz for RS-232C. It is divided by the
  binary counters IC122, IC123 and IC124 (74LS93P), with IC91, IC92 and IC125 for gating and
  resets. **CS3** is the baud chip-switch.

**Table 6-14:**

| Point | RS/C SW = H (RS-232C) | RS/C SW = L (cassette) |
|---|---|---|
| IC111 pin 1 | RS-232C | Cassette |
| IC111 pin 4 (counter input) | 16.128 MCK | 1.008 MCK |
| IC111 pin 7 (**ACIA TxC/RxC**) | 19.2 kHz (when CS3 is set to 1) | **9.6 kHz** |
| IC111 pin 9 (**ACIA RxD**) | RxD | cassette signal |
| IC123 pin 11 | 153.6 kHz | 9.6 kHz |
| IC124 pin 9 | 76.8 kHz | 4.8 kHz |
| IC124 pin 8 | 38.4 kHz | 2.4 kHz |
| IC124 pin 11 | 19.2 kHz | 1.2 kHz |

**Derived:**

- Cassette: the ACIA clock is fixed at **9.6 kHz**, which with ACIA ÷16 gives **600 baud**. The
  2.4 kHz and 1.2 kHz taps are the FSK tones.
- RS-232C: CS3 selects 153.6 / 76.8 / 38.4 / 19.2 kHz (16.128 MHz / 105 and its halvings), i.e.
  9600 / 4800 / 2400 / 1200 baud at ÷16.

**MAME check (bml3.h, "p.67"):** MAME's commented-out frequencies match this table. However, MAME
maps **$FFD7 as "BAUD SEL"**, switching the ACIA clock between 9600 and 19200 Hz (600/1200 baud).
**Conflict:** on the MB-6890, cassette mode has no software baud select; the ACIA clock is a fixed
9.6 kHz. $FFD7 is "BANK SEL" (p.81). A 1200-baud select may exist on the Mark II/Mark 5, but not
in this manual.

### 9.2 Cassette SAVE (Fig 6-30, 6-31, img p070) [SVC p.65, p.68]

- ACIA TxD (IC84 pin 6) is latched by IC126 (74LS74) on the 1.2 kHz clock. IC125 (74LS00) gates
  2.4 kHz or 1.2 kHz to the SAVE output (through R79/C210/R80).
- **Encoding** (from the load chart, Fig 6-33):

  | Bit | Signal | Duration |
  |---|---|---|
  | "1" (H, mark) | **4 cycles of 2.4 kHz** (417 µs each) | 1.67 ms |
  | "0" (L, space) | **2 cycles of 1.2 kHz** (833 µs each) | 1.67 ms |

  That is a **600 baud** Kansas-City-style format, so each bit is one 1.2 kHz period window. The
  SAVE chart shows a 1.66 µs tick (a typo for 1.66 ms) and 834 µs half-periods [SVC p.68].

### 9.3 Cassette LOAD (Fig 6-32, 6-33, img p070-p071) [SVC p.68-p69]

1. The input is limited to 1.2 Vpp by diodes D3/D4.
2. It goes to **IC127, an LM565CN PLL**. Its VCO control voltage goes to **IC128 (75108AP
   comparator)** pin 11, against a reference on pin 12.
3. IC128 pin 9 gives the digital data, which goes to IC111 pin 11 and then to ACIA RxD.
4. The output is H for the 2.4 kHz tone and L for 1.2 kHz.

### 9.4 RS-232C (Table 6-15, img p071-p072) [SVC p.69-p70]

- Signals: TxD (out, low logic), RTS (out), DCD (in; ground it to receive normally), CTS (in; ground
  it to always allow sending) and RxD (in).

| Signal | Buffer | ACIA pin |
|---|---|---|
| TxD | IC119 HD75188P (±12 V driver) | TxData (6) |
| RTS | IC119 | RTS (5) |
| RxD | IC120 HD75189P (receiver, threshold tied to +15 V) | RxData (2) |
| CTS | IC120 | CTS (24) |
| DCD | IC120 | DCD (23) |

- CTS, RTS and DCD are effective only when RS-232C is selected. IC92 gates CTS/DCD with RS/C SW
  [SVC p.70, p.72].

### 9.5 ACIA wiring (Fig 6-39, img p074) [SVC p.72]

- IC84 HD46850P:
  - CS2-bar = IN LSI SEL ($FFC0-$FFC7), CS1 = AB2, CS0 = IC91 pin 5 (a decoded/inverted address
    bit), RS = AB0, so the ACIA sits at **$FFC4-$FFC5**.
  - E = ETTL. IRQ goes to the CPU **IRQ**.
  - TxCK and RxCK both come from IC111 pin 7.
- The ACIA chapter explains the 6850's ÷16 sampling (Fig 6-36 to 6-38) [SVC p.70-p71]. With the
  ÷16 setting, a 9.6 kHz clock gives 600 baud.

### 9.6 Cassette remote ($FFD2) (Fig 6-40) [SVC p.72]

- **IC126 latches D7 on the REMOTE strobe.** Q = H turns on Q4 (2SC1213), which closes relay RL1 to
  the recorder's remote jack.
- /RES clears the latch, so the motor is off at reset.

### 9.7 Printer / PIA (Fig 6-41, img p074-p075) [SVC p.72-p73]

- **IC85** HD46821P (PIA):
  - CS2-bar = IN LSI SEL, CS0 from AB2 via IC91, CS1 pulled up, RS0 = AB0, RS1 = AB1, so it sits at
    **$FFC0-$FFC3**.
  - IRQA and IRQB go to **IRQ**, and RES to /RES.
- **Port B:** PB0-PB7 go through IC105/IC95 (74LS05 open-collector) to the printer data lines
  (connector E-1..E-8).
- **CB2 → STRB** through IC93 (74LS74) and IC95.
- **CB1** ← the OR (IC94) of BUSY and ACK. BUSY is H while the printer is busy, and ACK goes L when
  it finishes.
- **Port A:** PA0-PA7, CA1 and CA2 go to connector H-1..H-10. This is the second header; its use is
  not described on these pages.

### 9.8 Light pen (Fig 6-42, 6-43, Table 6-16, img p075-p076) [SVC p.73-p74]

- Connector JC:

  | Pin | Signal | Content |
  |---|---|---|
  | 1 | LP OUT | photodiode output |
  | 2 | LP-SW | pen pressed (L) |
  | 3 | — | +5 V |
  | 4 | LP VCMP | reference voltage for sensitivity |
  | 5 | — | GND |

- LP-SW and LP OUT are ANDed by IC25 and clocked into IC17, which outputs **LP STB to the CRTC**.
- IC18 and IC22 raise **IRQ** when LPENBL is set ($FFD5 bit 7). LPFLG ($FFCB bit 7) is the flag.
- Timing: the strobe and IRQ come once per 16.6 ms frame while the pen is held.

### 9.9 Sound ($FFD3) (Fig 6-44, 6-45, img p076) [SVC p.74]

- **On the rising edge of MUSIC SEL, MPU D7 is latched in IC93** (74LS74AP). Q goes through the
  volume network (R35/R36) and C204 to the amplifier (Q1-Q3), then to the speaker (6×9 cm, 16 Ω,
  0.4 W per p.2).
- **It is a pure 1-bit output.** Software toggles bit 7 to make a tone; there is no hardware tone
  generator.
- A "voice input" from the I/F-1..I/F-6 slots is mixed in before the amplifier, for sound cards.
- **MAME** (`music_sel_w` → `speaker->level_w(BIT(data,7))`) **matches.**

---

## 10. System expansion and memory expansion (img p077-p079) [SVC p.75-p77]

- The general expansion connectors are **I/F-1..I/F-6**. They carry the MPU address and data buses,
  and **ROM-KIL** (active low) disables internal ROM decoding.
- The RAM expansion connectors are **RAM3 and RAM4**. They carry the RAM address, the decoded
  selects (Table 6-7) and ROM-KIL. A RAM card also outputs ROM-KIL as **EXROM-KIL** onto the
  general slots, to block slot ROMs in the same range.
- **One 8 KB RAM card in RAM3:** ROM-KIL goes low for $8000-$9FFF. Internal ROM-KILO goes H, so IC2
  (the expansion ROM socket) is disabled and data buffer IC6 connects the card [SVC p.75].
- **Maximum expansion, two cards:**
  - RAM3 = 16 KB at $8000-$BFFF.
  - RAM4 = 12 KB at $C000-$EFFF.
  - ROM-KIL disables IC2-IC4 and the BASIC part of IC5. **Only the monitor area $F000-$FEFF and
    $FFF0-$FFFF stays active in IC5** [SVC p.75-p76].
- **Slot cards:** a card's decoder asserts ROM-KIL for the addresses it uses, so the internal ROMs
  release those addresses and IC6 connects the slot data bus [SVC p.75, p.77].

**Fig 6-46** [SVC p.76]:

| Range | (a) standard | (b) +8K RAM | (c) max |
|---|---|---|---|
| $0000-$3FFF | 1st RAM 16K | RAM | RAM |
| $4000-$7FFF | 2nd RAM 16K | RAM | RAM |
| $8000-$9FFF | **IC2, internal expansion ROM socket (8K)** | 3rd RAM 8K | 3rd RAM 16K ($8000-$BFFF) |
| $A000-$BFFF | IC3 BASIC | BASIC | (3rd RAM) |
| $C000-$DFFF | IC4 BASIC | BASIC | 4th RAM 12K ($C000-$EFFF) |
| $E000-$EFFF | IC5 BASIC | BASIC | (4th RAM) |
| $F000-$FFFF | IC5 BASIC/monitor | monitor | monitor |

**MAME check (p.76):** MAME's TODO "RAM3 at 0x8000-0xbfff, RAM4 at 0xc000-0xefff" **matches.**

**Conflicts:**
- **MAME always maps RAM at $8000-$9FFF** (`map(0x8000, 0x9fff).ram()`). On a standard MB-6890 that
  range is an empty ROM socket with no RAM.
- MAME's write-through RAM under $A000-$FFFF exists on the real machine only with RAM3/RAM4 cards
  fitted, or on later models. The ROM decode is read-only (R/W gated), so writes to $A000+ on a
  stock MB-6890 go nowhere.

---

## 11. Power unit (img p080-p082) [SVC p.78-p80]

- An isolated single-forward switching supply gives +5 V (Q1 2SC2749L, IC100 MB3759 PWM).
- +12 V comes from a slaved chopper (IC200 MB3759, Q200/Q201).
- −12 V and −5 V come from 3-terminal regulators (IC400, IC300).
- Protection: inrush (R1 with thyristor TH1), a temperature fuse (TF1), over-current (R107, R207
  into the pin 15/16 current amps), and over-voltage (TH130/Q130 into IC100 pin 4 dead-time; the
  supply latches off until power is cycled).
- Nothing here matters for the FPGA core.

---

## 12. Memory map (Fig 7, img p083) [SVC p.81]

| Range | Use |
|---|---|
| $0000-$03FF | work area (1) |
| $0400-... | display RAM area, (1) to (4) by mode; colour RAM (5-bit) shadows $0400-$43FF |
| after display | work area (2), then the user RAM area |
| $7FFF | top of user RAM (standard) |
| $8000-$9FFF | open |
| $A000-$FEFF | ROM area, BASIC and monitor (24 KB) |
| $FF00-$FFEF | I/O |
| $FFF0-$FFFF | interrupt vectors |

**Display area and user RAM start:**

| Area | Mode | Display area | User RAM head address |
|---|---|---|---|
| (1) | 40 ch normal | 1 KB | $0868 |
| (1)-(2) | 80 ch normal | 2 KB | $0F68 |
| (1)-(3) | 40 ch high res | 8 KB | $2768 |
| (1)-(4) | 80 ch high res | 16 KB | $4768 |

**I/O page, $FFC0 upward (Fig 7):**

| Address | Register |
|---|---|
| FFC0 | PIA |
| FFC4 | ACIA |
| FFC6 | CRTC |
| FFC8 | KB NMI |
| FFC9 | DIP SW |
| FFCA | TIMER |
| FFCB | L.PEN FLG |
| FFCC | open |
| FFD0 | MODE SEL |
| FFD1 | TRACE |
| FFD2 | REMOTE |
| FFD3 | MUSIC SEL |
| FFD4 | TIME MASK |
| FFD5 | L/PEN ENBL |
| FFD6 | INTERLACE SEL |
| FFD7 | **BANK SEL** |
| FFD8 | C-REG SEL |
| FFD9-FFDF | space |
| FFE0 | KB SEL |
| FFE1-FFE7 | space |
| FFE8-FFEF | space |

**Conflicts:**
- The **user manual Table S.2 lists $FFD5 as "Light pen register" and $FFD7 as "Open"**. The
  service manual has $FFD5 = L/PEN ENBL and **$FFD7 = BANK SEL**. **MAME has $FFD7 = baud select.**
  The bit layout of BANK SEL is not given in pp.41-81.
- $FFE8-$FFEF is "space" on the MB-6890. MAME's $FFE8 bank register and $FFE9/$FFEA IG registers
  are Mark 5 additions.

---

## 13. Verification of MAME's service-manual citations

| MAME cite | Printed page (img) | Content | Verdict |
|---|---|---|---|
| p.43 (MODE_SEL) | p.43 (img p045) | Table 6-1 register map and Table 6-2 MODE SEL | Matches (W, HR, C, BG bits) |
| p.48 (clocks) | p.48 (img p050) | Fig 6-6 clock generator and clock spec | Matches |
| p.64 (raster return 2.4 ms) | p.64 (img p066) | Fig 6-27 display spec: 12.7 ms display, 2.4 ms raster return, 1.43 ms VSYNC, 16.7 ms frame | Matches |
| p.65 (keyboard timer = hsync) | p.65 (img p067) | Keyboard: HP 15.75 kHz scan clock | Matches |
| p.67 (ACIA clocks) | p.67 (img p069) | Table 6-14 | Frequencies match; **$FFD7 as baud select is not supported** |
| p.76 (RAM expansion) | p.76 (img p078) | Fig 6-46 | Matches; **default RAM at $8000-$9FFF conflicts** |
| p.88 (DIP switches) | img p090 | outside this range | not checked here |

**Other MAME points:**
- **Timer → FIRQ:** confirmed by Fig 6-2 and the text on p.41. User-manual Table S.2's "(IRQ)" and
  Table 6-1's "Timer IRQ" are loose wording. MAME raises it on every vblank (60 Hz). The source of
  the timer (IC16) is not described in pp.41-81; check the schematics.
- **MAME's `crtc_change_clock` doubles the CRTC clock in interlace** (`<< interlace`). The manual
  gives CHRCK = 1.008 or 2.016 MHz depending only on 40/80. Interlace is done by CRTC programming
  plus the $FFD6 raster remap. **This is a likely MAME hack.**
- **MAME does not implement:**
  - $FFD1 TRACE (the trace counter that raises NMI)
  - $FFCB LPFLG
  - $FFD0 bit 5 (RS/C, cassette vs RS-232C routing)
- **NMI** sources are BREAK (with $FFE0 BM = 1) and the TRACE counter. $FFC8 bit 7 is the BREAK
  flag.
