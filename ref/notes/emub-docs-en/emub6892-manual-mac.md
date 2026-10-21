# EmuB-6892 manual (readme_mac_cocoa.txt) — English translation

Source: `ref/emulators/EmuB-6892/src/docs/readme_mac_cocoa.txt`, "HITACHI BASIC MASTER
LEVEL3 MARK5 Emulator, SDL2 + Mac Cocoa edition, Version 2.1.4, 2026/07/12".
Copyright (C) Common Source Code Project, Sasaji 2011-2026. The program is called
`bml3mk5`. Menu names are given as in the English UI. Purely cosmetic UI text is
translated a little more compactly; all technical content (ROMs, file formats, I/O
addresses, disk geometry, options) is complete.

Differences in the other editions (SDL, wx, Qt, Win) are listed in
[emub-manual-other-editions.md](emub-manual-other-editions.md).

## Introduction

This software is an emulator of the Hitachi Basic Master Level 3 Mark 5 (MB-6892).

## Main features

- CPU: speed x0.5 to x16
- RAM: standard 64 KB + extended 64 KB (modelled on the MP-9764)
- Display: hi-res up to 640x200, 8 colours, IG
- Sound: MUSIC_SEL (beeper), 6-voice PSG (modelled on the MP-9710), 9-voice PSG (the
  design published in *I/O* magazine, August 1983)
- Cassette tape input/output
- Printer output
- RS-232C input/output
- Light pen input: emulated with the mouse
- Kanji ROM: modelled on the MP-9740
- FDD, one of:
  - single-sided single-density (1S) 3-inch compact floppy (MP-3375 drive, MP-1805 I/F)
  - double-sided double-density (2D) 5.25-inch mini floppy (MP-3550/MP-3560 drive, MP-1802 I/F)
  - double-sided double-density (2D) 8-inch standard floppy (MP-3630 drive, MP-1806 I/F)

## Tested environment

macOS Sequoia (15.6.1) / High Sierra (10.13.6); built for Apple silicon and Intel 64-bit.
Devices: keyboard, mouse, joystick.

## What you need (ROM images)

The software needs ROM images from a real machine:

1. **ROM BASIC** (required to use BASIC)
   - `L3BAS.ROM`: image of addresses `$A000-$FFFF` (24 KB = 24576 bytes)
   - or `ROM1.ROM`: image of `$A000-$FEFF` (24320 bytes) **and** `ROM2.ROM`: image of
     `$FFF0-$FFFF` (16 bytes, the vectors).
   - `$FF00-$FFEF` is I/O space, so dummy data is fine there.
2. **Character font image** (required)
   - `FONT.ROM`: the character font. The `FONT.ROM` in the `tool` folder was made by the
     author and differs slightly from the real machine's.
3. **Disk boot ROM images** (to use DISK BASIC)
   - `MP1802.ROM`: ROM on the 5.25-inch mini-floppy I/F board (model MP-1802/A), image of
     `$F800-$FFFF` (2 KB). Required to boot from a 5-inch FD when using an L3 ROM BASIC
     dumped from an L3.
   - `MP1805.ROM`: ROM on the 3-inch compact-floppy I/F board (MP-1805), image of
     `$F800-$FFFF`. Required to boot from a 3-inch FD when using an L3 ROM BASIC dumped
     from an S1.
   - `MP1806.ROM`: ROM on the 8-inch standard-floppy I/F board (MP-1806), image of
     `$F800-$FFFF`.
4. **Kanji ROM** (optional)
   - `KANJI.ROM`: modelled on the MP-9740, JIS level 1 (128 KB). The `tool` folder has a
     program that creates a pseudo kanji ROM image.
5. **Relay, FDD seek and FDD motor sounds** (optional): `relay_on.wav`, `relayoff.wav`
   (relay click during tape load/save), `fddseek3.wav`, `fddmotor3.wav`,
   `fddheadon3.wav`, `fddheadoff3.wav` (3-inch), the same with `5` (5.25-inch 2D) and `8`
   (8-inch). Uncompressed PCM, 11025-48000 Hz, 8 or 16 bit, mono, up to about 0.25 s.
6. **ffmpeg libraries** (optional) — see "Libraries used for recording".

If you reuse the ROM files of **CLUB09's L3 emulator**, strip the first 5 bytes and the
last 5 bytes of each file. Mapping: `ROM1` -> `ROM1.ROM`, `ROM2` -> `ROM2.ROM`,
`FONT` -> `FONT.ROM`.

(The doc gives no hashes. The sizes in parentheses above follow from the address ranges.)

## File layout of the release

```
bml3mk5/
  readme.txt   history.txt   spec.txt
  bml3mk5.app/Contents/MacOS/bml3mk5      (the program)
  bml3mk5.app/Contents/Resources/         (icon, locale/ja/LC_MESSAGES/bml3mk5.mo)
  tool/
    FONT.ROM                              (author-made font)
    kanji/mkkanji, kanji.txt, readme.txt  (pseudo kanji ROM generator, JIS level 1 map)
```

## Installation

1. Unpack the archive and copy the `bml3mk5` folder anywhere (not into a system folder
   or the Applications folder).
2. Put the ROM images dumped from the real machine next to `bml3mk5.app`, or in another
   folder. Without a font ROM you can use `tool/FONT.ROM`; without a kanji ROM you can
   run `tool/mkkanji` to make a pseudo `KANJI.ROM`.
3. Connect any joystick beforehand.
4. Start the program. If the ROMs are elsewhere, set Configure -> CPU, Memory -> ROM
   Path, then Control -> PowerOn or restart.
5. To use an FDD, choose the FDD Type in the menu (or option+F), then PowerOn or
   restart. With an FDD active, the disk image last used in FDD0 is used as the boot disk.

The program creates `bml3mk5.ini` (settings), `bml3mk5.log` (log) and `keybind.ini`
(key settings) next to the app, or next to an ini file given on the command line.

If it will not start: for "cannot be opened because the developer cannot be verified",
Control-click and choose Open; or allow apps from identified developers in System
Preferences -> Security & Privacy. On Sierra (10.12) and later, if settings are not
saved, move the app folder elsewhere and back (App Translocation). Otherwise check
`bml3mk5.log` or run it from Terminal.

Uninstall: delete the folder.

## Menus

### bml3mk5 menu
- About bml3mk5 — version dialog.
- Exit.

### Control
- **PowerOn** — power cycle (cold reset). If the power-off state is enabled, toggles
  power on/off.
- **MODE Switch** — the mode switch. If checked when you PowerOn, it is equivalent to
  `NEW ON 7` (otherwise `NEW ON 3`; see the Configure dialog).
- **Reset Switch** — the reset switch.
- **FDD Type** — No FDD / 3inch compact FDD / 5.25inch mini FDD / 8inch standard FDD.
- **Pause**.
- **CPU Speed** — x0.5 to x16. "Sync Devices With CPU Speed": if checked the whole
  machine speeds up with the CPU; if unchecked only the CPU speed changes.
- **Auto Key** — Open... (type the contents of a file automatically), Paste (type the
  clipboard), Stop.
- **Record Key** — Play... (play back a key record file), Stop Playing, Record... (first
  saves the current state to a state file, then asks for the key-record file; paths of
  open tape and disk images are saved too; see "Key record files"), Stop Recording.
- **Load State...**, **Save State...**, **Recent State Files** (up to 20).
  Do not use these during tape or FDD load/save; doing so during a save can destroy data.

### Tape
- **Play...** — presses PLAY. Select the file, then run the load command on the machine.
  Supported: WAV (uncompressed PCM, 11025/22050/44100/48000 Hz, 8/16 bit), `.l3c`,
  `.l3b`, `.l3`, `.t9x`.
- **Rec...** — presses REC. Set the file name first, then run the save command on the
  machine. The format is chosen by the file type selected in the save dialog: WAV (the
  sample rate is set in the Configure dialog), `.l3c`, `.l3b`, `.l3`, `.t9x`.
- **Eject** — stops play/record and closes the file.
  - Note 1: by default recording overwrites. To append, fast-forward (F.F.) to the end of
    the file first.
  - Note 2: always Eject after recording to close the file.
- **Rewind** (to start of file), **F.F.** (to end of file), **Stop** (stops rewind/FF).
  Use Eject to stop play/record.
- **Real Mode** — play/record at close to real-machine speed ("you can feel how slow
  cassette tape was"). In this mode the tape sound (the "pee-gaa" noise) is heard, and the
  tape advances only with MOTOR ON.
- **Recent Files** (up to 20).

### FDD0/1/2/3
- **Insert...** — open a disk image. A multi-volume image opened in FDD0 puts volume 1 in
  FDD0 and volume 2 in FDD1 (likewise FDD2 -> FDD3). Images other than D88 may not load
  correctly.
- **Change Side to A/B** — 3-inch compact FDD only: flip the disk.
- **Eject** — close the image. Written data is saved to the image file on eject or after
  about 5 s of inactivity. Plain (raw sector) images are by default saved converted to
  D88; this can be changed on the Tape, FDD tab.
- **New** — Insert Blank 2D (5-inch 2D; also use for 3-inch and 5-inch single-density) /
  Insert Blank 2HD (use for 8-inch 2D). It must then be formatted.
- **Write Protect** — turning it on saves changes and the protect flag into the image.
  Cannot be removed if the host file is read-only; HFE is read-only.
- **Multi Volume** — choose a volume in a multi-image file.
- **Recent Files**.

### Screen
- **Frame Rate** — Auto (variable) / 60 / 30 / ... / 10 fps.
- **Record Screen** — 640x480 or 768x512 capture size; Rec 60fps ... Rec 10fps (pick the
  library, codec and quality, then the sound codec; video and audio are written as
  separate files); Stop; **Capture** (writes `<date-time>.bmp` or `.png` to the snapshot
  path).
- **Window** — WWWxHHH xM sizes.
- **Fullscreen** — Stretch Screen, Cutout Screen, `[n] WWWxHHH` per monitor. Primary
  monitor only; no menu in full screen; option+Return or right-click top-left to leave.
- **Aspect Ratio**.
- **Drawing Mode** — Full Draw; Scanline (CRT-like alternate lines, flickers in
  interlace); Stripe (alternate lines alternately, lighter); Checker (grid).
- **Afterimage1** — reproduces a long-persistence display so interlace flickers less.
  **Afterimage2** — one frame of after-image.
- **Drawing Method** — Default (Sync/Async), Use OpenGL (Sync/Async).
- **Filter Type** — Nearest Neighbor / Bilinear.

### Sound
- **Volume...**; **Record Sound** (Start... / Stop); sample rate 8000-96000 Hz; output
  delay 50-400 ms (restart needed; lengthen the delay if the sound breaks up).

### Devices (LPTx = printers, COMx = serial)
- **LPT0** — printer output from BASIC goes to an internal buffer. Save..., Print to
  mpprinter, Clear, Online (unchecked = disconnected), Send to mpprinter concurrently.
  (mpprinter is the author's print-data viewer, V0.3.0 or later; a host parallel port
  cannot be used directly.)
- **LPT1**, **LPT2** — the extension printer ports (enable "Ex LPT Port" in Configure).
- **COM0** — two copies of the emulator can talk over the network (one as server), or
  connect to a telnet terminal or a host serial port. Connect both sides before using COM
  from BASIC. Enable Server; Connect -> Ethernet (TCP/IP) or a listed host serial port;
  Comm With Byte Data (normally a byte is split into bits; check this to send whole
  bytes — use with telnet); Options For Telnet -> Binary Mode, Send WILL ECHO.
- **COM1** — the extension COM port (enable "Ex COM Port").

### Options
- Show LED, Inside LED, Show Message, Log....
- **Enable Lightpen**.
- **Enable Joypad (Key Assigned)** — joystick mapped to keys.
- **Enable Joypad (PIA Type)** — joystick on the PIA port.
- **Enable Joypad (PSG Type)** — joystick on the PSG port (enable "6voice PSG").
- **Enable Key to Joypad (PIA Type / PSG Type)** — keys act as a joystick.
- **Dull key input (for games)** — suppresses key over-press in BASIC games where the
  character moves too far.
- **Virtual Keyboard**.
- **Joypad Setting...**, **Keybind...**, **Configure...**.
- **Start Debugger** / **Stop Debugger** — only in debugger builds; see `debugger.txt`.

## Keys

A Japanese keyboard is assumed. Defaults (changeable in Keybind):

| Level 3 key | Mac key |
|---|---|
| BREAK | F9 |
| GRAPH | F8 / 英数 (Eisu) |
| KATA/HIRA | Tab / right Command |
| DEL/INS | Delete |
| CAPSLOCK | F7 / Caps |
| Keypad `?` | End |
| Reset switch | F10 |

INSERT is Shift+Delete (this is how the Level 3 works). Pause on/off: F16.

Option-key shortcuts: PowerOn/Off option+F3; MODE Switch option+M; Reset option+R;
FDD type option+F; Pause option+Q; CPU x0.5/x1/x2/x4/x8/x16 option+9/1/2/3/4/5; Sync with
CPU speed option+0; Record Key -> Play option+E; Load State option+O; Exit command+Q;
Tape Play option+F7, Rewind option+F5, F.F. option+F8, Stop option+F6; FDD0-3 Insert
option+F9..F12; Capture option+G; Fullscreen/Window option+Enter; Window size option+W;
Aspect option+A; Drawing mode option+S; Stretch/Cutout option+X; Afterimage1/2 option+T;
Drawing method option+Y; Filter option+U; Volume option+V; LED option+L; Message option+Z;
Joypad (key/PIA) option+J; Lightpen option+Ctrl; Keybind option+K; Configure option+C;
Start Debugger option+D; move LED indicator option+P.

## Joypad Setting dialog

Sets rapid-fire (0 = off, 3 = fastest) per port, analog-to-digital sensitivity and
button assignments, with presets.

1. **Joypad (PIA Type)** — maps the joystick's D-pad, analog stick and buttons 1-28 onto
   the signals of the standard PIA A port (`$FFC0-$FFC1`) or the extension PIA card's B
   port (`$FF62-$FF63`). One joystick only. Options: *Signals are negative logic*
   (unchecked: pressed = 1; checked: pressed = 0); *Connect to* standard PIA A port
   (`$FFC0-$FFC1`) or extended PIA B port (`$FF62-$FF63`).
2. **Key to Joypad (PIA Type)** — keys as joystick; uses the negative-logic and
   connect-to settings of (1).
3. **Joypad (PSG Type)** — maps onto the port of the 6-voice PSG card (`$FF30`); emulates
   a joystick on the second PSG's parallel I/O. Negative-logic option as above.
   (Note: spec.txt and the Joystick section below say the PSG1 side.)
4. **Key to Joypad (PSG Type)**.

"Disable temporarily: Z/R/U/V axis" ignores stuck analog axes while assigning.

## Keybind dialog

- **Keyboard** — up to two host keys per Level 3 key; presets. Special names: RESET =
  reset button, (Pause) = pause on/off (emulator-only key), (option) = shortcut modifier.
  Host key names assume a JP keyboard.
- **Joypad (Key Assigned)** — joystick buttons to Level 3 keys; up to two joysticks;
  "Recognize as another key when pressed two buttons" for chords/diagonals.

## Configure dialog

### Mode tab
- **DIP Switch -> MODE Switch** — checked = `NEW ON 7`, unchecked = `NEW ON 3`. ">" marks
  the current mode. Takes effect on restart or PowerOn.
- **FDD Type** — No FDD / 3-inch / 5.25-inch / 8-inch (restart or PowerOn).
- **Behavior of Power On/Off** — enable a power-off state; power state at start-up.
- **I/O Port Address** — which peripherals are enabled (restart or PowerOn):
  - 6voice PSG `$FF30-$FF33` — 6-voice PSG card
  - Ex LPT Port `$FF3C-$FF3F` — additional printer card
  - Ex COM Port `$FF40-$FF41` — additional RS-232C card
  - 9voice PSG `$FF70-$FF7F` — 9-voice PSG card. Cannot be used together with the kanji
    ROM (addresses overlap).
  - KANJI ROM `$FF75-$FF76` — kanji ROM card (JIS level 1). Cannot be used with the
    9-voice PSG.
  - Disable IG `$FFE9` — when checked, IG character display is disabled (compatible with
    the original Level 3 / Mark II).
  - Real Time Clock `$FF38-$FF3A` — sets the clock to host time at power on.

### Screen tab
- Drawing method, filter type, LED position.
- **CRTC: Disptmg Skew** (adjusts display timing) and **Curdisp Skew** (adjusts cursor
  display position).
- Capture type, snapshot path, font path, message font, info font, language (System
  Dependent / Default (English) / Japanese).

### Tape, FDD tab
- **Load Wav File from Tape** — how WAVs are analysed: Reverse Wave; Half Wave (detect
  half-wavelengths); Correct (correct the waveform first) with COS Wave / SIN Wave and the
  amplitude of the 1200 Hz and 2400 Hz correction sines. See the author's wavtool docs.
- **Save Wav File to Tape** — sample rate for saving WAVs.
- **When Start Up, mount drive at** — which drives remount their image at start-up.
- **Ignore delays to find sector** — FD speed depends heavily on the sector order of the
  image; this ignores sector order, so access is faster.
- **Ignore delays to seek track**.
- **Ignore delays to set the Busy flag in FDC** — normally there is a small lag between
  issuing an FDC command and Busy being set; this sets it immediately.
- **Suppress checking for density** — ignore single vs double density.
- **Suppress checking for media type** — ignore 2D vs 2HD.
- **Save a plain disk image as it is** — otherwise plain images are saved as D88.

### Network tab
- **LPT0-LPT2** — mpprinter host name, port, print delay (0.1-1000 ms). TCP/IPv4.
- **COM0-COM1** — host name (server: accepted hosts, `0.0.0.0` = all; client: target)
  and port. **Communication speed** (pairs are the rate with `"S"` / with `"F"` in BASIC):
  300/1200, 600/2400, 1200/4800, 2400/9600 baud. 9600 baud does not seem to be guaranteed
  by BASIC.
- **Connectable host to Debugger** — telnet access to the debugger console (debugger
  builds only).
- **Settings of serial ports on host** — baud rate, data bits, parity, stop bits, flow
  control (set at least as fast as the emulated COM port; reconnect after changing).

### CPU, Memory tab
- **ROM Path** — folder with ROM images, relay and FDD sounds (blank = program folder).
- **Use Extended Memory**.
- **Show message when the CPU fetches undefined opcode**.
- **Clear CPU registers at power on** — zero the CPU registers at power on.

## Volume dialog

Master, Beep (MUSIC_SEL), 6voice PSG, 9voice PSG, Relay, CMT (tape playback sound), FDD
(seek and motor); each with Mute.

## Record Screen / Record Sound dialogs

Choose library by tab (Mac video: avkit, ffmpeg; Mac audio: wave, avkit, ffmpeg), codec
and quality. Some codecs may not work.

## Virtual Keyboard

SHIFT, CTRL and GRAPH toggle (press once to latch, again to release).

## Libraries used for recording (ffmpeg)

ffmpeg 6.x is needed. Install with Homebrew (`brew install ffmpeg@6`, libraries in
`/opt/homebrew/opt/ffmpeg@6/lib`) or build ffmpeg 6.1.1 with
`--disable-static --enable-shared` (plus codecs such as libx264). Copy or symlink
`libavcodec.60.dylib`, `libavutil.58.dylib`, `libavformat.60.dylib`,
`libswresample.4.dylib`, `libswscale.7.dylib` into the ROM path, the program folder or
`~/lib`.

## Command-line options

```
bml3mk5 [-i <ini_file>] [-t <tape_file>] [-d <disk_file>] [-s <state_file>]
        [-a <autokey_file>] [-k <recordkey_file>] [<support_file> ...]
```

- `<ini_file>`: settings file; `keybind.ini` and `bml3mk5.log` are written in its folder.
- `<tape_file>`: tape image opened at start-up.
- `<disk_file>`: disk image opened at start-up.
- `<state_file>`: load this state and start.
- `<autokey_file>`: text file typed automatically from start-up.
- `<recordkey_file>`: key-record file played from start-up.
- `<support_file>`: any of the above; the type is decided by the extension.

## Drag and drop

Dropping a file on the window opens it if the extension is supported.

## Supplementary notes

### Disk images

Readable: D88 (M88 emulator), HFE (HxC Floppy Emulator, read-only), DSK (CPC DISK,
unverified), FDI (Anex86, unverified), TD0 (Teledisk, unverified), plain (raw).
Writable: D88, plain. D88 is the intended format; plain images are only tested with the
standard DISK BASIC format.

- **3-inch compact floppy** — the image is single-sided single-density (1S) x 2 (two
  sides as separate A/B), but a 2D image can be used. Parameters: 40 cylinders (tracks per
  side), 2 heads, 16 sectors/track, 128 bytes/sector (256-byte sectors work, but data
  beyond 128 bytes is ignored).
- **5.25-inch mini floppy** — 2D: 40 cylinders, 2 heads, 16 sectors per track per side,
  256 bytes/sector. On a boot disk, track 0 side 0 is single density.
- **8-inch standard floppy** — 2D: 77 cylinders, 2 heads, 26 sectors per track per side,
  256 bytes/sector. On a boot disk, track 0 side 0 is single density.

### Cassette tape images

- **wav** — audio. Uncompressed PCM, 11025/22050/44100/48000 Hz, 8/16 bit.
- **l3c** — the audio signal sliced at 4800 Hz: each slice is `"1"` if the level is High
  and `"0"` if Low. So a 1200 Hz cycle is `"1100"` (or `"0011"`) and a 2400 Hz cycle is
  `"1010"` (or `"0101"`). The file is a text file of `"0"` and `"1"` characters.
- **l3b** — serial data. Serial data is normally start bit (`"0"`) + 8 data bits + 2 stop
  bits (`"11"`). The file is a text file of `"0"` and `"1"` characters.
- **l3** — a tape image: the serial data with the start and stop bits removed (i.e. the
  bytes). It contains the extra information such as the file name given at SAVE and the
  checksum. Binary file.
- **t9x** — the tape image used by **eMB-689X**: the serial data stored in binary form.
  Support is provisional because there is no clear specification.

### Key record files (`.l3k`)

Text format. When recording starts the paths of open files are stored: `StateFile:`
(loaded on playback), `TapeFile:`, `TapeType:` (`Play` or `Rec`), `Disk0File:` ..
`Disk3File:`. Key presses during menus/dialogs are not recorded; input is still accepted
during playback (which will then diverge); timing-critical input such as games often does
not replay as intended.

### Light pen

Left-click on the screen with the mouse = pen pressed. In this emulator it registers
regardless of the screen brightness.

### Joystick

Tested with USB joysticks. Besides key input it emulates connection to the extension PIA
card B port (`$FF62-$FF63`), the standard PIA A port (`$FFC0-$FFC1`), or the PSG1 side of
the 6-voice PSG card (`$FF30-$FF33`). Do not unplug the joystick while running.

### Kanji ROM

- `tool/kanji/mkkanji` makes a pseudo kanji ROM from a chosen font (see its readme).
- Image format for JIS level 1: bytes 1-2 are the values read from `$FF75,$FF76` after
  writing `$0000` to `$FF75,$FF76`; bytes 3-4 the values after writing `$0001`; bytes 5-6
  after writing `$0002`; and so on. This layout may differ from a dump of the kanji ROM IC
  itself.

### LED indicator

From the left: KATA/HIRA lit; Caps on; cassette (lit for play, play-set, record,
record-set); cassette counter; FDD type (3 / 5 / 8); FDD0-3 (lit on access, number lit
when mounted). The tape counter value differs for the same program depending on the tape
image format.

## Development environment

Mac mini (M2, 8 GB), macOS Sequoia 15.6.1, Xcode 16, SDL2-2.28.5, SDL2_ttf-2.20.2.

## References (as listed)

- HITACHI PERSONAL COMPUTER Basic Master Level 3 Mark 5 入門書 (Introduction), Hitachi /
  Hitachi Kaden Hanbai, 1983
- Basic Master Level 3 Mark 5 文法書 (BASIC grammar), 1983
- Basic Master Level 3 Mark 5 取扱説明書 (Operating manual), 1983
- I/O 別冊 ベーシックマスター活用研究 (I/O special issue: Basic Master utilisation
  research), Kohgakusha, 1982
- レベル3BASIC入門 (Introduction to Level-3 BASIC), ASCII, 1981
- マイクロコンピュータMC6809の考え方 (Thinking about the MC6809), Ohmsha, 1982

## Acknowledgements, credits, disclaimer

Thanks to those who helped, and to Mr. Takeda, who kindly permitted publication
(Common Source Code Project: http://takeda-toshiya.my.coocan.jp/). Credits: SDL, SDL_ttf,
FreeType 2. Freeware, copyright not abandoned: the executable is (c) Sasaji, the source
code is (c) each author. No liability. Reprinting/redistribution needs no permission, but
the author would like to be told.

Contact: Sasaji (sasaji@s-sasaji.ddo.jp), http://s-sasaji.ddo.jp/bml3mk5/,
https://github.com/bml3mk5/EmuB-6892, https://x.com/bml3mk5
