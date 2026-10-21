# Other Basic Master Level 3 / MB-S1 emulators (survey, 2026-10-21)

Scope: everything other than the cloned bml3mk5 repos, plus the s-sasaji site facts about
EmuB-6892 / EmuB-S1. No ROMs were downloaded and no binaries were run. Raw page captures
(HTML and text) were saved to the session scratchpad only; they are not mirrored in ref/.

## Summary table

| Emulator | Machine | URL | Source? | Last update | Status / accuracy claims |
|---|---|---|---|---|---|
| **EmuB-6892** ("マーク5エミュレータ", bml3mk5) by Sasaji | L3 / Mk II / Mark 5 (MB-6892) | http://s-sasaji.ddo.jp/bml3mk5/ , https://github.com/bml3mk5/EmuB-6892 | Yes (GitHub + `bml3mk5_214_source.zip`); `src/COPYING.txt` is GPL v2 | V2.1.4, 2026-07-12 | Actively maintained since 2011. Compatibility list `tested.htm`: about 225 titles marked ○ (works), 6 △, 4 ×. The best L3 reference. |
| **EmuB-S1** ("S1モデル05エミュレータ") by Sasaji | MB-S1 (A mode and B/L3 mode) | http://s-sasaji.ddo.jp/bml3mk5/ , https://github.com/bml3mk5/EmuB-S1 | Yes (`mbs1_094_source.zip`) | V0.9.4, 2026-07-12 | Described as "an emulator that **behaves like** the MB-S1" (日立MB-S1のような動きをする), so it does not claim exactness. `s1tested.htm`: about 136 ○, 6 △, 2 ×. The only working S1 emulator. |
| **MAME `bml3` / `bml3mk2` / `bml3mk5`** | L3 family | https://github.com/mamedev/mame/blob/master/src/mame/hitachi/bml3.cpp | Yes (GPL-2.0+) | Last functional change 2024-10-24 (BAUD SEL); only refactors since (2025-01, 2026-05-29, 2026-07-24) | `MACHINE_NOT_WORKING`. See the history below. |
| **MAME `mbs1`** | MB-S1 | https://github.com/mamedev/mame/blob/master/src/mame/hitachi/mbs1.cpp | Yes (BSD-3-Clause) | Added 2024-09-26; last touched 2026-08-25 (refactor) | `MACHINE_NOT_WORKING`: "Cassette won't load, not even in Level 3 mode; Many features missing". |
| **bml3emulator** (shippoiincho) | L3 (Mark 5 IG included) | https://github.com/shippoiincho/bml3emulator | Yes (C, Pico SDK; no licence file) | 2024-07-21 | Raspberry Pi Pico, VGA via PIO, USB keyboard. 64 KB RAM, colour RAM, CRTC "partial", ACIA "partial", IG, beep, kanji ROM. ROM bank switching is "untested". Tape goes over UART hex or LittleFS, and baud select is ignored. Uses the spc476/mc6809 core. ROM is compiled into `bml3rom.h` (BASIC 24 KB + font 8 KB). A useful second compact C implementation. |
| **BASIC_MASTER_LEVEL3** (hi631, FPGA) | L3 (MB-6890), partial | https://github.com/hi631/BASIC_MASTER_LEVEL3 , article https://qiita.com/hi631/items/d10b7b5abeb195c5f4b9 | Yes (VHDL/Verilog, Quartus 17.1, DE10-Nano with MiSTer IO board for VGA; no licence) | 2019-11-26 | Based on MultiComp: a 6809 core plus the BBC-Micro mc6845. Keyboard is a plain register at $FFE0 fed over JTAG (no PIA). No interlace, no tape. The author says it is "not a complete MB6890". The only prior FPGA attempt; not a reference. |
| **eMB-689X** by "よ" (basicmaster.fan-site.net) | MB-6890/6891/6892 | http://basicmaster.fan-site.net/ (dead; Wayback has only a 2010 directory index and a 404 for `/emb689x/about.php`) | Unknown / no | Build "2008071900" (2008-07-19) | Win32. ROMs: `L3BAS.ROM` ($A000-$FFFF flat, $FF00-$FFEF skipped), `CHR.ROM` (4 KB), `KANJI.ROM` (128 KB). Its tape format `.t9x` (binary serial bitstream) is read by EmuB "provisionally". Lost. |
| **L3.EXE** "ベーシックマスターレベル3エミュレータ" by つの / club09 | L3 | http://club09.hp.infoseek.co.jp/ (dead; Wayback 2006), Vector https://www.vector.co.jp/soft/winnt/util/se202083.html (404; Wayback 2012-03-19) | No (shareware, 2,100 yen, time-limited trial) | Ver 1.14a (Vector only had 1.11) | WinXP/2000. Bundled tape-capture tool. Can pull the font from an MB-S1. ROMs `ROM1` ($A000-$FEFF), `ROM2` ($FFF0-$FFFF) and `FONT` in SAVEM format (5-byte header $00,size16,start16 and 5-byte trailer $FF,$0000,entry16). Lost. |
| **XM7** (Ryu Takegami) | FM-7, not L3 | http://retropc.net/ryu/xm7/ | | | Only used by haserin for F-BASIC comparison. Not an L3 emulator. |

The haserin page (Wayback copy of http://haserin09.la.coocan.jp/L3.html, 2026-08-02) says:
"As far as I know, **four** Level 3 emulators have been developed (two of them are lost)."
The four are eMB-689X, BML3MK5 (EmuB-6892), MESS/MAME `bml3`, and club09 L3.EXE. The Pico and
FPGA projects came later.

### Searched, nothing found
- **Takeda Common Source Code Project**: no `bml3`/`mbs1` VM. The local copy
  `~/dev2/common_source_code` (history to 2026-01-01) has only `bmjr`. The Takeda site was
  down (503, @nifty maintenance) on 2026-10-21. The Artanejp/common_source_project-fm7 fork's
  `source/src/vm` has `bmjr` only. GitHub code search for "BASIC MASTER LEVEL3", "MB-6892" and
  "bml3mk5" turns up only bml3mk5 repos, MAME and its forks, sedoc notes, and ROM-collection
  repos (e.g. `Abdess/retrobios`, which holds ROMs and was not opened). No CSP fork with an L3 VM
  exists. (EmuB itself is the CSP-derived L3 VM.)
- **j68**: this is a 68000 FPGA CPU core (fredrequin/j68_cpu), not a Basic Master emulator. No
  "j68" L3 emulator exists.
- **Web/JS emulators**: none found for the L3 or S1. MAME/JSMESS web builds do not include a
  working bml3.
- **ver0 (bm2 author)**: http://ver0.sakura.ne.jp/pc/ has only the Jr emulator bm2 (source
  2026-08-22) and bmtape2. It links eMB-688X/689X at basicmaster.fan-site.net. Its 2008 L3
  emulator was never released.
- **sedoc** (0cjs/sedoc `8bit/hitachi/emulation.md`) lists only bm2, mk5 and CSP bmjr.
- Many MAME forks (mameui, libretro mame2015/2016, etc.) carry the same driver unchanged.

## s-sasaji site details (fetched 2026-10-21 with curl; WebFetch's HTTPS upgrade fails, so use http://)

- Download page: http://s-sasaji.ddo.jp/bml3mk5/download.htm. All files are relative to
  `http://s-sasaji.ddo.jp/bml3mk5/`:
  - **Mark 5 V2.1.4 (2026-07-12)**:
    - `bml3mk5_win32_214.zip` MD5 0a1c9cef51c18b2ec779bac056cda02f
    - `bml3mk5_win32_214_dbgr.zip` 5ae0c9ee1ff4a006381cd4bdb3209ccc
    - `bml3mk5_win64_214.zip` 02e760d50748688697ea4ddbcfc70422
    - `bml3mk5_win64_214_dbgr.zip` 476f30a366caa3c01dc7acb108978782
    - `bml3mk5_cocoa2_macos_214.dmg` 843ddcd13a1cbea653fad4ef4d51b8b7
    - `bml3mk5_cocoa2_macos_214_dbgr.dmg` 484385b52919dbde55f57b0522914c65
    - `bml3mk5_214_source.zip` 302313bc22f9a217a2cb804fd50d6a06
  - **S1 V0.9.4 (2026-07-12)**:
    - `mbs1_win32_094.zip` 183b67edf3149a8566dd640f1811b944
    - `mbs1_win64_094.zip` fd59233970555bbe00d4dbe7576b7462
    - `mbs1_cocoa2_macos_094.dmg` f59bfe552c8d2abe6201a7b9573a62ed
    - `mbs1_094_source.zip` 67214d272df72fd106afadfaeb9cfeb3
    - Also `_dbgr`, `_z80b_dbgr` (Z80B card) and `_m68k_dbgr` (MPC-68008 card) variants.
  - Older versions are on `downloadold.htm`.
  - WavTool V0.6.7 (2026-01-31), L3DiskEx V0.8.6 (2026-10-01), MPPrinter V0.5.1, L3S1Basic V0.8.2,
    dump2bin V0.3.0 (2012-08-28, a perl script for I/O-magazine dump lists).
- Tested platforms: Windows 11/10 and macOS Sequoia 15.6.1 (Apple Silicon) / High Sierra (Intel).
  **Linux: "binary distribution stopped because it is untested; even if built from source it
  may well not work."**
- Other useful pages:
  - `tech.htm`: Mark 5 technical notes
  - `l3basic.htm`: LEVEL-3 BASIC reference
  - `l3s1ext.htm` / `fpgaext.htm`: hardware extensions
  - `s1notes.htm`: S1 BASIC work area
  - `l3s1progconv.pdf`: program conversion
  - `howto.htm` / `s1howto.htm`: how to extract images from real hardware
  - `l3tools.htm` / `s1tools.htm`: software and tools
  - `tested.htm` / `s1tested.htm`: compatibility lists
  - `l3help/` and `s1help/`: the manuals

### EmuB-6892 feature claims (l3help, V2.1.0)
- CPU: 6809 at 1 MHz equivalent, speed adjustable 0.5x to 16x.
- RAM: 64 KB standard plus 64 KB expansion (MP-9764).
- Video: up to 640x200 in 8 colours, plus IG.
- Sound: MUSIC_SEL, the 6-voice PSG (MP-9710), and the 9-voice PSG from I/O Aug 1983.
- Other devices: tape, printer, RS-232C, light pen (mouse), kanji ROM (MP-9740).
- FDD: 3" 1S (MP-3375/MP-1805), 5.25" 2D (MP-3550/3560, MP-1802), 8" 2D (MP-3630/MP-1806).
- **ROMs**:
  - `L3BAS.ROM` ($A000-$FFFF), or `ROM1.ROM` ($A000-$FEFF) plus `ROM2.ROM` ($FFF0-$FFFF).
  - `FONT.ROM`, required. A home-made font is supplied in `tool/`.
  - Optional: `MP1802.ROM` / `MP1805.ROM` / `MP1806.ROM` ($F800-$FFFF disk boot) and `KANJI.ROM`.
  - Note on the boot ROMs: MP1802 is needed for 5" boot with an L3-extracted BASIC; MP1805 for
    3" boot with an S1-extracted L3 BASIC.
- Disk image formats: d88 (read/write), hfe (read only), raw/"beta" (read/write), and
  dsk/fdi/td0 (untested).

### EmuB-S1 feature claims (s1help)
- CPU: 68B09 at 2 MHz equivalent.
- RAM: 64 KB standard (16 KB of it used as VRAM), plus 32 KB VRAM, 4 KB TEXT, and 0-512 KB
  expansion.
- Video modes: 320x200 in 8/16 colours, 640x200 in 8/16 colours, 320x200 in 64 colours,
  640x400 mono, and IG.
- Sound:
  - PSG 3 voices plus an extra 3 voices.
  - FM card (YM2203, I/O Jun 1985).
  - In B mode: the 6-voice PSG and the 9-voice PSG.
- FDD: 3" 1S (MP-1805), 5" 2D (MP-1870), and 5" 2HD (S1/30,40).
- Expansion cards: MPC-CM01 comms card, Z80B card, MPC-68008 card.
- **ROMs**:
  - S1 BASIC: `S1BAS1.ROM` ($E0000-$E7FFF, 32 KB) and `S1BAS2.ROM` ($E8000-$EFFFF), or
    `S1ROM2.ROM` ($E8000-$EFDFF) plus `S1ROMI.ROM` ($EFFF0-$EFFFF).
  - L3 BASIC for B mode: `L3BAS.ROM` ($FA000-$FFFFF, 24 KB), or `ROM1.ROM` plus `ROM2.ROM`.
  - Font: `FONT.ROM` ($BD000-$BDFFF, 4 KB, L3 compatible) or `S1FONT.ROM` (IC27, 8 KB).
  - Optional: `MP1802.ROM` / `MP1805.ROM`, `KANJI.ROM` / `KANJI2.ROM` (128 KB each),
    `S1DIC.ROM` ($D0000-$D8000, 32 KB; a pseudo-dictionary tool is supplied), and OPNA rhythm
    samples.

### Tape image formats (l3help/notes.htm, authoritative user-level description)
- **wav**: uncompressed PCM at 11025/22050/44100/48000 Hz, 8 or 16 bit.
- **l3c**: the audio sliced at **4800 Hz**, written as "1" for high level and "0" for low
  level. 1200 Hz is "1100" (or "0011"); 2400 Hz is "1010" (or "0101"). Text file.
- **l3b**: serial data, written as text "0"/"1". Each byte is a start bit "0", 8 data bits and
  2 stop bits "11".
- **l3**: binary tape image. It is the serial data with the start and stop bits removed. It
  contains the filename given at SAVE, checksums, and so on.
- **t9x**: the eMB-689X tape image, a binary form of the serial data. EmuB supports it
  provisionally, as there is no clear spec.
- **l3k**: a key-input recording (text), not a tape format.

## MAME history

The local checkout `~/Documents/development/BasicMasterJr_MiSTer/mame` **has full git history**
(HEAD f4bfc5a423f, 2025-12-24). The upstream master bml3.cpp / mbs1.cpp have the same headers
and flags. Upstream adds only the refactors d066f161341 (2026-05-29, clocks), 774a180df2b
(2026-07-24, screen split) and fd89972a567 (2026-08-25, mbs1).

`bml3.cpp`: 149 commits (with `--follow`). Key milestones:
- **pre-2012**: MESS `src/mess/drivers/bml3.c`, "preliminary driver by Angelo Salese". It was
  imported into the MAME tree on 2012-08-21 (7285b359d25). The early TODO already said
  "keyboard is actually tied to crtc hsync timer; understand how to load a tape". Haserin
  notes that MESS 0.149 had no cassette support.
- 2019-11-22 Nigel Barnes: RTC card.
- 2020-09-22 Robbbert: natural keys and a break-NMI key.
- 2021-05-18 Robbbert: software list.
- 2021-05-21 Robbbert: "adjusted keyboard, fixes Insect Hunter".
- 2023-04-08 AJR (ddfca0cb2cf): overhauled memory management and the expansion interface,
  using views so cards don't overwrite the main ROM region.
- 2024-09-16..21 angelosa:
  - long names, PORT_DIPLOCATION, System I/O as a proper block;
  - IG RAM support and IG display for bml3mk5;
  - cassette softlist, interlace clock;
  - an mc6845 fix for soft-reset hangs (6aeb83416cc).
- 2024-09-26: MB-S1 added (b1139717362, "New systems marked not working", [archive.org]
  dumps), after a revert on 2024-09-24.
- 2024-10-24 angelosa: "hookup BAUD SEL [Robbbert]" (68008cfb34e), and the IG Demo softlist item
  marked working.
- 2025-01-03 onward: refactors only.

Current flags and TODO:
- All three sets are `MACHINE_NOT_WORKING | MACHINE_SUPPORTS_SAVE`.
- Copyright holders: Angelo Salese, Jonathan Edwards, Christopher Edwards, Robbbert.
- Header TODO:
  - keyboard break NMI;
  - move the keyboard timer to the 6845 hsync callback (key repeat is too fast);
  - sound as a bus slot;
  - RAM expansion slots (RAM3 $8000-$BFFF, RAM4 $C000-$EFFF);
  - `$FFE8` bank reg ("applies EMS for the RAM expansion?");
  - cassette needs a manual play press (verify).
- Inline TODOs: break "supposed to actually raise an NMI"; MODE front-panel button; sound card
  slot.
- **ROM notes**: "replace with MB-6890 ROMs (these are from an MB-6892)", and "checksums are
  inclusive of the MP1805 patch". So MAME's bml3/bml3mk2 BASIC ROMs are Mark 5 dumps with the
  MP-1805 disk patch.

`mbs1.cpp` (BSD-3, Angelo Salese):
- 5 local commits, all from 2024-09/10.
- Flag `MACHINE_NOT_WORKING`.
- TODOs:
  - cassette won't load, even in L3 mode;
  - many features missing;
  - WIDTH80 bit not pinpointed;
  - memory_view base issue;
  - keyboard duplicated from bml3.
