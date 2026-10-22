#!/usr/bin/env python3
"""Convert .l3b / .l3c tape images to .l3 byte streams for the MiSTer core.

The core's tape player feeds bytes to the ACIA (start/stop bits already
stripped), at the baud rate the program selects in $FFD7, so a byte stream is
all it needs even for tapes that change speed (Lode Runner).

  .l3b  ASCII '0'/'1', one character per serial bit: start bit 0, 8 data
        bits LSB first, 2 stop bits 1 (EmuB cmt.cpp). Baud-independent.
  .l3c  ASCII '0'/'1', one character per 1/4800 s sample of the FSK signal:
        1200 Hz = '1100' (a 0 bit is 2 cycles at 600 baud, 1 at 1200),
        2400 Hz = '10'   (a 1 bit is 4 cycles at 600 baud, 2 at 1200).
        Any other character (EmuB-S1 files contain G/H/L) is ignored.

usage: l3conv.py in.l3b|in.l3c out.l3
"""
import sys


def frames(bits, bit_len=1):
    """UART-decode a list of bit values (one entry per bit_len samples)."""
    out = []
    i, n = 0, len(bits)
    while i < n:
        if bits[i] != 0:                       # idle / stop
            i += 1
            continue
        # start bit at i; sample the middle of each bit
        ok = True
        byte = 0
        for b in range(8):
            j = i + (b + 1) * bit_len + bit_len // 2
            if j >= n:
                ok = False
                break
            byte |= bits[j] << b
        stop = i + 9 * bit_len + bit_len // 2
        if not ok or stop >= n or bits[stop] != 1:
            i += 1                              # framing error: resync
            continue
        out.append(byte)
        i += 10 * bit_len                       # start + 8 + first stop
    return bytes(out)


def l3b(text):
    bits = [1 if c == '1' else 0 for c in text if c in '01']
    return frames(bits)


def l3c(text):
    s = [c for c in text if c in '01']
    # half-cycle run lengths -> tone per sample: 1 = 2400 Hz, 0 = 1200 Hz
    tone = []
    i = 0
    while i < len(s):
        j = i
        while j < len(s) and s[j] == s[i]:
            j += 1
        run = j - i
        t = 1 if run <= 1 else 0
        tone.extend([t] * run)
        i = j
    # decode byte by byte, choosing 8 (600 baud) or 4 (1200 baud) samples per
    # bit by which gives valid stop bits; prefer the rate of the last byte
    out = bytearray()
    i, n = 0, len(tone)
    bl = 8
    while i < n:
        if tone[i] != 0:
            i += 1
            continue
        got = None
        for cand in ((bl, 12 - bl) if bl in (4, 8) else (8, 4)):
            byte = 0
            ok = True
            for b in range(8):
                j = i + (b + 1) * cand + cand // 2
                if j >= n:
                    ok = False
                    break
                byte |= tone[j] << b
            s1 = i + 9 * cand + cand // 2
            s2 = i + 10 * cand + cand // 2
            if ok and s2 < n and tone[s1] == 1 and tone[s2] == 1 \
               and tone[i + cand // 2] == 0:
                got = (byte, cand)
                break
        if got is None:
            i += 1
            continue
        out.append(got[0])
        bl = got[1]
        i += 10 * bl
    return bytes(out)


def main():
    if len(sys.argv) != 3:
        sys.exit(__doc__)
    src, dst = sys.argv[1], sys.argv[2]
    text = open(src, 'r', encoding='latin1').read()
    data = l3c(text) if src.lower().endswith('.l3c') else l3b(text)
    open(dst, 'wb').write(data)
    print('%s: %d bytes' % (dst, len(data)))


if __name__ == '__main__':
    main()
