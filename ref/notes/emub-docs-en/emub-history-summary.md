# EmuB-6892 and EmuB-S1 change history — condensed English summary

Sources: `ref/emulators/EmuB-6892/src/docs/history.txt` (V0.1.0 2011-10-01 to V2.1.4
2026-07-12) and `ref/emulators/EmuB-S1/src/docs/history.txt` (Build 14 2015-09-23 to
V0.9.4 2026-07-12). Pure UI, host-OS, recording-library and packaging items are left out;
everything touching emulation accuracy is kept. Since 2022 the two emulators share most
changes (same dates).

## EmuB-6892 (bml3mk5) — hardware-relevant changes, newest first

| Date / version | Change |
|---|---|
| 2026-07 V2.1.4 | Kanji ROM image is (re)read at power-on. |
| 2026-03 V2.1.3 | **VIA output buffer behaviour changed** (9-voice PSG card's VIA). Pseudo kanji ROM tool: no dot in the right-most column, or `KANJI` statements show nothing. |
| 2025-12 V2.1.2 | **MB8866 FDC Busy flag set earlier**; option to ignore the Busy delay. |
| 2025-11 V2.1.1 | **MB8866: Busy is set a few cycles after a command is written** (was immediate). |
| 2025-10 V2.1.0 | HFE disk images; floppy code reworked. **MC6843 FDC: FFR command implemented.** **MC6809: fixed — reset signal was initialising registers** (real 6809 reset does not clear registers). **PIA: reading a port whose pins are set to output always returned 0 — fixed.** Joypad on PSG port. |
| 2024-12 V2.0.1 | Joypad on PIA A port. |
| 2024-04 V2.0.0 | Sound output reworked. |
| 2024-01 V1.9.5 | **PSH instructions now do the dummy read; so if the stack is in the VRAM area the colour register is updated** (VRAM reads latch the colour/attribute register — a real side-effect). |
| 2023-07 V1.9.3 | Option to clear CPU registers at power-on. |
| 2023-03 V1.9.2 | FD boot/access could fail at >=2x overall speed — fixed. |
| 2022-04 V1.8.7 | **Reading the VRAM address area of the extended RAM updated the colour register — fixed** (only main VRAM reads should). |
| 2021-06 V1.8.5 | COM to host serial port; byte-mode COM paced at the baud rate; ACIA was wrongly reset on disconnect. **PSG: out-of-range address latch values are ignored.** |
| 2021-04 V1.8.1 | FD density/media checks (off by default). **MB8876: if DRQ was left on without reading the data register, DRQ was not cleared after the next command — fixed.** |
| 2021-03 V1.8.0 | "Dull key input" option for BASIC games. |
| 2020-04 V1.7.1 | **Fixed: KB register was cleared when no key input followed a key release.** CRTC cursor-skew display made closer to the real machine. Debugger shows interrupt sources. |
| 2020-03 V1.7.0 | **IRQ and FIRQ interrupt behaviour changed.** 8-inch FDC masking behaviour changed. **CRTC: changing disptmg/curdisp skew reset vsync — fixed.** Delayed (5 s) disk write-back. |
| 2019-10 V1.6.4 | **Joystick (PIA) on broke bank switching — fixed** (PIA A port also drives banking). **BREAK key behaviour changed slightly.** |
| 2019-05 V1.6.3 | **ACIA even-parity check was wrong — fixed.** |
| 2018-07 V1.6.1 | Drawing logic fixed; 8-inch FD behaviour changed. |
| 2018-03 V1.6.0 | Drawing logic changed. **Tape logic changed**, rewind changed. Joystick on extension PIA B. **RTC implemented.** BASIC-level debugger. |
| 2017-12 V1.5.6 | IG can be disabled (L3 / Mark II compatibility). |
| 2017-11 V1.5.5 | **FDC: seek to the same track moved the head — fixed.** |
| 2017-07 V1.5.3 | FD access time computed from the image's sector order. |
| 2017-06 V1.5.2 | FDC seek could hang — fixed. **Reset while stopped in CWAI/SYNC did not restart — fixed.** |
| 2017-06 V1.5.1 | PSG behaviour changed slightly. FD CRC calculation fixed (unused). |
| 2017-03 V1.5.0 | Power-on reset behaviour changed. **I/O: colour register mirrored at `$FFD8-$FFDF`, KB register at `$FFE0-$FFE7`.** WRITE TRACK rebuilds the whole track. Undefined-opcode message option. |
| 2017-02 V1.4.7 | **ROM images are checked when loaded** (data check; no hash given in docs). 5" FDC READ ADDRESS could make sectors unreadable — fixed. |
| 2016-06 V1.4.3 | 5" FDC READ TRACK implemented. Extended memory optional. |
| 2016-04 V1.4.1 | DISK BASIC after reset gave Drive Not Ready — fixed. |
| 2016-04 V1.4.0 | Debugger. 8-inch mode (untested). FDD error handling changed. |
| 2016-01 V1.3.6 | CRTC: some settings shifted the cursor position — fixed. |
| 2015-12 V1.3.1 | **Frequent NMIs caused a crash — fixed.** Trace processing changed. |
| 2015-11 V1.3.0 | VM in its own thread; 4 FDDs; 1S disk images. |
| 2015-10 V1.2.8 | Saving to tape in L3 format after Load State could be wrong — fixed. One drive's motor-off turned off all motors — fixed. |
| 2014-09 V1.2.3 | **VRAM-area bank switching behaved differently from the real machine — fixed. Extended RAM can no longer be used as VRAM. IGENREG now initialised on reset.** |
| 2014-11 V1.2.4 | Reset enabled IG (regression in 1.2.3) — fixed. |
| 2014-08 V1.2.2 | **IG display behaviour differed from the real machine — fixed** (regression from 1.2.0). |
| 2014-05 V1.2.1 | Tape load sound pitch follows CPU speed. |
| 2014-04 V1.2.0 | Write protect, FDD sounds, tape counter, **T9X tape images (provisional)**, key recording. 5" FD write-protect error not raised — fixed. Upper-case tape file names broke format detection — fixed. |
| 2014-02 V1.1.1 | Non-linear-PCM WAV hung — fixed. **After setting 1200 baud and resetting, the tape load sound was wrong — fixed.** |
| 2013-12 V1.1.0 | Core changed; CPU x0.5; printer to mpprinter over network; extension LPT1/LPT2, COM1. MUSIC_SEL at high CPU speed fixed. |
| 2013-11 V1.0.0 | Per-device volume; MUSIC_SEL filter changed. |
| 2013-07 V0.9.7 | **KB mode: when the UE flag = 1, the key counter range is 0-7.** |
| 2013-05 V0.9.6 | Some games did not auto-start after loading — fixed. 5" FDC WRITE TRACK. |
| 2013-03 V0.9.5 | **BREAK key behaviour fixed.** |
| 2013-01 V0.9.3 | 3-voice PSG extended to 6-voice PSG. |
| 2012-10 V0.9.1 | IG display wrong under some condition — fixed. |
| 2012-09 V0.9.0 | **Real-speed cassette mode** with tape sound; relay sound. |
| 2012-08 V0.8.7 | CRTC disptmg/curdisp skew settable in a dialog. |
| 2012-08 V0.8.6 | **CRTC start address below `$0400` displayed wrongly — fixed.** |
| 2012-07 V0.8.3 | **Memory bank switching was not initialised on reset — fixed.** |
| 2012-07 V0.8.2 | Rewind did not work for L3C and WAV — fixed. |
| 2012-07 V0.8.0 | **9-voice PSG and VIA implemented.** Tape rewind/FF. **3-voice PSG moved behind a PIA.** **ACIA bug fixed.** Merged CSP 2012/03/20. |
| 2012-06 V0.7.5/0.7.4/0.7.3 | CRTC display bugs fixed; display timing fixed; screen drawn in step with CPU speed. |
| 2012-06 V0.7.2 | Some WAV tape images would not load — fixed. |
| 2012-04 V0.7.0b | FDD and no-FDD builds merged. WAV tapes at 11025/22050/44100/48000 Hz, 8/16 bit. |
| 2012-03 V0.5.2 | **FDD: IRQ and DRQ flags at `$FF04` were inverted — fixed.** IRQ timing changed. |
| 2012-03 V0.5.1 | SyncIRQ fixed. |
| 2012-03 V0.5.0 | `$FF04` behaviour fixed. |
| 2012-02 | Merged CSP 2012/02/22. **PSG I/O only at `$FF30`, `$FF32` (`$FF00` dropped).** |
| 2012-01 V0.5.0a | 5" 2D FDD implemented. |
| 2011-12 V0.3.4 / 0.1.9 | **Keyboard scan counter now driven by the CRTC HSYNC, and the timer FIRQ by the CRTC VSYNC.** |
| 2011-12 V0.3.3 | IG RAM initialisation changed. |
| 2011-11 V0.3.2 | **IG display disabled at power-on.** FD format command fixed. |
| 2011-11 V0.3.0 | 1S (3") FDD implemented. **Unused I/O reads return `$FF`.** |
| 2011-10 V0.1.4 | CRTC cursor skew / disptmg skew implemented. ACIA parity error check fixed. Kanji ROM implemented. |
| 2011-10 V0.1.2/0.1.3 | `SCREEN ,16` (page 16) display fixed. **IG shown as soon as IGMODREG is written.** Kanji ROM registers. RESET lost IG display — fixed. |
| 2011-10 V0.1.1 | **INTERLACE-SEL behaviour fixed. Period after which the key scan code is invalidated changed. PSG changed to AY-3-8912 equivalent.** |
| 2011-10 V0.1.0 | First release ("more or less complete"). FONT.ROM generator perl script added to source in 0.1.0a. |

## EmuB-S1 (mbs1) — hardware-relevant changes, newest first

Started 2015-09-23 (Build 14) "newly created, reused from BML3MK5". Shares the 2021+
changes listed above (FDC Busy timing, MC6809 reset, PIA output read, VIA buffer, PSG
latch, MB8876 DRQ, ACIA parity, CWAI/SYNC reset, seek-same-track, etc.). S1-specific:

| Date / version | Change |
|---|---|
| 2026-07 V0.9.4 | 68008 card: bus request via `$EFE19` hung both CPUs; NMI masking with `$FE10` IMK blocked 68K NMI; INT5 via `$EFE1A` cleared too early — all fixed. |
| 2026-03 V0.9.3 | With ROM-BASIC boot disabled (来夢来人 behaviour) the cassette status `$FFCD` returns a dummy. |
| 2025-10 V0.9.0 | 2HD mode could not format 2D disks — fixed. |
| 2024-12 V0.8.1 | **With joystick disabled the PIA port returned "all buttons pressed" — fixed.** Option: joystick buttons raise no IRQ. |
| 2024-01 V0.7.5 | **L3 mode: PSH dummy read updates the colour register if the stack is in VRAM.** |
| 2023-09 V0.7.4 | **S1 mode: CRTC start address `$800` displayed text wrongly — fixed.** |
| 2022-12 V0.7.1 | Ext PSG as AY-3-8910 was an octave low — fixed. |
| 2022-10 V0.7.0 | YM2608 (OPNA) FM; 68008 card (special build). |
| 2022-04 V0.6.7 | **L3 mode: reading the VRAM area of extended RAM updated the colour register — fixed.** |
| 2020-03 V0.5.0 | Z80B card (special build). **IRQ/FIRQ behaviour changed.** 2HD FDC masking changed. Ext PSG as FM: status unreadable — fixed. **DISP PAGE with R,G,B bits = 0 (text mode) blocked simultaneous R/G/B plane writes — fixed.** CRTC skew vsync reset — fixed. |
| 2018-03 V0.4.0 | **4800-baud tape supported; tape logic changed.** RTC. |
| 2017-12 V0.3.6 | ROM-BASIC boot and IG can be disabled to reproduce **来夢来人** behaviour. |
| 2017-11 V0.3.5 | **Black text colour made the text invisible even with a non-black background — fixed.** FM card clock settable; ext PSG usable as FM. |
| 2017-07 V0.3.3 | **S1 mode: accessing the L3 VRAM area (`$F0400-$F4400`) rewrote the colour register — fixed.** |
| 2017-06 V0.3.2 | FDC seek bug stopped OS-9 Level II booting — fixed. Debugger blocked user->system mode return — fixed. |
| 2017-06 V0.3.1 | **Power-on reset duration changed.** |
| 2017-03 V0.3.0 | FM sound card. "No memory wait" moved to Configure. |
| 2017-02 V0.2.7 | ROM data check on load. **GCURSOR did not see the mouse button / did not move up-right — fixed.** |
| 2016-06 V0.2.3 | **B mode: bank switching works even without extended RAM.** |
| 2016-05 V0.2.2 | **Accessing extended RAM incurred a wait — fixed** (no wait on ext RAM). 2HD FDD start-up behaviour changed. Keyboard and mouse I/O can be disabled. |
| 2016-04 V0.2.1 | **Joystick (PIA) button raises IRQ.** **High-speed timer (1 ms, 2 ms) period made slightly slower.** Can play BML3MK5 key-record files. |
| 2016-04 V0.2.0 | Debugger. **Mouse button polarity was inverted — fixed.** Communication-card ROM. **A/B mode switches at the moment the reset button is pressed; a short delay after releasing reset before restart.** |
| 2016-03 V0.1.7 | **ALT key raised an IRQ — fixed. A-mode access to `$Fxxxx` changed.** SRAM initialisation changed. |
| 2016-01 V0.1.6 | **OS-9 card segment register implemented (untested). RS-232C baud calculation fixed. `$FFE00-$FFEFF` was I/O — now L3 ROM area. Analog RGB also uses the palette. B-mode colour RAM area changed.** Can load BML3MK5 state files. |
| 2016-01 V0.1.5 | PIA-A joystick. **FUSE and TRACE fixed (untested). 640x400 graphics logic changed. A-mode border colour not drawn inside the display area. B mode: no cursor/reverse while IG shown.** |
| 2015-12 V0.1.4 | 3" FD fixed. Analog RGB does not use palette (reverted in 0.1.6). **IG shown reversed; cursor shown during IG in B mode (changed again in 0.1.5). CPU HALTs during RESET.** |
| 2015-12 V0.1.3 | Frequent-NMI crash fixed. 80-column cursor stretched at >=2x CPU — fixed. |
| 2015-11 V0.1.2 | **A/B mode switch takes effect at reset.** BREAK NMI crash fixed. 1S images. MUSIC_SEL noise fixed. |
| 2015-10 V0.1.1 | **Graphic VRAM writes also updated attribute RAM — fixed.** **2HD + B mode boots from drive 2.** **Trace NMI fired too early — fixed.** |
| 2015-10 V0.1 | First public release. **S1 mode: `$FA000-$FA7FF` now mapped to IG.** PIA A port disabled to stop software mis-detecting a joystick. |
| 2015-10 Build 64 | **`$FA000-$FFFFF` mapped to L3 BASIC.** 4 FDDs. |
| 2015-10 Build 51 | **High-speed timer FIRQ interval fixed. Memory wait handling changed.** |
| 2015-10 Build 36/30 | 320x200x64 and 640x400 modes, 2HD, mouse, ext-RAM size, digital/analog RGB, no-wait option. |
| 2015-09 Build 17/20 | Graphic colours; **graphic/text priority corrected**; ROM loading; **CPU clock lowered on I/O port access**; address-mapping and graphic VRAM real-address bugs fixed; 3" FDD cursor offset adjustable in B mode. |
| 2015-09 Build 14 | Created from BML3MK5. |

## Takeaways for the core

- EmuB timing knowledge accumulated over 15 years: keyboard scan from CRTC HSYNC, FIRQ
  from CRTC VSYNC (L3); 1 ms/2 ms FIRQ timer on the S1; S1 slows the CPU on I/O access and
  has main-memory wait states (none on extended RAM).
- VRAM reads latch the colour register (even 6809 dummy reads such as PSH's), and only
  main VRAM — not extended RAM in the same window — does this.
- Unused I/O reads return `$FF`.
- MC6809 reset must not clear registers; a PIA port read with its pins set to output must not return 0 (EmuB now returns the port state).
- KB register: key counter 0-7 when UE = 1; KB register is not cleared on key release.
