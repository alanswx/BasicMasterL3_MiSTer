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
module keyboard (
  input             clk,
  input             reset,
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

always @(posedge clk) begin
  old_toggle <= ps2_key[10];
  if (reset) begin
    keys <= 128'd0;
    break_key <= 1'b0;
  end else if (old_toggle != ps2_key[10]) begin
    if (code == 8'h80)       break_key <= pressed;
    else if (~code[7])       keys[code[6:0]] <= pressed;
  end
end

endmodule
