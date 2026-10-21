# Level 3 / MB-S1: BASIC, monitor and power-on behaviour (for testing)

Compiled 2026-10-21 from the manuals downloaded into `ref/docs/` (index: `ref/SOURCES-docs.md`).
Per-source detail, with every page reference, is in `ref/notes/sources/`:
`l3-manuals-basic-monitor.md`, `peach-rom-notes.md`, `s1-manuals.md`, `svc-C.md`, `peach-misc.md`,
`mp1802-tech.md`, `s-sasaji.md`.

Citation keys (page numbers are PDF/image pages unless marked "printed"):

| Key | Document |
|---|---|
| L3UserMan | Hitachi MB-6890 BASIC Master Level-3 User and BASIC Programming Manual (English). Printed page = PDF − 9 |
| L3AsmMan | MB-6890 Assembler Manual 1983 (English). Printed = PDF − 7 |
| L3DiskBasic | MB-6890 Level-3 Disk BASIC Manual (English) |
| PeachROM | Rossell & Viccars, *Peach ROM Notes* rev 2 (1982), "s.X-Y" = printed section page |
| SVC | MB-6890 Service Manual (English, 1981). **Printed** page; image file = printed + 2 |
| S1OpMan / S1BasicMan / S1DiskBasic | MB-S1 operation / BASIC / Disk BASIC manuals (English translations) |
| Calder | P. Calder, *Notes on Hitachi Peach Double Density DOS* (1983) |
| MP1802Tech | MP-1802 / MP-3550 Technical Manual. Image page = printed + 3 |

---

## 1. Power-on

### 1.1 What the screen shows (golden references)

Level 3 cold start goes straight into ROM BASIC; there is no boot menu [L3UserMan p.50].

```
HITACHI LEVEL-3 BASIC Version 1.0
Copyright (c) 1980 by Microsoft
22378 Bytes Free
Ready
_
```

The bytes-free figure depends on the screen mode chosen at power-on by the DIP switches and the
front-panel MODE switch [L3UserMan p.50, Table 3.3]:

| Power-on mode | Bytes free (MB-6890, 32 KB) |
|---|---|
| 40 columns, normal | 29546 |
| 80 columns, normal | 28522 |
| 40 columns, hi-res (factory setting, MODE = 0) | 22378 |
| 80 columns, hi-res (MODE = 1) | 14186 |

- The service manual's RAM check expects exactly this banner with "14186 Bytes Free" in
  80-column hi-res [SVC p.84, see `svc-C.md`]. Use these numbers (and `PRINT FRE(0)`)
  as the first bring-up check [L3AsmMan p.14].
- The prompt is **`Ready`**, not `Ok` [L3UserMan p.36]. Errors print like `Syntax Error in 30`
  [L3UserMan p.66].
- On an MB-S1 in **B mode** (Level-3 compatibility) the banner is the same but reports
  **30570 Bytes Free** [S1OpMan p.38]. S1 A mode prints `HITACHI S1 BASIC Version 1.0 /
  Copyright (c) 1984 By Hitachi, Ltd. / Copyright (c) 1980 By Microsoft / 36K Bytes Free /
  BASIC User Area 36K Bytes / Ready` [S1OpMan p.37].
- DIP switch 1 closed (0) powers up in **terminal mode** instead of BASIC [L3UserMan p.218].
  The full DIP table is in `hardware-from-manuals.md` §9.
- Disk BASIC boot banner (MP-1800 card fitted, system disk in drive 0): `HITACHI LEVEL-3 DISK BASIC
  Version 1.0 / Copyright (c) 1980 By Microsoft / 17944 Bytes Free / Ready` (40-column hi-res).
  Disk BASIC bytes free: 40N 25112, 80N 24088, 40H 17944, 80H 9752 [L3DiskBasic p.17-18].

### 1.2 Cold start, warm start and reset

- Cold start entry `$FAB3` (= `NEW ON`, with the DIP/NEW-ON byte in A); `$FAB0` re-initialises
  with defaults from `$0248` [L3UserMan p.224 Table S.3]; [PeachROM s.6-19].
- Warm start entries `$A438` / `$A3A7` [L3UserMan p.224]. `JMP $A438` returns to BASIC; `JMP $A3A7`
  with B = error number raises an error [PeachROM s.2-5, s.9-1].
- The reset handler checks `$00FD`: if it holds `$55` the reset is a **warm restart** through the
  address in `$00FE-$00FF` (`$EF0E`); anything else is a full cold start that re-initialises memory
  [PeachROM s.A-3, s.6-19]. **Core implication:** the front-panel RESET must reset the CPU without
  clearing RAM; only power-on (or a "cold reset" OSD option) should clear `$00FD`.
- RESET returns to the command level and keeps RAM: after RESET or CTRL-D the assembler can be
  re-entered at `$5006` [L3AsmMan p.75]; [SVC p.6]. CTRL-D is "soft (hot) start"
  [L3UserMan p.17].
- On the MB-S1, the SYSTEM switch (A = S1 BASIC, B = Level-3 BASIC) is read at reset; press RESET
  after changing it. In A mode RESET deletes programs [S1OpMan p.22, p.36]. Power-cycling too fast
  shows nothing; wait 5 s [S1OpMan p.7].
- All interrupt vectors go through RAM `JMP` slots at `$0100-$0111` (NMI via `$0109`), so software
  can hook them [PeachROM s.A-3]; [Phase p.38-39, see `peach-misc.md`].

### 1.3 `NEW ON`

`NEW ON n` restarts BASIC with a new screen mode / VRAM size, the software equivalent of changing the
DIP/MODE switch; it clears the program [L3DiskBasic p.74]; [L3UserMan p.24, p.128]. On the S1,
`NEW ON 0..3` picks graphics vs text mode (36 KB vs 84 KB user area) [S1OpMan p.58-59].

---

## 2. Loading software from tape

### 2.1 Commands

| Command | Meaning | Source |
|---|---|---|
| `LOAD ["CAS0:name"][,R]` | Load a BASIC program; `,R` runs it | [L3DiskBasic p.69-70] |
| `RUN "name"` | Load and run | [L3DiskBasic p.80] |
| `LOADM ["name"][,offset][,R]` | Load machine code at its saved address (+offset); `,R` jumps to the exec address recorded by SAVEM | [L3DiskBasic p.70]; [L3AsmMan p.16, p.81] |
| `EXEC addr` | Call machine code; RTS returns to BASIC. Last exec address is kept at `$0148-$0149` | [L3UserMan p.177, p.225]; [PeachROM s.A-4] |
| `SAVEM "name",start,end,exec` | Save memory | [L3DiskBasic p.82] |
| `LOAD?` | Verify a tape file (checksum) | [L3DiskBasic p.70] |
| `SKIPF ["name"]` | Skip to a named file | [L3DiskBasic p.72] |
| `MOTOR [ON/OFF]` | Cassette relay (`$FFD2` bit 7) | [L3DiskBasic p.73]; [PeachROM s.6-18] |
| `CLEAR str,top` | Reserve memory above `top` before loading machine code, e.g. `CLEAR 300,&H4EFF` | [L3UserMan p.176]; [L3AsmMan p.74] |

A session looks like this (the ROM turns the motor relay on itself) [L3AsmMan p.73, p.75]:

```
LOADM "ASM9"
Searching          <- recorder in PLAY
Found: ASM9
Ready
```

- `CTRL-D` aborts a cassette search [L3DiskBasic p.69]. A read error reports `Device I/O Error`
  [S1OpMan p.65-70].
- Under Disk BASIC the default device is drive 0, so tape needs an explicit `"CAS0:"`
  [L3UserMan p.154].
- File names are up to 8 characters [S1BasicMan p.45].
- Typical machine-code game loader: `CLEAR 300,&H....` then `LOADM "",,R` (or `LOADM` then
  `EXEC &H....`). Most BASIC games: `LOAD "",R` or `RUN ""`.

### 2.2 Tape format as the ROM writes it

From the ROM commentary [PeachROM s.3-12 to 3-14]; see `hardware-from-manuals.md` §7 for the
electrical side.

1. Leader of `$FF` bytes (at least 6 are needed on input; the count written is `[$0119]` if the
   motor was already on, `[$011A]` if it was just switched on).
2. Sync `$01 $3C`.
3. Block type: `$00` header, `$01` data, `$FF` trailer.
4. Length byte (data blocks up to 255 bytes; header is `$14`; trailer 0).
5. Data.
6. Checksum: sum mod 256 of the block from the type byte onward (whether `$01 $3C` is included is
   unconfirmed).
7. Five `$00` bytes written after each block, not read.

Header data (`$14` = 20 bytes): 8-byte name, file type (0 BASIC, 1 data, 2 machine code), file
format (0 binary, `$FF` ASCII), a second format/gap byte, 9 nulls. This matches the `.l3` byte
streams described in `TODO.md`. For ASCII/data files the motor stops between blocks
[PeachROM s.3-14].

Serial framing: 1 start, 8 data, 2 stop bits, ACIA setting "S8N2" (`$12`)
[PeachROM s.3-12]; [S1OpMan p.123].

---

## 3. Booting a disk

- **Level 3:** there is no boot command. With an MP-1800/1801/1802 card fitted, the card's boot ROM
  overlays `$F800-$FEFF` (via /ROM-KIL) and the ROM's reset path runs it. Power the drive on, insert
  the system disk in drive 0, then power on the Level 3; `Ready` appears after one or two seconds
  [L3UserMan p.152-154]; [L3DiskBasic p.17-18]; [MP1802Tech, see `mp1802-tech.md`].
- Calder's DD DOS notes: the card boot code is called from `$FB5E`, loads track 0 sectors 1-2 to
  `$4400`, then the DOS from track 1 into `$8800-$9FFF` (so Disk BASIC needs RAM at `$8000+`)
  [Calder, see `peach-misc.md`]. Disk BASIC MA-5320 needs 40 KB RAM [MP-1802 sheet p.1-2].
- The early SSSD Disk BASIC auto-runs the file with a blank name by executing `COLOR 0,0` and
  `R.""` at initialisation [PeachROM s.8-4].
- Disk formats: Disk BASIC MA-5300 disks are 40 tracks × 16 sectors × 128 bytes with the directory
  on track 20 [L3DiskBasic]. MP-1802 2D: 40 tracks × 2 sides × 16 sectors, 128-byte FM / 256-byte
  MFM sectors; Calder's DD DOS keeps track 0 side 0 single density [MP1802Tech]; [Calder].
- If the boot fails: check the card is in I/F-1, the disk is in, the motor lamp is on, and the drive
  was powered first [L3DiskBasic p.18].
- Utilities on the system disk: `FORMAT`, `DSKINI drive`, `CONFIG`, `DISKCOPY`
  [L3DiskBasic p.20-22].
- **MB-S1 A mode:** same procedure; without a system disk it shows "Insert Program Diskette" and
  waits [S1OpMan p.74]; [S1DiskBasic p.9-11].

---

## 4. The machine-language monitor (`MON`)

### 4.1 Level 3

- `MON` enters the ROM monitor (code at `$DCE6`, input via `$EF55`); the prompt is **`*`**. It
  returns to BASIC only on **BREAK** (or CTRL-C / CTRL-D) [L3DiskBasic p.73]; [L3UserMan p.175-177];
  [PeachROM s.6-18].
- Commands documented in the English manuals [L3UserMan p.176]; [L3AsmMan p.15, p.78-79]:

| Command | Function | Example |
|---|---|---|
| `M addr` | Memory display/modify: shows `6002 00-`, type hex bytes in sequence | `*M6002` |
| `D addr` | Dump | `*D6000` |
| `G addr` | Go | `*G5000` (assembler), `*G7000` (debugger) |

- Whether M/D/G are terminated by Return or Space is not stated (the Jr's monitor used Space; check
  in the reference emulator). A fuller list is expected in the Japanese Level-3 BASIC manual, which
  has not been found.
- The disk/tape DEBUG program (`DEBUG70` at `$7000`, `DEBUG5A` at `$5A00`) has its own M, D, B, G,
  R, S, C, F, T, E, A commands; it is not the ROM monitor [L3AsmMan p.5].

### 4.2 MB-S1 A mode

`MON`, prompt `*`; subcommand format `<name> <op1>,<op2>,...` in hex. Commands: B/BL/BP
(breakpoints via SWI), D/DL, E (screen editor), F (fill), G, H (hex sum/difference), HC (hard copy),
M/ML, MAP/MAPL/MAPP (memory-area map images), Q (quit), R/RL/RP (registers), S (search),
T (transfer), TS, X/XL/XP [S1BasicMan p.157-169]. `DEF MAP = 0..3` chooses the "machine language
space" used by MON, LOADM, SAVEM, EXEC, PEEK, POKE and USR [S1BasicMan p.89].

---

## 5. Small test programs taken from the manuals

| Purpose | Program | Source |
|---|---|---|
| Colour RAM + VRAM write | `SCREEN0:WIDTH80:POKE &HFFD8,&H84:POKE &H0400,&H41` gives a green "A" top left | [L3UserMan p.144-145] |
| Whole character set, three colours | `SCREEN0:WIDTH40`, then `POKE &HFFD8,&H84/&H89/&H92` and `POKE &H400+I,I` / `&H500+I` / `&H600+I` for I = 0-255 | [L3UserMan p.145-146] |
| Hi-res raster layout | `SCREEN1:WIDTH80:FOR I=0 TO 7:POKE &HFFD8,&H84:POKE &H400+I*&H800,&H41:NEXT` | [L3UserMan p.150] |
| Beeper | `FOR I=0 TO 20:POKE &HFFD3,0:POKE &HFFD3,255:NEXT` | [L3UserMan p.170] |
| Beeper (machine code at `$6002`) | `B6 60 00 C6 00 F7 FF D3 F6 60 01 5A 26 FD C6 FF F7 FF D3 F6 60 01 5A 26 FD 4A 26 E7 39`, then `POKE &H6000,255:POKE &H6001,60:EXEC &H6002` | [L3UserMan p.176-177] |
| Timer mask | `POKE &HFFD4,255` stops TIME$, `POKE &HFFD4,0` restarts it | [L3UserMan p.169]; [SVC] |
| Raw keyboard | `POKE &HFFE0,&H0C` then loop `PRINT PEEK(&HFFE0)`: Space 128, ↑ 129, ← 131, ↓ 132, → 133. Restore with `POKE &HFFE0,&HF0` | [L3UserMan p.167-168] |
| ROM checksum (service manual "ROM-C") | Sums `$A000-$FEFF` + `$FFF0-$FFFF`; a good v1.0 set gives A = 18, B = 178 | [SVC p.109, see `svc-C.md`] |
| Keyword table | Reserved words start at `$A078` (bit 7 ends each word) | [L3UserMan p.247]; [PeachROM s.2-4] |

---

## 6. Other BASIC facts useful for testing

- `WIDTH 40|80`; `SCREEN mode,page,interlace` (mode 0 normal, 1 hi-res; interlace 0 = on)
  [L3UserMan p.126-127]; `COLOR fg[,bg]`; `CONSOLE`; `LOCATE x,y[,cursor]`; `CLS`; graphics
  commands use X 0-639, Y 0-199 in every mode [L3DiskBasic p.51].
- Function keys default to PF1 `LOAD↵`, PF2 `?DATE$,TIME$↵`, PF3 `KEY`, PF4 `LIST↵`, PF5 `RUN↵`,
  PF6 `TERM`, PF7 `SCREEN`, PF8 `COLOUR`, PF9 `LIST"LPT0:"↵`, PF10 `CONT↵` [L3UserMan p.19].
- Device names: `KYBD:`, `SCRN:`, `LPT0:`, `COM0:`, `CAS0:`, `0:`-`3:` [L3UserMan p.56].
- BASIC work area: program start `$001D`, variables `$001F`, arrays `$0021`, free `$0023`, stack
  `$0025`, program end `$002B`, EXEC address `$0148`, USR table `$014A-$015D`, key buffer pointer
  `$01CA`, cassette buffer pointer `$01D0` (255-byte buffer), file name `$01FE-$0205`
  [L3UserMan p.225 Table S.4]; [PeachROM App. A]. For reading a loaded BASIC program out of RAM,
  take the start/end from `$001D`/`$002B`.
- Screen RAM starts at `$0400`; its end, and so BASIC's start, moves with the screen mode
  (`$07FF`, `$0BFF`, `$23FF` or `$43FF`) [PeachROM s.5-1, s.5-3].
- ROM routines: character in `$E804`, character out `$E820`, CLS `$F160`, cursor move `$F13C`,
  BEEP `$F7A7` (click `$F7A9`), MOTOR on/off `$EE64`/`$EE67`, LOAD/LOADM `$E6D4`, SAVEM `$E5AD`,
  SKIPF `$E2D1` [PeachROM s.6, App. A].
- Error codes: 2 Syntax Error, 7 Out Of Memory, 53 Device I/O Error, 63 File Not Found,
  72 Drive Not Ready, etc. [L3DiskBasic p.149-153].
