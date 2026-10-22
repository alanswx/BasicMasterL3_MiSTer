// 6-voice PSG card: a 6821 PIA at $FF30-$FF33 driving two AY-3-8910s at
// 1.008 MHz (EmuB psgc.cpp, bml3mk5.cpp).
//   PIA port A  = PSG data bus (read back through the PIA input pins)
//   PIA port B  b1:b0 = BDIR:BC1 (01 read, 10 write, 11 latch address)
//               b2    = which PSG (0 or 1)
// The PIA's interrupt and control lines are not used by the card.
module psg6 (
  input             clk,
  input             reset,
  input             ce_psg,       // 1.008 MHz

  input             cs,           // $FF30-$FF33
  input       [1:0] a,
  input             we,
  input       [7:0] din,
  output reg  [7:0] dout,

  input       [7:0] joy_a,        // PSG 0 port A (joystick), active low
  output     [10:0] sound
);

reg [7:0] ora, ddra, cra, orb, ddrb, crb;
wire [7:0] pb = (orb & ddrb) | ~ddrb;
wire [7:0] pa_out = (ora & ddra) | ~ddra;

always @(posedge clk) begin
  if (reset) begin
    ora <= 8'h00; ddra <= 8'h00; cra <= 8'h00;
    orb <= 8'h00; ddrb <= 8'h00; crb <= 8'h00;
  end else if (cs & we) begin
    case (a)
      2'd0: if (cra[2]) ora <= din; else ddra <= din;
      2'd1: cra <= {2'b00, din[5:0]};
      2'd2: if (crb[2]) orb <= din; else ddrb <= din;
      2'd3: crb <= {2'b00, din[5:0]};
    endcase
  end
end

wire       sel  = pb[2];
wire       bdir = pb[1];
wire       bc1  = pb[0];
wire [7:0] psg_dout0, psg_dout1;
wire [9:0] snd0, snd1;

// a PSG read drives the PIA's port A pins
wire [7:0] pa_in = (bc1 & ~bdir) ? (sel ? psg_dout1 : psg_dout0) : pa_out;

always @(*) begin
  case (a)
    2'd0: dout = cra[2] ? ((pa_in & ~ddra) | (ora & ddra)) : ddra;
    2'd1: dout = cra;
    2'd2: dout = crb[2] ? ((pb & ~ddrb) | (orb & ddrb)) : ddrb;
    2'd3: dout = crb;
  endcase
end

jt49_bus psg0 (
  .rst_n(~reset), .clk(clk), .clk_en(ce_psg),
  .bdir(bdir & ~sel), .bc1(bc1 & ~sel), .din(pa_out), .sel(1'b1),
  .dout(psg_dout0), .sound(snd0), .A(), .B(), .C(), .sample(),
  .IOA_in(joy_a), .IOA_out(), .IOA_oe(),
  .IOB_in(8'hff), .IOB_out(), .IOB_oe()
);

jt49_bus psg1 (
  .rst_n(~reset), .clk(clk), .clk_en(ce_psg),
  .bdir(bdir & sel), .bc1(bc1 & sel), .din(pa_out), .sel(1'b1),
  .dout(psg_dout1), .sound(snd1), .A(), .B(), .C(), .sample(),
  .IOA_in(8'hff), .IOA_out(), .IOA_oe(),
  .IOB_in(8'hff), .IOB_out(), .IOB_oe()
);

assign sound = {1'b0, snd0} + {1'b0, snd1};

endmodule
