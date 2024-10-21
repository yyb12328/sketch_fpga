module Matrix_7X7
#(
    parameter   IMG_HDISP   = 640       ,            //  640*480
    parameter   IMG_VDISP   = 480       ,
    parameter   DATA_WIDTH  = 8         ,
    parameter   DELAY_NUM   = 2105              //  Interval period from the penultimate row to the last row
)
(
    //  global clock & reset
    input  wire                         clk                     ,
    input  wire                         rst_n                   ,
    
    //  Image data prepared to be processed
    input  wire                         per_img_vsync           ,   //  Prepared Image data vsync valid signal
    input  wire                         per_img_href            ,   //  Prepared Image data href vaild  signal
    input  wire     [DATA_WIDTH-1:0]    per_img_gray            ,   //  Prepared Image brightness input
    
    //  Image data has been processed
    output wire                         matrix_img_vsync        ,   //  processed Image data vsync valid signal
    output wire                         matrix_img_href         ,   //  processed Image data href vaild  signal
    output wire                         matrix_top_edge_flag    ,   //  processed Image top edge
    output wire                         matrix_bottom_edge_flag ,   //  processed Image bottom edge
    output wire                         matrix_left_edge_flag   ,   //  processed Image left edge
    output wire                         matrix_right_edge_flag  ,   //  processed Image right edge
    output reg      [DATA_WIDTH-1:0]    matrix_p11              ,   //  7X7 Matrix output
    output reg      [DATA_WIDTH-1:0]    matrix_p12              ,
    output reg      [DATA_WIDTH-1:0]    matrix_p13              ,
    output reg      [DATA_WIDTH-1:0]    matrix_p14              ,
    output reg      [DATA_WIDTH-1:0]    matrix_p15              ,
    output reg      [DATA_WIDTH-1:0]    matrix_p16              ,
    output reg      [DATA_WIDTH-1:0]    matrix_p17              ,
    output reg      [DATA_WIDTH-1:0]    matrix_p21              ,   
    output reg      [DATA_WIDTH-1:0]    matrix_p22              ,
    output reg      [DATA_WIDTH-1:0]    matrix_p23              ,
    output reg      [DATA_WIDTH-1:0]    matrix_p24              ,
    output reg      [DATA_WIDTH-1:0]    matrix_p25              ,
    output reg      [DATA_WIDTH-1:0]    matrix_p26              ,
    output reg      [DATA_WIDTH-1:0]    matrix_p27              ,
    output reg      [DATA_WIDTH-1:0]    matrix_p31              ,   
    output reg      [DATA_WIDTH-1:0]    matrix_p32              ,
    output reg      [DATA_WIDTH-1:0]    matrix_p33              ,
    output reg      [DATA_WIDTH-1:0]    matrix_p34              ,
    output reg      [DATA_WIDTH-1:0]    matrix_p35              ,
    output reg      [DATA_WIDTH-1:0]    matrix_p36              ,
    output reg      [DATA_WIDTH-1:0]    matrix_p37              ,
    output reg      [DATA_WIDTH-1:0]    matrix_p41              ,   
    output reg      [DATA_WIDTH-1:0]    matrix_p42              ,
    output reg      [DATA_WIDTH-1:0]    matrix_p43              ,
    output reg      [DATA_WIDTH-1:0]    matrix_p44              ,
    output reg      [DATA_WIDTH-1:0]    matrix_p45              ,
    output reg      [DATA_WIDTH-1:0]    matrix_p46              ,
    output reg      [DATA_WIDTH-1:0]    matrix_p47              ,  
    output reg      [DATA_WIDTH-1:0]    matrix_p51              ,   
    output reg      [DATA_WIDTH-1:0]    matrix_p52              ,
    output reg      [DATA_WIDTH-1:0]    matrix_p53              ,
    output reg      [DATA_WIDTH-1:0]    matrix_p54              ,
    output reg      [DATA_WIDTH-1:0]    matrix_p55              ,
    output reg      [DATA_WIDTH-1:0]    matrix_p56              ,
    output reg      [DATA_WIDTH-1:0]    matrix_p57              ,
    output reg      [DATA_WIDTH-1:0]    matrix_p61              ,   
    output reg      [DATA_WIDTH-1:0]    matrix_p62              ,
    output reg      [DATA_WIDTH-1:0]    matrix_p63              ,
    output reg      [DATA_WIDTH-1:0]    matrix_p64              ,
    output reg      [DATA_WIDTH-1:0]    matrix_p65              ,
    output reg      [DATA_WIDTH-1:0]    matrix_p66              ,
    output reg      [DATA_WIDTH-1:0]    matrix_p67              ,
    output reg      [DATA_WIDTH-1:0]    matrix_p71              ,   
    output reg      [DATA_WIDTH-1:0]    matrix_p72              ,
    output reg      [DATA_WIDTH-1:0]    matrix_p73              ,
    output reg      [DATA_WIDTH-1:0]    matrix_p74              ,
    output reg      [DATA_WIDTH-1:0]    matrix_p75              ,
    output reg      [DATA_WIDTH-1:0]    matrix_p76              ,
    output reg      [DATA_WIDTH-1:0]    matrix_p77              
    
);

//----------------------------------------------------------------------
//  href & vsync counter
reg             [15:0]          hcnt;

always @(posedge clk or negedge rst_n)
begin
    if(!rst_n)
        hcnt <= 16'b0;
    else
    begin
        if(per_img_href == 1'b1 && hcnt == IMG_HDISP - 1)
            hcnt <= 16'b0;
        else    if(per_img_href == 1'b1)
            hcnt <= hcnt + 1'b1;
        else
            hcnt <= 16'b0;
    end
end

/* reg                             per_img_href_dly;

always @(posedge clk or negedge rst_n)
begin
    if(!rst_n)
        per_img_href_dly <= 1'b0;
    else
        per_img_href_dly <= per_img_href;
end

wire img_href_neg = ~per_img_href & per_img_href_dly;       //  falling edge of per_img_href */

reg             [15:0]          vcnt;

always @(posedge clk or negedge rst_n)
begin
    if(!rst_n)
        vcnt <= 16'b0;
    else
    begin
        if(per_img_vsync == 1'b0)
            vcnt <= 16'b0;
        else    if(per_img_href == 1'b1 && hcnt == IMG_HDISP - 1 && vcnt == IMG_VDISP - 1)
            vcnt <= 16'b0;
        else if(per_img_href == 1'b1 && hcnt == IMG_HDISP - 1)
            vcnt <= vcnt + 1'b1;
        else
            vcnt <= vcnt;
    end
end

//----------------------------------------------------------------------        
reg     [15:0]  extend_last_all_row_cnt;        //3行

always @(posedge clk or negedge rst_n)
    if(!rst_n)
        extend_last_all_row_cnt <=  0;
    else    if((per_img_href == 1'b1)&&(vcnt == IMG_VDISP - 1)&&(hcnt == IMG_HDISP - 1))
        extend_last_all_row_cnt <=  1;
    else    if((extend_last_all_row_cnt > 0)&&(extend_last_all_row_cnt < ({DELAY_NUM,1'b0}+DELAY_NUM) + ({IMG_HDISP,1'b0}+IMG_HDISP)))
        extend_last_all_row_cnt <=  extend_last_all_row_cnt + 1'b1;
    else
        extend_last_all_row_cnt <=  0;

wire extend_3_last_row_en = (extend_last_all_row_cnt > DELAY_NUM)
                           &(extend_last_all_row_cnt <= DELAY_NUM + IMG_HDISP) ? 1'b1 : 1'b0;
                           
wire extend_2_last_row_en = (extend_last_all_row_cnt > {DELAY_NUM,1'b0} + IMG_HDISP)
                           &(extend_last_all_row_cnt <= {DELAY_NUM,1'b0} + {IMG_HDISP,1'b0}) ? 1'b1 : 1'b0;                         

wire extend_1_last_row_en = (extend_last_all_row_cnt > {DELAY_NUM,1'b0} + DELAY_NUM + {IMG_HDISP,1'b0})
                           &(extend_last_all_row_cnt <= {DELAY_NUM,1'b0} + DELAY_NUM + {IMG_HDISP,1'b0} + IMG_HDISP) ? 1'b1 : 1'b0;

wire                                fifo1_wenb;
wire            [DATA_WIDTH-1:0]    fifo1_wdata;
wire                                fifo1_renb;
wire            [DATA_WIDTH-1:0]    fifo1_rdata;

wire                                fifo2_wenb;
wire            [DATA_WIDTH-1:0]    fifo2_wdata;
wire                                fifo2_renb;
wire            [DATA_WIDTH-1:0]    fifo2_rdata;

wire                                fifo3_wenb;
wire            [DATA_WIDTH-1:0]    fifo3_wdata;
wire                                fifo3_renb;
wire            [DATA_WIDTH-1:0]    fifo3_rdata;

wire                                fifo4_wenb;
wire            [DATA_WIDTH-1:0]    fifo4_wdata;
wire                                fifo4_renb;
wire            [DATA_WIDTH-1:0]    fifo4_rdata;    

wire                                fifo5_wenb;
wire            [DATA_WIDTH-1:0]    fifo5_wdata;
wire                                fifo5_renb;
wire            [DATA_WIDTH-1:0]    fifo5_rdata;

wire                                fifo6_wenb;
wire            [DATA_WIDTH-1:0]    fifo6_wdata;
wire                                fifo6_renb;
wire            [DATA_WIDTH-1:0]    fifo6_rdata;

assign fifo1_wenb  = per_img_href;
assign fifo1_wdata = per_img_gray;
assign fifo1_renb  = per_img_href & (vcnt > 16'd0) | extend_3_last_row_en;

assign fifo2_wenb  = per_img_href & (vcnt > 16'd0) | extend_3_last_row_en;
assign fifo2_wdata = fifo1_rdata;
assign fifo2_renb  = per_img_href & (vcnt > 16'd1) | extend_3_last_row_en | extend_2_last_row_en;

assign fifo3_wenb  = per_img_href & (vcnt > 16'd1) | extend_3_last_row_en | extend_2_last_row_en;
assign fifo3_wdata = fifo2_rdata;
assign fifo3_renb  = per_img_href & (vcnt > 16'd2) | extend_3_last_row_en | extend_2_last_row_en | extend_1_last_row_en;

assign fifo4_wenb  = per_img_href & (vcnt > 16'd2) | extend_3_last_row_en | extend_2_last_row_en;
assign fifo4_wdata = fifo3_rdata;
assign fifo4_renb  = per_img_href & (vcnt > 16'd3) | extend_3_last_row_en | extend_2_last_row_en | extend_1_last_row_en;

assign fifo5_wenb  = per_img_href & (vcnt > 16'd3) | extend_3_last_row_en | extend_2_last_row_en;
assign fifo5_wdata = fifo4_rdata;
assign fifo5_renb  = per_img_href & (vcnt > 16'd4) | extend_3_last_row_en | extend_2_last_row_en | extend_1_last_row_en;

assign fifo6_wenb  = per_img_href & (vcnt > 16'd4) | extend_3_last_row_en | extend_2_last_row_en;
assign fifo6_wdata = fifo5_rdata;
assign fifo6_renb  = per_img_href & (vcnt > 16'd5) | extend_3_last_row_en | extend_2_last_row_en | extend_1_last_row_en;

fifo_w8xd2048 u1 (
  .rst      (~rst_n),           // input wire rst
  .wr_clk   (clk),              // input wire wr_clk
  .rd_clk   (clk),              // input wire rd_clk
  .din      (fifo1_wdata),      // input wire [7 : 0] din
  .wr_en    (fifo1_wenb),       // input wire wr_en
  .rd_en    (fifo1_renb),       // input wire rd_en
  .dout     (fifo1_rdata),      // output wire [7 : 0] dout
  .full     (),                 // output wire full
  .empty    ()                  // output wire empty
);

fifo_w8xd2048 u2 (
  .rst      (~rst_n),           // input wire rst
  .wr_clk   (clk),              // input wire wr_clk
  .rd_clk   (clk),              // input wire rd_clk
  .din      (fifo2_wdata),      // input wire [7 : 0] din
  .wr_en    (fifo2_wenb),       // input wire wr_en
  .rd_en    (fifo2_renb),       // input wire rd_en
  .dout     (fifo2_rdata),      // output wire [7 : 0] dout
  .full     (),                 // output wire full
  .empty    ()                  // output wire empty
);

fifo_w8xd2048 u3 (
  .rst      (~rst_n),           // input wire rst
  .wr_clk   (clk),              // input wire wr_clk
  .rd_clk   (clk),              // input wire rd_clk
  .din      (fifo3_wdata),      // input wire [7 : 0] din
  .wr_en    (fifo3_wenb),       // input wire wr_en
  .rd_en    (fifo3_renb),       // input wire rd_en
  .dout     (fifo3_rdata),      // output wire [7 : 0] dout
  .full     (),                 // output wire full
  .empty    ()                  // output wire empty
);

fifo_w8xd2048 u4 (
  .rst      (~rst_n),           // input wire rst
  .wr_clk   (clk),              // input wire wr_clk
  .rd_clk   (clk),              // input wire rd_clk
  .din      (fifo4_wdata),      // input wire [7 : 0] din
  .wr_en    (fifo4_wenb),       // input wire wr_en
  .rd_en    (fifo4_renb),       // input wire rd_en
  .dout     (fifo4_rdata),      // output wire [7 : 0] dout
  .full     (),                 // output wire full
  .empty    ()                  // output wire empty
);

fifo_w8xd2048 u5 (
  .rst      (~rst_n),           // input wire rst
  .wr_clk   (clk),              // input wire wr_clk
  .rd_clk   (clk),              // input wire rd_clk
  .din      (fifo5_wdata),      // input wire [7 : 0] din
  .wr_en    (fifo5_wenb),       // input wire wr_en
  .rd_en    (fifo5_renb),       // input wire rd_en
  .dout     (fifo5_rdata),      // output wire [7 : 0] dout
  .full     (),                 // output wire full
  .empty    ()                  // output wire empty
);

fifo_w8xd2048 u6 (
  .rst      (~rst_n),           // input wire rst
  .wr_clk   (clk),              // input wire wr_clk
  .rd_clk   (clk),              // input wire rd_clk
  .din      (fifo6_wdata),      // input wire [7 : 0] din
  .wr_en    (fifo6_wenb),       // input wire wr_en
  .rd_en    (fifo6_renb),       // input wire rd_en
  .dout     (fifo6_rdata),      // output wire [7 : 0] dout
  .full     (),                 // output wire full
  .empty    ()                  // output wire empty
);

always @(posedge clk or negedge rst_n) 
    if(!rst_n)begin
        {matrix_p11, matrix_p12, matrix_p13, matrix_p14, matrix_p15, matrix_p16, matrix_p17} <= 0;
        {matrix_p21, matrix_p22, matrix_p23, matrix_p24, matrix_p25, matrix_p26, matrix_p27} <= 0;
        {matrix_p31, matrix_p32, matrix_p33, matrix_p34, matrix_p35, matrix_p36, matrix_p37} <= 0;
        {matrix_p41, matrix_p42, matrix_p43, matrix_p44, matrix_p45, matrix_p46, matrix_p47} <= 0;
        {matrix_p51, matrix_p52, matrix_p53, matrix_p54, matrix_p55, matrix_p56, matrix_p57} <= 0;
        {matrix_p61, matrix_p62, matrix_p63, matrix_p64, matrix_p65, matrix_p66, matrix_p67} <= 0;
        {matrix_p71, matrix_p72, matrix_p73, matrix_p74, matrix_p75, matrix_p76, matrix_p77} <= 0;
    end
    else    begin
        {matrix_p11, matrix_p12, matrix_p13, matrix_p14, matrix_p15, matrix_p16, matrix_p17} <= {matrix_p12, matrix_p13, matrix_p14, matrix_p15, matrix_p16, matrix_p17, fifo6_rdata};
        {matrix_p21, matrix_p22, matrix_p23, matrix_p24, matrix_p25, matrix_p26, matrix_p27} <= {matrix_p22, matrix_p23, matrix_p24, matrix_p25, matrix_p26, matrix_p27, fifo5_rdata};
        {matrix_p31, matrix_p32, matrix_p33, matrix_p34, matrix_p35, matrix_p36, matrix_p37} <= {matrix_p32, matrix_p33, matrix_p34, matrix_p35, matrix_p36, matrix_p37, fifo4_rdata};
        {matrix_p41, matrix_p42, matrix_p43, matrix_p44, matrix_p45, matrix_p46, matrix_p47} <= {matrix_p42, matrix_p43, matrix_p44, matrix_p45, matrix_p46, matrix_p47, fifo3_rdata};
        {matrix_p51, matrix_p52, matrix_p53, matrix_p54, matrix_p55, matrix_p56, matrix_p57} <= {matrix_p52, matrix_p53, matrix_p54, matrix_p55, matrix_p56, matrix_p57, fifo2_rdata};
        {matrix_p61, matrix_p62, matrix_p63, matrix_p64, matrix_p65, matrix_p66, matrix_p67} <= {matrix_p62, matrix_p63, matrix_p64, matrix_p65, matrix_p66, matrix_p67, fifo1_rdata};
        {matrix_p71, matrix_p72, matrix_p73, matrix_p74, matrix_p75, matrix_p76, matrix_p77} <= {matrix_p72, matrix_p73, matrix_p74, matrix_p75, matrix_p76, matrix_p77, per_img_gray};
    end

reg                             extend_1_last_row_en_dly;

always @(posedge clk or negedge rst_n)
begin
    if(!rst_n)
        extend_1_last_row_en_dly <= 1'b0;
    else
        extend_1_last_row_en_dly <= extend_1_last_row_en;
end



reg             [3:0]           vsync               ;
reg             [4:0]           vsync_ext           ;
reg             [3:0]           hsync               ;
reg             [3:0]           href                ;
reg             [3:0]           top_edge_flag       ;
reg             [3:0]           bottom_edge_flag    ;
reg             [3:0]           left_edge_flag      ;
reg             [3:0]           right_edge_flag     ;

wire                            vsync_ext1;


always @(posedge clk or negedge rst_n)
begin
    if(!rst_n)
        vsync <= 4'b0;
    else
    begin
        if((per_img_href == 1'b1)&&(vcnt == 16'd3)&&(hcnt == 16'b0))
            vsync[0] <= 1'b1;
        else if((extend_1_last_row_en == 1'b0)&&(extend_1_last_row_en_dly == 1'b1))
            vsync[0] <= 1'b0;
        else
            vsync[0] <= vsync[0];
        vsync[3:1] <= vsync[2:0];
    end
end

//vs信号展宽
always @(posedge clk)   vsync_ext   <=  {vsync_ext[3:0],vsync[3]};
assign  vsync_ext1 = (|vsync_ext)|vsync[3];


always @(posedge clk or negedge rst_n)
    if(!rst_n)begin
        href                    <=  0;
        top_edge_flag           <=  0;
        bottom_edge_flag        <=  0;
        left_edge_flag          <=  0;
        right_edge_flag         <=  0;
    end
    else    begin
        href[0]                 <=  per_img_href & (vcnt > 2) | extend_3_last_row_en | extend_2_last_row_en | extend_1_last_row_en;
        href[3:1]               <=  href[2:0];
        top_edge_flag[0]        <=  per_img_href & ((vcnt == 3) | (vcnt == 4) | (vcnt == 5));
        top_edge_flag[3:1]      <=  top_edge_flag[2:0];
        bottom_edge_flag[0]     <=  extend_3_last_row_en | extend_2_last_row_en | extend_1_last_row_en;
        bottom_edge_flag[3:1]   <=  bottom_edge_flag[2:0];
        left_edge_flag[0]       <=  per_img_href & (vcnt > 2) & (hcnt <= 2) | (extend_last_all_row_cnt == DELAY_NUM + 1'b1) | (extend_last_all_row_cnt == DELAY_NUM + 3) 
                                    | (extend_last_all_row_cnt == {DELAY_NUM,1'b0} + IMG_HDISP + 1'b1) | (extend_last_all_row_cnt == {DELAY_NUM,1'b0} + IMG_HDISP + 3)
                                    | (extend_last_all_row_cnt == DELAY_NUM * 3 + {IMG_HDISP,1'b0} + 1'b1) | (extend_last_all_row_cnt == DELAY_NUM * 3 + {IMG_HDISP,1'b0} + 3);
        left_edge_flag[3:1]     <=  left_edge_flag[2:0];
        right_edge_flag[0]      <=  per_img_href & (vcnt > 2) & (hcnt >= IMG_HDISP - 3) | (extend_last_all_row_cnt == DELAY_NUM + IMG_HDISP - 2) | (extend_last_all_row_cnt == DELAY_NUM + IMG_HDISP)
                                    | (extend_last_all_row_cnt == {DELAY_NUM,1'b0} + {IMG_HDISP,1'b0} - 2) | (extend_last_all_row_cnt == {DELAY_NUM,1'b0} + {IMG_HDISP,1'b0})
                                    | (extend_last_all_row_cnt == DELAY_NUM * 3 + IMG_HDISP * 3 - 2) | (extend_last_all_row_cnt == DELAY_NUM * 3 + IMG_HDISP * 3);
        right_edge_flag[3:1]    <=  right_edge_flag[2:0];
        
    end

assign matrix_img_vsync        = vsync_ext1||per_img_vsync; 
assign matrix_img_href         = href[3];
assign matrix_top_edge_flag    = top_edge_flag[3];
assign matrix_bottom_edge_flag = bottom_edge_flag[3];
assign matrix_left_edge_flag   = left_edge_flag[3];
assign matrix_right_edge_flag  = right_edge_flag[3];



endmodule