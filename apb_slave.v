module apb_slave(
  input PCLK,
  input PRESETn,
  input [31:0] PADDR,
  input PWRITE,
  input PSELx,
  input PENABLE,
  input in_wait,
  input [3:0]  PSTRB,
  input [31:0] PWDATA,       
  output reg [31:0] PRDATA,  
  output reg PREADY
);

  reg [2:0]  state;
  reg [31:0] mem [31:0];
  
  parameter IDLE=3'b000;
  parameter WRITE=3'b001;
  parameter READ=3'b010;

  always @(posedge PCLK or negedge PRESETn) begin
    if (!PRESETn) begin
      state  <= 3'b000;
      PRDATA <= 32'd0;
      PREADY <= 1'b0;
    end
    else begin
      case (state)

        3'b000: begin
          PREADY <= 1'b0;           // deassert ready in idle
          if (PSELx) begin           
            if (PWRITE)
              state <= 3'b001;      // go to write
            else
              state <= 3'b010;      // go to read
          end
          else
            state <= 3'b000;
        end

        3'b001: begin               // write
          if ((!in_wait) && PENABLE) begin
            PREADY <= 1'b1;         
            state  <= 3'b000;
            if (PSTRB[0]) mem[PADDR][7:0]   <= PWDATA[7:0];
            if (PSTRB[1]) mem[PADDR][15:8]  <= PWDATA[15:8];
            if (PSTRB[2]) mem[PADDR][23:16] <= PWDATA[23:16];
            if (PSTRB[3]) mem[PADDR][31:24] <= PWDATA[31:24];
          end
          else begin
            PREADY <= 1'b0;
            state  <= 3'b001;       // wait
          end
        end

        3'b010: begin               // read
          if ((!in_wait) && PENABLE) begin
            PRDATA <= mem[PADDR];
            PREADY <= 1'b1;         
            state  <= 3'b000;
          end
          else begin
            PREADY <= 1'b0;
            state  <= 3'b010;       // wait
          end
        end

        default: state <= 3'b000;   

      endcase
    end
  end

endmodule
      
              
              
              
              
              
              
              
              
              
              
              
              
              
              
              
              
              
              
              
              
              
              
