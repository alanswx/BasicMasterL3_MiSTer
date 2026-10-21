# Basic Master Level 3 / MB-S1 hardware, from the original documentation

Compiled 2026-10-21. Every fact carries a citation. Where a source note goes into more detail
(full tables, transcriptions), it is named; those per-source notes are in `ref/notes/sources/`.
The documents themselves are indexed in `ref/SOURCES-docs.md`.

## 0. Sources and how to read the citations

| Key | Document | Page numbering used here |
|---|---|---|
| **SVC** | Hitachi *Personal Computer MB-6890 Service Manual*, Rev. 0, 30/12/1981, English. `ref/docs/service/MB-6890-service-manual/manualslib-pages/` | **printed page**; image file `pNNN` = printed + 2. MAME's "service manual p.N" citations use the same printed numbers |
| **PeachROM** | Rossell & Viccars, *Peach ROM Notes* rev 2 (The Software House, Canberra, 1982). A commentary on the MB-6890 ROM disassembly | printed section page "s.X-Y" |
| **L3UserMan** | *Hitachi MB-6890 BASIC Master Level-3 User and BASIC Programming Manual* (English, Australian "Peach") | PDF page (printed = PDF − 9) |
| **L3DiskBasic / L3AsmMan** | MB-6890 Level-3 Disk BASIC manual; Assembler manual 1983 | PDF page |
| **S1OpMan** | *Hitachi Personal Computer MB-S1 10/20 Operation Manual* (English translation). Section 11 "System Description" is the S1 hardware manual and also documents the L3-compatible I/O | PDF page (printed = PDF − 13) |
| **S1BasicMan / S1DiskBasic / S1Brochure** | MB-S1 BASIC manual, Disk BASIC MA-S101 manual, export brochure | PDF page |
| **MP1802Tech** | *MP-1802 / MP-3550 Technical Manual* (English) | printed page / image number |
| **MP1802** | MP-1802 fitting sheet 「サービスマンの方へ」 | PDF page |
| **Calder** | P. F. Calder, *Notes on Hitachi Peach Double Density DOS*, Aug 1983 | PDF page |
| **Phase** | *The Australian Phase* v1n3 (1985), incl. Calder's "Interfacing to the MB-6890" | PDF page |
| **PUN** | *Peach User Notes* v2n3/v2n4 (1984), MB-S1 review | PDF page |
| **sasaji** | s-sasaji's Basic Master pages (mirrored in `ref/web/s-sasaji/`) | page name; see `sources/s-sasaji.md` |

"Peach" is the export (Australia/NZ) name of the MB-6890. All the English L3 sources describe
the **MB-6890**. Nothing found documents the Mark II (MB-6891) or Mark 5 (MB-6892) directly; the
Mark 5 registers ($FFE8-$FFEA) are known here only from the MB-S1 manual (B mode) and s-sasaji.

**MAME** means `~/Documents/development/BasicMasterJr_MiSTer/mame/src/mame/hitachi/bml3.cpp`
(`bml3.h`, `mbs1.cpp`, `mbs1_mmu.cpp`, `src/devices/bus/bml3/`). Conflicts are marked
**⚠ MAME** and collected in §16.

---

## 1. Clocks and bus timing (MB-6890)

Clock tree [SVC p.41, p.48-49, Fig 6-6]:

| Signal | Frequency | Derivation / use |
|---|---|---|
| X1 crystal | **32.256 MHz** | 3rd-overtone oscillator IC43 (74S04) with LC tank |
| QA of IC37 (74S163) | 16.128 MHz | 80-column dot clock (= 80×8 dots / 39.68 µs); system-signal generator; RS-232C baud source; **16MCK** on the slots |
| QB | 8.064 MHz | 40-column dot clock |
| QC | 4.032 MHz | 6809 **EXTAL** |
| QD | 2.016 MHz | 80-column character clock (CRTC CLK in 80 col); **2MCK** on the slots |
| E | **1.008 MHz** | EXTAL/4. Also 40-column character clock |
| H | 15.75 kHz | 2.016 MHz/128 = 1.008 MHz/64 |
| V | 60 Hz | H/262.5 |

- Slot pins 47/49 carry 16MCK = 16.128 MHz and 2MCK = 2.016 MHz [L3UserMan p.209]; [SVC p.5].
  MAME's clocks match [SVC p.48] (see `sources/svc-B.md` §5).
- CPU: HD6809P / MC6809L (internal-clock 6809, EXTAL input) [SVC p.8, p.44]. The MPU timing phase is
  trimmed per CPU "grade" with jumpers on the IC42 (LS164) tap chain [SVC p.83]: the CPU clock comes
  from the same counter chain as video.
- **Memory is interleaved with video.** In each 1 µs E cycle the E-low half is the display period
  (CRTC address drives DRAM) and the E-high half is the MPU period. In 80-column mode two display
  bytes are fetched per E-low half using DRAM page mode. There are no CPU wait states [SVC p.50,
  p.57, p.59, Fig 6-9].
- The video/DRAM signals (CHRCK, LOAD, GRENBL, RAS, CAS φ1/φ2, MPU DISP SW) are gates of a 74LS164
  that shifts E with the 16.128 MHz clock (62.5 ns taps). Pulse widths are tabulated in
  `sources/svc-B.md` §5.2 [SVC p.50-51].
- MB-S1: HD68B09E, 1 MHz or 2 MHz. **Any access to the system I/O area automatically drops the clock
  to 1 MHz**, so L3 option cards keep their timing; `$FFEB` bit 1 selects 2M/1M [S1OpMan p.98-99].
  B mode runs at 1 MHz by default and can be poked to 2 MHz [PUN p.3, p.12]. The S1 slots also carry
  16MCK and 2MCK [S1OpMan, expansion pinout; see `sources/s1-manuals.md`]. The S1 PSG is clocked at
  1.008 MHz [S1BasicMan p.49].

---

## 2. Memory map (MB-6890)

### 2.1 Standard machine

| Range | Contents | Source |
|---|---|---|
| `$0000-$03FF` | Work area (1); RAM JMP slots for vectors at `$0100-$0111` | [SVC p.81]; [PeachROM s.A-3] |
| `$0400-$43FF` | Display RAM (up to 16 KB) in main RAM, **with a 5-bit colour RAM in parallel**. Only the part needed by the power-on mode is used as VRAM | [SVC p.41, p.57-59, p.81] |
| after the display area to `$7FFF` | Work area (2) (keyboard buffer etc.), then user RAM. BASIC's start moves with the mode | [SVC p.81]; [PeachROM s.5-1] |
| `$8000-$9FFF` | **Empty**: socket IC2 ("BASIC expansion" 8 KB ROM, not fitted), or RAM3-card RAM | [SVC p.46, p.76] |
| `$A000-$BFFF` | IC3 µPD2364C-330 BASIC ROM | [SVC p.46] |
| `$C000-$DFFF` | IC4 µPD2364C-331 BASIC ROM | [SVC p.46] |
| `$E000-$FEFF` | IC5 µPD2364C-332 BASIC + monitor ROM | [SVC p.46] |
| `$FF00-$FFBF` | Not decoded on the main board; slot I/O (`/EX-I/O` = `$FF00-$FF7F`, `/EX-I/O2` = `$FF80-$FFBF`) | [SVC p.45]; [Phase p.38] |
| `$FFC0-$FFEF` | System I/O (§3) | [SVC p.43] |
| `$FFF0-$FFFF` | Vectors, from the top of IC5 | [SVC p.18, p.46] |

User RAM start by mode (cassette BASIC): 40 normal `$0B68` (service manual: `$0868`), 80 normal
`$0F68`, 40 hi-res `$2768`, 80 hi-res `$4768` [PeachROM s.A-11]; [SVC p.81]; [L3AsmMan p.13].
Screen RAM ends at `$07FF`, `$0BFF`, `$23FF` or `$43FF` and the keyboard work area follows at
`$0800`, `$0C00`, `$2400` or `$4400` [PeachROM s.5-1].

Main RAM is 32 KB of HM4716 (16K×1) DRAM: IC56-63 = `$0000-$3FFF`, IC69-76 = `$4000-$7FFF`. The
colour RAM is IC64-68 (16K×5) [SVC p.57-58, Table 6-10]. 21 DRAM chips in total [SVC p.8-9].

### 2.2 Address decoding [SVC p.45-48]

- **ROMs are selected only on reads** (IC11 74LS139 enabled by NAND(AB15, R/W)). Writes to
  `$8000-$FFFF` go to whatever RAM card is fitted below, otherwise nowhere [SVC p.45].
- `/ROM-KIL` (slot pin 29, RAM3/RAM4 pin 23; AND-ed in IC138) disables all main-board ROM selects
  for the current cycle; a slot card or RAM card asserts it for the addresses it serves [SVC p.45,
  p.75-77].
- IC5 is gated off in `$FF00-$FFEF` [SVC p.45, p.47].
- System I/O decoder: IC30 (8-input NAND of AB8-15) + IC12 (74LS138: A=AB3, B=AB4, C=AB5, G1=AB6,
  G2 from IC30/AB7) gives 8-byte blocks: Y0 `$FFC0-7` PIA/ACIA/CRTC, Y1 `$FFC8-F`, Y2 `$FFD0-7`,
  Y3 `$FFD8-F`, Y4 `$FFE0-7`, Y5 `$FFE8-F` (unused on MB-6890) [SVC p.45, p.47]. IC11/IC13 then
  decode AB2-0. Partial decoding means **mirrors within each 8-byte block are likely** (e.g.
  `$FFD8-$FFDF` all hit C-REG-SEL); confirm against EmuB.
- RAM decoder: IC33 gives RAM1 SEL (`$0000-$3FFF`) and RAM2 SEL (`$4000-$7FFF`); IC137 decodes
  AB15-AB11 into the expansion selects `/A89-SEL` `$8000-$9FFF`, `/AAB-SEL` `$A000-$BFFF` (RAM3)
  and `/ACD-SEL` `$C000-$DFFF`, `/AE-SEL` `$E000-$EFFF` (RAM4) [SVC p.46, p.48, Table 6-7].

### 2.3 RAM expansion and banking

- The RAM3/RAM4 connectors carry **raw DRAM signals** (AR0-6, /RAS, /CAS φ2, /WE) plus the block
  selects; expansion boards are bare 16K DRAM driven by the main board's controller
  [SVC p.4].
- Configurations (Fig 6-46) [SVC p.75-76]:
  - standard: nothing at `$8000-$9FFF`;
  - one 8 KB card in RAM3 → RAM at `$8000-$9FFF` (40 KB machine; MP-9717/MP-9718) [L3AsmMan p.9];
    [MP1802Tech p.65];
  - maximum: RAM3 = 16 KB at `$8000-$BFFF`, RAM4 = 12 KB at `$C000-$EFFF`; ROM-KIL disables IC2-IC4
    and the BASIC part of IC5, leaving only the monitor at `$F000-$FEFF` and `$FFF0-$FFFF`
    [SVC p.75-76]; [L3UserMan p.27] ("60 KB").
- **PIA port A (`$FFC0`) is the memory bank-switch port** for the RAM cards; port B is the printer
  [PeachROM s.B-1, s.3-3]; [Phase p.33, p.39]. The MB-6890 service manual only says port A goes to
  connector H [SVC p.73]. Bit meanings as documented by the MB-S1 manual for B mode
  [S1OpMan p.90]:

  | PA bit | 0 | 1 |
  |---|---|---|
  | D0 | RAM at `$8000-$9FFF` | ROM (power-on: D0-D3 = 1; RAM under ROM is write-only) |
  | D1 | RAM selected at `$A000-$BFFF` | ROM |
  | D2 | RAM selected at `$C000-$DFFF` | ROM |
  | D3 | RAM selected at `$E000-$EFFF` | ROM |
  | D6 | `$A000-$BFFF` RAM write-only (reads give ROM) | with D1 = 0: RAM read/write (no effect when D1 = 1) |
  | D7 | `$C000-$DFFF` / `$E000-$EFFF` RAM write-only | with D2 / D3 = 0: RAM read/write (no effect when D2 / D3 = 1) |

  CRA bit 2 must be set first (data register, not DDR) [S1OpMan p.90].
  s-sasaji's L3 register table agrees for PA1-PA3/PA6/PA7 but marks **PA0, PA4, PA5 unused**
  [sasaji:systemio.htm]. **⚠ MAME** uses bit 0 for `$F000-$FEFF` and bit 1 also for `$FFF0-$FFFF`;
  no document supports that. On the Mark 5 those two areas are switched by `$FFE8` D0/D1 instead
  (below).
- Slot pin 44 **/BANK-SW** ("system/peripheral memory swap") is a main-board output even on the
  MB-6890 [SVC p.5]; [Phase p.38]. Its source is not described.
- **`$FFD7` is model-dependent.** The service manual's memory map [SVC p.81] and the Peach ROM notes
  [PeachROM s.B-1] name it "BANK SEL" with no bits; the English user manual and Phase list it as
  "Open" [L3UserMan p.224]; [Phase p.39]. s-sasaji gives the bits: on the **original Level 3**,
  **D7 = 1 disables the RAM at `$4000-$7FFF`** (BANK-SEL); on **all later models** it is BAUD-SEL,
  **D0: 0 = 600, 1 = 1200 baud** [sasaji:systemio.htm]. On the MB-S1 it widens to a 4-bit BAUD-SEL
  (§7) [S1OpMan p.91]. MAME's 1-bit baud select is therefore right for the Mark II/Mark 5 and wrong
  only for `bml3` (MB-6890).
- `$FFE8` BANK-REG (write; Mark 5, and S1 B mode only) [S1OpMan p.89, p.98]; [sasaji:memory.htm,
  systemio.htm]. Unused ("space") on the MB-6890 [SVC p.81]:

  | Bit | 1 means |
  |---|---|
  | D0 | standard RAM at `$F000-$FEFF` |
  | D1 | standard RAM at `$FFF0-$FFFF` |
  | D2 | swap the VRAM area `$0400-$43FF` between standard and expansion RAM |
  | D3 | expansion RAM at `$0000-$7FFF` |
  | D4 | expansion RAM at `$8000-$FFFF` |
  | D5 | expansion RAM `$0000-$7FFF` read/write (0 = write-only) |
  | D6 | expansion RAM `$8000-$FFFF` read/write (0 = write-only) |

  Expansion RAM has priority over ROM and standard RAM; with IGMODREG set, writes to `$A000-$A7FF`
  go to IG RAM first [sasaji:memory.htm]. MAME does not implement `$FFE8`.

---

## 3. System I/O registers ($FFC0-$FFEF)

### 3.1 Register map (MB-6890, service manual Table 6-1 and Fig 7) [SVC p.43, p.81]

| Addr | Name | R/W | D7 | D6 | D5 | D4 | D3 | D2 | D1 | D0 | Function |
|---|---|---|---|---|---|---|---|---|---|---|---|
| FFC0-FFC3 | PIA HD46821P (IC85) | R/W | | | | | | | | | Port A: memory bank switch; port B: printer [SVC p.72-73]; [PeachROM s.B-1] |
| FFC4-FFC5 | ACIA HD46850P (IC84) | R/W | | | | | | | | | Cassette and RS-232C (routed by FFD0 bit 5) [SVC p.72] |
| FFC6-FFC7 | CRTC HD46505SP (IC36) | R/W | | | | | | | | | RS = A0 [SVC p.52] |
| FFC8 | KBNMI | R | BK | - | - | - | - | - | - | - | BK = 1: BREAK pressed (NMI source). Read clears [SVC p.43]; [PeachROM s.B-3] |
| FFC9 | DIPSW | R | SW8 | SW7 | SW6 | SW5 | SW4 | SW3 | SW2 | SW1 | 8-pole DIP, open = 1 (§9) [SVC p.43, p.88] |
| FFCA | TIMER | R | T | - | - | - | - | - | - | - | T = 1: timer interrupt pending; read clears [SVC p.43]; [PeachROM s.B-3] |
| FFCB | LPFLG | R | LP | - | - | - | - | - | - | - | LP = 1: light-pen interrupt; read clears [SVC p.43]; [PeachROM s.B-3] |
| FFCC-FFCF | — | | | | | | | | | | open [SVC p.81] |
| FFD0 | MODE SEL | W | W | HR | C | - | - | GB | RB | BB | §3.2 [SVC p.43] |
| FFD1 | TRACE | W | - | - | - | - | - | - | - | - | A write starts the trace counter → NMI [SVC p.43] |
| FFD2 | REMOTE | W | RM | - | - | - | - | - | - | - | RM = 1: cassette relay on; cleared by reset [SVC p.43, p.72] |
| FFD3 | MUSIC SEL | W | MS | - | - | - | - | - | - | - | Speaker level [SVC p.43, p.74] |
| FFD4 | TIME MASK | W | TM | - | - | - | - | - | - | - | TM = 1: timer interrupt prohibited [SVC p.43] |
| FFD5 | LPENBL | W | LE | - | - | - | - | - | - | - | LE = 1: light pen enabled [SVC p.43] |
| FFD6 | INTERLACE SEL | W | - | - | - | - | IS | - | - | - | IS = 1 interlace (latched on the strobe from D3) [SVC p.43, p.54] |
| FFD7 | BANK SEL | W | SW | | | | | | | | MB-6890: SW = 1 disables RAM `$4000-$7FFF` [sasaji:systemio.htm]; named only in [SVC p.81]. Mark II/5: D0 = baud. See §2.3 |
| FFD8 | C-REG-SEL | R/W | MK | - | - | GC | RV | G | R | B | Colour register (§4.5) [SVC p.43, p.45] |
| FFD9-FFDF | — | | | | | | | | | | "space" [SVC p.81] |
| FFE0 | KB (write) | W | BM | SS | - | - | UE | SL | HR | KN | §5 [SVC p.43, p.45] |
| FFE0 | KB (read) | R | key code (bit 7 = key flag) |||||||| [SVC p.43, p.65] |
| FFE1-FFEF | — | | | | | | | | | | "space" on MB-6890 [SVC p.81] |

The English user manual's Table S.2 agrees except that it calls `$FFD5` "Light pen register" and
`$FFD7` "Open", and labels `$FFCA` "Timer interrupt (IRQ)" [L3UserMan p.224]. The interrupt *line* is
FIRQ (§6).

### 3.2 `$FFD0` MODE SEL [SVC p.43, Table 6-2]; [PeachROM s.B-3]; [S1OpMan p.90-91]

| W (b7) | HR (b6) | Mode |
|---|---|---|
| 0 | 0 | 40 columns, high resolution |
| 0 | 1 | 40 columns, normal |
| 1 | 0 | 80 columns, high resolution |
| 1 | 1 | 80 columns, normal |

- C (b5): 0 = ACIA to cassette, 1 = ACIA to RS-232C. It switches the ACIA clock source and the RxD
  source (IC111) [SVC p.65, p.67].
- GB RB BB (b2-0): background colour (code table in §4.5).
- MB-S1 adds IB (b3): background brightness; W and HR are ignored in S1 mode [S1OpMan p.90-91].
- ROM copy at `$0249` [PeachROM s.A-7].

### 3.3 MB-S1 additions to the common I/O area [S1OpMan p.88-99]

`$FFC9` reads a constant `$03`; `$FFCB` reads 0 (no light pen); `$FFCA` bit 6 T2 = 1 ms/2 ms
high-speed timer (S1 mode); `$FFD4` bits 1-0 TM2/T2S; `$FFD7` BAUD-SEL (§7); `$FFD8` bit 5 IG;
`$FFD9` TRQ-SEL; `$FFDC-$FFDF` mouse; `$FFE1` keyboard type; `$FFE2` video superimpose;
`$FFE4/$FFE5` PSG (AY-3-8910 type); `$FFE8` BANK-REG (B mode only); `$FFE9` IGMODREG; `$FFEA`
IGENREG; `$FFEB` SYS-MODE; `$FF75/$FF76` kanji ROM. Full bit table: `sources/s1-manuals.md` §5.

---

## 4. Video

### 4.1 CRTC programming by the ROM [PeachROM s.B-2]

| Reg | 40 col | 80 col | | Reg | Interlace | Non-interlace |
|---|---|---|---|---|---|---|
| R0 H total | `$3F` | `$7F` | | R8 interlace/skew | `$83` | `$80` |
| R1 H displayed | `$28` | `$50` | | R9 max raster | `$0E` | `$07` |
| R2 H sync pos | `$31` | `$5F` | | R10 cursor start | `$2E` | `$27` |
| R3 sync widths | `$85` | `$8A` | | R11 cursor end | `$0F` | `$07` |
| R4 V total | `$1F` | `$1F` | | R12/R13 start | `$04`/`$00` | `$04`/`$00` |
| R5 V adjust | `$06` | `$06` | | | | |
| R6 V displayed | `$19` | `$19` | | | | |
| R7 V sync pos | `$1C` | `$1C` | | | | |

- A BASIC program that restores 25-line text writes R4-R9 = 31, 6, 25, 28, `$83`, 14 [Phase
  p.26-27], i.e. the ROM's normal text mode runs the CRTC in **interlace sync-and-video mode**
  (R8 = `$83`, R9 = 14 = 16 raster addresses per row across two fields). The MB-S1 manual's B-mode
  values are R8 = `$43` interlace / `$40` non-interlace, R9 = `$0E`/`$07` [S1OpMan p.117].
- Non-interlace frame: (31+1) × 8 + 6 = 262 lines → 60 Hz at 15.75 kHz (derived).
- The CRTC hardware cursor is used (CUDISP XORs the cell, §4.7). LOCATE writes R10 bits 6-5 via
  `$0115`; the book's 00/01 labels look swapped relative to the 6845 coding [PeachROM s.6-17].
- `R12 = $04`: the start address is `$0400`. Pages step R12/R13 (normal mode up to 16 pages, hi-res
  up to 2) [PeachROM s.5-5]; [L3UserMan p.12].
- On an MB-S1 in B mode the cursor appears one column to the right of where an L3 shows it [PUN p.6,
  p.11] (a cursor-skew difference).

### 4.2 Timing [SVC p.48, p.53, p.63-64]

- Horizontal: 64 characters (40 col, 1.008 MHz) or 128 (80 col, 2.016 MHz) = **63.5 µs**; display
  39.68 µs; ~10 µs, **4 µs HSYNC**, ~10 µs. The HSYNC on the video connector is **regenerated** as a
  fixed 4 µs pulse by IC134/IC135 counting E, synchronised to CRTC HSYNC [SVC p.63].
- Vertical (Fig 6-27): 25 rows displayed = 12.7 ms, "raster return period" 2.4 ms, VSYNC 1.43 ms,
  frame 16.7 ms. Fig 6-11 shows VSYNC ≈ 500 µs and vertical DISPTMG blank ≈ 2.4 ms [SVC p.53, p.64].
- The CRTC clock depends only on 40/80 columns (1.008/2.016 MHz). Interlace is done by CRTC
  programming plus the `$FFD6` raster remap. **⚠ MAME** doubles the CRTC clock in interlace.
- Character cell 8×8 (non-interlace), 8×16 (interlace) [SVC p.64]; [L3UserMan p.12].

### 4.3 Display addressing [SVC p.54-56]; [L3UserMan p.147-149]; [PeachROM s.5-3]

- Normal mode: one byte per cell, `$0400 + row×W + col` (W = 40 or 80); rows end at `$07E7`/`$0BCF`.
- Hi-res mode: the CRTC raster address is added into MA10-MA13 by IC40 (74LS283) through IC51:
  **address = MA + raster×`$400` (40 col) or raster×`$800` (80 col)**. 40 col: `$0400-$23E7`;
  80 col: `$0400-$43CF` [SVC p.54-55, Fig 6-17/6-18].
- With interlace the IC141 mux remaps RA0-3 so that the downstream raster address RAA1-3 is the same
  in both modes [SVC p.54-55].

Graphic resolutions (Table 6-13) [SVC p.63]: normal 40 → 80×100 (1000 B), normal 80 → 160×100
(2000 B), hi-res 40 → 320×200 (8000 B), hi-res 80 → 640×200 (16000 B).

### 4.4 Pixel formats [SVC p.60-63]

- **Hi-res graphic cell** (colour bit 4 = 1): each raster has its own byte; **D7 = leftmost** dot
  [SVC p.62, Fig 6-25b].
- **Normal-mode semigraphics** (bit 4 = 1): each byte is a 2×4 grid of blocks, each block 4 dots ×
  2 rasters. Left column top→bottom = DD4, DD5, DD6, DD7; right column = DD0, DD1, DD2, DD3
  [SVC p.61-62, Fig 6-25a]. This agrees with MAME. The user manual's Fig 1.8 draws the left column
  as bits 0-3 [L3UserMan p.22]; the service manual's circuit-level description wins.
- **Characters** (bit 4 = 0) go through the character generator in both normal and hi-res modes.
  In hi-res each raster line shows row *r* of the glyph whose code is in that raster's byte; the ROM
  writes the same code into all 8 bytes [L3UserMan p.150]; [PeachROM s.5-4].

### 4.5 Colour RAM and the colour register `$FFD8` [SVC p.45, p.57-59]; [S1OpMan p.92-93]

Colour RAM (5 bits per display byte, IC64-68):

| Bit | 4 | 3 | 2 | 1 | 0 |
|---|---|---|---|---|---|
| 1 | graphic | reverse | green | red | blue |
| 0 | character | normal | — | — | — |

Colour codes (GRB): 0 black, 1 blue, 2 red, 3 magenta, 4 green, 5 cyan, 6 yellow, 7 white
[SVC p.43, p.105]. Background uses the same code in `$FFD0` bits 2-0.

Mechanism [SVC p.59]:
1. CPU **write** to `$0400-$43FF`: the byte goes to main RAM and **the colour register (IC77,
   74LS174) is written into colour RAM at the same address**.
2. CPU **read** of `$0400-$43FF`: the CPU gets the main-RAM byte, and **if MK = 0** the colour RAM
   value at that address is loaded into the colour register (so it can be read back at `$FFD8`).
   With MK = 1 the register keeps its contents.
3. Colour RAM exists only for `$0400-$43FF`.

Table 6-3 calls MK "0 = enable write, 1 = prohibit write", but the circuit text only describes MK
gating the read-back; MAME behaves the same way (writes always go through) and notes that gating
writes breaks HI-WRITER. The S1 manual describes MK exactly as the read-back mask [S1OpMan p.92].
The ROM keeps a copy at `$0116` [PeachROM s.B-5]. Machine code that reads `$0400-$43FF` with MK = 0
changes the colour register under BASIC's feet [PeachROM s.5-2, s.8-3]. MB-S1 adds bit 5 IG
(IG display priority) [S1OpMan p.92].

### 4.6 Character generator [SVC p.8, p.19, p.60-62, Fig 6-22/6-23]

- IC107 **µPD2332C-328, 4 KB** mask ROM. /CS = colour bit 4 (characters only). Address A1-A3 =
  RAA1-3, A4-A11 = the display byte; A0 and A11 are modified by the interlace circuit.
- Layout: area 1 = 2 KB **interlace** glyphs (128 chars × 16 bytes), area 2 = 1 KB **non-interlace**
  glyphs (128 × 8), area 3 = 1 KB **common** glyphs (128 × 8). Non-interlace uses areas 2+3;
  interlace shows area-3 glyphs line-doubled and the 128 "complex" characters from area 1.
- The two modes show different glyphs for `$80-$9F` and `$E0-$FF`: interlace has kanji-like symbols
  (年月日…) and hiragana; non-interlace has block/line graphics and symbols [L3DiskBasic
  p.147-148]. The service manual's character-ROM test prints both sets [SVC p.104, p.109].
- Glyph quirks: `$7F` DEL shows a backslash, `$5C` shows ¥, `$60` shows a space [PeachROM s.D-12].
- ⚠ MAME's font is "handcrafted" and cannot be right for interlace glyphs.

### 4.7 Video output [SVC p.60-64]

Character/graphic byte → IC117 (74LS166) shifter, loaded by LOAD and shifted at DOTCK → XOR with
REV and with CUR DISP (**the cursor inverts the cell**) → IC118 (74LS158) picks per dot between the
foreground (colour RAM G/R/B, latched per character by IC115 then per dot by IC116) and the
background (`$FFD0`) → IC132 (74S05) → TTL RGB. Monochrome composite is a resistor mix of R, G, B
and sync through Q5 [SVC p.60-64].

Colour DIN (8-pin): 1 +12 V, 2 GND, 3 /PEDSTL, 4 /HSYNC, 5 /VSYNC, 6 R, 7 G, 8 B [SVC p.3];
[Phase p.27].

---

## 5. Keyboard [SVC p.41, p.45, p.65-66, Fig 6-28]; [PeachROM s.4]; [S1OpMan p.95-96, p.120]

- Hardware scan of a **16 × 8 matrix** (7-bit code): IC101/IC102 (74LS93) count **HP = the
  15.75 kHz horizontal pulse**; IC86 (74159) drives the 16 columns; IC90 (74LS151) reads the
  8 rows [SVC p.65].
- When the scan reaches a pressed key the counter **stops** (IC99), the HP gate closes, and **IRQ**
  is raised if SS = 1. The IRQ routine reads `$FFE0`, which returns the counter (bit 7 set =
  key flag); the end of the read releases IRQ and restarts the scan [SVC p.65]; [S1OpMan p.96].
- Scan period: **16.25 ms** per full scan (128 codes, the counter stepping at hsync/2) per the Peach
  ROM notes and s-sasaji's measurements [PeachROM s.4-1]; [sasaji:keyboard.htm]. (Reading the
  service manual literally, HP clocking every line would give 8.1 ms; the hsync/2 figure is the
  better-supported one and matches MAME's stepping.)
- After the last key is released the counter goes round once more and, at `$7F`, the register
  outputs **`$FF`** and raises IRQ again; that is how software sees all keys up [PeachROM s.4-2];
  [sasaji:keyboard.htm]. The service manual does not describe this.
- `$FFE0` write [SVC p.45, Table 6-4]: BM (b7) 1 = BREAK NMI enabled; SS (b6) 1 = key IRQ enabled;
  UE (b3) 1 = scan counter stopped; SL/HR/KN (b2-0) = SHIFT, hiragana, katakana LEDs. The ROM keeps
  a copy at `[$01CA]+3` [PeachROM s.B-5].
- Test vector: `POKE &HFFE0,&H0C` then `PEEK(&HFFE0)` gives Space 128, ↑ 129, ← 131, ↓ 132, → 133;
  `POKE &HFFE0,&HF0` restores [L3UserMan p.167-168].
- **BREAK** is not in the matrix code space: it sets `$FFC8` bit 7 and pulls NMI when BM = 1. The ROM
  normally leaves BM = 0 and **polls `$FFC8`**; its NMI handler is just RTI [PeachROM s.4-6];
  [S1OpMan p.95].
- Full code table (codes `$80-$DF`): `sources/peach-rom-notes.md` §4 and the S1 matrix table in
  `sources/s1-manuals.md` §5.5. Examples: Space `$80`, ↑ `$81`, CTRL `$86`, SHIFT `$87`, CAPS `$89`,
  HIRA/KATA `$8A`, GRAPH `$8B`, ESC `$8C`, Q `$A8`, RETURN `$AF`, A `$B8`, Z `$C8`, PF1-PF5
  `$D0-$D4`. The S1 adds INS `$E5`, 変換 `$E7`, COPY `$E8`, TAB `$EC`, pad-comma `$ED`, DEL `$EF`
  [S1OpMan p.120].
- **⚠ MAME** labels `$8B` (GRAPH) "Kana Shift" and swaps the main DEL (`$9E`) and keypad INS/DEL
  (`$98`) labels [PeachROM s.D-3..D-5]; MAME scans only codes below 96; its UE handling
  (`scancode &= 7`) is not in the service manual, which just says UE stops the counter [SVC p.65],
  but s-sasaji says UE = 1 limits the scan to codes `$00-$07` [sasaji:keyboard.htm], which fits the
  user manual's `$0C` test (only Space and cursor keys readable) [L3UserMan p.167]. So MAME is right.

---

## 6. Interrupts

Wiring (open-collector 74LS05 wired-OR into each CPU pin) [SVC p.39, p.41, p.44, Fig 6-2]:

| CPU line | Sources |
|---|---|
| **NMI** | TRACE counter (`$FFD1`); keyboard BREAK (when `$FFE0` BM = 1); slots (e.g. MP-1802 FDC INTRQ) |
| **FIRQ** | **Timer** (60 Hz; flag `$FFCA` b7; mask `$FFD4` b7 = 1); slots |
| **IRQ** | Keyboard (`$FFE0` SS); light pen (`$FFD5` LE, flag `$FFCB`); PIA IRQA/IRQB; ACIA; slots |

- Timer = FIRQ is stated in the text ("FIRQ pin is for Timer interrupt") [SVC p.41], drawn in
  Fig 6-2 [SVC p.44] and confirmed by troubleshooting chart 11-8 (1/60 s pulse at IC16 → IC22 → CPU)
  [SVC p.98]. The user manual's "Timer interrupt (IRQ)" [L3UserMan p.224] and the Peach ROM notes'
  "timer IRQ" are loose wording. MAME (FIRQ) is right. The MB-S1 manual also says timer FIRQ
  [S1OpMan p.88].
- Timer rate: 60 Hz; BASIC counts it at `$0215` [PeachROM s.6-30]; [SVC p.98]. It is clocked from the
  CRTC [SVC p.39].
- TRACE: a write to `$FFD1` raises NMI **15 CPU cycles later**, long enough for an RTI, so the NMI
  hits the next instruction (single-step for DEBUG5A/DEBUG70) [PeachROM s.B-4]. Hardware: IC14
  (LS74) + IC15 (LS93) [SVC p.91]. **⚠ MAME** does not implement it.
- All hardware vectors jump through RAM: SWI3 `$0100`, SWI2 `$0103`, SWI `$0106`, NMI `$0109`,
  IRQ `$010C`, FIRQ `$010F` [PeachROM s.A-3]; [Phase p.39].
- MB-S1: any interrupt switches the MMU to system mode; FUSE IMK masks NMI/FIRQ/IRQ together;
  an access to physical `$BF000-$BFFFF` raises NMI (TRAPF) [S1OpMan p.106-107].

---

## 7. Cassette

- One ACIA (HD46850P at `$FFC4/5`) serves cassette and RS-232C; `$FFD0` bit 5 selects
  [SVC p.65, p.72].
- **Cassette clock: fixed 9.6 kHz** (E ÷ 105, from IC122-124 74LS93 chains), giving **600 baud** at
  ACIA ÷16. The same divider chain gives the FSK tones: 2.4 kHz and 1.2 kHz (Table 6-14) [SVC p.65,
  p.67]. There is **no software baud select on the MB-6890** in this manual.
- SAVE: TxD is latched by IC126 on the 1.2 kHz clock and gates 2.4 kHz or 1.2 kHz out.
  **"1" = 4 cycles of 2400 Hz, "0" = 2 cycles of 1200 Hz** (each bit 1.67 ms) [SVC p.65, p.68,
  Fig 6-30/6-33]; [S1OpMan p.91].
- LOAD: input limited to 1.2 Vpp (D3/D4) → **LM565 PLL** (IC127) → 75108 comparator → ACIA RxD;
  output H for 2.4 kHz, L for 1.2 kHz [SVC p.68-69]. The PLL is adjusted with a 1.7 kHz,
  2 Vp-p sine into JA pin 5 [SVC p.82].
- Framing: 1 start, 8 data, 2 stop ("S8N2", ACIA control `$12`) [PeachROM s.3-12]; [S1OpMan p.123].
  Note `$12` selects ACIA ÷64, which would need a 38.4 kHz clock for 600 baud; the service manual's
  9.6 kHz clock implies ÷16 (control byte `$11`), and s-sasaji's framing analysis agrees
  [sasaji:tape.htm]. The Peach notes' `$12` is probably a misreading; confirm in the ROM.
- Motor: `$FFD2` bit 7 → IC126 → Q4 → relay RL1 on DIN pins 1/4; cleared at reset [SVC p.3, p.72].
- Block format (leader `$FF`s, `$01 $3C`, type, length, data, checksum, five `$00`): see
  `basic-and-monitor.md` §2.2 [PeachROM s.3-12..3-14].
- Cassette DIN: 1 remote, 2 GND, 3 record (out), 4 remote, 5 play (in) [SVC p.3].
- **MB-S1 `$FFD7` BAUD-SEL** (S3-S0) [S1OpMan p.91]: `0000` 600, `0001` 1200, `0010` 2400,
  `0011` 300 (all FSK 1200/2400 Hz); `0110` 4800 (FSK 2400/4800 Hz); `1001` 3200 ("Hitachi's own
  format"). `POKE &HFFD7,4` / `5` are used for double-speed play on the TRQ-1500 [S1OpMan p.68].
  BASIC `MOTOR ,0/1/2` = 600/1200/2400 [S1BasicMan p.170]. The S1 manuals disagree on the
  power-on rate in A mode (1200 vs 600) [S1OpMan p.67]. **⚠ MAME** implements `$FFD7` as a 1-bit
  600/1200 select on the L3.

---

## 8. Sound

- `$FFD3` bit 7 is latched by IC93 (74LS74) on the MUSIC SEL strobe and drives a class-B amplifier
  and a 6×9 cm 16 Ω speaker (0.4 W). A pure **1-bit beeper**; software toggles it [SVC p.2, p.42,
  p.74]; [L3UserMan p.170]. MAME agrees.
- Slot pin 46 SOUND IN is mixed into the amplifier (sound cards) [SVC p.74]; [L3UserMan p.209].
- The timer FIRQ disturbs software tone loops; `POKE &HFFD4,255` gives a clean tone
  [L3UserMan p.169].
- ROM BEEP `$F7A7`, key click `$F7A9` [PeachROM s.6-2].
- MB-S1: AY-3-8910-compatible PSG at `$FFE4` (data) / `$FFE5` (register), 1.008 MHz [S1OpMan p.97];
  [S1BasicMan p.49].

---

## 9. Switches

### 9.1 DIP switch SW (`$FFC9`), open = 1 [SVC p.88, Table 10-1]

| SW | Open (1) | Closed (0) | Factory |
|---|---|---|---|
| 1 | BASIC | Terminal mode | 1 |
| 2 | Interlace (SCREEN ,,0) | Non-interlace | 1 |
| 3 | 80 columns | 40 columns | 1 (*) |
| 4 | Normal | High resolution | 0 (hi-res) |
| 5 | Show PF keys (CONSOLE 0,24,1) | Hide | 0 |
| 6 | Half duplex (terminal) | Full duplex | 0 |
| 7 | 7-bit characters (terminal) | 8-bit | 0 |
| 8 | Print hiragana as katakana | As is | 0 |

(*) The front-panel **MODE** push switch is wired in parallel with SW3 (it pulls the line low), so
with SW3 open MODE "0" = 40 columns and MODE "1" = 80 columns. Chip switch **CS1** can reassign MODE
to SW2 or SW1 instead [SVC p.88-89]. So the factory power-on mode is 40-column hi-res (MODE 0) →
22378 bytes free [L3UserMan p.50]. MAME's DIP definition matches [SVC p.88].

VRAM size is fixed at power-on by SW3/SW4 (and MODE), or later by `NEW ON`; pages available
[L3DiskBasic p.53]: SW4=1,SW3=1 → N40 2 pages, N80 1; SW4=1,SW3=0 → N40 1; SW4=0,SW3=1 → N40 16,
N80 8, H40 2, H80 1; SW4=0,SW3=0 → N40 8, N80 4, H40 1.

### 9.2 Chip switches [SVC p.89-90]; [L3UserMan p.211-217]

- **CS3**: RS-232C baud factor 1-4. Slow/fast (÷64/÷16, chosen by the COM/TERM "S"/"F" option):
  1 → 300/1200, 2 → 600/2400, 3 → 1200/4800, 4 → 2400/—. The RS-232C ACIA clock taps are 153.6,
  76.8, 38.4, 19.2 kHz (16.128 MHz ÷ 105 and halvings) [SVC p.67].
- **CS4**: TxD/RTS polarity, DCD and CTS active or grounded.

---

## 10. Other interfaces

- **Printer**: PIA port B → 74LS05 → Centronics D0-D7; CB2 → STRB (via IC93); CB1 ← BUSY OR ACK
  [SVC p.72-73]. 36-pin connector: 1 /STRB, 2-9 D0-D7, 10 /ACK, 11 BUSY [SVC p.4].
- **RS-232C**: ACIA via HD75188/75189; DB-25: 2 TxD, 3 RxD, 4 RTS, 5 CTS, 7 GND, 8 DCD; CTS/DCD only
  active when RS-232C is selected [SVC p.3, p.69-70].
- **Light pen**: LP-SW AND LP-OUT → LP STB into the CRTC (R16/R17); IRQ when `$FFD5` LE = 1, flag
  `$FFCB`; once per frame while held. DIN: 1 /LP OUT, 2 /LP-SW, 3 +5 V, 4 LP VCMP, 5 GND [SVC p.3,
  p.73-74].
- **Expansion slots I/F-1..6** (56-pin): full pinout in `sources/svc-A.md` §4.7 and
  `sources/peach-misc.md` (Phase table). Key signals: /ROM-KIL (in), /EXROM-KIL, /EX-I/O
  (`$FF00-$FF7F`), /EX-I/O2 (`$FF80-$FFBF`), /NMI /IRQ /FIRQ /HALT /DMA (in), /BANK-SW (out),
  SOUND IN, 16MCK, 2MCK [SVC p.5]; [Phase p.38].
- **RAM3/RAM4** (28-pin): DRAM-level expansion, see §2.3 [SVC p.4].

---

## 11. Floppy: MP-1802 (5.25" 2D) [MP1802Tech]; [Calder]; [MP1802]

- FDC **MB8866** (WD1791-type, inverted data bus: no inverter on the card, so software sees inverted
  register values; MAME agrees) clocked at 16MCK/16 = 1.008 MHz [MP1802Tech p.45-47].
- `$FF00-$FF03`: FDC status/command, track, sector, data. `$FF04` (mirrored to `$FF07`):
  - read: **b7 = /DRQ, b0 = /IRQ** (active low) [MP1802Tech p.39-40, p.45]; [Calder].
  - write: b6 NMI MASK (1 = FDC INTRQ does not reach NMI), b5 1 = double density, b4 side 1,
    b3 motor on, b1-0 drive 0-3 (two units of two); drive select is only decoded while MOTOR ON = 1;
    cleared at reset [MP1802Tech p.39-40, p.48].
- FDC INTRQ drives **/NMI** only; DRQ is polled [MP1802Tech p.40, p.45].
- **Boot ROM**: 2716 "DD-1", decoded only at **`$F800-$FEFF`** (asserts /ROM-KIL to overlay BASIC);
  EXPROM KILL inhibits it; jumper CS612 disables it [MP1802Tech p.41-44]. Calder: bootstrap at
  `$FE7E`, called from `$FB5E`, loads track 0 sectors 1-2 to `$4400` and the DOS into
  `$8800-$9FFF` [Calder]. Disk BASIC MA-5320 needs 40 KB (a RAM3 card) [MP1802 p.1-2].
- The card occupies two slots (MDB-A/MDB-B) and cannot be fitted with an MP-1800/1801/1806
  [MP1802Tech p.4, p.63].
- Format: 40 cylinders × 2 sides × 16 sectors; FM 128-byte, MFM 256-byte sectors; 300 rpm,
  250 kbit/s MFM [MP1802Tech p.2-3, p.27-29]. Calder's DD DOS keeps track 0 side 0 in single density.
- Earlier MB-6890 system: MP-1800 card + MP-3540 drive, SS SD 40 tracks × 16 sectors × 128 bytes,
  directory on track 20 [L3UserMan p.152]; [L3DiskBasic p.54].
- **⚠ MAME** `mp1802.cpp` reads /IRQ from `$FF04` bit 6 (should be bit 0) and also maps the card ROM
  at `$FFF0-$FFFF` (the hardware does not).
- Other slot I/O allocations (Phase Table 2) [Phase p.39]: `$FF00-$FF04` 5"/8" DD controllers,
  `$FF18-$FF20` 5" SD controller, `$FF38-$FF3A` RTC, `$FF3C-$FF3F` extra printer PIAs,
  `$FF40-$FF47` COM1-4 ACIAs, `$FF90-$FF9F` modem card.

---

## 12. Mark II / Mark 5 (MB-6891 / MB-6892)

No Hitachi document for these models was found. What is known indirectly:
- The MP-1802 supports "MB-6890 and Mark II" [MP1802Tech p.1].
- Mark 5 registers, as seen through MB-S1 B mode [S1OpMan p.89, p.98]: `$FFE8` BANK-REG (bits 6-0,
  expanded-RAM banks); `$FFE9` IGMODREG (write b0 PM = 1 enables IG RAM writes; **reading it during
  the display period halts the CPU until the next retrace**); `$FFEA` IGENREG (b2-0 = G/R/B IG plane
  select; all three set = read the font ROM); `$FFD8` bit 5 = IG display.
- `$FFD7` is BAUD-SEL (D0 600/1200) from the Mark II on; `$FFE8` banking as in §2.3
  [sasaji:systemio.htm].
- Mark 5 `$FFC9` has no DIP switches: D0 = D1 = 1, D2 = front-panel MODE switch, D3-D7 = 0
  [sasaji:systemio.htm].
- Mark 5 colour RAM is **6 bits** (the IG bit) [sasaji:memory.htm]. IG characters stay hidden until
  IGMODREG has been written once; IG RAM is write-only from the CPU (except via IGENREG)
  [sasaji:screen.htm]; see `sources/s-sasaji.md`.
- `$EED7` is the reset-switch handler on the Mark II and later; on the MB-6890 that address holds
  the programmer's name (so Phase's "`$EED7` cold start" is a Mark II-era fact)
  [sasaji:basicsub.htm]; [Phase p.39].
- ROM interrupt handlers: FIRQ `$E131` (timer etc.), IRQ `$EA87` (keyboard scan)
  [sasaji:basicsub.htm].

---

## 13. MB-S1

Details with citations: `sources/s1-manuals.md`. Summary:

- **Physical map (1 MB)** [S1OpMan p.85-87]: `$00000-$7FFFF` expansion RAM; `$84000-$8FFFF` system
  RAM 48 KB; `$B0000/$B4000/$B8000` graphic planes R/G/B (16 KB each); `$BC000-$BC7FF` text VRAM +
  colour; `$BD000-$BDFFF` IG RAM (3 × 2 KB) / 4 KB font ROM; `$D0000-$D7FFF` kanji dictionary ROM
  (/20); `$E0000-$EFDFF` S1 BASIC ROM; `$EFE00-$EFEFF` S1-only I/O; `$EFF00-$EFFEF` common I/O image;
  `$EFFF0` S1 vectors; `$F0000-$F9FFF` "system RAM image" in B mode; `$FA000-$FFEFF` Level-3 BASIC
  ROM; `$FFF00-$FFFEF` common I/O; `$FFFF0` B-mode vectors. B mode runs entirely in `$F0000-$FFFFF`.
- **MMU** [S1OpMan p.102-107]: MAP0-MAPF at `$FE00-$FE0F` (8 bits each = A19-A12 for one 4 KB CPU
  page). FUSE `$FE10`: TRON, IMK, FC3-0 (cycles before switching system→user). System mode (reset and
  every interrupt) forces physical `$84000-$84FFF` at CPU `$E000` and `$EF000-$EFFFF` at `$F000`;
  user mode uses MAPE/MAPF and cannot touch the MMU. S1 BASIC never uses user mode. TRAPF `$FE18`,
  BUSCTRL `$FE19`.
- **Graphics I/O** [S1OpMan p.102-112]: `$FE20` BMSK-COLOR, `$FE21` ACTIVE-PLANE (+DW), `$FE23`
  DISP-PAGE, `$FE24` SCRN-MODE (320×200 8 colours / 64 colours with the superimpose card /
  640×200 / 640×400 mono; 40/80 text), `$FE25-$FE27` B/R/G registers (indirect, bit-mask and
  three-plane simultaneous read/write modes), `$FE28-$FE2F` palette (I G R B, 8 of 15 colours),
  `$FE40-$FE41` PIA (joystick).
- **CRTC** HD6845S initial values R0 `$7F`, R1 `$50`, R2 `$5F`, R3 `$8A`, R4 `$1F`, R5 `$06`, R6
  `$19`, R7 `$1C`, R8 `$43`/`$40`, R9 `$0E`/`$07`, R10 `$2E`/`$27`, R11 `$0F`/`$07` [S1OpMan p.117].
- Graphics layout: 320×200 byte = (row/8)×`$28` + (row%8)×`$400` + col; 640×200 uses `$50`/`$800`
  [S1OpMan p.114-116].
- Power-on: SYSTEM switch A/B read at reset [S1OpMan p.22, p.36]. B-mode banner shows 30570 bytes
  free [S1OpMan p.38].
- **⚠ MAME** `mbs1`: no forced system-mode mapping, no FC delay, TRAPF, IMK, BUSCTRL, PSG or
  I/O-access slowdown; separate RAM at `$F0000-$F9FFF` where the manual says "system RAM image".

---

## 14. Chip list (MB-6890 main board BM-A) [SVC p.8-9, p.114-117]

IC1 HD6809P (CPU); IC2 empty ROM socket; IC3-5 µPD2364C-330/331/332 (BASIC/monitor); IC36
HD46505SP (CRTC); IC84 HD46850P (ACIA); IC85 HD46821P (PIA); IC56-76 HM4716AP-1 ×21; IC107
µPD2332C-328 (character ROM); IC37 74S163 (clock divider); IC43 74S04 (oscillator); IC42 74LS164
(timing taps); IC127 LM565 (cassette PLL); IC119/120 HD75188/75189 (RS-232C). Full list and roles:
`schematic-notes.md` and `sources/svc-C.md`.

ROM part numbers: the MB-6890 uses µPD2364C-330/331/332 [SVC p.46]. MAME's labels for `bml3`
(`598 p16611.ic3`, `599 p16561.ic4`, `600 p16681.ic5`) do not match, so MAME's set may be a later
revision. The service manual's ROM checksum test expects **A = 18, B = 178** for a v1.0 set (6809
code transcribed in `sources/svc-C.md`) [SVC p.104, p.109].

---

## 15. Things the documents do not give

- The schematic itself (sections 13-15 of the service manual are missing from the manualslib scan).
  Leads: the 29 MB 1000bit.it copy of the service manual (login), the books I/O別冊「ベーシックマスター
  活用研究」 and 「S1活用研究」 (工学社), an MB-S1 schematic printed in I/O magazine, and the S1 FM card
  schematic in I/O May 1986 [sasaji:s1kbcircuit.htm]. Bus timing / takeover measurements for L3 and S1
  are in `sources/s-sasaji.md` §8.
- A Hitachi document for the Mark II / Mark 5 (their differences are known only via the S1 manual and
  s-sasaji).
- The ROM's actual ACIA control byte for cassette (`$11` ÷16 expected; the Peach notes say `$12`).

---

## 16. Conflicts with MAME (summary)

| # | Topic | Documents | MAME | Verdict |
|---|---|---|---|---|
| 1 | `$8000-$9FFF` | Empty socket on a standard MB-6890; RAM only with a RAM3 card [SVC p.46, p.76] | RAM always | MAME wrong for a stock MB-6890 (fine as a "40 KB" config; Disk BASIC needs it) |
| 2 | RAM under ROM `$A000-$FFFF` | Exists only with RAM3/RAM4 cards; ROM decode is read-only [SVC p.45, p.75] | always present (write-through) | Model as an option / Mark 5 feature |
| 3 | `$FFD7` | MB-6890: BANK SEL, D7 = 1 disables RAM `$4000-$7FFF` [SVC p.81]; [sasaji:systemio.htm]; cassette clock fixed 9.6 kHz [SVC p.67]. Mark II/5: D0 baud 600/1200 [sasaji:systemio.htm]. MB-S1: 4-bit [S1OpMan p.91] | 1-bit 600/1200 baud on all models | Decode per model; MAME wrong only for `bml3` |
| 4 | Timer line | FIRQ [SVC p.41, p.44, p.98]; [S1OpMan p.88] | FIRQ | **MAME right**; the user manual's "IRQ" is loose |
| 5 | `$FFD1` TRACE | NMI 15 cycles after a write [PeachROM s.B-4]; [SVC p.43] | missing | Add (cheap) |
| 6 | `$FFCB` LPFLG, `$FFD5` LE | light pen IRQ [SVC p.43, p.73] | missing | Add as stubs (LPFLG reads 0) |
| 7 | `$FFD0` bit 5 | ACIA cassette/RS-232C routing [SVC p.43, p.65] | ignored | Add |
| 8 | CRTC clock in interlace | depends only on 40/80 [SVC p.48, p.52] | doubled | MAME hack; do not copy |
| 9 | Keyboard scan | 128 codes at hsync/2 (16.25 ms), counter stops on a key, `$FF` + IRQ after release; UE = 1 limits to `$00-$07` [SVC p.65]; [PeachROM s.4-1]; [sasaji:keyboard.htm] | 96 codes; `&= 7` on UE | Use 128 codes and the release `$FF`; MAME's UE handling is right |
| 10 | Key labels | `$8B` GRAPH; `$9E` main DEL, `$98` pad INS/DEL [PeachROM s.D-3] | "Kana Shift"; DELs swapped | Labels only |
| 11 | PIA bank bits | PA1-3/PA6/PA7 for `$A000-$EFFF`; PA0 unused [sasaji:systemio.htm] (S1 manual: PA0 = `$8000-$9FFF` [S1OpMan p.90]); Mark 5 `$F000`/`$FFF0` RAM via `$FFE8` D0/D1 | PA0 = `$F000-$FEFF`, PA1 also `$FFF0` | MAME unsupported; follow s-sasaji/EmuB |
| 12 | MP-1802 `$FF04` read | /IRQ = bit 0 [MP1802Tech p.39-40]; [Calder] | bit 6 | **MAME wrong** |
| 13 | MP-1802 ROM window | `$F800-$FEFF` only [MP1802Tech p.41-44] | also `$FFF0-$FFFF` | MAME overlays vectors; hardware does not |
| 14 | Character ROM | 4 KB µPD2332C-328 with interlace/non-interlace/common areas [SVC p.60-62] | handcrafted font | Need the real 4 KB font |
| 15 | ROM part numbers | µPD2364C-330/331/332 [SVC p.46] | `598 p16611` etc. | Different revision? Verify with the ROM-C checksum |
| 16 | MB-S1 MMU details | forced system-mode `$E000-$FFFF`, FC delay, TRAPF, IMK [S1OpMan p.105-107] | not modelled | Use EmuB-S1 |
| 17 | MB-S1 `$F0000-$F9FFF` | "system RAM image" [S1OpMan p.87] | separate RAM | Unresolved |
| 18 | MB-S1 I/O clock slow-down | 1 MHz on any system-I/O access [S1OpMan p.98] | not modelled | Model it |
