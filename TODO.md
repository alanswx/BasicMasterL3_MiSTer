# Basic Master Level 3 / MB-S1 MiSTer core: handoff TODO

Started 2026-10-21; last updated 2026-10-26. The core works: Level 3 / Mark 5 run on a
MiSTer, and the MB-S1 runs in vsim. **Start with "Handoff (2026-10-24)" below**, then
`CLAUDE.md` (layout, sim, build). The rest of this file is the original plan, kept for its
research and lessons; its checkboxes are kept up to date.

## Handoff (2026-10-24)

- **Repo:** <https://github.com/alanswx/BasicMasterL3_MiSTer> (public, GPL v2), branch
  `main`. ROMs, software and reference copies are local only (`.gitignore`). The history
  was checked: it contains no ROM or software files.
- **Latest RBF:** fd3e6f3 (2026-10-26), tested on Mister 126: the OSD follows
  `~/dev2/osd-standard.md` (top page: Pri. disk 0, Disk 1, Tape, Load ROM, Memory; P1
  Machine, P2 Video, P3 Input; settings latched into `cfg` at reset, "Changes pending",
  Apply and reset; h2 blank keeps rows still; `v,1`) and `~/dev2/tape-standard.md`
  (Tape speed 16x/Normal, Rewind tape, "Tape ready (rewound)", tape status bar in
  `rtl/tape_overlay.v`). Not done from the standards: Swap Alt/Win (the keyboard maps
  neither key), Tape audio (no waveform to play). Hardware check: Model change shows
  Changes pending without resetting, Apply and reset boots S1 BASIC, tape mount message,
  Aerial (S1) loads at 16x with the bar counting and vanishing when the motor stops.
- **Before that:** f3c0c75 (2026-10-26), tested on Mister 126: reset fixed (the CRTC
  model cleared its registers on reset, so after any L3 reset the warm start left no
  HSYNC and the keyboard scanner stopped: the tester's "reset bug"); every reset now
  clears main RAM so BASIC cold-starts. Model switches L3 <-> S1 A/B, OSD Reset, S1
  BASIC and typing all verified on hardware. Tester zip
  `releases/BasicMasterL3_tester_<date>.zip`.
- **Earlier:** 35ab176 (2026-10-26): Floppy card "Auto" (fitted only with a disk in
  drive 0, because an S1 in A mode with the card fitted waits forever at "Insert Program
  Diskette", ROM `$5471`), reset on Model/SYSTEM change, J last in the OSD. Tester zip
  `releases/BasicMasterL3_tester_20261026.zip`. Tester report on f3f5c82: S1 stuck at
  the diskette prompt, tapes would not load (probably the same cause), "reset bug"
  (details pending).
- **Previous RBF:** f3f5c82 (`releases/BasicMasterL3_f3f5c82.rbf`). Timing met, 39% ALMs,
  73% RAM blocks. It is the first build with the MB-S1, SD tape streaming and the PSG
  card. **Not yet tested on hardware.** The last build tested on hardware is a30d92b
  (L3 boot, keyboard, tape, MP-1802 Tetris).
- **Testers:** `releases/BasicMasterL3_tester_20261024.zip` (f3f5c82 + boot0.rom + 66
  tapes + 9 disks + README) went to two private testers. To rebuild it, run
  `software/tools/make_tester_zip.sh`; the tester README is `software/tester/README.txt`.
  The zip holds ROMs and commercial software, so never publish it.
- **Hardware:** Mister 192 is shared with the user. Ask before loading anything on it.
- **Next, in order:**
  1. Hardware-test f3f5c82: MB-S1 boot and games, SD tape at 1x and fast speeds, PSG
     card and S1 PSG audio. Collect tester reports.
  2. Tester report (2026-10-27): "on L3, tapes load only with turbo off". Not
     reproduced in vsim (Ascend at 16x loads on Level 3, Mark 5 and S1 mode B); waiting
     for the tester's model, tape and screen. Next idea if it is real: prefetch the next
     tape sector (tape standard rule 10), since a slow SD read pauses playback.
  3. Mazy (S1): the right-hand score digits are clipped. Compare with EmuB-S1.
  4. The rest of the S1: 640x400 (interlace), 64-colour mode, user mode / FUSE, the
     keyboard's extra keys.
  5. MP-1805 (MC6843) 3" floppy; a 9-voice PSG if any software needs it; kanji ROM.
  6. Cassette SAVE, last.

## Goal

Build a MiSTer FPGA core for the Hitachi **Basic Master Level 3** family (MB-6890
Level 3 1980, MB-6891 Mark II 1982, MB-6892 Mark 5 1983). Then extend it to the
**Hitachi MB-S1** (1984). The S1 has a Level 3 compatibility mode ("B mode"), so one
core with an L3/S1 model switch is the plan.

**This is not the Basic Master Jr.** There is a working Jr core at
`~/Documents/development/BasicMasterJr_MiSTer`, but the Jr is a 6800 machine.
Japanese Wikipedia says the Level 3 "shares the name only. It is completely
incompatible in design and function with Level 1, 2 and Jr." No RTL carries over.
The Jr project's workflow does carry over (sim harness, reference-emulator CLI,
regression, tester packaging), and so do its lessons (see the end of this file).

## Machine summary (verify each fact; these come from MAME and Wikipedia)

**Level 3 / Mark II / Mark 5**
- CPU: MC6809 (actually HD46809), 1 MHz. A 32.256 MHz crystal is divided down to
  4.032 MHz EXTAL, which the 6809 divides by 4. Source: `bml3.h`, citing the service
  manual p.48.
- Video: HD46505SP CRTC (a 6845). Text is 40 or 80 columns. Graphics are 640x200 or
  320x200 in 8 colours (BRG 3-bit). Each byte of attribute RAM holds bit 0 blue,
  bit 1 red, bit 2 green, bit 3 reverse and bit 4 graphic. Interlace (400 lines) is
  selected at `$FFD6`. 15.75 kHz / 60 Hz.
- Memory: RAM at `$0000-$03FF`. VRAM and attribute RAM at `$0400-$43FF`. RAM at
  `$4400-$7FFF`. RAM or ROM banks at `$8000-$FFFF`: views at `$A000`, `$C000`,
  `$E000`, `$F000` and `$FFF0`, written-through RAM under the ROM. I/O is at
  `$FF00-$FFEF`. BASIC ROM is 3 x 8 KB at `$A000`, `$C000` and `$E000`. MAME's dumps
  are marked BAD_DUMP and its font is "handcrafted".
- I/O (`$FFxx`):
  - `C0-C3`: PIA 6821
  - `C4-C5`: ACIA 6850, used for both cassette and RS-232C
  - `C6-C7`: CRTC
  - `C8`: keyboard NMI
  - `C9`: DIP switches
  - `CA`: timer
  - `D0`: mode select
  - `D2`: remote (tape motor)
  - `D3`: music select (beeper)
  - `D4`: time mask
  - `D6`: interlace
  - `D7`: baud select, 600 or 1200
  - `D8`: C-reg select
  - `E0`: keyboard select
  - `E8`: bank register (Mark 5)
  - `E9`: IG mode (Mark 5)
  - `EA`: IG enable
- Cassette: Kansas City-style 1200/2400 Hz through the ACIA at **600 baud**
  (1200 selectable).
- Options (bus cards): MP-1805 3"/5" SS FDC, MP-1802 5" 2D FDC (MB8866), 6-voice
  and 9-voice PSG cards, YM2203, kanji ROM, RTC, extra RAM. `$FF00-$FF03` is the
  5" FDC, `$FF18-$FF1F` the 3" FDC, `$FF30-33` 6PSG, `$FF70-7F` 9PSG, `$FF75-76` kanji,
  `$FF38-3A` RTC. These addresses come from EmuB-6892's spec.txt.
- Mark 5: IG ("image generator", programmable characters).

**MB-S1**
- HD68B09E at 2 MHz, dropping to 1 MHz in L3 mode.
- MMU: 1 MB address space, 4 KB pages, 16 mapping registers. See MAME `mbs1_mmu.cpp`.
- 48 KB RAM plus 48 KB VRAM. Extra graphic planes and a palette. S1-BASIC and L3
  BASIC are selected by a switch.
- Models: /10 and /20 (kanji) from May 1984; /30 and /40 (1 MB FDDs) from Dec 1984;
  /10AV with 6-voice sound and joysticks; /15 and /45 with RS-232C.
- MAME's `mbs1` is a stub: "Cassette won't load, not even in Level 3 mode; Many
  features missing". Do not use it as the reference for S1 behaviour.

## Reference sources found so far

### MAME (local checkout)
`~/Documents/development/BasicMasterJr_MiSTer/mame/` (untracked; GPL)
- `src/mame/hitachi/bml3.cpp` / `bml3.h`: the L3, Mark II and Mark 5 driver. It is
  marked NOT_WORKING, and its TODO list names keyboard NMI, keyboard timer, sound,
  RAM expansion and `$FFE8`.
- `src/mame/hitachi/mbs1.cpp`, `mbs1_mmu.cpp` / `.h`: the S1 stub. It gives the MMU
  map and the ROM names and CRCs.
- `src/devices/bus/bml3/`: `bml3bus`, `mp1802`, `mp1805`, `kanji`, `rtc`.
- `hash/bml3_cass.xml`, `hash/bml3_flop.xml`: the software lists.
- ROM set names: `bml3`, `bml3mk2`, `bml3mk5`, `mbs1`.

### Common Source Code Project (`~/dev2/common_source_code`)
- **It has no Level 3 or S1 VM.** Only `src/vm/bmjr/`, which is the Jr.
- **It does have every L3 building block as a device:** `mc6809.cpp` /
  `mc6809_base.cpp`, `hd46505.cpp`, `mc6820.cpp` (PIA), `mc6850.cpp` (ACIA),
  `mb8877.cpp` (FDC), `ym2203.cpp` / `ay_3_891x.cpp`, `beep.cpp`, `datarec.cpp`
  (tape), and `disk.cpp` (D88).
- `src/vm/fm7/`: another 6809 machine. It is a model for the structure of a 6809 VM
  in CSP.
- The Jr headless CLI (`src/mac/bmjr_cli.mm`, `MAC_BMJR_CLI.md`) is the pattern for
  a scriptable reference: `--tape`, `--type`, `--screenshot`, `--dump-mem`, `--poke`,
  traces. It runs about 300x faster than Verilator. The same pattern exists for
  SMC-777 and X1.
- `MISTER_CORE_GAPS.md` is the list of CSP machines against MiSTer cores.

### s-sasaji (bml3mk5): the best reference
GitHub user `bml3mk5`. "Copyright Common Source Code Project, Sasaji". It is
CSP-derived and GPL v2 (both repos ship `src/COPYING.txt`). Cloned with history
into `ref/emulators/`; both build on macOS with `make -f Makefile.mac_cocoa2` (see
`ref/notes/emulators.md`).
- **`EmuB-6892`**: Level 3 Mark 5 emulator, full source, Japanese docs in `src/docs`
  (spec.txt is the device and I/O support list).
- **`EmuB-S1`**: MB-S1 emulator, full source. This is the **only** working S1
  reference.
- Tools:
  - `WavTool`: tape WAV conversion.
  - `L3S1Basic`: text to/from tokenized BASIC.
  - `L3DiskEx`: disk image file access.
  - `MPPrinter`.
- Hardware projects with documentation: `L3PSG6n9Voices`, `L3KanjiRom`,
  `L3mk5ExRam`, `S1ExmemAndFmOPN`, `S1FmSynthOPNA`, `S1KanjiRomJIS2`, `S1MpcExCard`,
  `L3S1VirtualFloppy`, `MP1800Gotek`, `MP1802Gotek`, `USBKeyboard4S1`.
- Site: <http://s-sasaji.ddo.jp/bml3mk5/> (`tech.htm` is the hardware notes that
  MAME cites). The same site has the ベーマガ program index for BM machines:
  <http://s-sasaji.ddo.jp/bm/>.
- Other references MAME cites: <https://github.com/bml3mk5/EmuB-6892/blob/master/src/docs/spec.txt>
  and <https://www.leadedsolder.com/2023/05/09/hitachi-basic-master-level-iii-mark-ii-cleaning-pickup.html>.

### Reusable RTL already in `~/dev2`
| Need | Where |
|---|---|
| 6809 CPU | `FM-7_MiSTer_alanswx/rtl/mc6809i.v` (in use on hardware); also `Vectrex_MiSTer/rtl/mc6809.v` and `CoCo3_MiSTer/rtl/CPU09` |
| 6845 CRTC | `SMC777_MiSTer/rtl/mc6845v/mc6845.v` |
| FDC (MB8866 ≈ WD1793) | `wd1793.sv` in FM-7, CoCo3, SharpMZ, X1 and SMC777 |
| YM2203 / PSG | `FM-7_MiSTer_alanswx/rtl/jt12/jt03.v` |
| Tape-from-HPS buffer, fast tape, vsim harness, CSP compare scripts | `~/Documents/development/BasicMasterJr_MiSTer` (`rtl/cassette.v`, `vsim/`, `vsim/csp/`) |

The FM-7 core is the closest whole-core template: 6809, YM2203, WD1793, D88 disks,
tape and an MMU (FM77AV).

## Software on hand (`software/incoming/`, unextracted originals)

| File | Machine | Format | Notes |
|---|---|---|---|
| `Skating_…zip` | L3 | `.l3` ×2 + WAV | SKATING1 and SKATING2 |
| `MELHEN_…zip` | L3 / Mark 5 / S1 B-mode | `.l3` + WAV + readme | Micom BASIC 1984-12. `LOAD "MELHEN"`, `RUN` |
| `Cannon-Ball_…zip` | L3 | `.l3` | |
| `Eric-and-the-Floaters_…zip` | L3 | `.l3` | The file inside is `Bomber Man.l3`. Downloads had a byte-identical "(1)" copy |
| `Hitachi - Basic Master Level 3 [!]│MSS│.7z` | L3 | `.d88` ×3 | Tetris (1991 homebrew), HI-Writer 1.5 + data disk |
| `…Jr. Level 3 - Games - [L3] (TOSEC…).zip` | L3 (TOSEC mislabels it "Jr.") | `.l3` | inufuto **Ascend, Mazy, Mazy (Mark-5), Ruptus**: the L3 builds of games proven on the Jr core. The best first tests |
| `…Jr. Level 3 - Games - [WAV] (TOSEC…).zip` | L3 | WAV | WAVs of the same titles |
| `Jelda_Hitachi-S1_JA.zip` | S1 | `.l3b` + WAV | |
| `Lode-Runner_Hitachi-S1_JA.zip` | S1 | `.l3b` / `.l3c` + WAVs | Program + Data |
| `Dezeni-Land_Hitachi-S1_JA.zip` | S1 | `.l3c` ×3 | |
| `mame_softlist/bml3_cass/` | L3 | MAME softlist | bmtetris, igdemo |
| `mame_softlist/bml3_flop/` | L3 | MAME softlist | dbu, fcg6890, hiwriter, insecth, jwp, ma5370, subtreas, tetris |

What has been worked out about the formats:
- **`.l3`** is a byte stream: a run of `$FF` leader, then `$01 $3C`, a block type
  (`$00` = name block), a length (`$14`), and the name (`SKATING1`…). After that come
  data blocks (`$01 $3C $01 …`) holding tokenized Level 3 BASIC (line links
  `$27xx`), so it looks like a Microsoft/CoCo-style tape.
- **`.l3b`** is ASCII `0`/`1` text, one character per serial bit.
- **`.l3c`** is ASCII text of `0`, `1`, `G` and `L`, apparently one character per
  carrier half-cycle.

Confirm all three formats against the EmuB-6892 / EmuB-S1 source (tape loader) and
WavTool.

Not in hand: **system ROMs**. MAME's sets are `bml3`/`bml3mk2`/`bml3mk5`
(`598 p16611.ic3`, `599 p16561.ic4`, `600 p16681.ic5`, `font.rom`) and `mbs1`
(`rom1.rom`, `rom2.rom`, `s1rom2.rom`, `s1romi.rom`, `s1bas1.rom`, `font.rom`; the
`s1dic.rom` dictionary is not dumped). The user has authorised downloading ROM dumps
(2026-10-21); they go in `roms/` (see `roms/README.md`), never in the RBF.

## Status (2026-10-24)

- Research step 0 is done: `ref/SOURCES-*.md`, `ref/notes/`, `roms/README.md`,
  `software/README.md`. EmuB-6892 is the reference and builds on macOS.
- Level 3 core boots BASIC to `Ready` in vsim **and on a MiSTer** (Mister 192),
  keyboard works (US-symbol translation, paced event queue), `.l3` tapes load
  byte-exact: inufuto Mazy loads at real 600 baud and runs on the MiSTer too.
- Mark 5 IG works in vsim (Mazy Mark 5 build); BM Tetris (IG) loads its IG setter.
- MP-1802 floppy (two drives, D88 via wd1793.sv): the Tetris (1991) disk boots and
  plays in vsim and on the MiSTer (build a30d92b). 6-voice PSG card (PIA + 2x jt49) answers register reads/writes.
- `$FFD1` trace NMI, optional true interlace, optional border, optional
  expansion RAM (off = stock MB-6890, 22378 bytes free) are in.
- **MB-S1** (model 3 in the OSD; ref/notes/mbs1-implementation-spec.md): S1 BASIC boots to
  `Ready` in A mode, typing and 640x200 graphics (LINE/CIRCLE) work; B mode boots Level 3
  BASIC. Build f3f5c82 meets timing: 39% logic, 73% RAM blocks. Not yet tried on hardware.
- BM Tetris (Mark 5 IG, 5 chained tape files) runs end to end at real tape speed.
- `software/tools/l3conv.py` converts `.l3b`/`.l3c` to `.l3` (Lode Runner converts with
  no bad blocks). Tapes are now streamed from the SD card as block device 2 (OSD "Mount
  Tape"), so size is unlimited and 64 RAM blocks are free again.
- S1 software in vsim: inufuto Mazy (S1 build) runs; Lode Runner loads across its 600/1200
  baud switch to the "COMMAND >" screen; Jelda (.l3b) loads at 16x and runs its title and
  attract ("THE WARS OF JELDA"). The Hudson tapes (Nuts & Milk, Mario Bros Special,
  Princess Tomato, Dezeni Land) failed because of l3conv.py, fixed 2026-10-27: their
  LOADER/M sets the ACIA to 8E1 (control $58), so bit 9 is parity and the old 2-stop-bit
  check dropped every byte with parity 0; and in .l3c a 600-baud frame also decodes at
  1200 (bit 0 = 0, $FF -> $FE), so the rate is now picked by decoding the next frames,
  with a doubled-bit test on ties. All four reach their title / first prompt in vsim at
  16x; the 8N2 tapes (Jelda, Lode Runner, Volguard) convert byte-identically. Mazy S1's right-hand score digits look clipped:
  compare with EmuB-S1.
- Open items: see "Next" in the handoff above. Cassette SAVE comes last because it is
  awkward on MiSTer: it needs a writable image or an audio-out path.

---

## TODO

### 0. Gather everything (do this first, in a subagent)

- [x] **Launch a subagent to download all documentation, software and emulator
  source** into `ref/` and `software/`, with a `ref/SOURCES.md` index giving the URL,
  date, licence/redistribution note and a sha256 for each item. Give it this list as
  a starting point and tell it to follow links outward:
  - **Emulators with source:** `git clone` `bml3mk5/EmuB-6892`, `bml3mk5/EmuB-S1`,
    `WavTool`, `L3S1Basic`, `L3DiskEx`, `MPPrinter`, and every
    `bml3mk5` hardware repo (they document the card I/O). Clone them with history,
    not as zips.
  - **s-sasaji site:** mirror `http://s-sasaji.ddo.jp/bml3mk5/` (especially
    `tech.htm` and any spec, memory-map, I/O or tape-format pages), the `mbs1`
    emulator pages, and `http://s-sasaji.ddo.jp/bm/` (program indexes).
  - **PDFs and scans:**
    - Hitachi manuals for the Level 3, Mark II, Mark 5 and MB-S1: the user's manual,
      the BASIC reference, and above all the **service manual** (MAME cites
      "MB-6890 service manual" p.48, p.64, p.65 and p.67).
    - Schematics.
    - I/O / ASCII / Oh!HITACHI magazine articles on L3/S1 internals.
    - Search archive.org (I/O and マイコンBASICマガジン scans are there; see the Jr
      project's `software/found2/README.md` for the item naming), bitsavers,
      Gaming Alexandria / Typing Task Force (the source of the MELHEN etc. zips),
      and the leadedsolder blog.
  - **Software:**
    - inufuto's L3 and S1 builds from <http://inufuto.web.fc2.com/8bit/> (check
      for a "bml3" or "s1" folder).
    - TOSEC Hitachi Basic Master Level 3 and MB-S1 sets.
    - Typing Task Force / Gaming Alexandria L3 and S1 releases.
    - Type-in listings for L3/S1 in ベーマガ (the s-sasaji index lists them).
    - MAME `hash/bml3_cass.xml` / `bml3_flop.xml` titles.
  - **Other emulators to note, even without source:** j68, bml3mk5 binaries, and
    MAME driver history (`git log` on `bml3.cpp`).
  - **Rules for the subagent:**
    - Put each download in its own directory and don't execute anything.
    - Report what was **not** found.
    - System ROMs are authorised: put them in `roms/` and verify them against MAME's CRCs.
- [x] Extract `software/incoming/*`. Write `software/README.md` with a table for each
  title: machine, format, load command and expected entry point.

### 1. Pick the reference emulator and make it scriptable
- [x] Build EmuB-6892 (and EmuB-S1) on macOS (done: `ref/notes/emulators.md`) or Linux. If that is impractical,
  write a `bml3` VM inside CSP from its existing devices (mc6809, hd46505, mc6820,
  mc6850, mb8877, beep, datarec, disk), using the fm7 VM as the structural model.
- [ ] Add a headless CLI that matches the Jr's `bmjr_cli.mm` flags (`--tape`,
  `--type`, `--screenshot`, `--dump-mem`, `--poke`, `--trace-cpu`, `--trace-io`,
  `--stop-at-frame`). The whole Jr workflow depends on this: it is how you learn what
  software *should* do, at about 300x sim speed.
- [ ] Get MAME `bml3mk5` running too, as a second opinion (it is NOT_WORKING; note
  where it fails).

### 2. Research notes before RTL
- [~] (Covered by `ref/notes/hardware-from-manuals.md` and `schematic-notes.md`.) Write `ref/notes/hardware-reference.md`: the I/O map, memory/ROM banking
  (`$FFD0` mode select, the RAM-under-ROM views, `$FFE8`), CRTC usage, the attribute
  format, the keyboard scan (MAME: keyboard timer driven from hsync, BREAK → NMI),
  timer/FIRQ sources, the ACIA tape path, beeper and IG. Tag every fact with its
  source: [MAME], [EMUB], [CSP], [SVC] (service manual), [ROM] (disassembly).
- [~] (Partly in `ref/notes/emulator-comparison-initial.md`.) Write `ref/notes/mame-vs-emub-verdicts.md` for every point where MAME and
  EmuB disagree, and decide each one from the service manual or a ROM disassembly.
- [ ] Disassemble the boot and BASIC ROM entry points (reset vector, keyboard
  routine, tape load routine), once the user has supplied ROMs.

### 3. Repo and simulation scaffolding
- [x] Start from the FM-7 core layout (or MiSTer Template), with
  `BasicMasterL3.sv`, `rtl/core.v` and `files.qip`. Use a CONF_STR with Load Tape
  (`.l3`), Load Disk (`.d88`) and Model (L3 / Mark II / Mark 5, later S1). System
  ROMs come from `boot.rom` / `boot1.rom` and so on, loaded by HPS; never compile
  them into the RBF.
- [x] Copy the Jr project's Verilator harness (`vsim/`: `--headless`,
  `--screenshot`, `--send-keys`, `--key-hold`, `--watch-pc`, `--dump-mem`, `--poke`,
  `--trace-*`), its `regression.sh` with golden images, and its CSP comparison
  scripts.
- [x] Write a `CLAUDE.md` in the style of the Jr project's.

### 4. Level 3 bring-up (target: the BASIC prompt)
- [x] 6809 (`mc6809is.v`, the synchronous version) at 1 MHz from a clock enable, plus the memory map and ROM/RAM
  views.
- [x] Hook up the CRTC and render 40-column text with attributes; then 80 columns,
  graphics mode, the colour/background register (`$FFD8`) and interlace. Compare
  screenshots against the reference emulator.
- [x] PS/2 → keyboard matrix through `$FFE0`, using the hsync-driven scan timer and
  BREAK NMI. Expect "eats inputs if typed fast", as on the Jr; give the sim a key-hold
  option from day one.
- [x] Timer/FIRQ (MAME raises FIRQ on vblank; check this against EmuB).
- [x] Beeper via `$FFD3`.

### 5. Tape
- [x] An `.l3` loader: the byte stream goes through the ACIA receive path at 600 or
  1200 baud (`$FFD7`), with the motor on `$FFD2`. Reuse the Jr's on-chip tape buffer
  and fast-tape idea, but check how the L3 ROM times bits (ACIA, not software delay
  loops, so fast tape may be easier than on the Jr).
- [x] A converter for `.l3b` / `.l3c` → `.l3` (Python, following WavTool/EmuB), plus a
  checker in the style of `bmtape_info.py`.
- [x] Test with inufuto Mazy and Ascend (L3 builds), MELHEN and Skating.

### 6. Floppy
- [~] MP-1802 (5" 2D, MB8866) done; MP-1805 (3") needs an MC6843, not `wd1793.sv`, plus D88 mounting.
  Both place their boot ROM at `$F800`, so only one can be fitted. Test with the MSS
  Tetris and HI-Writer disks and the `bml3_flop` titles.

### 7. Mark 5 and options
- [x] IG mode (`$FFE9`/`$FFEA`, the `$A000-$A7FF` IG view). Test with MAME's `igdemo`
  cassette.
- [~] PSG cards (6 voices done; 9 voices not), the YM2203 card, kanji ROM, RTC and extra RAM, as
  the software requires them.

### 8. MB-S1
- [x] Choose: a model in the same core (preferred) or a separate core. **Same core.**
- [x] MMU (4 KB pages × 16 registers into a 1 MB space; see `mbs1_mmu.cpp` and
  EmuB-S1), the 2 MHz / 1 MHz switch, and B-mode (L3) versus S1 mode.
- [~] S1 video (done except 640x400 and 64 colours; on-chip BRAM was enough): VRAM, extra planes, palette (MAME ext-I/O `$EFE20-$EFE2F`: BMSK colour, active plane, display page, screen mode, BRG colour, palette at `$EFE28-2F`) and
  the 40/80-column text in S1 mode. RAM is beyond on-chip BRAM once expanded, so plan
  on SDRAM.
- [x] Test with Jelda, Lode Runner and Dezeni Land (all load in vsim; Dezeni Land after the 2026-10-27 l3conv fix). Only EmuB-S1 can show the
  correct behaviour.

### 9. Hardware and testers
- [x] Build RBFs on `misterubuntu` (`ssh misterubuntu`, Quartus at
  `~/intelFPGA_lite/quartus/bin/quartus_sh --flow compile <proj>`). Copy the
  committed tree there with `git archive`.
- [x] Make a tester zip like `~/dev2/BasicMasterJr_tester_20261021`: the RBF, the
  ROM requirements with hashes, `games/<core>/`, and a README with the load commands
  and what to test.

## Lessons from the Jr core (save yourself the time)
- **Cross-check emulators.** MAME was wrong on several Jr points. Keep a verdicts
  file, and prefer the schematic or service manual and ROM disassembly over any
  emulator.
- **The reference emulators had bugs too.** CSP's Jr colour code was off by `$100`.
  When the core and the reference disagree, find out which one is wrong before
  changing anything.
- **Keyboard.** ROM keyboard scans are slow. Injected keys need long holds, and BASIC
  games poll INKEY$ rarely.
- **Monitor commands.** Jr monitor commands end with Space, not Return. Check the
  L3's equivalents.
- **Screenshots.** A screenshot cannot prove a tape loaded correctly. Diff RAM
  against the tape image.
- **CPU timing.** Make CPU timing cycle-exact if the ROM times anything with
  software loops.
- **Regressions.** Run the regression after every RTL change, and never bless
  golden images without looking at them.
