# s-sasaji (bml3mk5) site: hardware notes

Source: local mirror `ref/web/s-sasaji/s-sasaji.ddo.jp/bml3mk5/` (Japanese, by Sasaji, the author
of EmuB-6892 and EmuB-S1). Most pages describe the **Mark 5** (MB-6892), checked on real hardware.
Citations: [sasaji:<page>.htm]. "MAME" means `src/mame/hitachi/bml3.cpp` in the local checkout.
Cross-references to the other work notes use their file names (svc-B = MB-6890 service manual,
PeachROM = Peach ROM Notes, S1OpMan = MB-S1 operation manual, L3UserMan = English user manual).

Sasaji's own references are two books he names repeatedly: **I/O別冊 ベーシックマスター活用研究**
and **I/O別冊 S1活用研究** (both 工学社). He also says an S1 schematic was published in I/O
magazine [sasaji:s1kbcircuit.htm], and that the S1 FM card schematic appeared in I/O, May 1986
[sasaji:s1fmopn.htm]. These are leads for schematics.

---

## 1. Memory map and banking

### 1.1 Map (Mark 5) [sasaji:memory.htm, memmap01.png]

| Range | Standard | Notes |
|---|---|---|
| $0000-$03FF | RAM | work area |
| $0400-$43FF | RAM (VRAM) + colour RAM | the colour RAM is drawn as **6 bits** wide on the Mark 5 |
| $4400-$87FF | RAM | |
| $8800-$9FFF | RAM | DISK BASIC lives here when loaded |
| $A000-$FEFF | ROM, with RAM underneath | the IG RAM (3 planes) overlays $A000-$A7FF for writes |
| $FF00-$FFEF | system I/O | |
| $FFF0-$FFFF | interrupt vectors (ROM), with RAM underneath | |
| Expansion RAM | $0000-$FFFF (64 KB card, Mark 5 only) | |

The Mark 5 has 64 KB of standard DRAM. A further 64 KB can be added on the RAM connector
[sasaji:l3exmem.htm].

### 1.2 PIA port A ($FFC0): standard-RAM bank switching [sasaji:memory.htm, systemio.htm]

Power-on state: PA1, PA2 and PA3 are all 1 (ROM). Sasaji warns not to bank out the ROM from BASIC.

| Bit | 0 | 1 |
|---|---|---|
| PA1 | $A000-$BFFF selects RAM | ROM |
| PA2 | $C000-$DFFF selects RAM | ROM |
| PA3 | $E000-$EFFF selects RAM | ROM |
| PA6 | $A000-$BFFF write-only (ROM read, RAM written) | with PA1=0: $A000-$BFFF read/write RAM |
| PA7 | $C000-$DFFF write-only | with PA2=0: $C000-$DFFF read/write RAM |
| (PA7, row unlabelled on the site) | $E000-$EFFF write-only | with PA3=0: $E000-$EFFF read/write RAM |

The register table marks PA0, PA4 and PA5 as "x" (unused) [sasaji:systemio.htm].

Example sequence from the page: `CLR $FFC1` (select DDRA), `LDA #$FF / STA $FFC0` (all outputs),
`LDA #$04 / STA $FFC1` (select PRA), `LDA #$0C / STA $FFC0`. $0C means PA1=0 (A000 RAM), PA2=1,
PA3=1, PA6=0. Read literally from the table, $A000-$BFFF is then in write-only mode (ROM read, RAM
written); the page only calls it "bank switch" [sasaji:memory.htm].

**Conflicts on the PIA bank bits:**
- **MAME** uses PA1+PA6, PA2+PA7 and PA3+PA7 the same way, **but also uses PA0 for $F000-$FEFF and
  PA1 for $FFF0-$FFFF**. Sasaji gives no PIA bit for $F000-$FEFF or $FFF0-$FFFF. On the Mark 5 he
  puts those two on **BANK-REG $FFE8 D0/D1** (below). PA1 doing double duty in MAME looks wrong.
- **S1OpMan** gives PA0 = $8000-$9FFF RAM/ROM (s1-manuals.md §5.1). Sasaji marks PA0 unused. On
  the MB-6890 there is no RAM at $8000+ without a card (svc-A), so PA0 probably only matters on the
  S1 (or with a ROM card at $8000). This stays unresolved.

### 1.3 BANK-REG $FFE8 (expansion-RAM banking, Mark 5) [sasaji:memory.htm, systemio.htm]

Write-only. Bit 7 unused.

| Bit | 0 | 1 |
|---|---|---|
| D0 | not selected | select standard RAM at $F000-$FEFF |
| D1 | not selected | select standard RAM at $FFF0-$FFFF |
| D2 (*1) | fixed | bank-switch the VRAM area $0400-$43FF |
| D3 | not selected | select expansion RAM at $0000-$7FFF |
| D4 | not selected | select expansion RAM at $8000-$FFFF |
| D5 | expansion RAM $0000-$7FFF write-only | read/write |
| D6 | expansion RAM $8000-$FFFF write-only | read/write |

- Expansion RAM has priority over ROM and standard RAM.
- (*1) If $0000-$7FFF is standard RAM, D2=1 selects expansion RAM at $0400-$43FF. If $0000-$7FFF is
  expansion RAM, D2=1 selects standard RAM at $0400-$43FF. Expansion RAM at $0400-$43FF cannot be
  used as VRAM.
- (*2) When IGMODREG is set, writes to $A000-$A7FF go to the IG RAM in preference to any RAM above.
- S1OpMan says BANK-REG works in Mode B only (s1-manuals.md).
- MAME does not implement $FFE8 (it is in MAME's TODO list).

### 1.4 $FFD7 on the original Level 3: BANK-SEL [sasaji:systemio.htm]

| Address | Bit | Meaning |
|---|---|---|
| $FFD7 (original Level 3 only) | D7 = SW | SW=1 **disables the RAM at $4000-$7FFF** |
| $FFD7 (all except the original Level 3) | D0 = SR | BAUD-SEL: 0 = 600 baud, 1 = 1200 baud |

**This settles the $FFD7 conflict.** The MB-6890 service manual calls it BANK SEL (svc-B), the
English user manual says "Open", and MAME and the Mark II/Mark 5 use it as a baud select. Both are
right, for different models. The S1 widens it to 4 bits (s1-manuals.md §5.3). A core should decode
$FFD7 per model: BANK-SEL (bit 7) on the MB-6890, BAUD-SEL (bit 0) on the Mark II and Mark 5.

---

## 2. System I/O registers ($FFC0-$FFEF) [sasaji:systemio.htm]

| Addr | Name | R/W | Bits |
|---|---|---|---|
| $FFC0-$FFC3 | PIA HD46821 | | Port A = bank switching (§1.2); port B = parallel printer (§7.2) |
| $FFC4-$FFC5 | ACIA HD46850 | | cassette **and** RS-232C, exclusive. MODE-SEL bit 5 picks which |
| $FFC6 | CRTC address | W | A4-A0 |
| $FFC7 | CRTC data | R/W | |
| $FFC8 | KBNMI | R | D7 = BK: 1 = BREAK key held |
| $FFC9 | DIPSWITCH | R | same encoding as the NEW ON value (§2.1). **Mark 5: no DIP switches. D0 and D1 read 1, D3-D7 read 0, and D2 is the MODE switch** |
| $FFCA | TIMER | R | D7 = T: 1 = the timer **IRQ (FIRQ)** has fired |
| $FFCB | LPFLG | R | D7 = LP: 1 = light pen triggered (raises IRQ) |
| $FFD0 | MODE-SEL | W | D7 W: 0 = 40, 1 = 80 columns. D6 HR: 0 = hi-res, 1 = normal. D5 C: 0 = ACIA to cassette, 1 = RS-232C. D2-D0 = background G, R, B |
| $FFD1 | TRACE | W | any write starts the trace counter. NMI fires "16? machine cycles" later |
| $FFD2 | REMOTE | W | D7 = RM: 1 = relay on (the page also says "cassette remote OFF"; the tape page says pins 1-4 close when the relay is on during LOAD/SAVE) |
| $FFD3 | MUSIC-SEL | W | D7 = MS: toggle 0/1 to drive the internal speaker |
| $FFD4 | TIME MASK | W | D7 = TM: 1 = timer IRQ (FIRQ) disabled, and the software clock stops |
| $FFD5 | LPENBL | W | D7 = LE: 1 = light pen enabled |
| $FFD6 | INTERLACE-SEL | W | D3 = IS: 1 = interlace mode; the character set switches to the interlace side |
| $FFD7 | BANK-SEL / BAUD-SEL | W | see §1.4 |
| $FFD8 | C-REG-SEL | R/W | D7 MK, D5 IG, D4 GC, D3 RV, D2 G, D1 R, D0 B (§4.3) |
| $FFE0 | KB | W | D7 BM, D6 SS, D3 UE, D2 SL, D1 HR, D0 KN (§3.2) |
| $FFE0 | KB | R | key scan data (§3) |
| $FFE8 | BANK-REG | W | §1.3 (Mark 5) |
| $FFE9 | IGMODREG | W | D0 = PM: 1 = IG character definition enabled (IG RAM writable) |
| $FFEA | IGENREG | W | D2 PG, D1 PR, D0 PB: IG RAM green/red/blue plane select |

### 2.1 NEW ON value / DIP switch encoding [sasaji:tech.htm]

The value is the sum of the offsets. The same bits are read at $FFC9.

| Bit (offset) | 1 | 0 | BASIC equivalent |
|---|---|---|---|
| 0 (1) | BASIC mode | terminal mode | TERM |
| 1 (2) | interlace | non-interlace | SCREEN ,,0 / SCREEN ,,1 |
| 2 (4) | 80 chars/line | 40 | WIDTH 80 / 40 |
| 3 (8) | normal resolution | high resolution | SCREEN 0 / SCREEN 1 |
| 4 (16) | show PF keys | hide | CONSOLE 0,24,1 / CONSOLE 0,25,0 |
| 5 (32) | half duplex (terminal) | full duplex | TERM "F8N1H" / "F8N1F" |
| 6 (64) | 7 bits/char (terminal) | 8 bits | TERM "F7" / "F8" |
| 7 (128) | convert hiragana to katakana for the printer | send as-is | |

- **MODE switch (Mark 5):** ON at power-up = NEWON 7 (80 columns, hi-res); OFF = NEWON 3 (40 columns,
  hi-res) [sasaji:keyboard.htm]. Both values include bit 1 (interlace) and bit 0 (BASIC).
- NEW ON values per screen mode: 11 = 40-col normal, 15 = 80-col normal, 3 = 40-col hi-res, 7 =
  80-col hi-res [sasaji:screen.htm].
- MAME check: MAME's DIP defaults should give $C9 = %xxxxx011 for the factory 40-column hi-res
  setting. l3-manuals-hardware.md already flags MAME's 80-column SW3 default.

---

## 3. Keyboard [sasaji:keyboard.htm]

### 3.1 Scan mechanism

- A hardware counter scans every key continuously. Bits 0-6 of the KB register show the counter.
- **The counter steps at half the horizontal sync rate** ("カウントアップ周期は水平同期周期の1/2").
- The range is $00-$7F. With KB UE=1 the range becomes **$00-$07**.
- When a key is down, the counter stops and KB bit 7 is set. If KB SS=1, an IRQ is raised too.
- Reading the KB register from the CPU restarts the counter.
- After the last key is released, the counter goes round once more. When it reaches $7F, the KB
  register outputs **$FF** (and raises an IRQ again). That $FF is how software learns that every key
  is up.
- BREAK has no scan code. Read it from KBNMI ($FFC8). With KB BM=1, pressing BREAK raises an NMI.
  **BASIC does not use the NMI.**

**Timing and conflicts:**
- At hsync/2 a full scan is 128 × 2 × 63.5 µs ≈ **16.25 ms**. This agrees with PeachROM's "scan cycle
  16.25 ms". svc-B derives 8.13 ms from "HP = 15.75 kHz". Sasaji measured real hardware, and the ROM
  book agrees with him, so **hsync/2 is the better figure**.
- MAME steps the counter once per hsync callback and only checks codes below 96 (32 × 3). The
  matrix has 128 positions (16 × 8).
- MAME's UE handling (`scancode &= 7`) **does** have a basis here: Sasaji says UE=1 limits the
  counter to $00-$07. svc-B says UE=1 stops counter IC102. These fit if IC102 is the upper counter,
  but then the range would be $00-$0F if the lower counter is 4 bits. Unresolved; the S1 circuit
  (§3.4) has a 4-bit low counter.

### 3.2 KB register $FFE0 (write)

| Bit | 0 | 1 |
|---|---|---|
| D7 BM | KBNMI disabled | BREAK → NMI enabled |
| D6 SS | KB IRQ disabled | KB IRQ enabled |
| D3 UE | keyboard counter runs | counter stopped (range $00-$07, §3.1) |
| D2 SL | CAPS LED **on** | CAPS LED off |
| D1 HR | hiragana LED off | on |
| D0 KN | katakana LED off | on |

MAME matches the bit positions. MAME names D2 `capslock_led_on`, but on the hardware 0 = LED on.

### 3.3 Scan codes (read from $FFE0, bit 7 set) [sasaji:keyboard04.png vs keyboard01.png]

Main block:

| Row | Keys → code |
|---|---|
| top | ESC 8C, 1 9A, 2 9B, 3 97, 4 91, 5 99, 6 92, 7 90, 8 93, 9 9C, 0 94, - 96, ^ 95, ¥ 9F, INS/DEL 9E |
| 2 | KANA/HIRA 8A, Q A8, W AA, E AB, R A1, T A9, Y A2, U A0, I A3, O AC, P A4, @ A6, [ A5, RETURN AF |
| 3 | CAPS 89, CTRL 86, A B8, S BA, D BB, F B1, G B9, H B2, J B0, K B3, L BC, ; B4, : B6, ] B5, GRAPH 8B |
| 4 | SHIFT 87 (both), Z C8, X CA, C CB, V C1, B C9, N C2, M C0, , C3, . CC, / C4, _ C6 |
| space | 80 |
| PF1-PF5 | D0, D1, D2, D3, D4 |

Keypad: HOME/CLS AE, ↑ 81, ? 82, / C5; ← 83, ↓ 84, → 85, * 8F; 7 9D, 8 8D, 9 8E, - BF; 4 B7, 5 BD,
6 BE, + CF; 1 C7, 2 CD, 3 CE, , C3; 0 A7, . AD, RETURN AF.

- Consistent with L3UserMan (space=128, ↑=129, ←=131, ↓=132, →=133).
- GRAPH = $8B, matching PeachROM (MAME labels $8B "Kana Shift").
- Main INS/DEL is $9E. Sasaji's keypad has no separate DEL; PeachROM says MAME swaps $9E/$98.

### 3.4 Keyboard circuit (MB-S1, from an I/O magazine schematic) [sasaji:s1kbcircuit.htm, s1kbcircuit01.png]

The S1 keyboard matrix is the same as the Mark 5's (Sasaji drove an S1 with a Mark 5 keyboard).

- **HPP** (horizontal pulse) clocks IC201 (74LS293, 4 bits). Q0-Q3 go to IC203 (**74159**, 4-to-16
  decoder, open-collector), which drives the 16 column lines.
- IC201's carry clocks IC202 (74LS293). Q0-Q2 go to IC204 (**40H151**, 8:1 multiplexer), which reads
  the 8 row lines (10 kΩ pull-ups). Its W output is **Y**, low while a pressed key is being scanned.
- So a scan code is **row (3 bits) × 16 + column (4 bits)**: the low nibble is the column.
- **KRES1** and **KRES2** reset the two counters separately. BREAK is a plain switch line to the host.
- **LED** clocks IC205 (74LS175), which latches the counter outputs as LED data (KATA red, HIRA green,
  CAPS red). The LED state is sent time-multiplexed over the counter lines.
- The host side has a custom IC, **YGM-003**. Sasaji forces scan code $71 on so YGM-003 sees a JIS
  keyboard.
- Interface: DIN 8-pin (HPP, KRES1, KRES2, LED, Y, BREAK, +5V, GND) through 74LS05/74LS14.

---

## 4. Video

### 4.1 Screen modes [sasaji:screen.htm]

| | normal 40 | normal 80 | hi-res 40 | hi-res 80 |
|---|---|---|---|---|
| NEW ON value | 11 | 15 | 3 | 7 |
| Dot resolution | 80×100 | 160×100 | 320×200 | 640×200 |
| Colour resolution | 40×25 | 80×25 | 40×200 | 80×200 |
| VRAM per screen | 1 KB | 2 KB | 8 KB | 16 KB |
| Text mixed in | 40×25 | 80×25 | 40×25 | 80×25 |
| BASIC bytes free (no cards) | 37738 | 36714 | 30570 | 22378 |

The 30570 figure (40-col hi-res) matches the S1 B-mode cold-start banner in s1-manuals.md. The 22378
figure is the 80-col hi-res mode that L3UserMan quotes.

- Pages: a mode with less VRAM than the power-on mode can use the spare VRAM as extra pages (hi-res 80
  at power-on → 16 pages of normal 40, 8 of normal 80, 2 of hi-res 40). `SCREEN ,<page>` switches
  pages. You cannot switch to a mode that needs more VRAM than the power-on mode allocated.
- **VRAM addresses** (X = column, Y = row 0-24, L = raster line in the cell 0-7):

  | Power-on mode | Range | Address of (X,Y,L) |
  |---|---|---|
  | normal 40 | $0400-$07FF | Y*40+X+$0400 |
  | normal 80 | $0400-$0BFF | Y*80+X+$0400 |
  | hi-res 40 | $0400-$23FF | $0400*L + Y*40 + X + $0400 |
  | hi-res 80 | $0400-$43FF | **$0C00***L + Y*80 + X + $0400 (as printed) |

  The hi-res 80 multiplier is printed as $0C00, but 16 KB / 8 lines = $0800, and L3UserMan and
  PeachROM give +$800 per raster line. **$0C00 is almost certainly a typo for $0800.**
- Interlace = two fields per frame (pseudo-400 lines, flickers). Non-interlace = one field.
  `SCREEN ,,0` = interlace, `SCREEN ,,1` = non-interlace. The character code charts differ between the
  two (charcode01/02.png).

### 4.2 CRTC

The site lists only the register ports ($FFC6 address, 5 bits; $FFC7 data, R/W). It gives no register
values; use PeachROM and peach-misc.md for those.

### 4.3 Colour register C-REG-SEL $FFD8 [sasaji:screen.htm, systemio.htm]

| Bit | Name | Meaning |
|---|---|---|
| D7 | MK | 0 = register writable; 1 = write-protected |
| D5 | IG | 1 = show the IG character (D0-D4 ignored) |
| D4 | GC | 0 = character, 1 = graphic |
| D3 | RV | 1 = reverse colours |
| D2-D0 | G, R, B | foreground colour |

- Write the colour register, then write VRAM: the register value is stored into the colour RAM for that
  cell.
- Reading VRAM copies that cell's colour RAM into the register **if MK=0**.
- The IG bit makes the attribute 6 bits on the Mark 5 (the memory map shows "colour RAM (6 bits)").
  The MB-6890 has 5 bits (svc-A).
- Background colour comes from MODE-SEL D2-D0.

### 4.4 IG (image generator, Mark 5) [sasaji:screen.htm]

- User-defined 8×8 characters, colour per dot.
- IG RAM at **$A000-$A7FF**: 8 bytes per character × 256 characters, **three planes** (R, G, B).
  Character P lives at $A000+8P to $A000+8P+7. **The IG RAM is write-only.**
- To write: set IGMODREG ($FFE9) bit 0 = 1, write, then clear the bit so IG characters display. While
  the bit is 1, IG characters show as white blocks. While it is 1, IG RAM writes take priority over the
  bank settings.
- IGENREG ($FFEA) picks which planes a write goes to. Several planes can be written at once (for
  monochrome characters).
- Display: write VRAM with C-REG-SEL bit 5 = 1. Setting bit 5 of work byte $0116 makes later printed
  characters use IG (COLOR resets it).
- **For compatibility, IG does not display at power-on even if those bits are set. It only becomes
  displayable after IGMODREG has been written once.** A core must model that latch.

### 4.5 Connectors [sasaji:screen.htm]

- Colour (DIN 8, TTL digital RGB): 1 +12V, 2 GND, 3 /PEDSTL (N/C on the Mark 5), 4 /HSYNC, 5 /VSYNC,
  6 R, 7 G, 8 B.
- Mono (DIN 4): 3 VIDEO, 2 GND.

---

## 5. Interrupts and timer

| Source | Line | Evidence |
|---|---|---|
| Timer (60 Hz) | **FIRQ** | $FFCA "timer IRQ(FIRQ)", $FFD4 "timer IRQ (FIRQ) disabled" [sasaji:systemio.htm]; ROM $E131 is the **FIRQ handler "(timer etc.)"** [sasaji:basicsub.htm] |
| Keyboard | IRQ | KB SS; ROM $EA87 is the **IRQ handler (keyboard scan)** [sasaji:basicsub.htm] |
| Light pen | IRQ | $FFCB [sasaji:systemio.htm] |
| BREAK | NMI (if KB BM=1) | BASIC does not use it [sasaji:keyboard.htm] |
| Trace counter | NMI | $FFD1 [sasaji:systemio.htm] |
| 5" FDC (MP-1802) INTRQ | NMI (masked by $FF04 NM) | [sasaji:systemio.htm, floppy.htm, l3s1vfdd1.htm] |
| 9-voice PSG card VIA timer | IRQ | [sasaji:l3psg9.htm] |

- **Timer IRQ vs FIRQ:** Sasaji, the service manual block diagram (svc-A) and MAME all say FIRQ, and
  the ROM's FIRQ handler handles the timer. The user manual's "Timer interrupt (IRQ)" is loose
  wording. **Verdict: FIRQ.** The 1/60 s counter is work byte $0215 (§9).
- Work-area hooks: $0100 SWI3, $0103 SWI2, $0106 SWI, $0109 NMI, $010C IRQ, $010F FIRQ (3-byte JMPs)
  [sasaji:basicwork.htm].
- Reset: if $00FD = $55, RESET gives "Abort" (warm). Any other value makes RESET a full reset.
  $00FE-$00FF is the RESET jump target, **and the first byte at the target must be $12 (NOP)**
  [sasaji:basicwork.htm].

---

## 6. Cassette [sasaji:tape.htm]

### 6.1 Signal

| Baud | "1" | "0" |
|---|---|---|
| 600 | 4 cycles of 2400 Hz | 2 cycles of 1200 Hz |
| 1200 | 2 cycles of 2400 Hz | 1 cycle of 1200 Hz |

Each byte is framed as **1 start bit (0), 8 data bits, 2 stop bits (11)**.

### 6.2 Block format

Every block is: GAP of $FF bytes, `$01 $3C`, a type byte, a length byte, data, a checksum, then 3-4 bytes
of $00 as a trailer.

| Block | Type | Length | Data | Checksum |
|---|---|---|---|---|
| File header | $00 | $14 (20) | name (8), file type (1: $00 BASIC, $01 data, $02 machine code), type 2 (2: $0000 binary, $FFFF ASCII), 9 × $00 | sum of type..data (mod 256) |
| Body | $01 | n (1-255) | data | sum of type..data |
| Footer | $FF | $00 | none | $FF |

- **GAP length:** the leading gap is the byte count in work byte **$011A** (90 = $5A at 600 baud, $C0 at
  1200 baud). In binary files, the gaps before the 2nd and later bodies and before the footer are
  **10 bytes**, from work byte **$0119**.
- **Machine-code payload** (concatenated body data): `$00`, size (2), load address (2), data (n), `$FF`,
  `$00 $00`, exec address (2).
- **BASIC binary payload:** protect byte ($FF none, $FE protected; protected programs look encrypted),
  first line number to hide (2: $0000 = hide all, $FFFF = show all), then tokenised lines (next-line
  pointer (2, $0000 = end), line number (2), tokens, $00).
- **ASCII BASIC / data:** the first byte is a newline. Lines end with CR ($0D).
- DIN 6 connector: 1 and 4 remote relay contacts, 2 GND, 3 DATA OUT, 5 DATA IN (analogue audio).

### 6.3 ACIA divide and baud: conflict check

- 8 data + 2 stop bits means CR4-CR2 = 100. At ÷16 that is CR = **$11**; at ÷64 it is $12.
- svc-B: the cassette ACIA clock is a fixed **9.6 kHz** on the MB-6890. 9.6 kHz ÷ 16 = **600 baud**,
  which matches the 1200/2400 Hz tones and Sasaji's 600-baud framing.
- PeachROM reports the ROM writing "S8N2" = $12 (÷64), which would need 38.4 kHz. **The 9.6 kHz clock
  and Sasaji's framing both point to ÷16 ($11).** Check the ROM byte; $12 is probably a misreading.
- On the RS-232C side, BASIC's 'S' option is ÷64 and 'F' is ÷16 (§7.1). That explains why both divide
  ratios appear in the ROM.
- MAME's 9600/19200 Hz for 600/1200 baud assumes ÷16, which is consistent with all of this on the
  Mark II/Mark 5.

---

## 7. Other standard I/O

### 7.1 RS-232C [sasaji:rs232c.htm]

The baud rate is chip switch **CS1** inside the case combined with the OPEN/TERM option 'S' (÷64) or
'F' (÷16):

| CS1 | 'S' (÷64) | 'F' (÷16) |
|---|---|---|
| 1 (default) | 300 | 1200 |
| 2 | 600 | 2400 |
| 3 | 1200 | 4800 |
| 4 | 2400 | (9600, not guaranteed in BASIC) |

- So the CS1=1 ACIA clock is 19.2 kHz, matching svc-B Table 6-14 (which calls the switch CS3 on the
  MB-6890).
- Connector ("F" on the board; "R" on the S1): 2 /TXD out, 3 /RXD in, 4 RTS, 5 CTS, 7 GND, 8 DCD. ±12 V.
  On the Mark 5, CTS and DCD are not wired unless jumpers J3/J4 are changed.

### 7.2 Printer [sasaji:printer.htm]

- PIA port B ($FFC2) is the data, output-only by circuit, **inverted** on the connector.
- /STRB = CB2. /ACK drives CB1 (ACK=0 → CB1=1). BUSY is N/C on the Mark 5.
- Sequence: write PB, pulse CB2 (STRB=0), the printer takes the data (ACK=1) then finishes (ACK=0), so
  CB1 → IRQB1 = 1, and the CPU polls IRQB1 before sending the next byte.

### 7.3 Expansion slot (56-pin, I/F-1..6) [sasaji:expif.htm]

The pinout matches svc-A. Behaviour notes:

- **D0-D7** connect to the internal bus only for $FF00-$FFBF, when /ROM-KIL is low, or when the CPU
  has released the bus (/HALT or /DMA). Otherwise they idle high.
- **A0-A15** are high-Z when the CPU has released the bus.
- **/ROM-KIL** (wired-OR): low lets a card drive the data bus (it overlays ROM).
- **EXROM-KIL** goes high when $A000-$FFFF is banked to RAM or expansion RAM is selected.
- **/EX-I/O** is low for $FF00-$FF7F and **/EX-I/O2** for $FF80-$FFBF.
- **VMA OUT** is high for main memory ($0000-$9FFF RAM, $A000-$FFFF ROM) and low for expansion
  memory. [sasaji:l3busctl.htm] adds that it goes low when banked to expansion RAM or RAM under ROM,
  and that **this disables the FDD card's EPROM**. A bus master waits for HALT ACK high, then pulls
  /VMA CTRL low.
- **E, Q:** buffered CPU clocks, 1 MHz.
- **/NMI, /IRQ, /FIRQ, /HALT, /VMA CTRL, /DMA:** open collector.
- **/BANK-SW** is unused on the Mark 5. **HALT ACK** = BA AND BS. **SOUND IN** is analogue, mixed
  into the speaker; it has a DC bias, so couple through a capacitor.
- 16MCK and 2MCK are the 16 MHz and 2 MHz clocks. The PSG cards use 2MCK.

### 7.4 Expansion-RAM connector (Mark 5 only, 36-pin) [sasaji:expif.htm, l3exmem.htm, l3exmem2.htm]

- For 64 Kbit DRAM, +5 V only. The original L3 and Mark II use a different pinout.
- Pins: RA0-RA7, D0-D7, /CS, OE (active **high**; one schematic wrongly shows it active low), /RAS,
  /CAS, /WE.
- Address multiplexing: on /RAS fall, RA0-6 = A1-A7 and RA7 = A15. On /CAS fall, RA0 = A0 and
  RA1-7 = A8-A14. The column address follows /RAS by about 50 ns.
- /CS is low on an expansion-RAM access. Data must be valid before /RAS rises, about 125 ns after
  /CAS.

---

## 8. Bus timing and bus takeover [sasaji:l3busctl.htm, s1busctl.htm]

### Level 3 (HD6809, internal clock)

- **/DMA:** the 6809 stops on the next cycle. It then requests the bus back every 15 cycles (including
  dead cycles), runs 2 cycles, and stops again. In effect the CPU runs 1 cycle in 16: the machine
  runs at 1/16 speed, and the keyboard still works with a lower click.
- **/HALT:** the CPU stops after the current instruction. RESET and NMI are held pending while halted;
  other interrupts are ignored.
- Both match the HD6809 datasheet charts, verified with a logic analyser.
- An external master puts the address and data out about 125 ns after E falls (midway to Q rising).
  Read data is latched on E falling.
- Writing VRAM during /DMA gave wrong colours, apparently because the CPU kept updating the colour
  register. Under /HALT it was fine.

### MB-S1 in L3 (B) mode

- The 68B09E has /HALT but **no /DMA**. The custom IC **YGM-001** emulates /DMA by stopping the
  **MPUE/MPUQ** clocks, then asserts HALT ACK.
- Holding /DMA for long hangs or reboots the S1, because the 68B09E's E/Q high/low time is limited to
  9.5 µs. Sasaji had to release /DMA for 1 cycle in 7.
- VMA OUT comes from the CPU's AVMA. /VMA CTRL also gates the internal address decoder.

### MB-S1 in S1 (A) mode

- 20-bit address bus (A16-A19).
- **MPUE** is the CPU clock reference.
- **WAIT** slows the CPU to 1 MHz.
- **MBC** (multi-bus control) disconnects the internal bus from the expansion bus; it is used by the
  Z80B and 68008 cards. BREQ OUT and BG IN request the bus during MBC.
- **/RAM0** is active when A16-A19 = 0 (in L3 mode: when banking selects expansion RAM)
  [sasaji:s1exmem2.htm].
- Under /DMA, MPUE stops, so access falls back to 1 MHz on E. The graphics I/O ($FFE2x) stops working
  without MPUE.

### MB-S1 DRAM timing [sasaji:s1exmem2.htm]

- **In L3 mode the CPU runs at 1 MHz but /CAS runs at 2 MHz: two memory accesses per CPU cycle**
  (CPU plus video, presumably).
- In L3 mode at 2 MHz, expansion RAM fails occasionally: the CPU accesses during the DRAM refresh slot,
  when /CAS is not asserted. Hitachi's own RAM card behaves the same way, so the S1 does not avoid it.
- The MPC-RA512S 512 KB card (16 × 256 Kbit DRAM) converts addresses on the card from the host's /RAS.
- The expansion RAM must answer within about 250 ns.

---

## 9. BASIC work area (Level 3 BASIC) [sasaji:basicwork.htm]

| Addr | Meaning |
|---|---|
| $0006 | type of the last variable (2 int, 3 string, 4 single, 8 double) |
| $001D-1E | start of BASIC program |
| $001F-20 / 21-22 / 23-24 | start of simple variables / arrays / free area |
| $0025-26 | start of string area (also the stack base; CLEAR) |
| $002B-2C | end of BASIC area (CLEAR) |
| $002D-2E | current line number ($FFFF when idle) |
| $0035-36 | current execution address |
| $0056-5E | FAC (USR argument and return) |
| $008B | error number; $008C-8D error line |
| $00A2 | chars per line (WIDTH) |
| $00A3-A4 / A5-A6 | display page start / end+1 |
| $00A7 | screen mode: 0 = 40 normal, 1 = 80 normal, 2 = 40 hi-res, 3 = 80 hi-res |
| $00FD | reset flag ($55 = RESET gives Abort) |
| $00FE-FF | RESET jump vector (target must start with $12) |
| $0100-0111 | SWI3/SWI2/SWI/NMI/IRQ/FIRQ hooks |
| $0115 | cursor: $00 steady, $20 hidden, $40 fast blink, $60 slow blink (default) |
| $0116 | text colour: bits 0-3 colour, bit 4 graphic, bit 5 IG |
| $0119 | cassette inter-block gap ($0A) |
| $011A | cassette leader length ($5A at 600 baud, $C0 at 1200) |
| $011B | default device ($02 CAS, $80 floppy) |
| $0121-22 | statement keyword table ($A078); $0123-24 statement jump table ($A281) |
| $0126-27 | function name table ($A1D9); $0128-29 function jump table ($A000) |
| $012A-0133 | Disk BASIC statement/function tables (0 and $A80F → Syntax Error when absent) |
| $0134-0147 | user extension statement/function tables |
| $0148-49 | default EXEC address |
| $014A-015D | USR0-USR9 addresses |
| $01C8-C9 | VRAM end+1; $01CA-CB keyboard work start (= VRAM end+1) |
| $01F7 | remote flag (copy of $FFD2) |
| $0214 | clock count flag ($00 counts $0215 down; $FF = don't, used when an RTC is fitted) |
| $0215 | 1/60 s counter; $0216-0221 hh, mm, ss, yy, mm, dd (2 BCD digits each) |
| $0238 / 0239 | cursor X / Y; $023A total lines ($19) |
| $0244 | break flag ($03 CTRL-C, $FF BREAK); $0245 abort flag ($04 CTRL-D) |
| $0247 | copy of $FFD6 (interlace) |
| $0248 | DIP switch / NEW ON value |
| $0249 | copy of $FFD0 (MODE-SEL) |
| $0251-52 | saved S for MON |
| $0278-0377 | input buffer |
| $03D8-D9 | RAM top − 1 ($9FFE for ROM BASIC) |
| VRAM_end+$00 | modifier keys: b7 CAPS off, b6 SHIFT, b5 hiragana, b4 katakana, b3 CTRL, b2 GRAPH |
| VRAM_end+$01 | last scan code (stored by the IRQ handler) |
| VRAM_end+$03 | value written to $FFE0 |
| VRAM_end+$04-$18 | key queues (10 + 10) |
| VRAM_end+$19-$3A | keyboard ring buffer (32 bytes) with write/read pointers |
| VRAM_end+$3B-$DA | PF1-PF10 strings (16 bytes each) |

The keyboard work area sits **right after VRAM**, so it moves with the power-on screen mode.

### 9.1 ROM entry points [sasaji:basicsub.htm]

| Addr | Routine |
|---|---|
| $A078-$A280 | statement keyword strings |
| $A39C / A627 / A782 / A80F / AC06 / C0E7 | errors: Out Of Memory / Undefined Line / Missing Operand / Syntax / Illegal Function Call / Overflow |
| $B104 | print string (X = start−1, terminated by $00) |
| $DCF0 | MON command (sets DP=0, saves S at $0251) |
| **$E131** | **FIRQ handler (timer etc.)** |
| $E2B1 / E2B4 | Device In Use / Device I/O Error |
| $E820 | print one character (A = ASCII, handles control codes) |
| **$EA87** | **IRQ handler (keyboard scan)** |
| $ED71 | printer out (A = data, U = $FFC2) |
| $ED94 | abort (CTRL-D) check |
| $EED7 | reset-switch handler on Mark II and later (jumps to $FDA9). **On the MB-6890 this location holds the programmer's name**, which explains peach-misc.md's "$EED7 cold start" conflict |
| $F2BE-$F2F9 | control-code jump table (addr(2) + code(1)) |
| $F7A7 / $F7A9 | beep / key click |
| $FAB0 | cold start at power-on |
| $FAB3 | cold start for NEW ON |
| $FD54-$FDA8 | "HITACHI LEVEL-3 BASIC ..." title string |
| $FDA9 | RESET handler |
| $FDDB-$FE2A | default PF key strings |
| $FE7E | FD loader: reads the boot loader into $4400 and runs it |

PeachROM gives BEEP as $F7A2; Sasaji's $F7A7 may be a different entry point or a later ROM revision.

### 9.2 Machine code and BASIC [sasaji:basicmachine.htm, l3basic.htm]

- Reserve space with `CLEAR <string size>,<end of BASIC area>`. The stack sits in BASIC's free area.
- Return to BASIC with RTS, with S and DP as they were on entry.
- `EXEC [addr]`. `DEFUSRn=addr` and `v=USRn(arg)`: A holds the argument type and X points to the value
  (normally X = $0056).
- `LOADM ["file"][,offset][,R]` loads machine code from tape or disk. R runs it at the SAVEM exec
  address.
- **MON** monitor commands: `D[addr]` dumps 64 bytes, `M[addr]` edits (a non-hex key ends it), `R`
  edits registers, `G[addr]` runs. BREAK, CTRL-C or CTRL-D returns to BASIC.
- `NEW ON <n>` changes the system mode and restarts (§2.1). `MOTOR ON/OFF` drives the relay.
- CTRL codes: M 0D CR, B 02 word left, E 05 erase to delimiter, F 06 word right, G 07 BEEP, H 08 DEL,
  I 09 TAB, K 0B home, L 0C CLS, R 12 INS, T 14 set tab, Y 19 clear tab, Z 1A erase to end of screen,
  \ 1C right, ] 1D left, ^ 1E up, _ 1F down, S 13 pause, C 03 break (CONT resumes), D 04 hard abort
  [sasaji:keyboard.htm].
- RESET returns to BASIC. If the work area is corrupted it may restart instead [sasaji:keyboard.htm].

---

## 10. Option cards

### 10.1 Floppy [sasaji:floppy.htm, systemio.htm]

**3" (MP-1805 + MP-3370/3375) and 5" single-sided (MP-1800 + MP-3540):**

- FDC **HD46503S (MC6843)** at $FF18-$FF1F:

  | Addr | Read | Write |
  |---|---|---|
  | $FF18 | DIR | DOR |
  | $FF19 | CTAR | CTAR |
  | $FF1A | CMR | ISR |
  | $FF1B | STRA | SUR |
  | $FF1C | STRB | SAR |
  | $FF1D | | GCR |
  | $FF1E | | CCR |
  | $FF1F | | LTAR |

- DRIVE-SEL at **$FF20** (W): D7 = MT (motor), D3-D0 = drive 3-0 select (one-hot). **A read writes $FF
  into this register.**
- Format: 40 tracks × 16 sectors × 128 bytes, FM, 300 rpm (125 kbit/s). The 3" disk is two manual
  sides. Disk BASIC interleave 3 (sector 1, then 12, then 7...).
- System disk: T0 S1-2 Disk BASIC loader; T1-2 Disk BASIC for 32 KB; T3-4 for 40 KB; T5-12 utilities;
  T20 file-management area (FAT + directory).
- FAT: 4 sectors per group, max group $9B. Starts at sector 1 byte 5. $00-$9B = next group; $C0-$C3 =
  last group (low nibble = sectors used + 1); $FD deleted; $FE system; $FF free. Directory: sectors 7-16,
  32 bytes per entry (name 8, unused 3, type, type2, type3 (seq/random), first group).
- Connector: 50-pin (signals listed on the page).

**5" 2D (MP-1802 + MP-3550/3560):**

- FDC **MB8866** at $FF00-$FF03 (STR/CR, TR, SCR, DR).
- DRIVE-SEL **$FF04**:
  - Read: D7 = DRQ (1 normally, 0 on DRQ); D0 = IRQ (1 normally, 0 on IRQ → **NMI**).
  - Write: D6 NM (1 = NMI disabled), D5 D/S (1 = double density), D4 S (side), D3 M (motor), D1-D0 DRV.
- Format: 40 tracks × 2 sides × 16 sectors × 256 bytes, MFM, 300 rpm (250 kbit/s), Disk BASIC
  interleave 6. Sectors 1-16 are side 0 and 17-32 side 1 in Disk BASIC numbering. **Track 0 side 0 is
  single density**; everything else is double density.
- System disk: T0 S1-2 loader; T1 S1-24 Disk BASIC; T18 S17-32 + T19 + T21 utilities; T20 file area.
  FAT: 8 sectors per group, max $97, at sector 2 byte 2. $C1-$C8 last group (low nibble = sectors used);
  $C0 = newly opened. Directory: sectors 5-23?, 32 bytes (name 8, ext 3, type, type2, first group,
  last-sector byte count (2)).
- The 5" FDC data bus is active-low (inverted). NMI after READ must not come too early, or Disk BASIC
  misses the end of the read [sasaji:l3s1vfdd1.htm].

**$FF04 conflict:** Sasaji has IRQ at **bit 0** and DRQ at bit 7, agreeing with mp1802-tech.md and Calder
(peach-misc.md). **MAME uses bit 6 for IRQ. MAME is wrong.**

### 10.2 PSG cards [sasaji:systemio.htm, l3psg6n9.htm, l3psg9.htm]

**6-voice (2 × AY-3-8910 + HD46821 PIA) at $FF30-$FF33:**

- $FF30 = port A (PSG data/register).
- $FF32 = port B: D2 SEL (0 = PSG1, 1 = PSG2), D1 BDIR, D0 BC1.
- BDIR/BC1: 11 = latch address, 10 = write, 01 = read.
- PSG clock: **1 MHz** (2MCK ÷ 2).

**9-voice (3 × AY-3-8910 + MCS6522 VIA) at $FF70-$FF7F** (standard 6522 register order):

- $FF70 ORB: D4 PSG3, D3 PSG2, D2 PSG1 (1 = selected), D1 BC1, D0 BDIR (note the swapped BDIR/BC1
  positions compared with the 6-voice card).
- $FF71 ORA = data.
- PSG clock: **2 MHz** (2MCK). Envelopes therefore run twice as fast as on the 6-voice card.
- The VIA timer raises **IRQ** periodically (the music driver uses it for tempo).
- It **overlaps the kanji ROM at $FF75/$FF76**: both cannot be fitted together.

Sasaji's reproduction adds a select register at $FF34/$FF35. That register is his own design, not
original hardware. AY-3-8913 needs 1850 ns write setup and misbehaves at 1 MHz; YM2149 has 32-step
envelopes.

### 10.3 Kanji ROM [sasaji:systemio.htm, l3s1kanji.htm]

- $FF75 (D15-D8), $FF76 (D7-D0), R/W.
- Write: D15-D4 = kanji code, D3-D0 = line number. Read: D15-D0 = 16 dots of that line (16×16 font,
  32 bytes per character). An undefined code reads with D0=1.
- 128 KB, JIS level 1.
- On the S1 a 32 KB single-kanji conversion dictionary ROM sits at **physical $D0000-$D7FFF**, directly
  readable by the CPU.

### 10.4 Other cards [sasaji:systemio.htm]

- Printer card PIA at $FF3C-$FF3F (LPT1 = port A, LPT2 = port B).
- RS-232C card ACIA at $FF40-$FF41 (COM1; COM2-4 at $FF42-$FF47 unimplemented).
- Unconfirmed:
  - RTC (RTC58321?) at $FF38-$FF3A. $FF38: R, W, REG; $FF39: RW, CS, DATAW; $FF3A: DATAR read.
  - Extension PIA card (2 × HD46821) at $FF60-$FF67.
- MB-S1:
  - Standard PSG at $FFE4/$FFE5.
  - Expansion PSG at **$FFE6 (data) / $FFE7 (address)** [sasaji:s1expsg.htm]. The internal-I/O select
    for $FFC0-$FFEF is not on the expansion connector, so a card at $FFE6 must decode it with
    /ROM-KIL tricks. TMG2 is the PSG timing signal.
  - FM card (YM2203, I/O May 1986). Sasaji's adaptation puts it at $FF1E (data) / $FF1F (address),
    clocked from the bus 2 MHz. The original used MPUE; L3 E works [sasaji:s1fmopn.htm].
- S1 expansion RAM + FM card by Sasaji: 512 KB SRAM [sasaji:s1exmemfm.htm].

---

## 11. Conflict summary

| Topic | Sasaji | Other sources | MAME | Verdict |
|---|---|---|---|---|
| $FFD7 | BANK-SEL bit 7 on the **original L3** (disables RAM $4000-$7FFF); BAUD-SEL bit 0 (600/1200) on the others | svc: BANK SEL; L3UserMan: Open; S1: 4-bit baud | baud bit 0 on all models | Model-dependent. MAME is wrong only for `bml3` (MB-6890) |
| Timer interrupt | FIRQ; ROM $E131 = FIRQ handler for the timer | svc block diagram FIRQ; L3UserMan "IRQ" | FIRQ | **FIRQ** |
| PIA bank bits | PA1/2/3 + PA6/PA7 for $A000/$C000/$E000; PA0 unused | S1OpMan: PA0 = $8000-$9FFF | also PA0 → $F000, PA1 → $FFF0 | MAME's PA0/PA1 for $F000/$FFF0 is unsupported. On the Mark 5, $F000/$FFF0 RAM is **$FFE8 D0/D1** |
| $FF04 IRQ bit | bit 0 (active low), DRQ bit 7 | MP-1802 tech manual, Calder: bit 0 | bit 6 | **Bit 0**; MAME is wrong |
| Cassette ACIA | 8N2 framing, 600 baud from 1200/2400 Hz | svc: 9.6 kHz fixed clock; PeachROM: CR=$12 | 9600/19200 Hz | ÷16 (CR=$11) fits the clocks. Recheck the ROM byte |
| Light pen | $FFCB LPFLG (R, bit 7, IRQ), $FFD5 LPENBL (W, bit 7) | svc agrees; L3UserMan calls $FFD5 "light pen register"; S1 has no $FFD5 | not implemented | Sasaji/svc |
| Keyboard scan rate | hsync/2 (16.25 ms per scan) | PeachROM 16.25 ms; svc-B derived 8.13 ms | one code per hsync, codes < 96 | hsync/2, 128 codes |
| KB UE bit | counter range $00-$07 | svc: stops IC102 | `&= 7` | MAME follows Sasaji |
| Hi-res 80 line stride | printed $0C00 | L3UserMan/PeachROM $0800 | | $0800 (typo on the site) |
| $EED7 | Mark II+ reset handler; programmer's name on the MB-6890 | Phase: "cold start" | | not an entry point on the MB-6890 |
| Colour RAM width | 6 bits (Mark 5, with IG) | 5 bits (MB-6890, svc) | | model-dependent |
| IG power-on | not displayable until IGMODREG has been written once | | | needs a latch in the core |
| $FFC9 on Mark 5 | D0=D1=1, D2 = MODE switch, others 0 | | DIP port | Mark 5 needs a fixed value |
