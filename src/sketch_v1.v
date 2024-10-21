module sketch_v1 #(
	parameter IMG_HDISP = 1280,
	parameter IMG_VDISP = 720
) 
(
	input 			    clk			,
    input               rst_n       ,
    
    input               bypass      ,
	
	input               pre_vs		,
	input               pre_de		,
	input       [7:0] 	pre_data	,
	
	output reg          post_vs     ,
	output reg          post_de     ,
	output reg  [7:0]   post_data 
);//延迟3行加46clk

wire    [7:0]   neg_data;

wire            gd_vs   ;
wire            gd_de   ;
wire    [7:0]   gd_data ;

wire    [7:0]   neg_ori_data;
wire    [7:0]   ori_data;

wire    [15:0]  mult_255_ori_data;
wire    [7:0]   neg_gd_data;
wire    [7:0]   neg_gd_data_dly;
wire    [23:0]  dodgeimg_t;
wire    [15:0]  dodgeimg;

reg     [15:0]  neg_dodgeimg;
wire    [15:0]  mult_255_neg_dodgeimg;

wire    [23:0]  burn_img_t;
wire    [15:0]  burn_img;

wire     [7:0]  finally_img;

assign  neg_data = 8'd255 - pre_data;
assign  ori_data = 8'd255 - neg_ori_data;
assign  mult_255_ori_data = {ori_data,8'b0} - ori_data;
assign  neg_gd_data = 8'd255 - gd_data;
assign  dodgeimg = dodgeimg_t[23:8];
assign  mult_255_neg_dodgeimg = {neg_dodgeimg,8'b0} - neg_dodgeimg;
assign  burn_img = burn_img_t[23:8];
assign  finally_img = (burn_img > 'd255) ? 8'd0 : ('d255 - burn_img);

gauss_filter_7x7 #(
    .IMG_HDISP(IMG_HDISP),
    .IMG_VDISP(IMG_VDISP)
)gauss_filter_7x7 
(
    .clk		    (clk	),
    .rst_n          (rst_n  ),
                    
    .pre_vs		    (pre_vs	),
    .pre_de		    (pre_de	),
    .pre_data	    (neg_data),
                    
    .post_vs        (gd_vs  ),
    .post_de        (gd_de  ),
    .post_data      (gd_data),
                    
    .original_data  (neg_ori_data)
);//延迟3行加9拍

div_16_8 u0_div_16_8 (
  .aclk                     (clk                ),     // input wire aclk
  .s_axis_divisor_tvalid    (1'b1               ),     // input wire s_axis_divisor_tvalid
  .s_axis_divisor_tdata     (neg_gd_data        ),     // input wire [7 : 0] s_axis_divisor_tdata
  .s_axis_dividend_tvalid   (1'b1               ),     // input wire s_axis_dividend_tvalid
  .s_axis_dividend_tdata    (mult_255_ori_data  ),     // input wire [15 : 0] s_axis_dividend_tdata
  .m_axis_dout_tvalid       (                   ),     // output wire m_axis_dout_tvalid
  .m_axis_dout_tdata        (dodgeimg_t         )      // output wire [23 : 0] m_axis_dout_tdata
);//延迟18拍

data_delay
#(
    .DATA_WIDTH(8),
    .DATA_DELAY(19)
)data_delay
(
    .I_video_clk(clk        ),
    .I_rst_n    (rst_n      ),   
    .I_data     (neg_gd_data),
                
    .O_data     (neg_gd_data_dly)
);

always@(posedge clk or negedge rst_n)
    if(!rst_n)
        neg_dodgeimg    <=  0;
    else    if(dodgeimg > 'd255)
        neg_dodgeimg    <=  0;
    else
        neg_dodgeimg    <=  'd255 - dodgeimg;

div_16_8 u1_div_16_8 (
  .aclk                     (clk                    ),     // input wire aclk
  .s_axis_divisor_tvalid    (1'b1                   ),     // input wire s_axis_divisor_tvalid
  .s_axis_divisor_tdata     (neg_gd_data_dly        ),     // input wire [7 : 0] s_axis_divisor_tdata
  .s_axis_dividend_tvalid   (1'b1                   ),     // input wire s_axis_dividend_tvalid
  .s_axis_dividend_tdata    (mult_255_neg_dodgeimg  ),     // input wire [15 : 0] s_axis_dividend_tdata
  .m_axis_dout_tvalid       (                       ),     // output wire m_axis_dout_tvalid
  .m_axis_dout_tdata        (burn_img_t             )      // output wire [23 : 0] m_axis_dout_tdata
);//延迟18拍

//  lag 37 clocks signal sync
reg             [36:0]           gd_vs_r;	
reg             [36:0]           gd_de_r;	
wire            [7:0]            ori_data_r;

always @(posedge clk or negedge rst_n)
begin
    if(!rst_n)
    begin
        gd_vs_r <= 0;
        gd_de_r <= 0;
    end
    else
    begin
        gd_vs_r <= {gd_vs_r[35:0],gd_vs};
        gd_de_r <= {gd_de_r[35:0],gd_de};
    end
end

data_delay
#(
    .DATA_WIDTH(8),
    .DATA_DELAY(37)
)u1_data_delay
(
    .I_video_clk(clk        ),
    .I_rst_n    (rst_n      ),   
    .I_data     (ori_data   ),
                
    .O_data     (ori_data_r)
);

//----------------------------------------------------------------------
//  result output
always @(posedge clk or negedge rst_n)
begin
    if(!rst_n)
        post_data   <=  0;
    else    if(gd_de_r[36])
        post_data   <=  bypass ? ori_data_r : finally_img;
    else
        post_data   <=  0;
end

always @(posedge clk or negedge rst_n)
begin
    if(!rst_n)
    begin
        post_vs <= 0;
        post_de <= 0;
    end
    else
    begin
        post_vs <= gd_vs_r[36];
        post_de <= gd_de_r[36];
    end
end


endmodule
