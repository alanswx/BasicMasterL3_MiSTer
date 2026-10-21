# EmuB readme editions: SDL, wxWidgets, Qt, Windows vs. Mac Cocoa

Both emulators ship five readmes in `src/docs/`: `readme_mac_cocoa.txt`, `readme_sdl.txt`,
`readme_wx.txt`, `readme_qt.txt`, `readme_win.txt`. They share the same body; the Mac
Cocoa edition is translated in full in [emub6892-manual-mac.md](emub6892-manual-mac.md)
and [emubs1-manual-mac.md](emubs1-manual-mac.md). The EmuB-S1 editions differ from each
other in the same way as the EmuB-6892 ones. Differences (checked with `diff`):

## readme_sdl.txt — "SDL edition" (Mac / Linux / Windows builds with SDL2)
- Tested on macOS (as Cocoa), **Ubuntu 24.04 64-bit** and **Windows 10 64-bit**.
- Menu/dialog font: the **Agar** build may show garbled kanji in menus; put the IPA font
  `ipagp.ttf` in the program or resource folder (font path settable in Configure).
- Gives the Linux and Windows release layouts (`bml3mk5`/`bml3mk5.exe`, `res/`, `locale/`,
  `tool/`).
- Linux preparation: install packages `libsdl2.0 libsdl2-ttf gtk+-3.0`.
- Shortcut modifier is **Alt** (option on Mac); on Ubuntu Alt is taken by the system, so
  rebind it. Exit = Alt+F4.
- Key table for three hosts:

  | Level 3 key | Mac | Linux | Windows |
  |---|---|---|---|
  | BREAK | F9 | F9 | F9 |
  | GRAPH | F8 / 英数 | F8 / 無変換 | F8 / 無変換 |
  | KATA/HIRA | Tab / right cmd | Tab / 変換 | Tab / 変換 |
  | DEL/INS | delete | Delete / BS | Delete / BS |
  | CAPSLOCK | F7 / Caps | F7 / Caps | F7 / Shift+Caps |
  | Keypad ? | end | End | End |
  | Reset switch | F10 | **F11** | **F11** |
  | Pause | F16 | Pause | Pause |
- Has a Help -> About menu; Exit is in the Control menu (Apple menu on Cocoa).
- Recording libraries: Linux video ffmpeg / audio wave, ffmpeg; Windows video "video for
  windows", ffmpeg / audio wave, ffmpeg. ffmpeg 6.1.1 install notes for Linux
  (`libavcodec60 libavutil58 libavformat60 libswscale7 libswresample4`) and Windows
  (gyan.dev / GyanD codexffmpeg 6.1.1 shared build; `avcodec-60.dll` etc.; no 32-bit).
- Dev environment: Ubuntu 24.04 in VMware, Windows 10 with MinGW + MSYS, SDL2-2.28.5,
  SDL2_ttf-2.20.2. Credits add Agar.

## readme_wx.txt — "wxWidgets edition"
- "The wxWidgets edition is a **beta**; it has some bugs and limitations."
- Drawing methods are "Default Drawing" (on-screen messages/indicators flicker) and
  "Default (Double Buffering)"; with default drawing the filter type is ignored (always
  nearest neighbour).
- Pause key on Mac is **F15**.
- Built with **wxWidgets 3.2.4** on all three platforms.

## readme_qt.txt — "Qt edition"
- Also **beta**. Tested on **Ubuntu 22.04**. Built with **Qt 5.12.4**. Same drawing
  methods and F15 pause as wx. (spec.txt: no joypad under Qt6; fps may not reach 60;
  OpenGL may show a blank screen.)

## readme_win.txt — native Win32 edition
- Windows 11 (AMD 64-bit) / Windows 10 (Intel 64-bit); needs Direct3D (DirectX 9+).
- **ROM note differs:** `MP1805.ROM` is the ROM on the 3-inch MP-1805 **or the 5.25-inch
  MP-1800** I/F board (EmuB-6892 Windows readme only).
- Drawing: GDI+ default / double-buffered, Direct2D sync/async, Direct3D sync/async.
  Option "Use DirectInput for key input".
- Windows key table: GRAPH = F8 / 無変換, KATA/HIRA = Tab / カタカナひらがな, DEL/INS =
  Delete / BackSpace, CAPS = F7 / CapsLock, Reset = F11, Pause = Pause. Alt, Menu and F10
  can be bound but open the system menu. Key settings from before V1.5 are discarded.
- Recording: video for windows, Media Foundation (Windows 7+, via `mmf_loader.dll`),
  ffmpeg.
- `tool/kanji/mkkanji.exe` uses the "MS Gothic" font.
- Dev environment: Windows 10, Visual C++ 2010 Express, Windows SDK 7.1, DirectX SDK
  (June 2010).
