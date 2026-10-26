Hitachi Basic Master Level 3 / Mark 5 / MB-S1 -- MiSTer core, tester build 2026-10-24
==================================================================================

PRIVATE TESTER PACKAGE. It contains the system ROMs and commercial software.
Please do not redistribute it.

Core build: f3f5c82. This is the first hardware build with the MB-S1 model, SD-card
tape streaming and the PSG card. Earlier builds were tested on a MiSTer (L3 boot,
keyboard, tape, MP-1802 disk). This one has only been tested in simulation.

INSTALL
-------
  _Computer/BasicMasterL3_20261024.rbf  ->  /media/fat/_Computer/
  games/BasicMasterL3/                  ->  /media/fat/games/BasicMasterL3/
                                            (boot0.rom must be in this folder)

OSD
---
  Mount Tape (.l3)       Cassette image. The motor relay controls playback.
  Fast tape              Off / 2x / 4x / 8x ... Off or 2-4x is safest.
  Model                  Mark 5 / Level 3 / MB-S1  (changing it resets the machine)
  S1 SYSTEM switch       (MB-S1 only) A = S1 mode, B = Level 3 compatible
  Floppy card            Auto (default): the MP-1802 card is fitted at reset only if
                         drive 0 has a disk mounted. MP-1802: always fitted. None.
                         Mount the .d88, then reset.
                         Note: an MB-S1 in S1 mode with the card fitted and no system
                         disk shows "Insert Program Diskette" and waits forever. The
                         real machine does the same. Auto avoids it.
  Keyboard               US symbols (type what is on your keyboard) / Positional (JIS)
  Expansion RAM, PSG card, Interlace, Border, Scandoubler, Aspect

  The keyboard is paced (about 9 characters/s), so the ROM sees every key. Typing
  quickly while the machine is busy can still drop keys, as on the real machine.

LOADING
-------
  BASIC reaches "Ready" a second or two after reset. Mount the tape first, then type:

  inufuto games (Tape - Level 3 / Mark 5 / MB-S1):   LOADM"",,R
      Use the Mark 5 builds with Model = Mark 5 and the (S1) builds with Model = MB-S1
      and SYSTEM switch A. The plain builds run on every model.

  Hudson (Cannon Ball, Bomber Man), MELHEN:   LOAD   then   RUN

  BM Tetris / BM Block (Mark 5):   LOAD, RUN   (IG character setter)
                                   LOADM       (character data)
                                   LOAD, RUN   (the game)
      LOAD"",R can drop a character, so type LOAD and RUN separately.

  Skating (Mark 5):   Skating 1: LOAD, RUN.  Then Skating 2: LOAD, RUN.

  MB-S1 commercial tapes (Model MB-S1, switch A):   LOAD   then   RUN
      Jelda                      works in simulation (title and story screens)
      Lode Runner (1 then 2)     reaches its COMMAND screen in simulation
      Dezeni Land                KNOWN BROKEN: hangs on "Loading" (converter problem)
      Volguard, Nuts & Milk, Mario Bros Special, Princess Tomato
                                 converted but never run. Please report what happens.

  Tape - Tests: 12lines/50lines reprogram the CRTC for 12 or 50 text rows; 25lines
  restores. Type NEWON7 first, then LOAD, RUN.

  Disks (Disk - MP-1802): mount tetris.d88 in drive 0, then reset (Floppy card = Auto).
  It boots LEVEL-3 DISK BASIC. Then:   RUN"TETRIS"
  tetris.d88 runs on hardware. The other disks are untested.

WHAT TO REPORT
--------------
  - The MB-S1 model: boot banner, typing, LINE/CIRCLE, the S1 games
  - Tape: loading from the SD card at real time and at fast tape speeds
  - The PSG card / S1 sound
  - Video: picture position and size on your display, with and without Border/Interlace
  - Anything that differs from a real machine or from EmuB

  With each report, include the model, the OSD settings and what you typed.

KNOWN ISSUES
------------
  - Cassette SAVE is not implemented.
  - MB-S1: no 640x400, 64-colour or user mode yet. Mazy (S1) score digits may be
    clipped at the right edge.
  - No MP-1805 (3" floppy) and no kanji card.
