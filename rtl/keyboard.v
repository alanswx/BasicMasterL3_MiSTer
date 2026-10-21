// PS/2 (set 2, as delivered by hps_io) -> Level 3 key state.
//
// keys[n] is 1 while the key with Level 3 scan code n ($00-$5F) is held; the
// hardware scanner in core.v walks these codes. BREAK is not in the matrix
// ($FFC8 / NMI), so it is a separate output.
//
// Host key choices follow EmuB-6892's default keyboard_bind.h:
//   F7/CapsLock = CAPS, Tab = KANA, F8 = GRAPH, F9 = BREAK, End = "num ?",
//   Backspace = INS/DEL, Delete = keypad INS/DEL, Home = HOME/CLS,
//   '=' = ^, '`' = @, ''' = :, '\' = yen, F1-F5 = PF1-PF5.
//
// With `symbolic` set, punctuation follows the US legends instead: a US key
// combination that means a symbol presses the Level 3 key that makes that
// symbol, forcing SHIFT on or off for as long as it is held. The ROM only
// learns SHIFT's state when the scanner passes code $07, so the key itself is
// held back 20 ms (more than one 16.25 ms scan) after a forced SHIFT. Forcing
// SHIFT off needs 55 ms: the ROM only sees a release through the scanner's $FF
// report, up to three scans later. Once down the key stays down >= 55 ms: the
// ROM wants to see a key on more than one scan.
//
// The same lead applies to any key pressed right after the real SHIFT goes
// down or up, so a fast typist (or a typing tool) gets the case it meant. (US Shift+2 = @,
// Shift+8 = *, ' = ', Shift+' = ", = = =, Shift+= = +, and so on). Letters
// and digits stay positional, so as on the real machine unshifted letters
// are capitals.
module keyboard (
  input             clk,
  input             reset,
  input             symbolic,
  input      [10:0] ps2_key,
  output reg [127:0] keys,
  output reg        break_key
);

reg old_toggle;
wire       pressed = ps2_key[9];
wire       ext     = ps2_key[8];
wire [7:0] sc      = ps2_key[7:0];

reg  [7:0] code;      // $FF = unmapped
always @(*) begin
  code = 8'hFF;
  if (ext) begin
    case (sc)
      8'h75: code = 8'h01;   // up
      8'h69: code = 8'h02;   // End -> num ?
      8'h6B: code = 8'h03;   // left
      8'h72: code = 8'h04;   // down
      8'h74: code = 8'h05;   // right
      8'h14: code = 8'h06;   // right ctrl
      8'h71: code = 8'h18;   // Delete -> keypad INS/DEL
      8'h6C: code = 8'h2E;   // Home -> HOME/CLS
      8'h5A: code = 8'h2F;   // keypad enter -> RETURN
      8'h4A: code = 8'h45;   // keypad /
      default: ;
    endcase
  end else begin
    case (sc)
      8'h29: code = 8'h00;   // space
      8'h14: code = 8'h06;   // ctrl
      8'h12, 8'h59: code = 8'h07;   // shift
      8'h58, 8'h83: code = 8'h09;   // caps (CapsLock, F7)
      8'h0D: code = 8'h0A;   // Tab -> KANA
      8'h0A: code = 8'h0B;   // F8 -> GRAPH
      8'h76: code = 8'h0C;   // esc
      8'h75: code = 8'h0D;   // num 8
      8'h7D: code = 8'h0E;   // num 9
      8'h7C: code = 8'h0F;   // num *
      8'h3D: code = 8'h10;   // 7
      8'h25: code = 8'h11;   // 4
      8'h36: code = 8'h12;   // 6
      8'h3E: code = 8'h13;   // 8
      8'h45: code = 8'h14;   // 0
      8'h55: code = 8'h15;   // = -> ^
      8'h4E: code = 8'h16;   // -
      8'h26: code = 8'h17;   // 3
      8'h2E: code = 8'h19;   // 5
      8'h16: code = 8'h1A;   // 1
      8'h1E: code = 8'h1B;   // 2
      8'h46: code = 8'h1C;   // 9
      8'h6C: code = 8'h1D;   // num 7
      8'h66: code = 8'h1E;   // backspace -> INS/DEL
      8'h5D: code = 8'h1F;   // \ -> yen
      8'h3C: code = 8'h20;   // U
      8'h2D: code = 8'h21;   // R
      8'h35: code = 8'h22;   // Y
      8'h43: code = 8'h23;   // I
      8'h4D: code = 8'h24;   // P
      8'h54: code = 8'h25;   // [
      8'h0E: code = 8'h26;   // ` -> @
      8'h70: code = 8'h27;   // num 0
      8'h15: code = 8'h28;   // Q
      8'h2C: code = 8'h29;   // T
      8'h1D: code = 8'h2A;   // W
      8'h24: code = 8'h2B;   // E
      8'h44: code = 8'h2C;   // O
      8'h71: code = 8'h2D;   // num .
      8'h5A: code = 8'h2F;   // return
      8'h3B: code = 8'h30;   // J
      8'h2B: code = 8'h31;   // F
      8'h33: code = 8'h32;   // H
      8'h42: code = 8'h33;   // K
      8'h4C: code = 8'h34;   // ;
      8'h5B: code = 8'h35;   // ]
      8'h52: code = 8'h36;   // ' -> :
      8'h6B: code = 8'h37;   // num 4
      8'h1C: code = 8'h38;   // A
      8'h34: code = 8'h39;   // G
      8'h1B: code = 8'h3A;   // S
      8'h23: code = 8'h3B;   // D
      8'h4B: code = 8'h3C;   // L
      8'h73: code = 8'h3D;   // num 5
      8'h74: code = 8'h3E;   // num 6
      8'h7B: code = 8'h3F;   // num -
      8'h3A: code = 8'h40;   // M
      8'h2A: code = 8'h41;   // V
      8'h31: code = 8'h42;   // N
      8'h41: code = 8'h43;   // ,
      8'h4A: code = 8'h44;   // /
      8'h51: code = 8'h46;   // JP ro -> _
      8'h69: code = 8'h47;   // num 1
      8'h1A: code = 8'h48;   // Z
      8'h32: code = 8'h49;   // B
      8'h22: code = 8'h4A;   // X
      8'h21: code = 8'h4B;   // C
      8'h49: code = 8'h4C;   // .
      8'h72: code = 8'h4D;   // num 2
      8'h7A: code = 8'h4E;   // num 3
      8'h79: code = 8'h4F;   // num +
      8'h05: code = 8'h50;   // F1 -> PF1
      8'h06: code = 8'h51;   // F2
      8'h04: code = 8'h52;   // F3
      8'h0C: code = 8'h53;   // F4
      8'h03: code = 8'h54;   // F5
      8'h01: code = 8'h80;   // F9 -> BREAK
      default: ;
    endcase
  end
end

// US symbol translation: {valid, force shift on, force shift off, code}
reg        shift_l, shift_r;
wire       host_shift = shift_l | shift_r;
reg  [9:0] sym_u, sym_s;     // unshifted / shifted translation of this key
always @(*) begin
  sym_u = 10'd0;
  sym_s = 10'd0;
  if (~ext) begin
    case (sc)
      8'h55: sym_u = {3'b110, 7'h16};   // =  -> SHIFT+-
      8'h52: sym_u = {3'b110, 7'h10};   // '  -> SHIFT+7
      8'h0E: sym_u = {3'b101, 7'h26};   // `  -> @
      default: ;
    endcase
    case (sc)
      8'h1E: sym_s = {3'b101, 7'h26};   // @  -> @
      8'h36: sym_s = {3'b101, 7'h15};   // ^  -> ^
      8'h3D: sym_s = {3'b110, 7'h12};   // &  -> SHIFT+6
      8'h3E: sym_s = {3'b110, 7'h36};   // *  -> SHIFT+:
      8'h46: sym_s = {3'b110, 7'h13};   // (  -> SHIFT+8
      8'h45: sym_s = {3'b110, 7'h1C};   // )  -> SHIFT+9
      8'h4E: sym_s = {3'b101, 7'h46};   // _  -> _
      8'h55: sym_s = {3'b110, 7'h34};   // +  -> SHIFT+;
      8'h4C: sym_s = {3'b101, 7'h36};   // :  -> :
      8'h52: sym_s = {3'b110, 7'h1B};   // "  -> SHIFT+2
      8'h0E: sym_s = {3'b110, 7'h15};   // ~  -> SHIFT+^
      default: ;
    endcase
  end
end
wire [9:0] sym = host_shift ? sym_s : sym_u;

reg [127:0] k;                   // Level 3 keys down (SHIFT is computed below)
reg [127:0] force_on, force_off; // per translated key: SHIFT it needs
reg   [6:0] pend_code;           // last key that had to wait for SHIFT
reg  [20:0] pend_timer;          // 0 = landed (or nothing pending)
reg         pend_delayed;        // pend_code is a delayed key not yet released
reg   [6:0] rel_code;            // delayed key waiting out its minimum hold
reg  [20:0] rel_timer;
reg  [20:0] settle;              // time until the ROM has seen the last SHIFT change
localparam [20:0] T20MS = 21'd645120;
localparam [20:0] T55MS = 21'd1774080;

wire       is_shift = ~ext && (sc == 8'h12 || sc == 8'h59);
wire       use_sym  = symbolic && sym[9];
wire [6:0] pcode    = use_sym ? sym[6:0] : code[6:0];
wire       pvalid   = use_sym || (~code[7] && code != 8'h07);
wire [20:0] sym_lead = ~use_sym              ? 21'd0 :
                       (sym[7] &&  host_shift) ? T55MS :
                       (sym[8] && ~host_shift) ? T20MS : 21'd0;
// a key also waits for a delayed key's minimum hold to finish, plus time for
// the ROM to see it released if it is the same key again
wire [20:0] rel_wait = rel_timer == 21'd0 ? 21'd0 :
                       rel_timer + (rel_code == pcode ? T55MS : 21'd0);
wire [20:0] lead0 = settle > sym_lead ? settle : sym_lead;
wire [20:0] lead  = rel_wait > lead0 ? rel_wait : lead0;
wire mine = pend_delayed && ((code[6:0] == pend_code && ~code[7]) ||
                             (sym_u[9] && sym_u[6:0] == pend_code) ||
                             (sym_s[9] && sym_s[6:0] == pend_code));

always @(posedge clk) begin
  old_toggle <= ps2_key[10];
  if (reset) begin
    k <= 128'd0; force_on <= 128'd0; force_off <= 128'd0;
    shift_l <= 1'b0; shift_r <= 1'b0;
    break_key <= 1'b0;
    pend_timer <= 21'd0; pend_delayed <= 1'b0; rel_timer <= 21'd0; settle <= 21'd0;
  end else begin
    if (settle != 21'd0) settle <= settle - 21'd1;
    if (pend_timer == 21'd1) k[pend_code] <= 1'b1;
    if (pend_timer != 21'd0) pend_timer <= pend_timer - 21'd1;
    if (rel_timer == 21'd1) begin
      k[rel_code] <= 1'b0; force_on[rel_code] <= 1'b0; force_off[rel_code] <= 1'b0;
    end
    if (rel_timer != 21'd0) rel_timer <= rel_timer - 21'd1;

    if (old_toggle != ps2_key[10]) begin
      if (is_shift) begin
        if (sc == 8'h12) shift_l <= pressed;
        else             shift_r <= pressed;
        settle <= pressed ? T20MS : T55MS;
      end else if (code == 8'h80 && ~use_sym) begin
        break_key <= pressed;
      end else if (pressed) begin
        if (pvalid) begin
          // a still-pending key lands now (its release will follow)
          if (pend_timer != 21'd0) k[pend_code] <= 1'b1;
          if (use_sym) begin
            force_on[pcode] <= sym[8];
            force_off[pcode] <= sym[7];
          end
          if (lead == 21'd0) begin
            k[pcode] <= 1'b1;
            pend_timer <= 21'd0;
            pend_delayed <= 1'b0;
          end else begin
            pend_code <= pcode;
            pend_timer <= lead;
            pend_delayed <= 1'b1;
          end
        end
      end else begin
        if (mine) begin
          // a delayed key stays down >= 55 ms: the ROM wants more than one scan
          if (pend_timer != 21'd0) k[pend_code] <= 1'b1;
          pend_timer <= 21'd0;
          pend_delayed <= 1'b0;
          if (rel_timer != 21'd0 && rel_code != pend_code) begin
            k[rel_code] <= 1'b0; force_on[rel_code] <= 1'b0; force_off[rel_code] <= 1'b0;
          end
          rel_code <= pend_code;
          rel_timer <= T55MS;
        end else begin
          if (~code[7] && code != 8'h07) k[code[6:0]] <= 1'b0;
          if (sym_u[9]) begin
            k[sym_u[6:0]] <= 1'b0; force_on[sym_u[6:0]] <= 1'b0; force_off[sym_u[6:0]] <= 1'b0;
          end
          if (sym_s[9]) begin
            k[sym_s[6:0]] <= 1'b0; force_on[sym_s[6:0]] <= 1'b0; force_off[sym_s[6:0]] <= 1'b0;
          end
        end
      end
    end
  end
end

wire shift_out = (host_shift & ~|force_off) | |force_on;

always @(*) begin
  keys = k;
  keys[7] = shift_out;
end

endmodule
