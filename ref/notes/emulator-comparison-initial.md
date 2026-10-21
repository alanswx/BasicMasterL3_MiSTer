# EmuB-6892 vs MAME bml3: initial comparison

Written 2026-10-21. Sources:

- EmuB-6892 V2.1.4, commit `0bd0afe`, at `ref/emulators/EmuB-6892/src/source/src/vm/bml3mk5/`. Tagged [EMUB] below.
- MAME `src/mame/hitachi/bml3.cpp` / `bml3.h` from the local checkout at
  `~/Documents/development/BasicMasterJr_MiSTer/mame/`. Tagged [MAME] below.

Neither one counts as ground truth. Settle each disagreement from the service manual or a ROM
disassembly, and record the verdict in `mame-vs-emub-verdicts.md`.

## Summary table

| Point | EmuB-6892 | MAME bml3 | Verdict needed? |
|---|---|---|---|
| CPU clock | `CPU_CLOCKS 1008000` (`bml3mk5_defs.h`) | 32.256 MHz / 8 = 4.032 MHz EXTAL, /4 = 1.008 MHz (`bml3.h`) | Agree |
| ROM / RAM banking, $A000-$EFFF | PIA port A (`$FFC0`) bits 1,2,3 (keep) and 6,7 (RAM read) (`MEMORY::write_signal SIG_MEMORY_PIA_PA` → `change_l3_memory_bank`, mask `0xce`) | Same bits (`bml3_state::piaA_w`) | Agree |
| $F000-$FEFF and $FFF0-$FFFF RAM read | **`$FFE8` bit 0 → $F000-$FEFF, bit 1 → $FFF0-$FFFF** | **PIA A bit 0 → $F000-$FEFF, bit 1 → $FFF0-$FFFF** | **YES**: they disagree on the source register |
| $FFE8 | Mark 5 bank register. Bit 0 = $F000-$FEFF RAM read. Bit 1 = $FFF0 RAM read. Bits 2/3 = swap the VRAM window $0400-$43FF with extended RAM (`(r & 0x0c)==0x04 or 0x08`). Bit 3 = $0000-$7FFF writes go to extended RAM. Bit 4 = $8000-$FFFF writes go to extended RAM. Bit 5 = extended RAM is also read. Bits 4+6 = $8000-$FFFF R/W extended RAM. Extended RAM only exists if `exram_size_num==1` (the L3mk5ExRam card). Write-only; reads return $FF unless DEBUG_READ_OK | Unimplemented (commented-out map line, listed in TODO) | EmuB is the only reference. Cross-check against the `L3mk5ExRam` card schematic/readme in `ref/hardware/L3mk5ExRam` |
| VRAM / attribute latch | Write to $0400-$43FF: `color_ram = color_reg & 0x3f` (always, 6 bits). Read: `color_reg = color_ram` unless color_reg bit 7 (MK) is set. `$FFD8-$FFDF` write: `color_reg = data & 0xbf`. Read returns `(color_reg & 0xbf) \| 0x40` | Write: `aram = latch & attr_mask` (5 bits on L3, comment says "will break hiwriter"). Read: latch = aram unless bit 7 | Mostly agree. Attribute width (5 vs 6 bits) and the write mask differ |
| FIRQ source | `TIMER`: the CRTC VSYNC signal sets `timer_irq=0x80` and asserts FIRQ unless `$FFD4` bit 7 (time mask) is set. Reading `$FFCA` returns bit 7 and clears FIRQ. Writing `$FFD4` with bit 7 set clears it (`timer.cpp update_timer_clock`, `read_io8`) | `timer_firq` at screen VBLANK, masked by `$FFD4` bit 7. `$FFCA` read returns status bit 7 and clears | Agree (VSYNC from the 6845 vs screen vblank: the timing differs slightly) |
| IRQ sources | Keyboard (`$FFE0` bit 6 enable), light pen, PIA B, ACIA (`acia->set_context_irq(board, SIG_CPU_IRQ, SIG_IRQ_ACIA_MASK)`), the extension PIA/ACIA cards, the 9-voice PSG VIA | Keyboard IRQ via HOLD_LINE. **The ACIA IRQ only logs (`acia_irq_w`) and is not connected to the CPU** | EmuB looks right. MAME is missing the ACIA IRQ |
| NMI sources | BREAK key (`$FFC8` bit 7, enabled by `$FFE0` bit 7), floppy (MP-1805 / MP-1802 IRQ goes to NMI), trace counter (`$FFD1` write starts an NMI single-step counter) | BREAK only sets `$FFC8` bit 7. No NMI ("TODO") | EmuB is more complete |
| Keyboard scan | Clocked by the CRTC **HSYNC** (`crtc->set_context_hsync(key, SIG_KEYBOARD_HSYNC)`). It alternates `clear_scan_code` and `update_scan_code`, so one scan code takes 2 HSYNCs. Codes 0x00-0x6F are keys; 0x70-0x7E are unassigned; 0x7F signals "key released" after a full empty scan (`m_key_pressed` 2→1). `$FFE0` write: bit 3 = counter limited to 0-7, bit 6 = IRQ enable, bit 7 = BREAK NMI enable; bits 0-2 = LEDs. Reading `$FFE0` returns the scan code with bit 7 = hit, clears bit 7 and the IRQ. Optional "original key limit" auto-release (`remain_count`). Special codes: 0x80 = BREAK, 0x7F = reset, 0x7E = power, 0x7D = mode switch (`keyboard.cpp update_keyboard`, `update_scan_code`, `update_special_key`) | Timer at H_CLOCK/2 (≈7.875 kHz, a fixed timer rather than the CRTC). Scan codes 0-95 are read from 3×32-bit ports. 0x7F = empty-scan trigger. Hit bit 7 latched; IRQ HOLD_LINE if `$FFE0` bit 6; auto-clear after `m_kbt=0xfff` ticks. `$FFE0` bits the same (LEDs 0-2, bit 3 counter disable, bit 6 IRQ, bit 7 NMI) | Same algorithm. Differences: EmuB is tied to the real HSYNC (so it follows CRTC programming), allows codes up to 0x6F, and implements the BREAK NMI |
| ACIA clock / tape | **No 16× clock.** In real-time mode the CMT device ticks at `CPU_CLOCKS/baud` (bit images) or `CPU_CLOCKS/baud*11` (byte images, `.l3`) and pushes RX bits/bytes into the ACIA with `SIG_ACIA_RXCLK`/`SIG_ACIA_RXDATA`. Non-real (fast) mode ticks at `CPU_CLOCKS/38400`. 600 baud by default; `$FFD7` bit 0 = 1200 baud (`cmt.cpp set_baud`, `register_my_event`, `event_callback`) | `clock_device` 9600 Hz (600 baud × 16) or 19200 Hz on `$FFD7`, driving TXC/RXC. Cassette decoded by counting zero-crossings at 40 kHz (`kansas_r`). Encoding at 4800 Hz (`kansas_w`) | Same nominal rates. The hardware divider and the 16× clock need the service manual. MAME is closer to the hardware. EmuB has the better image handling |
| ACIA routing | `$FFD0` bit 5 ("C"/RS bit) selects RS-232C (COMM) vs cassette. `COMM::write_signal SIG_COMM_RS` routes RX/TX either to the CMT or to the serial port | Comment in `mode_sel_w` (bit 5 = cassette/RS-232C) but not implemented | Agree on meaning |
| $FFD0 mode bits | Bits 0-2 = background colour. Bit 5 = RS-232C select. Bit 6 = 0: hi-res (640/320×200 bitmap, RA-paged at +0x400/0x800 per raster), 1: normal (2×4 semigraphic blocks per character cell). Bit 7 = 80 columns (CRTC char clock ×2) (`DISPLAY::write_io8 0xffd0`) | Bit 7 W = 80 columns, bit 6 HR (0 = high res), bit 5 C (ACIA), bits 0-2 background (`mode_sel_w`, p.43 of the service manual) | Agree. Neither uses bits 3/4 |
| $FFD6 interlace | Bit 3 (`REG_INTERLACE_SEL`): interlaced character rows | `m_vres_reg`, used together with CRTC R8 | Agree on the address. Check the bit |
| $FFD2 / $FFD3 | Remote = bit 7. Music = bit 7 | Same | Agree |
| $FFC9 | DIP switches (default `0x03`) | DIP switches | Agree |
| $FFE9 / $FFEA (IG) | `$FFE9` bit 0 = IG enable (when it is set, writes to $A000-$A7FF go to IG RAM, write-through to the 3 planes selected by `$FFEA` bits 0-2) | IG view | Agree in outline |
| Extension I/O | `$FF00-$FF04, $FF08` MP-1802 5"/8" FDC. `$FF18-$FF1F` MC6843 (MP-1805 3"). `$FF20-$FF27` 3" drive select. `$FF30-$FF33` 6-voice PSG (PIA). `$FF38-$FF39` RTC. `$FF3C-$FF3F` extension printer PIA. `$FF40-$FF41` extension ACIA. `$FF60-$FF63` extension PIA. `$FF70-$FF7F` 9-voice PSG (VIA). `$FF75-$FF76` kanji ROM | Bus slot devices (`bus/bml3`): mp1802, mp1805, kanji, rtc | EmuB is far more complete |

## Notes

- The biggest real disagreement is **where the $F000-$FEFF and $FFF0 RAM-read bits live**.
  MAME takes them from PIA A bits 0/1. EmuB takes them from `$FFE8` bits 0/1 and ignores PIA A bit 0
  (it masks with `0xce`). On a non-Mark 5 machine that has no `$FFE8`, EmuB still models it, because
  this emulator is Mark 5 only. Check this against the service manual's ROM-KIL logic and against how
  the BASIC ROM writes to `$FFC0`.
- MAME's font (`font.rom`, CRC `0b6f2f10`, "handcrafted") has **the same CRC as the `tool/FONT.ROM`
  that ships with every EmuB-6892 release**. The EmuB manual says that file is "my own work; it
  differs slightly from the real machine". MAME is therefore using Sasaji's hand-made font, not a dump.
- `l3bas.rom` (24 KB, CRC `d81baa07`) is the same image MAME keeps commented out. EmuB checks only
  that the first two bytes are `C4 5C`, and it only warns if they differ.
