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

A frame is start, 8 data bits, then bits 9 and 10. BASIC writes 8N2 (both 1);
custom loaders (Mario Bros Special's LOADER/M, ACIA control $58) use 8E1, where
bit 9 is the parity bit and only bit 10 is a stop bit. A frame whose bit 9 is 0
is accepted when bit 10 is 1 and bit 9 is the byte's even parity, so those
bytes are no longer dropped as framing errors (and 8N2 data decodes as before).

usage: l3conv.py in.l3b|in.l3c out.l3
"""
import sys


def even_par0(byte):
    """True if a 0 parity bit is correct for this byte under even parity."""
    return bin(byte).count('1') % 2 == 0


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
        s1 = i + 9 * bit_len + bit_len // 2
        s2 = i + 10 * bit_len + bit_len // 2
        if not ok or s2 >= n or not (bits[s1] == 1 or (bits[s2] == 1 and even_par0(byte))):
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
    # decode byte by byte at 8 (600 baud) or 4 (1200 baud) samples per bit.
    # A 600-baud frame is also a valid 1200-baud frame whose bit 0 is always 0
    # ($FF reads as $FE), so one frame can't tell the rates apart: pick the
    # rate that decodes more of the next few frames cleanly. On a tie, 600-baud
    # data read at 1200 shows doubled bits (bit 0 = 0, 1 = 2, 3 = 4, 5 = 6) in
    # every frame; real 1200-baud data almost never does.
    n = len(tone)

    def frame(i, c):
        if i + 10 * c + c // 2 >= n or tone[i + c // 2] != 0:
            return None
        byte = 0
        for b in range(8):
            byte |= tone[i + (b + 1) * c + c // 2] << b
        s1, s2 = tone[i + 9 * c + c // 2], tone[i + 10 * c + c // 2]
        if s2 == 1 and (s1 == 1 or even_par0(byte)):
            return byte
        return None

    def next_start(i, c):
        j, lim = i + 10 * c, min(n, i + 40 * c)
        while j < lim and tone[j] != 0:
            j += 1
        return j if j < lim else None

    def score(i, c, look=6):
        k, doubled = 0, True
        while k < look and i is not None:
            byte = frame(i, c)
            if byte is None:
                break
            b = [(byte >> x) & 1 for x in range(8)]
            doubled &= b[0] == 0 and b[1] == b[2] and b[3] == b[4] and b[5] == b[6]
            k += 1
            i = next_start(i, c)
        return k, doubled

    out = bytearray()
    i = 0
    while i < n:
        if tone[i] != 0:
            i += 1
            continue
        (s8, _), (s4, doubled) = score(i, 8), score(i, 4)
        c = 8 if s8 > s4 or (s8 == s4 and doubled) else 4
        byte = frame(i, c)
        if byte is None:
            i += 1
            continue
        out.append(byte)
        i += 10 * c
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
