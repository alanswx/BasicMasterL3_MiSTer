# EmuB-6892 (Basic Master Level 3 Mark 5 emulator) — spec.txt, English translation

Source: `ref/emulators/EmuB-6892/src/docs/spec.txt` (EmuB-6892 V2.1.4, commit 0bd0afe).
Copyright (C) Common Source Code Project, Sasaji 2011-2026. Translated faithfully; every
address and support status is kept. Legend used in the original: ○ = supported,
△ = partly supported, × = not supported.

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
| Text display | ○ | |
| Graphic display | ○ | |
| Background colour | ○ | |
| Cursor colour and blink | ○ | |
| Kanji output (JIS level 1) | ○ | |
| IG | ○ | |
| Monochrome display | × | |
| **Sound** | | |
| Beep | ○ | |
| PSG 6-voice card | ○ | Joypad connects to the PSG1 side |
| PSG 9-voice card | ○ | |
| **Cassette tape** | | |
| Load / save | ○ | |
| 600 baud | ○ | |
| 1200 baud | ○ | |
| **Floppy** | | |
| 3-inch | ○ | The 5-inch single-density version can also be used in this mode |
| 5-inch 2D | ○ | |
| 8-inch 2D | untested | |
| Light pen | ○ | Emulated with the mouse |
| Joypad | ○ | (PIA A port, extension PIA B port, PSG) |
| Extended memory (64 KB) | ○ | |
| Printer | ○ | |
| — Additional printer card | ○ | |
| RS-232C | ○ | |
| — CHIPSW1,2 switching (baud rate) | ○ | |
| — Additional RS-232C card | ○ | |
| **Other** | | |
| Extension PIA card | △ partly | Joypad only (connected to port B) |
| 16-bit card | × | |
| Z80 card (Hu-Engine) | × | |

## I/O port support

| Address | Function | Status | Note |
|---|---|---|---|
| `$FF00-$FF03` | FDC (5-inch) | ○ | |
| `$FF04` | FD UNITSEL | ○ | |
| `$FF08` | HALT (8-inch) | ○ | |
| `$FF18-$FF1F` | FDC (3-inch) | ○ | |
| `$FF20` | FDC (3-inch) UNIT | ○ | |
| `$FF30-$FF33` | 6PSG | ○ | Joypad usable |
| `$FF38-$FF3A` | RTC | △ partly | |
| `$FF3C-$FF3F` | Extension PRINTER | ○ | |
| `$FF40-$FF41` | Extension RS-232C 1 | ○ | |
| `$FF42-$FF43` | Extension RS-232C 2 | × | |
| `$FF44-$FF45` | Extension RS-232C 3 | × | |
| `$FF46-$FF47` | Extension RS-232C 4 | × | |
| `$FF60-$FF67` | Extension PIA x2 | △ partly | Only `$FF62-$FF63`, joypad only |
| `$FF70-$FF7F` | 9PSG | ○ | |
| `$FF75-$FF76` | KANJI | ○ | |
| `$FFC0-$FFC1` | PIA A BANK | ○ | Joypad usable |
| `$FFC2-$FFC3` | PIA B (PRINTER) | ○ | |
| `$FFC4-$FFC5` | ACIA | ○ | |
| `$FFC6-$FFC7` | CRTC | ○ | |
| `$FFC8` | KB NMI | ○ | |
| `$FFC9` | L3 DIPSW | ○ | |
| `$FFCA` | TIMER | ○ | |
| `$FFCB` | LPFLG (light-pen flag) | ○ | |
| `$FFD0` | MODE-SEL | ○ | |
| `$FFD1` | TRACE | ○ | |
| `$FFD2` | REMOTE | ○ | |
| `$FFD3` | MUSIC-SEL | ○ | |
| `$FFD4` | TIME MASK | ○ | |
| `$FFD6` | INTERLACE-SEL | ○ | |
| `$FFD7` | BAUD-SEL | ○ | |
| `$FFD8-$FFDF` | C-REG-SEL | ○ | |
| `$FFE0-$FFE7` | KB | ○ | |
| `$FFE8` | BANK-REG | ○ | |
| `$FFE9` | IGMODE REG | ○ | |
| `$FFEA` | IGEN REG | ○ | |

Note: "PIA A BANK" at `$FFC0-$FFC1` — on the L3 the PIA A port is used for memory
banking (and joypad), cf. the S1 spec where `$FFC0-$FFC1` is called "MEMORY BANK".
`$FFD1` TRACE and `$FFCB` LPFLG are not in the MAME I/O list in TODO.md.

## Emulator features

| Feature | Status |
|---|---|
| CPU speed setting | ○ |
| Auto key input (paste) | ○ |
| Key input record & playback | ○ |
| State save & load | ○ |
| Video recording | ○ |
| Audio recording | ○ |
| After-image mode 1 | ○ |
| After-image mode 2 | ○ |
