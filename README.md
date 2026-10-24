# BasicMasterL3_MiSTer

A MiSTer FPGA core for the **Hitachi Basic Master Level 3** family (MB-6890 Level 3,
MB-6891 Mark II, MB-6892 Mark 5) and the **Hitachi MB-S1**, in one core. The OSD "Model"
option selects Mark 5, Level 3 or MB-S1. Licence: GPL v2 (see `LICENSE`).

Work in progress. `TODO.md` is the status and handoff document; `CLAUDE.md` describes the
code layout, the simulator and the build.

## Status

| Area | State |
|---|---|
| Level 3 / Mark 5: BASIC, keyboard, 40/80-column text, colour, graphics, Mark 5 IG | Works in simulation and on a MiSTer |
| Cassette load (`.l3`, streamed from SD, real time or fast) | Works in simulation and on a MiSTer |
| MP-1802 5" floppy card (D88) | Works in simulation and on a MiSTer |
| 6-voice PSG card | Works in simulation |
| MB-S1 (S1 mode and Level 3 mode, mapper, S1 display, built-in PSG) | S1 BASIC and several games run in simulation; not yet tried on a MiSTer |
| Cassette SAVE, MP-1805 3" floppy, 9-voice PSG, kanji ROM, S1 640x400 and 64-colour modes | Not done |

## Using it

- Copy the RBF to `_Computer/`.
- Put `boot0.rom` in `games/BasicMasterL3/`. It is built from MAME's `bml3`, `mbs1` and
  `bml3mp1802` ROM sets, laid out as `rtl/core.v` describes. ROMs are not distributed here.
- Mount a `.l3` tape image with "Mount Tape", then type `LOADM"",,R` (machine code) or
  `LOAD` and `RUN` (BASIC). `software/tools/l3conv.py` converts `.l3b`/`.l3c` images to
  `.l3`.
- For disks, turn on "Floppy card", mount a `.d88` and reset.

## Thanks

The behaviour follows Sasaji's EmuB-6892 and EmuB-S1 emulators. The 6809 is the
Vectrex-development `mc6809is`, the FDC is `wd1793.sv` from the FM-7 core, and the PSG
is jotego's `jt49`.
