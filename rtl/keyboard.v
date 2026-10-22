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
// symbol, with SHIFT forced on or off for as long as it is held (US Shift+2
// = @, Shift+8 = *, ' = ', Shift+' = ", = = =, Shift+= = +, ...). Letters
// and digits stay positional, so as on the real machine unshifted letters are
// capitals.
//
// The ROM only notices a key through the 16.25 ms hardware scan plus its own
// polling, and only notices a release through the scanner's $FF report up to
// three scans later. So host events (including forced SHIFT changes) go
// through a small queue and are applied one at a time, each given time to be
// seen: 35 ms after SHIFT goes down, 45 ms after a key goes down and 70 ms
// after anything goes up (the same key again needs the $FF report first).
// An event arriving with the queue idle applies at once; the queue holds
// about 170 typed characters.
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

localparam [21:0] T_SDN = 22'd1128960;    // 35 ms
localparam [21:0] T_KDN = 22'd1451520;    // 45 ms
localparam [21:0] T_KUP = 22'd2257920;    // 70 ms
localparam [21:0] T_SUP = 22'd2257920;    // 70 ms

// queue entry: {is_shift, level, code[6:0]}. 512 entries in block RAM; a
// host event's (up to three) entries are staged and written one per clock,
// and the head is read through a register.
reg  [8:0] q[0:511];
reg  [8:0] q_wr, q_rd, q_wr_d;
// the pop side sees the write pointer a clock late, so q_head is never read
// on the same clock its entry is written (read-during-write gives old data)
wire [8:0] q_used = q_wr_d - q_rd;          // modulo 512
reg  [8:0] q_head;
reg [21:0] wait_t;
reg  [8:0] st[0:2];
reg  [1:0] st_n;

always @(posedge clk) begin
  q_head <= q[q_rd];
  q_wr_d <= reset ? 9'd0 : q_wr;
end
always @(posedge clk) if (st_n != 2'd0) q[q_wr] <= st[0];

reg [127:0] k;               // Level 3 keys as applied
reg         vshift;          // SHIFT as applied
reg         want_shift;      // SHIFT as it will be once the queue drains
reg         sym_held;        // a translated key is down
reg   [6:0] sym_code;

wire       is_shift = ~ext && (sc == 8'h12 || sc == 8'h59);
wire       use_sym  = symbolic && sym[9];
wire       sym_need = sym[8];                    // SHIFT the translation needs

always @(posedge clk) begin : kb
  reg [1:0] n;
  reg       ws;
  reg [8:0] e0, e1, e2;
  old_toggle <= ps2_key[10];
  if (reset) begin
    k <= 128'd0; vshift <= 1'b0; want_shift <= 1'b0;
    shift_l <= 1'b0; shift_r <= 1'b0;
    break_key <= 1'b0;
    q_wr <= 9'd0; q_rd <= 9'd0; wait_t <= 22'd0; st_n <= 2'd0;
    sym_held <= 1'b0;
  end else begin
    // ---- apply queued events, one per wait period. q_head lags q_rd by a
    // clock, so every pop waits at least two.
    if (wait_t != 22'd0) wait_t <= wait_t - 22'd1;
    else if (q_used != 9'd0) begin
      q_rd <= q_rd + 9'd1;
      wait_t <= 22'd2;
      if (q_head[8]) begin
        if (vshift != q_head[7]) begin
          vshift <= q_head[7];
          wait_t <= q_head[7] ? T_SDN : T_SUP;
        end
      end else if (k[q_head[6:0]] != q_head[7]) begin
        k[q_head[6:0]] <= q_head[7];
        wait_t <= q_head[7] ? T_KDN : T_KUP;
      end
    end

    // ---- drain the staging buffer into the queue
    if (st_n != 2'd0) begin
      q_wr <= q_wr + 9'd1;
      st[0] <= st[1]; st[1] <= st[2];
      st_n <= st_n - 2'd1;
    end

    // ---- turn a host event into up to three staged entries (host events
    // are milliseconds apart, so the stage is always empty by then)
    if (old_toggle != ps2_key[10] && q_used < 9'd500) begin
      n = 2'd0;
      ws = want_shift;
      e0 = 9'd0; e1 = 9'd0; e2 = 9'd0;
      if (is_shift) begin
        if (sc == 8'h12) shift_l <= pressed;
        else             shift_r <= pressed;
        if (~sym_held && ws != (pressed | (sc == 8'h12 ? shift_r : shift_l))) begin
          ws = pressed | (sc == 8'h12 ? shift_r : shift_l);
          e0 = {1'b1, ws, 7'd0}; n = 2'd1;
        end
      end else if (code == 8'h80 && ~use_sym) begin
        break_key <= pressed;
      end else if (pressed) begin
        if (use_sym) begin
          if (ws != sym_need) begin
            ws = sym_need;
            e0 = {1'b1, ws, 7'd0};
            e1 = {2'b01, sym[6:0]}; n = 2'd2;
          end else begin
            e0 = {2'b01, sym[6:0]}; n = 2'd1;
          end
          sym_held <= 1'b1;
          sym_code <= sym[6:0];
        end else if (~code[7] && code != 8'h07) begin
          e0 = {2'b01, code[6:0]}; n = 2'd1;
        end
      end else begin
        if (sym_held && ((sym_u[9] && sym_u[6:0] == sym_code) ||
                         (sym_s[9] && sym_s[6:0] == sym_code))) begin
          e0 = {2'b00, sym_code}; n = 2'd1;
          sym_held <= 1'b0;
          if (ws != host_shift) begin
            ws = host_shift;
            e1 = {1'b1, ws, 7'd0}; n = 2'd2;
          end
        end else if (~code[7] && code != 8'h07) begin
          e0 = {2'b00, code[6:0]}; n = 2'd1;
        end
      end
      if (n != 2'd0) begin
        st[0] <= e0; st[1] <= e1; st[2] <= e2;
        st_n <= n;
      end
      want_shift <= ws;
    end
  end
end

always @(*) begin
  keys = k;
  keys[7] = vshift;
end

endmodule
