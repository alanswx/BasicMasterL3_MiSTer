# EmuB-S1 (Hitachi MB-S1 model05 emulator) — spec.txt, English translation

Source: `ref/emulators/EmuB-S1/src/docs/spec.txt` (EmuB-S1 V0.9.4, commit 6a2eb1c).
Copyright (C) Common Source Code Project, Sasaji 2011-2026. Translated faithfully.
Legend: ○ = supported, △ = partly supported, × = not supported.

Note: the I/O addresses below are as the document writes them (16-bit form). In S1
mode the system I/O at `$FExx` is in the MMU's system-I/O page; MAME writes the same
registers as physical `$EFE00-$EFE4x` (e.g. palette `$EFE28-2F` = `$FE28-$FE2F` here).

## Limitations and known problems

- Resizing the window while paused leaves garbage on screen.
- Moving the on-screen LED indicator while paused leaves an after-image of the indicator.
- [Mac Cocoa edition] The menu is not shown in full-screen mode.

### wxWidgets edition
- Full-screen mode may not display correctly.

### Qt edition
- Full-screen mode may not display correctly.
- The frame rate may not reach 60 fps.
- The screen may stay blank when OpenGL is used.
- Joypads are not supported under Qt6.

## Device support

| Device | Status | Note |
|---|---|---|
| **Screen** | | |
| Text display | ○ | Page switching OK |
| Text-only display mode | ○ | |
| Graphics 320x200 8 colours | ○ | Page switching OK |
| Graphics 640x200 8 colours | ○ | |
| Graphics 320x200 2 screens (digital) | ○ | |
| Graphics 320x200 64 colours (analog) | ○ | But it is unknown whether the colours are correct |
| Graphics 640x400 monochrome | ○ | |
| Text and graphics overlay | ○ | |
| Background colour | ○ | |
| Border colour | ○ | |
| Cursor colour and blink | ○ | |
| Kanji output (JIS level 1, level 2) | ○ | |
| IG | ○ | |
| Superimpose card | × | Display via analog RGB is possible though |
| DIPSW4 switching (video printer) | × | |
| Monochrome display | × | |
| **Sound** | | |
| Beep | ○ | |
| PSG 3 voices | ○ | |
| Extension PSG 3 voices | ○ | |
| FM sound card | ○ | YM2203 (OPN) / YM2608 (OPNA) |
| **Cassette tape** | | |
| Load / save | ○ | |
| 600 baud | ○ | |
| 1200 baud | ○ | |
| 2400 baud | ○ | WAV output OK; WAV input has poor accuracy |
| 300 baud | ○ | |
| 4800 baud (double-speed FSK) | ○ | WAV output OK; WAV input has poor accuracy |
| DIPSW3 switching (recorder type) | × | Meaningless in an emulator |
| **Floppy** | | |
| 3-inch | ○ | |
| 5-inch 2D | ○ | |
| 5-inch 2HD | ○ | |
| 8-inch 2D | unknown | |
| Mouse | ○ | |
| Joypad | ○ | (connected to PIA A port) |
| Extended memory (64 KB - 512 KB) | ○ | |
| Kanji dictionary | ○ | |
| Printer | ○ | |
| — Additional printer card | ○ | |
| RS-232C | ○ | |
| — DIPSW1,2 switching (baud rate) | ○ | |
| — Additional RS-232C card | ○ | |
| **Other** | | |
| FUSE: transition to MMU user mode | ○ | |
| `$BFxxx` TRAP | ○ | |
| Memory access wait | ○ | |
| Communication card (MPC-CM01) | ○ | |
| OS-9 extension card | ○ | |
| Extension PIA card | × | |
| Modem card | × | |
| DMA card | × | |
| 68008 card (MPC-68008) | ○ | Only in versions built with it |
| Z80B card | ○ | Only in versions built with it |

## I/O port support

| Address | Function | Status | Note |
|---|---|---|---|
| `$FE00-$FE0F` | MAP (MMU mapping registers) | ○ | |
| `$FE10` | FUSE | ○ | |
| `$FE11` | SEGMENT | ○ | |
| `$FE18` | TRAP | ○ | |
| `$FE19` | BUS CTRL | | Only when the Z80B card or 68008 card is used |
| `$FE1A` | PRO CTRL | | Only when the 68008 card is used |
| `$FE1B` | ACC CTRL | | With the 68008 card only B/S (bit 0) is supported; AS (bit 3) is not |
| `$FE20` | BMSK COLOR | ○ | |
| `$FE21` | ACTIVE PLANE | ○ | |
| `$FE23` | DISP PAGE | ○ | |
| `$FE24` | SCRN MODE | ○ | |
| `$FE25-$FE27` | BRG REG | ○ | |
| `$FE28-$FE2F` | PALETTE | ○ | |
| `$FE40-$FE41` | PIA A | ○ | Joypad only |
| `$FE42-$FE43` | PIA B (PRINTER) | ○ | Same as `$FFC2-$FFC3` |
| `$FF00-$FF03` | FDC (5-inch) | ○ | |
| `$FF04` | FD UNITSEL | ○ | But the 8-inch reset (bit 6) is not supported |
| `$FF08` | FD (2HD) HALT | ○ | |
| `$FF0C` | FD (2HD) TYPE | fixed 0 | |
| `$FF10-$FF13` | FDC (extension) | ○ | |
| `$FF14` | FDC (extension) UNIT | ○ | |
| `$FF18-$FF1F` | FDC (3-inch) | ○ | |
| `$FF20` | FDC (3-inch) UNIT | ○ | |
| `$FF16-$FF17` | FM sound YM2608 | | When YM2608 (OPNA) is selected for the FM card |
| `$FF1E-$FF1F` | FM sound YM2203 | ○ | Also used with YM2608 (OPNA) |
| `$FF30-$FF33` | 6PSG for L3 | ○ | |
| `$FF38-$FF3A` | RTC | △ partly | |
| `$FF3C-$FF3F` | Extension PRINTER | ○ | |
| `$FF40-$FF41` | Extension RS-232C 1 | ○ | |
| `$FF42-$FF43` | Extension RS-232C 2 | × | |
| `$FF44-$FF45` | Extension RS-232C 3 | × | |
| `$FF46-$FF47` | Extension RS-232C 4 | × | |
| `$FF60-$FF67` | Extension PIA x2 | × | |
| `$FF70-$FF7F` | 9PSG for L3 | ○ | |
| `$FF72-$FF73` | KANJI JIS level 2 | ○ | |
| `$FF74` | KANJI level 2 enable | ○ | |
| `$FF75-$FF76` | KANJI JIS level 1 | ○ | |
| `$FF77` | Communication ROM ENABLE | ○ | |
| `$FF80-$FF9F` | DMA card? | × | |
| `$FFB8-$FFBB` | Modem? | × | |
| `$FFC0-$FFC1` | MEMORY BANK | ○ | Joypad not possible |
| `$FFC2-$FFC3` | PIA B (PRINTER) | ○ | |
| `$FFC4-$FFC5` | ACIA | ○ | |
| `$FFC6-$FFC7` | CRTC | ○ | |
| `$FFC8` | KB NMI | ○ | |
| `$FFC9` | L3 DIPSW | ○ | |
| `$FFCA` | TIMER | ○ | |
| `$FFCB` | LPFLG | fixed 0 | |
| `$FFCC` | Reamraito (来夢来人) cassette control | × | |
| `$FFCD` | Reamraito cassette status | | Returns `$BF` when ROM-BASIC boot is disabled |
| `$FFCE` | Reamraito detection | ○ | Disables ROM-BASIC boot |
| `$FFD0` | MODE-SEL | ○ | |
| `$FFD1` | TRACE | ○ | |
| `$FFD2` | REMOTE | ○ | |
| `$FFD3` | MUSIC-SEL | ○ | |
| `$FFD4` | TIME MASK | ○ | |
| `$FFD6` | INTERLACE-SEL | ○ | |
| `$FFD7` | BAUD-SEL | △ | Supported up to 4800 baud (double-speed FSK) |
| `$FFD8` | C-REG-SEL | ○ | |
| `$FFD9` | TRQ-SEL | × | |
| `$FFDC-$FFDF` | MOUSE | ○ | |
| `$FFE0` | KB | ○ | |
| `$FFE1` | KB TYPE | fixed 1 | Can be disabled in settings |
| `$FFE2` | TV SUPER (superimpose) | △ | Only ANA/DIGI (bit 4) |
| `$FFE4-$FFE5` | PSG | ○ | |
| `$FFE6-$FFE7` | Extension PSG | ○ | (PSG / YM2203 (OPN) / YM2608 (OPNA)) |
| `$FFE8` | BANK-REG | ○ | |
| `$FFE9` | IGMODE REG | △ | PAE (bit 7) on read differs from the real machine |
| `$FFEA` | IGEN REG | ○ | |
| `$FFEB` | SYS-MODE | ○ | |
| `$FFEE-$FFEF` | OPNA on ExPSG | | When YM2608 (OPNA) is selected on the extension PSG port |

Note: 来夢来人 ("Reamraito") is described in the EmuB-S1 manual as "an MB-S1-compatible machine"; selecting FDD 5.25" 2D plus "ROM BASIC disabled" and "IG disabled" approximates it.


## Emulator features

| Feature | Status |
|---|---|
| CPU speed setting | ○ |
| Auto key input | ○ |
| Key input record & playback | ○ |
| State save & load | ○ |
| Video recording | ○ |
| Audio recording | ○ |
| After-image mode 1 | ○ |
| After-image mode 2 | ○ |
