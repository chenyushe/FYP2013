/* 
(C) OOMusou 2008 http://oomusou.cnblogs.com

Filename    : SWITCH_LUT8.v
Compiler    : Quartus II 7.2 SP1
Description : Demo how to use 8 bit 7 segment display
Release     : 04/16/2008 1.0
*/
module SEG7_LUT_8 (
  output [6:0]  oSEG0,
  output [6:0]  oSEG1,
  output [6:0]  oSEG2,
  output [6:0]  oSEG3,
  output [6:0]  oSEG4,
  output [6:0]  oSEG5,
  output [6:0]  oSEG6,
  output [6:0]  oSEG7,
  input  [31:0] iDIG,
  input         iWR,
  input         iCLK,
  input         iRESET_n
);

reg [31:0] dig;

always@(posedge iCLK or negedge iRESET_n) begin
  if (!iRESET_n)
    dig <= 0;
  else begin
    if (iWR)
      dig <= iDIG;
  end
end

SEG7_LUT u0 (
  .iDIG(dig[3:0]),
  .oSEG(oSEG0)
);

SEG7_LUT u1 (
  .iDIG(dig[7:4]),
  .oSEG(oSEG1)
);

SEG7_LUT u2 (
  .iDIG(dig[11:8]),
  .oSEG(oSEG2)
);

SEG7_LUT u3 (
  .iDIG(dig[15:12]),
  .oSEG(oSEG3)
);

SEG7_LUT u4 (
  .iDIG(dig[19:16]),
  .oSEG(oSEG4)
);

SEG7_LUT u5 (
  .iDIG(dig[23:20]),
  .oSEG(oSEG5)
);

SEG7_LUT u6 (
  .iDIG(dig[27:24]),
  .oSEG(oSEG6)
);

SEG7_LUT u7 (
  .iDIG(dig[31:28]),
  .oSEG(oSEG7)
);

endmodule