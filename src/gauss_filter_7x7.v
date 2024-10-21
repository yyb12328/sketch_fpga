module gauss_filter_7x7 #(
	parameter IMG_HDISP = 1280,
	parameter IMG_VDISP = 720
) 
(
	input 			    clk			,
    input               rst_n       ,
	
	input               pre_vs		,
	input               pre_de		,
	input       [7:0] 	pre_data	,
	
	output reg          post_vs     ,
	output reg          post_de     ,
	output reg  [7:0]   post_data   ,
    
    output reg  [7:0]   original_data
);//延迟3行加9拍

wire            matrix_img_vsync        ;      
wire            matrix_img_href         ;
wire            matrix_top_edge_flag    ;
wire            matrix_bottom_edge_flag ;
wire            matrix_left_edge_flag   ;
wire            matrix_right_edge_flag  ;

wire    [7:0]   matrix_p11;
wire    [7:0]   matrix_p12;
wire    [7:0]   matrix_p13;
wire    [7:0]   matrix_p14;
wire    [7:0]   matrix_p15;
wire    [7:0]   matrix_p16;
wire    [7:0]   matrix_p17;
wire    [7:0]   matrix_p21;
wire    [7:0]   matrix_p22;
wire    [7:0]   matrix_p23;
wire    [7:0]   matrix_p24;
wire    [7:0]   matrix_p25;
wire    [7:0]   matrix_p26;
wire    [7:0]   matrix_p27;
wire    [7:0]   matrix_p31;
wire    [7:0]   matrix_p32;
wire    [7:0]   matrix_p33;
wire    [7:0]   matrix_p34;
wire    [7:0]   matrix_p35;
wire    [7:0]   matrix_p36;
wire    [7:0]   matrix_p37;
wire    [7:0]   matrix_p41;
wire    [7:0]   matrix_p42;
wire    [7:0]   matrix_p43;
wire    [7:0]   matrix_p44;
wire    [7:0]   matrix_p45;
wire    [7:0]   matrix_p46;
wire    [7:0]   matrix_p47;
wire    [7:0]   matrix_p51;
wire    [7:0]   matrix_p52;
wire    [7:0]   matrix_p53;
wire    [7:0]   matrix_p54;
wire    [7:0]   matrix_p55;
wire    [7:0]   matrix_p56;
wire    [7:0]   matrix_p57;
wire    [7:0]   matrix_p61;
wire    [7:0]   matrix_p62;
wire    [7:0]   matrix_p63;
wire    [7:0]   matrix_p64;
wire    [7:0]   matrix_p65;
wire    [7:0]   matrix_p66;
wire    [7:0]   matrix_p67;
wire    [7:0]   matrix_p71;
wire    [7:0]   matrix_p72;
wire    [7:0]   matrix_p73;
wire    [7:0]   matrix_p74;
wire    [7:0]   matrix_p75;
wire    [7:0]   matrix_p76;
wire    [7:0]   matrix_p77;

Matrix_7X7
#(
    .IMG_HDISP (IMG_HDISP),            //  640*480
    .IMG_VDISP (IMG_VDISP),
    .DATA_WIDTH(8        ),
    .DELAY_NUM (100      )        //  Interval period from the penultimate row to the last row
)Matrix_7X7
(
    //  global clock & reset
    .clk                     (clk	),
    .rst_n                   (rst_n ),
    
    //  Image data prepared to be processed
    .per_img_vsync           (pre_vs	),   //  Prepared Image data vsync valid signal
    .per_img_href            (pre_de	),   //  Prepared Image data href vaild  signal
    .per_img_gray            (pre_data  ),   //  Prepared Image brightness input
    
    //  Image data has been processed
    .matrix_img_vsync        (matrix_img_vsync       ),   //  processed Image data vsync valid signal
    .matrix_img_href         (matrix_img_href        ),   //  processed Image data href vaild  signal
    .matrix_top_edge_flag    (matrix_top_edge_flag   ),   //  processed Image top edge
    .matrix_bottom_edge_flag (matrix_bottom_edge_flag),   //  processed Image bottom edge
    .matrix_left_edge_flag   (matrix_left_edge_flag  ),   //  processed Image left edge
    .matrix_right_edge_flag  (matrix_right_edge_flag ),   //  processed Image right edge
    .matrix_p11              (matrix_p11),   //  7X7 Matrix output
    .matrix_p12              (matrix_p12),
    .matrix_p13              (matrix_p13),
    .matrix_p14              (matrix_p14),
    .matrix_p15              (matrix_p15),
    .matrix_p16              (matrix_p16),
    .matrix_p17              (matrix_p17),
    .matrix_p21              (matrix_p21),   
    .matrix_p22              (matrix_p22),
    .matrix_p23              (matrix_p23),
    .matrix_p24              (matrix_p24),
    .matrix_p25              (matrix_p25),
    .matrix_p26              (matrix_p26),
    .matrix_p27              (matrix_p27),
    .matrix_p31              (matrix_p31),   
    .matrix_p32              (matrix_p32),
    .matrix_p33              (matrix_p33),
    .matrix_p34              (matrix_p34),
    .matrix_p35              (matrix_p35),
    .matrix_p36              (matrix_p36),
    .matrix_p37              (matrix_p37),
    .matrix_p41              (matrix_p41),   
    .matrix_p42              (matrix_p42),
    .matrix_p43              (matrix_p43),
    .matrix_p44              (matrix_p44),
    .matrix_p45              (matrix_p45),
    .matrix_p46              (matrix_p46),
    .matrix_p47              (matrix_p47),  
    .matrix_p51              (matrix_p51),   
    .matrix_p52              (matrix_p52),
    .matrix_p53              (matrix_p53),
    .matrix_p54              (matrix_p54),
    .matrix_p55              (matrix_p55),
    .matrix_p56              (matrix_p56),
    .matrix_p57              (matrix_p57),
    .matrix_p61              (matrix_p61),   
    .matrix_p62              (matrix_p62),
    .matrix_p63              (matrix_p63),
    .matrix_p64              (matrix_p64),
    .matrix_p65              (matrix_p65),
    .matrix_p66              (matrix_p66),
    .matrix_p67              (matrix_p67),
    .matrix_p71              (matrix_p71),   
    .matrix_p72              (matrix_p72),
    .matrix_p73              (matrix_p73),
    .matrix_p74              (matrix_p74),
    .matrix_p75              (matrix_p75),
    .matrix_p76              (matrix_p76),
    .matrix_p77              (matrix_p77)    
);

//  [p11,p12,p13,p14,p15,p16,p17]   [11    15    18    19    18    15    11]
//  [p21,p22,p23,p24,p25,p26,p27]   [15    20    23    25    23    20    15]
//  [p31,p32,p33,p34,p35,p36,p37]   [18    23    28    29    28    23    18]
//  [p41,p42,p43,p44,p45,p46,p47] * [19    25    29    31    29    25    19]
//  [p51,p52,p53,p54,p55,p56,p57]   [18    23    28    29    28    23    18]
//  [p61,p62,p63,p64,p65,p66,p67]   [15    20    23    25    23    20    15]
//  [p71,p72,p73,p74,p75,p76,p77]   [11    15    18    19    18    15    11]

reg             [12:0]          mult_result11;
reg             [12:0]          mult_result12;
reg             [12:0]          mult_result13;
reg             [12:0]          mult_result14;
reg             [12:0]          mult_result15;
reg             [12:0]          mult_result16;
reg             [12:0]          mult_result17;
reg             [12:0]          mult_result21;
reg             [12:0]          mult_result22;
reg             [12:0]          mult_result23;
reg             [12:0]          mult_result24;
reg             [12:0]          mult_result25;
reg             [12:0]          mult_result26;
reg             [12:0]          mult_result27;
reg             [12:0]          mult_result31;
reg             [12:0]          mult_result32;
reg             [12:0]          mult_result33;
reg             [12:0]          mult_result34;
reg             [12:0]          mult_result35;
reg             [12:0]          mult_result36;
reg             [12:0]          mult_result37;
reg             [12:0]          mult_result41;
reg             [12:0]          mult_result42;
reg             [12:0]          mult_result43;
reg             [12:0]          mult_result44;
reg             [12:0]          mult_result45;
reg             [12:0]          mult_result46;
reg             [12:0]          mult_result47;
reg             [12:0]          mult_result51;
reg             [12:0]          mult_result52;
reg             [12:0]          mult_result53;
reg             [12:0]          mult_result54;
reg             [12:0]          mult_result55;
reg             [12:0]          mult_result56;
reg             [12:0]          mult_result57;
reg             [12:0]          mult_result61;
reg             [12:0]          mult_result62;
reg             [12:0]          mult_result63;
reg             [12:0]          mult_result64;
reg             [12:0]          mult_result65;
reg             [12:0]          mult_result66;
reg             [12:0]          mult_result67;
reg             [12:0]          mult_result71;
reg             [12:0]          mult_result72;
reg             [12:0]          mult_result73;
reg             [12:0]          mult_result74;
reg             [12:0]          mult_result75;
reg             [12:0]          mult_result76;
reg             [12:0]          mult_result77;

always @(posedge clk)
begin
    mult_result11 <= matrix_p11 * 5'd11;
    mult_result12 <= matrix_p12 * 5'd15;
    mult_result13 <= matrix_p13 * 5'd18;
    mult_result14 <= matrix_p14 * 5'd19;
    mult_result15 <= matrix_p15 * 5'd18;
    mult_result16 <= matrix_p16 * 5'd15;
    mult_result17 <= matrix_p17 * 5'd11;
    
    mult_result21 <= matrix_p21 * 5'd15;
    mult_result22 <= matrix_p22 * 5'd20;
    mult_result23 <= matrix_p23 * 5'd23;
    mult_result24 <= matrix_p24 * 5'd25;
    mult_result25 <= matrix_p25 * 5'd23;
    mult_result26 <= matrix_p26 * 5'd20;
    mult_result27 <= matrix_p27 * 5'd15;
    
    mult_result31 <= matrix_p31 * 5'd18;
    mult_result32 <= matrix_p32 * 5'd23;
    mult_result33 <= matrix_p33 * 5'd28;
    mult_result34 <= matrix_p34 * 5'd29;
    mult_result35 <= matrix_p35 * 5'd28;
    mult_result36 <= matrix_p36 * 5'd23;
    mult_result37 <= matrix_p37 * 5'd18;
    
    mult_result41 <= matrix_p41 * 5'd19;
    mult_result42 <= matrix_p42 * 5'd25;
    mult_result43 <= matrix_p43 * 5'd29;
    mult_result44 <= matrix_p44 * 5'd31;
    mult_result45 <= matrix_p45 * 5'd29;
    mult_result46 <= matrix_p46 * 5'd25;
    mult_result47 <= matrix_p47 * 5'd19;    

    mult_result51 <= matrix_p51 * 5'd18;
    mult_result52 <= matrix_p52 * 5'd23;
    mult_result53 <= matrix_p53 * 5'd28;
    mult_result54 <= matrix_p54 * 5'd29;
    mult_result55 <= matrix_p55 * 5'd28;
    mult_result56 <= matrix_p56 * 5'd23;
    mult_result57 <= matrix_p57 * 5'd18;

    mult_result61 <= matrix_p61 * 5'd15;
    mult_result62 <= matrix_p62 * 5'd20;
    mult_result63 <= matrix_p63 * 5'd23;
    mult_result64 <= matrix_p64 * 5'd25;
    mult_result65 <= matrix_p65 * 5'd23;
    mult_result66 <= matrix_p66 * 5'd20;
    mult_result67 <= matrix_p67 * 5'd15;
    
    mult_result71 <= matrix_p71 * 5'd11;
    mult_result72 <= matrix_p72 * 5'd15;
    mult_result73 <= matrix_p73 * 5'd18;
    mult_result74 <= matrix_p74 * 5'd19;
    mult_result75 <= matrix_p75 * 5'd18;
    mult_result76 <= matrix_p76 * 5'd15;
    mult_result77 <= matrix_p77 * 5'd11;    

end

reg     [15:0]  sum_result1;
reg     [15:0]  sum_result2;
reg     [15:0]  sum_result3;
reg     [15:0]  sum_result4;
reg     [15:0]  sum_result5;
reg     [15:0]  sum_result6;
reg     [15:0]  sum_result7;

always @(posedge clk)
begin
    sum_result1 <= (mult_result11 + mult_result12) + (mult_result13 + mult_result14) + (mult_result15 + mult_result16) + mult_result17;
    sum_result2 <= (mult_result21 + mult_result22) + (mult_result23 + mult_result24) + (mult_result25 + mult_result26) + mult_result27;
    sum_result3 <= (mult_result31 + mult_result32) + (mult_result33 + mult_result34) + (mult_result35 + mult_result36) + mult_result37;
    sum_result4 <= (mult_result41 + mult_result42) + (mult_result43 + mult_result44) + (mult_result45 + mult_result46) + mult_result47;
    sum_result5 <= (mult_result51 + mult_result52) + (mult_result53 + mult_result54) + (mult_result55 + mult_result56) + mult_result57;
    sum_result6 <= (mult_result61 + mult_result62) + (mult_result63 + mult_result64) + (mult_result65 + mult_result66) + mult_result67;
    sum_result7 <= (mult_result71 + mult_result72) + (mult_result73 + mult_result74) + (mult_result75 + mult_result76) + mult_result77;        
end

reg     [18:0]  sum_result;

always @(posedge clk)
begin
    sum_result <=   (sum_result1 + sum_result2) + (sum_result3 + sum_result4) + (sum_result5 + sum_result6) + sum_result7;
end

reg     [7:0]   pixel_data;

always @(posedge clk)
begin
    pixel_data <= sum_result[18:10] + sum_result[9];
end

//----------------------------------------------------------------------
//  lag 4 clocks signal sync
reg             [3:0]           matrix_img_vsync_r;
reg             [3:0]           matrix_img_href_r;
reg             [3:0]           matrix_edge_flag_r;

always @(posedge clk or negedge rst_n)
begin
    if(!rst_n)
    begin
        matrix_img_vsync_r <= 4'b0;
        matrix_img_href_r  <= 4'b0;
        matrix_edge_flag_r <= 4'b0;
    end
    else
    begin
        matrix_img_vsync_r <= {matrix_img_vsync_r[2:0],matrix_img_vsync};
        matrix_img_href_r  <= {matrix_img_href_r[2:0],matrix_img_href};
        matrix_edge_flag_r <= {matrix_edge_flag_r[2:0],matrix_top_edge_flag | matrix_bottom_edge_flag | matrix_left_edge_flag | matrix_right_edge_flag};
    end
end

reg             [7:0]           matrix_p44_r    [0:3];

always @(posedge clk)
begin
    matrix_p44_r[0] <= matrix_p44;
    matrix_p44_r[1] <= matrix_p44_r[0];
    matrix_p44_r[2] <= matrix_p44_r[1];
    matrix_p44_r[3] <= matrix_p44_r[2];
end

//----------------------------------------------------------------------
//  result output
always @(posedge clk)
begin
    if(matrix_edge_flag_r[3] == 1'b1)
        post_data <= matrix_p44_r[3];
    else
        post_data <= pixel_data;
end

always @(posedge clk or negedge rst_n)
begin
    if(!rst_n)
    begin
        post_vs <= 1'b0;
        post_de <= 1'b0;
    end
    else
    begin
        post_vs <= matrix_img_vsync_r[3];
        post_de <= matrix_img_href_r[3];
    end
end

always @(posedge clk)begin
    original_data   <=  matrix_p44_r[3];
end

endmodule