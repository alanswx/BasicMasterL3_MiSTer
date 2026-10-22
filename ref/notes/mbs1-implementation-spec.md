# MB-S1 implementation spec (second model in the BasicMasterL3 core)

Status: research only, 2026-10-21. No RTL changed.

**Sources and citation keys.** Unless marked otherwise, `file:line` means
`ref/emulators/EmuB-S1/src/source/src/vm/mbs1/<file>:<line>` (EmuB-S1 V0.9.4). "6892:" means
`ref/emulators/EmuB-6892/src/source/src/vm/bml3mk5/<file>:<line>`. `mc6809.cpp` means
`ref/emulators/EmuB-S1/src/source/src/vm/mc6809.cpp`. [S1OpMan p.N] etc. are the manual citations
already digested in `ref/notes/sources/s1-manuals.md`. [ROM $xxxxx] means bytes in
`roms/mister/mbs1_boot0.rom` at that **physical** S1 address, decoded with a throwaway 6809
disassembler (it is not in the repo). MAME (`~/Documents/development/BasicMasterJr_MiSTer/mame/src/mame/hitachi/mbs1*.cpp`)
is a second opinion only.

Terms. **A mode** = S1 mode (S1 BASIC). **B mode** = Level-3 mode (Level-3 BASIC). **PA** = 20-bit
physical address. **SU** = the system/user bit (1 = system).

---

## 0. Summary of key numbers

| Item | Value | Cite |
|---|---|---|
| Physical space | 1 MB (20 bits, PA[19:0]) | memory.h:90-92, memory.cpp:1601-1618 |
| MMU page | 4 KB; 16 map registers x 8 bits (PA[19:12]) | memory.cpp:1611, memory_writeio.h:15-35 |
| Map registers | `$FE00-$FE0F` CPU (PA `$EFE00-$EFE0F`), R/W in system mode only | memory_writeio.h:31-34, memory_readio.h:31-34 |
| System-mode override | CPU `$E000-$EFFF` -> PA `$84000-$84FFF`, CPU `$F000-$FFFF` -> PA `$EF000-$EFFFF` | memory.cpp:1606-1608 |
| B mode | PA = `$F0000 | CPU address`, then Level-3 banking exactly as the L3 core | memory.cpp:1613-1616, 1341-1476 |
| Main RAM | 64 KB `ram[]`: R graphic plane (16 KB) + 48 KB system RAM. Same array is the whole 64 KB in B mode | memory.h:71, memory.cpp:399-402 |
| Graphic RAM (G,B) | 32 KB `vgram[]`. In B mode `vgram[0..$3FFF]` is the L3 colour RAM | memory.h:78, memory.h:376-378 |
| Text RAM | 2 KB characters + 2 KB 7-bit colour | memory.h:79-80 |
| IG RAM | 3 x 2 KB (shared with the L3 Mark 5 IG) | memory.h:73 |
| ROM | S1 BASIC 64 KB at PA `$E0000-$EFFFF`; L3 BASIC 24 KB at PA `$FA000-$FFFFF`; font 4 KB | memory.cpp:410-419 |
| CPU clock | 2.016 MHz in A mode, 1.008 MHz in B mode at reset, switchable by `$FFEB` bit 1 | mbs1_defs.h:30-31, memory.cpp:1644-1669 |
| I/O slow-down | at 2 MHz any access to `$xFF00-$xFFEF` (x = E or F) is stretched to a 1 MHz cycle | memory.cpp:484-526 |
| CRTC | char clock 2.016 MHz always in A mode, 8 pixels per char, R0 = `$7F`, R1 = `$50` | memory.cpp:1656, display.cpp:328-332, [ROM $E1230] |
| BRAM added for a base S1 | about +719 Kbit (+12.7 % of 5.66 Mbit) or +88 M10K. Total about 60 % bits. **No SDRAM needed** unless expansion RAM is wanted | section 8 |

---

## 1. Modes, reset, CPU clock, SYS-MODE

### 1.1 Mode selection

* The mode is the front-panel SYSTEM switch (A = up, B = pressed in), read at reset
  [S1OpMan p.22, p.36]. In EmuB it is config bit `sys_mode` bit 0 (`REG_SYS_MODE` is literally
  `pConfig->sys_mode`, registers.h:97-106). It is applied on power-on reset
  (memory.cpp:189-200) **and on every warm reset**: `SIG_CPU_RESET` reloads
  `REG_SYS_MODE = ParamSysMode` and calls `reset_s1_l3_mode()` (memory.cpp:1312-1330).
  So for MiSTer: an OSD "S1 mode A/B" bit sampled while `reset` is high.
* `REG_SYS_MODE` bits (registers.h:97-106): bit 0 S1/L3 (1 = A mode), bit 1 CLK (1 = 2 MHz),
  bit 2 S/U (1 = system mode).

### 1.2 What reset does (`reset_s1_l3_mode`, memory.cpp:1644-1662)

1. SU := 1 (system mode), in both modes.
2. CLK := 1 in A mode, 0 in B mode, then `set_cpu_speed` (memory.cpp:1664-1669).
3. CRTC and display character clock := 2.016 MHz if A mode **or** `$FFD0` bit 7, else 1.008 MHz
   (memory.cpp:1656-1657, repeated on every `$FFD0` write in display.cpp:438-439).

Other reset actions (warm reset unless marked "power-on only"):

| State | Reset value | Cite |
|---|---|---|
| Map registers | all 0 (**power-on only**; not cleared on warm reset) | memory.cpp:215, compare 1312-1330 |
| FUSE | `$8F` (TRON = 1, IMK = 0, FC = 15) | memory.cpp:475 |
| Segment reg (OS-9 card) | 0 (power-on) | memory.cpp:197 |
| `$FFC0` bank reg 1 / mask / `$FFE8` | `$0E` / masked / 0 | memory.cpp:450-459 |
| IG mode / IG enable | 0 / 0 | memory.cpp:1325-1326 |
| `$FFD4` time mask | `$82` in A mode, 0 in B mode | timer.cpp:43-65 |
| Fast (1 ms) timer | only started if A mode at reset | timer.cpp:60-64 |
| Display regs `$FE20-$FE2F` | 0, only at construction, not on reset | registers.cpp:21-43, display.cpp:230-251 |
| `$FFD6` interlace sel, `$FFE9` enable | 0 | display.cpp:234-236 |
| `$FFD7` baud | 0 (600 baud) | cmt.cpp:103-108 |
| RAM / VGRAM | zero (power-on); text RAM and colour RAM: even bytes random, odd bytes `$FF` | memory.cpp:202-206, 358-364 |
| Colour reg `$FFD8` | random 1/4/7 (+24 if 7), cosmetic | memory.cpp:209-212 |
| `$FFD0` | random background, cosmetic | display.cpp:245-248 |

MAME's MMU instead loads map latches 0-D with `$F0|i`, E = `$84`, F = `$EF` (mbs1_mmu.cpp
`init_banks`). The ROM does not care (see section 7.2): reset runs entirely in the
system-mode pages. Use EmuB's 0.

### 1.3 What differs between A and B mode

| Aspect | A mode (S1) | B mode (L3) | Cite |
|---|---|---|---|
| Address translation | MMU (section 2) | PA = `$F0000 | a` | memory.cpp:1601-1618 |
| CPU clock at reset | 2 MHz | 1 MHz | memory.cpp:1648-1653 |
| CRTC char clock | always 2 MHz | 1 or 2 MHz by `$FFD0` bit 7 (as L3) | memory.cpp:1656, display.cpp:438 |
| Renderer | S1 renderer (planes, palette, 7-bit colour RAM) | L3 renderer (as EmuB-6892) | display.cpp:1314/1351, displaysub.h:68/323 |
| `$FFD0` W/HR (bits 7/6) | ignored | 80 col / hi-res | display.cpp:429-441, 1682-1693 |
| Border/background colour | `$FFD0` bits 3-0 as I G R B, no palette | bits 2-0, forced bright (bit 3 := 1) | display.cpp:433, 1684 |
| `$FE24` screen mode | used | stored only | display.cpp:402-409 |
| L3 VRAM colour latch at `$0400-$43FF` | off | on | memory.cpp:679, 1003 (`NOW_L3_MODE`) |
| `$FFD4` reset / fast timer | `$82`, 1 ms timer runs | 0, no fast timer | timer.cpp:60-64 |
| ROM | S1 BASIC (`$E0000`) | L3 BASIC (`$FA000`) | memory.cpp:410-419 |
| `$EFExx` S1-only I/O | reachable (through the map) | unreachable (B mode never makes PA `$EFxxx`) | memory_writeio.h:13-14 |

Everything else (common I/O `$FFC0-$FFEF`, PSG, keyboard, timer FIRQ source, `$FFEB`) is the
same machine in both modes.

### 1.4 CPU clock and `$FFEB` SYS-MODE

* `$FFEB` write: only bit 1 (CLK) is used, in **both** modes (memory_writeio.h:482-485,
  memory.cpp:1664-1669). Read: `REG_SYS_MODE & 7` = {SU, CLK, S1L3} (memory_readio.h:495-498).
  Typical reads: `$07` in A mode, `$04` in B mode at 1 MHz.
* EmuB runs the 6809 on a 2.016 MHz base and halves it at 1 MHz (mbs1_defs.h:30-31, 45-47,
  `SIG_EVENT_CPU_HALF_SPEED` in memory.cpp:1668). For RTL: E = clk/16 at 2 MHz, clk/32 at
  1 MHz.

**Automatic slow-down** [S1OpMan p.98-99] as EmuB models it (`set_s1_cpu_wait` /
`set_l3_cpu_wait`, memory.cpp:484-526 and 569-604, applied per bus cycle in
write_data8w/read_data8w/latch_address, memory.cpp:644-676, 957-997, 1259-1290). Only at 2 MHz:

* `addr_comio = PA & $EFFFF` in `$EFF00-$EFFEF`, so common I/O at `$EFFxx` and `$FFFxx`. Plus,
  unless "no wait" is configured, PA `$EFE25-$EFE27` (BRG registers) and the trap page
  `$BFxxx`. An access on an even 2 MHz cycle gets +1 cycle and on an odd cycle +2. The result
  is that the access always **ends on a 1 MHz boundary** and lasts at least 2 cycles. The
  S1-only registers other than `$EFE25-27` do **not** slow down.
* DRAM refresh: every 30th cycle, +1 for main/graphic RAM. Display contention: during DISPTMG,
  when any graphic plane is displayed, accesses to RAM marked with the display-wait bit get +1
  on even cycles (main RAM, graphic RAM and text RAM are all marked; `S1_SET_BANK` wait values
  `$77`/`$55`, memory.cpp:400-407). These change speed only, not function. Leave them for later.

RTL rule for the I/O stretch (exact for EmuB apart from refresh): at 2 MHz, if the cycle's
address is slow I/O, do not issue the 2 MHz `fallE`. Instead end the cycle at the first
`cnt == 0` that is at least 32 clk after the cycle started, and put `fallQ` at `cnt == 24` just
before it. Normal 2 MHz cycles use `fallE` at `cnt[3:0] == 0` and `fallQ` at `cnt[3:0] == 12`.

---

## 2. Memory and MMU

### 2.1 Registers

* **MAP0-MAPF** at PA `$EFE00-$EFE0F` (CPU `$FE00-$FE0F` in system mode): 8 bits = PA[19:12] for
  CPU page `a[15:12]` (memory_writeio.h:15-35). Read back in system mode only
  (memory_readio.h:15-35); in user mode a read returns the underlying ROM byte (`$FF`, because
  S1BAS2 is `$FF`-padded there) and writes are ignored.
* There is **one** set of 16 registers. EmuB's `addr_map[64][16]` with `$FE11` SEGMENT is only
  for the optional OS-9 card (`IOPORT_USE_OS9BD`, memory_writeio.h:48-53). Base machine:
  segment = 0. MAME says the mapper is 2x 74S189 (16x4 each) (mbs1_mmu.cpp header).
* **FUSE** PA `$EFE10`, write only, system mode only: `REG_FUSE = data & $CF`
  (memory_writeio.h:36-47). Bit 7 TRON (trace NMI enable), bit 6 IMK (mask NMI/IRQ/FIRQ), bits
  3-0 FC (registers.h:31-35). Write-only (memory_readio.h:36-41).
* **TRAPF** PA `$EFE18`, read: bit 7 = trap seen. Reading clears it (memory_readio.h:50-57).
* **BUSCTRL** PA `$EFE19`: write bit 7 BREQ, read `BUSCTRL | $7F` (memory_writeio.h:57-70,
  memory_readio.h:58-61). Only meaningful with Z80B/68008 cards.

### 2.2 System and user mode

* System mode is entered on reset and on **every vector fetch**: the 6809 core signals
  `SIG_CPU_BABS` = 1 (BA = 0, BS = 1) around the vector read for RESET, NMI, FIRQ, IRQ, SWI,
  SWI2 and SWI3 (mc6809.cpp:367-369, 692-695, 718-721, 748-751, 2305-2308, 2330-2333,
  2355-2358). The memory sets SU before the vector bytes are read, so vectors always come from
  PA `$EFFFx` (memory.cpp:1305-1311).
* Entering system mode **from user mode** also sets FUSE IMK (all interrupts masked) unless a
  trace count is in progress (memory.cpp:1628-1638). Software clears IMK by writing FUSE.
* User mode is entered only through the trace counter: write `$FFD1`. If FC != 0, after FC+1
  CPU cycles (memory.cpp:1527-1542, 1544-1556): if TRON = 1, raise NMI (the L3-compatible
  single-step); if TRON = 0, switch to user mode (SU := 0) and clear IMK (memory.cpp:1558-1574,
  1621-1627). The NMI drops at the next opcode fetch (memory.cpp:1576-1599). With the reset
  value `$8F` this is exactly the L3 behaviour: NMI 16 cycles after a `$FFD1` write.
* In user mode, CPU `$E000-$FFFF` use MAPE/MAPF, and the map registers and FUSE are locked
  (memory_writeio.h:32, 38). **S1 BASIC never enters user mode** [S1OpMan p.106]. The S1 ROM
  never stores to `$FE10` (scan of absolute stores in [ROM $E0000-$EFFFF]).
* **TRAP**: any access to PA `$BF000-$BFFFF` sets TRAPF bit 7 and asserts NMI. NMI is released
  on the next access outside that page (memory.cpp:713-721, 1035-1043). Reads there return
  `$FF` (unmapped).
* IMK gating is done at the board: while IMK = 1 the CPU sees NMI = IRQ = FIRQ = 0; clearing it
  re-presents the current levels (board.cpp:89-164). IMK is also set/cleared through
  `SIG_FUSE_INTR_MASK` on FUSE writes (memory_writeio.h:39-42, board.cpp:150-164).

### 2.3 Address translation (pseudo-code)

```
// combinational, valid for the whole bus cycle
vec   = cpu_bs & ~cpu_ba;              // vector fetch (6809 BA=0, BS=1)
sys   = su | vec;                      // EmuB sets SU before the vector read
if (!s1_mode)                          pa = {4'hF, a[15:0]};            // B mode
else if (sys && a[15:13] == 3'b111)    pa = a[12] ? {8'hEF, a[11:0]}    // $F000-$FFFF
                                                  : {8'h84, a[11:0]};   // $E000-$EFFF
else                                   pa = {map[a[15:12]], a[11:0]};
// on every fallE with vec: su <= 1 (and if su was 0 and no trace pending: imk <= 1)
```
Cite memory.cpp:1601-1618, 1305-1311, 1620-1642.

### 2.4 Physical memory map

| PA | Read | Write | Cite |
|---|---|---|---|
| `$00000-$7FFFF` | expansion RAM if fitted (64-512 KB, from 0), else `$FF` | expansion RAM / dropped | memory.cpp:1671-1698 |
| `$80000-$83FFF` | `$FF` (reserved) | dropped | memory.cpp:160-163 |
| `$84000-$8FFFF` | `ram[$4000-$FFFF]` (48 KB system RAM) | same | memory.cpp:399-400 |
| `$90000-$AFFFF` | `$FF` | dropped | |
| `$B0000-$B3FFF` | **graphic window**: plane logic (2.6) | plane logic | memory.cpp:749-810, 1073-1124 |
| `$B4000-$B7FFF` | `vgram[$0000-$3FFF]` plain (G plane) | same | memory.cpp:404 |
| `$B8000-$BBFFF` | `vgram[$4000-$7FFF]` plain (B plane) | same | memory.cpp:404 |
| `$BC000-$BCFFF` | `vtram[pa & $7FF]` (mirrored); side effect: colour latch | `vtram` and `vcram := color_reg & $7F` | memory.cpp:406-407, 738-747, 1055-1071 |
| `$BD000-$BEFFF` | IG RAM or font (2.7) | IG RAM planes | memory.cpp:812-819, 1126-1145 |
| `$BF000-$BFFFF` | `$FF`, TRAP | TRAP | memory.cpp:58, 713-721 |
| `$C0000-$C7FFF` | MPC-CM01 ROM (option) else `$FF` | | memory.cpp:432-448 |
| `$D0000-$D7FFF` | S1DIC kanji dictionary ROM (not dumped) else `$FF` | dropped | memory.cpp:410-411 |
| `$E0000-$EFFFF` | S1 BASIC ROM (64 KB). `$EFE00-$EFEFF` S1 I/O and `$EFF00-$EFFEF` common I/O override the ROM data | dropped / I/O | memory.cpp:412-415, memory_readio.h |
| `$F0000-$FFFFF` | **L3 path**: `ram[pa & $FFFF]` with L3 banking, L3 ROM at `$FA000-$FFFFF` (when banked in), common I/O at `$FFF00-$FFFEF`, IG write window `$FA000-$FA7FF` when `$FFE9` bit 0 | as L3 | memory.cpp:670-701, 991-1018, 1341-1476 |

Facts worth stating plainly:

* **The "system RAM image" question is settled.** `$F0000-$FFFFF` is the same 64 KB `ram[]` as
  `$B0000-$B3FFF` (R plane = `ram[0..$3FFF]`) and `$84000-$8FFFF` (`ram[$4000..$FFFF]`)
  (memory.cpp:399-402, 670-700). So B mode's 64 KB RAM *is* the S1's R plane + system RAM.
  MAME's separate RAM there is wrong. The L3 path is reachable from A mode too, by mapping a
  page to `$Fx` (with the L3 bank registers in force; reset `$FFC0` = `$0E` means
  `$FA000-$FFFFF` reads ROM).
* The I/O decode runs **after** the memory read and overrides it (memory.cpp:984-989,
  1020-1026). The common-I/O switch tests `PA & $EFFFF`, so `$FFFxx` and `$EFFxx` are the same
  registers (memory_readio.h:134-135). The S1-only switch tests the full PA `$EFExx`
  (memory_readio.h:13-14). Unimplemented I/O addresses therefore read the ROM byte underneath,
  which is `$FF` in both ROM images.
* Writes in S1 space go to RAM first and then to I/O; writes to ROM/unmapped are dropped
  (memory.cpp:660-669).

### 2.5 Decode pseudo-code (RTL-ready)

```
// a: CPU address, pa: from 2.3, rd/wr strobes at fallE (as core.v)
comio   = (pa[19:8] & 12'hEFF) == 12'hEFF && pa[7:4] != 4'hF;  // $xFF00-$xFFEF, x=E/F
s1io    = pa[19:8] == 12'hEFE;                                   // $EFE00-$EFEFF
l3path  = pa[19:16] == 4'hF;                                     // also all of B mode
gwin    = pa[19:14] == 6'b1011_00;                               // $B0000-$B3FFF
gplain  = pa[19:14] == 6'b1011_01 || pa[19:14] == 6'b1011_10;     // $B4000-$BBFFF
txt     = pa[19:12] == 8'hBC;
igwin   = pa[19:12] == 8'hBD || pa[19:12] == 8'hBE;
trap    = pa[19:12] == 8'hBF;
sysram  = pa[19:14] >= 6'h21 && pa[19:14] <= 6'h23;             // $84000-$8FFFF
s1rom   = pa[19:16] == 4'hE;
exram   = pa[19] == 1'b0 && exram_present(pa);

// RAM address into the shared 64 KB ram[]:
ram_a   = l3path ? pa[15:0] : sysram ? pa[15:0] /* $4000-$FFFF */ : {2'b00, pa[13:0]} /* R plane */;
// vgram address: gwin uses pa[13:0] in each plane (2.6);
//   gplain: $B4000-$B7FFF -> vgram[{1'b0, pa[13:0]}], $B8000-$BBFFF -> vgram[{1'b1, pa[13:0]}]
//   i.e. vgram_a = {pa[15], pa[13:0]} (pa[15:14] is 01 or 10 there)

read data priority: comio/s1io register (if decoded) > txt (vtram) > gwin (plane logic)
                    > igwin > l3path (L3 bank logic, as core.v) > sysram > gplain > s1rom > exram > $FF
```
(The I/O tables are in section 4. `l3path` reuses `core.v`'s `rom_sel` / `ram_hi` logic with
`a` replaced by `pa[15:0]`.)

### 2.6 Graphic window `$B0000-$B3FFF` (plane logic)

Registers: `$FE20` BMSK-COLOR (bit 7 BMSC, bits 2-0 G R B), `$FE21` ACTIVE-PLANE (bit 3 DW,
bits 2-0 G R B), `$FE25-$FE27` B/R/G colour registers (display.cpp:378-415, registers.h:45-56,
83-86). Internally `bmsk_dw = {BMSC, DW}` (display.cpp:381, 386). Planes: R = `ram[a14]`,
G = `vgram[a14]`, B = `vgram[$4000 + a14]`, where `a14 = pa[13:0]` (memory.cpp:61-63).

```
write (memory.cpp:749-786):
  if (!BMSC && !DW)  for each active plane P: P[a14] = data              // direct
  if (!BMSC &&  DW)  for each active plane P: P[a14] = REG_P              // indirect
  if ( BMSC)         for each active plane P:                             // bit-mask
                       P[a14] = (BMSK_P ? data : 0) | (REG_P & ~data)
read (memory.cpp:1074-1097):
  if (!DW) data = first active of G, R, B ? that plane[a14] : 0           // sequential
  else     { for each active P: REG_P = P[a14];                           // 3-plane latch
             data = REG_G if G active, else REG_R, else REG_B, else 0 }
```
Writes to the window do **not** touch the colour RAM (the colour-copy code is `#if 0`,
memory.cpp:787-808).

### 2.7 IG RAM and font window `$BD000-$BEFFF`

`ig_en = $FFEA[2:0]` = {G, R, B} (memory_writeio.h:478-481). Both 4 KB pages alias the same 2 KB
(`addr & $7FF`).
* Write: every enabled plane gets the byte (memory.cpp:812-818). No `$FFE9` gate in the S1
  window.
* Read: if `ig_en == 7`, the **font ROM** byte `font[pa & $FFF]` (memory.cpp:1127-1129, font
  pointer from display, mbs1.cpp:258). Otherwise the first enabled plane in order G, R, B, or 0
  (memory.cpp:1130-1139).
* The L3 IG window (PA `$FA000-$FA7FF`, gated by `$FFE9` bit 0) also works in both modes
  (memory.cpp:689-699).

### 2.8 Text RAM and the colour latch (A mode)

* Write `$BCxxx`: `vtram[pa & $7FF] = data`, `vcram[pa & $7FF] = color_reg & $7F`
  (memory.cpp:738-747, 668).
* Read `$BCxxx`: returns `vtram`; if `color_reg[7]` (MK) = 0 then `color_reg = vcram & $7F`
  (memory.cpp:1055-1071).
* `$FFD8` is a full 8-bit R/W register in EmuB-S1 (memory_writeio.h:414-420,
  memory_readio.h:429-435). **Differs from EmuB-6892**, which masks bit 6 on write and forces it
  to 1 on read (6892: memory_writeio.h:234, memory_readio.h:240). In B mode on the S1 the
  colour RAM still stores only 6 bits (`color_reg & $3F`, memory.cpp:687) and a read reloads
  6 bits (memory.cpp:1013-1015).

---

## 3. ROM files

| EmuB file | MAME name (roms/README.md) | Size | Loaded to | PA | Check bytes | Cite |
|---|---|---|---|---|---|---|
| `L3BAS.ROM` | (bml3 ic3+ic4+ic5) | 24 KB | `l3rom[0..$5FFF]` | `$FA000-$FFFFF` (L3 path) | `C4 5C` | memory.cpp:253-255 |
| `ROM1.ROM` + `ROM2.ROM` | `rom1.rom` (24320) + `rom2.rom` (16) | `$5F00` + 16 | `l3rom[0]`, `l3rom[$5FF0]` | same | `C4 5C` / `00 00 01 00` | memory.cpp:256-262 |
| `S1BAS1.ROM` | `s1bas1.rom` | 32 KB | `s1rom[0..$7FFF]` | `$E0000-$E7FFF` | `EE C5` | memory.cpp:263-265, 414 |
| `S1BAS2.ROM`, or `S1ROM2.ROM` + `S1ROMI.ROM` | `s1rom2.rom` (32256) + `s1romi.rom` (16) | 32 KB, or `$7E00` + 16 | `s1rom[$8000..]`, vectors at `s1rom[$FFF0]` | `$E8000-$EFFFF` (vectors `$EFFF0`) | `31 C6` / `FF FF EE FD` | memory.cpp:266-274, 415 |
| `S1DIC.ROM` | `s1dic.rom` (NO_DUMP) | 32 KB | `s1dicrom` | `$D0000-$D7FFF` | `B1 00` | memory.cpp:275-277, 411 |
| `FONT.ROM` | `font.rom` (mbs1, real dump) | 4 KB | display `font[]` (L3 layout) | not CPU-mapped except via `$BDxxx` with IGEN = 7 | | display.cpp:344-345 |
| `S1FONT.ROM` | none (missing) | 8 KB | only if `FONT.ROM` is absent | | | display.cpp:347-349 |
| `MP1802.ROM` / `MP1805.ROM` | `mp1802.rom` / `mp1805.rom` | 2 KB | over L3 `$F800-$FEFF` (and `$FFF0` when ROM vectors) | `$FF800-` | | memory.cpp:278-283, 1419-1426, 1456-1463 |
| `MPC-CM01.ROM` | none | 32 KB | `$C0000` / `$E2000` (option) | | | memory.cpp:284-290, 422-448 |

Notes:
* The S1 uses **the same 4 KB L3-layout font** as the L3 (`FONT.ROM` is tried first and
  rendered with `set_l3font_data`, display.cpp:344-370; the S1 text renderer indexes
  `chrfont[IS][code][ra & $F]`, displaysub.h:114). `S1FONT.ROM` (8 KB, interlace set at
  `+$1000`, display.cpp:652-666) is only a fallback. So the missing 8 KB font does not block
  anything. The manual's remark that code `$7F` differs between A and B mode [S1OpMan p.121]
  is not modelled by EmuB.
* S1 vectors (`s1romi`): `FFF0 FFFF, SWI3 EEFD, SWI2 EEFA, FIRQ EEEE, IRQ EEF1, SWI EEF7,
  NMI EEF4, RESET FDF2` [ROM $EFFF0].
* The `rom1.rom` (S1's L3 BASIC) differs from `l3bas.rom` in 126 bytes (`$F800-$FEFF` S1 disk
  boot code instead of MP-1805, plus `$EE5D`) (roms/README.md).

**Proposed `boot0.rom` layout for the S1 model: keep the existing `mbs1_boot0.rom`.** It already
lets one decoder serve both models, and the S1 ROM offset is just PA[15:0] + `$10000`:

| boot0 offset | Size | Contents | Used at |
|---|---|---|---|
| `$00000` | `$6000` | L3 BASIC (rom1 + `$FF` pad + rom2 at `$5FF0`) | PA `$FA000-$FFFFF` (L3 path) |
| `$06000` | `$0800` | MP-1802 | L3 `$F800-$FEFF` |
| `$06800` | `$0800` | MP-1805 | L3 `$F800-$FEFF` |
| `$07000` | `$1000` | reserved (MP-1806 / spare) | |
| `$08000` | `$1000` | FONT.ROM (mbs1 real font) | chargen, `$BDxxx` read with IGEN = 7 |
| `$09000` | `$7000` | reserved (S1FONT 8 KB at `$0A000` if ever dumped) | |
| `$10000` | `$10000` | S1 BASIC 64 KB = s1bas1 + s1rom2 + pad + s1romi (= PA `$E0000-$EFFFF`) | A mode |
| `$20000` | `$8000` | S1DIC (reserved, NO_DUMP) | PA `$D0000` |

RTL impact: `core.v`'s `rom_addr` is `[15:0]` today and must become `[17:0]` (file size
`$28000`). Only the S1 model needs the BRAM at `$10000-$1FFFF`.

---

## 4. I/O map

Legend for the "Boot" column: **M** = needed for S1 BASIC to reach `Ready` (minimal milestone),
**P** = probed at boot but a failed probe is harmless (the ROM just records "absent"),
**L** = later.

### 4.1 S1-only I/O, PA `$EFE00-$EFEFF` (CPU `$FE00-$FEFF` via MAPF; A mode only)

| PA | Name | R/W | Bits / behaviour | Boot | Cite |
|---|---|---|---|---|---|
| `$EFE00-0F` | MAP0-F | R/W (system mode) | PA[19:12] of page n | M | memory_writeio.h:15-35, memory_readio.h:15-35 |
| `$EFE10` | FUSE | W (system mode) | 7 TRON, 6 IMK, 3-0 FC; stored `& $CF` | L (reset value suffices) | memory_writeio.h:36-47 |
| `$EFE11` | SEGMENT | W | OS-9 card only | - | memory_writeio.h:48-53 |
| `$EFE18` | TRAPF | R | 7 TRAP; read clears | L | memory_readio.h:50-57 |
| `$EFE19` | BUSCTRL | R/W | W bit 7 BREQ; R `BUSCTRL | $7F` | L | memory_writeio.h:57-70 |
| `$EFE20` | BMSK-COLOR | W | 7 BMSC, 2 G, 1 R, 0 B (`& $87`) | M | display.cpp:378-382 |
| `$EFE21` | ACTIVE-PLANE | W | 3 DW, 2 G, 1 R, 0 B (`& $0F`) | M | display.cpp:383-387 |
| `$EFE23` | DISP-PAGE | W | 7 G, 6 R, 5 B display enables; 1 GR (graphic page, 320x200 8-col only); 0 TX (text page, 40 col only) | M (store) | display.cpp:388-401, 1663-1671 |
| `$EFE24` | SCRN-MODE | W | 2 text width (1 = 80); 1 graphic width (1 = 640); `[1:0]` 00 320x200 8-col, 01 320x200 64-col / 2 pages, 10 640x400 mono, 11 640x200 8-col | M (store) | display.cpp:402-409, 1673-1680, registers.h:72-81 |
| `$EFE25-27` | B-REG, R-REG, G-REG | R/W | graphic colour / scroll latch (2.6). Slow I/O | M | display.cpp:410-415, memory_readio.h:94-99 |
| `$EFE28-2F` | PALET0-7 | W | 3 I, 2 G, 1 R, 0 B (`& $0F`). Read returns `$FF` and, if neither HSYNC nor VSYNC is active, HALTs the CPU until the next HSYNC/VSYNC edge | M | display.cpp:416-428, 454-476, 535-587 |
| `$EFE40-41` | PIA-A port A / CRA | R/W | joystick (PIA "MA", port A) | L | memory_writeio.h:100-104 |
| `$EFE42-43` | PIA-B (printer) | R/W | mirror of `$FFC2-$FFC3` | L | memory_writeio.h:105-109 |

`$FE22` is not decoded. `$FE20/$FE21/$FE23/$FE24` cannot be read (memory_readio.h:70-93).

### 4.2 Common I/O `$FFC0-$FFEF` (PA `$EFFC0-$EFFEF` and `$FFFC0-$FFFEF`; both modes)

Only differences from the current L3 core (`rtl/core.v`) are spelled out; "= L3" means the
existing logic is right for the S1 too.

| Addr | Name | S1 behaviour | vs EmuB-6892 / core.v | Boot | Cite |
|---|---|---|---|---|---|
| `$FFC0` | bank reg 1 | write `& $CE` unless masked; read returns it | 6892 uses a real PIA; S1 emulates only DDR/CRA2 via `$FFC1`. Same effect | M (B) | memory_writeio.h:332-342, memory_readio.h:337-340 |
| `$FFC1` | bank mask | `mask = (data & 4) == 0` | same idea as PIA CRA bit 2 | M (B) | memory_writeio.h:340-342 |
| `$FFC2-3` | PIA B (printer) | = L3 | | L | |
| `$FFC4-5` | ACIA | = L3 (`$FFD0` bit 5 routes cassette/RS-232C) | | P (A writes `$7F`, then ORs status 256 times, then `$03`) | [ROM $E1143-$E115D, $E11C8] |
| `$FFC6-7` | CRTC | = L3. A mode loads the table at [ROM $E1230]: `7F 50 5F 8A 1F 06 19 1C 40 07 27 07 00 00 00 00` | | M | [ROM $E1049-$E1058] |
| `$FFC8` | KBNMI | = L3 | | M | memory_readio.h:363-366 |
| `$FFC9` | DIPSW | reads `$03` (config default) | 6892 reads its DIP switch | M | memory_readio.h:367-370, mbs1_defs.h:80 |
| `$FFCA` | TIMER | bit 7 = 60 Hz flag, bit 6 = fast-timer flag; read returns both and clears both and the FIRQ | 6892: only bit 7 | M | timer.cpp:104-119 |
| `$FFCB` | LPFLG | `$7F` | = L3 | M | keyboard.cpp:735-746 |
| `$FFCD` | (Reamraito) | `$FF` (`$BF` only with "disable ROM BASIC" option) | new | M (must not read `$7F`) | memory_readio.h:379-386 |
| `$FFCE` | (Reamraito) | `$FF` (`$7F` disables ROM BASIC boot) | new | M | memory_readio.h:383-386 |
| `$FFD0` | MODE-SEL | A mode: bits 3-0 border colour IGRB; bit 5 ACIA routing; W/HR ignored. CRTC clock rule in 1.2 | 6892 border = bits 2-0, forced bright | M | display.cpp:429-441 |
| `$FFD1` | TRACE | arms trace counter (2.2) | 6892: NMI 16 cycles later, fixed | L | memory_writeio.h:381-386, memory.cpp:1527-1599; 6892: memory.cpp:586-598 |
| `$FFD2` | REMOTE | = L3 | | M (written 0) | |
| `$FFD3` | MUSIC-SEL | = L3 (beep bit 7) | | L | memory_writeio.h:391-396 |
| `$FFD4` | TIME MASK | `& $83`: bit 7 TM (60 Hz mask), bit 1 TM2 (fast mask), bit 0 T2S (1 = 1 ms, 0 = 2 ms). Setting a mask clears that flag and its FIRQ | 6892: bit 7 only | M (A writes `$02`: 60 Hz on, fast off) | timer.cpp:82-102, [ROM $E11D9] |
| `$FFD5` | LPEN BL | = L3 | | L | memory_writeio.h:401-405 |
| `$FFD6` | INTERLACE-SEL | = L3 (bit 3 IS) | | M | memory_writeio.h:406-409 |
| `$FFD7` | BAUD-SEL | `& $0F`: bits 1-0 = 600/1200/2400/300, bit 2 = double speed | 6892: bit 0 only (600/1200) | L | memory_writeio.h:410-413, cmt.cpp:544-573; 6892: memory_writeio.h:218-221, cmt.cpp:546 |
| `$FFD8` | C-REG | full 8 bits R/W (A: 7 MK, 6 SI, 5 IG, 4 GR/TX, 3 RV, 2-0 G R B) | 6892/core.v mask bit 6 | M | 2.8 |
| `$FFD9` | TRQ-SEL | reads `$0F` | new | L | memory_readio.h:436-439 |
| `$FFDC-DF` | MOUSE | absent unless option; reads `$FF` | new | P (fails cleanly with `$FF`) | memory_readio.h:440-448, [ROM $E1111-$E113A] |
| `$FFE0` | KB | = L3 (separate register now) | 6892 mirrors keyboard over `$FFE0-$FFE7` | M | memory_readio.h:449-452; 6892: memory_readio.h:243-250 |
| `$FFE1` | KB-TYPE | reads `$01` (JIS keyboard) | new (6892: keyboard mirror) | M | memory_readio.h:453-456 |
| `$FFE2` | TVSUPER | W `& $17`; bit 4 analog/digital (64-colour rendering) | new | L | memory_writeio.h:441-444, registers.h:108-111 |
| `$FFE4` | PSG data | AY-3-8910 (8913, no ports) data R/W, clock 1.008 MHz | new | P (A probes R0/R2/R4 with `$55` read-back) | memory_writeio.h:445-449, memory_readio.h:463-466, mbs1.cpp:94, 1150, [ROM $E10EB-$E1109] |
| `$FFE5` | PSG reg | W `& $0F` | new | P | memory_writeio.h:450-454 |
| `$FFE6-7`, `$FFEE-F` | ext PSG / OPN(A) | option | new | - | memory_writeio.h:455-499 |
| `$FFE8` | BANK-REG | = Mark 5 (L3 path only) | | M (B) | memory_writeio.h:469-473 |
| `$FFE9` | IGMODE | W bit 0 PM; R: 7 PAE, 2 DISPTMG, 1 HSYNC, 0 VSYNC, bits 6-3 read 1 | = Mark 5 + status read | M (A writes it in the text-RAM test) | memory_writeio.h:474-477, memory_readio.h:488-491, registers.h:115-124 |
| `$FFEA` | IGEN | `& $07` | = Mark 5 | L | memory_writeio.h:478-481 |
| `$FFEB` | SYS-MODE | 1.4 | new | M | memory_writeio.h:482-485, memory_readio.h:495-498 |

Option cards on the common bus (all reachable in A mode through the `$EFFxx` image):
`$FF00-$FF04/$FF08/$FF0C/$FF10-$FF14` 5" FDC, `$FF16-17/$FF1E-1F` FM, `$FF18-$FF27` 3" FDC,
`$FF30-$FF33` 6-voice PSG (the core's `psg6.v`), `$FF38-$FF3A` RTC, `$FF3C-$FF3F` ext printer,
`$FF40-$FF41` ext ACIA, `$FF70-$FF7F` 9-voice PSG, `$FF72-$FF76` kanji, `$FF77` CM01
(memory_writeio.h:120-330). The existing `mp1802.v` and `psg6.v` need only the common-I/O
decode to work in A mode.

### 4.3 What the A-mode reset code touches (ordered, from [ROM])

From the reset vector `$FDF2` (PA `$EFDF2`) and `$A000` (PA `$E1000`):
1. `ORCC #$50`; MAPA := `$E1`; `JMP $A000` [ROM $EFDF2-$EFDFB].
2. MAPB := `$E0`, MAPC := `$86`, MAPD := `$85`, MAPE := `$84`, MAPF := `$EF` [ROM $E1002-$E1014].
3. DP := `$EF`; `$FFE0` := 0; read `$FFC8` (BREAK held selects another path); `$FFD2` := 0
   [ROM $E1020-$E102D].
4. CRTC R0-R15 from the table above [ROM $E1049-$E1058].
5. Work RAM init at CPU `$EExx` (= PA `$84Exx`); S := `$E217`.
6. MAP1 := `$BC` (text RAM at CPU `$1000`); test `$1000-$10FF` with `$FFE9` toggled 1/0 around
   each write. The result goes to flag byte `$EE32` bit 3 [ROM $E10BB-$E10E9].
7. PSG probe through `$FFE5`/`$FFE4` (`$EE32` bit 2 if absent); mouse probe `$FFDC-$FFDF`
   (bit 1); ACIA probe `$FFC4` (bit 0) [ROM $E10EB-$E115D].
8. PALET0-7 := 0 [ROM $E115E-$E1167]. Then system calls (`JSR $F0D1` + inline function bytes)
   for the screen set-up, `$FFE0` := `$44` (KB IRQ on), `$FFC4` := `$03`, `$FFD4` := `$02`
   [ROM $E11B9-$E11DB].

Absolute-address stores anywhere in the S1 ROM also hit `$FE20/21/23/24`, `$FE25-27`
(heavily), `$FFD0`, `$FFD3`, `$FFD6`, `$FFD7`, `$FFD8`, `$FFE8`, `$FFEA`, `$FFEB`. That is a byte
scan, so it is noisy. The rest of the set-up goes through the system-call layer and needs a
run in EmuB-S1 (or our sim with `--trace-io`) to list exactly.

---

## 5. Video

### 5.1 Memories and fetch

* Text: `vtram` 2 KB + `vcram` 2 KB (7 bits). 40 columns: page 0 at `$000`, page 1 at `$400`
  (`DISP-PAGE` TX). 80 columns: `$000-$7CF` [S1OpMan p.113].
* Graphics: three 16 KB planes (R = `ram[0..$3FFF]`, G = `vgram[0..$3FFF]`,
  B = `vgram[$4000..$7FFF]`) (memory.cpp:1495-1508). 320x200 uses 8 KB per page (page 1 at
  `+$2000`); 640x200 uses 16 KB; 640x400 uses R and G as one 32 KB plane [S1OpMan p.114-116].
* Palette: 8 entries x 4 bits (I G R B) = 8 of 15 colours. RGB: I = 0 gives `$AF` per primary,
  I = 1 gives `$FF`; `{I=1, GRB=0}` is black, or dark grey `$1F1F1F` with EmuB's
  "original palette" option (display.cpp:96-108, 1695-1704). 64-colour mode uses a
  2-bit-per-gun table (display.cpp:109-139).
* CRTC: char clock 2.016 MHz, 8 dots per char at 16.128 MHz (= `clk_sys/2`, as the L3 80-col
  mode) (display.cpp:328-332). The boot table gives R0 `$7F` (128 chars, 63.5 us), R1 `$50`,
  R4/R5/R9 = 32x8+6 = 262 lines, R6 25 rows, R8 `$40` (non-interlace, cursor skew 1).
  Interlace uses R8 `$43`, R9 `$0E` [S1OpMan p.117].
* 40/80 columns and 320/640 dots are selected by `$FE24`, **not** by the CRTC: the CRTC always
  runs 80 chars. A 40-column character or a 320-dot byte spans two CRTC characters
  (display.cpp:1321-1322).

Per CRTC character (display.cpp:1314-1329, 1478-1556):

```
w80  = SCRN_MODE[2]; gw = SCRN_MODE[1]; gm = SCRN_MODE[1:0];
t_addr = w80 ? ma[10:0] : {tpage, ma[10:1]};               // + 0x400 for page 1
half   = ~w80 & ma[0];                                     // 0 = left nibble, 1 = right
if (gm == 2'b10)  g_off = (ra & 4'hE) << 11;               // 640x400: line n at n*0x800
else              g_off = ((ra >> IS) & 7) << (gw ? 11 : 10);
g_addr = (gw ? ma[13:0] : ma[13:1]) + g_off
         + ((gw || gm == 2'b01) ? 0 : gpage << 13);        // 320x200 8-col page
g_addr &= (gm == 2'b10) ? 15'h7FFF : 14'h3FFF;
code = vtram[t_addr]; cr = vcram[t_addr];                  // cr bit 7 is unused
gr = ram[g_addr]; gg = vgram[g_addr]; gb = vgram[0x4000 + g_addr];  // masked by DISP-PAGE
// 640x400: one plane: g_addr < 0x4000 ? R(g_addr) : G(g_addr-0x4000); odd line uses +0x800
// 64-colour: second fetch at g_addr + 0x2000 (all 3 planes)
```
(Assumes R12/R13 = 0, as the manual requires in A mode [S1OpMan p.117-118]. EmuB's
`crt_mon_col_st`/`addr_left` terms only handle odd start columns.)

### 5.2 Pixel composition (8-colour modes; displaysub.h:68-312)

```
// 8 output pixels per CRTC char, p = 0..7 left to right
bitsel(byte, p) = (w80 or gw, as appropriate) ? byte[7-p]
                : byte[half ? 3 - p/2 : 7 - p/2];          // 40-col / 320-dot doubling
sel = {cr[6], cr[4]};                                      // SI, GR/TX  (cram & 0x50)

// text layer (skipped when sel == 01)
if (cr[5]) {                                               // IG
  ig = {igG,igR,igB}[{code, ra >> vmode}];                 // 3 planes
  if (cr[3]) ig = ~ig;                                     // reverse
  if (cursor) ig = {cr[2],cr[1],cr[0]} for all p;          // cursor fills fg colour
  tcol[p] = {G,R,B bits of ig at bitsel}; ton[p] = tcol[p] != 0;
} else {
  pat = font[l3_font_addr(code, ra, IS)];                  // same addressing as video.v
  if (cursor) pat = ~pat; if (cr[3]) pat = ~pat;
  ton[p] = bitsel(pat, p); tcol[p] = ton[p] ? cr[2:0] : 0;
}
// graphic layer
gcol[p] = {bitsel(gg,p), bitsel(gr,p), bitsel(gb,p)} & {DP_G, DP_R, DP_B};

if (sel == 00 || DISP_PAGE[7:5] == 0) c = tcol[p];         // text only
else if (sel == 01)                   c = gcol[p];         // graphic only
else if (sel == 10)                   c = ton[p] ? tcol[p] : gcol[p];   // text on top
else                                  c = gcol[p] != 0 ? gcol[p] : tcol[p]; // graphic on top
pix = palette[c];                                          // {I,G,R,B}
rgb = {G?(I?FF:AF):0, R?..., B?...};
border/blank: rgb from $FFD0[3:0] as {I,G,R,B} directly (no palette); 0 during sync
```
Notes:
* `c` is a 3-bit index with bit 2 = G, bit 1 = R, bit 0 = B (displaysub.h:881-889: `pal[b | r<<1 | g<<2]`).
* Text-on-top uses the **pattern**, not the colour, so black text (cr[2:0] = 0) still hides the
  graphic: `cd = (cg & ~pat) | ct` (displaysub.h:236-239, CREATE_MASK_0 at display.cpp:915-917).
  For IG text the mask is "IG pixel non-zero" (CREATE_MASK_1).
* `sel == 01` with all planes disabled reuses a stale text value in EmuB (displaysub.h:84, 262).
  Output colour 0 instead.
* Cursor: in 40 columns the cursor covers both CRTC chars of the character
  (display.cpp:1336-1350, 1388-1390). R14/R15 hold twice the 40-column offset
  [S1OpMan p.117-118]. RTL: in A mode with `~w80`, compare `ma[13:1] == cursor[13:1]`. Ignore
  R8 cursor skew (EmuB cancels it: display.cpp:1339-1341).
* 64-colour mode with digital RGB (`$FFE2` bit 4 = 0, the default) is "two 320x200 pages, page 0
  on top" (`cg0 | (cg1 & ~mask(cg0))`, displaysub.h:193-218). Analog uses the 2-bit tables. Later.
* 640x400 needs interlace (CRTC video mode); even/odd lines come from `g_addr` and `+$800`
  (display.cpp:1501-1538, displaysub.h:74). Later.
* `disp_page_changed` (display.cpp:388-397, 574) forces a plane to all-ones for the rest of a
  frame when a plane is switched on. It is an emulation of a latch-timing glitch. Skip it.

### 5.3 B mode on the S1

The EmuB-S1 L3 renderer (displaysub.h:323-386, display.cpp:1352-1385, 1589-1645) is the
EmuB-6892 one: the existing `video.v` applies unchanged, with the colour RAM read from the G
plane memory. Differences from `core.v`/`video.v` that come from the S1 board, not the renderer:
* `ig_mask`: IG display (colour RAM bit 5) is masked off until the first CPU write to `$FFE9`
  after reset (display.cpp:449, 1594, 1622). EmuB-6892 does the same (6892: display.cpp:297,
  955, 981). The current `video.v` does not. It is an L3 (Mark 5) item as much as an S1 one.
* Border/background bright bit: identical (bit 3 forced).

### 5.4 Video pipeline in RTL

The current 80-column phase plan (`ph = cnt[3:0]`, address at ph 1, bytes at ph 3, pattern at
ph 5, pixels from ph 6) carries over. The A-mode pipeline adds, in parallel at ph 1/3: the
`vtram`/`vcram` read (the existing `vram`/`cram` ports, muxed), and three plane reads (`ram` port
B, `vgram` port B twice, or `vgram` built as two 16 KB BRAMs). 64-colour and 640x400 interlace
need a second plane read per char: time-multiplex at ph 5/7, since there are 16 clk per char.

---

## 6. Keyboard, interrupts, timer

### 6.1 Keyboard

* Same scanner and codes as the L3 (keyboard.cpp diff against 6892: only the items below).
  `$FFE0` read returns the code and clears bit 7 and the IRQ (keyboard.cpp:747-764). Write = mode
  register: bit 7 BREAK-NMI enable, bit 6 IRQ enable, bit 3 UE (limits the counter to
  `$00-$07`) (keyboard.cpp:702-719, 778-790).
* **Clock source differs.** The S1 steps the counter from a fixed event every
  `CPU_CLOCKS/262/60` = 128 cycles at 2.016 MHz (15.75 kHz), not from CRTC HSYNC
  (keyboard.cpp:321-325, 440-447, 1145-1151). EmuB-6892 uses CRTC HSYNC (6892: bml3mk5.cpp:136,
  keyboard.cpp:652). RTL: a `clk_sys/2048` tick for the S1 model in both modes.
* Extra S1 keys (key code = bit 7 + counter): INS `$E5`, 変換 (convert) `$E7`, COPY `$E8`, TAB
  `$EC`, keypad comma `$ED`, DEL `$EF`. PF1-5 `$D0-$D4` exist on both
  (keyboard_bind.h:130-175 vs 6892). EmuB-S1 binds PC Tab to `$EC` (L3 binds Tab to kana `$8A`),
  Insert to `$E5`, Delete to `$EF`, F12 to COPY, kana to F8/right-Alt, CAPS F6, GRAPH F7
  (keyboard_bind.h:18-29, 42-52). The counter already covers `$00-$6F` in `core.v`
  (`kb_scan < 7'h70`), so this is only a `keyboard.v` mapping change per model.
* `$FFE1` reads `$01` (JIS). `$FFC8` BREAK: = L3.

### 6.2 Interrupt sources and routing (mbs1_defs.h:171-224, mbs1.cpp:288-376, board.cpp:89-164)

| Line | Sources |
|---|---|
| NMI | trace counter, `$BFxxx` trap, FDC, BREAK (if `$FFE0` bit 7) |
| IRQ | keyboard, mouse, PIA A/B, ACIA, ext PIA/ACIA, 9-PSG, OPN (option) |
| FIRQ | 60 Hz timer, fast timer, OPN (option) |

All three are forced inactive while FUSE IMK = 1 (board.cpp:98-138, 150-164). Every vector
fetch puts the MMU in system mode (2.2).

### 6.3 Timers (timer.cpp)

* **60 Hz timer**: in EmuB-S1 it is a fixed event at line 260 of EmuB's 262-line frame, not the
  CRTC VSYNC (timer.cpp:148-151; the CRTC VSYNC hookup is commented out, mbs1.cpp:175).
  EmuB-6892 uses CRTC VSYNC (6892: bml3mk5.cpp:134, timer.cpp:43-45). RTL for the S1 model:
  a free-running `clk_sys/537600` tick (32.256 MHz / 60). It sets `$FFCA` bit 7 and FIRQ unless
  `$FFD4` bit 7 (timer.cpp:122-130).
* **Fast timer** (A mode only): a tick every 2048 cycles at 2.016 MHz = `clk_sys/32768`
  (1.016 ms) (timer.cpp:63). Each tick toggles a phase bit; it sets `$FFCA` bit 6 and FIRQ when
  `$FFD4[1:0] == 01` (every tick, 1 ms) or `== 00` on alternate ticks (2 ms)
  (timer.cpp:132-142). TM2 (bit 1) masks it. Reset `$FFD4` = `$82` (both masked).
* `$FFCA` read returns both flags, clears both and drops FIRQ (timer.cpp:104-113). A `$FFD4`
  write that sets a mask clears that flag (timer.cpp:87-99).

### 6.4 Other differences from EmuB-6892, collected

| Item | EmuB-S1 | EmuB-6892 | Cite |
|---|---|---|---|
| Timer 60 Hz source | fixed 60 Hz | CRTC VSYNC | timer.cpp:148-151 / 6892 bml3mk5.cpp:134 |
| Fast timer, `$FFCA` bit 6, `$FFD4` bits 1-0 | yes | no | timer.cpp:82-142 |
| Keyboard counter clock | fixed 15.75 kHz | CRTC HSYNC | keyboard.cpp:321-325 / 6892 bml3mk5.cpp:136 |
| `$FFD7` | 4 bits (300-2400, x2) | 1 bit | memory_writeio.h:412 / 6892 memory_writeio.h:220 |
| `$FFD8` | 8 bits | bit 6 forced | memory_writeio.h:419 / 6892 memory_writeio.h:234 |
| `$FFE0-$FFE7` | separate regs (KB, KB-TYPE, TVSUPER, PSG, ext PSG) | all mirror KB | memory_readio.h:449-481 / 6892 memory_readio.h:243-250 |
| `$FFE4/5` PSG, `$FFEB` | present | absent | |
| `$FFC0/1` | register + mask bit | full 6821 PIA | memory_writeio.h:332-342 / 6892 memory_writeio.h:153-159 |
| `$FFD1` trace | FC+1 cycles from the write (FUSE) | 16 cycles from the next fetch | memory.cpp:1527-1542 / 6892 memory.cpp:586-598 |
| L3 bank logic (`change_l3_memory_bank`) | identical (exram replaces ram2; no MP-1806) | | diff of the two functions |
| Colour RAM storage | `vgram[0..$3FFF]` | separate 16 KB | memory.cpp:687 / 6892 memory.cpp:281 |
| Border bright | `$FFD0` bit 3 in A mode; forced in B | forced | display.cpp:433, 1684 / 6892 display.cpp:275 |
| CPU clock | 2.016 MHz base, half speed in B | 1.008 MHz | mbs1_defs.h:31 / 6892 bml3mk5_defs.h:30 |

---

## 7. Golden reference and power-on

### 7.1 Expected A-mode screen

ROM strings [ROM $E22EB, $E2354, $E2373, $E847E] and [S1OpMan p.37]:

```
HITACHI S1 BASIC Version 1.0
Copyright (c) 1984 By Hitachi,Ltd.
Copyright (c) 1980 By Microsoft
36K Bytes Free
BASIC User Area 36K Bytes

Ready
_
```
(The ROM string has no space in "Hitachi,Ltd." although the manual prints one. The free figure
is 36K in the default graphics mode with no expansion RAM [S1OpMan p.63].) Layout: 40x25
non-interlaced text over 640x200 graphics [S1OpMan p.57-59], so `$FE24` should end up as
`$03` (bit 2 = 0: 40-col text; bits 1-0 = 11: 640x200 8-colour), with the planes cleared.
This is inferred from the manual, not yet seen in a trace. Palette n = colour n+8 after BASIC
initialises it [S1BasicMan p.41]. The exact foreground/border colours are not documented: take
them from an EmuB-S1 screenshot before calling a mismatch.

B mode (same hardware, L3 BASIC from `rom1`): "HITACHI LEVEL-3 BASIC Version 1.0 / Copyright
(c) 1980 By Microsoft / 30570 Bytes Free / Ready" [S1OpMan p.38].

### 7.2 Power-on sequence

Given in 4.3. The essential points for the RTL: (1) reset vectors are fetched in system mode
from PA `$EFFFE` (needs the vector-fetch override or SU = 1 at reset); (2) the first ROM code
runs from page F (PA `$EF000`) with every map register 0; (3) the first map write is MAPA, then
B-F; (4) the stack is in page E (PA `$84xxx`, RAM); (5) CRTC programming, PSG/mouse/ACIA probes,
palette clear; (6) KB IRQ on, timer FIRQ on.

---

## 8. BRAM budget

Cyclone V 5CSEBA6: 553 M10K = 5,662,720 bits. Current L3 design: 47 % (about 2.66 Mbit,
including the MiSTer framework).

| Memory | Size | Bits | M10K | Notes |
|---|---|---|---|---|
| Main RAM `ram` | 64K x 8 | 524,288 | 64 | **already present** (L3 RAM = S1 R plane + system RAM) |
| IG RAM | 3 x 2K x 8 | 49,152 | 6 | already present |
| Font | 4K x 8 | 32,768 | 4 | already present (use the real mbs1 font for both) |
| L3 ROM | 24K (declared 32K) | 262,144 | 32 | already present; could drop to 24 blocks |
| FDC ROM | 2K | 16,384 | 2 | already present |
| **New: S1 ROM** | 64K x 8 | 524,288 | 64 | CPU port only |
| **New: VGRAM (G+B)** | 32K x 8 | 262,144 | 32 | absorbs the L3 colour RAM (16K x 6 = 98,304 bits, 12 M10K) |
| **New: text RAM** | 2K x 8 | 16,384 | 2 | |
| **New: text colour RAM** | 2K x 7 | 14,336 | 2 | |
| **Net added** | | **+718,848 bits** | **+88** | +12.7 % bits, +15.9 % blocks |

Total RAM 106 KB (matches the brochure's "106K Bytes") + ROM 94 KB (+2 KB MP-1805) for a base S1.
**Estimate: about 60 % of block-RAM bits (about 63 % of M10K blocks if blocks track bits today).
It fits beside the L3 design; no SDRAM is needed for a base S1.** Options:
* Expansion RAM (PA `$00000+`): 64 KB in BRAM is +64 M10K (to about 75 %), possible. 128-512 KB
  needs SDRAM. It is also what B mode's `$FFE8` extended RAM uses (memory.cpp:1352-1360).
* S1DIC (32 KB) is not dumped; nothing to store.
* Fallback if the fit gets tight: move the S1 ROM to SDRAM (CPU-only, 2 MHz = 496 ns cycles, easy).

---

## 9. Staged plan

**M0: plumbing (no behaviour change for L3).** Model parameter `s1` plus OSD "Model: L3 / Mark II
/ Mark 5 / MB-S1" and "S1 mode A/B". `rom_addr[17:0]`. S1 ROM BRAM loaded from boot0
`$10000-$1FFFF`. Replace the 16K x 6 colour RAM with the VGRAM (G plane `[13:0]` = L3 colour
RAM). Check L3 still boots in vsim.

**M1: S1 BASIC prompt (A mode).** Smallest set that should reach `Ready`:
1. MMU: 16 map registers, SU bit with vector-fetch override (needs `BS`/`BA` from
   `mc6809is`), system-mode pages E/F, B mode = `$F0000|a`.
2. Physical decode of 2.4/2.5: system RAM, text RAM + 7-bit colour latch, graphic window
   plane logic (2.6), plain G/B windows, IG/font window, S1 ROM, L3 path for `$Fxxxx`.
3. 2 MHz CPU (E = clk/16) with the I/O stretch of 1.4. (Fallback: run at 1 MHz first. It is
   only slower.)
4. S1-only registers `$FE20-$FE2F` as storage + plane logic; palette.
5. Common I/O deltas: `$FFC9` = `$03`, `$FFCA` bit 6, `$FFCD/$FFCE` = `$FF`, `$FFD4` 3 bits,
   `$FFD8` 8 bits, `$FFE1` = `$01`, `$FFEB`, PSG at `$FFE4/5` (a `jt49` from `rtl/jt49`;
   a stub that reads `$FF` only makes BASIC mark the PSG absent).
6. Fixed 60 Hz FIRQ, fast timer, fixed-rate keyboard counter.
7. Renderer: CRTC at 2 MHz in A mode, S1 text path (40/80, page, colour bits, reverse, cursor
   with the 40-col compare), palette, border from `$FFD0[3:0]`. Graphics planes can render
   black at first: BASIC clears them, so the banner looks right.
   Pass criterion: vsim `--text`-style dump of PA `$BC000` (40x25) shows the banner, then
   typing `PRINT 12*3+4` works.

**M2: S1 graphics.** 320x200 / 640x200 8-colour, overlay modes, `DISP-PAGE` enables and pages,
IG in A mode. Test with `LINE`/`PAINT`/`COLOR` and the S1 games in `software/` (Jelda, Lode
Runner, Dezeni Land; S1 tapes `.l3b`/`.l3c`: confirm the formats against EmuB-S1 `cmt.cpp`).

**M3: B mode on the S1.** Should be nearly free: L3 path + `rom1/rom2` + timer/keyboard clock
differences + `$FFD7` 4 bits. Check against the 30570-bytes banner.

**M4: completeness.** FUSE/TRON/user mode, TRAP, IMK, palette-read HALT, `$FFE9` status bits,
DRAM/display waits (speed accuracy), 64-colour and 640x400, mouse, PIA-A joystick, `$FFD7`
300/2400 tape, S1 FDC boot (the MP-1802 card via `$EFFxx`; `rom1` has the S1's own disk boot
at `$F800`), kanji card.

**M5: expansion RAM** (BRAM 64 KB or SDRAM up to 512 KB).

### Risks

1. **Vector-fetch detection with `mc6809is`.** `BS & ~BA` must be valid in the same cycle as
   the vector address, or the vector is read from the user map. Fallback: also force system
   mode when the CPU address is `$FFF0-$FFFF` during an interrupt sequence. Check in vsim first.
2. **2 MHz cycle stretching** inside `mc6809is` (enables only, no wait input): the stretch has to
   be applied by withholding `fallE/fallQ`. Make sure the address is stable early enough in the
   cycle to decode "slow I/O" before the 2 MHz `fallQ`.
3. Speed accuracy without the DRAM/display waits: the S1 will run a little fast in graphics
   mode. Timing loops in games may notice. The cassette is byte-level, so tape loading is not at
   risk.
4. BRAM fit is comfortable, but routing at 32 MHz with 2 MHz CPU paths through the bigger read
   mux should be checked early (M0 build).

### Open questions

1. Exact A-mode screen set-up after the probes (system calls `$42 $1B`, `$42 $0F`, ...): run
   EmuB-S1's debugger or our vsim with `--trace-io` once M1 decode exists, and record the
   golden colours (foreground, border, palette).
2. IG access HALT: the manual says reading `$FFE9` during display HALTs the CPU until retrace
   [S1OpMan p.98]. EmuB HALTs on a **palette** read instead (display.cpp:454-476) and returns
   status on `$FFE9`. Which is right?
3. What the boot's text-RAM test with `$FFE9` toggling detects (flag `$EE32` bit 3; perhaps the
   Reamraito clone).
4. Reset contents of the map registers (EmuB 0, MAME `$F0|i`); harmless for the ROM but visible
   to software that reads MAP before writing it.
5. Code `$7F` glyph difference between A and B mode, and whether the real S1 uses the 8 KB
   `S1FONT.ROM` (IC27) for anything in A mode. EmuB renders both modes from the 4 KB font.
6. The 60 Hz timer source on real hardware (EmuB: fixed; the L3: CRTC VSYNC). It matters only if
   software reprograms the CRTC to a non-60 Hz frame.
7. Whether the S1 keyboard counter really ignores CRTC HSYNC (EmuB says fixed 15.75 kHz).
8. 64-colour palette correctness: EmuB-S1's own spec says the colours are unverified.
