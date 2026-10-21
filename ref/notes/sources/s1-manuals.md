# MB-S1: notes from the Hitachi English manuals

Sources (all in English: the operation manual and the disk manual say they are
translations of the Japanese MB-S1 10/20 manuals; "some specifications may be changed in
export models"):

- **[S1OpMan p.N]**: `ref/docs/manuals/S1-operation-manual/Hitachi_Personal_Computer_MB-S1_10_20_Operation_Manual_Photocopy.pdf`
  (129 PDF pages). The PDF page number is the printed page + 13 for printed pp.1-111.
  Appendix printed pp.113-116 = PDF 126-129. **Printed p.112 (the colour RGB connector
  pinout) is missing from the scan**: PDF 125 is a duplicate of printed p.102.
- **[S1BasicMan p.N]**: `ref/docs/manuals/S1-basic-manual/Basic_Manual_For_Hitachi_Personal_Computer_MB-S1_1020.pdf`
  (348 pages). PDF = printed + 8. It covers both S1 BASIC and Level-3 BASIC.
- **[S1DiskBasic p.N]**: `ref/docs/manuals/S1-disk-basic-manual/Disk_Basic_Manual_MS-S101_For_Hitachi_Personal_Computer_MB-S1.pdf`
  (144 pages; MA-S101). Printed "101-N" = PDF N+4.
- **[S1Brochure p.N]**: `ref/docs/brochures/S1-brochure/Hitachi_S1_Brochure.pdf` (2 pages).

All page numbers below are **PDF pages**. "Mode A" means S1 mode (S1 BASIC). "Mode B"
means Level-3 compatibility mode (Level-3 BASIC).

**The operation manual's Section 11 "System Description" (PDF 84-121) is effectively the
S1 hardware manual.** It has the full physical memory map, the bit-level I/O register
tables for both the common (L3-compatible) area and the S1-only area, the MMU, the CRTC
init values, the keyboard scan codes and the matrix. Because the common I/O area
$FFC0-$FFEF is shared with Mode B, **it also documents most of the Level-3 I/O bits.**

---

## 1. Specifications

| Item | Value | Cite |
|---|---|---|
| CPU | 68B09E (HD68B09E), 1 MHz / 2 MHz clocks | [S1OpMan p.15, p.122] |
| ROM | 24 KB Level-3 BASIC; 64 KB S1 BASIC; character generator (6 KB on p.15, "64K-byte" on p.122, 4 KB on p.64: inconsistent); 160 KB JIS level-1 kanji ROM (standard on /20, optional MPC-KA01S on /10) | [S1OpMan p.15, p.64, p.122] |
| RAM | 48 KB program DRAM; 48 KB graphics DRAM; 4 KB character display SRAM; 6 KB IG SRAM. p.15 says "52KB for character and graphics display" | [S1OpMan p.15, p.122] |
| Brochure RAM | "Standard 106K Bytes (VRAM 48K, System RAM 48K, IG RAM 6K, Text RAM 4K). Expandable: 618K Bytes"; address area 1 MB | [S1Brochure p.1] |
| Text | 80x25 and 40x25; 8x8 cell (non-interlace), 8x16 cell (interlace); 281 character/graphic glyphs | [S1OpMan p.122] |
| Colours | 15: blue, red, magenta, green, cyan, yellow and white in two brightnesses each, plus black. Palette: 8 of 15 | [S1OpMan p.64, p.122-123] |
| Graphics | 640x200, 320x200 (2 pages); 640x400 one colour in interlace | [S1OpMan p.122] |
| IG | 256 user-defined 8x8 patterns, 1-dot colour unit | [S1OpMan p.15, p.64] |
| Video out | RGB with separate sync (colour); composite (monochrome) | [S1OpMan p.122, p.126] |
| Keyboard | 92 keys, JIS layout, hardware scanning, auto-repeat and type-ahead | [S1OpMan p.123] |
| Cassette | 600, 1200 and "240" (sic, means 2400) bps; FSK; 1 start, 8 data, 2 stop bits | [S1OpMan p.123] |
| RS-232C | 300, 600, 1200, 2400 and 4800 bps (connector MP-9732 is optional) | [S1OpMan p.123, p.81] |
| Printer | 8-bit parallel, Centronics-like (STROBE/ACK) | [S1OpMan p.123, p.127] |
| Sound | "3-tone, 8-octave" (an AY-3-8910-type PSG at $FFE4/$FFE5) | [S1OpMan p.15, p.123] |
| Slots | 2 internal interface expansion connectors, a video-superimpose card connector, a mouse socket | [S1OpMan p.123] |
| Power | AC 100 V 50/60 Hz, 15 W | [S1OpMan p.123] |

Models in this manual: MB-S1/10 and MB-S1/20. The /20 adds the kanji ROM and the kanji
dictionary ROM [S1OpMan p.6]. The S1 was "developed as the host for the MB-6890, MB-6891
and MB-6892", and Mode B offers "full software compatibility" with the Level-3 series,
plus light pen functions [S1OpMan p.14].

## 2. Power-on, the SYSTEM switch and reset

- There is a **SYSTEM mode selection switch on the front panel**. Up ("A") = Mode A (S1
  BASIC); pressed in ("B") = Mode B (Level-3 BASIC). **Press RESET after changing it** to
  switch modes. In Mode A, RESET deletes all programs and data [S1OpMan p.22, p.36].
- If power is switched off and immediately on again, nothing displays; wait 5 s
  [S1OpMan p.7, p.37].
- **Mode A cold-start screen** [S1OpMan p.37]:
  ```
  HITACHI S1 BASIC Version 1.0
  Copyright (c) 1984 By Hitachi, Ltd.
  Copyright (c) 1980 By Microsoft
  36K Bytes Free
  BASIC User Area 36K Bytes

  Ready
  _            (blinking underline cursor)
  ```
- **Mode B cold-start screen** [S1OpMan p.38]:
  ```
  HITACHI LEVEL-3 BASIC Version 1.0
  Copyright (c) 1980 By Microsoft
  30570 Bytes Free
  Ready
  _
  ```
  (A useful golden reference for the L3 core: this is what Level-3 BASIC prints on an S1
  in B mode.)
- At Mode A start-up, the screen is in graphics mode, 640x200 graphics plus 40x25 text,
  non-interlace [S1OpMan p.57-59]. `NEW ON 0..3` selects graphics/text mode (text mode
  frees the 48 KB GVRAM for programs: 36 KB versus 84 KB user area) and printer kana
  conversion, and clears memory [S1OpMan p.58-59].
- **Disk boot (Mode A)**: power the drive on first, put the system diskette in drive 0,
  then switch the S1 on. DISK BASIC loads automatically. Without a system disk it shows
  "Insert Program Diskette" in the middle of the screen and waits [S1OpMan p.74],
  [S1DiskBasic p.9-11]. Drives: MP-3560/MP-3550 (5.25" 2D, 40 tracks, 2 drives, 656 KB
  per dual drive, 250 kbit/s) need the MP-1870 card (with the MPC-EX01S Expansion
  Board A) or the MP-1802/MP-1802A card (with MPC-EX02S Expansion Board B). MP-3660/3630
  (8" 2D, 77 tracks, 500 kbit/s) need MP-1806 plus Expansion Board B. DISK BASIC is
  MA-S101 (mini) / MA-S102 (8") [S1OpMan p.60, p.74, p.79]. The disk manual also says
  MP-1801 is needed for the MP-3370/3375 compact (3") drives [S1DiskBasic p.23].
  MA-S101 is file-compatible upward from L3 DISK BASIC MA-5310/MA-5320 [S1DiskBasic p.3].
  Default extensions: `.BAS` (LOAD/SAVE), `.BIN` (LOADM/SAVEM), `.DAT` (OPEN)
  [S1DiskBasic p.23].

## 3. Physical memory map (1 MB, $00000-$FFFFF) [S1OpMan p.85-87]

| Physical | Use |
|---|---|
| $00000-$7FFFF | (1) Memory expansion area, normally vacant (expansion RAM card) |
| $80000-$83FFF | (12) Reserved |
| $84000-$8FFFF | (2) **System RAM** (48 KB); the user area in BASIC |
| $90000-$AFFFF | (12) Reserved |
| $B0000-$B3FFF | (3) Graphics RAM, red plane (16 KB) |
| $B4000-$B7FFF | Graphics RAM, green plane |
| $B8000-$BBFFF | Graphics RAM, blue plane. "$B4000-$BBFFF is an image of the green and blue area" (pages 2..). Usable as program memory in text mode |
| $BC000-$BC7FF | (4) Character display RAM + character colour RAM (text VRAM) |
| $BD000-$BDFFF | (5) IG RAM (red/green/blue, 2 KB x 3 at $BD000-$BD7FF, plane chosen by IGENREG) / 4 KB character font ROM at $BD000-$BDFFF |
| $C0000-$CFFFF | (12) Reserved |
| $D0000-$D7FFF | Kanji dictionary ROM (MB-S1/20 only) |
| $D8000-$DFFFF | (12) Reserved |
| $E0000-$EFDFF | (6) **S1 BASIC ROM** (Mode A) |
| $EFE00-$EFEFF | (7) System I/O-2: Mode A-only I/O ($EFE00-$EFEFF) |
| $EFF00-$EFFEF | System I/O-2: common area (the same registers as $FFF00-$FFFEF) |
| $EFFF0-$EFFFF | (8) Interrupt vectors ROM, Mode A |
| $F0000-$F9FFF | (System RAM image) RAM in Mode B. "Addresses $F0000-$F9FFF used as RAM areas in system mode B become system RAM image areas" [S1OpMan p.87] |
| $FA000-$FFEFF | (9) **Level-3 BASIC ROM** (Mode B) |
| $FFF00-$FFFEF | (10) System I/O-1: Mode B I/O, also used by Mode A |
| $FFFF0-$FFFFF | (11) Interrupt vectors, Mode B |

Mode B therefore runs entirely inside physical $F0000-$FFFFF, as a Level 3 would.

## 4. MMU (Mode A) [S1OpMan p.102-106]

- **MAP0-MAPF at $FE00-$FE0F** (physical $EFE00-$EFE0F), R/W. Each holds A19-A12 (8 bits)
  for one 4 KB block of the CPU's space: MAP0 = $0000-$0FFF ... MAPF = $F000-$FFFF. The
  CPU's A15-A12 index the register, the register supplies A19-A12, and A11-A0 pass
  straight through [S1OpMan p.102, p.104].
- Example: writing $B2 to MAP0 puts physical $B2000-$B2FFF at CPU $0000-$0FFF
  [S1OpMan p.105].
- **FUSE ($FE10, write)**: bit 7 TRON (1 = enable the trace counter), bit 6 IMK
  (1 = hardware-mask NMI, FIRQ and IRQ together), bits 3-0 FC3-FC0 [S1OpMan p.102, p.106].
  - **System mode** is entered on RESET and on every hardware or software interrupt. In
    it, physical $84000-$84FFF is forced at CPU $E000-$EFFF and physical
    $EF000-$EFFFF at CPU $F000-$FFFF, whatever MAPE/MAPF hold. "Data assignments to MAPE
    and MAPF are invalid in the system mode" [S1OpMan p.105-106].
  - **User mode** (SYS-MODE S/U = 0) uses MAPE/MAPF for $E000-$FFFF. The mapping
    registers and FUSE cannot be accessed in user mode [S1OpMan p.106].
  - FC3-FC0 = how many machine cycles (1-15) pass before the switch from system mode to
    user mode. All zeros = stay in system mode. **S1 BASIC writes 0 and never uses user
    mode**, because MAPF ($F000-$FFFF) is the hardware register area plus the supervisor
    ROM and MAPE ($E000-$EFFF) is the system stack [S1OpMan p.106].
- **TRAPF ($FE18, read)**: bit 7 TRAP. An NMI is generated when physical $BF000-$BFFFF is
  accessed (used as a cheap loop terminator, worked example) [S1OpMan p.102, p.107].
- **BUSCTRL ($FE19)**: read bit 7 BG (bus grant); write bit 7 BREQ [S1OpMan p.102].
- Hardware note from MAME `mbs1_mmu.cpp`: the mapper is 2x 74S189 plus 2x LS257 for the
  system/user switch (citing haserin09.la.coocan.jp/os9_mmu.html). This is not from the
  manuals.
- S1 BASIC's logical layout ("address space 1") [S1OpMan p.61-63]:
  $0000-$1FFF variable window (8 KB), $2000-$3FFF program window (8 KB), $4000-$4FFF
  character display RAM, $5000-$CFFF S1 BASIC ROM (32 KB windowed out of the 64 KB ROM),
  $D000-$EFFF RAM (work and system stack), $F000-$FFFF ROM, system I/O and vectors.
  Program/variable/string areas are separate 4 KB-block "address spaces 3/4/5" banked
  into the windows; "address space 2" maps GVRAM, character RAM, IG RAM etc. for
  graphics and music [S1OpMan p.61-63]. User area: graphics mode 36 KB (100 KB with
  64 KB expansion, 132 KB with 128 KB); text mode 84 KB (132 KB) [S1OpMan p.63].
- `DEF MAP = 0..3` picks one of four "machine language spaces" used by MON, LOADM, SAVEM,
  EXEC, POKE, PEEK and USR. The diagram shows the system ROM / I/O at page F, system
  work area at E, stack at D in all four; space 1 has graphics VRAM at pages 0-3, text
  VRAM at 4, CG/IG at 5 [S1BasicMan p.88].
- Monitor `MAP` example output (memory area F):
  `0=03 1=04 2=05 3=06 4=07 5=08 6=09 7=0A 8=0B 9=0C A=0D B=0E C=0F D=85 E=84 F=EF`
  [S1BasicMan p.165]. D/E/F (85, 84, EF) match the physical layout; 0-C (03..0F) are
  probably BASIC's logical block numbers rather than raw MAP register contents.
  Unresolved.

**MAME comparison (mbs1_mmu.cpp / mbs1.cpp):**
- MAME's `init_banks()` in S1 mode sets latches 0-D to $F0|i, E = $84, F = $EF; in L3
  mode all 16 = $F0|i. E/F match the manual's system-mode values. **MAME does not model
  the forced system-mode override of $E000-$FFFF (FUSE/system-vs-user switch), FC3-FC0
  delayed switching, TRAPF, IMK or BUSCTRL.**
- MAME maps separate RAM at $F0000-$F9FFF. The manual says that area in Mode B is a
  "system RAM image", which suggests it is the 48 KB system RAM ($84000-$8FFFF) seen
  again, not separate RAM. MAME has a comment that $84000-$8FFFF is "mirror of main
  work RAM +$4000". **Conflict/unresolved: check EmuB-S1.**
- MAME `s1basic` ROM (32 KB) at $E0000-$E7FFF and `s1boot` (32 KB-$200 + vectors) at
  $E8000-$EFFFF: consistent with the manual's single 64 KB "S1 BASIC ROM" at
  $E0000-$EFDFF plus vectors at $EFFF0.

## 5. Common system I/O ($FFC0-$FFEF, and the $EFFxx image) [S1OpMan p.88-89]

The manual says that within the I/O tables the leading hex digit is dropped (so $FFC0
means $FFFC0/$EFFC0) [S1OpMan p.87]. This table is shared by Mode B (= Level 3) and
Mode A. R = read, W = write, X = undefined on read, X/O = undefined on read, write 0.

| Addr | Name | D7 | D6 | D5 | D4 | D3 | D2 | D1 | D0 | R/W | Function |
|---|---|---|---|---|---|---|---|---|---|---|---|
| FFC0 | PIA-BANK (PIA port A) | D7 | D6 | X/O | X/O | D3 | D2 | D1 | D0 | R/W | RAM/ROM bank switching in Mode B (see 5.1) |
| FFC1 | PIA-BANK (CRA) | 0 | 0 | 0 | 0 | 0 | CRA2 | 0 | 0 | W | |
| FFC2 | PIA port B | PB7..PB0 |||||||| R/W | Printer control |
| FFC3 | PIA CRB | CRB7..CRB0 |||||||| R/W | |
| FFC4 | ACIA status / control | IRQ | PE | OVRN | FE | CTS | DCD | TDRE | RDRF | R | Cassette and RS-232C (switched by MODE-SEL C) |
| | | CR7..CR0 |||||||| W | |
| FFC5 | ACIA data | D7..D0 |||||||| R/W | |
| FFC6 | CRTC address | 0 | 0 | 0 | A4 | A3 | A2 | A1 | A0 | W | |
| FFC7 | CRTC data | D7..D0 |||||||| R/W | |
| FFC8 | KBNMI | BK | X | X | X | X | X | X | X | R | BREAK key pressed when BK = 1 |
| FFC9 | DIPSW | 0 | 0 | 0 | 0 | 0 | 0 | 1 | 1 | R | "Data fix" (reads constant $03 on the S1) |
| FFCA | TIMER | T | T2 | X | X | X | X | X | X | R | T = 1: timer FIRQ generated (Mode B). T2 = 1: high-speed timer FIRQ (Mode A) |
| FFCB | LPFLG | 0 | X | X | X | X | X | X | X | R | D7 fixed 0 (light pen flag) |
| FFD0 | MODE-SEL | W | HR | C | 0 | IB | GB | RB | BB | W | see 5.2 |
| FFD1 | TRACE | 0..0 |||||||| W | Trace counter on during write (NMI generated) |
| FFD2 | REMOTE | RM | 0 | 0 | 0 | 0 | 0 | 0 | 0 | W | Relay on when RM = 1 (cassette remote **OFF** per the table text; see note) |
| FFD3 | MUSIC-SEL | MS | 0 | 0 | 0 | 0 | 0 | 0 | 0 | W | Internal speaker; toggle 0/1 to make sound |
| FFD4 | TIME MASK | TM | 0 | 0 | 0 | 0 | 0 | 0 | 0 | W | Mode B: timer FIRQ inhibited (internal clock stop) when TM = 1 |
| | | 0 | 0 | 0 | 0 | 0 | 0 | TM2 | T2S | W | Mode A: TM2 = 1 inhibits high-speed timer FIRQ; T2S = 0 2 ms timer, 1 = 1 ms timer |
| FFD6 | INTERACE-SEL (sic) | 0 | 0 | 0 | 0 | IS | 0 | 0 | 0 | W | Interlace mode when IS = 1 |
| FFD7 | BAUD-SEL | 0 | 0 | 0 | 0 | S3 | S2 | S1 | S0 | W | Cassette baud rate (see 5.3) |
| FFD8 | C-REG-SEL | MK | X/O | IG | GC | RV | G | R | B | R/W | Colour register, Mode B (see 5.4) |
| | | MK | SI | IG | GR/TX | RV | G | R | B | R/W | Character-screen colour register, Mode A |
| FFD9 | TRQ-SEL | IRQF | STBY | TPED | FIND | C3 | C2 | C1 | C0 | R | (not explained in the manual) |
| | | IE | 0 | 0 | 0 | C3 | C2 | C1 | C0 | W | |
| FFDC | MOUSE0 | IF1 | TR1 | SGX | X12 | X11 | X10 | X9 | X8 | R | Mouse (5.6) |
| | | IE | ED | XC | YC | YSG1 | YCT1 | XSG1 | XCT1 | W | |
| FFDD | MOUSE1 | X7..X0 |||||||| R | |
| FFDE | MOUSE2 | IF2 | TR2 | SGY | Y12 | Y11 | Y10 | Y9 | Y8 | R | |
| | | 0 | 0 | 0 | 0 | YSG2 | YCT2 | XSG2 | XCT2 | W | |
| FFDF | MOUSE3 | Y7..Y0 |||||||| R | |
| FFE0 | KB | BM | SS | 0 | 0 | UE | SL | HR | KN | W | Keyboard mode / LEDs (5.5) |
| | | D7..D0 |||||||| R | Key-matrix scan data |
| FFE1 | KB-TYPE | X | X | X | X | K3 | K2 | K1 | K0 | R | Keyboard type |
| FFE2 | TVSUPER | 0 | 0 | 0 | AD | 0 | HC | TD | SI | W | Video superimpose card control |
| FFE4 | PSG-DATA | D7..D0 |||||||| R/W | PSG data (5.7) |
| FFE5 | PSG-COM | 0 | 0 | 0 | 0 | D3 | D2 | D1 | D0 | W | PSG register select |
| FFE8 | BANK-REG | 0 | D6 | D5 | D4 | D3 | D2 | D1 | D0 | W | Expanded-RAM bank switching, **Mode B only** |
| FFE9 | IGMODREG | PAE | X | X | X | X | DT | H | V | R | IG access timing (5.8) |
| | | 0 | 0 | 0 | 0 | 0 | 0 | 0 | PM | W | PM = 1 enables writes to IG RAM (Mode B) |
| FFEA | IGENREG | 0 | 0 | 0 | 0 | 0 | PG | PR | PB | W | IG colour plane select |
| FFEB | SYS-MODE | X | X | X | X | X | S/U | 2M/1M | S1/L3 | R | 5.9 |
| | | 0 | 0 | 0 | 0 | 0 | 0 | 2M/1M | 0 | W | |
| FF75 | KADR-H / KLEFT | KA11..KA4 (W) / LD7..LD0 (R) |||||||| | JIS kanji code high / font left half |
| FF76 | KADR-L / KRIGHT | KA15..KA12, KA3..KA0 (W) / RD7..RD0 (R) |||||||| | kanji code low / font right half |

Note on FFD2: the function column reads "Relay ON when RM = '1' (cassette remote OFF)".
The meaning of the parenthesis is unclear. MAME treats it as motor on.
Note: **$FFD5 (light pen register on the L3) is not in the S1 table.** FFCB LPFLG
reads D7 = 0 [S1OpMan p.88]. S1 BASIC does not support ON PEN [S1BasicMan p.43].

### 5.1 PIA-BANK ($FFC0/$FFC1) [S1OpMan p.90]

"Normally used in system mode B for switching ROM addresses $A000-$EFFF between the bank
and the RAM area."

| Bit | "0" | "1" |
|---|---|---|
| D0 | Select RAM in $8000-$9FFF | Select ROM. At power-on D0-D3 = 1, and $8000-$EFFF are write-only (the RAM underneath can be written but not read) |
| D1 | Select $A000-$BFFF | (as above) |
| D2 | Select $C000-$DFFF | |
| D3 | Select $E000-$EFFF | |
| D6 | $A000-$BFFF are write-only (cannot be read) | Invalid when D1 = 1. $A000-$BFFF read/write when D1 = 0 |
| D7 (with D2) | $C000-$DFFF write-only | Invalid when D2 = 1. $C000-$DFFF read/write when D2 = 0 |
| D7 (with D3) | $E000-$EFFF write-only | Invalid when D3 = 1. $E000-$EFFF read/write when D3 = 0 |

"Caution: this register is usable after write operation for D2 = '1' in $FFC1" (that is,
the 6821 CRA bit 2 must select the data register rather than the DDR).

**MAME conflict (bml3.cpp `piaA_w`)**: MAME uses bit 1 = 0 plus bit 6 for $A000-$BFFF,
bit 2 plus bit 7 for $C000, bit 3 plus bit 7 for $E000 (the same as the manual), **but MAME
also uses bit 0 for $F000-$FEFF (1 = RAM R/W) and bit 1 for $FFF0-$FFFF**. The manual
gives bit 0 as $8000-$9FFF, and does not mention $F000-$FEFF or the vectors at all. The
manual's 0/1 sense for D1-D3 ("0 = select [RAM]", "1 = ROM") is consistent with MAME's
"bit = 1: no change". Decide this from the L3 service manual or a ROM disassembly; the
$8000 meaning may be S1-specific.

### 5.2 MODE-SEL ($FFD0) [S1OpMan p.90-91]

| W | HR | Mode |
|---|---|---|
| 0 | 0 | 40-character high-resolution |
| 0 | 1 | 40-character normal |
| 1 | 0 | 80-character high-resolution |
| 1 | 1 | 80-character normal |

C: 0 = cassette, 1 = RS-232 (ACIA routing). GB RB BB = background colour: 000 black,
001 blue, 010 red, 011 magenta, 100 green, 101 cyan, 110 yellow, 111 white. IB: 0 =
background low brightness, 1 = high brightness. **W and HR are invalid in Mode A.**
Consistent with MAME's `mode_sel_w` comment (W bit 7, HR bit 6, C bit 5, RGB bits 2-0).
MAME does not model IB (bit 3).

### 5.3 BAUD-SEL ($FFD7) [S1OpMan p.91]

| S3 S2 S1 S0 | Baud | Remarks |
|---|---|---|
| 0000 | 600 | FSK, 0 = 1200 Hz, 1 = 2400 Hz |
| 0001 | 1200 | same FSK |
| 0010 | 2400 | same FSK |
| 0011 | 300 | same FSK |
| 0110 | 4800 | FSK, 0 = 2400 Hz, 1 = 4800 Hz |
| 1001 | 3200 | "Hitachi's own format" |

3200 and 4800 are "for future system expansion" and unsupported by BASIC. Above
2400 bps cassette I/O "may not be normal". Fast-play with the TRQ-1500 data recorder:
`POKE &HFFD7,4` (for tapes written at 600 baud) or `POKE &HFFD7,5` (1200) [S1OpMan p.68].
Values 4 and 5 are not in the table (they presumably double the FSK frequencies to match
a tape running at double speed).

**MAME conflict**: MAME `baud_sel_w` uses only bit 0 (ACIA clock 9600 or 19200 Hz =
600/1200 baud at ÷16). The L3 English user manual's Table S.2 lists $FFD7 as "Open"
(see the L3 notes). On the S1 it is a 4-bit register.

### 5.4 C-REG-SEL ($FFD8) [S1OpMan p.92-93]

- A 7-bit, bidirectional register for the character screen colour. Six of the 7 bits (all
  except the MSB) are stored in the colour RAM. **On write**: the C-REG-SEL contents are
  stored in the colour RAM at the same time as the CPU writes display data into the
  display memory. The value is held until the next write or until display memory is read.
  **On read**: if MK (bit 7) = 0, reading display memory loads the colour RAM byte for
  that address into C-REG-SEL.
- **MK**: in Mode B display memory and program memory overlap ($0400-$43FF). A program
  reading that area would overwrite C-REG-SEL, destroying the colour set up so far. With
  MK = 1, the colour is held even when display memory is read. MK: 0 = write enable,
  1 = write inhibit.
- GC: 0 = character, 1 = graphics. RV: 0 = standard, 1 = inverted. IG: 0 = IG display
  inhibited, 1 = IG displayed in preference to other modes. Bits 0-4 are ignored when
  IG = 1. G, R, B select the palette entry.
- Mode A SI / GR-TX: 00 = character screen only; 01 = graphics only; 10 = superimposed,
  character priority; 11 = superimposed, graphics priority. Superimposition is
  controlled per character cell.
- G R B → palette number 0-7 (GRB as a 3-bit number, G = MSB).

This matches MAME's attribute layout (bit 0 B, 1 R, 2 G, 3 reverse, 4 graphic) and
confirms the **attribute-latch mechanism** (the colour RAM is written from a latch on
every VRAM write, and the latch is reloaded on every VRAM read unless MK = 1). MAME
`vram_r` has a comment "Bit 7 masks reading back to the latch", which is consistent.
The new fact is **bit 5 IG**.

### 5.5 Keyboard ($FFE0) [S1OpMan p.95-96, p.120]

Write:
- BM (bit 7): 0 = KBNMI inhibit, 1 = KBNMI enable. It controls NMI on BREAK. BASIC sets
  it to 0 (no NMI on BREAK in BASIC). BREAK never causes an IRQ; read KBNMI bit 7
  ($FFC8) to see whether BREAK is pressed.
- SS (bit 6): 0 = KBIRQ inhibit, 1 = KBIRQ enable. BASIC sets it to 1, so every key
  press raises an IRQ, and the scan code is converted and buffered. With SS = 0 software
  must poll the KB register.
- UE (bit 3): 0 = counter (scan) operation enabled, 1 = inhibited.
- SL HR KN (bits 2-0) LEDs: 000 = SHIFT-mode LED (sic), 110 = hiragana, 101 = katakana,
  100 = all LEDs off for keyboard use.

Read:
- "A counter circuit constantly scans the keyboard. When a key is pressed, the counter
  stops, data indicating that a key has been pressed is set into bit 7 of the KB
  register and held, and an IRQ is generated. The MPU reads the KB register in IRQ
  processing, inputs the key-scan code (the counter value) and converts it" [S1OpMan p.96].
- **Key-scan codes (hex)** from the keyboard drawing [S1OpMan p.96]: BREAK = (BREAK, via
  FFC8); PF1-PF5 = D0-D4; COPY E8, INS E5, DEL EF. Row 1: ESC 8C, 1 9A, 2 9B, 3 97,
  4 91, 5 99, 6 92, 7 90, 8 93, 9 9C, 0 94, - 96, ^ 95, ¥ 9F, BS 9E. Row 2: TAB EC,
  Q A8, W AA, E AB, R A1, T A9, Y A2, U A0, I A3, O AC, P A4, @ A6, [ A5, RETURN AF.
  Row 3: CAPS 89, CTRL 86, A B8, S BA, D BB, F B1, G B9, H B2, J B0, K B3, L BC, ; B4,
  : B6, ] B5. Row 4: SHIFT 87, Z C8, X CA, C CB, V C1, B C9, N C2, M C0, , C3, . CC,
  / C4, _ C6, SHIFT 87. GRAPH 8B, SPACE 80, kana-convert E7, kana 8A. Keypad: HOME/CLS
  AE, ↑ 81, ? 82, / C5; ← 83, ↓ 84, → 85, * 8F; 7 9D, 8 8D, 9 8E, - BF; 4 B7, 5 BD,
  6 BE, + CF; 1 C7, 2 CD, 3 CE, RETURN AF; 0 A7, , ED, . AD. (Read from a small
  drawing; cross-check with the matrix table below.)
- **Matrix table** [S1OpMan p.120] (row = high nibble 8-F, column = low nibble 0-F):
  - 8x: 0 SPACE, 1 ↑, 2 ?(pad), 3 ←, 4 ↓, 5 →, 6 CTRL, 7 SHIFT, 9 CAPS LOCK, A カナ/ひら
    (kana), B GRAPH, C ESC, D 8(pad), E 9(pad), F *(pad)
  - 9x: 0 7, 1 4, 2 6, 3 8, 4 0, 5 ^, 6 -, 7 3, 9 5, A 1, B 2, C 9, D 7(pad), E BS/IS,
    F ¥
  - Ax: 0 U, 1 R, 2 Y, 3 I, 4 P, 5 [, 6 @, 7 0(pad), 8 Q, 9 T, A W, B E, C O, D .(pad),
    E HOME/CLS, F RETURN
  - Bx: 0 J, 1 F, 2 H, 3 K, 4 ;, 5 ], 6 :, 7 4(pad), 8 A, 9 G, A S, B D, C L, D 5(pad),
    E 6(pad), F -(pad)
  - Cx: 0 M, 1 V, 2 N, 3 ,, 4 /, 5 /(pad), 6 _, 7 1(pad), 8 Z, 9 B, A X, B C, C .,
    D 2(pad), E 3(pad), F +(pad)
  - Dx: 0 PF1/PF6, 1 PF2/PF7, 2 PF3/PF8, 3 PF4/PF9, 4 PF5/PF10
  - Ex: 5 INS, 7 変換 (convert), 8 COPY, C TAB, D ,(pad), F DEL
  - Fx: 0 "Keyboard disconnected", 1 "JIS keyboard" (dotted row)
  This is consistent with MAME's mbs1/bml3 `X0` port ordering (bit 0 Space, 1 Up, 2 ?
  pad, 3 Left, 4 Down, 5 Right, 6 Control, 7 Shift...).
- Auto-repeat and "advance key-entry" (type-ahead) exist (section 5-10, per the table of contents) [S1OpMan p.4].

### 5.6 Mouse ($FFDC-$FFDF) [S1OpMan p.94]

Two 13-bit counters ($0000-$1FFF). Read: IF1/IF2 = button 1/2 stroke latched, TR1/TR2 =
button state, SGX/SGY = direction sign, X12-X0 / Y12-Y0 = counts. Write: IE = interrupt
on trigger button, ED = trigger edge, XC/YC = count direction, XSG1/XCT1/YSG1/YCT1 =
move/clear, XSG2/XCT2/YSG2/YCT2 = negative move/all-ones. Mouse is MP-3710 (its manual is
`ref/docs/manuals/MP-3710`).

### 5.7 PSG ($FFE4 data, $FFE5 register select) [S1OpMan p.97], [S1BasicMan p.48-50]

An AY-3-8910-compatible register set: R0-R5 tone A/B/C (12-bit), R6 5-bit noise, R7
mixer (noise C B A, tone C B A), R8-RA volume with M (envelope) bit, RB/RC envelope
period, RD envelope shape (the 10 standard shapes are drawn) [S1OpMan p.97].
**PSG clock = 1.008 MHz**: the BASIC manual gives the envelope M value as
`M = cycle(s) x 1.008 MHz / 256` [S1BasicMan p.49]. (1.008 MHz = 16.128 MHz / 16 or
32.256 MHz / 32, consistent with the L3 crystal.) PLAY supports 3 voices; 4-6 voices
need an optional card [S1BasicMan p.49]. **MAME's mbs1 has no PSG.**

### 5.8 IG registers [S1OpMan p.98]

- BANK-REG ($FFE8): valid only in Mode B (no bit definitions given).
- IGMODREG read ($FFE9): reading it during the CRTC display period **HALTs the MPU from
  the end of the read until the start of the next retrace**, so a following IG RAM write
  lands in the retrace and does not flicker. If read during retrace, no HALT. Character
  and graphics RAM never need this.
- IGENREG ($FFEA): PG/PR/PB select the green/red/blue IG RAM plane for read/write. "The
  character font ROM can be read when PG = PR = PB = 1" (the text says "PG, PR and PG").
  The palette (PALET0-7) also colours the IG display.

### 5.9 SYS-MODE ($FFEB) [S1OpMan p.98-99]

- Read: bit 2 S/U (0 = user mode, 1 = system mode); bit 1 2M/1M (0 = 1 MHz, 1 = 2 MHz);
  bit 0 S1/L3 (0 = Mode B, 1 = Mode A).
- Write: bit 1 2M/1M (0 = 1 MHz, 1 = 2 MHz).
- 2 MHz is standard in Mode A. **Accessing the system I/O area automatically drops the
  clock to 1 MHz**, so Level-3 option cards are timed correctly. Writing 0 to 2M/1M forces
  1 MHz, so Level-3 programs run at Level-3 speed.
- MAME: `system_io` $EFFEB read = system_type | clock<<1 | su_mode<<2 (bit layout
  matches); write sets the clock from bit 1 (matches). **MAME does not slow the CPU on
  I/O accesses.**
- Kanji ($FF75/$FF76): write KADR-H then KADR-L (a code that is "different from the JIS
  code"; a conversion routine KANJRD is listed in full), then read 16 rows of KLEFT/KRIGHT
  (32 bytes, 16x16) [S1OpMan p.100-101].

## 6. Mode A-only I/O ($FE00-$FE41 = physical $EFE00-$EFE41) [S1OpMan p.102-103]

| Addr | Name | Bits | R/W | Function |
|---|---|---|---|---|
| FE00-FE0F | MAP0-MAPF | A19..A12 | R/W | Address mapping for $0000-$FFFF in 4 KB steps |
| FE10 | FUSE | TRON IMK 0 0 FC3 FC2 FC1 FC0 | W | System/user switch |
| FE18 | TRAPF | TRAP X X X X X X X | R | Address trap flag (NMI) |
| FE19 | BUSCTRL | BG ... (R) / BREQ 0... (W) | R/W | Bus grant / request |
| FE20 | BMSK-COLOR | BMSC 0 0 0 0 G R B | W | Colour for indirect (bit-mask) writes |
| FE21 | ACTIVE-PLANE | 0 0 0 0 DW G R B | W | Planes accessed |
| FE23 | DISP-PAGE | G R B 0 0 0 GR TX | W | Display page/plane enables |
| FE24 | SCRN-MODE | 0 0 0 0 0 D2 D1 D0 | W | Screen mode |
| FE25 | B-REG | D7..D0 | R/W | Graphics colour register (blue) / scroll register |
| FE26 | R-REG | D7..D0 | R/W | red |
| FE27 | G-REG | D7..D0 | R/W | green |
| FE28-FE2F | PALET0-7 | 0 0 0 0 I G R B | W | Colour palette |
| FE40 | PIA-A port A | PA7..PA0 | R/W | HD6821 port A (joystick, per MAME "DE-9") |
| FE41 | PIA-A CRA | CRA7..CRA0 | R/W | Use only after writing 0 to SYS-MODE 2M/1M (1 MHz) |

This matches MAME's commented ext-I/O list ($20 BMSK, $21 plane, $23 page, $24 mode,
$25-27 BRG, $28-2F palette, $40-41 PIA). MAME also lists $11 "OS-9 address segment",
$1A/$1B for the MPC-68008 card and $42/$43 PIA 2 (printer mirror), which the manual
does not.

- **BMSK-COLOR** [S1OpMan p.108]: B/R/G = 1 means write the specified dots in that colour.
- **ACTIVE-PLANE** [S1OpMan p.108]: B/R/G = 1 makes that plane accessible.
- **DISP-PAGE** [S1OpMan p.108]: TX = character page 0/1 (40-column mode), GR = graphics
  page 0/1 (320x200), B/R/G = display that graphics plane. Text mode = R = G = B = 0,
  which frees the 48 KB GVRAM for data.
- **SCRN-MODE** [S1OpMan p.109]: D0 with D1 = 0: 0 = 320x200 8-colour, 1 = 320x200
  64-colour (needs the MPC-VSC1S superimpose card and the C15-B01 TV). D0 with D1 = 1:
  0 = 640x400 one colour (flickers), 1 = 640x200 8-colour. D1: 0 = 320, 1 = 640 dots
  across. D2: 0 = 40x25 text, 1 = 80x25 text.
- **B/R/G-REG and graphics RAM access modes** [S1OpMan p.109-112]:
  - Write, BMSC = 0, DW = 0: direct write into the planes selected by ACTIVE-PLANE.
  - Write, BMSC = 0, DW = 1: indirect write. The B/R/G-REG contents are written into the
    selected planes (the data bus value is ignored).
  - Write, BMSC = 1: bit-mask write. For each bit, data-bus bit = 0 writes the graphics
    colour register's bit; data-bus bit = 1 writes the BMSK-COLOR G/R/B value
    (diagram on p.111).
  - Read, BMSC = 0, DW = 0: sequential read. Only one plane is returned, in priority
    order G, R, B.
  - Read, BMSC = 0, DW = 1: the selected plane data is read and **at the same time
    latched into G-REG/R-REG/B-REG** ("three-sequence simultaneous read"). Writing that
    byte back unmodified writes all three planes, so a scroll copies three planes per
    access (the scroll-register use).
- **PALET0-7** [S1OpMan p.103]: 0 0 0 0 I G R B. BASIC colour codes 0-15: 0 black,
  1 dark blue, 2 dark red, 3 dark magenta, 4 dark green, 5 dark cyan, 6 dark yellow,
  7 white, 8 black, 9 light blue, 10 light red, 11 light magenta, 12 light green,
  13 light cyan, 14 light yellow, 15 bright white. Initial: palette n → colour n+8
  (palette 0 → 8 = black) [S1BasicMan p.41]. So I = bit 3 is the bright half and colour
  7 (I = 0, GRB = 111) is "white" while 15 is "bright white".

## 7. Video memory layout and CRTC [S1OpMan p.113-118]

- **Character screen** at physical $BC000 + offset [S1OpMan p.113]: 40-column: row r,
  column c at r*$28 + c, $000-$3E7; page 2 adds $400. 80-column: r*$50 + c, $000-$7CF.
- **Graphics** at physical $B0000 + offset (each plane) [S1OpMan p.114-116]:
  - 320x200: byte = (row/8)*$28 + (row%8)*$400 + col (character-row interleaved like the
    L3: line within a character row steps by $400; next character row +$28; last byte
    $1FE7). Page 2 adds $2000. D7 is the leftmost pixel.
  - 640x200: (row/8)*$50 + (row%8)*$800 + col, up to $3FCF.
  - 640x400 (interlace only): 16 lines per character row, (row/16)*$50 + (row%16)*$800,
    up to $7FCF.
- **CRTC = HD6845S.** Initial register values [S1OpMan p.117]:

| Reg | Name | Interlace | Non-interlace |
|---|---|---|---|
| R0 | Horizontal total | $7F | $7F |
| R1 | Horizontal displayed | $50 | $50 |
| R2 | H sync position | $5F | $5F |
| R3 | Sync widths | $8A | $8A |
| R4 | Vertical total | $1F | $1F |
| R5 | V total adjust | $06 | $06 |
| R6 | Vertical displayed | $19 | $19 |
| R7 | V sync position | $1C | $1C |
| R8 | Interlace & skew | $43 | $40 |
| R9 | Max raster address | $0E | $07 |
| R10 | Cursor start | $2E | $27 |
| R11 | Cursor end | $0F | $07 |
| R12-R15 | Start addr / cursor | $00 | $00 |
| R16-R17 | Light pen | unused | unused |

  Notes [S1OpMan p.117-118]: (1) SCRN-MODE, not the CRTC, switches 40/80 columns (Mode A);
  (2) in 80-column mode the cursor (R14/R15) is the byte offset; (3) in 40-column mode
  the cursor value is **double** the 40-column offset (shifted left 1), with 0 = top-left
  for both pages; (4) R12/R13 = 0 regardless of 40/80 or page; (5) display fetches use
  physical addresses (unlike the cursor).
  - Derived timing (not stated in the manual): R0 = 127 → 128 character times per line;
    R4/R5/R9 non-interlace: 32 rows x 8 + 6 = 262 lines. With a 15.75 kHz line that is a
    2.016 MHz character clock for 80-column (128 x 15.75 kHz), which is consistent with
    the 32.256 MHz / 16 = 2.016 MHz, and with MAME's C80_CLOCK. Treat this as an
    inference.
- Interlace: Mode A starts non-interlaced. Interlace uses 8x16 characters (flickers on
  the C12-2120 and C15-B01) [S1OpMan p.59]. SCREEN's third argument picks
  interlace/scroll mode; the manual's table looks misprinted (all four rows say
  "Interlace mode") [S1BasicMan p.226].

## 8. Character set [S1OpMan p.121]

Two tables: interlace and non-interlace character sets differ in $80-$FF graphics (the
interlace set has kanji-like glyphs 年月日 etc. in $80-$9F; the non-interlace set has
block/line graphics). **Code $7F is DEL in Mode A and a different glyph in Mode B.**

## 9. Cassette [S1OpMan p.65-70, p.126], [S1BasicMan p.146-148, p.170, p.225]

- Format: FSK, 1 start + 8 data + 2 stop bits [S1OpMan p.123]. Frequencies: 0 = 1200 Hz,
  1 = 2400 Hz for 300/600/1200/2400 baud [S1OpMan p.91].
- Baud: `MOTOR ,0` = 600, `MOTOR ,1` = 1200, `MOTOR ,2` = 2400. **Conflict**: the
  operation manual says Mode A sets **1200 baud** at power-on/RESET [S1OpMan p.67], but
  the BASIC manual's MOTOR table says 0 (600 baud) is the "initial value"
  [S1BasicMan p.170]. (Mode B presumably 600 like the L3.)
- Remote relay on $FFD2 bit 7; BASIC turns the motor on for LOAD/SAVE and off at the end;
  `MOTOR ON/OFF` [S1OpMan p.66].
- DIP SW1 on the rear panel: switches 1-2 = RS-232C clock divider (S/F × 300/600/1200/
  2400 → 300...4800 bps; factory = 300/1200) [S1OpMan p.83, p.118-119]; switch 3 =
  cassette recorder type (TRQ-359 vs TRQ-1500/2400 data recorder, factory) — affects
  the record waveform only; switch 4 = display output signal (standard / special
  printers) [S1OpMan p.118-119].
- LOAD flow: "Searching", then "Found: <name>", then "Ready"; errors "Device I/O Error";
  `LOAD?` verifies the checksum without loading; `SKIPF` skips files [S1OpMan p.65-70].
  Filename is up to 8 characters [S1BasicMan p.45].
- Machine code: `LOADM "name"[,offset][,R]` loads a SAVEM file (R = run from the SAVEM
  start address) [S1BasicMan p.148]; `SAVEM "name",start,end,exec` [S1BasicMan p.225];
  `EXEC [addr]` (default: the entry point of the last loaded file) [S1BasicMan p.98].
  Example: `CLEAR 300,&HC000 : DEF MAP=0 : LOADM "TEST" : EXEC &HC000`
  [S1BasicMan p.89].
- Connector (6-pin DIN): 1 REMOTE, 2 GND, 3 OUT, 4 REMOTE, 5 IN [S1OpMan p.126].

## 10. Monitor (`MON`) [S1BasicMan p.157-169]

`MON` enters the machine-language monitor; prompt `*`. Subcommand format
`<name> <op1>,<op2>,...` with hex operands; `$` = PC at start, `*` = current PC; strings
in quotes. BREAK, CTRL+C, CTRL+D or BREAK+RESET interrupt a subcommand.

| Cmd | Function |
|---|---|
| B, BL | Display/set breakpoints (5 max: address, function byte b1 = no stop, b0 = no register display, count). Implemented with SWI ($3F); no breakpoints in ROM |
| BP | Display breakpoints |
| D [addr][,lines] | Dump 16 bytes per line |
| DL n | Set D's line count |
| E [addr] | Screen-editor memory edit, 256 bytes (CTRL+A hex/char, CTRL+B/F page, CTRL+G breakpoint) |
| F start,end\|@n,pattern | Fill |
| G [addr] | Go (CTRL+D shows registers) |
| H v1,v2 | Hex sum and difference |
| HC [0/1] | Hard copy to printer |
| M, ML [addr] | Display/alter 16 bytes |
| MAP, MAPL [n] | Display/alter current memory area number or that area's map image (areas 0-6 reserved; user area is F when DEFMAP = 0, E when DEFMAP = 1-3) |
| MAPP [n] | Display map image |
| Q | Quit to BASIC |
| R, RL / RP | Display/alter registers: S (system stack + contents), CC (NZVC letters), A, B, DP, X, Y, U, PC + 5 bytes at PC |
| S [start],[end\|@n],pattern | Search |
| T start,end\|@n,dest | Transfer (copy) |
| TS [flag] | Save/restore the text screen around breakpoints |
| X, XL / XP | Display/alter / display the current area's map image |

Register display example: `S=E45D(F200)CC=88(N***)A=8F B=38 DP=00 X=EAD9 Y=F3B5 U=C066
PC=5001(5A7E5000FF)` [S1BasicMan p.166]. (Level-3 monitor commands are documented in the
L3 manuals, not here.)

## 11. Interrupts (as far as the manuals go)

- NMI: BREAK key when KB BM = 1 [S1OpMan p.95]; TRACE counter ($FFD1 write) [S1OpMan
  p.88]; address trap TRAPF ($BF000-$BFFFF) [S1OpMan p.107]. IMK in FUSE masks NMI,
  FIRQ and IRQ together [S1OpMan p.106].
- FIRQ: timer (Mode B, $FFCA bit 7, masked by $FFD4 bit 7); high-speed timer 1 ms/2 ms
  (Mode A, $FFCA bit 6, masked by $FFD4 bit 1, period by $FFD4 bit 0) [S1OpMan p.88].
- IRQ: keyboard (KB SS = 1, flag in $FFE0 bit 7) [S1OpMan p.95-96]; ACIA (status bit 7)
  [S1OpMan p.88]; mouse button (MOUSE0 IE) [S1OpMan p.94]; $FFD9 has an IRQF flag and
  IE (TRQ-SEL, undocumented).
- Entering any interrupt switches the MMU to system mode [S1OpMan p.106].
- BASIC-level interrupts: ON COM, ON ERROR, ON INTERVAL, ON KEY, ON MTRIG, ON STRIG; ON
  PEN is not available in S1 BASIC [S1BasicMan p.43].

## 12. Options listed [S1OpMan p.75-80]

MPC-RA64S 64 KB RAM card (up to 4, with MPC-EX01S Expansion Board A); MPC-VS01S video
superimpose card (with C15-B01 RGB TV); MP-3710 mouse; MP-7932/MP-9732 RS-232C connector;
MPC-KA01S kanji ROM card (standard on /20); MP-9740/9740A kanji ROM cards, MP-1810
printer card, MP-1820 RS-232C card (up to 5 ports), MP-1895 PIA card (2 PIAs) — these
four are "option cards for the Basic Master Level-3 series" needing MPC-EX02S Expansion
Board B. Floppy cards MP-1870 (Board A) and MP-1802/1802A, MP-1806 (Board B). Displays
C14-2190(A), C12-2120 (640x200), K12-2070P (green mono), C15-B01. Recorders TRQ-359,
TRQ-1500, TRQ-2400.

## 13. Expansion connector pinout (72-pin, "Hitachi format") [S1OpMan p.128]

1 +5V, 2 GND, 3-10 D0-D7, 11-26 A0-A15, 27 BA, 28 BS, 29 ROM-KIL (in), 30 EXROM-KIL (in),
31 R/W IN, 32 EX-I/O, 33 R/W OUT, 34 VMA OUT, 35 E, 36 Q, 37 RES, 38 NMI (in), 39 IRQ (in),
40 FIRQ (in), 41 HALT (in), 42 VMA CTRL (in), 43 DMA (in), 44 TMG2, 45 HALT ACK,
46 SOUND IN (in), 47 16MCK, 48 GND, 49 2MCK, 50 GND, 51 —, 52 EX-I/O2, 53 -12V, 54 +12V,
55 GND, 56 +5V, 57 A16, 58 A17, 59 A18, 60 A19, 61 RAMO, 62 MPUE, 63 RAS, 64 CAS, 65 REF,
66 RASCAS, 67 INT REF KIL (in), 68 SO IF SEL (in), 69 WAIT, 70 MBC (in), 71 BREQ OUT,
72 BG IN.
**Note the "16MCK" and "2MCK" clock pins: a 16 MHz-class master clock (likely 16.128 MHz)
and a 2 MHz-class clock are on the bus.** ROM-KIL / EXROM-KIL let cards disable the
on-board ROMs.

Other connectors [S1OpMan p.126-127]: B/W 4-pin DIN (3 VIDEO, 2 GND); printer 36-pin
(1 STRB, 2-9 D0-D7 interleaved, 10 ACK, 16/33 GND), STROBE timing 0.99 µs min.

## 14. Conflicts with MAME, summary

1. MAME's `mbs1` has no FUSE/system-mode override of $E000-$FFFF, no TRAPF/IMK, no PSG,
   no auto-1 MHz on I/O access, no graphics planes/palette, a stub text renderer.
2. PIA-BANK bit 0: manual = $8000-$9FFF RAM/ROM; MAME = $F000-$FEFF RAM view (and bit 1
   doubles as $FFF0 vectors). Needs a verdict.
3. $FFD7: manual 4-bit baud select with 300/600/1200/2400/4800/3200; MAME 1 bit.
4. $F0000-$F9FFF in Mode B: manual "system RAM image"; MAME separate RAM.
5. $FFD5 light pen register: absent on the S1; LPFLG at $FFCB instead.
6. $FFC9 DIPSW reads a fixed $03 on the S1 (MAME's mbs1 inherits the L3 DIP port with a
   40/80 column switch at bit 2).
7. Cassette power-on baud: operation manual (1200) vs BASIC manual (600) disagree with
   each other.
