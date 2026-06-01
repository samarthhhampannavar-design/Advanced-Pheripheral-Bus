
module apb_driver(
  input PCLK,
  input PRESETn,
  input start,
  input in_mul_transfer,
  input stop,
  //------------------
  input [31:0]PADDR_dr,
  input PSELx_dr,
  input [31:0]PWDATA_dr,
  input PWRITE_dr,
  input [3:0] PSTRB_dr,
  input PREADY,
  input [31:0] PRDATA, //slave interface 
  //-----------------
  output reg[31:0]PWDATA,
  output reg[31:0]PADDR,
  output reg PSELx,
  output reg PENABLE,
  output reg PWRITE,
  output reg [3:0] PSTRB
);
  
  reg [2:0] state;
  reg [31:0] mem;
  
  
 parameter IDLE=3'b000;
 parameter SETUP=3'b001;
 parameter ACCESS=3'b010;
 parameter WRITE=3'b011;
 parameter READ=3'b110;
  
  
  
  
  always @(posedge PCLK or negedge PRESETn)begin
    if(!PRESETn)begin
      PWDATA<=32'd0;
      PADDR<=32'd0;
      PSELx<=1'b0;
      PENABLE<=1'b0;
      PSTRB<=4'b0000;
      PWRITE<=1'b0;
      state<=3'b000; 
    end
    else begin
      case (state)
        3'b000:begin 
          PSTRB<=4'b0000;                                                            //IDLE
          if(start)
            state<=3'b001;
          else
            state<=3'b000;
        end
        3'b001:begin                                                         //SETUP Phase 
            PSELx<=PSELx_dr;
            PWDATA<=PWDATA_dr;
            PADDR<=PADDR_dr;
            PWRITE<=PWRITE_dr;
            PENABLE<=1'b0;
            PSTRB[0]<=PSTRB_dr[0];
            PSTRB[1]<=PSTRB_dr[1];
            PSTRB[2]<=PSTRB_dr[2];
            PSTRB[3]<=PSTRB_dr[3];
            state<=3'b010;
        end
        3'b010:begin
          PENABLE<=1'b1;                                             // ACCESS Phase
          state<=(PWRITE==1)?3'b011:3'b110;                         // write or read opreation
        end
        3'b011:begin                                             // write state
          if(PREADY)begin                                       // check if slave interface is ready to except the data 
            if(in_mul_transfer)begin                           // multiple transfer
              if(!stop)begin
              state<=3'b010;
              PSELx<=1'b1;
              PENABLE<=1'b0;
              PWDATA<=PWDATA_dr;
              PADDR<=PADDR_dr;
              PSTRB[0]<=PSTRB_dr[0];
              PSTRB[1]<=PSTRB_dr[1];
              PSTRB[2]<=PSTRB_dr[2];
              PSTRB[3]<=PSTRB_dr[3];
              end
                else begin
                   state   <= 3'b000;
                   PSELx   <= 1'b0;
                   PENABLE <= 1'b0;
                end
            end
            else begin
              state<=3'b000;                             //single transfer and stop 
              PSELx<=1'b0;
              PENABLE<=1'b0;
            end
          end
          else begin
            state<=3'b011;                        // slave pulled PREADY slow to for wait state
          end
        end
        3'b110:begin                                            // read phase
          if(PREADY && (!stop))begin
            mem<=PRDATA;
            state<=3'b001;
            PENABLE<=1'b0;
            PADDR<=PADDR_dr;
          end
          else if(PREADY==0 && (!stop)) begin
            state<=3'b110;                                         // wait
          end
          else if (PREADY && stop)begin
            state<=3'b000;
            PENABLE<=1'b0;
            PSELx<=1'b0;
          end
        end
        default :begin
          state<=3'b000;
        end
      endcase 
    end
  end
endmodule