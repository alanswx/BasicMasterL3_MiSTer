# EmuB-6892 / EmuB-S1 build instructions — English translation (combined)

Sources: `src/source/README.md`, `README_SDL.md`, `README_WX.md`, `README_QT.md`,
`README_WIN.md` in both `ref/emulators/EmuB-6892` and `ref/emulators/EmuB-S1`. The S1
files are identical apart from names (`bml3mk5` -> `mbs1`, EmuB-6892 -> EmuB-S1) and an
extra `font/dict/` folder (pseudo kanji-dictionary ROM script). Below, `APP` = `bml3mk5`
or `mbs1`. Both repos also have a top-level `BUILD.md` that only links to
`src/source/README.md`.

Note: a `src/source/CMakeLists.txt` exists (project `bml3mk5`, `VMTARGET _BML3MK5`,
cmake >= 3.12) but the READMEs only list it ("build file for cmake") and do not document
it. The documented paths are the per-OS Makefiles.

## Source tree (README.md)

```
docs/                 documentation
font/                 screen-font creation scripts
  kanji/              pseudo kanji ROM tool (SDL/ and Win/ versions)
  dict/               (S1 only) pseudo kanji dictionary ROM script
source/
  data/ include/ lib/
  locale/             gettext translations (list.xml; ja/APP_ja.qm, APP_ja.ts for Qt;
                      ja/LC_MESSAGES/APP.po, APP.mo)
  src/
    extra/            misc
    gui/              GUI: agar/ cocoa/ gtk_x11/ qt/ windows/ wxwidgets/
    osd/              OS-dependent: gtk/ qt/ SDL/ windows/ wxwidgets/
    res/              resources
    video/            recording: avkit/ cocoa/ ffmpeg/ mmf/ libpng/ qt/ qtkit/ vfw/
                      wave/ windows/ wxwidgets/
    vm/               the VM (emulation core)
  patch/              agar-1.4.1, agar-r9049 (Agar 1.4.2 beta), SDL-1.2.15-mac-keyboard
                      (fn key on mac), SDL_net-1.2.8, SDL2-2.0.8/2.26.5/2.28.5-mac-keyboard,
                      SDL2_net-2.0.0 patches
  Eclipse/            sdl_linux, sdl_win (Pleiades), wx_linux, wx_win
  VC++2010 .. VC++2019/  APP.vcxproj (Win32), APP_sdl.vcxproj, APP_wx.vcxproj,
                      mmf_loader.vcxproj (DLL to load Media Foundation dynamically)
  Xcode/              Xcode projects
  CMakeLists.txt      cmake build file
  Makefile.xxx        makefiles per OS
```

Editions: Windows (VC++), SDL, wxWidgets, Qt.

## SDL edition (README_SDL.md)

### macOS
- Maintained: **SDL2 + Cocoa** -> `Makefile.mac_cocoa2`, `Makefile.mac_cocoa2_dbgr`
  (debugger build). Other Makefiles are not maintained.
1. Environment: install Xcode (Command Line Tools seem to come with it). Install the
   libraries in Terminal (Xcode itself is not used):
   - From source: **SDL2-2.28.5** — apply `patch -p 1 < SDL2-2.28.5-mac-keyboard.patch`,
     then `./configure && make && make install`; **SDL2_ttf-2.20.2** —
     `./configure && make && make install`; **FFmpeg-6.1.1** — headers are needed in the
     `include` folder (see the FFmpeg macOS compilation guide). To build without FFmpeg,
     comment out `#define USE_REC_VIDEO_FFMPEG` in `src/rec_video_defs.h`.
   - Or Homebrew: install `sdl2`, `sdl2_ttf`, `ffmpeg@6`.
2. Command-line build (Terminal):
   - With Homebrew, edit the Makefile: set `SDLPATH` to `/opt/homebrew`; add
     `-I/opt/homebrew/opt/ffmpeg@6/include` to `SDL_CFLAGS`.
   - Shared binary: `make -f Makefile.xxx clean` then `make -f Makefile.xxx install`.
     `install` creates a `ReleaseSH` directory **above** the make directory and copies
     the needed files there (nothing goes to /usr/local). Change `SH_INSTALLDIR` to move it.
   - Static binary: `make -f Makefile.xxx st_clean` then `make -f Makefile.xxx st_install`
     (`ST_INSTALLDIR`).
3. Xcode build: open the project in `Xcode/`; if headers/libs are not under /usr/local set
   Header/Library Search Paths in Build Settings.

### Linux
- Maintained: **GTK+3 + SDL2** -> `Makefile.linux_gtk_sdl2`, `Makefile.linux_gtk_sdl2_dbgr`.
1. Install dev packages (apt/Synaptic on Debian/Ubuntu, yum on Red Hat/Fedora): gcc, g++,
   make; `gtk-3.0-dev`, `libsdl2-dev`, `libsdl2-ttf-dev`; for recording
   `libavcodec60-dev`, `libavutil58-dev`, `libavformat60-dev`, `libswscale7-dev`
   (ffmpeg 6).
2. Shared: `make -f Makefile.xxx clean; make -f Makefile.xxx install` (creates `Release`
   above the make directory; `SH_INSTALLDIR`). Static: `st_clean`, `st_install`
   (`ST_INSTALLDIR`).

### MSYS2 + MinGW64 (Windows)
- Maintained: **SDL2 + Win GUI** -> `Makefile.win_gui2`, `Makefile.win_gui2_dbgr`.
- pacman: `mingw-w64-x86_64-gcc`, `-make`, `-SDL2`, `-SDL2_ttf`, `-ffmpeg6` (probably
  missing; get the include files as for VC++). Adjust `GCCLIBDIR`, `SH_LOCALDIR`,
  `ST_LOCALDIR` (packages install under `/mingw64/lib/`). Shared: `clean`/`install`
  (`ReleaseSH`); static: list all libraries in `LOCALLIBS`, then `st_clean`/`st_install`
  (`ReleaseST`).

### VC++ (Windows), SDL edition
- Build SDL2-2.28.5 (`VisualC/SDL.sln`; copy dll/lib to `lib/Release/x86`) and
  SDL2_ttf-2.20.2 (`SDL_ttf.sln`). FFmpeg-6.1.1 headers in `include` (64-bit shared build
  from gyan.dev `ffmpeg-6.1.1-full_build-shared.7z`, or GyanD/codexffmpeg 6.1.1 on GitHub;
  with headers a 32-bit build is possible; v5 headers build; v4 headers build but are
  untested). Build `*_sdl.vcxproj`; in View -> Property Manager -> Release, edit the user
  macros' paths.

## wxWidgets edition (README_WX.md)

- macOS: **wxWidgets3 + SDL2** -> `Makefile.mac_wx2`, `Makefile.mac_wx2_dbgr` (SDL is used
  for sound). wxWidgets-3.2.4 from source: static —
  `../configure --with-osx_cocoa --disable-debug --disable-shared --enable-unicode`;
  shared — `--enable-shared`. SDL2-2.28.5, FFmpeg-6.1.1 as above. Or Homebrew `sdl2`,
  `wxwidgets`, `ffmpeg@6`. Build as for SDL (`clean`/`install`, `st_clean`/`st_install`),
  or Xcode.
- Linux: `Makefile.linux_wx2`, `Makefile.linux_wx2_dbgr`. Packages:
  `libwxbase3.2-dev`, `libwxgtk3.2-gtk3-dev`, `libsdl2-dev`, ffmpeg 6 dev libs (or build
  wxWidgets with `--with-gtk`; FFmpeg from source with
  `--disable-static --enable-shared --disable-programs --disable-doc`). For a static
  build set `WXDIR` to the wxWidgets build directory.
- MinGW + MSYS (Windows): `Makefile.win_wx2`, `Makefile.win_wx2_dbgr`; wxWidgets-3.1.0
  with `--with-msw`.

## Qt edition (README_QT.md)

- With Qt Creator: open `source/Qt/APP_qt.pro`; add a make build step with argument
  `install` (copies resources into the build directory, not the system); for a debugger
  build add qmake argument `CONFIG+=debugger`. FFmpeg-6.1.1 headers in `include` (Ubuntu:
  `libavcodec-dev libavformat-dev libswscale-dev`).
- Without Qt Creator (Ubuntu 19.04 example): install `libqt5opengl5-dev`,
  `libqt5gamepad5-dev`, `qtmultimedia5-dev` (+ the ffmpeg dev packages); make a build
  subdirectory under `source/Qt`, cd into it,
  `qtchooser -run-tool=qmake -qt=5 ../APP_qt.pro` (add `"CONFIG+=debugger"` for the
  debugger), then `make` and `make install`.
- Translations: `lupdate -tr-function-alias QT_TR_NOOP+=_TX APP_qt.pro`, then `lrelease`.
  Merging the gettext `.po`: open `APP.po` in Linguist, save as `APP_ja.ts`, run lupdate,
  then lrelease.

## Windows (VC++) edition (README_WIN.md)

Open the `.vcxproj` in Visual Studio and build. FFmpeg-6.1.1 headers as above (or comment
out `USE_REC_VIDEO_FFMPEG`). `mmf_loader` builds the DLL used for Microsoft Media
Foundation.
