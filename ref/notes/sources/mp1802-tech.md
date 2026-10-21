# MP-1802 floppy card / MP-3550 drive unit: notes from the Technical Manual

Source: "Basic Master Level-3 MP-3550 / MP-1802 Technical Manual", Nissei Sangyo / Hitachi, 1983
(inner title page: "Minifloppy Disk Drive Unit MP-3550 and Minifloppy Disk Card MP-1802 Service
Manual", 1982). The local copy is 92 page images from manualslib in
`ref/docs/manuals/MP-1802-technical-manual/pNNN.jpg|png`.

Citation format: [MP1802Tech p.N / imgNNN]. N is the printed page. For printed pages 1-71, the image
number is the printed page + 3. The schematic fold-outs (img083-img092) have no printed page numbers.

## 1. Scope and specs

- The MP-1802 plugs into a Level-3 expansion slot (I/F-1 to I/F-6). It connects MP-3550 UNIT-1, and
  UNIT-2 daisy-chains from UNIT-1. It supports the **MB-6890 and the Mark II**
  [MP1802Tech p.1 / img004].
- **The card takes two slots.** It is two PCBs, MDB-A and MDB-B, each with its own card-edge
  connector, joined by a 40-pin cable. The manual's example uses slots I/F-1 and I/F-2.
  [MP1802Tech p.4, p.16-20, p.64 / img007, img019-023, img068]
- The MP-1802 cannot be fitted at the same time as the MP-1800/MP-1801 (3" card) or the MP-1806
  (standard 8" floppy card) [MP1802Tech p.63 / img067].
- System software is Disk BASIC **MA-5320**. It needs **40 KB of RAM**, which means an MP-9717 or
  MP-9718 RAM card (8 KB setting) in the RAM3 socket. The manual's chip-switch table gives
  CS300=3 and CS301-CS303 partly illegible ("0"?) [MP1802Tech p.65 / img069].
- **MP-3550 capacity** [MP1802Tech p.2 / img005]:

  | Item | Value |
  |---|---|
  | Per unit (2 drives) | 655 KB |
  | Per drive | 328 KB |
  | Sides | 2 |
  | Cylinders | 40 |
  | Sectors per track | 16 |
  | Bytes per sector | 256 |

  The page notes that the figures depend on the system disk. Section 7-3 gives
  163.84 KB/side × 2 = 327.68 KB [MP1802Tech p.29 / img032].
- **Drive:** 300 rpm (200 ms per revolution), 250 kbit/s MFM, DC brushless motor
  [MP1802Tech p.3, p.29, p.31, p.37 / img006, img032, img034, img040]. The mechanisms are Canon
  **MDD6108** [img086]. The unit has 68 ICs and draws 55 W.
- **MP-1802 card:** handles 2 units = 4 drives. It has 28 ICs, 4 transistors and 2 diodes, and draws
  3 W at +5 V [MP1802Tech p.3 / img006]. The card's +5 V is switched by Q641-Q644, fed from MP-3550
  UNIT-1, and follows the Level-3's power on/off [MP1802Tech p.51 / img054].

## 2. I/O map (Table 7.1) [MP1802Tech p.39-40 / img042-043]

| Address | Device | R/W | Function |
|---|---|---|---|
| $FF00 | IC618 FDC (MB8866) | R | status register |
| $FF00 | IC618 | W | command register |
| $FF01 | IC618 | R/W | track register |
| $FF02 | IC618 | R/W | sector register |
| $FF03 | IC618 | R/W | data register |
| $FF04 | IC625 (read buffer) / IC615 (write latch), "MDD SEL" | R/W | see below |

$FF04-$FF07 is decoded as one block: "image included MDD SEL" [MP1802Tech p.41-42 / img044-045].
In Fig 7.20 the memory map shows FDC at $FF00-$FF03 and MDD SEL at $FF04-$FF07.

### $FF04 read [MP1802Tech p.39-40, p.45 / img042-043, img048]

| Bit | Meaning |
|---|---|
| D7 | **/DRQ**: "L" = data request |
| D6-D1 | not used (x) |
| D0 | **/IRQ**: "L" = interrupt request (FDC INTRQ, inverted) |

The text on p.45 confirms it: "DRQ and IRQ are output at D7 and D0 respectively". In the schematic,
FDC pin 38 (DRQ) and pin 39 (IRQ) each go through an HD74LS14 inverter (IC626) to IC625 tri-state
buffers on D7 and D0 [img051, img084].

### $FF04 write: IC615, HD74LS174P latch, cleared by /RES [MP1802Tech p.39-40, p.45 / img042-043, img048, img051, img084]

| Bit | Name | Meaning |
|---|---|---|
| D7 | — | write 0 |
| D6 | NMI MASK | "H" masks the FDC IRQ (pin 39) so it does not reach /NMI |
| D5 | DOUBLE DEN | "H" = double density (MFM); "L" = single density (FM) |
| D4 | SIDE 1 | "H" = side 1 head; "L" = side 0 |
| D3 | MOTOR ON | "H" = drive motors run; "L" = stopped |
| D2 | — | write 0 |
| D1-D0 | drive select | see the table below |

| D1 | D0 | Drive | Unit |
|---|---|---|---|
| L | L | 0 | 1 |
| L | H | 1 | 1 |
| H | L | 0 | 2 |
| H | H | 1 | 2 |

In other words, drives 0-3 map to SELECT 0-3 on the drive bus. IC650 (HD74LS139) decodes the two
bits only while MOTOR ON = H (Table 7.2) [MP1802Tech p.48 / img051].

## 3. Interrupt wiring [MP1802Tech p.40, p.45 / img043, img048, img051, img084]

- The FDC **IRQ goes to the bus /NMI line** (slot pin A-38), not IRQ or FIRQ.
- Path: FDC IRQ → IC626 inverter → IC627 (HD74LS02 NOR, other input NMI MASK) → IC616 (HD7406
  open collector) → /NMI. So /NMI is low while INTRQ = 1 and NMI MASK = 0.
- R621, R622 and C634 form an RC noise filter.
- The card-edge pinout lists no IRQ or FIRQ pin. A-38 is the only interrupt signal used
  [MP1802Tech p.17 / img020].
- DRQ is never an interrupt. Software polls it in $FF04 bit 7.

## 4. FDC, clocks and data bus

- **IC618 = Fujitsu MB8866 (MB8866C-G)** [img084; MP1802Tech p.45 / img048]. For details of the chip
  the manual points to the MP-3630/MP-1806 service manual.
- **The data bus is inverted.** The MB8866 data pins are /D0-/D7 (active low, like the FD1791). They
  connect straight to the card's internal bus and through IC622 (SN74LS245N) to the slot, with no
  inverter [img049, img084]. The CPU therefore reads and writes the complement of each register.
  This matches Calder's "data bus inverted" note. MAME's `mb8866_device` sets
  `bus_invert_value = 0xff`, so it agrees.
- **Clocks** [MP1802Tech p.45-47 / img048-050, img084]:
  - 16MCLK comes from the slot (pin A-47) through IC625 into IC628 (HD74LS93P), which divides it to
    **4 MHz (QC) and 1 MHz (QA)**.
  - The 1 MHz output drives FDC CLK (pin 24).
  - The 4 MHz output (4MCLK, via IC626) drives the write-precompensation shifter and the FM RCLK
    decoder.
  - The time chart labels the input 62.5 ns (a nominal 16 MHz). The real slot clock is 16.128 MHz,
    so the FDC runs at 1.008 MHz. MAME uses `32.256_MHz_XTAL/2/16` = 1.008 MHz, which agrees.
- **Write precompensation:** in MFM, IC614, IC619 and IC621 (SN74LS166) shift WD early or late
  according to the FDC's EARLY (pin 17) and LATE (pin 18) outputs. In FM, the uncompensated
  "SINGLE WD" (from IC626 pin 8) is written instead [MP1802Tech p.45-47 / img048-050].
- **Read path, MDB-B:** IC644 (HD74LS157) switches between two read paths under DOUBLE DEN
  [MP1802Tech p.48 / img051].
  - DD: RAW READ = READ DATA and READ CLOCK = D-RCLK, from the MP-3550's VFO data separator.
  - SD: S-READ DATA and S-RCLK, from the card's own RCLK decoder (IC648 HD74LS123, IC643 HD74LS161,
    IC646 HD74LS74 clocked at 4 MHz).
  - FM timing: 4 µs clock-to-data and 8 µs bit cell [MP1802Tech p.50-51 / img053-054].
- **Head-load timing:** IC648 (HD74LS123) produces HEAD LOAD TIME back to the FDC (HLT, pin 23),
  about 60 ms after HEAD LOAD rises, set by Tw ≈ 0.45 × C652 × (R658+R659). The text says
  "about 100 ms", and the minimum head settling time is 35 ms [MP1802Tech p.50 / img053].
- IC646 holds IC650 off (no drive select) after power-on until the first MOTOR ON
  [MP1802Tech p.50 / img053].
- The MP-3550 time chart [MP1802Tech p.39 / img042] shows:
  - INDEX period 200 ms
  - STEP pulses 4 µs wide at a 12 ms rate
  - READY goes low some time after MOTOR ON and the first index pulses

## 5. Address decoding and boot ROM [MP1802Tech p.41-44 / img044-047, img084]

- **IC620 (HD74LS138P):**
  - Enabled by **/EX-I/O** (slot A-32). The main board decodes /EX-I/O for **$FF00-$FF7F**.
  - Inputs are A2, A3 and A4. Y0 = $FF00-$FF03 (FDC) and Y1 = $FF04-$FF07 (MDD SEL).
  - A5 and A6 feed further enables. Jumper CS611, through IC611, inserts an inverter on one address
    line. It is shipped on 1-2; the alternate position presumably moves the card to another base
    address.
- **Strobes:**

  | Gate | Low when | Use |
  |---|---|---|
  | IC613 pin 12 | $FF04-07 and R/W·E | $FF04 read (IC625) |
  | IC613 pin 8 | $FF04-07, write, Q high | IC615 latches on the rising edge of Q |
  | IC612 pin 8 | $FF00-03, write, E | FDC /WE |
  | IC612 pin 6 | $FF00-03, read, E | FDC /RE |

- **Boot ROM IC617 = HN462716 (a 2716, 2 KB EPROM, labelled "DD-1"):**
  - Addressed by A0-A10. Enabled when IC623 (HD74LS30 8-input NAND) pin 8 goes low.
  - IC623 decodes **$F800-$FEFF**: A11-A15 all high, NOT(A8·A9·A10), VMA, and EXPROM KILL inactive
    on a read cycle (gated by IC627 with R/W OUT).
  - Jumper CS612 (shipped 1-2) connects this decode to the ROM's CE/OE. In the other position R617
    pulls it high, which disables the boot ROM.
- **/ROM KILL (slot A-29, open collector through IC616):** asserted, via IC613 pin 6, whenever the
  card decodes $F800-$FEFF, $FF00-$FF03 or $FF04-$FF07 during VMA. It tells the main board to
  deselect its own ROM for that cycle, so the card's boot code overlays BASIC at $F800-$FEFF.
- **EXPROM KILL (slot A-30, input):** when asserted by the main board, the card's ROM decode is
  inhibited.
- **IC622 (LS245) data buffer:** enabled by IC624 pin 11 whenever IC613 pin 6 is active and E is
  high. Its direction follows R/W OUT [MP1802Tech p.42, p.44 / img045, img047].
- The memory map with MA-5320 loaded (Fig 7.20, 40 KB RAM) [MP1802Tech p.41 / img044]:

  | Range | Contents |
  |---|---|
  | $0000-$03FF | work area (1) |
  | $0400 up | display/colour RAM (modes 1-4, with 5-bit colour RAM) |
  | after display RAM | work area (2), then user RAM |
  | **$8AFC-$9FFF** | **Disk BASIC RAM area** |
  | $A000-$FEFF | BASIC/monitor ROM (24 KB), with the boot ROM overlaid in the $F800 region |
  | $FF00 | FDC |
  | $FF04 | MDD SEL |
  | $FF08-$FFEF | I/O |
  | $FFF0-$FFFF | interrupt vectors |

  The boot-ROM label in the figure is illegible.

## 6. Disk format [MP1802Tech p.27-29 / img030-032]

- 16 soft sectors per track, 40 tracks (00-27h), 2 sides. Gap fill is $4E in MFM and $FF in FM.
- The ID field holds track (00-27h), side (00 = single-sided or side 0, 01 = side 1),
  sector (01h-10h) and length code (00 = 128 bytes, 01 = 256 bytes).
- **Fig 7.7 track layout, in bytes:**

  | Field | FM count | FM value | MFM count | MFM value |
  |---|---|---|---|---|
  | GAP0 | 40 | FF | 80 | 4E |
  | SYNC | 6 | 00 | 12 | 00 |
  | Index mark | 1 | FC* | 3 + 1 | F6* + FC |
  | GAP1 | 26 | FF | 50 | 4E |
  | SYNC | 6 | 00 | 12 | 00 |
  | ID AM | 1 | FE* | 3 + 1 | F5* + FE |
  | ID | 4 | | 4 | |
  | CRC | 2 | | 2 | |
  | GAP2 | 11 | FF | 23 | 4E |
  | SYNC | 6 | 00 | 12 | 00 |
  | Data AM | 1 | FB*/F8* | 3 + 1 | F5* + FB/F8 |
  | Data | 128 | | 256 | |
  | CRC | 2 | | 2 | |
  | GAP3 | 27 | FF | 55 | 4E |
  | GAP4 | 247 | FF | 598 | 4E |

  \* marks a byte written with a missing clock. In WD-command terms, F5/F6 are what the format
  command writes as A1/C2.
- So **FM = 16 × 128-byte sectors** and **MFM = 16 × 256-byte sectors**. This fits Calder's note that
  track 0 side 0 is single density and the rest double density
  (`ref/notes/sources/peach-misc.md`).

## 7. Connectors

### 7.1 MP-1802 card edge, MDB-A (56-pin Level-3 slot) [MP1802Tech p.16-18 / img019-021]

| Pins | Signal |
|---|---|
| 1-2 | unused |
| 3-10 | D0-D7 |
| 11-26 | A0-A15 |
| 27, 28 | unused |
| 29 | /ROM KILL (card → L3) |
| 30 | EXPROM KILL (L3 → card) |
| 31 | unused |
| 32 | /EX-I/O (L3 → card) |
| 33 | R/W OUT |
| 34 | VMA |
| 35 | E |
| 36 | Q |
| 37 | /RES |
| 38 | /NMI (card → L3) |
| 39-46 | unused |
| 47 | 16MCK (16 MHz clock) |
| 48 | GND |
| 49 | unused |
| 50 | GND |
| 51-54 | unused |
| 55 | GND |
| 56 | unused |

**MDB-B card edge** uses only pins 2, 48, 50 and 55 (GND) and pin 56 (+5 V); the other pins have no
terminals [MP1802Tech p.18 / img021].

### 7.2 MDB-A ↔ MDB-B, 40-pin [MP1802Tech p.19-20 / img022-023]

| Pin | Signal | Pin | Signal |
|---|---|---|---|
| 1 | UNIT SELECT 2^1 | 3 | UNIT SELECT 2^0 |
| 5 | /INDEX | 7 | STEP |
| 11 | WRITE GATE (H) | 13 | SIDE 1 (H) |
| 15 | WRITE DATA (DD) | 17 | READY (H) |
| 19 | /TRACK 00 | 21 | /WRITE PROTECT |
| 23 | STEP DIRECTION | 25 | RCLK |
| 27 | /SINGLE WD | 29 | /DOUBLE DEN |
| 31 | 4M CLOCK | 33 | MOTOR ON (H) |
| 37 | HEAD LOAD (H) | 38 | HEAD LOAD TIME |
| 39 | /RAW READ | | |

Pins 14, 16, 18, 20, 22 and 24 are +5 V; the rest are GND or unused.

### 7.3 MP-1802 UNIT-1 connector and MP-3550 50-pin "C" connector [MP1802Tech p.5-7, p.13-15 / img008-010, img016-018]

| Pin | Signal | Pin | Signal |
|---|---|---|---|
| 1 | /HEAD LOAD | 9 | /DIRECTION IN |
| 2 | /SELECT 3 | 10 | /STEP |
| 3 | /READY | 11 | /WRITE DATA |
| 4 | /INDEX | 12 | /WRITE GATE |
| 5 | /SELECT 0 | 13 | /TRACK 00 |
| 6 | /SELECT 1 | 14 | /WRITE PROTECT |
| 7 | /SELECT 2 | 15 | /READ DATA (after the VFO) |
| 8 | /MOTOR ON | 16 | /SIDE 1 (L = side 1) |

- 17: D-RCLK (VFO data clock, unit → card)
- 18-25: +5 V (the unit powers the card)
- 26: DOUBLE DEN (H = DD)
- 27-48: GND
- 49-50: unused

The UNIT-2 port is the same except that pin 2, pin 7 and pins 18-25 are unused
[MP1802Tech p.10-12 / img013-015].

### 7.4 MP-3550 internal drive connector "E" (34-pin, Shugart-style) [MP1802Tech p.8-9 / img011-012]

| Pin | Signal |
|---|---|
| 2 | /HEAD LOAD |
| 6 | /READY |
| 8 | /INDEX |
| 10 | /SELECT 0 |
| 12 | /SELECT 1 |
| 16 | /MOTOR ON |
| 18 | /DIRECTION IN |
| 20 | /STEP |
| 22 | /WRITE DATA |
| 24 | /WRITE GATE |
| 26 | /TRACK 00 |
| 28 | /WRITE PROTECT |
| 30 | /READ DATA |
| 32 | /SIDE 1 |

Odd pins are GND; pin 14 and pin 34 are unused.

## 8. Chip list, MP-1802 [img084-085, text p.41-51]

**MDB-A:**

| Ref | Part | Function |
|---|---|---|
| IC611 | HD74LS14P | |
| IC612 | HD74LS10P | strobes |
| IC613 | HD74LS10P | strobes and ROM KILL |
| IC614 | HD74LS74AP | write precompensation |
| IC615 | HD74LS174P | $FF04 mode latch |
| IC616 | HD7406P | open-collector /NMI and /ROM KILL |
| IC617 | HN462716 "DD-1" | boot ROM |
| IC618 | MB8866C-G | FDC |
| IC619 | HD74LS74AP | write precompensation |
| IC620 | HD74LS138P | I/O decode |
| IC621 | SN74LS166AN | precompensation shifter |
| IC622 | SN74LS245N | data buffer |
| IC623 | HD74LS30P | boot ROM decode |
| IC624 | HD74LS00P | |
| IC625 | HD74LS367AP | buffers |
| IC626 | HD74LS14P | |
| IC627 | HD74LS02P | NMI mask and ROM decode |
| IC628 | HD74LS93P | clock divider |

**MDB-B:**

| Ref | Part | Function |
|---|---|---|
| IC641 | HD74LS367AP | |
| IC642 | HD7406P | drivers |
| IC643 | HD74LS161P | RCLK decoder |
| IC644 | HD74LS157P | SD/DD switch |
| IC645 | HD7406P | drivers |
| IC646 | HD74LS74AP | RCLK and power-on initialisation |
| IC647 | HD74LS367AP | |
| IC648 | HD74LS123P | head settle and FM waveform restore |
| IC649 | HD74LS14P | |
| IC650 | HD74LS139P | drive select |

Q641-Q644 handle power control.

The MP-3550 FCN/IF board [img085-086] holds a VFO (MC4044 phase detector, MC4024 VCO, IC101-IC123)
and the "Rclk" separator. The MDD6108 drive schematics are on img088-092, and the MP-3550 power
supply schematic (TL494 ×2) is on img083. These pages are legible at this resolution.

## 9. Boot procedure

- This manual does not describe the boot flow beyond the hardware.
- The boot ROM (2 KB, only $F800-$FEFF visible, decoded by IC623) overlays BASIC through /ROM KILL.
  Check after fitting: Disk BASIC MA-5320 must "activate" with MP-3550 on UNIT-1
  [MP1802Tech p.65 / img069].
- Calder's notes cover the software side (bootstrap at $FE7E, loads T0 S1-2 to $4400 and so on).

## 10. Conflicts and comparisons

1. **$FF04 read, /IRQ bit.** The manual puts /IRQ on **bit 0** [MP1802Tech p.39-40, p.45]. Calder
   also says bit 0. **MAME `mp1802.cpp::read()` puts it on bit 6 (0x40). MAME is wrong.** /DRQ on
   bit 7 (active low) agrees with MAME.
2. **$FF04 write.** MAME `write()` agrees on every bit:
   - drive = bits 1-0
   - `dden_w(!BIT(5))`: bit 5 = 1 means MFM
   - `mon_w(!BIT(3))`: bit 3 = 1 means motor on
   - `ss_w(BIT(4))`
   - NMI enabled when bit 6 = 0

   Two hardware details are missing from MAME: drive select is gated by MOTOR ON (IC650), and drive
   select is held off after power-on until the first MOTOR ON (IC646).
3. **Boot ROM window.** The hardware decodes only **$F800-$FEFF** (IC623 excludes $FFxx). MAME
   `map_exrom()` also maps **$FFF0-$FFFF** to ROM offset $7F0, so the card replaces the CPU vectors.
   The manual gives no path for that. On real hardware the vectors come from the main-board ROM.
   **Flag:** MAME overlays the vectors and the hardware does not. It only matters if the 2716 image
   differs from the system ROM's vectors at $FFF0.
4. **Interrupt.** The FDC INTRQ drives **NMI**, as in MAME (`raise_slot_nmi`). No IRQ or FIRQ is
   used. Agrees.
5. **FDC clock.** 16MCLK/16 = 1.008 MHz. Agrees with MAME's comment "16MCLK divided by IC628
   (HD74LS93P)".
6. **Data-bus inversion.** Hardware has no inverter, so the bus is inverted; MAME's MB8866 sets
   `bus_invert_value=0xff`. Agrees.
7. **I/O range.** MAME installs only $FF00-$FF04. The hardware decodes $FF04-$FF07 as images of
   $FF04 (minor).
8. **Drive count.** The card supports four drives (two units). MAME configures four connectors, with
   two populated by default. Agrees.
9. **Sector size.** Some L3 manual notes give 128-byte sectors. That applies to FM (track 0 side 0)
   or to the 3" MP-1805 system. MFM tracks on the MP-1802 are 16 × 256 bytes [MP1802Tech p.2, p.28].
10. **MP-1805 vs MP-1802 boot ROMs.** Both map their boot ROM at $F800, so only one card can be
   fitted. That agrees with this manual's "cannot use MP-1802 with MP-1800/1801/1806" [p.63].
