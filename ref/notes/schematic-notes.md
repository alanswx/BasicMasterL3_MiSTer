# MB-6890 circuit notes (from the service manual's circuit explanation)

Compiled 2026-10-21. Citation keys as in `hardware-from-manuals.md` ([SVC p.N] = printed page of the
MB-6890 Service Manual; image file = printed + 2).

## Status of the schematics

- **The foldout circuit diagram, PCB layout and waveform sections (TOC items 13-15) are not in the copy
  we have.** The manualslib scan (`ref/docs/service/MB-6890-service-manual/manualslib-pages/`) goes
  from the last test listing (printed p.113) straight to the parts list (p.114); images p122-p123 are
  blank watermark pages [SVC p.1, p.113-114].
- What we do have is better than a bare schematic in places: a 40-page **circuit explanation**
  (printed pp.39-80) with block-level figures of every section, signal names, IC numbers and pin
  numbers, the full IC parts list, and troubleshooting charts that name IC pins per function. The notes
  below come from those. Roles that come only from the troubleshooting charts are marked *(chart)*.
- Leads for the real schematic: the 29 MB copy of the same manual on 1000bit.it
  (`https://www.1000bit.it/support/manuali/download.asp?id=1083`, free registration required) may
  include the foldouts; the defunct computerarchive.org copy
  (`files/comp/manuals/hitachi/Hitachi Personal Computer MB-6890 Service Manual.pdf`); the
  MP-1802 technical manual does include the **MP-1802 card schematic** (§9).
- s-sasaji cites the books I/O別冊「ベーシックマスター活用研究」 and 「S1活用研究」 (工学社) and an MB-S1
  schematic published in I/O magazine; his site reproduces the S1 keyboard circuit
  (`ref/web/s-sasaji/.../s1kbcircuit.htm`) [sasaji:s1kbcircuit.htm].

Detail and full transcriptions: `sources/svc-A.md` (pp.1-40), `sources/svc-B.md` (pp.41-81),
`sources/svc-C.md` (pp.82-119), `sources/svc-schematic.md` (chart-based chip roles).

---

## 1. Chip list by function [SVC p.8-9, p.114-117 parts list; roles from pp.41-81]

### CPU, ROM, bus

| IC | Part | Role |
|---|---|---|
| IC1 | HD6809P / MC6809L | MPU, EXTAL = 4.032 MHz [SVC p.44] |
| IC2 | (empty socket) | 8 KB "BASIC expansion" ROM, `$8000-$9FFF` [SVC p.46] |
| IC3 / IC4 / IC5 | µPD2364C-330 / -331 / -332 | 8 KB mask ROMs at `$A000` / `$C000` / `$E000-$FEFF` + `$FFF0-$FFFF` [SVC p.46] |
| IC6 | SN74LS245N | Data bus buffer to RAM3/RAM4 and slots; ROM, RAM, PIA, ACIA, CRTC sit directly on D0-7 [SVC p.44] |
| IC7-IC9 | 74LS367 | Address buffers to slots, RAM, ROM, decoders [SVC p.44] |
| IC9/IC25 | 74LS08 | VMA from BA/BS [SVC p.44] |
| IC10 | 74LS367 | Q and reset to slots [SVC p.44] |
| IC21, IC22 | 74LS14, 74LS05 | Reset switch path; IC22 = open-collector wired-OR interrupt drivers [SVC p.44] |
| IC24 | 74LS125 | R/W buffer [SVC p.44] |
| IC41 | 74LS367 | E out as ETTL [SVC p.44] |
| IC11 | 74LS139 | ROM decoder (AB13/AB14, enabled on reads of `$8000-$FFFF`) [SVC p.45] |
| IC26 | 74LS00 | NAND(AB15, R/W) enable for IC11 [SVC p.45] |
| IC138 | 74LS11 | ROM-KIL AND (slot pin 29, RAM3/RAM4 pin 23) [SVC p.45] |
| IC30 | 74LS30 | `$FFxx` detect (AB8-AB15) [SVC p.45] |
| IC12 | 74LS138 | I/O block decoder (AB3-5, G1 = AB6, G2 from IC30/AB7) [SVC p.45] |
| IC13 (and IC11 half) | 74LS138 | Register strobes from AB0-2 [SVC p.45] |
| IC33 | 74LS02 | RAM1 SEL / RAM2 SEL from AB15/AB14 [SVC p.46] |
| IC137 | 74LS139 | RAM3/RAM4 block selects from AB15-AB11 [SVC p.46] |
| IC19, IC20 | 74LS367 | DIP switch read buffers (`$FFC9`) [SVC p.43] |

### Clock and timing

| IC | Part | Role |
|---|---|---|
| X1 | 32.256 MHz crystal (no value in the parts list) | Frequency given on [SVC p.41, p.48] |
| IC43 | 74S04 | 3rd-overtone oscillator with L1/C201 tank [SVC p.49] |
| IC37 | 74S163 (parts list: SN74LS163N) | ÷2/÷4/÷8/÷16: QA 16.128, QB 8.064, QC 4.032, QD 2.016 MHz [SVC p.48-49] |
| IC42 | 74LS164 | Shifts E with 16.128 MHz; taps QA-QH (62.5 ns) make CHRCK, LOAD, GRENBL, RAS, CAS, MPU DISP SW [SVC p.50-51] |
| IC38 | 74LS157 | 40/80 selection of DOTCK, LOAD, CHRCK, GRENBL [SVC p.52] |
| IC28, IC34, IC35, IC45, IC46 | gates | Timing gates [SVC p.50-51] |
| IC140 | 74LS367 | CPU-grade timing jumpers JP9/JP10 [SVC p.83] |

### Memory and video

| IC | Part | Role |
|---|---|---|
| IC56-IC63, IC69-IC76 | HM4716AP-1 | 32 KB main DRAM (`$0000-$3FFF`, `$4000-$7FFF`) [SVC p.57-58] |
| IC64-IC68 | HM4716AP-1 | 16K × 5 colour RAM (B, R, G, RV, GC) [SVC p.57-58] |
| IC52-IC55 | 74153 | DRAM address multiplexers (CPU/CRTC, row/column) *(chart)* [SVC p.94] |
| IC77 | 74LS174 | **Colour register** ($FFD8), drives colour RAM DIN [SVC p.58-59] |
| IC78, IC79 | 74LS367 | Colour register bus buffers (each direction) [SVC p.58-59] |
| IC80, IC139 | 74LS367 | RAM data to CPU *(chart)* [SVC p.92, p.94] |
| IC36 | HD46505SP | CRTC; CLK = CHRCK, LPSTB from the light pen [SVC p.52-53] |
| IC47, IC49, IC50 | 74LS00/08/74 | Force a valid CRTC address at power-on in 80 col [SVC p.55] |
| IC39 | 74LS174 | **MODE SEL latch** ($FFD0): HRSO-SW, RS/C SW, background colour [SVC p.43, p.60, p.65] |
| IC40 | 74LS283 | Adds raster×1024/2048 into MA10-13 for hi-res [SVC p.54] |
| IC51 | 74LS157 | Raster-to-adder select (40/80), /G = HRSO-SW [SVC p.54] |
| IC130 | 74LS74 | `$FFD6` interlace latch (D3) [SVC p.54] |
| IC141 | 74LS157 | Interlace raster remap RA → RAA [SVC p.54] |
| IC107 | µPD2332C-328 | 4 KB character generator [SVC p.60-62] |
| IC112 | 74LS153 | Semigraphic block select (RAA2/RAA3) [SVC p.61] |
| IC113, IC114 | 74LS257 | Graphic generator output (hi-res vs semigraphic) [SVC p.61] |
| IC129 | 74LS00 | G/C enable gating [SVC p.61] |
| IC117 | SN74LS166 | Pixel shift register [SVC p.60] |
| IC115 / IC116 | 74LS174 / 74LS175 | Attribute + cursor + DISPTMG latches, per character then per dot [SVC p.60] |
| IC131, IC136 | 74LS86, 74LS08 | Reverse and cursor XOR [SVC p.60] |
| IC118 | 74LS158 | Foreground/background colour select [SVC p.60] |
| IC132, IC135 | 74S05, 7405 | RGB and sync outputs, monochrome mix with Q5 [SVC p.60-64] |
| IC134 | 74LS93 | Regenerated 4 µs HSYNC [SVC p.63] |

### Keyboard, interrupts, I/O

| IC | Part | Role |
|---|---|---|
| IC101, IC102 | 74LS93 | X and Y scan counters (clocked by HP) [SVC p.65] |
| IC86 | 74159 | 4→16 column driver [SVC p.65] |
| IC90 | 74LS151 | 8→1 row sense [SVC p.65] |
| IC97 | 74LS32 | HP gate; keyboard read strobe [SVC p.65] |
| IC99 | 74LS74 | Counter-stop flip-flop; BREAK latch half [SVC p.65, p.96] |
| IC96 | 74LS08 | Key IRQ AND mask (SS) [SVC p.65] |
| IC88, IC98 | 74LS367, 74LS125 | Key code / BREAK onto the bus [SVC p.65] |
| IC89 | 74LS174 | `$FFE0` write latch (BM, SS, UE, LEDs) [SVC p.43] |
| IC14, IC15 | 74LS74, 74LS93 | TRACE counter → NMI [SVC p.43, p.91] |
| IC16, IC17 | 74LS74 | Timer flag / time mask → FIRQ [SVC p.43, p.98] |
| IC18, IC24, IC25 | 74LS74 etc. | Light pen flag/enable → IRQ, LPSTB [SVC p.43, p.73] |
| IC84 | HD46850P | ACIA at `$FFC4-5` [SVC p.72] |
| IC111 | 74LS157 | Cassette / RS-232C clock and RxD switch (RS/C SW) [SVC p.65, p.67] |
| IC122-IC124 | 74LS93 | Baud and FSK tone dividers [SVC p.67] |
| IC125, IC126 | 74LS00, 74LS74 | FSK modulator; IC126 also the `$FFD2` relay latch [SVC p.68, p.72] |
| IC127 | LM565CN | Cassette PLL demodulator [SVC p.68] |
| IC128 | HD75108 | PLL output comparator [SVC p.68] |
| IC119, IC120 | HD75188, HD75189 | RS-232C driver and receiver [SVC p.69] |
| IC85 | HD46821P | PIA at `$FFC0-3` [SVC p.72] |
| IC93 | 74LS74 | Speaker latch (`$FFD3` D7) and printer STRB [SVC p.73-74] |
| IC94, IC95, IC105 | 74LS02, 74LS05 | Printer BUSY/ACK and data drivers [SVC p.73] |

---

## 2. Clock tree [SVC p.48-52]

```
X1 32.256 MHz -> IC43 (74S04 osc) -> IC37 (74S163)
   QA 16.128 MHz -> 80-col DOTCK; IC42 shift clock; RS-232C divider; slot 16MCK
   QB  8.064 MHz -> 40-col DOTCK
   QC  4.032 MHz -> 6809 EXTAL (E = Q = 1.008 MHz)
   QD  2.016 MHz -> 80-col CHRCK (CRTC CLK); slot 2MCK
E (1.008 MHz) -> 40-col CHRCK; cassette divider (9.6 kHz ACIA clock, 2.4/1.2 kHz tones)
IC42 (74LS164, E shifted by 16.128 MHz) -> CHRCK, LOAD, GRENBL, RAS, CAS phi1/phi2, MPU DISP SW
IC38 (74LS157) picks the 40- or 80-column versions
CRTC HSYNC (15.75 kHz) -> keyboard scan clock HP; IC134 regenerates a 4 us HSYNC from E
```

## 3. Address decoding [SVC p.45-48]

```
ROM:  IC26 = NAND(AB15, R/W) enables IC11 (AB14, AB13) -> $8000/$A000/$C000/$E000 blocks
      each gated with /ROM-KIL (IC138) ; IC5 also gated off in $FF00-$FFEF (IC33 output)
I/O:  IC30 = NAND(AB15..AB8) -> IC12 (C,B,A = AB5,AB4,AB3 ; G1 = AB6 ; G2 = IC30, AB7)
        Y0 $FFC0-7  -> "IN LSI SEL": PIA (AB2=0), ACIA (AB2=1, AB1=0), CRTC (AB2=1, AB1=1)
        Y1 $FFC8-F  -> KBNMI, DIPSW, TIMER, LPFLG
        Y2 $FFD0-7  -> MODE, TRACE, REMOTE, MUSIC, TIME MASK, LPENBL, INTERLACE, BANK SEL
        Y3 $FFD8-F  -> C-REG-SEL
        Y4 $FFE0-7  -> KB
      IC11/IC13 decode AB2-AB0 within the block (so expect mirrors)
RAM:  IC33 (AB15, AB14) -> RAM1 SEL $0000-$3FFF, RAM2 SEL $4000-$7FFF
      IC137 (AB15-AB11) -> /A89-SEL, /AAB-SEL (RAM3), /ACD-SEL, /AE-SEL (RAM4)
Slots: /EX-I/O = $FF00-$FF7F, /EX-I/O2 = $FF80-$FFBF  [Phase p.38]
```

The exact PIA/ACIA chip-select wiring: ACIA CS2-bar = IN LSI SEL, CS1 = AB2, CS0 from IC91 (inverted
address bit), RS = AB0; PIA CS2-bar = IN LSI SEL, CS0 from AB2 via IC91, CS1 pulled up, RS0/RS1 =
AB0/AB1 [SVC p.72].

## 4. Memory / video interleave [SVC p.50, p.57-59]

- E low = display period (CRTC address on DRAM), E high = MPU period; MPU DISP SW switches the
  address mux. CAS φ1 = display CAS, CAS φ2 = MPU CAS. 80-column mode does two page-mode display
  reads per E-low half.
- CAS selection (Table 6-10): CAS1 (IC56-63) for MPU `$0000-$3FFF` / display `$0400-$3FFF`; CAS2
  (IC69-76) for MPU `$4000-$7FFF` / display `$4000-$43FF`; CASCR (colour RAM) for `$0400-$43FF`.
- The CRTC scan refreshes the DRAM.

## 5. Video circuit [SVC p.52-64]

1. CRTC MA0-13 → (hi-res: IC40 adds raster×1024/2048 to MA10-13) → DRAM address mux.
2. Display byte (DD0-7) and colour byte (B, R, G, RV, GC) are read in the display period.
3. GC = 0: IC107 character ROM, address = {DD0-7, RAA1-3} with A0/A11 modified by the interlace
   circuit (IC130/IC136/IC141) to select the 16-row interlace area for complex glyphs.
   GC = 1: graphic generator, hi-res = DD7..DD0 left to right; normal = 2×4 blocks (left DD4-7,
   right DD0-3) via IC112 selected by RAA2/RAA3; IC113/IC114 select by HRSO-SW.
4. IC117 (LS166) loads on LOAD, shifts at DOTCK.
5. IC115 latches RV/G/R/B + CUDISP + DISPTMG per character (LOAD), IC116 per dot (DOTCK).
6. Pixel XOR RV (IC136) XOR CUDISP (IC131) → IC118 selects foreground G/R/B or background
   (MODE SEL bits) → IC132 → RGB TTL; monochrome composite via IC132/IC135 + Q5.
7. HSYNC regenerated to 4 µs by IC134/IC135; VSYNC and pedestal from IC135.

## 6. Keyboard circuit [SVC p.65]

HP (15.75 kHz) → IC97 gate → IC101 (X, 4 bits) → IC86 74159 drives one of 16 columns low;
IC101 carry → IC102 (Y, 3 bits) → IC90 74LS151 selects one of 8 rows. A low on the selected row sets
IC99 → gate closes (counters stop) and IRQ via IC96 (AND SS) and the LS05 wired-OR. Reading `$FFE0`
enables IC88/IC98 onto the bus with the counter value, and the end of the read clears IC99 so the
scan resumes. UE ($FFE0 b3) stops IC102. BREAK is a separate line to IC99/IC98 → `$FFC8` b7 and NMI
(gated by BM).

## 7. Interrupt wiring [SVC p.44, Fig 6-2]

```
NMI  <- wired-OR( TRACE counter IC14/IC15 , BREAK & BM , slots )
FIRQ <- wired-OR( Timer IC16 (60 Hz, masked by IC17 = $FFD4) , slots )
IRQ  <- wired-OR( keyboard & SS , light pen IC18 & LE , PIA IRQA/IRQB , ACIA , slots )
```

## 8. Cassette / RS-232C [SVC p.65-72]

```
RS/C SW (=$FFD0 b5, from IC39) -> IC111 (74LS157)
  L (cassette): counter input 1.008 MHz -> IC122/123/124 -> ACIA TxC/RxC 9.6 kHz;
                taps 4.8 / 2.4 / 1.2 kHz ; RxD <- cassette PLL
  H (RS-232C):  counter input 16.128 MHz -> 153.6 / 76.8 / 38.4 / 19.2 kHz (CS3) ; RxD <- HD75189
SAVE: ACIA TxD -> IC126 (latched by 1.2 kHz) -> IC125 gates 2.4 kHz ("1") or 1.2 kHz ("0") -> JA pin 3
LOAD: JA pin 5 -> D3/D4 limiter (1.2 Vpp) -> IC127 LM565 PLL -> IC128 75108 -> IC111 -> ACIA RxD
MOTOR: $FFD2 D7 -> IC126 -> Q4 2SC1213 -> RL1 -> JA pins 1/4 (cleared by /RES)
```

## 9. MP-1802 floppy card (schematic in the MP-1802 technical manual, img084-085) [MP1802Tech]

| IC | Part | Role |
|---|---|---|
| IC618 | MB8866C-G | FDC, inverted data bus, CLK = 1.008 MHz |
| IC628 | 74LS93 | 16MCK ÷4 (4 MHz) and ÷16 (1 MHz) |
| IC620 | 74LS138 | `/EX-I/O` + A2-A4 → Y0 `$FF00-03` FDC, Y1 `$FF04-07` MDD SEL |
| IC615 | 74LS174 | `$FF04` write latch (NMI MASK, DD, SIDE, MOTOR, DS1-0), cleared by /RES |
| IC625 | buffer | `$FF04` read: D7 = /DRQ, D0 = /IRQ |
| IC626 / IC627 / IC616 | LS14 / LS02 / 7406 | INTRQ NOR NMI MASK → open-collector /NMI |
| IC617 | HN462716 "DD-1" | 2 KB boot ROM at `$F800-$FEFF` |
| IC623 | 74LS30 | Boot-ROM decode (A11-15 high, not `$FFxx`, VMA, read, EXPROM KILL inactive) |
| IC622 | SN74LS245 | Slot data buffer |
| IC650 | 74LS139 | Drive select decode, only while MOTOR ON |
| IC614, IC619, IC621 | SN74LS166 | MFM write precompensation |
| IC643, IC646, IC648 | 74LS161, 74LS74, 74LS123 | FM read-clock separator, head-load timer |

Full detail: `sources/mp1802-tech.md`.
