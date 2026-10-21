# EmuB documentation index (English)

English translations/summaries of the Japanese docs shipped with Sasaji's emulators.
Originals are UTF-8 (the CSP history is Shift-JIS/CP932).

- EmuB-6892 = Basic Master Level 3 Mark 5 emulator (`bml3mk5`), V2.1.4, commit 0bd0afe,
  `ref/emulators/EmuB-6892/`
- EmuB-S1 = MB-S1 model05 emulator (`mbs1`), V0.9.4, commit 6a2eb1c, `ref/emulators/EmuB-S1/`

## Translations in this folder

| File | Content |
|---|---|
| [emub6892-spec.md](emub6892-spec.md) | spec.txt for EmuB-6892, full: known issues, device support table, I/O port support table `$FF00-$FFEA` |
| [emubs1-spec.md](emubs1-spec.md) | spec.txt for EmuB-S1, full: device support, I/O table including `$FE00-$FE43` system I/O (MMU MAP/FUSE/SEGMENT/TRAP, palette, planes) |
| [emub6892-manual-mac.md](emub6892-manual-mac.md) | readme_mac_cocoa.txt for EmuB-6892, full: ROM files, menus, options, keys, command line, disk geometry, tape formats, kanji ROM format |
| [emubs1-manual-mac.md](emubs1-manual-mac.md) | readme_mac_cocoa.txt for EmuB-S1: every section that differs from the 6892 manual, in full (S1 ROMs with physical addresses, A/B mode, I/O options, S1 keys, interrupts, LED `$FFEB`) |
| [emub-manual-other-editions.md](emub-manual-other-editions.md) | How readme_sdl / readme_wx / readme_qt / readme_win differ from the Mac Cocoa readme (both emulators) |
| [emub-debugger.md](emub-debugger.md) | debugger.txt, 6892 in full plus S1 additions; includes the **interrupt-source tables** (NMI/IRQ/FIRQ/HALT per device) |
| [build.md](build.md) | src/source/README*.md (build instructions for SDL, wx, Qt, VC++ editions), combined for both emulators |
| [emub-history-summary.md](emub-history-summary.md) | Condensed history.txt of both emulators, hardware-accuracy items only |

## Every file in `src/docs/` (both repos have the same set)

| File | One-line summary | Translation |
|---|---|---|
| `spec.txt` | Known issues, device support and I/O port support tables | emub6892-spec.md, emubs1-spec.md |
| `readme_mac_cocoa.txt` | User manual, SDL2 + Mac Cocoa edition | emub6892-manual-mac.md, emubs1-manual-mac.md |
| `readme_sdl.txt` | User manual, SDL edition (Mac/Linux/Windows; Agar notes, 3-host key table) | emub-manual-other-editions.md |
| `readme_wx.txt` | User manual, wxWidgets edition (beta; wx 3.2.4) | emub-manual-other-editions.md |
| `readme_qt.txt` | User manual, Qt edition (beta; Qt 5.12.4) | emub-manual-other-editions.md |
| `readme_win.txt` | User manual, native Win32 edition (Direct2D/3D, DirectInput, Media Foundation) | emub-manual-other-editions.md |
| `debugger.txt` | Telnet debugger (port 54321) command reference, trace format, interrupt-source bits | emub-debugger.md |
| `history.txt` | Change log (6892: 2011-2026; S1: 2015-2026) | emub-history-summary.md |
| `CSP/readme.txt` | Takeda's "retro pc emulator common source code" readme dated 2/16/2012: list of CSP machines, **licence: "you can use the source codes under the GNU GENERAL PUBLIC LICENSE"**, credits (mc6809 from MAME, mb8877 from XM7, fmgen from M88, etc.) | (English original; not translated) |
| `CSP/history.txt` | CSP upstream change log up to 3/20/2012 (Shift-JIS file, English text), the version EmuB merged | (English original) |

The `CSP/` files are byte-identical in both repos. `src/COPYING.txt` in both repos is
the **GNU GPL v2** text.

## Other docs nearby (not in src/docs)

| File | Summary |
|---|---|
| `README.md`, `BUILD.md` (repo root) | Bilingual summary, disclaimer, link to releases; BUILD.md links to src/source/README.md |
| `src/source/README*.md` | Build instructions -> build.md |
| `src/font/readme.txt` | Bilingual: `FONT.ROM` (6892, 4096 bytes) / `S1FONT.ROM` (S1, 8192 bytes) are **author-made compatible font ROMs** (not dumps); `kanji/` makes pseudo kanji ROMs; `dict/` (S1) makes a pseudo dictionary ROM |
| `src/font/kanji/{SDL,Win}/readme.txt`, `src/font/dict/readme.txt` | Japanese instructions for the pseudo kanji / dictionary ROM generators (not translated) |
