# Level 3 hardware facts from the English Hitachi manuals

Sources (all under `ref/docs/manuals/`):

- **[L3UserMan p.N]**: `L3-user-and-basic-manual/Hitachi MB-6890 BASIC Master Level 3 user and BASIC programming manual.pdf`, 247 pages, an English (Australian "Peach" market) introductory manual. N is the PDF page. The printed page is N-9 (PDF 10 is printed page 1). It is an OCR'd text PDF.
- **[L3AsmMan p.N]**: `L3-assembler-manual-1983/Hitachi_Basic_Master_Level_3_MB-6890_Assembler_Manual_1983.pdf`, 123 pages, image only, Delta Software Melbourne 1983, V1.1. N is the PDF page; the printed page is N-7.
- **[L3DiskBasic p.N]**: `L3-disk-basic-manual/Hitachi_MB-6890_Level-3_Disk_Basic_Manual_Difficult_Scan.pdf`, 164 pages, image only, V1.1. N is the PDF page; printed "2-1" is PDF 27, and "4-1" is PDF 145. PDFs 71-74 are scanned upside-down, and printed 2-61 to 2-67 appear at PDFs 157-163.

None of these is the service manual or the Japanese BASIC reference manual ("MB-6890 Level-3 Basic Manual"). They point to that manual for the DIP switches, cassette and NEW ON, and it is not in hand.

**Scan gap:** printed page 199 of the user manual is missing. PDF 208 is a duplicate of printed page 197. Page 199 held the slot-signal descriptions for RES, NMI, IRQ, FIRQ, HALT and part of HALT ACK (items 8-12).

---

## 1. Specification (MB-6890)  [L3UserMan p.11-13]

| Item | Value |
|---|---|
| MPU | 6809 (8-bit), "HD 6809 (compatible with the Motorola MC 6809)" [p.11] |
| ROM | 24 KB standard, expandable to 32 KB. Masked ROM: Monitor and BASIC [p.12] |
| RAM | 32 KB standard, expandable to 60 KB, plus "5-bit x 16K (colour RAM)" [p.12] |
| Display | 80x25 or 40x25, software selectable. Character cell max 8x16 dots (interlace mode) or 8x8 dots (non-interlace) [p.12] |
| Colours | 8 (blue, red, magenta, green, cyan, yellow, white, black) [p.12] |
| Graphics | 640x200 / 320x200 / 160x100 / 80x100, mixable with characters, 4 modes [p.12] |
| Screen control | auto scroll, scroll window, multipage (normal mode max 16 pages, hi-res max 2) [p.12] |
| Keyboard | ASCII, function, edit and 5 (x2 with shift) programmable soft keys, key click [p.12]. "Hardware scan method", 30-character input buffer [p.15] |
| Cassette | **600 baud FSK** [p.12] |
| Light pen | Hitachi original [p.12] |
| Video | colour: separate colour video and separate sync; B&W: composite [p.12] |
| Printer | Centronics parallel [p.13] |
| RS-232C | 300, 600, 1200, 2400, 4800 baud [p.13] |
| Expansion | 6 slots [p.13] |
| Power | AC100V 50/60 Hz; 45.0 x 12.5 x 51.5 cm, 7 kg [p.13] |

Front operation panel (under a flap): POWER, VOLUME, **MODE** (push on/off, "▲1 ▲0"), RESET [p.13-14].

## 2. Memory map

### 2.1 Standard 32 KB  [L3UserMan p.51 (Diag 3.4), p.143 (Fig 7.16)]; [L3DiskBasic p.145 (4.1)]

| Address | Use |
|---|---|
| `$0000-$03FF` | work area (1) |
| `$0400-$43FF` | display RAM (VRAM), 16 KB max, with the 5-bit colour RAM in parallel. How much is VRAM depends on the screen mode; areas (1) to (4) are below |
| above the display area | work area (2), then the user RAM |
| up to `$7FFF` | user RAM |
| `$8000-$9FFF` | "open" (empty) in the standard 32 KB machine |
| `$A000-$FEFF` | ROM: BASIC and Monitor (24 KB) |
| `$FF00-$FFFF` | I/O addresses and interrupt vectors |

"VRAM is allocated 16 Kbytes from 0400-43FF. This is the maximum capacity for display use... VRAM does not have colour information" [L3UserMan p.142]. Colour comes from the parallel 5-bit colour RAM [p.143].

Display area and user RAM head [L3DiskBasic p.146]; [L3AsmMan p.13 (Table 1-2-3)]:

| Area | Mode | Display bytes | User RAM head (Disk BASIC) | User start (cassette BASIC MA-5100) |
|---|---|---|---|---|
| (1) | 40-char normal | 1 KB | `$0F72` | `$0B68` |
| (1)-(2) | 80-char normal | 2 KB | `$1372` | `$0F68` |
| (1)-(3) | 40-char hi-res | 8 KB | `$2B72` | `$2768` |
| (1)-(4) | 80-char hi-res | 16 KB | `$4B72` | `$4768` |

BASIC's string ("character conversion") area after power-on: top of BASIC `$7FFF` and string area `$7ED1` for ROM BASIC with 32 KB; `$9FFF` / `$9ED1` with 40 KB. For Disk BASIC: `$72B7` / `$7189` (32 KB) and `$92B7` / `$9189` (40 KB) [L3AsmMan p.14 (Table 1-2-5)].

Disk BASIC adds a "DISK BASIC RAM area" at `$7000-$7FFF` (32 KB machine) [L3UserMan p.157 (Fig 8.9)]; [L3DiskBasic p.145]. More precisely it is `$72B8-$7FFF` (32 KB) or `$92B8-$9FFF` (40 KB) [L3AsmMan p.12].

### 2.2 RAM expansion  [L3UserMan p.27 (Fig 1.12)]; [L3AsmMan p.9]

- There are two RAM-expansion connectors (RAM3, RAM4) beside the 6 slots, and each takes a 16 KB board [p.27, p.152 (Fig 8.1)].
- **RAM card 1 → 40 KB:** an 8 KB block appears at `$8000-$9FFF`, and the ROM stays at `$A000-$FEFF` [p.27]. The assembler manual calls this "RAM expansion card (MP-9717)... up to 40KB" [L3AsmMan p.9].
- **Two RAM cards → 60 KB:** "extended 32k bytes" replaces the ROM area (`$8000-$FEFF`), with I/O still at the top [p.27]. This is consistent with the slot signal **ROM KIL** (below) disabling the ROM chip select.
- MAME's TODO says "RAM3 at 0x8000-0xbfff, RAM4 at 0xc000-0xefff". The manual's figure does not give per-card ranges, so this is unresolved.

## 3. I/O map  ($FF00-$FFEF)  [L3UserMan p.224 (Table S.2, printed 215)]

The table, transcribed in full:

| Address | Hardware (manual wording) |
|---|---|
| `FF00-FFBF` | Open |
| `FFC0-FFC3` | Parallel interface (PIA) |
| `FFC4-FFC5` | Serial interface (ACIA) |
| `FFC6-FFC7` | CRT controller |
| `FFC8` | Keyboard interrupt (NMI) |
| `FFC9` | Internal dip switch |
| `FFCA` | Timer interrupt (**IRQ**) |
| `FFCC-FFCF` | Open |
| `FFD0` | Mode select |
| `FFD2` | Remote control |
| `FFD3` | Speaker control |
| `FFD4` | Timer mask |
| `FFD5` | **Light pen register** |
| `FFD6` | Interlace control |
| `FFD7` | **Open** |
| `FFD8` | Colour register |
| `FFD9-FFDF` | Open |
| `FFE0` | Keyboard |
| `FFE1-FFEF` | Open |

**Conflicts and notes against MAME `bml3.cpp`:**

- **CONFLICT: `$FFCA` is listed as "Timer interrupt (IRQ)".** MAME drives the timer as **FIRQ** (`timer_firq` asserts `M6809_FIRQ_LINE` once per vblank; `$FFCA` read returns the status in bit 7 and clears FIRQ). The English manual is a translation and may be loose, and MAME's FIRQ choice presumably comes from the service manual or EmuB. This needs the service manual or a ROM check: look at what the FIRQ and IRQ vectors at `$FFF6`/`$FFF8` point to, and which handler reads `$FFCA`.
- **CONFLICT (probably a documentation gap): `$FFD7` is listed as "Open".** MAME implements `$FFD7` as BAUD SEL (bit 0: 600/1200 baud ACIA clock) and comments that it is "Misspelled as BANK SEL in the English documentation". This manual says Open. It is a 1980-era table and may simply omit it, but treat `$FFD7` as unconfirmed.
- **`$FFD5` light pen register.** MAME maps `$FFD5` as `noprw` ("L/P ENBL - Light pen operation enable") and has `$FFCB` LPFLG commented out. That is compatible with this manual, just unimplemented. The light-pen coordinates themselves are latched in the CRTC (HD46505SP R16/R17) [L3UserMan p.183].
- `$FFC8` "Keyboard interrupt (NMI)" matches MAME's KBNMI (the BREAK key; the bit 7 status is read at `$FFC8`). The ordinary key interrupt (IRQ) is controlled through `$FFE0` (see §7).
- `$FFE8-$FFEA` (the Mark 5 bank and IG registers) are not listed. This is an MB-6890 manual, so that is expected.

## 4. Video

### 4.1 Modes  [L3UserMan p.20-23, p.126-128]; [L3DiskBasic p.51]

| | Normal 40 | Normal 80 | Hi-res 40 | Hi-res 80 |
|---|---|---|---|---|
| Graphic dots | 80x100 | 160x100 | 320x200 | 640x200 |
| Colour resolution (Table 1.9, p.23) | 40x25 | 80x25 | 40x200 | 80x200 |
| Colour resolution (Table 7.4, p.131) | 40x25 | 80x25 | 40x100 (?) | 80x100 (?) |
| VRAM per screen | 1 KB | 2 KB | 8 KB | 16 KB |
| Text usable at the same time | 40x25 (Disk BASIC manual: "40 chars x 23 lines") | 80x25 | 40x25 | 80x25 |
| User area (32 KB RAM) | 30 K | 29 K | 23 K | 15 K |

- Table 7.4 [p.131] contradicts Table 1.9 [p.23] and the Disk BASIC manual [L3DiskBasic p.51], both of which give **40x200 / 80x200** colour resolution in hi-res. The hardware evidence (one colour byte per VRAM byte) supports x200; p.131 looks like a typo.
- `WIDTH 40|80` sets the columns. `SCREEN l,m,n`: `l` = 0 normal / 1 hi-res (this clears the screen); `m` = page; **`n` = 0 interlace / 1 non-interlace** (no clear) [L3UserMan p.127].
- Character cell: 8x8 in non-interlace and 8x16 in interlace. "The L-3 character generator is twice as big as a normal system" [L3UserMan p.20-21]. In interlace the vertical resolution is still 25 rows of 8 "dots", so the graphics resolution does not change [p.22].
- **The character set differs between interlace and non-interlace** [L3DiskBasic p.147-148 (4.2.1/4.2.2)]. In interlace mode, codes `$80-$9F` are the kanji-like symbols (年月日市区町 etc.) and hiragana, and `$E0-$FF` are hiragana. In non-interlace mode, codes `$80-$9F` are block/line graphic symbols and `$E0-$FF` are graphic symbols (spade/heart/円/年/月/日/時/分/秒 etc.). Codes `$00-$1F` are control codes only in both modes. Hiragana display was the reason for interlace [L3DiskBasic p.52].
  - Manual inconsistency: [L3UserMan p.18] says "Level-3 displays graphic characters in the non-interlace mode", but [p.21] says "graphic characters are displayed only in interlace mode". The character tables [L3DiskBasic p.147-148] agree with p.18 (graphics in non-interlace).
- **The VRAM size is fixed at power-on** by the DIP switch and the front MODE switch, or later by `NEW ON`. Asking for a mode that needs more VRAM gives "Illegal Function Call" [L3UserMan p.24, p.127-128]. Power-on with MODE=0 gives 8 KB of VRAM (as WIDTH 40, SCREEN 1); MODE=1 gives 16 KB [p.128].

### 4.2 Screen addressing  [L3UserMan p.147-149 (Figs 7.21-7.25)]

- Normal 40: `$400` + row*40 + col, ending at `$7E7` (row 24 starts `$7C0`).
- Normal 80: `$400` + row*80 + col, ending at `$BCF` (row 24 starts `$B80`).
- **Hi-res:** 200 lines in 25 blocks of 8 lines. The head of block *b* is the same address as the head of text row *b* in normal mode. Raster line *r* (0-7) within a block is at **+r*`$400`** (320-wide) or **+r*`$800`** (640-wide). Examples: 320x200 line 1 is `$800`, line 2 `$C00` ... line 7 `$2000`, and block 1 starts at `$428`. 640x200 line 1 is `$C00` ... line 7 `$3C00`, block 1 starts at `$450`. 320 mode ends at `$23E7` ("unused area" up to `$23FF`), 640 mode at `$43CF`. "Just ... add 04(16) [or 08(16)] to the upper byte" [p.148]. This matches MAME's `ma + x + ra*x_count/40*0x400`.
- Characters in hi-res mode: with the colour register bit 4 = 0 (character), write the character code into all 8 raster bytes of a cell (`$400+I*$800`, I=0..7, in 640 mode) and the character appears. "Horizontally you can write different character codes in eight lines but vertically this is not possible" [p.150]. So in hi-res character mode each raster line *r* shows row *r* of the glyph whose code is stored at that raster's byte.
- Normal-mode graphics (attribute bit 4 = 1): each byte is a 2x4 block of 8 sub-dots [p.22 (Fig 1.8), p.129 (Fig 7.2)]. **Fig 1.8 shows the left column numbered 0,1,2,3 (top to bottom) and the right column 4,5,6,7.**
  - **CONFLICT with MAME:** `crtc_update_row` comments "4 0 / 5 1 / 6 2 / 7 3" and computes `(rawbits >> ra/2 & 0x11) * 0xf`, which puts **bit 4 in the left half and bit 0 in the right half**. The manual figure has 0-3 on the left. Check with a ROM PSET trace or EmuB.

### 4.3 Colour / attribute  [L3UserMan p.143-145]

5-bit colour RAM, one entry per VRAM byte (Table 7.17):

| bit 4 | bit 3 | bit 2 | bit 1 | bit 0 |
|---|---|---|---|---|
| 0 = character, 1 = graphic | 0 = normal, 1 = inverse | G | R | B |

Colour codes (Table 7.18): 0 black, 1 blue, 2 red, 3 magenta, 4 green, 5 cyan, 6 yellow, 7 white.

**Colour register `$FFD8`** (Fig 7.19): `1 x x C/G N/I G R B`. "The information to write in &HFFD8 is 5 bits but to write this, we make bit 7 1." The procedure is "You must always set the colour information into the register before writing the data in VRAM": writing a VRAM byte copies the register into colour RAM. Examples: `POKE &HFFD8,&H84 : POKE &H400,&H41` gives a green "A" at top-left; `&H89` is character/inverse/blue and `&H92` is graphic/normal/red [p.144-146].

- This agrees with MAME (`vram_w` copies `m_attr_latch` to aram, and a VRAM read loads the latch unless bit 7 = 1). MAME calls bit 7 "MK: 1 = prohibit write" (that is, it stops VRAM *reads* from overwriting the latch). The manual's "set bit 7 to 1" convention is consistent with that.
- The sample "screen reverse" machine program [L3UserMan p.240] does `LDB $FFD8 / PSHS B / ... STA $FFD8` and so on, saving and restoring the register.

**Background colour:** MAME puts it in `$FFD0` bits 2-0. The manual only says `COLOR` exists [p.159]; there is no register detail.

## 5. Interrupts (as far as these manuals go)

- BREAK key: "This key also uses 'interrupt' so that it is possible to return to input state at any time" [L3UserMan p.15]. The `$FFC8` "Keyboard interrupt (NMI)" [p.224].
- Timer: `$FFCA` "Timer interrupt (IRQ)" and `$FFD4` timer mask [p.224]. `POKE &HFFD4,255` stops the timer, which stops TIME$ (it no longer advances) and makes BEEP a clean tone. `POKE &HFFD4,0` restores it. "The indistinct sound is caused by intrusion from the timer" [p.169]. So the timer ISR runs often enough to disturb software tone loops, and it drives the TIME$ clock.
- Work-area note (handwritten in the scan): `$216` "Acc. Timer (1/60 second)", so the timer is **60 Hz**, consistent with a vblank-rate timer; `$21C-$221` is the date [p.225].
- Light pen interrupt (`ON PEN GOSUB`) and RS-232C receive interrupt (`ON COM(0) GOSUB`) exist in BASIC [p.178-182, p.221-222]. Their sources are not given.
- Slot bus carries NMI, IRQ, FIRQ, HALT and DMA (all inputs to the CPU) [p.205].

## 6. Sound  [L3UserMan p.169-177]

- `$FFD3` "speaker control": "only bit 7 is connected to the speaker. There is a flip flop and an AMP between &HFFD3 and the speaker" (Fig 10.1: bit 7 → flip-flop → amp → speaker). The waveform figure shows output high after writing 255 and low after writing 0. That is a level latch, matching MAME `level_w(BIT(data,7))`.
- The example tone routine writes `#$00` and `#$FF` to `$FFD3` with DECB delay loops (Table 10.5, at `$6002`) [p.176].
- The key click and the error beep come out of the same speaker [p.169]. Slot pin 46 **SOUND IN** "is connected to the speaker inside" [p.209], so option sound cards mix in through the slot.
- VOLUME knob on the front panel [p.13].

## 7. Keyboard  [L3UserMan p.14-20, p.167-168]

- Layout (Diag 1.4): main block with BREAK (covered), PF1-PF5, ESC, the 1-0 `- ^ ¥` INS/DEL row, Q-P `@ [` RETURN, CAPS LOCK/CTRL/A-L `; : ]` GRAPH, SHIFT Z-M `, . / _` SHIFT, space. Numeric pad: HOME/CLS ↑ ? INS/DEL / ← ↓ → / 7 8 9 * / 4 5 6 - / 1 2 3 + / 0 . RETURN [p.14]. The JIS version adds a KATA/HIRA key with a red/green lamp [L3DiskBasic p.28-29].
- "Hardware scan method", 30-char buffer, auto-repeat after about 1 s (no repeat on function keys) [p.15, p.20].
- **Direct keyboard read (a useful test vector):** `POKE &HFFE0,&H0C` disables the key interrupt. `PEEK(&HFFE0)` then returns live values, but only the cursor keys and space can be read: **space = 128, ↑ = 129, ← = 131, ↓ = 132, → = 133**, and it returns other values when no key is pressed. BREAK will not restore key input; you must RESET or `POKE &HFFE0,&HF0` [p.167-168].
  - This agrees with MAME `kb_sel_w`: `$0C` sets bit 3 = "counter operation disabled" (the scan is limited to codes 0-7), bit 6 = 0 (IRQ off) and bit 7 = 0 (NMI off). The read value is `$80 | code`. `$F0` re-enables the IRQ (bit 6) and NMI (bit 7). So scan codes 0-7 include space(0), ↑(1), ←(3), ↓(4) and →(5).
- CTRL codes (Table 1.5): CTRL-M Return, -G bell, -K home, -^ up, -- down, -¥ right, -] left, -F word right, -B word left, -R insert, -H delete, -E delete to end of line, -Z delete to end of screen, -L clear/home, -T set tab, -Y clear tab, -I next tab, -S pause output, -C break (CONT restarts), **-D "soft (hot) start"** [p.16-17].

## 8. Cassette

- "600 baud FSK method" [L3UserMan p.12]. No levels or frequencies are given here.
- BASIC messages: `Searching` then `Found: <name>` [L3AsmMan p.73, p.75].
- `$FFD2` "Remote control" is the motor relay [L3UserMan p.224]. Work area `$01F4` holds the "Remote state" [p.225]. The BASIC `MOTOR` statement is "Motor control of cassette" [L3DiskBasic p.73].
- Cassette buffer pointer at `$01D0-$01D1` [p.225].

## 9. RS-232C  [L3UserMan p.210-218]

- Async, 8 data bits plus start and stop bits. The stop-bit count is software selectable (1 or 2) [p.210-211].
- "The transfer speed is decided by the clock to the ACIA" [p.211]. Chip switch **CS3** (to the left of the memory-expansion connector) sets the base rate, and software selects Slow or Fast (Table 15.2):

| CS3 | Slow | Fast |
|---|---|---|
| 1 | 300 | 1200 |
| 2 | 600 | 2400 |
| 3 | 1200 | 4800 |
| 4 | 2400 | — |

  Fast is 4x slow, which suggests the ACIA counter-divide select (/64 vs /16). That inference is mine, not the manual's.
- Chip switch **CS4** sets the line logic: TXD 8 = positive / 7 = negative (normally 7); RTS 5 = positive / 6 = negative (normally negative); DCD 1 = earth / 2 = active; CTS 4 = active / 3 = earth [p.216-217].
- DB-25 connector: TXD 2, RXD 3, RTS 4, CTS 5, GND 7, DCD 8 [p.217 (Table 15.6)].
- `TERM "F8N1F"` gives clock S/F, bits 7/8, parity N/E/O, stop 1/2, duplex F/H. Factory defaults (Table 15.5): clock S, bits from **DIP 7** (normally 8), parity N, stop 2, duplex from **DIP 6** (normally F) [p.213-215].
- Since cassette and RS-232C share one ACIA (`$FFC4-5`), MAME's "C bit" of `$FFD0` (ACIA mode: 0 = cassette, 1 = RS-232C) would select between the cassette clock and the CS3 clock. The manual does not describe `$FFD0`.

## 10. DIP switches (internal, `$FFC9`)

What these manuals say:

- **DIP 1:** closed (0) means "terminal mode as soon as the power comes on" [L3UserMan p.218].
- **DIP 3:** 80/40 columns. **DIP 4:** Normal / High resolution. Together they set the maximum VRAM and so the pages available [L3DiskBasic p.53]:

| # | DIP4 (Normal/Hi-res) | DIP3 (80/40) | N40 | N80 | H40 | H80 |
|---|---|---|---|---|---|---|
| 1 | 1 | 1 | 2 pages | 1 | x | x |
| 2 | 1 | 0 | 1 | x | x | x |
| 3 | 0 | 1 | 16 | 8 | 2 pages | 1 |
| 4 | 0 | 0 | 8 | 4 | 1 | x |

  "The standard state when shipped out is No. 4" [L3DiskBasic p.53] (hi-res, 40 columns, 8 KB VRAM). The modes are "determined by No.3 and No.4 DIP switches (or by the NEW ON command)" [L3DiskBasic p.51].
- **DIP 6:** terminal duplex default. **DIP 7:** terminal bit length default [L3UserMan p.215].
- The front **MODE switch** is "the 40-character/80-character change switch". "The dip switch has been set to high resolution mode when delivered" [L3UserMan p.50]. MODE 0 means 8 KB VRAM (40-col hi-res max) and MODE 1 means 16 KB (80-col hi-res) [p.128]. MAME's note that the MODE button XORs DIP 3 fits this.
- **Possible conflict with MAME:** MAME's DIPSW port defaults SW3 to `0x04` (80 chars/line) and SW4 to High. The shipped state per the manual is DIP3 = 0 (40) with MODE switch 0, which gives the 40-col hi-res power-on screen ("22378 Bytes Free"). The MAME defaults will power up at 80 columns unless MODE is modelled. Check which polarity DIP3 reads at `$FFC9`.
- DIP 2, 5 and 8 are not described in these manuals. MAME has 2 = interlace, 5 = show PF keys and 8 = hiragana→katakana.

## 11. Light pen  [L3UserMan p.178-183]

5-pin DIN on the back panel (the back panel also has the colour monitor, B&W monitor and cassette DINs, the printer connector and DB-25 RS-232C) [p.183, p.212]:

| Pin | Signal | Meaning |
|---|---|---|
| 1 | /LP OUT | photodiode output voltage |
| 2 | /LP SW | low when the pen is pressed |
| 3 | +5V | supply |
| 4 | LP VCMP | reference voltage setting sensitivity |
| 5 | GND | ground |

"The co-ordinates where the light pen is pressed are set in the CRT controller LSI" (HD46505SP) [p.183]. The resolution is one character cell (80x25 or 40x25) in both normal and hi-res modes [p.25].

## 12. I/O slot (6 slots, 56 pins)  [L3UserMan p.204-209]

Pin arrangement (Fig 14.1 / Table 14.2). Directions are relative to the CPU: → is an output from the L3, ← an input, ↔ bidirectional.

| Pin | Signal | Dir | Pin | Signal | Dir |
|---|---|---|---|---|---|
| 1 | +5V | → | 2 | GND | ↔ |
| 3 | D0 | ↔ | 4 | D1 | ↔ |
| 5 | D2 | ↔ | 6 | D3 | ↔ |
| 7 | D4 | ↔ | 8 | D5 | ↔ |
| 9 | D6 | ↔ | 10 | D7 | ↔ |
| 11 | A0 | ↔ | 12 | A1 | ↔ |
| 13 | A2 | ↔ | 14 | A3 | ↔ |
| 15 | A4 | ↔ | 16 | A5 | ↔ |
| 17 | A6 | ↔ | 18 | A7 | ↔ |
| 19 | A8 | ↔ | 20 | A9 | ↔ |
| 21 | A10 | ↔ | 22 | A11 | ↔ |
| 23 | A12 | ↔ | 24 | A13 | ↔ |
| 25 | A14 | ↔ | 26 | A15 | ↔ |
| 27 | BA | → | 28 | BS | → |
| 29 | /ROM KIL | ← | 30 | EXROM KIL | → |
| 31 | R/W IN | ← | 32 | /EX-I/O | → |
| 33 | R/W OUT | → | 34 | VMA OUT | → |
| 35 | E | → | 36 | Q | → |
| 37 | /RES | → | 38 | /NMI | ← |
| 39 | /IRQ | ← | 40 | /FIRQ | ← |
| 41 | /HALT | ← | 42 | /VMA CTRL | ← |
| 43 | /DMA | ← | 44 | /BANK SW | → |
| 45 | HALT ACK | → | 46 | SOUND IN | ← |
| 47 | 16MCK | → | 48 | GND | |
| 49 | 2MCK | → | 50 | GND | |
| 51 | -5V | → | 52 | /EX-I/O2 | → |
| 53 | -12V | → | 54 | +12V | → |
| 55 | GND | | 56 | +5V | → |

Signal notes [p.205-209]:

- Data and address buses are bidirectional, so a card can master the bus. "R/W IN is used to access the memory in Level-3 from the interface card. In this case, set the MPU halt state" [p.207].
- **/ROM KIL** "is connected to the ROM chip select in Level-3. When this signal is low, the ROM does not function and the ROM memory is released." **EXROM KIL** disables the ROM on an expansion card [p.206-207].
- **VMA OUT** "is the output of AND between BA and BS". **/VMA CTRL** low forces VMA OUT high [p.207]. (As literally translated this looks garbled. Treat it as "a valid-memory-address qualifier".)
- **E, Q** are the 6809 clocks: the MPU reads data on E falling, and the address is valid at Q rising [p.207].
- **16MCK = 16.128 MHz, 2MCK = 2.016 MHz** [p.209]. Both are consistent with MAME's 32.256 MHz master (/2 and /16): 2.016 MHz is MAME's `CPU_EXT_CLOCK/2` (the 80-char clock).
- **/BANK SW, /EX-I/O, /EX-I/O2:** "We do not know the purpose of these signals" [p.209]. /EX-I/O is presumably the `$FF00-$FFBF` expansion I/O select.
- The power supply is a switching regulator with +5, -5, +12 and -12 V. There is not enough spare capacity for external use [p.205-206].

## 13. Floppy (MB-6890 era)  [L3UserMan p.152-156]; [L3DiskBasic p.17-18, p.53-55]

- Hardware: MP-3540 mini floppy unit, **MP-1800** floppy interface card (best in I/F-1, the slot nearest the edge), Disk BASIC master MA-5300 (32 KB) or MA-5301 (40 KB) [L3UserMan p.152]. The assembler manual also says I/F cards MP-1800 and MP-1801 [L3AsmMan p.9].
- MP-3540 format: single-sided single density, **40 tracks (0-39) x 16 sectors (1-16) x 128 bytes**. A group is 4 sectors, groups 0-155 [L3DiskBasic p.54].
- System disk layout: tracks 0-2 hold the DISK BASIC code, 3-19 user area, **track 20 the directory** (FAT in sectors 1-2), 21-39 user area. FAT values: `0-$9B` next group, `$C0-$C3` last group (low bits = sectors used - 1), `$FE` system, `$FF` free. A directory entry is 32 bytes: name 0-7, attributes 8-13, first group 14, spare 15-31. Maximum 40 files [L3DiskBasic p.54-55, p.150].
- The boot is automatic at power-on when the MP-1800 is fitted and a system disk is in drive 0 (see the BASIC notes).

## 14. Missing from these manuals (needs the service manual or Japanese manuals)

`$FFD0` bit layout, `$FFD6` bits, `$FFD7`, `$FFE0` read/write bit layout beyond the `$0C`/`$F0` example, the keyboard matrix and scan codes, the cassette tone frequencies and levels, the IRQ/FIRQ assignment, CRTC register values, the ROM/RAM bank switching (`$FFE8`), the character ROM, and the Mark II/Mark 5 differences.
