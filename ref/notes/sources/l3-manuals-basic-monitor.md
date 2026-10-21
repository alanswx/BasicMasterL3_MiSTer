# Level 3 BASIC and monitor usage from the English manuals (for testing)

The sources and page conventions are the same as `l3-manuals-hardware.md`: [L3UserMan p.N] (PDF page; printed = N-9), [L3AsmMan p.N] (PDF; printed = N-7), [L3DiskBasic p.N] (PDF; "2-1" = PDF 27).

## 1. Cold start / power-on screen

- Power-on goes straight into BASIC: "BASIC is called up and the screen display shows the title and memory capacity" [L3UserMan p.50]. The photo (Photo 3.1, 40-column hi-res, MODE switch at 0) reads:

  ```
  HITACHI LEVEL-3 BASIC Version 1.0
  Copyright (c) 1980 by Microsoft
  22378 Bytes Free
  Ready
  _
  ```

  The photo is blurred. The title and copyright lines match the Disk BASIC screen below, and the byte count comes from the text: "22378 bytes (40-ch.) or 14186 bytes (80-ch.)" [L3UserMan p.50].
- Bytes free by power-on mode (Table 3.3): 40 normal 29546, 80 normal 28522, 40 hi-res 22378, 80 hi-res 14186 [L3UserMan p.50]. "The dip switch has been set to high resolution mode when delivered", so the factory power-on screen is 40-column hi-res (MODE 0) or 80-column hi-res (MODE 1) [p.50]. These numbers are good golden values for a first core bring-up.
- The prompt is **`Ready`**, not `Ok` [L3UserMan p.36]; [L3DiskBasic p.27]. Errors look like `Syntax Error in 30` [L3UserMan p.66].
- If DIP 1 is closed (0), the machine powers up in **terminal mode** instead of BASIC [L3UserMan p.218].
- Disk BASIC boot screen (system disk in drive 0, MP-1800 fitted, MODE switch 0) [L3DiskBasic p.17]:

  ```
  HITACHI LEVEL-3 DISK BASIC Version 1.0
  Copyright (c) 1980 By Microsoft
  17944 Bytes Free
  Ready
  ```

  Bytes free under Disk BASIC: 40N 25112, 80N 24088, 40H 17944, 80H 9752 [L3DiskBasic p.18]; [L3UserMan p.156]. The formula is B = 26866 + (128/5)·W·(7R−8) − 142F − 162D, where W = columns, R = 0 for hi-res and 1 for normal, F = FCBs and D = maximum drive [L3DiskBasic p.19].
- ROM entry points disclosed (Table S.3) [L3UserMan p.224]:

  | Address | Routine |
  |---|---|
  | `$FAB3` | Cold start |
  | `$A438`, `$A3A7` | Warm start |
  | `$E804` | Input one character |
  | `$E820` | Output one character |

- CTRL-D is "Soft (hot) start" [L3UserMan p.17]. RESET from the front panel exists [p.13]. After RESET or CTRL-D, the assembler is re-entered at `$5006`, so RESET does not destroy RAM contents [L3AsmMan p.75].

## 2. Booting a disk

1. Fit the MP-1800 card (in I/F-1) and connect the MP-3540 [L3UserMan p.152].
2. Power on the MP-3540, insert the system (Disk BASIC MA-5300/5301) diskette in **drive 0**, close the door, then power on the Level 3 [L3UserMan p.153-154]; [L3DiskBasic p.17].
3. "The Level-3 then automatically starts reading the disk and the 'Ready' condition is displayed on the screen after one or two seconds" [L3UserMan p.154].

There is no boot command: the boot happens because the floppy card is present at power-on. If it fails, check that the MP-1800 is fitted, the connector is on I/F-1, the disk is inserted and the motor lamp is on, and that the power-up order was correct [L3DiskBasic p.18].

Under Disk BASIC the default device is drive 0 (`0:`), so cassette needs an explicit `"CAS0:"`. LOAD with no descriptor loads the file named "" (spaces) from drive 0. `LOAD?` and `SKIPF` are cassette-only [L3UserMan p.154]; [L3DiskBasic p.56-57].

Disk utilities on the system disk: `FORMAT` (BASIC; it asks for drive 1, 2 or 3 and loads the machine-code `SKIP2`), `CONFIG` (maximum drive count and number of FCBs), `DISKCOPY`. A new disk needs `FORMAT` then `DSKINI <drive>` [L3DiskBasic p.20-22].

## 3. Cassette and machine code

File descriptors (Table 4.2) [L3UserMan p.56]:

| Device | Name |
|---|---|
| Keyboard | `KYBD:` |
| Display | `SCRN:` |
| Printer | `LPT0:` |
| RS-232C | `COM0:` (options in parentheses, e.g. `"COM0:(F8N1)"`) |
| Cassette | `CAS0:` |
| Floppy | `0:` - `3:` |

Commands (syntax from [L3DiskBasic p.69-70, p.80-82]):

- `LOAD ["<desc>"] [,R]`: load a BASIC program. `,R` runs it. CTRL-D aborts a cassette search [L3DiskBasic p.69-70].
- `RUN "<desc>" [,R]`: load and run [L3DiskBasic p.80-81].
- `SAVE ["<desc>"] [,A]`: `,A` saves ASCII; the default is tokenised binary [L3DiskBasic p.81].
- **`SAVEM "<desc>", <start>, <end>, <exec>`**: save memory. Example: `SAVEM "ASM9",&H5000,&H69FF,&H5000` [L3DiskBasic p.82]; [L3AsmMan p.74].
- **`LOADM ["<desc>"] [,<offset>] [,R]`**: load a machine-code file at its saved address plus the offset. **`,R` jumps to the exec address given at SAVEM** [L3DiskBasic p.70]. Examples: `LOADM "CAS0:ASM9",,R` and `LOADM "1:ASM9"` [L3AsmMan p.16, p.81].
- `LOAD?`: verify a cassette program. `SKIPF`: skip to the named file on cassette. `MERGE "<desc>"[,R]`: merge an ASCII program [L3DiskBasic p.70-72].
- `MOTOR`: cassette motor control [L3DiskBasic p.73].
- **`EXEC <addr>`**: run machine code, e.g. `EXEC &H6002`, `EXEC &H5000`. RTS returns to BASIC [L3UserMan p.177]; [L3AsmMan p.75]. The work area `$0148-$0149` holds the "EXEC execution address" [L3UserMan p.225].
- `DEFUSR` / `USR(n)` call machine code with a value. The USR jump table is at `$014A-$015D` [L3UserMan p.225, p.246].
- `CLEAR <strspace>, <top>` reserves memory above `<top>`, e.g. `CLEAR 300,&H5FFF` before poking code at `$6000` [L3UserMan p.176], or `CLEAR 300,&H4EFF` before loading the assembler [L3AsmMan p.74].
- **`NEW ON`**: "Restart by mode switching". It re-initialises with a new VRAM size / screen mode, the software equivalent of changing the DIP/MODE switch [L3DiskBasic p.74]; [L3UserMan p.24, p.128].
- A cassette load session looks like this [L3AsmMan p.73, p.75]:

  ```
  Ready
  LOADM "ASM9"
  Searching          <- put the recorder in PLAY
  Found: ASM9
  Ready
  ```

## 4. Monitor (`MON`)

- **`MON`** "Activation of the machine language monitor" [L3DiskBasic p.73]. The monitor prompt is **`*`** [L3UserMan p.175].
- Commands documented in these manuals:
  - **`M<addr>`**: memory modify. `*M6002` shows `6002 00-` with the cursor after the dash. Type hex bytes in sequence [L3UserMan p.176].
  - **`D`**: dump ("The monitor command is executed using D (dump) and M (memory input)") [L3UserMan p.176].
  - **`G<addr>`**: go, e.g. `*G5000` starts the assembler and `*G7000` the debugger [L3AsmMan p.15, p.78-79].
  - Return to BASIC with **BREAK** or **CTRL-C** [L3UserMan p.177]; [L3AsmMan p.15 (Fig 1-2-3: MON goes BASIC→MONITOR, BREAK goes MONITOR→BASIC)].
- The exact terminator for M and D (Return or Space?) is not stated. The example shows `*M6002` entered, then bytes typed until "B6 to 39", then BREAK. The full ROM monitor command list should be in the Japanese BASIC manual or the Peach ROM Notes (`ref/docs/peach/Peach-ROM-Notes-rev2`).
- Do not confuse this with the separate disk/tape **debugger** (DEBUG70 at `$7000`, DEBUG5A at `$5A00`), which has its own M, D, B, G, R, S, C, F, T, E and A commands [L3AsmMan p.5]. That is not the ROM monitor.

## 5. Useful test snippets straight from the manual

- Colour/VRAM: `10 CLS:20 SCREEN0:30 WIDTH 80:40 POKE &HFFD8,&H84:50 POKE &H0400,&H41:60 LOCATE 0,10` puts a green "A" at the top-left [L3UserMan p.144-145].
- Whole character set in three colours: `SCREEN0:WIDTH40`, then loop `POKE &HFFD8,&H84` / `&H89` / `&H92` with `POKE &H400+I,I`, `&H500+I`, `&H600+I` for I=0..255 (Photo 7.20) [L3UserMan p.145-146].
- Hi-res text: `SCREEN1:WIDTH80:FOR I=0 TO 7:POKE &HFFD8,&H84:POKE &H400+I*&H800,&H41:NEXT` [L3UserMan p.150].
- Beeper: `FOR I=0 TO 20:POKE &HFFD3,0:POKE &HFFD3,255:NEXT` [L3UserMan p.170]. Machine code at `$6002` (B6 60 00 C6 00 F7 FF D3 F6 60 01 5A 26 FD C6 FF F7 FF D3 F6 60 01 5A 26 FD 4A 26 E7 39), then `POKE &H6000,255:POKE &H6001,60:EXEC &H6002` [L3UserMan p.176-177].
- Timer: `POKE &HFFD4,255` stops TIME$; `POKE &HFFD4,0` resumes it [L3UserMan p.169].
- Raw keys: `POKE &HFFE0,&H0C` then `PRINT PEEK(&HFFE0)` in a loop. Space gives 128, ↑ 129, ← 131, ↓ 132, → 133. Restore with `POKE &HFFE0,&HF0` or RESET [L3UserMan p.167-168].
- `PRINT FRE(0)` should match the Bytes Free numbers above [L3AsmMan p.14].

## 6. Screen and other commands relevant to testing

- `WIDTH 40|80`; `SCREEN mode,page,interlace` (mode 0 normal / 1 hi-res; interlace 0 = on, 1 = off) [L3UserMan p.126-127].
- `COLOR fg[,bg]` (e.g. `COLOR 7,0`) [L3UserMan p.226, p.229]; `CONSOLE` sets the scroll window [L3UserMan p.237 sample program]; `LOCATE x,y[,cursor]` [p.166]; `CLS`; `PSET/PRESET/LINE/PAINT/POINT` with X 0-639 and Y 0-199 in every mode [L3DiskBasic p.51].
- `KEY n,"str"` defines PF keys. The defaults are PF1 `LOAD↵`, PF2 `?DATE$,TIME$↵`, PF3 `KEY`, PF4 `LIST↵`, PF5 `RUN↵`, PF6 `TERM`, PF7 `SCREEN`, PF8 `COLOUR`, PF9 `LIST"LPT0:"↵`, PF10 `CONT↵` [L3UserMan p.19].
- `INKEY$`, `INPUT$(n[,#f])`, `OPEN "I",#1,"KYBD:"` [L3UserMan p.158, p.166].
- `TERM "<clock><bits><parity><stop><duplex>"`, e.g. `TERM "F8N1F"` [L3UserMan p.213].
- `BEEP`; the `TIME$`/`DATE$` clock (timer-driven) [L3UserMan p.169].
- The `PEN` function and `ON PEN GOSUB` read the light pen [L3UserMan p.178-182].
- Line numbers are 0-63999, with up to 255 characters per line [L3DiskBasic p.27].
- Program 28 at [L3UserMan p.247] lists the reserved words by reading the ROM keyword table starting at **`$A078`** (bit 7 terminates each word). That is useful for checking a ROM image.

## 7. BASIC work area (Table S.4)  [L3UserMan p.225]

| Address | Content |
|---|---|
| `$0006` | Floating accumulator type |
| `$001D-1E` | BASIC program start |
| `$001F-20` | Simple variable start |
| `$0021-22` | Array start |
| `$0023-24` | Free area start |
| `$0025-26` | Stack start |
| `$0027-2A` | Output work |
| `$002B-2C` | BASIC program end (handwritten note: `$2D-2E` BASIC program counter) |
| `$0056-5E` | Floating point accumulator |
| `$009E` | File number |
| `$00A2` | Maximum horizontal character number |
| `$00A3-A4` | Display area start |
| `$00A5-A6` | Display area end |
| `$00A7` | Graphic mode (handwritten: `$115` cursor mode) |
| `$0116` | Character colour |
| `$0148-49` | EXEC execution address |
| `$014A-15D` | USR jump table |
| `$01C8-1C9` | Work area start |
| `$01CA-1CB` | Key buffer start |
| `$01CC-1CD` / `$01CE-1CF` | Function key table start / end |
| `$01D0-1D1` | Cassette buffer start |
| `$01D2-1D3` | I/O device table start |
| `$01F4` | Remote (motor) state |
| `$01FB` | Item |
| `$01FC` | Type |
| `$01FD` | File name exists flag |
| `$01FE-205` | File name |
| `$0206` | I/O device number |
| (handwritten) `$216` | "Acc. Timer (1/60 second)"; `$21C-221` date; `$24F-250` "ML monitor counter" |

The handwritten additions come from a previous owner, so treat them as unverified.

## 8. Error codes (Disk BASIC adds 50-73)  [L3DiskBasic p.149-153]

Common ones: 1 Next Without For, 2 Syntax Error, 3 Return Without Gosub, 4 Out Of Data, 5 Illegal Function Call, 6 Overflow, 7 Out Of Memory, 8 Undefined Line Number, 9 Subscript Out Of Range, 11 Division By Zero, 13 Type Mismatch, 14 Out Of String Space, 53 Device I/O Error, 61 Buffer Overflow, 63 File Not Found, 72 Drive Not Ready. A cassette read error presumably reports as "Device I/O Error".
