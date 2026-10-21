# MB-6890 schematic notes (from the service manual, images p084-p123)

## Status: the circuit diagram is NOT in this copy
The service manual's TOC lists "13. Basic circuit diagram", "14. Basic P.C.B. layout" and "15. Waveform of each
block" after printed page 102 [SVC p.1]. In the manualslib copy (2236613), printed p.113 (img 115) runs straight
into the printed p.114 parts list (img 116). Images 122 and 123 are blank all-guides.com watermark pages, and
the manualslib HTML viewer shows nothing on them either. **There is no schematic, PCB layout or waveform page in
this copy**, so it cannot be judged legible or not. It is simply absent.
- Lead: 1000bit.it lists "Hitachi Personal Computer MB-6890 Service Manual" (1981-12-30, 29 MB, shared by
  Jonathan Edwards) at `https://www.1000bit.it/support/manuali/download.asp?id=1083`. It needs a free login and
  may include the foldouts. computerarchive.org once hosted
  `files/comp/manuals/hitachi/Hitachi Personal Computer MB-6890 Service Manual.pdf`. The domain no longer resolves.

What follows is reconstructed from the **parts list** [SVC p.114-119], the **adjustment / jumper figures**
[SVC p.82-83] and the **troubleshooting flowcharts** [SVC p.91-101]. The flowcharts name specific IC pins
per function. Every role marked *(inferred)* is deduced from those charts plus the standard TTL pinouts, not
read from a schematic. The circuit-explanation chapter (printed p.10-80, another fork's pages) should confirm or
correct them.

## Chip list by function

### CPU, ROM and bus
| IC | Part | Role |
|---|---|---|
| IC1 | HD6809P / MC6809L | MPU (internal-clock 6809, fed with external clock on EXTAL) [SVC p.83, p.114] |
| IC2 | (socket) | BASIC expansion ROM, $8000-$9FFF (per Table 6-5, printed p.46, outside this share) |
| IC3 | uPD2364C-330 | 8 KB mask ROM (BASIC $A000) [SVC p.114] |
| IC4 | uPD2364C-331 | 8 KB mask ROM (BASIC $C000) [SVC p.114] |
| IC5 | uPD2364C-332 | 8 KB mask ROM (BASIC $E000-$FEFF + monitor/vectors $FFF0-$FFFF) [SVC p.114] |
| IC6 | SN74LS245N | Data bus transceiver *(inferred; data-bus chart)* [SVC p.92] |
| IC7, IC8, IC9 | HD74LS367AP | Address bus buffers ("input/output signal similar" check in the address-decoder branch) [SVC p.91] |
| IC10, IC19, IC20 | HD74LS367AP | Bus/control buffers [SVC p.114] |
| IC11 | HD74LS139P | Address/strobe decoder; pin 7 pulses at power-on; pin 11 is on the data-bus path [SVC p.91-92] |
| IC12, IC13 | HD74LS138P | I/O decoders. IC13 clocks the beeper FF (IC93) and is in the timer path [SVC p.91, p.98] |
| IC24 | HD74LS125AP | Bus buffer on the interrupt/timer path ("IC24 pin 4 and 13 L") [SVC p.92, p.98] |
| IC30 | HD74LS30P | 8-input NAND, likely the A15-A8 = $FF page detect *(inferred)* [SVC p.91] |
| IC33 | HD74LS02P | RAM bank select from A15/A14 (RAM1/RAM2 SEL), per printed p.46 |
| IC137 | HD74LS139P | RAM-expansion connector decoder (A15-A11 -> 1Y0-1Y2, 2Y0-2Y), per printed p.46 |
| IC138 | HD74LS11P | Data-bus control gating [SVC p.92] |

### Clock / timing chain
| IC | Part | Role |
|---|---|---|
| X1 | crystal (no frequency in parts list) | Master oscillator. MAME's bml3.h gives 32.256 MHz citing p.48 [SVC p.118] |
| IC43 | HD74S04P | Crystal oscillator / clock buffer [SVC p.83, p.93] |
| IC37 | SN74LS163N | Master divider. Its outputs feed the CPU EXTAL path and the character clocks. JP8/JP9 tap IC37 pin 13 [SVC p.83, p.93] |
| IC42 | HD74LS164P | Shift register producing delayed timing phases. JT2 picks the tap; C187 (180 pF) sits across pins 7-8 [SVC p.83] |
| IC38 | HD74LS157P | Clock/timing select (40/80 column) *(inferred)*; "correct signals at IC38 outputs" is the first timing check [SVC p.91, p.93] |
| IC41 | HD74LS367AP | Timing buffer; pin 13 feeds the CRTC clock (IC36 pin 21) [SVC p.93] |
| IC140 | HD74LS367AP | Timing jumper path (JP9/JP10 at pins 11/12) [SVC p.83] |
| IC28, IC34, IC35, IC44, IC45, IC46 | gates | Timing gates in the timing chart [SVC p.93] |

The MPU timing is trimmed per CPU grade with JT2, C187 and JP8-JP10 (Table 8-1) [SVC p.83]. The CPU clock is
therefore derived from, and phase-locked to, the video/DRAM counter chain. That matters for DRAM/video
interleave: the CPU and CRTC share RAM through time multiplexing.

### Video
| IC | Part | Role |
|---|---|---|
| IC36 | HD46505SP | CRTC. Pin 21 = CLK; pins 39/40 = VSYNC/HSYNC checked for "synchronous signal" [SVC p.91, p.93] |
| IC52-IC55 | HD74153P x4 | DRAM address multiplexers (CPU vs CRTC, row/column) *(inferred; "pulse at inputs/outputs of IC52-IC55" in the RAM chart)* [SVC p.94] |
| IC40 | HD74LS283P | 4-bit adder in the video address path (hi-res row-to-address computation) *(inferred)*; pins 1/4/10/13 checked in the graphic-mode chart [SVC p.97] |
| IC51, IC147, IC141 | HD74LS157P | Address/mode multiplexers. IC51 pin 15 (enable) depends on IC39 [SVC p.94, p.97] |
| IC39 | HD74LS174P | Mode latch (likely the $FFD0 mode-select register) *(inferred: "IC51 pin 15 L? NO -> IC39 defective" for graphic mode; IC39 also in the cassette-input path, which matches $FFD0 bit 5 RS-232/cassette select per the Peach ROM notes)* [SVC p.97, p.99] |
| IC112 | HD74LS153P | Graphic-mode data select [SVC p.97] |
| IC113, IC114 | HD74LS257P | Hi-res address/data muxes [SVC p.97] |
| IC56-IC76 | HM4716AP-1 x21 | 32 KB main DRAM (16 chips) + 16Kx5 colour RAM (5 chips, IC64-IC68) [SVC p.94, p.115-116] |
| IC77 | HD74LS174P | **Colour-register latch.** Its pin 9 output feeds pin 2 (DIN) of IC64-IC68, so it is the $FFD8 colour data written into colour RAM *(inferred)* [SVC p.94] |
| IC80, IC139 | HD74LS367(A)P | RAM-to-CPU data buffers [SVC p.92, p.94] |
| IC48, IC142-IC145, IC32, IC45, IC49 | gates | RAS/CAS/WE timing [SVC p.94] |
| IC107 | uPD2332C-328 | **Character generator ROM, 4 KB** (2332 = 32 Kbit) [SVC p.118] |
| IC108, IC109 | HD74LS174P | Character / attribute latches *(inferred)* |
| IC115 | HD74LS174P | Attribute latch; pins 5/7/10 (Q outputs) must be high for video [SVC p.95] |
| IC116 | HD74LS175P | Attribute/colour latch; pin 14 output [SVC p.95] |
| IC117 | SN74LS166N | **Pixel shift register** (8-bit PISO). Pin 13 = QH serial video ("brightness signal") [SVC p.91, p.95] |
| IC131 | HD74LS86P | XOR: reverse video / cursor *(inferred)* [SVC p.95] |
| IC118 | HD74LS158P | Inverting 2:1 mux producing the RGB outputs (pins 4/7/9); pin 15 = enable/blank *(inferred)* [SVC p.95] |
| IC129, IC130, IC148, IC23 | gates/FF | Video blanking/timing; IC129 pin 9 [SVC p.95, p.97] |
| IC132, IC135 | HD74S05P, HD7405P | Open-collector drivers to the colour (JB) and B/W outputs; Q5 = video amplifier [SVC p.95] |

### Keyboard
| IC | Part | Role *(inferred from chart 11-6)* [SVC p.96] |
|---|---|---|
| IC101, IC102 | HD74LS93P x2 | Scan counter (8 bits). IC102 pins 2/3 are its reset inputs |
| IC86 | HD74159P | 4-to-16 open-collector decoder driving the keyboard rows |
| IC90 | HD74LS151P | 8-to-1 mux sensing the columns (pin 5 = Y) |
| IC89 | HD74LS174P | Latch for the scan code on a key hit |
| IC88 | HD74LS367P | Buffer putting the key code onto the data bus ($FFE0 read) |
| IC95 | HD74LS05P | Open-collector interrupt drive (pin 11) |
| IC98 | HD74LS125AP | Gating (pin 4) |
| IC97 | HD74LS32P | Scan clock input at pin 9, from IC130/IC134 (hsync-derived) |
| IC99 | HD74LS74AP | BREAK-key latch (pin 9 = Q2), read at $FFC8 |
| IC130, IC134, IC136, IC141 | LS74, LS93, LS08, LS157 | GRAPH-key and scan-clock logic |
| IC94, IC100 | LS02, LS04 | Gating |

A 4-bit row decoder (16 rows) plus an 8-column mux gives a 128-position matrix, which matches the 7-bit scan
code plus bit 7 flag read at $FFE0 (see the Peach ROM notes). The scan clock comes from the IC130/IC134 chain.
MAME's "keyboard timer driven by hsync" (it cites p.65) is consistent with this.

### Interrupts (6809 pin 2 = /NMI, pin 3 = /IRQ, pin 4 = /FIRQ)
From chart 11-1 (MPU pin stuck low) and the per-function charts [SVC p.91, p.96, p.98, p.100]:
| Line | Suspect ICs | Sources *(inferred)* |
|---|---|---|
| /NMI (pin 2) | IC14 LS74, IC15 LS93, IC22 LS05, IC23 LS04, IC94 LS02, IC95 LS05 | Keyboard/BREAK path, and a counter-delayed NMI (IC15 LS93 + IC14 FF: the $FFD1 single-step "trace" NMI in the Peach ROM notes) |
| /FIRQ (pin 4) | IC16 LS74, IC22 LS05, IC17 LS74 | **60 Hz timer.** Chart 11-8: 1/60 s pulse at IC16 pin 9 and pin 5, then IC22 pin 8, then IC1 |
| /IRQ (pin 3) | IC22 LS05, IC17 LS74, IC18 LS74, IC95 LS05, IC96 LS08 | Keyboard (IC95), light pen (IC18, chart 11-12), probably the ACIA/PIA |
IC22 (LS05 open-collector) is the common wired-OR interrupt driver.
- **Conflict:** the user manual's Table S.2 calls $FFCA "Timer interrupt (IRQ)", and the Peach ROM notes agree.
  These service-manual charts point to **FIRQ** for the timer, which is what MAME does. Check against the
  circuit-explanation text (printed p.10-80) and the ROM's vector usage.

### Sound
- IC93 (LS74) Q1 (pin 5) -> Q1 2SC458 -> Q2 2SA673 / Q3 2SC1213 push-pull -> 16 ohm 0.4 W speaker through
  **R36 volume (2 kohm)**. IC93's clock (pin 3) comes from decoder IC13 / buffer IC20. **The speaker level is a
  data bit latched by an I/O write** ($FFD3) [SVC p.2, p.98, p.114, p.117].

### Cassette
- **Save:** IC124 (LS93) divides down to **2.4 kHz (pin 8) and 1.2 kHz (pin 11)**. IC126 (LS74) / IC125
  (LS00) select the tone from the ACIA TxD. Then to JA [SVC p.99].
- **Load:** JA -> limiter D3/D4 -> IC127 **LM565 PLL** (in pin 2, out pin 7), centred at 1.7 kHz with R109
  (TP13/TP14 null) -> IC128 HD75108 (comparator/line receiver) -> IC111 (LS157, pins 4/9) -> IC122/IC123
  (LS93) -> ACIA IC84 (HD46850). IC111 also selects between the RS-232C and cassette clocks/data under IC39
  (mode latch) [SVC p.82, p.99]. MAME's bml3.h notes that IC111 takes 16.128 MHz and 1.008 MHz clocks, with RS/C
  SW selecting (it cites p.67).
- **Motor:** RL1 sub-miniature relay [SVC p.118] (remote, $FFD2).

### Serial / printer / light pen
- RS-232C: ACIA IC84 (HD46850P), drivers **IC119 HD75188 / IC120 HD75189**, CS3 baud factor, CS4 handshake
  strapping [SVC p.89-90, p.116].
- Printer: PIA IC85 (HD46821P) data/strobe -> IC94 pin 4 -> IC95/IC105 (LS05 open-collector) to the printer
  connector [SVC p.100].
- Light pen: JC pins 1/2 -> IC21 (LS14 Schmitt) / IC25 pin 11 -> IC17/IC18 FF (IC18 pin 9) -> IC22 ->
  MPU interrupt (IRQ) [SVC p.100]. Presumably also to the CRTC LPSTB. R112 (500 ohm) adjusts the threshold.

## Connectors [SVC p.2, p.87, p.118]
- JA: 6-pin DIN, cassette (pin 5 = input signal, pin 2 = ground per the PLL adjustment) [SVC p.82].
- JB: 5-pin DIN, colour display. JC: 8-pin DIN, light pen (pins 1, 2 = pen signal). B/W monitor output.
- RS-232C (25P), printer (36P), 28P connectors R3/R4 (RAM3/RAM4 memory expansion), **six 56-pin IF1-IF6
  expansion slots**. The slot pinout is in the Australian Phase magazine (see peach-misc notes); it is not in
  this section.

## Things still unknown from this share
- Crystal frequency (only MAME's p.48 citation). The divider ratios of IC37 / IC42 / IC38. The exact CRTC clock in
  40 vs 80 columns. The exact decode of each $FFxx strobe onto IC12/IC13. The colour-RAM bit order. All of these
  need the circuit-explanation chapter (printed p.10-80) or the missing foldout schematic.
