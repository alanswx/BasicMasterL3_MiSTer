# Emulators for the Basic Master Level 3 / Mark 5 and the MB-S1: evaluation and ranking

Written 2026-10-21. Index of every download: `ref/SOURCES-emulators.md`. MAME vs EmuB on specific
points: `emulator-comparison-initial.md`. English translations of the EmuB docs:
`emub-docs-en/`. Other emulators found on the web: see "Other emulators" below.

## Ranking

| Machine | 1st (primary reference) | 2nd | 3rd |
|---|---|---|---|
| Level 3 (MB-6890) / Mark II (MB-6891) | **EmuB-6892** (bml3mk5) V2.1.4 | MAME `bml3` / `bml3mk2` | — |
| Mark 5 (MB-6892) | **EmuB-6892** | MAME `bml3mk5` (no `$FFE8`, IG is a "tracer bullet" hack) | — |
| MB-S1 | **EmuB-S1** (mbs1) V0.9.4 | (nothing usable: MAME `mbs1` is a stub that can't even load cassettes) | — |

### Why EmuB first

1. **Full source, actively maintained.** EmuB-6892 has 19 commits / tags from V1.9.0 (2022-10) to
   V2.1.4 (2026-07-12). EmuB-S1 has 16, from V0.7.0 to V0.9.4 (2026-07-12). Both are the same
   author's CSP-derived codebase, the first versions dating from 2011.
2. **License: GPL v2.** Both repos ship `src/COPYING.txt` (GNU GPL v2). The README's "free software,
   copyright not abandoned" disclaimer is about the binaries. So the TODO's "no explicit licence"
   is wrong: the source is GPLv2 like CSP.
3. **It models the machine at device level and is wired to real signals.** The keyboard scan is
   clocked by the HD46505's HSYNC output, and the FIRQ timer by the 6845's VSYNC. The ACIA IRQ goes
   to the CPU. BREAK drives NMI. The trace counter (`$FFD1`) drives NMI. Floppy IRQ goes to NMI and
   DRQ to HALT. MAME is missing most of these (see the comparison).
4. **Every option card:** MP-1802 (MB8866) / MP-1805 (MC6843) / MP-1806 8", 6- and 9-voice PSG,
   kanji, RTC (MSM58321), the extension PIA and ACIA, the Mark 5 extension RAM (`$FFE8`), IG.
5. **It handles every tape format** (wav/l3c/l3b/l3/t9x) and has a real-time vs fast tape mode.
6. **Debugger builds** (`*_dbgr`, `Makefile.*_dbgr`): a CPU trace / breakpoint / memory-map
   console (`debugger.txt`). It also has a BASIC-level debugger (`l3basic.cpp`). This is a good
   starting point for the headless CLI the TODO asks for.
7. **It builds on this Mac** (see below). The cocoa2 makefile is the author's own macOS target.

Caveats: no test suite. Some of the timing is approximate. Real-time tape delivers whole bytes to
the ACIA for `.l3` and doesn't model the 16× ACIA clock. The history file shows a lot of
compatibility tweaking. For low-level bus timing, trust the service manual over EmuB, as the Jr
project learned.

### MAME's role

A second opinion only. `bml3.cpp` is MACHINE_NOT_WORKING, cites EmuB's spec.txt and Sasaji's
tech.htm as references, uses Sasaji's hand-made font (same SHA1 as EmuB's `src/font/FONT.ROM`), and
leaves BREAK NMI, `$FFE8`, the ACIA IRQ and the keyboard timer as TODOs. It is useful where it cites
service-manual pages (clock tree p.48, keyboard timer p.65, MODE_SEL p.43). `mbs1` is
useful only for its MMU description and ROM CRCs.

## Build status (macOS, this machine: Apple clang 21, Homebrew SDL2-compat)

| Emulator | Target | Result | Notes |
|---|---|---|---|
| EmuB-6892 V2.1.4 | `make -f Makefile.mac_cocoa2` (SDL2 + Cocoa, the `sh_exe` shared build) | **Builds** (arm64 Mach-O, ~1.0 MB, about 5 s with -j10) | Needed 1) `brew install sdl2_ttf` (installed in this session), 2) `FFMPEGDIR=/opt/homebrew/include` on the make line (the makefile hard-codes `$(HOME)/Devel/ffmpeg-6.1.1`), 3) a 2-line patch to `src/video/ffmpeg/ffm_rec_audio.cpp` for the FFmpeg 8 API (`AVCodec::supported_samplerates` / `sample_fmts` were removed). Patch: `ref/notes/emub-macos-ffmpeg8.patch`. FFmpeg is only for video recording and is loaded at runtime |
| EmuB-S1 V0.9.4 | same | **Builds** (arm64, ~1.2 MB, about 7 s) | Same three fixes (the `ffm_rec_audio.cpp` file is identical) |

The build trees are in the scratchpad (`.../scratchpad/build/EmuB-6892/src/source/build/shared_cocoa2/bml3mk5`
and `.../EmuB-S1/src/source/build/shared_cocoa2/mbs1`). They are not in `ref/`, and the
binaries were not run. To rebuild: copy the repo, apply the patch, run `make -f Makefile.mac_cocoa2 -j10 FFMPEGDIR=/opt/homebrew/include`
in `src/source`. Other targets exist: `Makefile.linux_sdl_gtk` / `linux_wx` / `mac_wx`,
CMakeLists.txt, a Qt `.pro`, Xcode projects, and VC++2010-2019. A headless CLI would replace the
`osd/SDL` + `gui/cocoa` layer, much as the Jr CLI does in CSP.

## Where the key device code lives (EmuB-6892, `src/source/src/vm/bml3mk5/`)

| Area | File / functions |
|---|---|
| VM wiring (which signal goes where) | `bml3mk5.cpp` `VM::VM()`. CPU 1,008,000 Hz, 262 lines, 60 fps (`bml3mk5_defs.h`) |
| Memory map / banking | `memory.cpp` `MEMORY::change_l3_memory_bank()` (PIA A bits = `mem_bank_reg1`, `$FFE8` = `mem_bank_reg2`), `write_data8()` / `read_data8()` (colour-RAM latch, IG write-through), `load_rom_files()`. I/O decode: `memory_writeio.h`, `memory_readio.h` |
| CRTC / display | `../hd46505.cpp` (6845 with hsync/vsync outputs). `display.cpp` `DISPLAY::write_io8` (`$FFD0`, `$FFD6`, `$FFE9`), `draw_screen_sub()` and the `DISP_*` macros (text, hi-res bitmap, 2×4 semigraphics, IG), `load_font_rom_file()` |
| Keyboard | `keyboard.cpp` `update_keyboard()` (per HSYNC), `clear_scan_code()`, `update_scan_code()`, `update_special_key()` (BREAK→NMI, reset), `read_io8` (`$FFC8`, `$FFCB`, `$FFE0`), `write_io8` (`$FFE0`, `$FFD5`). Key matrix: `keyboard_bind.h` |
| Timer / FIRQ | `timer.cpp` `update_timer_clock()` (VSYNC), `$FFCA` read, `$FFD4` mask |
| Interrupt aggregation | `board.cpp` (masks in `bml3mk5_defs.h`: `SIG_NMI_*`, `SIG_IRQ_*`, `SIG_FIRQ_*`, `SIG_HALT_*`) |
| Tape | `cmt.cpp` `CMT::get_data()`, `set_data()`, `event_callback()`, `register_my_event()`, `set_baud()`, `check_file_format()`. WAV/l3c decoding: `../parsewav.cpp`, `../paw_parsewav.cpp`, `../paw_parsecar.cpp` (`CarrierParser::DecodeToSerial`, `GetL3CSample`) |
| ACIA / serial routing | `../acia.cpp` (6850). `comm.cpp` `COMM::write_signal` (`$FFD0` bit 5 picks the cassette or RS-232C path) |
| FDC | `floppy.cpp` `FLOPPY::write_io8/read_io8` (`$FF00-$FF08`, `$FF18-$FF27`), `DISK_DRIVE::*`. `../mb8866.cpp` (5"/8"), `../mc6843.cpp` (3"). Disk images: `../disk*.cpp` (D88, HFE) |
| IG (Mark 5) | `memory.cpp` `set_igmode()`, `reset_igram()`, IG write path in `write_data8()`. Display IG path in `display.cpp` |
| Sound | `sound.cpp` (beeper, `$FFD3`). `psgc.cpp` (6-voice, PIA), `psg9c.cpp` (9-voice, VIA). `../ay38910.cpp`, `../fmgen/` |
| Kanji / RTC / printer | `kanji.cpp` (`$FF75-76`), `rtc.cpp` + `../msm58321.cpp`, `printer.cpp` |
| BASIC debugger | `l3basic.cpp` |

### EmuB-S1 (`EmuB-S1/src/source/src/vm/mbs1/`)

| Area | File / functions |
|---|---|
| MMU | `memory.cpp` `MEMORY::address_mapping()`. S1 mode: `phys = (addr & 0xfff) \| addr_map[REG_ADDRSEG][addr>>12] << 12`. In system mode, `$E000-$FFFF` is forced to `$84000`/`$EF000`. L3 mode: `addr \| 0xF0000`. `reset_s1_membank()` holds the physical map: ext RAM `$00000-$7FFFF`, main RAM `$84000-$8FFFF`, GRAM `$B0000-$BBFFF`, text RAM `$BC000-$BCFFF`, dictionary ROM `$D0000-$D7FFF`, S1 BASIC `$E0000-$EFDFF`, S1 I/O `$EFE00-$EFFFF`, RAM image `$F0000-$FFFFF`, L3 ROM `$FA000-$FFFFF`. The map registers are at `$EFE00-$EFE0F` (writable only in system mode). `$EFE10` = fuse / user mode, `$EFE11` = segment select (64 segments, OS-9 board only), `$EFE18` = trap flag, `$EFE19` = bus control. `change_system_mode()`, `reset_s1_l3_mode()`, `set_cpu_speed()` (2.016 / 1.008 MHz). Writes to `$BFxxx` cause a trap NMI |
| I/O decode | `memory_writeio.h` / `memory_readio.h` (`$EFE00-$EFEFF` S1 only, `$EFF00-$EFFFF` common I/O) |
| Display | `display.cpp` `set_s1_screen_mode()`, `set_l3_screen_mode()`, `change_palette()`, `set_disp_page()` |
| Others | Same structure as EmuB-6892 (keyboard, timer with `update_fast_timer_clock`, cmt, floppy, board). Extras: `mouse.cpp`, `z80b_card.cpp`, `mpc_68008.cpp` (sub-CPU cards, build flags `_z80b` / `_m68k`) |

## ROM files EmuB expects

Placed in the configured ROM path or the application folder (`MEMORY::load_rom_files`). The checks
only warn (`loaded = 2`); a mismatch never stops loading. The file name is case-sensitive on
non-Windows builds.

| File | Size | Check (warn only) | Emulator | Notes |
|---|---|---|---|---|
| `L3BAS.ROM` | 0x6000 (24 KB) | first bytes `C4 5C` | both | $A000-$FFFF. MAME CRC `d81baa07` (the commented-out `l3bas.rom`). It is the concatenation of MAME's `598 p16611.ic3` (`954b9bad`), `599 p16561.ic4` (`b27a48f5`) and `600 p16681.ic5` (`fe3988a5`), 8 KB each. **Or** `ROM1.ROM` + `ROM2.ROM` |
| `ROM1.ROM` | 0x5F00 | first bytes `C4 5C` | both | $A000-$FEFF |
| `ROM2.ROM` | 0x10 | first bytes `00 00 01 00` | both | $FFF0-$FFFF vectors |
| `FONT.ROM` | 0x1000 | first bytes `00 00 00 00` | both | L3 font. The repo / release `src/font/FONT.ROM` (CRC `0b6f2f10`, SHA1 `dc411b44…`) is Sasaji's hand-made substitute, generated by `src/font/mkfont.py` from `display_font.bmp`. It is byte-identical to MAME's "handcrafted" `font.rom` |
| `MP1802.ROM` | 0x800 | — | both | 5" FDC boot ROM at $F800-$FFFF |
| `MP1805.ROM` | 0x800 | — | both | 3" FDC boot ROM at $F800-$FFFF |
| `MP1806.ROM` | 0x800 | — | 6892 | 8" FDC boot ROM |
| `KANJI.ROM` / `KANJI2.ROM` | 0x20000 each | — | both | Kanji level 1 / 2. `src/font/kanji/` builds a pseudo kanji ROM (`mkkanji`) |
| `S1BAS1.ROM` | 0x8000 | first bytes `EE C5` | S1 | MAME `s1bas1.rom` `efb80721` |
| `S1BAS2.ROM` | 0x8000 | first bytes `31 C6` | S1 | **or** `S1ROM2.ROM` (0x7E00, `31 C6`; MAME `e266108c`) + `S1ROMI.ROM` (0x10, `FF FF EE FD`; MAME `81cc0e4d`) |
| `S1DIC.ROM` | 0x8000 | first bytes `B1 00` | S1 | Dictionary. MAME NO_DUMP. `tool/dict/mkdic.py` + `s1dic.txt` in the release builds a substitute |
| `S1FONT.ROM` | 0x2000 | first bytes `00 00 00 00` | S1 | The repo `src/font/S1FONT.ROM` (CRC `1340db8a`) is a hand-made substitute. MAME's mbs1 `font.rom` (0x1000, `d1f27c5a`) is a different file |

The EmuB-S1 L3 mode also loads `L3BAS.ROM`/`ROM1+2` and `FONT.ROM` (`display.cpp`, `l3font_rom_loaded`).

**Local ROM set:** `/Users/alans/Downloads/bml3mk5_win32_191.zip` (copied to
`ref/emulators/binaries/local_bml3mk5_win32_191/`) contains `598_p16611.ic3`, `599_p16561.ic4`,
`600_p16681.ic5`, `l3bas.rom` and `font.rom`. Their CRC-32s (from `unzip -v`) are exactly MAME's
bml3 set (`954b9bad`, `b27a48f5`, `fe3988a5`, `d81baa07`, `0b6f2f10`). So the user already has the
Level 3 system ROMs. Extracting them into `roms/` was blocked by the permission classifier in this
session, so they are still only inside the zip.

## Tape formats (from `cmt.cpp`, `parsewav.cpp`, `paw_parsecar.cpp` and the manual §"Cassette tape images")

All five go through the 6850 ACIA. `$FFD7` bit 0 selects 600 baud (default) or 1200 baud. The motor
is `$FFD2` bit 7. In "real mode", one event per serial bit (or per byte for `.l3`) is timed at
`CPU_CLOCKS/baud`. In fast mode, events run at `CPU_CLOCKS/38400`.

| Ext | `file_type` | What it is | How EmuB feeds it |
|---|---|---|---|
| `.wav` | 0 | PCM audio, 11025/22050/44100/48000 Hz, 8/16-bit | `ParseWav` decodes to the l3c-style carrier and then to serial bits; FFT/sine correction options |
| `.l3c` | 1 | **ASCII text, one character per 1/4800 s sample of the carrier: `1` = high level, `0` = low level.** 1200 Hz = `1100` (or `0011`), 2400 Hz = `1010` (or `0101`). A 600-baud `0` bit = `11001100`, a `1` bit = `10101010`, so 8 characters per bit at 600 baud and 4 at 1200 baud. CR/LF are ignored (`GetL3CSample`). Any other character is just a non-matching sample: the `G`/`L` characters seen in the Dezeni Land files are not produced or interpreted specially by EmuB or WavTool (they behave as glitches the pattern matcher resyncs past). Their origin is unknown, probably the dumper's tool marking gaps/levels | `CarrierParser::DecodeToSerial` pattern-matches the 8/4-character groups into serial bits, which go to the ACIA RX one bit per event |
| `.l3b` | 2 | **ASCII text, one character per serial bit**: `0`/`1` (low bit of the character is used). Each byte is framed start `0` + 8 data bits LSB-first + 2 stop bits `11`, so 11 characters per byte. The leader is a run of `1`s. EmuB inserts CR+LF after ≥110 characters when a `1`→`0` boundary occurs, and skips CR/LF on read | One character = one RX bit (`mask=1`) |
| `.l3` | 3 | **Binary: the decoded bytes with start/stop bits removed** (exactly what the ACIA receives), including the BASIC tape header/name/checksum blocks (the `$FF` leader, `$01 $3C <type> <len> <data> <sum>` blocks described in the TODO) | `is_bytedata`: a whole byte is handed to the ACIA RX register per event (`mask=0xff`), timed at `CPU_CLOCKS/baud*11` |
| `.t9x` | 4 | The tape format of the older emulator **eMB-689X**: a 64-byte header (`"eMB-689X CassetteTapeImageFile  "` 32-byte ident, `int data1`, `int data2` (=9 when written), 24 reserved bytes), then the serial bit stream packed 8 bits per byte, LSB first. Undocumented ("provisional support") | One bit per event |

WavTool converts between all of them (`ref/emulators/WavTool`, docs `docs/Readme.txt`). Its
"real file" export strips the tape framing to raw BASIC/binary. Commercial software with custom
loaders must stay as l3b/l3c/wav, because the `.l3` byte form assumes standard ACIA framing.

## Other emulators

Full survey with URLs, dates, MAME commit history and the s-sasaji download MD5s:
`other-emulators-survey.md`. In short:

| Emulator | Source | Last update | Use as reference? |
|---|---|---|---|
| EmuB-6892 / EmuB-S1 (Sasaji) | yes, GPLv2 | 2026-07-12 | **Primary.** Compatibility lists on the site: ~225 L3 titles OK / 6 partial / 4 fail; ~136 S1 OK / 6 / 2. The S1 one says it "behaves like" the S1, not that it is exact |
| MAME bml3 / bml3mk2 / bml3mk5 | yes, GPL-2.0+ | last functional change 2024-10-24 (BAUD SEL) | Second opinion. NOT_WORKING. Its ROM comments say the bml3/bml3mk2 BASIC dumps really come from an MB-6892 and include the MP-1805 patch |
| MAME mbs1 | yes, BSD-3 | added 2024-09-26 | MMU and ROM CRCs only. NOT_WORKING, cassettes don't load |
| shippoiincho/bml3emulator (Raspberry Pi Pico) | yes, C, no licence file | 2024-07-21 | A compact third opinion (CRTC/ACIA "partial", IG, kanji). Cloned to `ref/emulators/shippoiincho-bml3emulator` (ROM headers are dummies) |
| hi631/BASIC_MASTER_LEVEL3 (DE10-Nano FPGA) | yes, VHDL/Verilog, no licence | 2019-11-26 | No: partial (no PIA, no tape, no interlace). Cloned to `ref/emulators/hi631-BASIC_MASTER_LEVEL3` as the only earlier FPGA attempt |
| eMB-689X ("よ", basicmaster.fan-site.net) | no | 2008-07-19 | Lost. Only its `.t9x` tape format survives (EmuB reads it) |
| L3.EXE (club09, shareware) | no | ~2006 (v1.14a) | Lost. ROM files were in SAVEM format (a 5-byte header and trailer) |
| Takeda CSP, any fork | — | — | **No L3/S1 VM anywhere** (local copy and the Artanejp fork have only `bmjr`). EmuB *is* the CSP-derived L3 VM |
| "j68" | — | — | Not an emulator: j68 is a 68000 FPGA core |
| Web / JS | — | — | None found |

## Docs (4d)

Each repo's `src/docs/` holds `spec.txt` (device and I/O support tables), `readme_{mac_cocoa,sdl,wx,qt,win}.txt`
(the user manual for each front end), `debugger.txt` (telnet debugger on port 54321: `! key`,
`! reset`, memory load/save, breakpoints, cycle-counted trace, and the table of which device drives
which interrupt), `history.txt`, and `CSP/` (Takeda's 2012 readme/history, which states the GPL).
The per-file summaries and the English translations are in `emub-docs-en/INDEX.md`. The telnet
debugger could serve as a stop-gap scriptable reference before a headless CLI is written.
