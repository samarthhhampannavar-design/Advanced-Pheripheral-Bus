module top (
  input PCLK,
  input PRESETn,
  input start,
  input in_mul_transfer,
  input stop,
  input [31:0] ADDR,
  input PSELx,
  input [31:0] PWDATA,
  input PWRITE,
  input [3:0] PSTRB,
  input in_wait
);

  wire [31:0] sl_PWDATA;
  wire [31:0] sl_PADDR;
  wire        sl_PSELx;
  wire        sl_PENABLE;
  wire        sl_PWRITE;
  wire [3:0]  sl_PSTRB;
  wire        dr_PREADY;
  wire [31:0] dr_PRDATA;

  apb_driver uut (
    .PCLK          (PCLK),
    .PRESETn       (PRESETn),
    .start         (start),
    .in_mul_transfer(in_mul_transfer),
    .stop          (stop),
    .PADDR_dr      (ADDR),
    .PSELx_dr      (PSELx),
    .PWDATA_dr     (PWDATA),
    .PWRITE_dr     (PWRITE),
    .PSTRB_dr      (PSTRB),
    .PREADY        (dr_PREADY),
    .PRDATA        (dr_PRDATA),
    .PWDATA        (sl_PWDATA),
    .PADDR         (sl_PADDR),
    .PSELx         (sl_PSELx),
    .PENABLE       (sl_PENABLE),
    .PWRITE        (sl_PWRITE),
    .PSTRB         (sl_PSTRB)
  );

  apb_slave dut (
    .PCLK    (PCLK),
    .PRESETn (PRESETn),
    .PADDR   (sl_PADDR),
    .PWRITE  (sl_PWRITE),
    .PSEL    (sl_PSELx),
    .PENABLE (sl_PENABLE),
    .PSTRB   (sl_PSTRB),
    .PWDATA  (sl_PWDATA),
    .in_wait (in_wait),
    .PRDATA  (dr_PRDATA),
    .PREADY  (dr_PREADY)
  );

endmodule
