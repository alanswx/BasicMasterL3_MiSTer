# Peach ROM Notes: engineering extract

Source: "PEACH ROM NOTES" by Bruce Rossell and Howard Viccars, rev 2, (c) 1982 The
Software House, Canberra. Local copy:
`ref/docs/peach/Peach-ROM-Notes-rev2/Peach_ROM_Notes_By_Bruce_Rossell_And_Howard_Viccars_rev_2.pdf`
(81 PDF pages, two printed pages per PDF page, typed English).

The Hitachi Peach is the export (Australia/NZ) name of the MB-6890 Basic Master Level 3.
The book is a commentary on a disassembly of the 24 KB BASIC/monitor ROM ($A000-$FEFF):
ROM entry points, the RAM work area, the I/O registers, the keyboard code table, and the
SSSD Disk BASIC hooks. It does not reproduce a full listing. Appendix C is the BASIC
jump table and the token tables. It is the best English source on how the ROM drives the
hardware.

Citation format: [PeachROM s.X-Y / pdf N], where X-Y is the printed section page and N
is the PDF page.

Caveats:
- This is the Peach (export) ROM. The Japanese MB-6890 ROM may differ in addresses.
- The authors worked from a disassembly plus experiments, and they say parts may be
  wrong [PeachROM s.1-1 / pdf 6].
- Tags: **MAME-CONFLICT** marks a disagreement with
  `mame/src/mame/hitachi/bml3.cpp` (and `bml3.h`). **CHECK** marks something to confirm.

---

## 1. I/O register map ($FFC0-$FFEF) [PeachROM s.B-1 / pdf 65]

| Addr | Name | Function |
|---|---|---|
| FFC0 | PIA | Parallel I/O (HD46821P) |
| FFC4 | ACIA | Serial I/O (HD46850P) |
| FFC6 | CRTC | CRT controller (HD46505SP) |
| FFC8 | KBNMI | Keyboard NMI flag |
| FFC9 | DIPSW | Switch settings |
| FFCA | TIMER | Timer flag |
| FFCB | LPFLG | Light-pen flag |
| FFD0 | MODE SEL | Screen mode etc. |
| FFD1 | TRACE | Trace counter |
| FFD2 | MOTOR | Cassette motor on/off |
| FFD3 | MUSIC SEL | Music select (speaker) |
| FFD4 | TIME MASK | Timer enable |
| FFD5 | L/PEN MASK | Light-pen enable |
| FFD6 | INT'LCE SEL | Interlace enable |
| FFD7 | BANK SEL | Bank select |
| FFD8 | C-REG-SEL | Colour register |
| FFE0 | KYBD REG | Keyboard register |

### Bit definitions

- **$FFC0 PIA.** One half drives the Centronics printer port (LPT0). The other half
  switches banks on the additional memory cards [PeachROM s.B-1 / pdf 65; s.3-3 / pdf 14].
  - The PIA can raise IRQ, but the ROM's IRQ handler does not service PIA interrupts
    (LPT code is at $ED11-$ED93) [PeachROM s.3-3 / pdf 14].
  - The LPT0 work area holds a pointer to the PIA register at [01E0]+$B4
    [PeachROM s.A-10 / pdf 63].
- **$FFC4 ACIA.** Used for RS-232C (COM0) and for the cassette (CAS0), so the two
  cannot be used at once [PeachROM s.B-1 / pdf 65; s.3-2 / pdf 13].
- **$FFC8 KBNMI.** Bit 7 is set while BREAK is held. Reading the register clears it
  [PeachROM s.B-3 / pdf 66].
- **$FFC9 DIPSW.** A read returns the physical switches. The ROM copies the value to
  $0248, which is also the "NEW ON" default [PeachROM s.B-3 / pdf 66; s.6-19 / pdf 40].
- **$FFCA TIMER.** Bit 7 is set when a timer IRQ is generated. Reading clears it
  [PeachROM s.B-3 / pdf 66].
- **$FFCB LPFLG.** Bit 7 is set when a light-pen IRQ is generated. Reading clears it
  [PeachROM s.B-3 / pdf 66].
- **$FFD0 MODE SEL** [PeachROM s.B-3 / pdf 66]. The ROM keeps a copy in $0249
  [PeachROM s.A-7 / pdf 62; s.5-5 / pdf 28].
  - bit 7: 0 = 40 columns, 1 = 80 columns
  - bit 6: 0 = high resolution (graphics), 1 = low resolution (text)
  - bit 5: 0 = cassette, 1 = RS-232 (routes the ACIA)
  - bits 2-0: background colour
- **$FFD1 TRACE.** This appears to be a single-step facility. A write causes an
  **NMI 15 CPU cycles later**, which is long enough to execute an RTI so that the NMI
  lands during the next instruction. The Hitachi debuggers DEBUG5A and DEBUG70 use it
  [PeachROM s.B-4 / pdf 66].
- **$FFD2 MOTOR.** Bit 7 = 1 turns the cassette motor relay on. Copy kept at $01F7
  [PeachROM s.B-4 / pdf 66; s.6-18 / pdf 39].
- **$FFD3 MUSIC SEL.** Toggling the top bit makes sounds, so this is a 1-bit speaker
  [PeachROM s.B-4 / pdf 66].
- **$FFD4 TIME MASK.** Setting bit 7 turns **off** the timer IRQ signal
  [PeachROM s.B-4 / pdf 66].
- **$FFD5 L/PEN MASK.** Setting bit 7 enables the light-pen IRQ
  [PeachROM s.B-4 / pdf 66].
- **$FFD6 INT'LCE SEL.** Bit 3 = 1 selects interlace, 0 selects non-interlace. Copy
  kept at $0247 [PeachROM s.B-5 / pdf 67; s.A-7 / pdf 62].
- **$FFD7 BANK SEL.** Listed only by name, with no bit description
  [PeachROM s.B-1 / pdf 65].
- **$FFD8 C-REG-SEL (colour register)** [PeachROM s.B-5 / pdf 67]. BASIC keeps a copy
  in $0116.
  - bit 7: 0 = enable writes to the colour RAM, 1 = prohibit writes to the colour RAM
  - bit 4: 0 = character, 1 = graphic
  - bit 3: 0 = normal, 1 = inverse video
  - bits 2-0: colour (the same value as the BASIC COLOR statement)
  - Bits 4-0 have the same layout as the 5-bit colour RAM.
- **$FFE0 KYBD REG (keyboard)** [PeachROM s.B-5, B-6 / pdf 67].
  - **Read:** returns the current keyboard scan counter, which identifies the key that
    caused the keyboard IRQ. The ROM keeps the last value in [01CA]+1.
  - **Write:** the ROM keeps a copy in [01CA]+3.
    - bit 7: 0 = keyboard NMI disable, 1 = keyboard NMI enable
    - bit 6: 0 = keyboard IRQ disable, 1 = keyboard IRQ enable
    - bit 3: 0 = keyboard counter enabled, 1 = keyboard counter disabled
    - bit 2: 0 = SHIFT (caps) lamp on, 1 = SHIFT lamp off
    - bit 1: 0 = HIRA lamp off, 1 = HIRA lamp on
    - bit 0: 0 = KATA lamp off, 1 = KATA lamp on
  - Setting bit 3, or clearing bit 6, stops keyboard input completely, so a program
    that does this cannot be recovered from the keyboard (power cycle needed)
    [PeachROM s.4-5 / pdf 23].

### Comparison with MAME

| Point | Peach ROM Notes | MAME bml3.cpp | Verdict |
|---|---|---|---|
| $FFD7 | "BANK SEL", bank select | `baud_sel_w`: bit 0 switches the ACIA clock between 9600 and 19200 (600/1200 baud) | **MAME-CONFLICT.** Settle it from the Japanese manuals or a ROM disassembly. The Peach's baud rate comes from a hardware rotary switch (CS3), see §6. |
| $FFD1 | TRACE: write → NMI 15 cycles later | not mapped | **MAME-CONFLICT (missing).** Needed only for debugger software. Cheap to implement. |
| $FFCB | LPFLG, light-pen IRQ flag | not mapped | **MAME-CONFLICT (missing).** |
| $FFD5 | L/PEN MASK bit 7 = enable | `noprw` | Missing. Low priority. |
| $FFCA timer | "timer **IRQ**" | asserts **FIRQ** on vblank (`timer_firq`) | **MAME-CONFLICT, CHECK.** The User Manual Table S.2 also says "Timer interrupt (IRQ)". The timer is 60 Hz (see §3). |
| $FFC8 | BREAK sets bit 7; reading clears it | `kbnmi_r` returns `m_nmi` but does not clear on read | Minor. MAME also lacks the clear-on-read. |
| $FFE0 write | bit 2 is the SHIFT lamp | bit 2 is named `capslock_led` | Naming only. It is the CAPS/SHIFT-lock lamp (status byte bit 7 = CAPS LOCK). |
| $FFD0 | bit 5 selects cassette or RS-232 | ignored, apart from the mode bits | Missing in MAME. It matters for ACIA routing. |
| $FFD8 bit 7 | 0 = colour RAM writes enabled | latch updated on VRAM read only if bit 7 = 0 | Consistent (see the colour RAM notes below). |

---

## 2. Memory map and RAM work areas

### Screen RAM [PeachROM s.5-1, 5-3 / pdf 26-27; s.A-11 / pdf 64]

- Screen RAM starts at $0400. It is at most $43FF.
- Its size depends on the mode, and the system work area (keyboard buffer, file buffers
  and so on) is placed directly after it. So **BASIC's start moves with the mode**:

| Mode ($00A7) | Screen RAM | [01CA] keyboard work area | Start of BASIC, cassette only |
|---|---|---|---|
| 0 = 40-col low res | $0400-$07FF | $0800 | $0B68 |
| 1 = 80-col low res | $0400-$0BFF | $0C00 | $0F68 |
| 2 = 40-col high res | $0400-$23FF | $2400 | $2768 |
| 3 = 80-col high res | $0400-$43FF | $4400 | $4768 |

- With disk BASIC and 5 file buffers, BASIC starts at $10B6, $14B6, $2CB6 or $4CB6. With
  16 buffers it starts at $16D0, $1AD0, $32D0 or $52D0 [PeachROM s.A-11 / pdf 64].
- **Low-res text layout:** one byte per character, rows contiguous [PeachROM s.5-3 / pdf 27].
  - 40 columns: row n is at $0400 + 40·n, so row 1 is $0400-$0427 and row 25 is
    $07C0-$07E7.
  - 80 columns: row n is at $0400 + 80·n, so row 25 is $0B80-$0BCF.
  - The last 48 bytes of each area are unused (zeroed by CLS) [PeachROM s.5-2 / pdf 27].
- **High-res layout:** 8 bytes per character cell. The 8 rows of a cell are at offsets of
  **+1024 (40 columns) or +2048 (80 columns)** from the low-res address. So scanline r of
  the cell at text address A is at A + r·1024 (40 col) or A + r·2048 (80 col).
  - This is the CRTC raster-address-in-high-bits layout (RA on the high address lines).
  - In graphics mode each byte is one 8-dot row. In character mode in hi-res, the ROM
    writes the ASCII code into all 8 bytes [PeachROM s.5-4 / pdf 28].

### Colour (attribute) RAM [PeachROM s.5-1, 5-2, 5-5 / pdf 26-28]

- There is a separate **5-bit colour RAM** in parallel with $0400-$43FF. It is not
  directly addressable.
- **Write side effect:** when $FFD8 bit 7 = 0, every CPU write to $0400-$43FF also writes
  $FFD8 bits 4-0 into the colour RAM at the same address.
- **Read side effect:** every CPU read of $0400-$43FF loads the corresponding colour RAM
  value into $FFD8, so the CPU can read it back from $FFD8.
- Colour resolution is one attribute per 8 horizontal dots. In hi-res that is one
  attribute per 8-dot row of each cell, because each of the 8 rows has its own address.
- Inconsistency in the book: §5.2.2 says the colour RAM "may be enabled ... by setting
  bit 7", but §B.16 says bit 7 = 0 enables writes. MAME follows "0 = enabled". **CHECK**
  against the Hitachi manual.
- Known effect: characters randomly turn into graphics when BASIC changes $FFD8 behind a
  program's back. The book blames the read side effect and recommends that machine code
  using $0400-$43FF set or disable the colour latch [PeachROM s.5-2 / pdf 27;
  s.8-3 / pdf 51]. This confirms the read-loads-latch behaviour, which MAME implements
  in `vram_r`.

### Interrupt and other vectors in RAM [PeachROM s.A-3 / pdf 60]

The ROM's hardware vectors jump through 3-byte RAM JMP slots:

| Addr | Use |
|---|---|
| $00FD | ABORT flag: $55 = warm restart, anything else = power-on restart |
| $00FE-$00FF | Warm restart address ($EF0E) |
| $0100 | SWI3 jump |
| $0103 | SWI2 jump |
| $0106 | SWI jump |
| $0109 | NMI jump |
| $010C | IRQ jump |
| $010F | FIRQ jump |

- Reset (front-panel ABORT) is a warm start when $00FD = $55. Zeroing any of
  $00FD-$00FF forces a full cold start that re-initialises all memory
  [PeachROM s.6-19 / pdf 40]. **For the core:** reset must not clear RAM. A cold power-up
  should leave $00FD ≠ $55. Random RAM is fine, but all-$55 would not be.
- The NMI handler is just an RTI. "The system is set up to handle BREAK by an NMI ...
  for some reason it has not been implemented this way. The NMI interrupt is normally
  inhibited and there is no NMI interrupt routine, excepting a RTI instruction". The ROM
  **polls $FFC8** for BREAK instead [PeachROM s.4-6 / pdf 23].

### Other work-area locations (selected) [PeachROM s.A-1..A-10 / pdf 59-63]

| Location | Use |
|---|---|
| $001D-$001E | Start of BASIC |
| $001F-$0020 | Start of variables |
| $0021-$0022 | Start of arrays |
| $0023-$0024 | Start of free space |
| $0025-$0026 | Top of stack / lower limit of string space |
| $002B-$002C | Top of string space |
| $03D8-$03D9 | Top of available memory |
| $009E | Current file number (0 = screen/keyboard; $11 = system, used by LOADM) |
| $009F | EOF flag |
| $00A2 | WIDTH ($28 or $50) |
| $00A3-$00A6 | Start and end of the current screen page |
| $00A7 | Screen mode: 0 = 40L, 1 = 80L, 2 = 40H, 3 = 80H |
| $0115 | Cursor flag: 00 = off, $20 = static, $40 = fast blink, $60 = normal. These are the CRTC R10 bits 6-5 |
| $0116 | Copy of $FFD8 |
| $0119 / $011A | Number of $FF sync bytes written before a CAS0 block, when the motor is already on / was off |
| $011B | Default device (02 = cassette, $80 = drive 0) |
| $0148 | Go address from LOADM or EXEC |
| $014A-$015D | USR0-9 jumps |
| $015E | LOAD/LOADM jump for devices other than CAS0 or disk |
| $0161-$0178 | DOS hooks (FILES, OPEN, CLOSE, character I/O, EOF/LOF, INPUT#) |
| $0188 | Disk BASIC functions |
| $018B | MON jump [DCE6] |
| $01BE-$01C7 | TAB map |
| $01C8 | End of screen RAM |
| $01CA | Pointer to keyboard work area |
| $01CC | Pointer to PF keys |
| $01CE | Pointer to light-pen areas |
| $01D0 | Pointer to cassette buffer (255 bytes) |
| $01D2 | Pointer to device list |
| $01D4 | Pointer to open-files list |
| $01DE | Pointer to screen line map |
| $01E0 | Pointer to COM0 jump table / work area |
| $01EC-$01FC | CAS0 state (see §6) |
| $0206 | Device number |
| $0207-$020A | COM0 options, e.g. "S8N2" |
| $0215 | **60 Hz timer counter** |
| $0216-$021B | Time, one digit per byte |
| $021C-$0221 | Date, one digit per byte |
| $0238 / $0239 | Cursor column (0-79) / line (0-24) |
| $023D | PF-key display flag |
| $023F | "Something to do with CRTC": $38 = 80 col, $0E = 40 col |
| $0244 | BREAK/CTRL-C/CTRL-D flag ($FF = BREAK, 03 = CTRL-C, 04 = CTRL-D) |
| $0245 | CTRL-D flag |
| $0246 | CTRL-S flag ($13) |
| $0247 | Copy of $FFD6 |
| $0248 | DIP switches / NEW ON value |
| $0249 | Copy of $FFD0 |
| $024A-$024B | INPUT WAIT time, in multiples of 60 Hz |
| $0278-$0377 | BASIC 255-byte command line |
| $03D6 | CTRL-C/S inhibit |
| $03D7 | TERM duplex |

Notes on these locations:
- $0119/$011A: the first is used at [EE7E], the second at [EE85].
- $0215 is decremented by the timer interrupt, and BASIC's clock advances every 60
  interrupts [PeachROM s.6-30 / pdf 45].

---

## 3. Interrupts

- **IRQ sources (all on one IRQ line):**
  - keyboard (key press and key release) [PeachROM s.3-1 / pdf 13; s.4-2 / pdf 21]
  - ACIA receive for COM0 [PeachROM s.3-3 / pdf 14]
  - light pen [PeachROM s.B-3 / pdf 66]
  - timer ($FFCA) [PeachROM s.B-3 / pdf 66]
  - PIA (hardware can, but the ROM ignores it) [PeachROM s.3-3 / pdf 14]
- The COM0 IRQ routine is at $EA97-$EAF7. The ROM's IRQ handler must therefore poll the
  timer, light-pen, keyboard and ACIA status [PeachROM s.3-10 / pdf 17].
- **Timer rate:** the counter at $0215 counts 60 interrupts per second of BASIC time, so
  the timer is **60 Hz** [PeachROM s.6-30 / pdf 45; s.A-6 / pdf 61]. That matches
  MAME's vblank timer, but the book calls it IRQ while MAME uses FIRQ. **CHECK** with the
  manuals: the English User Manual Table S.2 (p.215) also says "Timer interrupt (IRQ)".
- **NMI sources:** the keyboard NMI (enabled by $FFE0 bit 7; normally disabled) and the
  $FFD1 trace counter. The ROM's NMI handler is an RTI [PeachROM s.4-6 / pdf 23;
  s.B-4 / pdf 66].
- **FIRQ:** jump slot at $010F. The book names no FIRQ source.

---

## 4. Keyboard

### Hardware behaviour

- The keyboard is scanned by hardware. When a key is pressed, the scan count is latched
  in $FFE0 and an IRQ is raised [PeachROM s.3-1 / pdf 13; s.4-1 / pdf 21].
- **Key release also raises an IRQ**, and $FFE0 reads **$FF** "at the time the last key
  was raised" [PeachROM s.4-2 / pdf 21].
- The scan counter cycles every **16.25 ms** and looks at each key once per cycle, which
  also debounces [PeachROM s.4-1 / pdf 21].
  - 16.25 ms ≈ 256 lines × 63.5 µs, or 128 keys × 2 hsyncs. That is consistent with an
    hsync-clocked 7-bit counter at H/2, as MAME has it.
- The $FFE0 count codes have **bit 7 set** when read. Key numbers run $00-$7F, so the
  value is $80 | index. Examples: Space = $80, ESC = $8C, Q = $A8, A = $B8, Z = $C8,
  PF1 = $D0 [PeachROM s.D-3..D-5 / pdf 73-74].
- Software handles up to 10 simultaneous keys. Per key it stores the $FFE0 value with
  the top bit set while held and cleared on release ([01CA]+5..+$0E), plus an auto-repeat
  counter [PeachROM s.A-8 / pdf 62].
- BREAK does not produce a $FFE0 code. It sets $FFC8 bit 7 [PeachROM s.4-1 / pdf 21].

### Keyboard work area [PeachROM s.4-2 / pdf 21]

- [01CA] is the status byte: bit 7 CAPS LOCK, 6 SHIFT, 5 K/H (green), 4 K/H (red),
  3 CTRL, 2 GRAPH.
- [01CA]+$1B..+$3A is a 32-character circular type-ahead buffer.

### ROM entry points

| Addr | Routine | Cite |
|---|---|---|
| $E804 | Character input from the current file (waits) | [PeachROM s.4-8 / pdf 24] |
| $F82C | Non-waiting key poll (INKEY$) | [PeachROM s.4-8 / pdf 24] |
| $F750 | Push a character into the key buffer | [PeachROM s.4-8 / pdf 24] |
| $F6BC | Convert an $FFE0 value to ASCII | [PeachROM s.4-9 / pdf 25] |
| $EF55 | Full-screen-editor line input | [PeachROM s.4-9 / pdf 25] |
| $F7F7 | Test for BREAK | [PeachROM s.4-7 / pdf 24] |
| $F814 | CTRL-S wait | [PeachROM s.4-7 / pdf 24] |
| $F521-$F7A1 | Keyboard IRQ routine | [PeachROM s.4-2 / pdf 21] |

### Full $FFE0 code table (Table 1) [PeachROM s.D-3..D-5 / pdf 73-74]

Format of the ASCII column: unshifted/shifted.

| Key | $FFE0 | ASCII | Key | $FFE0 | ASCII | Key | $FFE0 | ASCII |
|---|---|---|---|---|---|---|---|---|
| ESC | 8C | 1B | CAPS LOCK | 89 | - | PF1 | D0 | - |
| 1 ! | 9A | 31/21 | CTRL | 86 | - | PF2 | D1 | - |
| 2 " | 9B | 32/22 | A | B8 | 41/61 | PF3 | D2 | - |
| 3 # | 97 | 33/23 | S | BA | 53/73 | PF4 | D3 | - |
| 4 $ | 91 | 34/24 | D | BB | 44/64 | PF5 | D4 | - |
| 5 % | 99 | 35/25 | F | B1 | 46/66 | BREAK | (none, $FFC8) | - |
| 6 & | 92 | 36/26 | G | B9 | 47/67 | pad CLS/HOME | AE | 0C/0B |
| 7 ' | 90 | 37/27 | H | B2 | 48/68 | pad ↑ | 81 | 1E |
| 8 ( | 93 | 38/28 | J | B0 | 4A/6A | pad ? | 82 | 3F |
| 9 ) | 9C | 39/29 | K | B3 | 4B/6B | pad DLE/INS | 98 | 08/12 |
| 0 | 94 | 30 | L | BC | 4C/6C | pad ← | 83 | 1D/02 |
| - = | 96 | 2D/3D | ; + | B4 | 3B/2B | pad ↓ | 84 | 1F |
| ^ | 95 | 5E | : * | B6 | 3A/2A | pad → | 85 | 1C/06 |
| ¥ | 9F | 5C | ] | B5 | 5D | pad / | C5 | 2F |
| DEL | 9E | 08/12 | GRAPH | 8B | - | pad 7 | 9D | 37 |
| HIRA/KATA | 8A | - | SHIFT (both) | 87 | - | pad 8 | 8D | 38 |
| Q | A8 | 51/71 | Z | C8 | 5A/7A | pad 9 | 8E | 39 |
| W | AA | 57/77 | X | CA | 58/78 | pad * | 8F | 2A |
| E | AB | 45/65 | C | CB | 43/63 | pad 4 | B7 | 34 |
| R | A1 | 52/72 | V | C1 | 56/76 | pad 5 | BD | 35 |
| T | A9 | 54/74 | B | C9 | 42/62 | pad 6 | BE | 36 |
| Y | A2 | 59/79 | N | C2 | 4E/6E | pad - | BF | 2D |
| U | A0 | 55/75 | M | C0 | 4D/6D | pad 1 | C7 | 31 |
| I | A3 | 49/69 | , < | C3 | 2C/3C | pad 2 | CD | 32 |
| O | AC | 4F/6F | . > | CC | 2E/3E | pad 3 | CE | 33 |
| P | A4 | 50/70 | / ? | C4 | 2F/3F | pad + | CF | 2B |
| @ | A6 | 40 | _ | C6 | 5F | pad 0 | A7 | 30 |
| [ | A5 | 5B | SPACE | 80 | 20 | pad . | AD | 2E |
| RETURN (both) | AF | 0D | | | | pad RETURN | AF | 0D |

- Both RETURN keys share $AF, and both SHIFT keys share $87 [PeachROM s.D-12 / pdf 77].
- Later Australian units lack the ¥ and HIRA/KATA keys [PeachROM s.D-1 / pdf 72].
- The KATA, HIRA, GRAPH and CTRL columns, and Table 2 (every byte value $00-$FF against
  its key combination), are in [PeachROM s.D-3..D-11 / pdf 73-77].

**MAME comparison** (index = code & $7F, compared with MAME's X0/X1/X2 port bit
numbering):
- Nearly everything matches: Space 0, Up 1, ?PAD 2, CTRL 6, SHIFT 7, CAPS 9, ESC 12,
  Q 40, A 56, Z 72, PF1 80, HOME 46, RETURN 47, and so on.
- **MAME-CONFLICT (labels):**
  - index 11 ($8B) is **GRAPH**. MAME calls it "Kana Shift".
  - index 10 ($8A) is HIRA/KATA. MAME calls it "Kana Lock", which is OK.
  - index 24 ($98) is the keypad **DLE/INS** key. MAME labels it "Delete" (backspace).
  - index 30 ($9E) is the **main DEL** key. MAME labels it "Delete PAD".
  - So MAME has the two delete keys swapped.
  - index 8 ($88) is unassigned in the Peach table. MAME has it as "X2 ???".

---

## 5. Video / CRTC

### Initial CRTC values programmed by the ROM [PeachROM s.B-2 / pdf 65]

| Reg | Name | 40 col | 80 col |
|---|---|---|---|
| R0 | H total | $3F | $7F |
| R1 | H displayed | $28 | $50 |
| R2 | H sync position | $31 | $5F |
| R3 | Sync width | $85 | $8A |
| R4 | V total | $1F | $1F |
| R5 | V total adjust | $06 | $06 |
| R6 | V displayed | $19 | $19 |
| R7 | V sync position | $1C | $1C |

| Reg | Name | Interlace | Non-interlace |
|---|---|---|---|
| R8 | Interlace mode | $83 | $80 |
| R9 | Max scan line address | $0E | $07 |
| R10 | Cursor start | $2E | $27 |
| R11 | Cursor end | $0F | $07 |
| R12/R13 | Start address | $04/$00 | $04/$00 |

Derived timing (my arithmetic, not stated in the book):
- 40 columns: 64 character clocks × 1.008 MHz = 15.75 kHz.
- 80 columns: 128 × 2.016 MHz = 15.75 kHz. This agrees with MAME's C40/C80 clocks.
- Non-interlace: (31 + 1) rows × 8 lines + 6 = 262 lines, so 60 Hz.
- Interlace: R8 = $83 is interlace sync and video, and R9 = $0E gives 16 lines per row
  across both fields.

Register notes:
- R3 = $85 / $8A: the high nibble (vertical sync width, HD46505SP) is 8 lines; H sync is
  5 or 10 characters.
- R12 = $04: the start address is the word address $0400, which follows the screen page
  [PeachROM s.B-2 / pdf 65].
- R8 bits 7-6 (= 10 in $80/$83) are display/cursor skew bits on the HD46505SP.
- R10 bits 6-5 = 01 at initialisation. LOCATE writes 00, $20, $40 or $60 into these bits
  through $0115 ("00 = off, $20 = static, $40 = fast, $60 = normal")
  [PeachROM s.6-17 / pdf 39].
  - The usual 6845 coding is 00 = steady, 01 = no cursor, 10 = blink 1/16,
    11 = blink 1/32. The book's labels for 00 and 01 are the other way round. **CHECK.**
  - Either way, the ROM uses the **CRTC hardware cursor** rather than a software cursor.
  - MAME draws the cursor as reverse video at cursor_x.

Other video facts:
- The book suggests R4 = $24 and R5 = $12-$14 as a fix for monitor instability
  [PeachROM s.B-2 / pdf 65].
- WIDTH re-initialises the CRTC. JSR $E015 with B = $28 (40 columns) or $50 (80 columns)
  [PeachROM s.6-32 / pdf 46].
- SCREEN statement ($DEB2): the path that changes interlace (JMP $DEEB with
  B = 0 interlace, 1 non-interlace) and the path that leaves it unchanged ($DF09).
  There are up to 16 screen pages, which step R12/R13 [PeachROM s.6-28 / pdf 44;
  s.5-5 / pdf 28].
- The background colour is in $FFD0 bits 2-0. "Shift ]" changes it from the keyboard
  [PeachROM s.5-5 / pdf 28; s.D-12 / pdf 77].
- The character generator maps DEL ($7F) to a backslash glyph, backslash ($5C) to the
  Yen sign, and grave ($60) to a space [PeachROM s.D-12, D-13 / pdf 77-78]. Useful for
  checking a font ROM.

---

## 6. Cassette (CAS0)

- The ACIA's serial stream is converted to FSK by hardware [PeachROM s.3-2 / pdf 13].
- CAS0 uses COM0-equivalent settings **"S8N2"**, together with **hardware switch CS3 at
  position 2, which gives 600 bps** [PeachROM s.3-13 / pdf 19].
- The ACIA control value $12 corresponds to "S8N2" [PeachROM s.3-12 / pdf 18].
  - $12 decodes as CR1:0 = 10 (÷64) and CR4:2 = 100 (8 data bits, no parity, 2 stop
    bits).
  - So "S" (slow) appears to mean the ÷64 clock divider and "F" (fast) ÷16. That fits
    the User Manual's chip-switch table: positions 1-4 give 300/600/1200/2400 slow and
    1200/2400/4800 fast.
  - At position 2 the ACIA clock would be 600 × 64 = **38.4 kHz**.
  - **MAME-CONFLICT, CHECK:** MAME feeds the ACIA 9600 Hz (600 × 16) and switches to
    19200 Hz with $FFD7. If the ROM really writes ÷64, MAME's tape clock would give
    150 baud. Either the Japanese ROM writes ÷16, or MAME's tape path does not care.
    Verify against the ROM's ACIA init (CAS0 open around $E22A/$EE24) once ROMs are
    disassembled.
  - The CS3 rotary switch is a Peach/MB-6890 hardware item. Its relation to $FFD7
    (BANK SEL here, BAUD SEL in MAME) is unresolved.
- **File format** [PeachROM s.3-13, 3-14 / pdf 19]: a header block, then data blocks,
  then a trailer block.
- **Block format:**
  1. Sync: at least 6 $FF bytes needed on input. Output writes [$0119] $FF bytes if the
     motor was already on, or [$011A] if it was just turned on.
  2. $01, $3C.
  3. Block type: 0 = header, 1 = data, $FF = trailer (stored in $01EE).
  4. Length (stored in $01EF).
  5. Data (written to the buffer).
  6. Checksum: the sum mod 256 of all bytes in the header and data, i.e. from the type
     byte onward. **CHECK** whether $01 $3C are included.
  7. Desync: five $00 bytes written but not read.
- **Header block data:**
  - 8-byte name
  - file type (0 = BASIC, 1 = data, 2 = machine code)
  - file format (0 = binary, $FF = ASCII)
  - a second format byte (from $01F4, written to $01F4/$01F6 on input)
  - 9 null bytes
  - So the header length is 8 + 3 + 9 = 20 = $14, which matches the `.l3` name block
    length $14 seen in TODO.md.
- **Data block:** up to 255 bytes. **Trailer:** no data.
- **Motor:** $FFD2 bit 7, copy in $01F7 (0 = off, $FF = on by MOTOR, $80 = on for
  load/save).
  - $01F6 controls motor-off at the end of a data block. So in ASCII/data files the motor
    stops between blocks, and the leader count differs ($0119/$011A).
  - ROM: MOTOR ON = JSR $EE64, MOTOR OFF = JSR $EE67, toggle = $EE3C
    [PeachROM s.6-18 / pdf 39; s.A-5 / pdf 61].
- The CAS0 buffer is 255 bytes at [$01D0]. The input routine verifies each byte written
  to the buffer, so bad RAM there gives an I/O error [PeachROM s.3-12 / pdf 18].
- LOAD/LOADM/LOAD?: $E6D4. Programmatic LOAD is JSR $E402 (label) then JSR $E717.
  LOADM uses file number $11. The go address from LOADM/EXEC is in $0148
  [PeachROM s.6-16 / pdf 38; s.A-4 / pdf 60]. SAVE is $E579/$E4FA, SAVEM $E5AD, SKIPF
  $E2D1.
- Tape hardware notes:
  - Most cheap recorders work. A TANDY CTR-80A works.
  - With some recorders the record (MIC) lead causes interference on load, so unplug it
    when loading [PeachROM s.3-2, 3-3 / pdf 13-14; s.8-4 / pdf 52].

---

## 7. Sound

- BEEP: JSR $F7A7 gives the standard beep, $F7A9 the key click, and $F7AB a tone chosen
  by B (B = 0 beep, B = 3 click). BEEP's numeric argument has no effect
  [PeachROM s.6-2 / pdf 31].
- Hardware: toggle $FFD3 bit 7 [PeachROM s.B-4 / pdf 66]. MAME agrees (`music_sel_w`
  bit 7 → speaker level).

---

## 8. Cold/warm start and ROM entry points

- **$FAB3:** NEW ON / cold initialise, with the NEW ON value (the DIP-switch byte) in A.
- **$FAB0:** EXEC &HFAB0 or JSR $FAB0 re-initialises using the default settings from
  $0248.
- These two match Table S.3 in the User Manual: "FAB3 cold start"
  [PeachROM s.6-19 / pdf 40].
- **Warm restart address:** $EF0E, stored at $00FE. $00FD = $55 marks a valid warm
  start [PeachROM s.A-3 / pdf 60].
- **BASIC main loop:** "Ready" is printed just before $A440. JMP $A438 returns to BASIC.
  Direct commands go to $D3F7. Statement execution is $D3BA-$D45B. JMP $A450 executes
  the command line at [$BC] [PeachROM s.2-5..2-7 / pdf 10-11; s.7-7 / pdf 50].
- **Error entry:** JMP $A3A7 with B = error number [PeachROM s.9-1 / pdf 53].
- **Other ROM routines:**

| Addr | Routine |
|---|---|
| $DCE6 | MON (machine-language monitor). Uses $EF55 for input. Returns to BASIC only on BREAK or CTRL-D [PeachROM s.6-18 / pdf 39] |
| $F160 | CLS |
| $F13C | Move cursor (A = column, B = line) |
| $F2AA / $F2AE | Cursor on / off |
| $DF6A | CONSOLE |
| $E820 | Character output |
| $FC48 / $EC41 | Block move |
| $F15A | Memory fill |
| $FC8A | 3-byte pattern fill (used to initialise jump tables) |
| $F7BF / $E953 | Delay loops |

- **Tables:** command table at $A078 with addresses at $A281. Function table at $A1D9
  with addresses at $A000 [PeachROM s.2-4 / pdf 10]. Appendix C has the full jump table
  and token list [PeachROM s.C-1..C-8 / pdf 68-71].
- **Default memory setup:** a 300-byte string area at the top of available memory (below
  the DOS if present), with the stack below it [PeachROM s.2-2 / pdf 9].
- **Disk BASIC (SSSD) hooks:** RAM JMPs at $0161-$0178. The 32 KB SSSD Disk BASIC lives
  at $7xxx; the 40 KB build is at $9xxx [PeachROM s.E-1 / pdf 78].
  - Auto-boot: the 32 KB SSSD Disk BASIC runs the file with a blank name at
    initialisation by executing `COLOR 0,0` and `R.""` [PeachROM s.8-4 / pdf 52].
  - Disk BASIC is RAM-loaded, not a ROM, on this early SSSD system. The disk boot ROM
    is a separate item not covered here.

---

## 9. RS-232C (COM0)

- COM0 uses RTS, CTS and CAR (DCD).
- The internal switch block CS4 can force these signals.
- Default parameters "S8N2" ($12) are hard-coded for COM0. TERM uses the DIP switches.
- RX is interrupt driven into a 128-byte buffer.
- DB-25 pinout: TD 2, RD 3, RTS 4, CTS 5, DSR 6, GND 7, CAR 8, TC 15, RC 17, DTR 20,
  TC 24. The port is designed as DTE for modems.
- Cite: [PeachROM s.9-4..9-7 / pdf 55-56; s.3-11, 3-12 / pdf 18].

---

## Things this book does NOT cover

- Schematics and chip lists.
- The clock tree.
- $FFE8/$FFE9/$FFEA (Mark 5 only; the Peach is the original MB-6890).
- The FDC card registers, and the PIA bank-switch bit assignments for RAM-under-ROM.
  The book says only "the other half of the PIA is used for switching the additional
  memory cards".
