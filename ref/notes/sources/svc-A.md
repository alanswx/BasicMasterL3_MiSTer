# MB-6890 Service Manual, images 001-042 (printed pp. cover-40)

Source: "HITACHI PERSONAL COMPUTER MB-6890 SERVICE MANUAL", Rev. 0, 30/12/1981 (English).
Local images: `ref/docs/service/MB-6890-service-manual/manualslib-pages/pNNN.jpg`.
Page numbering: image number = printed page + 2 (img005 = printed p.3). Citations below are
[SVC p.<printed>]; the image number is given once per section.

Coverage note: img001-002 are cover pages, img003 is the index, img004-011 are spec/connector/IC
tables, img012-040 are mostly generic datasheet descriptions of each IC type (pinouts, truth
tables), and img041 (printed p.39) is the first page of section 6 "Explanation of the circuit"
(block diagram). **img042 (printed p.40) is blank in the manualslib scan** (white page; either a
genuinely blank page or a failed render) - check against the 1000bit.it PDF if obtained.

MAME's service-manual page citations (p.43 MODE_SEL, p.48 clocks, p.64 raster return, p.65 keyboard
timer, p.67 ACIA clocks, p.76 RAM expansion, p.88 DIP switches) all fall **outside** this range.
Judging from content seen elsewhere (img048 = printed p.46 is the RAM/ROM decoder page, which is
not about clocks), MAME's numbers are most likely *printed* page numbers, i.e. MAME p.48 = img050.
Verify in the svc-B notes.

---

## 1. Index (table of contents) [SVC p.1 / img003]

| No. | Section | Printed page |
|---|---|---|
| 1 | General | 2 |
| 2 | Features | 2 |
| 3 | Specification | 2 |
| 4 | The name of each block | 6 |
| 5 | Function of I.C's used | 8 |
| 6 | Explanation of the circuit | 10 (body actually starts p.39) |
| 7 | Memory map | 81 |
| 8 | Adjustment | 82 |
| 9 | Service points | 85 |
| 10 | The usage of inbuilt switches | 87 |
| 11 | Trouble shootings | 91 |
| 12 | Operation check method | 102 |
| 13 | Basic circuit diagram | (unnumbered, after p.102) |
| 14 | Basic P.C.B. layout | |
| 15 | Waveform of each block | |
| 16 | Parts list | |

(The index says section 6 starts on p.10, but pp.10-38 are the IC datasheet descriptions that
belong to section 5; the section 6 heading "6-1 STRUCTURE" is on p.39.)

## 2. General / features [SVC p.2 / img004]

- MB-6890 is a "multi purpose personal computer" with BASIC in ROM and built-in interfaces for
  expansion [SVC p.2].
- Features [SVC p.2]:
  - Seven-colour graphic display, with separate commands for characters and their background colour.
  - High-resolution colour display up to **640 x 200 pixels**, usable for graphics, and characters
    and graphics can be combined on screen at the same time.
  - "Extended BASIC" and a "Monitor program" in ROM.
  - Standard interfaces for cassette recorder, printer and light pen.
  - Built-in interface connectors for future expansion.

## 3. General specification (Table 3.1) [SVC p.2 / img004]

| Item | Value |
|---|---|
| IC | 143 pcs (CPU board), 4 pcs (power unit) |
| Transistor | 7 pcs (CPU), 8 pcs (power unit) |
| Diode | 10 pcs (CPU), 25 pcs (power unit) |
| Speaker output | 0.4 W |
| Speaker | 6 x 9 cm (16 ohm), 1 pc |
| Input/Output | Cassette tape recorder connector (CASSETTE); Light pen connector (L/PEN); Colour display connector (COLOR); Monochrome display connector (B/W); RS-232C connector (RS-232C); Printer connector (PRINTER) |
| Built-in connectors | Expansion connectors (I/F-1 to I/F-6); Memory expansion connectors (RAM3, RAM4) |
| Power | AC 100 V (50/60 Hz) |
| Power consumption | 30 W (without memory expansion or interface cards) |
| Dimensions | 45.0 (W) x 12.5 (H) x 51.5 (D) cm |
| Weight | 7 kg |

(Printed p.3, img005, was not in the downloaded set as a spec page: img005 is printed p.3 =
the connector pin tables below. If there was a further spec table (CPU/clock/RAM) on a page
between, it is not in this scan. Clock/CPU details must come from section 6.)

## 4. Connector pin signals (section 3-2) [SVC p.3-5 / img005-007]

Direction column: "CPU -> out" means the signal is output from the computer.

### 4.1 CASSETTE (DIN, 6 pins used) [SVC p.3]

| Pin | Signal | Dir | | Pin | Signal | Dir |
|---|---|---|---|---|---|---|
| 1 | remote | out | | 2 | GND | - |
| 3 | record | out | | 4 | remote | out |
| 5 | play | in | | 6 | (n.c.) | |

Remote (motor) is a relay contact pair on pins 1 and 4.

### 4.2 L/PEN light pen [SVC p.3]

| Pin | Signal | Dir | | Pin | Signal | Dir |
|---|---|---|---|---|---|---|
| 1 | /LP OUT | in | | 2 | /LP-SW | in |
| 3 | +5 V | out | | 4 | LP VCMP | out |
| 5 | GND | | | | | |

(LP OUT = light pen detector pulse, LP-SW = pen switch, LP VCMP = comparator reference voltage.)

### 4.3 COLOR display (8-pin) [SVC p.3]

| Pin | Signal | Dir | | Pin | Signal | Dir |
|---|---|---|---|---|---|---|
| 1 | +12 V | out | | 2 | GND | |
| 3 | /PEDSTL (pedestal/blanking) | out | | 4 | /H SYNC | out |
| 5 | /V SYNC | out | | 6 | R | out |
| 7 | G | out | | 8 | B | out |

Digital (TTL) RGB with separate negative syncs and a pedestal (blanking) signal.

### 4.4 RS-232C (DB-25) [SVC p.3]

| Pin | Signal | Dir |
|---|---|---|
| 2 | TxD | out |
| 3 | RxD | in |
| 4 | RTS | out |
| 5 | CTS | in |
| 7 | GND | |
| 8 | DCD | in |
| all others (1, 6, 9-25) | not connected | |

### 4.5 PRINTER (36-pin, Centronics-style) [SVC p.4 / img006]

| Pin | Signal | Dir | | Pin | Signal | Dir |
|---|---|---|---|---|---|---|
| 1 | /STRB | out | | 2 | D0 | out |
| 3 | D1 | out | | 4 | D2 | out |
| 5 | D3 | out | | 6 | D4 | out |
| 7 | D5 | out | | 8 | D6 | out |
| 9 | D7 | out | | 10 | /ACK | in |
| 11 | BUSY | in | | 16 | GND | |
| 33 | GND | | | others | n.c. | |

(The printer port is driven by the PIA HD46821P, IC85 - see block diagram.)

### 4.6 Memory expansion RAM3 / RAM4 (28-pin) [SVC p.4 / img006]

RAM3 is for **$8000-$BFFF**; RAM4 is for **$C000-$EFFF** (footnotes *1 and *2).

| Pin | RAM3 | RAM4 | Dir | | Pin | RAM3 | RAM4 | Dir |
|---|---|---|---|---|---|---|---|---|
| 1 | +12V | +12V | out | | 2 | GND | GND | |
| 3 | +5V | +5V | out | | 4 | -5V | -5V | out |
| 5 | D0 | D0 | bidir | | 6 | D1 | D1 | bidir |
| 7 | D2 | D2 | bidir | | 8 | D3 | D3 | bidir |
| 9 | D4 | D4 | bidir | | 10 | D5 | D5 | bidir |
| 11 | D6 | D6 | bidir | | 12 | D7 | D7 | bidir |
| 13 | AR0 | AR0 | out | | 14 | AR1 | AR1 | out |
| 15 | AR2 | AR2 | out | | 16 | AR3 | AR3 | out |
| 17 | AR4 | AR4 | out | | 18 | AR5 | AR5 | out |
| 19 | AR6 | AR6 | out | | 20 | /RAS | /RAS | out |
| 21 | /CAS phi2 | /CAS phi2 | out | | 22 | /WE1 | /WE1 | out |
| 23 | /ROM-KIL | /ROM-KIL | in | | 24 | R/W OUT | R/W OUT | out |
| 25 | /A89-SEL | /ACD SEL | out | | 26 | /AAB SEL | /AE SEL | out |
| 27 | GND | GND | | | 28 | +12V | +12V | out |

Engineering reading:
- The connectors carry the **multiplexed DRAM address (AR0-AR6), RAS, CAS and WE** directly -
  i.e. expansion RAM boards are bare 16K DRAM (4116-type, +12/+5/-5 V) driven by the main board's
  DRAM controller, not decoded CPU-bus RAM.
- Per-8K/4K block select lines: RAM3 gets /A89-SEL ($8000-$9FFF) and /AAB-SEL ($A000-$BFFF);
  RAM4 gets /ACD-SEL ($C000-$DFFF) and /AE-SEL ($E000-$EFFF).
- **/ROM-KIL is an input from the RAM card**, so a fitted RAM card can disable the BASIC ROM to put
  RAM in its place (RAM-under-ROM is a function of the expansion card, not the base machine).
- **No RAM exists at $8000-$EFFF on a base MB-6890.** The base machine has 32 KB main RAM only
  (see block diagram and IC list).

>>> MAME CONFLICT: `bml3.cpp` maps `0x8000-0x9fff` as RAM unconditionally (line ~346). On the base
MB-6890 this region is unpopulated unless a RAM3 card is fitted (and $8000-$9FFF is also the empty
"BASIC expansion" ROM socket IC2, per p.46 Table 6-5). MAME's own TODO already says RAM3/RAM4 should
be bus slots.

### 4.7 Interface expansion I/F-1 to I/F-6 (56-pin) [SVC p.5 / img007]

| Pin | Signal | Dir | | Pin | Signal | Dir |
|---|---|---|---|---|---|---|
| 1 | +5V | out | | 2 | GND | |
| 3 | D0 | bidir | | 4 | D1 | bidir |
| 5 | D2 | bidir | | 6 | D3 | bidir |
| 7 | D4 | bidir | | 8 | D5 | bidir |
| 9 | D6 | bidir | | 10 | D7 | bidir |
| 11 | A0 | bidir | | 12 | A1 | bidir |
| 13 | A2 | bidir | | 14 | A3 | bidir |
| 15 | A4 | bidir | | 16 | A5 | bidir |
| 17 | A6 | bidir | | 18 | A7 | bidir |
| 19 | A8 | bidir | | 20 | A9 | bidir |
| 21 | A10 | bidir | | 22 | A11 | bidir |
| 23 | A12 | bidir | | 24 | A13 | bidir |
| 25 | A14 | bidir | | 26 | A15 | bidir |
| 27 | BA | out | | 28 | BS | out |
| 29 | /ROM-KIL | in | | 30 | /EXROM-KIL | in (arrow drawn as out; ambiguous) |
| 31 | R/W IN | in | | 32 | /EX-I/O | out |
| 33 | R/W OUT | out | | 34 | VMA OUT | out |
| 35 | E | out | | 36 | Q | out |
| 37 | /RES | out | | 38 | /NMI | in |
| 39 | /IRQ | in | | 40 | /FIRQ | in |
| 41 | /HALT | in | | 42 | /VMA CTRL | in |
| 43 | /DMA | in | | 44 | /BANK-SW | out |
| 45 | HALT ACK | out | | 46 | SOUND IN | in |
| 47 | 16MCK | out | | 48 | GND | |
| 49 | 2MCK | out | | 50 | GND | |
| 51 | -5V | out | | 52 | /EX-I/O2 | out |
| 53 | -12V | out | | 54 | +12V | out |
| 55 | GND | | | 56 | +5V | out |

Engineering reading:
- Address lines are bidirectional (with R/W IN, /DMA, /VMA CTRL and HALT ACK, a card can become bus
  master - DMA support on the slot bus).
- /EX-I/O and /EX-I/O2 are pre-decoded I/O selects for cards (other docs: $FF00-$FF7F and
  $FF80-$FFBF; the manual's I/O map calls $FF00-$FFBF "open").
- /ROM-KIL lets a card disable the internal BASIC ROM; /EXROM-KIL presumably disables the
  expansion ROM socket (IC2, $8000-$9FFF).
- **/BANK-SW is a CPU-board output** to the slots: there is a bank-switch signal on the base MB-6890
  bus (source register not described in this page range; see section 6).
- SOUND IN: cards can feed audio into the internal speaker amplifier (used by PSG cards).
- 16MCK and 2MCK clocks are exported to cards (16 MHz-class and 2 MHz-class; consistent with
  32.256 MHz / 2 = 16.128 MHz and /16 = 2.016 MHz, but the exact values are not stated on these
  pages).

## 5. Explanation of each part [SVC p.6-7 / img008-009]

Operation panel (switches are under a cover above the keyboard) [SVC p.6]:
1. POWER switch: push on (red light on), push again off.
2. VOLUME: controls the keyboard click sound and speaker volume.
3. **MODE switch: selects characters/line - "1" = 80 ch/line, "0" = 40 ch/line.** (A hardware
   switch; the ROM reads it at power-on/reset to choose the initial width. Where it is read is
   not given here - likely the $FFC9 DIP/switch port; see later sections.)
4. RESET switch: triggers RESET, "stops executing the BASIC program, and returns to command
   level" - i.e. a warm restart that preserves the program (consistent with the ROM's warm-start
   flag behaviour).

Rear connectors [SVC p.7]: six standard interfaces - (1) cassette, (2) light pen (MP-3700),
(3) colour monitor (C14-2170), (4) monochrome monitor (green, K12-2055P), (5) RS-232C,
(6) printer; plus the I/F-1..I/F-6 expansion edge. "The six pairs of interface expansion
connectors and two pairs of memory expansion connectors are inside the MB-6890."

## 6. IC list (section 5, "IC's in use") [SVC p.8-9 / img010-011]

| No. | Class | Type | Circuit no. | Function (as printed; corrections in brackets) |
|---|---|---|---|---|
| 1 | MPU | HD6809P / MC6809L | IC1 | Central processing unit (internal-clock 6809, EXTAL/XTAL input) |
| 2 | LSI | HD46505SP | IC36 | CRTC |
| 3 | LSI | HD46821P | IC85 | PIA |
| 4 | LSI | HD46850P | IC84 | ACIA |
| 5 | RAM | HM4716AP-1 | IC56-IC76 (21 chips: IC56,57,58,59,60,61,62,63,64,65,66,67,68,69,70,71,72,73,74,75,76) | RAM (16K x 1 dynamic) |
| 6 | ROM | uPD2364C-330 | IC3 | BASIC ROM |
| 7 | ROM | uPD2364C-331 | IC4 | BASIC ROM |
| 8 | ROM | uPD2364C-332 | IC5 | BASIC, monitor ROM |
| 9 | ROM | uPD2332C-328 | IC107 | Characters, graphic ROM (character generator) |
| 10 | gate | HD74LS00P | IC26, IC28, IC47, IC125, IC129, IC145 | 2-input NAND |
| 11 | | HD74LS02P | IC33, IC34, IC46, IC94, IC142 | 2-input NOR |
| 12 | | HD74LS04P | IC23, IC31, IC44, IC91, IC100 | inverter |
| 13 | | HD74LS05P | IC22, IC95, IC105 | open-collector inverter |
| 14 | | HD74LS08P | IC25, IC48, IC49, IC92, IC96, IC136, IC143, IC146 | 2-input AND (printed "NAND") |
| 15 | | HD74LS10P | IC27, IC45 | 3-input NAND (printed "AND") |
| 16 | | HD74LS11P | IC138 | 3-input AND |
| 17 | | HD74LS14P | IC21 | Schmitt-trigger inverter |
| 18 | | HD74LS30P | IC30, IC104 | 8-input NAND (printed "AND") |
| 19 | | HD74LS32P | IC29, IC32, IC97, IC144 | 2-input OR (printed "NOR") |
| 20 | | HD74LS74AP | IC14, IC16, IC17, IC18, IC50, IC83, IC93, IC99, IC103, IC126, IC130 | D flip-flop |
| 21 | | HD74LS86P | IC35, IC131 | XOR |
| 22 | | HD74LS93P | IC15, IC101, IC102, IC122, IC123, IC124, IC134 | 4-bit binary counter (printed "4 bit 2 decimal counter") |
| 23 | | HD74LS125AP | IC24, IC98 | bus buffer (tri-state) |
| 24 | | HD74LS138P | IC12, IC13 | 3-to-8 decoder |
| 25 | | HD74LS139P | IC11, IC137 | dual 2-to-4 decoder |
| 26 | | HD74LS151P | IC90 | 8-to-1 multiplexer |
| 27 | | HD74LS153P | IC112 | dual 4-to-1 multiplexer |
| 28 | | HD74LS157P | IC38, IC51, IC111, IC141 | quad 2-to-1 mux |
| 29 | | HD74LS158P | IC118 | quad 2-to-1 mux (inverting) |
| 30 | | HD74LS164P | IC42 | 8-bit serial-in parallel-out shift register |
| 31 | | SN74LS166P | IC117 | 8-bit parallel-in shift register (video shifter) |
| 32 | | HD74LS174P | IC39, IC77, IC81, IC82, IC89, IC108, IC109, IC115 | hex D flip-flop |
| 33 | | HD74LS175P | IC116 | quad D flip-flop |
| 34 | | SN74LS245N | IC6 | bus transceiver (data bus buffer) |
| 35 | | HD74LS257P | IC113, IC114 | quad 2-to-1 mux, tri-state |
| 36 | | HD74LS283P | IC40 | 4-bit binary full adder (printed "4 bit 2 decimal adder") |
| 37 | | HD74LS367AP | IC7, IC8, IC9, IC10, IC19, IC20, IC41, IC78, IC79, IC80, IC88, IC139, IC140 | hex bus driver (tri-state) |
| 38 | | HD74S04P | IC43 | inverter (Schottky) |
| 39 | | HD74S05 | IC132 | open-collector inverter (Schottky) |
| 40 | | SN74S163N | IC37 | 4-bit synchronous counter (Schottky) - the master clock divider (MAME: "IC37 4.032 MHz") |
| 41 | | HD7405P | IC135 | open-collector inverter |
| 42 | | HD74153P | IC52, IC53, IC54, IC55 | dual 4-to-1 mux (DRAM address multiplexer) |
| 43 | | HD74159P | IC86 | 4-to-16 decoder, open collector |
| 44 | other | HD75108AP | IC128 | dual line receiver |
| 45 | other | HD75188P | IC119 | quad line driver (RS-232C, printed "receiver") |
| 46 | other | HD75189P | IC120 | quad line receiver (RS-232C) |
| 47 | other | LM565CN | IC127 | FSK signal demodulation PLL (cassette read) |

Engineering reading of the IC list:
- **RAM: 21 x HM4716 (16K x 1).** 16 chips = 32 KB main RAM; the other **5 chips = 16K x 5-bit
  colour (attribute) RAM** (block diagram labels it "Colour RAM 5bit x 16K"). This confirms a
  5-bit attribute per VRAM byte ($0400-$43FF), matching MAME's 5-bit attribute RAM.
- **Cassette input is demodulated by an LM565 PLL (IC127)**, i.e. analog FSK demodulation to a bit
  stream that goes to the ACIA; the core can model the cassette as a clean bit stream at the ACIA RxD.
- The 6809 variant is the internal-clock type (HD6809P/MC6809L, with XTAL/EXTAL), clocked from
  IC37 (74S163) via EXTAL; the 6809 divides by 4 internally.
- HD74159 (IC86, 4-to-16 open-collector) and LS138s (IC12, IC13) are the likely $FFxx I/O decoders.
- SN74LS166 (IC117) is the pixel shifter; LS153s (IC52-55) are the DRAM row/column address muxes;
  LS257s (IC113/114) / LS157s are the CPU/CRTC address switch ("Address change switch" in the
  block diagram).

## 7. IC descriptions (section 5 body) [SVC p.10-38 / img012-040]

Mostly standard datasheet text. Machine-specific facts extracted:

- HD6809P/MC6809L pinout and pin functions [SVC p.10-12 / img012-014]: standard internal-clock
  6809 (pin 38 EXTAL, 39 XTAL, 36 MRDY, 33 DMA/BREQ). Notes: the reset vector is at $FFFE/$FFFF;
  the RES pin has a Schmitt trigger, "a simple R/C network may be used to reset the entire
  system" (the MB-6890 uses an R/C power-on reset); address is valid on the rising edge of Q and
  data is latched on the falling edge of E; MRDY allows E/Q stretching; DMA/BREQ "Typical uses
  include DMA and dynamic memory refresh". Table "MPU State Definition": BA/BS = 00 running,
  01 interrupt/reset acknowledge, 10 SYNC acknowledge, 11 HALT or bus grant [SVC p.11].
- HD46821P PIA [SVC p.12-14 / img014-016]: generic. CS0/CS1 high and /CS2 low select it; RS0/RS1
  select registers; /IRQA and /IRQB are open-drain (wire-OR). No MB-6890-specific port usage on
  these pages.
- HD46850P ACIA [SVC p.14-16 / img016-018]: generic. CS0, CS1 high, /CS2 low; RS high = data
  registers, low = control/status. Clock inputs: "Clock frequencies of 1, 16 or 64 times the data
  rate may be selected." Tx clocks out on the falling edge of TxCLK; Rx samples on the rising
  edge of RxCLK. /DCD high inhibits and resets the receiver; a low-to-high transition of /DCD
  raises an interrupt when RIE is set. RTS output follows CR5/CR6.
- HD46505SP CRTC [SVC p.16-17 / img018-019]: generic HD46505 description: 18 control registers
  plus the address register; RS normally from A0; E from the system phi2; RES (pin 2) "has
  capability of reset function only when LPSTB is at Low level"; after RES goes high the CRTC
  starts display immediately; HSYNC, VSYNC, DISPTMG and CUDISP are active-high; MA0-MA13 refresh
  address ("enables 16k words max ... up to 2000 characters/screen and 8-page system");
  RA0-RA4 raster address; LPSTB is active-high and latches MA0-MA13 into the 14-bit light-pen
  register, which "need to be corrected in software" for display/pen delays.
- HM4716AP-1 [SVC p.17 / img019]: 16,384-bit dynamic RAM, 7 multiplexed address lines (128 rows x
  128 columns), /RAS, /CAS, /WE, Din/Dout; supplies +5, +12 (VDD) and -5 (VBB) per the pinout.
  128-row refresh is required (the CRTC scan provides it in practice - see section 6).
- uPD2364C [SVC p.18 / img020]: 8 KB mask ROM, /CS low active. **Table 5-2:**

  | ROM | Address |
  |---|---|
  | uPD2364C-330 | $A000-$BFFF |
  | uPD2364C-331 | $C000-$DFFF |
  | uPD2364C-332 | $E000-$FEFF and $FFF0-$FFFF |

  "Basic and Monitor System Program is written in three pieces of ROM" (the text says
  uPD2364C-331 and "uPD2363C-332", a typo). The I/O hole $FF00-$FFEF is cut out of the -332 ROM;
  the vectors $FFF0-$FFFF come from the top of the -332 ROM.
- uPD2332C-328 [SVC p.19 / img021]: **4 KB mask ROM used as the character generator**, 12 address
  lines A0-A11, /CS1 = L and CS2 = H to enable. (4 KB = 256 characters x 16 bytes: consistent with
  8x16-row cells for the interlaced/high mode or 8x8 used twice; the cell height is not stated
  here.)
- 74-series pages [SVC p.20-38 / img022-040]: generic pinouts and truth tables for LS00, LS02,
  LS04/S04, LS05/S05/7405, LS08, LS10, LS11, LS14, LS30, LS32, LS74, LS86, LS93, LS125, LS138,
  LS139, LS151, LS153/74153, LS157, LS158, 74159, S163, LS164, LS166, LS174, LS175, LS245, LS257,
  LS283, LS367, 75108, 75188, 75189, LM565. Machine-specific notes only: the circuit diagram uses
  a distinct symbol for open-collector inverters and for Schmitt-trigger inverters [SVC p.22-24];
  HD75188/75189 are the +-12 V RS-232C line driver/receiver [SVC p.37-38]; LM565 = phase
  detector + VCO + amplifier [SVC p.38].

## 8. Block diagram (Figure 6-1, "6-1 STRUCTURE") [SVC p.39 / img041]

Blocks and connections (read from the figure; a zoomed crop was examined):

- **MPU 6809**, EXTAL fed from the **clock generator** (crystal symbol), which also clocks the CRTC
  (the "Timing signal generate block").
- **Interrupt sources as drawn:**
  - **NMI**: from the **Trace Counter** and from the keyboard **BREAK** key.
  - **FIRQ**: from the **Timer**. The Timer is clocked from the CRTC (a line runs from the CRTC to
    the Timer), i.e. a video-derived periodic timer.
  - **IRQ**: from the **Light pen F/F** (and very likely the keyboard, ACIA and PIA; the drawing is
    too coarse to be sure which other blocks join the IRQ line).
- ROM 24 KB (Monitor/BASIC) on the data bus.
- CRTC HD46505SP -> "High resolution flag" -> "Address change switch" (selects CPU vs CRTC
  address, and the hi-res address arrangement) -> **Main RAM (32 KB)** and **Colour RAM
  (5 bit x 16K)**.
- **Colour register** sits between the data bus and colour RAM (the $FFD8 latch that is
  written into colour RAM on CPU writes and loaded from it on CPU reads).
- Video signal generator block: two latches -> "Serial/parallel row change" (shift register) ->
  "Colour video signal generator" (fed by colour RAM) -> **Colour display**; and "Composite signal
  generator" -> **Monochrome signal**. The character generator ROM and a "Graph generator" sit on
  the RAM-data path (text mode goes through the character ROM; graphics mode bypasses it).
- Keyboard -> keyboard interface on the data bus.
- **Cassette / RS-232C switch** in front of the **ACIA HD46850P**: one ACIA shared between cassette
  and RS-232C (selected by $FFD0 bit 5 per other sources) -> cassette recorder I/F and RS-232C I/F.
- **PIA HD46821P -> printer drive -> printer connector.**
- Speaker I/F -> acoustic output amp -> speaker (volume control on the panel).
- Buffers -> RAM expansion terminals (RAM3/RAM4) and the expansion terminals (I/F-1..6).

>>> Interrupt routing vs other sources:
- The block diagram draws the **Timer on FIRQ**, which **agrees with MAME** (FIRQ timer) and
  **disagrees with the English User Manual Table S.2**, which labels $FFCA "Timer interrupt
  (IRQ)", and with the Peach ROM Notes (IRQ). Treat this as unresolved until the schematic
  pages (svc-C) or the circuit text for the timer (svc-B, around printed p.64-65) are checked.
- The **Trace Counter on NMI** confirms the Peach ROM Notes' "$FFD1 TRACE: write raises an NMI a
  few cycles later" (MAME does not implement it).
- **BREAK on NMI** agrees with MAME's keyboard NMI, but the Peach ROM Notes say the ROM polls
  $FFC8 and its NMI handler is just RTI, which fits: BREAK pulls NMI, and $FFC8 is the flag the
  ROM reads.

## 9. Things NOT on these pages (look in svc-B / svc-C)

- Crystal frequency and the clock tree (MAME cites p.48; not here).
- The I/O register map and bit definitions ($FFD0 etc.; MAME cites p.43 for MODE_SEL).
- CRTC register values, video timing, keyboard scan timing (MAME p.64/65), ACIA clocks (p.67),
  RAM expansion configuration (p.76), DIP switches (p.88).
- Any further spec table (CPU clock, RAM size, display spec) between printed p.2 and p.3: the scan
  goes straight from the general spec table (p.2) to the connector pin tables (p.3), so there is
  no separate CPU/video spec table in this manual's section 3.

## 10. MAME cross-check summary for this range

| Topic | Service manual | MAME | Verdict |
|---|---|---|---|
| $8000-$9FFF | Unpopulated on base unit; RAM3 card (with /A89-SEL) or the IC2 "BASIC expansion" ROM socket | RAM always | **Conflict** (MAME TODO acknowledges) |
| RAM4 range | $C000-$EFFF | not modelled | MAME gap |
| ROM layout | -330 $A000, -331 $C000, -332 $E000-$FEFF + $FFF0-$FFFF | 3 x 8 KB at A000/C000/E000 | Agrees; ROM names in MAME (`598 p16611.ic3` etc.) are different part markings from the uPD2364C-330/331/332 listed here |
| Character ROM | uPD2332C-328, 4 KB, IC107 | `font.rom` (handcrafted) | MAME font size should be checked against 4 KB |
| Colour RAM | 5 x 16K x 1 = 5 bits per cell | 5-bit attribute | Agrees |
| Timer interrupt | Block diagram: Timer -> FIRQ | FIRQ | Agrees (but User Manual says IRQ) |
| Trace counter | Trace Counter -> NMI | not implemented | **MAME gap** |
| /BANK-SW on slots | CPU-board output on I/F pin 44 | `$FFE8` bank reg only on Mark 5 | Note: a bank-switch line exists on the original MB-6890 bus |
