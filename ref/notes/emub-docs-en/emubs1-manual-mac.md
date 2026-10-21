# EmuB-S1 manual (readme_mac_cocoa.txt) — English translation

Source: `ref/emulators/EmuB-S1/src/docs/readme_mac_cocoa.txt`, "HITACHI MB-S1 model05
Emulator, SDL2 + Mac Cocoa edition, Version 0.9.4, 2026/07/12". Program name `mbs1`.

The S1 manual is the EmuB-6892 manual with S1-specific changes. Everything not listed
here is identical (with `bml3mk5` -> `mbs1`) to
[emub6892-manual-mac.md](emub6892-manual-mac.md): installation, tape menu, FDD menu,
screen menu, sound, devices (LPT/COM), key-record files, ffmpeg, command line
(`mbs1 [-i ini] [-t tape] [-d disk] [-s state] [-a autokey] [-k recordkey] [files...]`),
drag and drop, disk image formats. This file translates every section that differs, in
full. Shortcut keys use the **left** option key on the S1 (the 6892 uses either option).

## Introduction

"This software is an emulator that **behaves like** the Hitachi MB-S1." (The author's
wording: it is modelled on the S1 rather than claimed to be exact.) Title: "MB-S1
model05".

## Main features

- CPU: speed x0.5 to x16
- RAM: standard 64 KB (16 KB of it used as VRAM) + VRAM 32 KB + TEXT 4 KB + extension
  0-512 KB
- Display: 320x200 8/16 colours, 640x200 8/16 colours, 320x200 64 colours, 640x400
  monochrome, IG
- Sound: MUSIC_SEL, 3-voice PSG + 3-voice extension PSG; FM sound card (YM2203 / OPN
  equivalent; the design published in *I/O*, June 1985); for B mode: 6-voice PSG
  (modelled on the MP-9710) and 9-voice PSG (*I/O*, August 1983)
- Cassette tape I/O, printer, RS-232C
- Mouse input
- Kanji ROM: modelled on the MPC-KA01S and MPC-KA02S
- FDD, one of:
  - 1S 3-inch compact floppy (MB-S1/10,20 + MP-1805 + 2x MP-3375)
  - 2D 5.25-inch mini floppy (MB-S1/10,20 + MP-1870 + 2x MP-3560)
  - 2HD 5.25-inch mini floppy — drives 0 and 1 are 2HD, drives 2 and 3 are 2D only
    (MB-S1/30,40 + MP-1870 + MP-3560)
- Communication card MPC-CM01
- Z80B card (modelled on the one by Chubu Honda Tsusho, 中部本多通商)
- 68008 card (modelled on the MPC-68008)
- See spec.txt for details.

## What you need (ROM images)

1. **S1 ROM BASIC** (required to use BASIC in A mode)
   - `S1BAS1.ROM`: `$E0000-$E7FFF` (32 KB)
   - `S1BAS2.ROM`: `$E8000-$EFFFF` (32 KB)
     - or instead of S1BAS2: `S1ROM2.ROM`: `$E8000-$EFDFF` + `S1ROMI.ROM`: `$EFFF0-$EFFFF`
2. **L3 ROM BASIC** (required to use BASIC in B mode)
   - `L3BAS.ROM`: `$FA000-$FFFFF` (24 KB)
   - or `ROM1.ROM`: `$FA000-$FFEFF` + `ROM2.ROM`: `$FFFF0-$FFFFF`
3. **Character font image** (required)
   - `FONT.ROM`: `$BD000-$BDFFF` (4 KB), compatible with the L3
   - or `S1FONT.ROM`: IC27 (8 KB), the character-font ROM used for the screen display.
     The `S1FONT.ROM` in the `tool` folder was made by the author and differs from the
     real one.
4. **Disk boot ROM images** (to use DISK BASIC in B mode)
   - `MP1802.ROM`: ROM on the 5-inch floppy I/F board MP-1802/A. Required to boot from a
     5-inch FD when using an L3 ROM BASIC dumped from an L3.
   - `MP1805.ROM`: ROM on the 3-inch floppy I/F board MP-1805. Required to boot from a
     3-inch FD when using an L3 ROM BASIC dumped from an S1.
5. **Kanji ROMs** (required for kanji BASIC and the Japanese word processor)
   - `KANJI.ROM`: JIS level 1 (128 KB)
   - `KANJI2.ROM`: JIS level 2 (128 KB)
   - The tool folder has software to make pseudo kanji ROM images.
   - `S1DIC.ROM`: `$D0000-$D8000` (32 KB), kanji dictionary ROM. The tool folder has
     software to make a pseudo dictionary ROM image.
6. **YM2608 (OPNA) rhythm samples** (required to use the OPNA rhythm section):
   `2608_BD.WAV` (bass drum), `2608_SD.WAV` (snare), `2608_TOP.WAV` (top cymbal),
   `2608_HH.WAV` (hi-hat), `2608_TOM.WAV` (tom), `2608_RIM.WAV` or `2608_RYM.WAV` (rim
   shot). Uncompressed PCM, 44100-48000 Hz, 16 bit, mono.
7. **Communication ROM** (optional)
   - `MPC-CM01.ROM` (32 KB): the EPROM on the MPC-CM01 communication card.
   - `mpc-cm01.eeprom` (8 KB): the EEPROM on the MPC-CM01. Optional; if used, put it in
     the same folder as the settings file (file name in lower case).
8. **Relay / FDD sounds** (optional) — as for the 6892, but the 8-inch files are replaced
   by `fddseek5h.wav`, `fddmotor5h.wav`, `fddheadon5h.wav`, `fddheadoff5h.wav`
   (5.25-inch 2HD).
9. ffmpeg libraries (optional).

If you reuse the ROM files of **CLUB09's S1 emulator**, strip the first 5 and last 5
bytes of each file (except KANJI). Mapping: `S1ROM1` -> `S1BAS1.ROM`, `S1ROM2` ->
`S1ROM2.ROM`, `S1ROMI` -> `S1ROMI.ROM`, `FONT` -> `FONT.ROM`, `KANJI` -> `KANJI.ROM`,
`DIC` -> `S1DIC.ROM`; `BOOT2HD` not needed (the bootstrap on the disk image is used).

(No hashes are given. Note the addresses are 20-bit physical addresses in the S1's 1 MB
space.)

## Release file layout (differences)

`tool/S1FONT.ROM` (instead of FONT.ROM); `tool/kanji/` also has `kanji2.txt` (JIS level 2
map); `tool/dict/` has `mkdic.pl`, `mkdic.py`, `readme.txt`, `s1dic.txt` (pseudo
dictionary ROM generator and mapping).

## Installation (differences)

No font ROM -> use `tool/S1FONT.ROM`; no kanji ROMs -> run `mkkanji` to make pseudo
`KANJI.ROM` and `KANJI2.ROM`; no dictionary ROM -> run `mkdic` to make a pseudo
`S1DIC.ROM`. FDD type shortcut is left option+F.

## Menus (differences)

### Control
- No "MODE Switch" item. Instead:
- **System Mode** — **A Mode (S1)**: boot in S1 mode; **B Mode (L3)**: boot in L3 mode.
- **FDD Type** — No FDD / 3inch compact FDD / 5.25inch mini FDD (2D) / 5.25inch mini FDD
  (2HD). (No 8-inch.)
- Auto Key: note — turn off romaji input.

### FDD
- With the 2HD type, drives 0 and 1 are 2HD and drives 2 and 3 are 2D only.

### Screen
- Adds **Digital RGB** (display equivalent to digital 16 colours) and **Analog RGB**
  (display equivalent to analog 64 colours).

### Options
- **Use Mouse** replaces Enable Lightpen.
- **Enable Joypad (PIA Type)** connects to the PIA **A** port; there is no PSG-type joypad
  and no Key-to-Joypad (PSG).

## Keys

| S1 key | Mac key |
|---|---|
| BREAK | F9 |
| GRAPH | F7 / 英数 (Eisu) |
| カタ/ひら (KATA/HIRA) | F8 / right option |
| 変換 (HENKAN, conversion) | right command |
| DEL | forward delete (delete x) |
| INS | insert / fn |
| BS | delete |
| CAPSLOCK | F6 / Caps |
| Keypad `?` | end |
| Keypad `,` | page down |
| COPY | F13 |
| Reset switch | F10 |

(The S1 has separate DEL, INS and BS keys, unlike the L3's Shift+DEL = INSERT.)
Shortcuts are the same as the 6892 with left option, except: System Mode = left option+M
(replaces MODE Switch), Mouse ON/OFF = left option+Ctrl.

## Joypad Setting dialog (differences)

- Rapid-fire is set per button.
- **Joypad (PIA Type)** maps onto PIA A port **`$FE40-$FE41`**; up to two joysticks.
- Option **"No interrupt caused by pressing the button"**: when checked, pressing a button
  never raises an IRQ regardless of the PIA port setting. (Replaces the 6892's
  negative-logic and connect-to options.)
- No PSG-type joypad sections.

## Configure dialog (differences)

### Mode tab
- **System Mode**: A Mode (S1) — use system mode A (S1 mode); B Mode (L3) — use system
  mode B (L3 mode); **NEWON7** — when checked, B mode boots in 80 columns.
- **FDD Type**: No FDD / 3-inch / 5.25-inch (2D Type) / 5.25-inch (2HD Type).
- **I/O Port Address** list:
  - 6voice PSG `$FF30-$FF33` — 6-voice PSG card for the Level 3
  - Ex LPT Port `$FF3C-$FF3F`, Ex COM Port `$FF40-$FF41` (as 6892)
  - 9voice PSG `$FF70-$FF7F` — 9-voice PSG card for the Level 3 (conflicts with kanji)
  - KANJI ROM `$FF75-$FF76` — JIS level 1 (conflicts with 9voice PSG)
  - **KANJI ROM JIS 2 `$FF72-$FF74`** — JIS level 2 kanji card; conflicts with 9voice PSG
  - **Ex PSG `$FFE6-$FFE7` (`$FFEE-$FFEF`)** — extension PSG card (for the S1). To use it
    as FM, change the sound chip on the Sound tab.
  - **OS-9 extension card `$FE11`** — enables the MMU segment register.
  - **Communication card `$FF77`** — needs the ROM image on the communication card.
  - **Keyboard `$FFE0-$FFE1`**
  - **Mouse `$FFDC-$FFDF`**
  - **FM sound card `$FF1E-$FF1F` (`$FF16-$FF17`)** — overlaps the 3-inch compact FDD;
    behaviour when both are used is undefined.
  - **ROM BASIC disabled (来夢来人) `$FFCE`** — when checked, behaves like 来夢来人 at
    start-up.
  - **IG disabled (来夢来人) `$FFE9`**
  - Real Time Clock `$FF38-$FF3A`
  - **Z80B Card `$FF7F`** — enables the Z80B card.
  - **MPC-68008 `$FE1A-$FE1B`** — enables the 68008 card.
  - To get a configuration close to **来夢来人 (an MB-S1-compatible machine)**: choose FDD
    type "5.25inch mini FDD (2D Type)", check "ROM BASIC disabled" and "IG disabled" in
    I/O Port Address, and power on.

### Screen tab
- CRTC Disptmg Skew / Curdisp Skew: effective only in B mode.

### CPU, Memory tab
- **Extended RAM** — size of the added memory (instead of a checkbox).
- **No wait to access the main memory** — normally a wait state is inserted on main-memory
  access; this removes it.
- **Connect interrupt signal of Z80B Card to** — interrupt routing for the Z80B card.
- **Show message when the address error occurred in MC68008**.

### Sound tab (new)
- **FM Synthesis Card** — chip used by the FM card (`$FF1E,$FF1F,$FF16,$FF17`).
- **Extended PSG port** — chip used on the extension PSG port (`$FFE6,$FFE7,$FFEE,$FFEF`).
  For BASIC PLAY, choose one of: PSG (AY-3-8910 equivalent), clock 1 MHz; OPN (YM2203
  equivalent), clock 2 MHz; OPNA (YM2608 equivalent), clock 4 MHz.
- **Connect interrupt signal of FM Synthesis to** — needed to use the FM chip's timers.
- The OPNA rhythm section needs the rhythm WAVs. Recording to the OPNA ADPCM is not
  possible.

## Volume dialog

Master, Beep, PSG (internal), ExPSG FM (*1), ExPSG SSG, ExPSG ADPCM (*2), ExPSG Rhythm
(*2), OPN FM (*1), OPN SSG, OPNA ADPCM (*2), OPNA Rhythm (*2), 6voice PSG (L3), 9voice PSG
(L3), Relay, CMT, FDD. *1 when an FM chip (YM2203/YM2608) is selected; *2 when YM2608 is
selected.

## Disk images (differences)

- 3-inch: as 6892 (40 cyl, 2 heads, 16 sectors, 128 bytes).
- **5.25-inch 2D**: 40 cylinders, 2 heads, 16 sectors per track per side, 256
  bytes/sector. (The S1 doc does *not* repeat the 6892's "track 0 side 0 is single
  density on a boot disk" note for 2D.)
- **5.25-inch 2HD**: 77 cylinders, 2 heads, 26 sectors per track per side, 256
  bytes/sector; on a boot disk track 0 side 0 is single density (same parameters as
  8-inch 2D).

## Cassette tape images

Same as the 6892 (`wav`, `l3c`, `l3b`, `l3`, `t9x`), with one footnote on `l3c`: the
1200 Hz / 2400 Hz frequencies become **2400 / 4800 Hz in double-speed FSK** mode.

## Mouse

When the mouse is enabled the host cursor is locked to the centre of the screen. Press
left option+Ctrl to release it before using other applications; it is also released
while paused.

## Joystick

Besides key input it emulates connection to the PIA A port (`$FE40-$FE41`). Joysticks on
the PSG general-purpose port are not emulated.

## Kanji ROM

- `tool/dict/mkdic.pl` / `mkdic.py` make a pseudo dictionary ROM.
- JIS level 2 image format: bytes 1-2 = values of `$FF72,$FF73` after writing `$0000` to
  `$FF72,$FF73`; bytes 3-4 after writing `$0001`; and so on (level 1 as on the 6892, via
  `$FF75,$FF76`).

## LED indicator

From the left: Caps; KATA/HIRA; cassette; tape counter; FDD type (3 = 3-inch, 5 =
5-inch 2D, 5H = 5-inch 2HD); FDD0-3; **system mode A/B; CPU clock (2 MHz / 1 MHz);
system/user mode**. The last three show the value of I/O port **`$FFEB`**.

## Additional references

- I/O 別冊 S1活用研究 (I/O special: S1 utilisation research), Kohgakusha, 1985
- 日立パーソナルコンピュータS1 10/20 取扱説明書 (S1 10/20 operating manual), Hitachi, 1984
- 日立パーソナルコンピュータS1 30/40 取扱説明書 (S1 30/40 operating manual), Hitachi, 1985
- S1ディスクBASIC (S1 Disk BASIC), Science-sha, 1985
- 図解マイクロコンピュータZ-80の使い方, Ohmsha, 1981
- M68000 8-/16-/32-Bit Microprocessors User's Manual, Motorola, 1993
- 68000プログラマーズハンドブック, Gijutsu-Hyoronsha, 1986
- 68000ファミリハンドブック, Keigaku, 1987
(plus the Level 3 references in the 6892 manual)
