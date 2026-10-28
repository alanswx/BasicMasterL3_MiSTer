Hitachi Basic Master Level 3 / Mark 5 / MB-S1 -- MiSTer core, tester build 2026-10-26
==================================================================================

PRIVATE TESTER PACKAGE. It contains the system ROMs and commercial software.
Please do not redistribute it.

Core build: fd3e6f3. Tested on a MiSTer: Level 3 / Mark 5 and MB-S1 boot, typing,
reset and model changes, tape loading at 16x (Aerial on the MB-S1). New in this build:
the OSD follows the MiSTer computer-core standard (see OSD below), Tape speed 16x by
default, and a tape status bar.

INSTALL
-------
  _Computer/BasicMasterL3_20261026.rbf  ->  /media/fat/_Computer/
  games/BasicMasterL3/                  ->  /media/fat/games/BasicMasterL3/
                                            (boot0.rom must be in this folder)

OSD
---
  The menu follows the MiSTer computer-core OSD standard. Settings take effect at the
  next reset: change them, then choose "Apply and reset" (the menu shows "Changes
  pending" until you do). Media, Keyboard and the tape rows act at once.

  Top page
    Pri. disk 0, Disk 1 (.d88)  MP-1802 drives. Remembered across core loads.
    Tape (.l3)             Cassette image, rewound on every mount. Not remembered.
                           The motor relay controls playback.
    Load ROM               Another boot0.rom for this session (the default is
                           games/BasicMasterL3/boot0.rom).
    Memory                 64K (expansion RAM) / 32K (stock MB-6890)
  Machine
    Model                  Mark 5 / Level 3 / MB-S1
    S1 SYSTEM              (MB-S1 only) A = S1 mode, B = Level 3 compatible
    Floppy card            Auto (default): the MP-1802 card is fitted at reset only if
                           disk 0 has an image. MP-1802: always fitted. None.
                           Note: an MB-S1 in S1 mode with the card fitted and no system
                           disk shows "Insert Program Diskette" and waits forever. The
                           real machine does the same. Auto avoids it.
    PSG card               On / Off
    Tape speed             16x (default) / Normal. Acts the next time the motor runs.
    Rewind tape            Back to the start of the tape.
  Video
    Interlace, Border, Scandoubler Fx, Aspect ratio
    Tape overlay           On: "TAPE > 0:07/ 2:12 x16" and a progress bar at the bottom
                           left while the motor runs.
  Input
    Keyboard               US symbols (type what is on your keyboard) / JIS layout

  The keyboard is paced (about 9 characters/s), so the ROM sees every key. Typing
  quickly while the machine is busy can still drop keys, as on the real machine.

LOADING
-------
  BASIC reaches "Ready" a second or two after reset. Mount the tape first, then type
  the command in the file name:

  (LOADM)          LOADM"",,R          machine code: the inufuto games
  (LOAD, RUN)      LOAD   then   RUN   BASIC programs and the commercial games
  Using the wrong one gives "Bad file mode" (LOAD on a machine-code tape, or
  LOADM on a BASIC tape).

  Use the (Mk5) builds with Model = Mark 5 and the (S1) builds with Model = MB-S1
  and SYSTEM switch A. The plain builds run on every model.

  BM Tetris / BM Block (Mark 5):   LOAD, RUN   (IG character setter)
                                   LOADM       (character data)
                                   LOAD, RUN   (the game)
      LOAD"",R can drop a character, so type LOAD and RUN separately.

  Skating (Mark 5):   Skating 1: LOAD, RUN.  Then Skating 2: LOAD, RUN.

  MB-S1 commercial tapes (Model MB-S1, switch A), all LOAD then RUN. In simulation:
      Jelda                      title and story screens
      Lode Runner (1 then 2)     COMMAND screen
      Nuts & Milk                title screen
      Mario Bros Special         title screen
      Princess Tomato 1          title screen
      Dezeni Land 1              loads; asks to load data from tape (Y or N)
      Volguard                   starts loading (a 32-minute tape: about 2 at 16x)
  Nuts & Milk, Mario, Princess Tomato and Dezeni Land were broken in earlier zips (a
  tape-conversion bug), so their tapes in this zip are new.

  Tape - Tests: 12lines/50lines reprogram the CRTC for 12 or 50 text rows; 25lines
  restores. Type NEWON7 first, then LOAD, RUN.

  Disks (Disk - MP-1802): mount tetris.d88 as disk 0, then Apply and reset
  (Floppy card = Auto).
  It boots LEVEL-3 DISK BASIC. Then:   RUN"TETRIS"
  tetris.d88 runs on hardware. The other disks are untested.

WHAT TO REPORT
--------------
  - The MB-S1 model: boot banner, typing, LINE/CIRCLE, the S1 games
  - Tape: loading at 16x and at Normal; the tape overlay. If a tape loads at Normal
    but not at 16x, please say which tape, which Model, and what is on the screen.
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
