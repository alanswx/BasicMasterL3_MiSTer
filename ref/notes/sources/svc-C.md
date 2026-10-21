# MB-6890 Service Manual, sections 8-12 and 16 (images p084-p123)

Source: Hitachi "MB-6890 Service Manual" (English, 1981), the manualslib page images at
`ref/docs/service/MB-6890-service-manual/manualslib-pages/`. Image number = printed page + 2.
Citations are [SVC p.N] using the printed page number.

**Missing from this copy:** TOC sections 13 (Basic circuit diagram), 14 (Basic P.C.B. layout) and
15 (Waveform of each block) [SVC p.1]. Printed page 113 (img 115, the last test listing) is
followed directly by printed page 114 (img 116, parts list p.1). Images p122 and p123 are blank
all-guides.com watermark pages; the manualslib viewer shows only the watermark there too. The
foldout schematics were not scanned into this copy. The 29 MB copy on 1000bit.it (download.asp?id=1083,
login required) may include them.

---

## 8. Adjustment method

### 8-1 PLL circuit adjustment (cassette input) [SVC p.82]
1. Main power on.
2. Feed a sine wave of **2 Vp-p +/- 0.2 V at 1.7 kHz +/- 5 Hz** into cassette I/O jack **JA pin 5 (signal) / pin 2
   (ground)**. Alternatively, inject it at the mini jack on the cassette cable (white = signal) [SVC p.82 Fig 8-2].
3. Measure between test points **TP13 and TP14** through a 10 kohm series resistor, with a meter of more than
   1 Mohm input impedance. Adjust **R109 (PLL adjust, 5 kohm B)** for **0 V +/- 2 mV** [SVC p.82; p.117 parts].
- 1.7 kHz is roughly the midpoint of the 1200 Hz / 2400 Hz FSK tones. The PLL is IC127 LM565CN (see the
  troubleshooting chart, 11-10) [SVC p.99, p.117].
- Fig 8-1 also shows **R112 "LP adjust"** (light pen, 500 ohm B), test point TP16, and jacks JA and JC
  [SVC p.82; p.117].
- (Section 8-2 is not on these pages. It is presumably on printed p.82 or earlier, which is another fork's share.)

### 8-3 System timing adjustment (when replacing the MPU) [SVC p.83]
If IC1 (**HD6809P / MC6809L**) is replaced, check the "grade number" printed on the MPU (Fig 8-4). Then set
jumper JT2, capacitor C187 and jumpers JP8/JP9/JP10 per Table 8-1:

| Grade | JT2 connection | C187 needed | JP8 | JP9 | JP10 |
|---|---|---|---|---|---|
| 1 | 1-3 | no | yes | no | no |
| 2 | 1-3 | yes | yes | no | no |
| 3 | 1-2 | no | yes | no | no |
| 4 | 1-2 | yes | yes | no | no |
| 5 | 1-2 | yes | no | yes | yes |
| 6 | 1-3 | no | yes | no | no |
| 7 | 1-3 | yes | yes | no | no |

Positions: C187 sits between IC42 pin 7 and IC42 pin 8. JP8 runs from IC37 pin 13 to JT1 pin 3. JP9 runs from
IC37 pin 13 to IC140 pin 12. JP10 runs from IC140 pin 11 to JT1 pin 3. C187 = 180 pF [SVC p.83, Fig 8-3].
- Fig 8-3 part labels: IC36 = CRTC; IC42 = **HD74LS164P**; IC37 = **SN74LS163N**; IC43 = **HD74S04P**;
  IC140 = **HD74LS367AP**; R15 is near IC37 [SVC p.83].
- Interpretation: the 6809's clock/timing phase is trimmed by choosing a tap on the LS164 shift register (JT2) and
  by a capacitor delay. That lets MPU timing be matched to the video/DRAM timing chain (IC37 LS163 counter,
  IC43 S04 oscillator buffer). An FPGA core does not need this, but it confirms that the CPU clock comes
  from the same counter chain as video.

### 8-4 RAM capacity confirmation [SVC p.84]
1. Set the front-panel MODE switch to "1" and power on.
2. The power-on screen (high-resolution mode) shows:
   ```
   HITACHI LEVEL-3 BASIC Version 1.0
   Copyright (C) 1980 By Microsoft
   14186 Bytes Free

   Ready
   ```
3. Type `PRINT FRE(0)`. It should show **14172**.
4. Set MODE back to "0".
- This is the **cold-start banner text**, and 14186 bytes free is the figure for a standard 32 KB machine in
  hi-res mode (the screen area takes RAM) [SVC p.84].

### 8-5 Power unit adjustment [SVC p.84]
- Replace connector A with a dummy load (Fig 8-5). Adjust **VR200 for +12 V +/- 0.2** and **VR100 for
  +5 V +/- 0.1** (Table 8-2). Rails: +12, +5, -5, -12 V [SVC p.84, p.101].

## 9. Service points (disassembly) [SVC p.85-86]
- Remove the upper case screws, then the upper cover (pair) and connectors. An expansion RAM card can sit in
  RAM3/RAM4. Then remove I/F panel A (panel hold plate), the power unit, the BM-A PCB (main board) and its shield
  case, and the keyboard (8 screws). Fig 9-8 shows the push switch, **R36 volume** (speaker) and push power
  switch on the front panel [SVC p.85-86].
- The main PCB is called **BM-A**. The power PCB is **PM-A** [SVC p.86, p.118].

## 10. Built-in switch usage [SVC p.87-90]
There are four switches. Change them only with power off, because the setting is read at power-on [SVC p.87]:
1. DIP switch **SW**: initial state at power-on.
2. Chip switch **CS1**: what the front-panel MODE switch does.
3. Chip switch **CS3**: RS-232C baud rate factor.
4. Chip switch **CS4**: RS-232C handshake/signal configuration.

Board layout (Fig 10-1): JA, JC and JB at the rear edge; SW near I/F-6; expansion connectors I/F-6...I/F-1;
RAM3/RAM4 memory expansion connectors; CS1 beside RAM4; CS3/CS4 beside IC107; ROMs IC2-IC5 in a column;
IC1 below them; keyboard connector at the front [SVC p.87].

### (1) DIP switch SW, Table 10-1 [SVC p.88]
Up = OPEN = "1"; down = CLOSE = "0".

| SW | OPEN (1) | CLOSE (0) | Normal |
|---|---|---|---|
| 1 | BASIC mode | TERMINAL mode (same as the TERM command) | 1: BASIC |
| 2 | Interlace mode (same as SCREEN 0) | Non-interlace mode (same as SCREEN 1) | 1: interlace |
| 3 | 80 chars/line (same as WIDTH 80) | 40 chars/line (same as WIDTH 40) | 1 (*) |
| 4 | Normal mode (same as SCREEN 0) | High-resolution mode (same as SCREEN 1) | 0: high resolution |
| 5 | Show programmable function key contents (CONSOLE 0,24,1) | Don't show them (CONSOLE 0,24,0) | 0: no display |
| 6 | Half duplex (H) in terminal mode | Full duplex (F) in terminal mode | 0: full duplex |
| 7 | 7 bits/char in terminal mode | 8 bits/char in terminal mode | 0: 8 bits |
| 8 | Convert hiragana to katakana on printout | Print hiragana codes as-is | 0: no conversion |

(*) The front-panel MODE switch is wired in parallel with DIP SW3 in the standard configuration. MODE "0"
(button up) = 40 chars/line; MODE "1" (pressed) = 80 chars/line. This is read at power-on. The MODE mapping can be
changed with CS1 [SVC p.88].

**MAME check:** MAME's `DIPSW` port cites "service manual p.88". Its bit assignments (bit0 = SW1 ...
bit7 = SW8), polarity (OPEN = 1) and labels all match Table 10-1, including SW4: 0 = high res. **No conflict.**
MAME's "40/80 column overridden by Mode toggle" note matches the CS1 description.

### (2) Chip switch CS1 [SVC p.89]
A 5-position header with one shorting tip:
- Standard: tip in positions **3-4**, so MODE switch = DIP SW3 (40/80 columns) (Fig 10-3).
- Tip in **2-3**: MODE switch = DIP SW2 (interlace/non-interlace).
- Tip in **1-2**: MODE switch = DIP SW1 (BASIC/TERM).
- Note: the DIP switch paired with the MODE switch must be OPEN (1). If it is CLOSE (0) the MODE switch has no
  effect. So MODE pulls the DIP line low, wired-AND [SVC p.89].

### (3) Chip switch CS3: RS-232C baud rate factor [SVC p.89]
A 4x2 header with one tip. Positions 1 (standard) to 4 select **baud rate factor 1 to 4**. The actual baud rate
is "set by the position of the tip and the combination of the program", meaning the COM open parameters
[SVC p.89]. (The user manual's Table 15.2 maps factors to 300...4800 baud; see the L3 user-manual notes.)

### (4) Chip switch CS4: RS-232C signal configuration [SVC p.90]
8 positions, 4 tips (Fig 10-6):

| Tip in | Effect |
|---|---|
| 8 | TxD output (true) |
| 7 | /TxD output (inverted) |
| 6 | /RTS output |
| 5 | RTS output |
| 2 | DCD active (from line) |
| 3 | DCD grounded (always receive) |
| 4 | CTS active (from line) |
| 3 | CTS grounded (always allowed to send) |

Meanings: TxD = data out. RTS = request to send. DCD = the far end is sending; grounded means this unit only
receives. CTS = the far end can receive; grounded means always enabled [SVC p.90].

## 11. Troubleshooting (flowcharts) [SVC p.91-101]
The flowcharts matter here mainly because they show **which ICs make up each functional block**. Those
inferences are collected in `svc-schematic.md`. Highlights:
- 11-1 No picture: check the power rails, then brightness at IC117 pin 3, then IC38 pin 9 (timing), then the sync
  signal at **IC36 pins 39/40** (CRTC VSYNC/HSYNC), then the MPU data bus IC1 pins 24-31. Next, IC5 pin 20
  (ROM /CE) pulsing at power-on. Then stuck-low checks on **IC1 pin 2 (/NMI)**, **pin 4 (/FIRQ)** and **pin 3 (/IRQ)**.
  The suspect lists are: NMI stuck: IC14, IC15, IC22, IC23, IC95, IC94. FIRQ stuck: IC16, IC22, IC17. IRQ stuck:
  IC22, IC17, IC18, IC95, IC96. Address decoder: IC7, IC8, IC9 (input/output similar), IC11 pin 7 at power-on;
  suspects IC25, IC7, IC8, IC9, IC11, IC26, IC30, IC12 [SVC p.91].
- 11-2 Data bus abnormal: IC24, IC6 (LS245), IC11 pin 11, IC3/IC4/IC5 pin 20, IC32 pin 3, IC97 pin 6; suspects
  include IC138, IC35, IC11, IC27, IC12, IC21, IC26, IC28, IC29, IC32, IC33, IC97, IC6, IC19, IC20, IC3-5, IC80,
  IC139, IC88 [SVC p.92].
- 11-3 Timing signal abnormal: IC38 outputs, IC42 outputs, IC46 pin 1, IC28 pin 8, IC41 (input = output),
  **IC41 pin 13**, **IC36 pin 21 (CRTC CLK)**, IC37 output; suspects IC38, IC46, IC28, IC45, IC41, IC34, IC35,
  IC44, IC36, IC51, IC40, IC23, IC42, IC37, IC43 [SVC p.93].
- 11-4 Data from RAM abnormal. Test program [SVC p.94]:
  ```
  1 I=0
  10 POKE &H6000,I
  20 I=I+1:IF I>15 GOTO 1
  30 COLOR I:PRINT"HITACHI";
  40 GOTO 10
  ```
  Checks: IC80/IC139 inputs; IC52-IC55 inputs and outputs; IC48 pin 3; IC143 pins 9 and 8; IC77 pin 9;
  **IC64-IC68 pin 2** (DRAM DIN). Suspects: DRAMs IC56-IC76, IC40, IC51, IC147, IC52-55, IC48, IC142-145, IC32,
  IC45, IC49, IC77, IC64-68 [SVC p.94].
- 11-5 No video signal: IC117 pin 13/15, IC129 pin 9, IC115 pins 5/7/10 high, IC116 pin 14, IC118 pin 15,
  IC118 pins 4/7/9, IC130 pin 9; colour path Q5, IC132, IC135, JB [SVC p.95].
- 11-6 Incorrect key entry (watch the waveform with a key held down) [SVC p.96]:
  - BREAK key: IC99 pin 9; suspects IC98, IC11, IC97, IC99.
  - "Only GRAPH can't enter": IC136, IC130, IC141.
  - Space and up-arrow: IC102 pins 2 and 3 "L"; suspects IC102, the keyboard, chip connector T2 contact, IC89.
  - Then: pulse into IC97 pin 9 (IC130, IC134), outputs of IC101 and IC102, IC86 output, IC90 pin 5,
    IC95 pin 11, IC98 pin 4; final suspects IC88, IC89, IC94, IC100.
- 11-7 Graphic mode defect: if hi-res works, IC112 or IC129. Then IC51 pin 15 "L" (else IC39), pulses on
  IC40 pins 1/4/10/13 (else IC40, IC51), otherwise IC113/IC114 [SVC p.97].
- 11-8 **Timer does not operate**. Observe after releasing the time mask, e.g. `POKE &HFFD4,0`. Expect a
  **pulse every 1/60 s at IC16 pin 9** (else IC16, IC17, IC20), then at IC16 pin 5 (else IC16), then at
  **IC22 pin 8** (else IC22), and finally IC24, IC13, IC1 [SVC p.98].
- 11-9 No sound. Run `1 BEEP:GOTO 1`. Pulse at **IC93 pin 5** (else check IC93 pin 3 input: IC93, IC13,
  IC20). Then the Q1 collector (else Q1, R36), otherwise Q2/Q3 [SVC p.98].
- 11-10 No cassette SAVE/LOAD [SVC p.99]:
  - SAVE: **IC124 pin 8 = 2.4 kHz and pin 11 = 1.2 kHz** (else IC124), then IC126 in/out, IC125 in/out,
    IC84 (ACIA).
  - LOAD: signal at IC127 pin 2 (else cable/tape/recorder/relay circuit/limiter D3, D4); IC127 pin 7 sine
    (else R109 adjustment or IC127); IC111 pin 9 sine (else IC128); IC111 pins 4 and 9 (else IC111);
    IC122 in/out; IC123 in/out; IC111 "L" (else IC39), otherwise IC84.
- 11-11 No printer output: IC94 pin 4 (else IC94 / printer), IC85 output (else IC85), otherwise IC95/IC105
  [SVC p.100].
- 11-12 Light pen: R112 adjustment, pulse at JC pins 1 and 2, IC25 pin 11 (else IC21, IC25), IC18 pin 9 (else
  IC17, IC18), otherwise IC22/IC1 [SVC p.100].
- 11-13 Abnormal power: dummy load on connector A (A1 30 ohm, 3 ohm, 200 ohm, 500 ohm); power-unit ICs IC100,
  IC200, IC300, IC400; Q1, T1, T3, T4, T101; TH130 [SVC p.101].

## 12. Operation check method [SVC p.102-113]
Set the switches to normal: **DIP 1-3 OPEN, 4-8 CLOSE, front-panel MODE "0"** [SVC p.102]. Connect a colour
monitor, green monitor, cassette recorder, printer, light pen, and a crossed RS-232C cable to a second MB-6890
("RS-232C check parent set") [SVC p.102 Fig 12-1].

Table 12-1 [SVC p.102-103]:

| No | Test item | Content | Program file |
|---|---|---|---|
| 1 | Master ROM | Checksum calculation | ROM-C |
| 2 | Character ROM | Judge characters on screen | CG-C |
| 3 | Display colour | Judge colours on screen | COL-C |
| 4 | Built-in switches | Function test of the switches | - |
| 5 | Graphic mode change | Judge normal vs high resolution | GR-C1, GR-C2 |
| 6 | Cassette interface | SAVE, VERIFY, MOTOR ON/OFF | CAS-C |
| 7 | Printer interface | Data bus and control lines | KY-PR |
| 8 | Speaker | Oscillating sound and volume control | SPK-C |
| 9 | Light pen interface | Signal line test | LP-C |
| 10 | RS-232C interface | Receive/send test | RS2-C |

Procedure [SVC p.104-108]:
- Power on and confirm the number of free bytes ("programmable bytes"). If it is wrong, suspect the RAM circuit.
- Insert the test cassette and press the **PF1 then PF5** keys. On the cassette these load and run the next
  program ("ROAD, RUN"). Each program chains to the next with `RUN"name"`.
- **Mask ROM test** screen: `***** MASK ROM TEST *****`, `CHECK SUM`, **`A= 18   B= 178`**, then a large "OK"
  banner `MASK ROM セイジョウ!` ("normal") [SVC p.104].
- **Character ROM test**: prints CHR$ &H20-&HFF as a 16-row table. The first pass is in interlace mode
  (SCREEN 0,,0), then "OK?". The second is in non-interlace mode (SCREEN ,,1), which shows different glyph
  shapes. In the second photo the upper half of the code table shows block-graphic, card-suit and other
  semigraphic shapes [SVC p.104, p.109].
- **Colour test**: eight bars labelled **black, blue, red, magenta, green, cyan, yellow, white** (colour codes
  0-7). This confirms the BRG 3-bit order (bit0 = B, bit1 = R, bit2 = G). Then the background colour cycles via
  `COLOR ,I-1` [SVC p.105, p.110].
- Then set DIP SW2 to CLOSE, power-cycle, and hold **GRAPH** while pressing **Z, X, C** to check that graphic
  characters appear. Set SW2 back to OPEN, power-cycle, and repeat. Press MODE, power-cycle, and confirm an
  80-column screen [SVC p.105-106].
- **Graphic mode check 1**: DIP SW3 and SW4 OPEN, MODE "0" (normal resolution). An X in a box drawn with LINE
  appears "thicker". **Check 2**: SW4 CLOSE (high resolution); the same drawing appears "thinner" [SVC p.106].
- **Cassette**: SAVE "TEST" with MOTOR ON/OFF, rewind, VERIFY. The screen shows `Searching` / `FOUND: TEST`
  [SVC p.107].
- **Printer**: prints `1234567890`, `A-Z`, and a katakana line [SVC p.107, p.111].
- **Speaker**: 20 BEEPs while the volume pot is turned [SVC p.108, p.111].
- **Light pen**: five colour boxes. Touching each with the pen changes its colour through ON PEN GOSUB
  [SVC p.108, p.112].
- **RS-232C**: on the parent machine type `TERM"S8N2H"`, then exchange `ABC`, `123`, and kana in both
  directions. Output test: `1234567890` should appear as 2 lines on the other machine. **RS-232C input IRQ
  test**: `ON COM(0) GOSUB` should print `COM(0) IRQ BY (A)` etc. [SVC p.108, p.113].

### Test program listings (useful facts) [SVC p.109-113]
- **ROM-C (mask ROM checksum)** [SVC p.109]:
  - Pokes 6809 code at &H7000 (patching the high bytes of two STA/STB operands to the load page) and runs it
    with `EXEC`. It then reads the results from ADRS+&H2E (A) and ADRS+&H2F (B).
  - Expected: **A = 18, B = 178** (decimal). Anything else prints "MASK ROM INCORRECT".
  - Machine code (transcribed from the DATA line; the scan is small, so verify):
    ```
    4F          CLRA
    5F          CLRB
    8E A0 00    LDX  #$A000
    8D 16       BSR  SUM
    8C FF 00    CMPX #$FF00      ; sum $A000-$FEFF
    26 F9       BNE  -7
    8E FF F0    LDX  #$FFF0      ; (printed "FFF1"; must be $FFF0)
    8D 0C       BSR  SUM
    8C 00 00    CMPX #$0000      ; sum $FFF0-$FFFF (wraps to 0)
    26 F9       BNE
    B7 70 2E    STA  $702E
    F7 70 2F    STB  $702F
    39          RTS
    SUM: AB 84  ADDA ,X
         49     ROLA
         24 01  BCC  +1
         4C     INCA
         EB 80  ADDB ,X+
         24 01  BCC  +1
         5C     INCB
         39     RTS
    ```
    This is an **independent checksum for validating a Level-3 (v1.0) ROM dump**. It covers
    $A000-$FEFF plus $FFF0-$FFFF and skips the I/O page $FF00-$FFEF. B is the 8-bit end-around-carry sum;
    A is a rotate-add sum. (The listing is labelled "MB-6890"; Mark II/Mark 5 ROMs will differ.)
- **CG-C**: `SCREEN 0,,0:WIDTH40` for interlace and `SCREEN ,,1` for non-interlace. The third SCREEN parameter is
  interlace [SVC p.109].
- **COL-C**: `SCREEN 0,1,0:WIDTH40`, `LINE(X1,96)-(X2,112),PSET,I-1,BF` draws colour bars 0-7 [SVC p.110].
- **GR-C1/C2**: `LINE(100,50)-(500,150),PSET,7,B` and diagonals. Coordinates run to 500 horizontally, so
  640-wide addressing in both modes [SVC p.110].
- **CAS-C**: `MOTOR ON`, `SAVE"TEST"`, `MOTOROFF` [SVC p.110].
- **KY-PR**: `OPEN"O",1,"LPT0:"`, PRINT#1 [SVC p.111].
- **LP-C**: `PEN ON`, `ON PEN GOSUB`, `KEY(n) ON`, `ON KEY(n) GOSUB`; "HITACHI YOKOHAMA WORKS" in the REM
  [SVC p.112].
- **RS2-C**: `OPEN"I",2,"COM0:(S8N2)"`, `ON COM(0) GOSUB`, `COM(0) ON`, `INPUT$(1,#2)`, and `TIME$`
  [SVC p.113].

## 16. Parts list [SVC p.114-119]
Columns: board position, circuit number, part name, Hitachi part number. `*` marks safety/important parts.

### Main board (BM-A) ICs [SVC p.114-117]

| IC | Part | IC | Part | IC | Part |
|---|---|---|---|---|---|
| IC1 | HD6809 / MC6809 (MPU) | IC2 | (not listed: empty BASIC expansion socket) | IC3 | uPD2364C-330 (mask ROM) |
| IC4 | uPD2364C-331 | IC5 | uPD2364C-332 | IC6 | SN74LS245N |
| IC7 | HD74LS367AP | IC8 | HD74LS367AP | IC9 | HD74LS367AP |
| IC10 | HD74LS367AP | IC11 | HD74LS139P | IC12 | HD74LS138P |
| IC13 | HD74LS138P | IC14 | HD74LS74AP | IC15 | HD74LS93P |
| IC16 | HD74LS74AP | IC17 | HD74LS74AP | IC18 | HD74LS74AP |
| IC19 | HD74LS367AP | IC20 | HD74LS367AP | IC21 | HD74LS14P |
| IC22 | HD74LS05P | IC23 | HD74LS04P | IC24 | HD74LS125AP |
| IC25 | HD74LS08P | IC26 | HD74LS00P | IC27 | HD74LS10P |
| IC28 | HD74LS00P | IC29 | HD74LS32P | IC30 | HD74LS30P |
| IC31 | HD74LS04P | IC32 | HD74LS32P | IC33 | HD74LS02P |
| IC34 | HD74LS02P | IC35 | HD74LS86P | IC36 | **HD46505SP (CRTC)** |
| IC37 | SN74LS163N | IC38 | HD74LS157P | IC39 | HD74LS174P |
| IC40 | HD74LS283P | IC41 | HD74LS367AP | IC42 | HD74LS164P |
| IC43 | HD74S04P | IC44 | HD74LS04P | IC45 | HD74LS10P |
| IC46 | HD74LS02P | IC47 | HD74LS00P | IC48 | HD74LS08P |
| IC49 | HD74LS08P | IC50 | HD74LS74AP | IC51 | HD74LS157P |
| IC52-IC55 | HD74153P (x4) | IC56-IC76 | **HM4716AP-1 (16Kx1 DRAM) x21** | IC77 | HD74LS174P |
| IC78 | HD74LS367AP | IC79 | HD74LS367AP | IC80 | HD74LS367P |
| IC81 | HD74LS174P | IC82 | HD74LS174P | IC83 | HD74LS74AP |
| IC84 | **HD46850P (ACIA)** | IC85 | **HD46821P (PIA)** | IC86 | HD74159P |
| IC88 | HD74LS367P | IC89 | HD74LS174P | IC90 | HD74LS151P |
| IC91 | HD74LS04P | IC92 | HD74LS08P | IC93 | HD74LS74AP |
| IC94 | HD74LS02P | IC95 | HD74LS05P | IC96 | HD74LS08P |
| IC97 | HD74LS32P | IC98 | HD74LS125AP | IC99 | HD74LS74AP |
| IC100 | HD74LS04P | IC101 | HD74LS93P | IC102 | HD74LS93P |
| IC103 | HD74LS74AP | IC104 | HD74LS30P | IC105 | HD74LS05P |
| IC107 | **uPD2332C-328 (character generator ROM, 4 KB)** | IC108 | HD74LS174P | IC109 | HD74LS174P |
| IC111 | HD74LS157P | IC112 | HD74LS153P | IC113 | HD74LS257P |
| IC114 | HD74LS257P | IC115 | HD74LS174P | IC116 | HD74LS175P |
| IC117 | SN74LS166N | IC118 | HD74LS158P | IC119 | HD75188P (RS-232 driver) |
| IC120 | HD75189P (RS-232 receiver) | IC122 | HD74LS93P | IC123 | HD74LS93P |
| IC124 | HD74LS93P | IC125 | HD74LS00P | IC126 | HD74LS74AP |
| IC127 | **LM565CN (PLL)** | IC128 | HD75108AP | IC129 | HD74LS00P |
| IC130 | HD74LS74AP | IC131 | HD74LS86P | IC132 | HD74S05P |
| IC134 | HD74LS93P | IC135 | HD7405P | IC136 | HD74LS08P |
| IC137 | HD74LS139P | IC138 | HD74LS11P | IC139 | HD74LS367AP |
| IC140 | HD74LS367AP | IC141 | HD74LS157P | IC142 | HD74LS02P |
| IC143 | HD74LS08P | IC144 | HD74LS32P | IC145 | HD74LS00P |
| IC146 | HD74LS08P | IC147 | HD74LS157P | IC148 | HD74LS74AP |

There is no IC87, IC106, IC110, IC121 or IC133 in the list.

DRAM count: 21 x HM4716 (16K x 1) = 16 chips for 32 KB main RAM (two banks of 8) plus **5 chips = 16K x 5-bit
colour/attribute RAM**. That matches the 5-bit colour RAM in the user manual's memory map [SVC p.115-116].

### Other main-board parts [SVC p.117-118]
- Q1 2SC458; Q2 2SA673; Q3, Q5 2SC1213; Q4 2SC1213; Q6, Q7 2SC458. Diodes 1S2076, 1N34A/1N60. D2 varistor
  MV-11. L1 filter coil, L2 peaking coil 820 uH.
- **R109 5 kohm (B) PLL volume; R112 500 ohm (B) light-pen volume**; R78 2.2 ohm; front panel **R36 2 kohm (B)
  speaker volume**.
- **RL1 sub-miniature relay** (cassette motor remote). **SW = 8-pole DIP switch. XTAL "X1" crystal: the part
  list gives no frequency.**
- JB = 5-pin DIN; JC = 8-pin DIN; JA = 6-pin DIN (cassette). K/B set; switching regulator.
- Connectors: 36P, 25P, two 28P (R3/R4), six **56-pin IF1-IF6** expansion connectors [SVC p.118].
- Power unit (PM-A): IC100 MB-3759 (switching regulator controller), IC200 TA78L005AP, IC300/IC400
  uPC14312H, plus regulator transistors and zeners [SVC p.118-119].

## MAME conflicts / confirmations from this section
1. **DIP switches (MAME cites p.88): confirmed.** Bit order, polarity and meanings match Table 10-1 [SVC p.88].
2. **Timer -> FIRQ: supported.** In flowchart 11-1, the suspects for a stuck **/FIRQ (IC1 pin 4)** are IC16, IC22
   and IC17. In flowchart 11-8, the 1/60 s timer pulse passes through IC16 and IC22 to IC1 [SVC p.91, p.98].
   This agrees with MAME's FIRQ-on-60 Hz. It **conflicts with the user manual's Table S.2, which says
   "Timer interrupt (IRQ)" at $FFCA**. The service manual's circuit-explanation section (another fork) should
   settle it.
3. **$FFD4 time mask:** `POKE &HFFD4,0` releases the mask [SVC p.98]. This matches MAME, where bit 7 = 1 masks.
4. **Beeper:** IC93 (LS74 D flip-flop) pin 5 (Q) drives Q1 to the speaker, clocked at pin 3 from the I/O
   decoder IC13 [SVC p.98]. So the speaker is a **latched data bit** written by an I/O strobe. That matches
   MAME's `level_w(BIT(data,7))` on $FFD3, although the bit number is not shown here.
5. **Cassette tones:** IC124 (LS93) generates **2.4 kHz and 1.2 kHz** for SAVE [SVC p.99]. Load uses an LM565
   PLL centred at 1.7 kHz [SVC p.82]. That matches MAME's 1200/2400 Hz FSK.
6. **NMI source:** IC14 (LS74) and IC15 (LS93 4-bit counter) appear in the NMI-stuck list [SVC p.91].
   That fits the Peach ROM Notes' "$FFD1 TRACE: NMI raised N cycles after the write" (a counter delay). **MAME
   does not implement this.**
7. **Light pen** feeds IC18 (LS74) and IC22 to IC1, and it is in the IRQ-stuck list. Light pen is an **IRQ**
   source [SVC p.91, p.100]. MAME has no light pen.
8. **RAM:** the standard machine has 32 KB DRAM plus a 16K x 5 colour RAM [SVC p.115-116]. The power-on banner
   reads `14186 Bytes Free` in hi-res mode [SVC p.84]. Use this as a golden-screen check.
9. **Colour order** black, blue, red, magenta, green, cyan, yellow, white [SVC p.105] matches MAME's BRG palette.
