# Peach / misc small documents: extracted facts

Working notes from a fork. Page numbers are **PDF page numbers** (1-based). Where the printed page
number differs it is given as "printed N". MAME = `mame/src/mame/hitachi/bml3.cpp` and
`mame/src/devices/bus/bml3/mp1802.cpp` in the local checkout.

Background: the MB-6890 was sold in Australia/NZ as the **Hitachi "Peach"** [PeachBrochure p.2]
[NZBB p.13]. The English-language Peach user-group literature (PUN = "Peach User Notes", later
"The Australian Phase") is therefore L3 literature.

---

## 1. Peach User Notes Vol.2 No.3 (+ No.4 pages), 1984 — `PUN-v2n3`
File: `ref/docs/peach/Peach-User-Notes-v2n3/Peach_User_Notes_Volume_2_Number_3.pdf` (18 pp).
One line: Australian Peach user-group newsletter pages, mostly an in-depth MB-S1 review, an S1
expansion-slot pinout, S1 benchmarks, and a Q&A on S1 compatibility with MB-6890 hardware.
(PDF pp.1-10 are Vol.2 No.3 printed pp.8-17; pp.11-18 are Vol.2 No.4 printed pp.6-11, 24-25.)

MB-S1 hardware facts:
- S1 is a CPU box with detachable keyboard; front panel has keyboard connector, speaker volume,
  reset, power, earphone socket and a **system mode switch** that switches between S1 mode and
  "PEACH emulation mode" (= B mode / Level 3 mode) [PUN-v2n3 p.1].
- Rear panel: B/W monitor, cassette, Centronics printer, mouse; optional RS-232C. **No light pen
  and no RS-232 as standard** (unlike the Peach) [PUN-v2n3 p.2] [PUN-v2n3 p.12: "A light pen circuit
  has not been provided"; RS-232 is a DB25 + short cable into a socket on the CPU board].
- Three expansion connectors on the main board: a small one is the **video interface card**
  (VTR control / superimpose); two others are expansion slots, each of which can take an
  "intermediate card" giving two slots (max 4) [PUN-v2n3 p.2]. A pinout of the S1 expansion
  connector is printed on p.2 (scan is low resolution; signals visible include D0-D7, A0-A15,
  BS, /EXROM-KIL(OUT), VMA-OUT, Q(OUT), NMI, FIRQ, VMA-CTRL, TMG2 OUT?, SOUND IN, -5V, A16-A19?,
  MPX OUT, CAS OUT, FASCAS?, SYSTEM SEL IN?, MEMIN?, BOIN?) — needs a better scan to transcribe.
- Two intermediate-card styles: one brings out only the PEACH Level 3 pinout (for L3 peripherals
  such as the **1802 disk controller**), the other all S1 pins (for S1 memory boards). Photo
  labels: **MPC-EX01S** (S1 intermediate card) and **MPC-EX02S** (Level 3 intermediate card)
  [PUN-v2n3 p.3]. All L3 peripherals are compatible with the S1 via the L3-type intermediate card;
  L3 cards can be plugged straight into S1 ports but misalignment "could prove disastrous"
  [PUN-v2n3 p.3].
- CPU: 2 MHz 6809. **In Level 3 emulation mode the clock is reduced to 1 MHz**; it can be set back
  to 2 MHz in PEACH mode "by poking the appropriate register", but care is needed with
  peripherals such as disk drives that are incapable of 2 MHz [PUN-v2n3 p.3] [PUN-v2n3 p.12].
- MMU: the 1 MB is via a memory-management circuit adding four address lines (20 total).
  **16 memory map registers, each holding the 4 most significant address bits**; the 64K CPU space
  is 16 blocks of 4K, each block mappable from anywhere in 1 MB [PUN-v2n3 p.4].
  (Consistent with MAME `mbs1_mmu`.)
- Screen nominally 640x200; 640x400 possible "under certain conditions; use of a single colour
  only". Image generator plus three independent graphics planes (R, G, B) [PUN-v2n3 p.4].
- **Cassette baud: 300, 600, 1200 or 2400**; base FSK frequencies are changed and "the resulting
  cassettes are incompatible with the PEACH" [PUN-v2n3 p.4]. (Presumably only at the new rates;
  S1 B-mode reads L3 tapes. See also Phase p.16: a set of chip switches presets cassette baud
  300-2400.)
- In PEACH emulation mode **the cursor is shifted one character to the right** — "should be
  correctable by adjusting the registers controlling the CRTC" [PUN-v2n3 p.6]; fixed for disk
  users by changing a chip switch on the 1802 controller card (except Procalc and Flex)
  [PUN-v2n3 p.11]. **Possible emulation detail: S1 B-mode CRTC cursor-skew/timing differs from
  the L3.**
- Software failing in emulation mode: Lady Bug reads screen colours; the screen arrangement on
  the S1 differs [PUN-v2n3 p.6]. Several games failed because of the way the **colour register
  &HFFD8** is used [PUN-v2n3 p.11].
- Most MB-6890 cards work in the S1: Hitachi 1802 disk controller, Rob's Multicard, Centronics
  printer card. The **MP-1600** (MS-DOS card) does not work [PUN-v2n3 p.11].
- Mouse is optional; connector and internal hardware are standard [PUN-v2n3 p.13]. Provision on
  the CPU board for an additional PIA chip [PUN-v2n3 p.12]. Max usable RAM 512K; max BASIC program
  132K [PUN-v2n3 p.12]. Only four NEWON levels (vs MB-6890 NEWON chip switches) [PUN-v2n3 p.13].
- S1 docs supplied in Japan: a "system manual" and a "BASIC manual"; English translation was
  planned (System Manual, BASIC reference, Disk Basic manual, ~500 pages) [PUN-v2n3 p.12, p.14].
- Option list with part numbers [PUN-v2n3 p.17]: MPC-RA64S 64K RAM; MP-3560 5.25" dual DSDD;
  C14-2170 14" monitor; MP-3375 3" dual SSSD; MP-1870 single-card drive controller (for
  MP-3560); **MP-3710 mouse**; S1 and L3 intermediate cards; MP-1600 MS-DOS card for the PEACH;
  **MP-9718 16K RAM bank switched**; **MP-1802A 5.25" disk controller**; MP-1810 line printer
  card; MP-1895 PIA card; FLEX for S1.
- Benchmarks: APC BASIC benchmarks S1 (S1 mode) avg 13.5 s vs PEACH 41.0 s [PUN-v2n3 p.8]; graphics
  benchtest S1 12:23 total vs PEACH 85:14 [PUN-v2n3 p.10]. Useful only as a rough speed sanity
  check.

## 2. Notes on Hitachi Peach Double Density DOS, Peter Calder, Aug 1983 — `CalderDD`
File: `ref/docs/peach/Peach-DD-DOS-notes-Calder/Notes_On_Hitachi_Peach_Double_Density_DOS_By_Peter_Calder.pdf`
(25 PDF pages, each a 2-up spread of printed pages; PDF p.N holds printed pages 2N-4 and 2N-3
roughly — page refs below are PDF pages). One line: disassembly-based notes on the Hitachi
5.25" DD Disk BASIC: FDC registers and bit definitions, the ROM DD bootstrap at $FE7E, the boot
loader, DD disk format, directory/FAT/FCB layout, DOS RAM map. **High value for the FDC and disk
boot.**

FDC (5" DD controller; "HITACHI disc controller IC is equivalent to the Western Digital 1791")
[CalderDD p.14]:

| Addr | R/W | Meaning |
|---|---|---|
| $FF00 | R | status |
| $FF00 | W | command |
| $FF01 | R/W | track |
| $FF02 | R/W | sector |
| $FF03 | R/W | data |
| $FF04 | R | auxiliary status: **bit7 = NOT(DRQ)**, bits1-6 unused, **bit0 = NOT(IRQ)** |
| $FF04 | W | drive/mode: bit7 unused, **bit6 = NMI mask**, **bit5 = SD/DD (DD=1, SD=0)**, **bit4 = SIDE (0=side 0, 1=side 1)**, **bit3 = MOTOR ON (1=on)**, bit2 unused, **bits1,0 = drive select** |

[CalderDD p.14] (table), repeated in the bootstrap listing header [CalderDD p.20] and loader
header [CalderDD p.20/21: "FF04 DRIVE REG DATA READY(7), SD/DD(5), SIDE(4), MOTOR ON(3),
DRIVE(0-1)"].

- **"Because the DATA BUS is inverted between the CPU and the drives, the data sent to or read from
  the disc registers must be inverted"** [CalderDD p.14]. The ROM/DOS code writes complemented
  commands, e.g. `LDA #$FE` = restore ($01 inverted), `LDB #$7F` = read sector ($80 inverted),
  `LDB #$EE` = seek ($11 inverted), and `COMB` on read data [CalderDD p.19-21]. So the FDC is an
  inverted-bus part (FD1791/MB8866 style). The status is also read inverted ("NOTE: STATUS IS
  INVERTED") [CalderDD p.21].
- DOS commands used: $01 restore 12 ms step; $11 seek 12 ms; $80 read single sector no 15 ms
  delay; $A0 write single sector; $D0 force interrupt (clear, no interrupt) [CalderDD p.14-15].
- **Sector transfer is by polling DRQ in $FF04 bit 7; end-of-sector is detected by the FDC INTRQ
  raising an NMI** (vector address in RAM set via $1A9 in DD DOS / $0109-$010A in the bootstrap).
  The DD routine disables IRQ and FIRQ during transfers [CalderDD p.15].
- Error bits returned (status): 7 not ready, 6 write protect, 4 not found/seek error, 3 CRC error,
  2 lost data [CalderDD p.15].
- Drive-not-ready timeout ~20 s [CalderDD p.15].

**Conflict with MAME** (`mp1802.cpp` line 84): MAME returns `$FF04` read as
`(drq ? 0x00 : 0x80) | (intrq ? 0x00 : 0x40)` — i.e. NOT(INTRQ) on **bit 6**. Calder says NOT(IRQ)
is **bit 0** (bits 1-6 unused). Neither the bootstrap nor the loader reads bit 0/6 (they use the
NMI), so this needs the schematic/EmuB to decide. MAME's write side (bit6 NMI mask via
`m_nmigate->in_w<1>(!BIT(data,6))`, bit5 = !DDEN, bit4 side, bit3 motor, bits1-0 drive) agrees with
Calder.

Boot path:
- The DOS is loaded by a **DD bootstrap in ROM at $FE7E-$FEFF, which physically lives on the disc
  controller card and overlays the BASIC ROM at the same address**; the overlay disappears if the
  drive is switched off. It is called by the ROM init routine (from **$FB5E**) after the CRTC has
  been set up [CalderDD p.4]. (MAME maps the 2 KB `mp1802.rom` at $F800-$FEFF plus $FFF0-$FFFF;
  consistent in that the bootstrap is inside $F800-$FEFF.) Bus signals /ROM-KIL and /EXROM-KIL
  exist for this (see Phase table below).
- Bootstrap listing [CalderDD p.19-20]: entry $FE7E (3 NOPs), `LDU #$FF00`, `LDD #$2F08`,
  `STA ,U` (force-interrupt $D0 inverted = $2F), `STB 4,U` ($08 = motor on, drive 0, SD, side 0,
  NMI unmasked), delay loop, `TST ,U`/`BMI` drive-present test (status bit7 = not-ready inverted);
  if no drive, `CLR $04,U` and RTS back to **cassette BASIC**. Otherwise set NMI vector
  (`LDA #$7E; STA $0109; LEAX ...; STX $010A` — i.e. the **NMI RAM vector at $0109 is a JMP**),
  restore, then read **track 0 sectors 1 and 2 in single density into $4400**, check the last byte
  read is **$DD** (at $44FF: "ROM BOOT LOOKS FOR DD HERE"), then `JMP $4400`.
- Loader (boot block at $4400) [CalderDD p.20-21]: resets the ACIA (`LDA #$03; STA $FFC4`),
  `LDS #$45FF`, loads the DOS from **track 1 sector 1 to sector 24 (DD)** into **$8800-$9FFF**, then
  `JMP [$4405]` (=$8800). On failure it restores `$39` (RTS) and `JMP $FB61` "START CAS BASIC"
  after setting S from `$0025` ("USE CAS BAS STACK").
- DOS init [CalderDD p.4-5]: clears $4400-$4600; PF key names from $FDDB; COM0 jump table from
  $EF39; scans **$FF40 onwards for further COM ports (ACIAs)**, $FF3C onwards for LPT ports; scans
  **$FF38-$FF3A for a hardware clock chip** and sets the R-C clock flag $214 to $FF; checks
  $8000 for $0C07 (another device/language ROM) and $9800; "keyboard, light pen and timer are
  enabled"; NEWON flag at $248; sign-on via $FD42 "bytes free".
- RAM vectors / hooks: ROM BASIC calls JMPs in the low-RAM "communications area" ($161 FILES,
  $164 OPEN, $167 CLOSE, $16A output-to-file (from $E820), $16D input-from-file (from $E804),
  $170 POS, $173 EOF/LOF, $176 INPUT#, ... $1BB file-name handling) [CalderDD p.5]. EXEC and USR
  jump addresses are at $148-$15E [CalderDD p.4]. ROM general input $E804, output $E820 (same as
  the user manual's disclosed routines).
- DOS memory map: $8800-$8AFB init code, $8AFC-$8B35 variables, $8B36 primary 256-byte buffer,
  $8C36 secondary buffer, ... $9FF8-$9FFF pointers [CalderDD p.5]. Default device byte $11B
  ($02 = cassette, $80 = drive 0) [CalderDD p.3].
- Running a NULL-named file on boot: ROM code at **$E6C5** loads/runs the file named in $1FE-$205
  [CalderDD p.17].
- Binary file (LOADM) format on disk: `$00`, 2-byte length, 2-byte load address, data, then
  `$FF $00 $00`, 2-byte entry address; entry stored at $148 by LOADM, and `R` option jumps there
  [CalderDD p.10]. BASIC file first byte $FF (tokenised) or $0D (ASCII) [CalderDD p.10].

DD disk format [CalderDD p.15-16]:
- 40 tracks (0-39), 2 sides, 16 sectors per side numbered 1-16; DOS treats a track as 32 sectors
  (1-16 = side 0, 17-32 = side 1). 256-byte sectors (size code 01); SD sectors are 128 bytes
  (code 00).
- **Track 0 side 0 (sectors 1-16) is single density** (128 bytes); the rest of track 0 (side 1) and
  all other tracks are DD.
- DD interleave: 1,9,4,12,7,15,2,10,5,13,8,16,3,11,6,14. ~300 rpm.
- SD track layout: 40x$FF, 6x$00, $FC index, 26x$FF; per sector 6x$00, $FE, trk, side, sec, $00,
  $F7, 12x$FF, 6x$00, $FB, 128 data, $F7, 28x$FF; 247x$FF end. DD layout: 80x$4E, 12x$00, 3x$F6,
  $FC, 50x$4E; per sector 12x$00, 3x$F5, $FE, trk, side, sec, $01, $F7, 23x$4E, 12x$00, 3x$F5, $FB,
  256 data, $F7, 55x$4E; 598x$4E.
- Directory on **track 20** from sector 5 to 32 (max 152 files); FAT on track 20 sector 2.
  Group = 8 sectors, 4 groups per track, 160 groups max; $FF free, $FE DOS track, $C0-$C8 last
  group (+sectors used) [CalderDD p.8-9]. Directory entry: 0-7 name, 8-10 ext, 11 kind (0 BAS,
  1 DAT, 2 BIN), 12 type ($00 tokenised, $FF ASCII), 13 first FAT group, 15 bytes used in last
  sector [CalderDD p.8].
- Single density DOS (32K SD DOS): 128-byte sectors; DSKI$/DSKO$ tokens are swapped relative to
  DD DOS [CalderDD p.3].

## 3. "Hitachi Peach Booklet in Japanese" — actually the MB-S1 Mouse Utility manual — `MouseUtil`
File: `ref/docs/peach/Peach-booklet-japanese/Hitachi_Peach_Booklet_in_Japanese.pdf` (50 pp).
One line: **mis-titled** — it is the Hitachi「マウスユーティリティ取扱説明書」(Mouse Utility
operating manual) for the **MB-S1** (cassette A side V1.0, B side V1.1), Hitachi doc no. 4682491.
Not Peach/L3 hardware.
- Loading: connect cassette, power on, insert tape, press PLAY, press **PF1**, when "Ready" shows
  press **PF5** [MouseUtil p.6-7]. (PF1 = LOAD-type key in S1 BASIC.)
- Moving to disk: boot S1 Disk BASIC, `NEWON 1`, set cassette to **1200 baud**, `MOTOR OFF,1`,
  `LOAD "CAS0:MOUSE 1/0"`, edit line 130 `DR=` to (max drive no.+1), `SAVE "1:MOUSE 1/0"`
  [MouseUtil p.46-47]. Disk drives named: MP-3550 / MP-3560 (2 drives); RAM disk supported.
- Autostart: save a program as the **nameless file** (`SAVE` with no name) and set autostart in
  the S1 Disk BASIC utility (menu 7, sub 1) [MouseUtil p.48-49]. Its listing begins
  `100 PALETTE:POKE &HFFD0,0:COLOR 7,0,0:SCREEN 0,0,0:WIDTH 40` — **S1-mode BASIC pokes $FFD0
  with 0** [MouseUtil p.48].
- Colours listed (border/line colours) in order: blue, red, magenta, green, cyan, yellow, white
  (BRG order) [MouseUtil p.11]. Extended RAM (64 KB+) required for disk use [MouseUtil p.5, p.8].

## 4. Hitachi Peach colour brochure (205x300 mm), c.1981-82 — `PeachBrochure`
File: `ref/docs/peach/Peach-205x300mm/Hitachi_Peach_205x300mm.pdf` (8 pp).
One line: Australian Hitachi Peach sales brochure with spec sheet and a hardware-options tree.
- Standard: 24K ROM, 32K RAM, six expansion slots for peripherals and two for memory, 40/80 col x
  25 lines, 8 colours, 640x200 byte-addressable graphics, Microsoft Colour BASIC, clock, speaker
  with volume, RS232, Centronics, light pen, audio, mono video and colour video [PeachBrochure p.2].
- Spec: HD6809, user memory 32K-1MB, 87 keys, 10 PF keys (5 with shift), **"PAL colour option"**,
  "power-on self testing", IEEE 488 option [PeachBrochure p.8].
- Options tree [PeachBrochure p.7]: C14-2170 640x200 colour monitor; green/BW monitor; Centronics;
  TRQ-237 cassette; **MP 3700 light pen**; RS-232C; **MP-1800 minifloppy interface (unit 1)**,
  **MP-1801 (unit 2)**, MP-3540 minifloppy drives; **MP-1806 standard (8") floppy interface** +
  MP-3630 1MB drives; PA 6109 hard disk interface; PA 6112 IEEE-488; PA 6115 memory upgrade to
  1MB; **MP 9718 16K RAM card** (x2) or PA 3200 32K RAM card in the two memory sockets.

## 5. The Australian Phase Vol.1 No.3, Feb/Mar 1985 — `Phase`
File: `ref/docs/magazines/Australian-Phase-A/The_Australian_Phase_A_Magazine_For_Japanese_Micros.pdf`
(48 pp; printed pp.10-13 missing from the scan; pp.42-48 blank). One line: successor of PUN; MB-S1/30
review with internal photos and S1 options tree, MB-6890 RGB-to-IBM monitor adapter, a disk boot
program, and P.F. Calder's "Interfacing to the MB-6890" with the **full 56-pin I/O slot pinout and
an I/O page allocation table**. **High value.**

MB-6890 I/O slot (interface socket) pinout, TABLE 1 [Phase p.38] (printed p.34):

| Pin | Signal | Dir | Function |
|---|---|---|---|
| 1 | +5V | O | |
| 2 | GND | | |
| 3-10 | D0-D7 | I/O | data bus |
| 11-26 | A0-A15 | I/O | address bus |
| 27 | BA | O | bus available |
| 28 | BS | O | bus status |
| 29 | /ROM-KIL | I | **disable system ROM from address bus** |
| 30 | /EXROM-KIL | O | **system ROM is off address bus** |
| 31 | R/W-IN | I | peripheral read/write to data bus |
| 32 | /EX-IO | O | **address is between FF00 and FF7F** |
| 33 | R/W-OUT | O | buffered R/W |
| 34 | VMA-OUT | O | valid memory address acknowledge |
| 35 | E | O | clock: data latched on falling edge |
| 36 | Q | O | clock: address valid on rising edge |
| 37 | /RES | O | CPU reset in progress |
| 38 | /NMI | I | |
| 39 | /IRQ | I | |
| 40 | /FIRQ | I | |
| 41 | /HALT | I | |
| 42 | /VMA-CTRL | I | peripheral valid memory address |
| 43 | /DMA | I | DMA request |
| 44 | /BANK-SW | O | system/peripheral memory swap |
| 45 | HALT-ACK | O | |
| 46 | SOUND-IN | I | analog audio input (mixed into sound) |
| 47 | 16MCK | O | **16 MHz system clock** |
| 48 | GND | | |
| 49 | 2MCK | O | **2 MHz system clock** |
| 50 | GND | | |
| 51 | -5V | O | |
| 52 | /EX-IO2 | O | **address is between FF80 and FFBF** |
| 53 | -12V | O | |
| 54 | +12V | O | |
| 55 | GND | | |
| 56 | +5V | O | |

Clock note: slot pins advertise **16 MHz and 2 MHz** clocks. MAME/TODO: 32.256 MHz crystal ->
4.032 MHz EXTAL -> 1.008 MHz E. A 16.128 MHz (32.256/2) "16MCK" and 2.016 MHz "2MCK" would be
consistent with that; the article just rounds. Flag for the schematic. NZ B&B lists "Clock speed:
4MHz" (= EXTAL) [NZBB p.14].

I/O page allocation, TABLE 2 [Phase p.39] (printed p.35):

| Address | Use |
|---|---|
| FF00-FF04 | 5 inch DD and 8 inch disc controllers |
| FF18-FF20 | 5 inch SD disc controller |
| FF34-FF37 | Rob's multicard PIA |
| FF38-FF3A | real time clock |
| FF3B | unused |
| FF3C-FF3D | LPT1 PIA (port A) |
| FF3E-FF3F | LPT2 PIA (port B) |
| FF40-FF41 / 42-43 / 44-45 / 46-47 | COM1-COM4 ACIAs |
| FF90-FF9F | MC7910 modem card (EX-IO2 range) |
| FFC0-FFC1 | **memory bank switch PIA (port A)** |
| FFC2-FFC3 | parallel printer PIA (port B) |
| FFC4-FFC5 | serial port (ACIA) |
| FFC6-FFC7 | CRTC |
| FFC8 | break flag |
| FFC9 | DIP switch |
| FFCA | timer IRQ |
| FFCB | LPEN IRQ |
| FFD0 | mode select |
| FFD1 | trace flag |
| FFD2 | cassette relay |
| FFD3 | sound bit |
| FFD4 | timer IRQ enable |
| FFD5 | LPEN enable |
| FFD6 | interlace register |
| FFD7 | (blank) |
| FFD8 | colour register |
| FFE0 | KYBD enable flag |
| FFF2 | SWI3 vector -> $0100 |
| FFF4 | SWI2 vector -> $0103 |
| FFF6-7 | FIRQ vector -> $010F |
| FFF8-9 | IRQ vector -> $010C |
| FFFA-B | SWI vector -> $0106 |
| FFFC-D | NMI vector -> $0109 |
| FFFE-F | RESET -> $EED7(?) COLD START |

- The vectors point to **3-byte JMP slots in RAM at $0100-$0111** (SWI3 $100, SWI2 $103, SWI $106,
  NMI $109, IRQ $10C, FIRQ $10F) [Phase p.39]; consistent with the DD bootstrap writing `$7E` to
  $0109 [CalderDD p.19].
- RESET "(&HEED7) COLD START" [Phase p.39] — the scan reads EED7; the user manual's Table S.3 says
  **cold start = $FAB3** (and warm start $A438/$A3A7). One of these is a typo or a different ROM
  revision; check against the ROM reset vector.
- MAME agreement: FFC0 PIA (port A = banking, MAME `piaA_w`), FFC4 ACIA, FFC6 CRTC, FFC8 kb NMI,
  FFC9 DIP, FFCA timer, FFCB LPFLG, FFD0 mode, FFD1 TRACE, FFD2 remote, FFD3 music, FFD4 time mask,
  FFD5 L/P ENBL, FFD6 interlace, FFD8 C-reg, FFE0 kb sel all match MAME's `system_io` comments.
  **Difference: $FFD7** — MAME maps baud select (600/1200) there; Phase leaves it blank and the
  MB-6890 English user manual Table S.2 (p.224) calls it "Open". Possibly a Mark II/Mark 5
  addition; check the Mk II/Mk 5 docs and EmuB.
- PIA port A is used for memory bank switching and port B for the parallel printer [Phase p.33].
- **/EX-IO = $FF00-$FF7F and /EX-IO2 = $FF80-$FFBF** are pre-decoded on the slots [Phase p.35];
  Geoff Drury's RTC circuit (PUN Vol.2 No.1, Apr 84) decodes **$FF38, $FF39, $FF3A** with two
  74LS138s, "addresses determined by the PEACH ROM" [Phase p.37].
- Boot program (T.J. Murphy) [Phase p.26-27]: **reprograms CRTC R4-R9 via $FFC6/$FFC7**:
  - 50-line mode: `DATA 63,6,50,55,&H83,6` for R4..R9 (R4=63, R5=6, R6=50, R7=55, R8=$83,
    R9=6), plus `POKE &HA5,&H14: POKE &H23A,50: POKE &H23C,49` (BASIC screen variables) and
    `SCREEN 0,,1`.
  - Restore normal 25-line mode: `DATA 31,6,25,28,&H83,14` (R4=31, R5=6, R6=25, R7=28,
    **R8=$83, R9=14**) with `POKE &HA5,&H0C: POKE &H23A,25: POKE &H23C,24`, `SCREEN 0,,0`.
  - So the ROM's normal text mode uses **R8=$83 (interlace sync+video mode bits = 3, bit7 set)**
    and R9=14 (16 raster lines per row over two fields = 8 per field). This shows that the CRTC
    runs in interlace-sync-and-video mode even in "200-line" text. Compare with MAME's
    `crtc_vreg[8] & 3` interlace handling and its comment that the mc6845 device lacks full
    interlace & video support.
  - Also `POKE &HFFD8,130` (colour register) [Phase p.26 line 290].
- MB-6890 colour DIN socket (8-pin) [Phase p.27]: 1 +12V, 2 GND, 3 pedestal (not used),
  **4 HSYNC (inverted), 5 VSYNC (inverted)**, 6 red, 7 green, 8 blue (TTL RGB).
- S1/30 review [Phase p.11-24]: S1/30 has a built-in 1 MB 5.25" drive (96 TPI HD disks needed);
  the controller sits in the centre I/F port; **no Level 3 OS for the 1 MB format, so B-mode on
  the S1/30 is cassette-only** unless the controller is swapped for MP-3550/MP-1802 [Phase p.18].
  Expansion: two 72-pin interface ports plus a video-card port; intermediate cards EX01S, EX02S,
  EX03S; max six expansion cards, only three may be MB-6890 cards [Phase p.16]. Video interface
  works with NTSC only; **chip switches preset the cassette baud from 300 to 2400** [Phase p.13].
  Graphics: text screen + three graphics planes R,G,B "consumes 52K of RAM" [Phase p.18].
  Standard RAM 106K expandable by 512K to 618K [Phase p.16].
- MB-S1 options tree [Phase p.17] (printed p.20): MPF-511 single 1MB drive; C12-2120/C14-2190A
  monitors; C15-S01 RGB TV; MP-1020 thermal printer; MPP-1042/MP-1041A/MP-1050 dot matrix;
  MP-1053/MPP-1060 kanji printers; TRQ-1500 cassette; **MP-3710 mouse**; **MPC-VS01S video
  interface**; MPC-EX03S intermediate card (S1/30,40) -> MPC-RA64S/RA128S/RA256S/RA512S RAM,
  MPC-KA01S ROM (kanji?), MPC-PR01 EPROM programmer, MPC-RS01 RS-232C, MPC-PA01 PIA,
  **MPC-FL03 disk controller + MPF-510S 5.25" 1MB**, **MP-1870 controller + MP-3560 (320KB)**,
  MPC-FL01 8" controller + MP-3660; MPC-EX01S (S1/10,20) for RAM; **MPC-EX02S** (L3-style
  intermediate) -> MP-1820 RS-232C, MP-1810 printer expansion, MP-1895 PIA, **MP-1802A disk
  controller + MP-3560 (320KB)**, MP-1806 8" controller + MP-3660; MP-9732 RS-232C connector;
  MP-9830/MP-9831 unknown.

## 6. NZ Bits & Bytes issue 1-06 — Hitachi MB-6890 (Peach) review, Warren Marett — `NZBB`
File: `ref/docs/magazines/NZ-Bits-and-Bytes-1-06/NZ-bits-and-bytes-issue-1-06.pdf` (48 pp; article on
PDF pp.13-14, printed pp.11-12). One line: 1982 NZ consumer review of the MB-6890 with a spec box.
- Summary box [NZBB p.14]: HD6809; **clock speed 4MHz** (presumably the EXTAL input); 32K RAM
  standard ("30K or less usable"); 24K ROM; **audio cassette interface 600 baud**; Centronics; light
  pen; **RS232 300-4800 baud**; RGB colour monitor interface; B/W video; 87-key keyboard;
  40x25 or 80x25; up to 640x200, seven colours; speaker with volume control; six I/O expansion
  connectors; two extra memory sockets, each 16K.
- Colour "is chosen at a character position level by providing a 5-bit code which is loaded into
  a separate 5-bit x 16K colour memory"; 640x200 takes 16K of RAM [NZBB p.14].
- "Hitachi optionally provides a technical manual" and "Another Australian source has produced a
  guide through the MB-6890 ROM" (= Peach ROM Notes) [NZBB p.14]. **Lead: a Hitachi technical
  manual for the MB-6890 existed (probably English).**

## 7. Hitachi MP-1802 service note「サービスマンの方へ」— `MP1802`
File: `ref/docs/manuals/MP-1802/Hitachi_MP-1802.pdf` (2 pp, Japanese; Hitachi doc 4674291).
One line: Hitachi service-technician sheet "How to install the mini floppy disk card MP-1802" in
the MB-6890/MB-6891, with a main-board layout sketch.

Translation:
- Title: "To the serviceman — How to fit the mini-floppy-disk card MP-1802." "By fitting the
  mini floppy disk card MP-1802 into the interface expansion connector inside the Basic Master
  Level 3 MB-6890/MB-6891, the mini floppy disk **MP-3550** can be connected." [MP1802 p.1]
- 1. Disassembly: remove the two screws on the back, remove the upper case; lift off the panel
  support plate. [MP1802 p.1]
- Caution: switch off and unplug first. **This card cannot be used at the same time as the
  mini-floppy cards MP-1800/MP-1801 or the standard floppy card MP-1806**; confirm those are not
  fitted. [MP1802 p.1]
- 2. Fitting: remove two IF panels of unused connectors among **IF/1-IF/6** on the back; insert the
  MP-1802 straight. Figure 4: the card is two boards, **MDB-A** and **MDB-B**; MDB-A goes to the
  left of MDB-B; check the connector joining them is fully seated and that **MDB-A chip switches
  CS611 and CS612 are both on pins 1-2**. [MP1802 p.2]
- Main-board sketch (Fig. 3) [MP1802 p.2]: keyboard at top; ROM sockets **IC5, IC4, IC3, IC2**
  stacked at the left (MAME's BASIC ROMs are `ic3`, `ic4`, `ic5`; IC2 is a fourth socket, maybe
  empty or the character generator); memory expansion connectors **RAM4** and **RAM3**; interface
  expansion connectors **I/F-1 ... I/F-6** in a row; a switch block **SW**; connectors **JA, JB,
  JC**; UNIT-1 connector on the card for the drive.
- 4. Check: connect MP-3550 to UNIT-1 and check **Disk BASIC MA-5320** boots. **MA-5320 needs
  40 KB of RAM**, so fit expansion RAM card **MP-9717 (set to 8 KB)** or expansion RAM bank card
  **MP-9718 (set to 8 KB)** in memory expansion connector **RAM3**. Card chip switches standard
  setting: **CS300 = S, CS301 = S, CS302 = O, CS303 = G**. [MP1802 p.2]
- Note: 32K RAM standard + 8K = 40K implies the $8000-$9FFF block is the expansion-RAM area
  (consistent with the DOS loading at $8800-$9FFF [CalderDD p.4]). **MAME maps $8000-$9FFF as
  plain RAM unconditionally**; on a real 32K L3 that range is empty until MP-9717/9718 is fitted.

## 8. Hitachi MP-3710 Mouse operating manual — `MP3710`
File: `ref/docs/manuals/MP-3710/Hitachi_MP-3710.pdf` (4 pp, Japanese; Hitachi doc 4682341).
One line: MB-S1 mouse (mechanical, 2 buttons) user manual — no register info.
- The mouse needs a **mouse interface IC fitted in a socket on the S1 main board** (installed by the
  dealer) [MP3710 p.1]. **MB-S1 only; not usable on the Basic Master Level 3; works only in system
  mode A (S1 mode), not system mode B** [MP3710 p.1]. Ships with the Mouse Utility cassette.
- Two contact encoders for X/Y; trigger buttons A and B can raise interrupts [MP3710 p.3]. Plugs
  into the rear MOUSE connector (mini-DIN style) [MP3710 p.3].

## 9. ProCalc operators manual — `Procalc`
File: `ref/docs/peach/Procalc/Procalc_for_the_Hitachi_Peach.pdf` (30 pp). One line: HiSoft Pty Ltd
(May 1982) ProCalc spreadsheet operator's manual for the Peach; no hardware content.

## 10. Micro Data (BJS Software Systems) — `MicroData`
File: `ref/docs/peach/MicroData-BJS-catalog/Micro_Data_BJS_Software_Systems_For_Hitachi_Peach.pdf`
(20 pp). One line: user manual/registration pack for BJS Software Systems' "Micro Data" database
program for the Peach (Rosanna, Vic.); no hardware content.

---

## Summary of MAME conflicts / open questions raised here
1. **$FF04 (5" DD FDC aux status) read bit for NOT(INTRQ)**: Calder bit 0, MAME bit 6.
2. **$FFD7**: MAME baud select; MB-6890 manual and Phase table say open/unused. Probably a later
   model addition — verify.
3. **$8000-$9FFF**: MAME always RAM; real 32K L3 needs MP-9717/9718 in RAM3 for it (Disk BASIC
   needs 40K) [MP1802 p.2].
4. **Cold start address**: user manual $FAB3 vs Phase table $EED7.
5. **CRTC R8=$83 / R9=14 in normal text mode** (interlace sync+video) per the ROM restore values —
   relevant to MAME's incomplete interlace handling and to the RTL.
6. S1 B-mode: CPU drops to 1 MHz (pokeable back to 2 MHz); cursor appears one column right of L3
   position (CRTC/skew difference); colour register $FFD8 behaves differently enough to break some
   games.
