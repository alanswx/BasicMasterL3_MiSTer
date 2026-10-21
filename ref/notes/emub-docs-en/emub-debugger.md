# EmuB debugger (debugger.txt) — English translation

Sources: `ref/emulators/EmuB-6892/src/docs/debugger.txt` (translated in full) and
`ref/emulators/EmuB-S1/src/docs/debugger.txt` (its additions are in the last part).
The debugger exists only in "debugger builds" (`Makefile.*_dbgr`, `_DEBUGGER` define).

**Why this matters for the MiSTer project:** the debugger is a telnet console
(`localhost:54321`) with memory dump/load, breakpoints, traces with cycle counts, an
interrupt-source display, `! key` and `! reset` commands, and a BASIC-level debugger. It
can drive the emulator from a script, which partly covers the "scriptable reference"
need in TODO.md section 1. The interrupt-source table at the end is direct evidence of
how EmuB wires NMI/IRQ/FIRQ.

## About the debugger

Start it with Options -> Start Debugger (or Alt+D). Starting it pauses the emulator. On
Windows a console window opens; on other systems you connect with a telnet terminal:

- macOS: open Terminal and type `telnet localhost 54321`. (telnet is not installed on
  10.13 and later; use an App Store app or Homebrew.)
- Linux: `telnet localhost 54321` from GNOME Terminal, Konsole, xterm, etc.
- Windows: Tera Term or PuTTY to host `localhost`, port `54321`.

The host name and port can be set on the Configure dialog's Network tab or in the
`[debugger]` section of `bml3mk5.ini` (`mbs1.ini`). To connect from a remote host set
`ServerHost` to `0.0.0.0` (and open the firewall).

## Commands, general

The prompt is `MC6809 - `. `?` lists the commands; `? <command>` or `<command> ?` gives
details. Numbers are hexadecimal; prefix `%` for decimal (with some exceptions). Up/down
arrows recall history.

## Command list

- **D** `[<start> [<end>]]` — dump memory (128 bytes if no end).
- **DP** `[<type> [<start> [<end>]]]` — dump physical memory. Types: 0 main RAM, 1
  extended RAM, 2 colour RAM, 3 IG RAM (blue), 4 IG RAM (red), 5 IG RAM (green). In main
  RAM, `ff00-ffef` is the I/O ports; some ports that are normally unreadable can be read
  here.
- **E, EB, EW, ED, EA** — edit memory: `E[{B,W,D}] <address> <value> [...]` (E/EB 1 byte,
  EW 2 bytes, ED 4 bytes); `EA <address> "<string>"`.
- **EP, EPB, EPW, EPD, EPA** — the same on physical memory, with a `<type>` as for DP.
- **R** `[<reg> <value>]` — show/edit CPU registers A, B, DP, CC, X, Y, S, U, PC.
- **RD** `<device> [{<regno>|<regname>} <value>]` — show/edit a device's registers or
  internal state. Devices with registers: `PIA, ACIA, CRTC, KEYBOARD, CMT, TIMER, FDC3,
  FDC5, FDDUNIT, BOARD, PIAPSG, PSG60, PSG61, VIAPSG, PSG90, PSG91, PSG92, PIAEX, ACIAEX,
  PIAEX2, RTC, MSM58321`. State only: `FDDINFO, FDD0, FDD1, FDD2, FDD3, EVENT`. The
  register number is the index shown in the listing.
- **M** — show the current memory map (bank-switching state).
- **S, SB, SW, SD, SA** — search memory: `S[{B,W,D}] <start> <end> <list>`;
  `SA <start> <end> "<string>"`. ESC aborts.
- **SP, SPB, SPW, SPD, SPA** — search physical memory (with `<type>`).
- **U** `[<start> [<end>]]` — disassemble (16 steps by default).
- **UP** `<type> [<start> [<end>]]` — disassemble physical memory.
- **SL** `[<address> <label>]` — register/show symbol labels (16-bit address, up to 16
  ASCII chars).
- **SLL** `<file> [R|TSC]` — load labels from a file (replaces all). Default line format
  `address label address label ...`; `R`: `label address ...`; `TSC`: `label type address
  ...` (type ignored). Separators: space, tab, comma, semicolon.
- **SC** `{*,ALL,<address>}` — delete labels.
- **H** `<v1> <v2>` — show sum and difference.
- **DN** `[<filename>]` / **DL** `<start> [<end>]` (or `DL <offset>` for Intel HEX /
  Motorola S) / **DS** `<start> <end>` — dump file name (default `debug.bin`), load from
  file, save to file. Format by extension: `.hex` Intel HEX, `.s`/`.mot` Motorola S,
  otherwise binary. For HEX/S records the address comes from the file.
- **DPL** / **DPS** — the same on physical memory (with `<type>`).
- **DIS** `<type>` — save memory as an image: 0 IG RAM (all), 1 IG blue, 2 IG red, 3 IG
  green. File `YYYY-MM-DD_HH-MI-SS_NN.bmp`/`.png` in the snapshot path.
- **DDIS** `<type>` — save memory as a text file of colour numbers.
- **G** `[{<address>,<sign>}]` — continue. `n`/`N` = step over (run until a called
  subroutine returns). Giving an address/sign adds it as a breakpoint and disables all
  other break/trace points. ESC stops.
- **T** `[<count> [<skip>]]` — trace (disassembling) while executing; with a skip count,
  executes `<skip>` instructions then traces one (total = count x (skip+1)). ESC stops.
- **TB** `[<count>]` — traceback: show recently executed instructions (max 1000,
  default 25).
- **RS** / **RH** — show / hide CPU registers during trace.

### Breakpoints and tracepoints

A breakpoint stops when its condition matches; a tracepoint traces the instruction
without stopping.

- **BP** — stop before the CPU fetches the opcode at the address.
- **RBP** — stop after the CPU reads memory at the address.
- **WBP** — stop after the CPU writes memory at the address.
- **NBP** — stop when an interrupt occurs.
- **TP / RTP / WTP / NTP** — the same, but trace.

Syntax: `{B,T}P [{<address(es)>,<sign>} [<expression>]]`;
`{R,W}{B,T}P [<address(es)> [<value>]]`; `N{B,T}P [<signal> [<switch>]]`.
Addresses can be a range `start-end`. Sign `.` = current address (next instruction);
`n`/`N` = the address after the next instruction. Expression `<reg>=<value>` stops only
when the register matches. Value may be `value&mask`; for reads the read value, for
writes the written value must match. Signal: `RESET, NMI, IRQ, FIRQ, HALT`; switch `ON`
(default, when asserted), `OFF` (when released), `CHG` (on change). Without arguments the
list is shown. Up to 64 of each can be registered and 8 of each enabled at once.

- **BC/BD/BE, RBC/RBD/RBE, WBC/WBD/WBE, NBC/NBD/NBE, TC/TD/TE, RTC/RTD/RTE, WTC/WTD/WTE,
  NTC/NTD/NTE** — suffix C deletes, D disables, E enables:
  `[{R,W,N}]{B,T}{C,D,E} [{*,ALL,<list>}]` (indices in decimal).
- **BL** / **TL** — list all breakpoints / tracepoints.

### Other

- **CL** — show the current clock count and elapsed time.
- **>** `[<filename>]` — open/close a log file (`CLOSE` closes; no argument shows the name).
- **PWD**, **CD** `<path>`, **DIR**/**LS**.
- **!** — send a command to the VM: `! reset [all,cpu]` (restart / power-on reset);
  `! key <code> [<msec>]` (send a key code, optionally held for msec).
- **Q** — quit the debugger.

### BAS — LEVEL-3 BASIC debugger

- **BAS VAR** `[<names> ...]` — list BASIC variables (incl. arrays) and values.
- **BAS LIST** `[<lines>]` — list the BASIC program; decimal line numbers, ranges
  `a-b`, `.` = current line. Non-ASCII/non-half-width-kana show as `.`; kana need a
  Shift-JIS terminal. After adding extended BASIC commands, run BAS COMMAND to reload the
  keyword list.
- **BAS BP** / **BAS TP** `[<lines>]` — break / trace when the BASIC line number matches.
  Setting one turns trace on automatically. A line that loops onto itself only matches
  once on entry.
- **BAS BC/BD/BE, BAS TC/TD/TE** `{*,ALL,<list>}` — delete/disable/enable.
- **BAS TB** — list the recently executed BASIC lines (up to 64).
- **BAS TRON / BAS TROFF** — show/hide the BASIC line at break/trace points and on pause.
- **BAS COMMAND** — read the BASIC keyword table from memory and list it (cached).
- **BAS ERROR** `[<n>]` — show error message n, or the last error.

## Trace disassembly format

```
  [a]- [b]----------- [c]--------------- [d]  [e]
  23AB B7 FF D0       STA $FFD0          ( 3) (W FFD0:04)                <-[1]
DP:00 A:04 B:03 X:0F84 Y:FDC4 U:FF18 S:9ED0 CC:[-F-I-Z--] FIRQ(0001)     <-[2]
> 23AE 86 04          LDA #$04                                           <-[3]
```

1. The executed instruction: [a] address, [b] machine code, [c] mnemonic, [d] machine
   cycles consumed, [e] value of the memory read/write.
2. CPU registers and the active interrupts. The number after the interrupt name is a hex
   bit mask of the devices asserting it:

   | Line | Bit | Source (EmuB-6892) |
   |---|---|---|
   | NMI | 0001 | trace (`$FFD1` TRACE) |
   | NMI | 0004 | floppy disk |
   | NMI | 0008 | BREAK key pressed |
   | IRQ | 0001 | keyboard key pressed |
   | IRQ | 0002 | light pen pressed |
   | IRQ | 0004 | PIA A port |
   | IRQ | 0008 | PIA B port |
   | IRQ | 0010 | extension PIA A port |
   | IRQ | 0020 | extension PIA B port |
   | IRQ | 0040 | ACIA |
   | IRQ | 0080 | extension ACIA |
   | IRQ | 0100 | 9-voice PSG VIA timer |
   | FIRQ | 0001 | **1/60 s timer** |
   | HALT | 0002 | 8-inch floppy disk |

3. The next instruction to execute.

## EmuB-S1 additions and differences

- Builds with the Z80B / 68008 card: most commands act on the current CPU; **CPU**
  `[<index>]` switches (0: MC6809, 1: Z80 or MC68008). Memory commands act on the memory
  visible to the current CPU. Symbols, dump file names and break/trace points are per
  CPU.
- **DP types** on the S1: 0 physical memory address, 1 attribute RAM, 3/4/5 IG RAM
  blue/red/green (6809 only). (No "I/O at ff00-ffef" note.)
- **RD devices**: `PIA, ACIA, CRTC, KEYBOARD, CMT, TIMER, FDC3, FDC5, FDC5EX, FDDUNIT,
  BOARD, PSG0, PSG1, PIAPSG, PSG60, PSG61, VIAPSG, PSG90, PSG91, PSG92, FMOPN, PIAEX,
  ACIAEX, RTC, MSM58321`.
- **M** shows the memory map by physical address.
- **X** `[<segment>|ALL]` — show the current address map (6809 only): the contents of
  system I/O `$FE00-$FE0F` for a segment (0-3f). If `$FE11` (segment register, OS-9 card)
  is disabled the segment number is fixed at 0.
- **XE** `<segment> <a0> [... <aF>]` — change the address map: 16 mapping values for
  addresses `$0xxxx-$Fxxxx` (i.e. writes `$FE00-$FE0F`); `XE <seg> MAP<n>` applies the
  map S1 BASIC manages for memory space n (0-f); `XE <seg> RESTORE` reverts to the
  previous map.
- **MAP** `[<space>|ALL]`, **MAP ID**, **MAP CALL**, **MAP DP**, **MAP ASSIGN** — show
  the address map / memory identification / system call addresses / default direct page
  per memory space / the memory ranges managed by S1 BASIC (6809 only).
- **MAPE** `<space> <a0>..<aC>` (13 values for `$0xxxx-$Cxxxx`), **MAPE ID**, **MAPE DP**
  `<space> <dp>` — edit those S1 BASIC tables.
- **I/IB/IW/ID** `<port>`, **O/OB/OW/OD** `<port> <value>` — I/O read/write (for the Z80;
  the 6809 is memory-mapped, use D/E).
- **DIS** types add 4 graphic RAM (all), 5 blue, 6 red, 7 green; **DDIS** writes palette
  numbers.
- Extra break/trace points: **IBP/OBP/ITP/OTP** (Z80 I/O read/write), **EBP/ETP**
  (68008 exception, optional vector number), **BPP/RBPP/WBPP/TPP/RTPP/WTPP** (like BP etc.
  but with **physical** addresses), with matching C/D/E commands.
- **CL** shows clocks and time for each CPU. The BAS debugger handles S1 and Level-3
  BASIC (6809 only).
- Trace format (6809) adds the **20-bit physical address** before the logical address:
  `E43AB 23AB B7 FF D0  STA $FFD0  ( 3) (W FFD0:04)`. Z80 and MC68008 trace formats are
  documented as well (68008 status flags `[T-XNZVC:S:M0:-210EsAQVBhH]`: trace, extend,
  N/Z/V/C, supervisor/user, interrupt mask, IPL0-2, exception, STOP, address error,
  BUSREQ, VPA, bus error, double-fault halt, HALT).
- **Interrupt sources on the S1** (added to/changed from the table above):

  | Line | Bit | Source (EmuB-S1) |
  |---|---|---|
  | NMI | 0002 | **trap (`$BFxxx` access)** |
  | NMI | 1000 | Z80B card (when NMI selected) |
  | IRQ | 0002 | mouse button pressed (instead of light pen) |
  | IRQ | 0200 | FM sound timer (when IRQ selected) |
  | IRQ | 0400 | FM sound (extension PSG) timer (when IRQ selected) |
  | IRQ | 1000 | Z80B card (when IRQ selected) |
  | FIRQ | 0002 | **1 ms / 2 ms timer** |
  | FIRQ | 0200 | FM sound timer (when FIRQ selected) |
  | FIRQ | 0400 | FM sound (extension PSG) timer (when FIRQ selected) |
  | HALT | 0001 | **palette read** |
  | HALT | 0002 | 2HD floppy disk |
  | HALT | 2000 | 68008 card |
