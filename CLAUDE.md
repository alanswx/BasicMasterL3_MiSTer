# CLAUDE.md

Guidance for Claude Code when working in this repository.

## What this is

A MiSTer FPGA core for the **Hitachi Basic Master Level 3** (MB-6890 / MB-6891 Mark II /
MB-6892 Mark 5): MC6809 at 1.008 MHz, HD46505 CRTC, 40/80-column text with a colour RAM,
320/640×200 graphics, Mark 5 IG (programmable characters), cassette through an ACIA.
The **MB-S1** is the third model in the same core (OSD "Model"; the S1 SYSTEM switch picks
S1 mode or Level 3 mode). **TODO.md** is the status and handoff; `ref/notes/` holds the
research (`mbs1-implementation-spec.md` for the S1). Repo:
<https://github.com/alanswx/BasicMasterL3_MiSTer> (public).

Level 3 BASIC boots to `Ready` in vsim and on a MiSTer; the keyboard works, `.l3` tapes
load byte-exact, the MP-1802 floppy boots D88 disks (vsim), Mark 5 IG works, and there is a
6-voice PSG card. The MB-S1 boots S1 BASIC and runs several games in vsim, but has not
been run on hardware yet.

Target is real hardware: clock enables, not gated clocks; no unsynthesisable constructs.

## Layout

```
BasicMasterL3.sv      MiSTer top (hps_io, PLL, tape buffer, video_mixer)
rtl/core.v            6809, memory map/banking, system I/O, keyboard scanner, timer, PIA
rtl/crtc6845.v        HD46505 (EmuB counting, incl. interlace sync & video mode)
rtl/video.v           VRAM/colour RAM -> font / graphic / IG -> pixels (Level 3)
rtl/s1video.v         MB-S1 S1-mode display: text + 7-bit colour RAM over 3 planes, palette
rtl/acia6850.v        ACIA, byte level
rtl/tape.v            .l3 player: one byte per 11 bit times into the ACIA, streamed from
                      block device 2 a sector at a time
rtl/keyboard.v        PS/2 -> Level 3 key codes, US-symbol translation, paced event queue
rtl/mp1802.v          MP-1802 floppy card (MB8866 via wd1793.sv, $FF00-$FF07, boot ROM)
rtl/wd1793.sv         FDC core from FM-7_MiSTer (D88/D77 sector-table scan); wd_dpram.v
rtl/psg6.v            6-voice PSG card ($FF30-$FF33 PIA + 2x jt49 in rtl/jt49/)
rtl/mc6809is.v        synchronous 6809 (Vectrex-development copy, rev 1.1 fixes)
rtl/dpram.v           behavioural dual-port RAM (Quartus infers M10K)
vsim/                 Verilator harness (derived from the Basic Master Jr core)
ref/notes/            hardware notes, emulator comparison, translated EmuB docs
roms/                 system ROMs (not in git; see roms/README.md)
software/             test software index (README.md), tools/ (l3conv.py, make_tester_zip.sh),
                      tester/README.txt; the software itself is not in git
```

Not in git (see `.gitignore`): `roms/`, `ref/{emulators,hardware,web,docs}`, the software
archives. They are local research copies.

## Clocks

`clk_sys` = **32.256 MHz**, the machine's crystal, in both the real top and the sim. A
5-bit phase counter in `core.v` makes everything else: CPU E = clk/32 (`fallE` at phase 0,
`fallQ` at 24), CRTC character clock = clk/32 (40 col) or clk/16 (80 col), pixel enable =
clk/2. CPU memory writes and read side effects happen on `fallE`, the end of the bus cycle.

## Simulation (vsim/)

```bash
cd vsim/
make
./obj_dir/Vemu --headless --text 120 --screenshot 120 --stop-at-frame 121
./obj_dir/Vemu --headless --send-keys '130:PRINT 12*3+4\n' --text 260 --stop-at-frame 261
./obj_dir/Vemu --headless --tape ../software/found/inufuto/mazy/l3/mazy.l3 --tape-speed 2 \
    --send-keys '130:LOADM"",,R\n' --trace-tape --screenshot 2300 --stop-at-frame 2301
./obj_dir/Vemu --help
```

* Frames are **1/60 s of simulated time** from power-on (not video frames), so they work
  before the CRTC is programmed. BASIC reaches `Ready` by about frame 82.
* Speed is about 19 frames/s.
* `--rom` defaults to `../roms/mister/boot0.rom` (160K: L3 BASIC `$0000`, MP-1802 `$6000`,
  font `$8000`, S1 BASIC/ROMs from `$10000`; see the comment at the top of `rtl/core.v`),
  loaded over ioctl index 0 just like MiSTer's `boot0.rom`.
* `--text N` prints `$0400` as 40×25 ASCII. In hi-res modes that is raster plane 0.
* `--tape file.l3` mounts block device 2 (`software/tools/l3conv.py` makes .l3 from
  .l3b/.l3c). `--model s1` (`--s1mode b`) runs the MB-S1.
* `--disk file.d88` (and `--disk1`) mounts disks and fits the MP-1802; `--fdc` fits it
  empty. `--ram32k` = stock MB-6890 memory, `--border`, `--interlace`, `--model l3`,
  `--keyboard jis` (positional) mirror the OSD options.
* `--trace-io` prints every `$FF00-$FFEF` access with the PC. `--trace-key` prints
  scanner latches.
* Typing: keys go through rtl/keyboard.v's queue, paced so the ROM sees each change
  (about 9 characters/s). Typing while the ROM is busy (e.g. finishing a tape load) can
  still lose keys, as on the real machine.

## Hardware reference

Behaviour follows **EmuB-6892** (`ref/emulators/EmuB-6892/src/source/src/vm/bml3mk5/`),
the best reference (see `ref/notes/emulators.md`). The service manual digest is
`ref/notes/hardware-from-manuals.md`. MAME's `bml3` is a second opinion only: it is
NOT_WORKING and gets several things wrong (see `ref/notes/emulator-comparison-initial.md`).

Key behaviours worth knowing before changing anything:

* Colour RAM: a CPU write to `$0400-$43FF` stores the colour register (`$FFD8`) into colour
  RAM; a CPU read loads it back into the register unless MK (bit 7) is set.
* Keyboard: hardware counter stepped per HSYNC, two steps per code; it stops on a pressed
  key until `$FFE0` is read; `$FF` is reported once after the last release.
* Timer: FIRQ on every CRTC VSYNC, flag at `$FFCA` (read clears), mask `$FFD4` bit 7.
* Normal ROM text mode is **interlace sync & video** (R8 = `$83`, R9 = 14) with `$FFD6`
  IS = 1. The CRTC generates only the even field, progressively.

## Hardware builds

Build on `misterubuntu`: copy a `git archive` of HEAD there, then
`~/intelFPGA_lite/quartus/bin/quartus_sh --flow compile BasicMasterL3`.
Test on a MiSTer with `/Applications/MiSTerKVMS.app/Contents/MacOS/misterkvms-cli`
(`load-core`, `screenshot`, `type`, `key`). `boot0.rom` goes in `games/BasicMasterL3/`.

* Keep finished RBFs as `releases/BasicMasterL3_<hash>.rbf` (git-ignored).
* `load-core` in misterkvms-cli fails (ssh key). Instead, `scp` the RBF to the MiSTer and
  write `load_core <path>` to `/dev/MiSTer_cmd` over ssh.
* The test MiSTer is shared. Ask the user before loading anything on it.
* Tester zip: `software/tools/make_tester_zip.sh releases/<rbf> software/tester/README.txt`
  writes `releases/BasicMasterL3_tester_<date>.zip`. It contains ROMs and commercial
  software: give it to named testers only, and never attach it to a public release.
  Update `software/tester/README.txt` (load commands, what works) with each zip.

## Conventions

* RTL style: terse, lower-case, two-space indent in `rtl/`; tabs in `BasicMasterL3.sv` and
  `vsim/`.
* New hardware findings go in `ref/notes/` with a source tag, not scattered in comments.
* When you fix something TODO.md lists, update TODO.md.
