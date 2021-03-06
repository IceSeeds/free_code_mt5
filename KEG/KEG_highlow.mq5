//+------------------------------------------------------------------+
//|                                                  KEG_highlow.mq4 |
//|                                         Copyright 2020, IceSeed. |
//|                                           https://ice-blog.work/ |
//+------------------------------------------------------------------+
#property copyright     "Copyright 2020, IceSeed."
#property link          "https://ice-blog.work/"
#property version       "1.00"
#property icon          "../../Images/res.ico"
#property description   "前日、当日の高値と安値にラインを描写するインジケータです。\n詳しい説明は上記リンクからご覧下さい。"
#property strict
#property indicator_chart_window


input int               text_shift           = 20; //フォント位置
input string            hl_dummy2 = "-- 本日高安 --"; //-- 本日高値 --
input color             to_line_color        = clrFireBrick;      //ラインカラー
input ENUM_LINE_STYLE   to_line_style        = STYLE_DOT;         //ラインスタイル
input int               to_line_width        = 1;                 //ライン幅
input color             to_font_color        = clrFireBrick;      //フォントカラー
input int               to_font_size         = 9;                 //フォントサイズ

input string            hl_dummy4　= "-- 前日高安 --"; //-- 前日高安 --
input color             yd_line_color        = clrDarkKhaki;      //ラインカラー
input ENUM_LINE_STYLE   yd_line_style        = STYLE_DOT;         //ラインスタイル
input int               yd_line_width        = 1;                 //ライン幅
input color             yd_font_color        = clrDarkKhaki;      //フォントカラー
input int               yd_font_size         = 9 ;                //フォントサイズ


string   prefix = "KEG_hl_";

//line name
string   t_high_name = prefix + "t_high";
string   t_low_name  = prefix + "t_low";
string   y_high_name = prefix + "y_high";
string   y_low_name  = prefix + "y_low";

//label name
string   t_high_label_name = prefix + "t_high_label";
string   t_low_label_name  = prefix + "t_low_label";
string   y_high_label_name = prefix + "y_high_label";
string   y_low_label_name  = prefix + "y_low_label";

datetime shift_time;


int OnInit()
{
   //setting font position
   shift_time = get_time() + PeriodSeconds() * text_shift;
   
   //objects create and setting style
   create();
   
   
   return INIT_SUCCEEDED;
}
void OnDeinit( const int reason )
{
   ObjectsDeleteAll( ChartID(), prefix );
}

int OnCalculate( const int       rates_total,
                 const int       prev_calculated,
                 const datetime  &time[],
                 const double    &open[],
                 const double    &high[],
                 const double    &low[],
                 const double    &close[],
                 const long      &tick_volume[],
                 const long      &volume[],
                 const int       &spread[] )
{
   //moved only today
   move();
   
   return rates_total;
}

void create()
{
   //object line create and style
   ObjectCreate( 0, t_high_name, OBJ_HLINE, 0,  get_time(), iHigh( _Symbol, PERIOD_D1, 0 ) );
   ObjectCreate( 0, t_low_name,  OBJ_HLINE, 0,  get_time(), iLow(  _Symbol, PERIOD_D1, 0 ) );
   ObjectCreate( 0, y_high_name, OBJ_HLINE, 0,  get_time(), iHigh( _Symbol, PERIOD_D1, 1 ) );
   ObjectCreate( 0, y_low_name,  OBJ_HLINE, 0,  get_time(), iLow(  _Symbol, PERIOD_D1, 1 ) );
   set_line_style( t_high_name, to_line_color, to_line_style, to_line_width );
   set_line_style( t_low_name,  to_line_color, to_line_style, to_line_width );
   set_line_style( y_high_name, yd_line_color, yd_line_style, yd_line_width );
   set_line_style( y_low_name,  yd_line_color, yd_line_style, yd_line_width );
   
   //object text create and style
   ObjectCreate( 0, t_high_label_name, OBJ_TEXT, 0,   shift_time, iHigh( _Symbol, PERIOD_D1, 0 ) );
   ObjectCreate( 0, t_low_label_name,  OBJ_TEXT, 0,   shift_time, iLow(  _Symbol, PERIOD_D1, 0 ) );
   ObjectCreate( 0, y_high_label_name, OBJ_TEXT, 0,   shift_time, iHigh( _Symbol, PERIOD_D1, 1 ) );
   ObjectCreate( 0, y_low_label_name,  OBJ_TEXT, 0,   shift_time, iLow(  _Symbol, PERIOD_D1, 1 ) );
   set_text_style( t_high_label_name, to_font_color, to_font_size, "当日高値" );
   set_text_style( t_low_label_name,  to_font_color, to_font_size, "当日安値" );
   set_text_style( y_high_label_name, yd_font_color, to_font_size, "前日高値" );
   set_text_style( y_low_label_name,  yd_font_color, to_font_size, "前日安値" );
}
void set_line_style( string name, color clr, ENUM_LINE_STYLE style, int width )
{
   ObjectSetInteger( 0, name, OBJPROP_COLOR,       clr   );
   ObjectSetInteger( 0, name, OBJPROP_STYLE,       style );
   ObjectSetInteger( 0, name, OBJPROP_WIDTH,       width );
   ObjectSetInteger( 0, name, OBJPROP_SELECTABLE,  false );
   ObjectSetInteger( 0, name, OBJPROP_BACK,        true  );
}
void set_text_style( string name, color clr, int size, string text )
{
   ObjectSetInteger( 0, name, OBJPROP_COLOR,       clr         );
   ObjectSetString(  0, name, OBJPROP_TEXT,        text        );
   ObjectSetString(  0, name, OBJPROP_FONT,        "ＭＳ　ゴシック" );
   ObjectSetInteger( 0, name, OBJPROP_FONTSIZE,    size        );
   ObjectSetInteger( 0, name, OBJPROP_SELECTABLE,  false       );
   ObjectSetInteger( 0, name, OBJPROP_BACK,        true        );
}

void move()
{
   ObjectMove( 0, t_high_name,         0, get_time(), iHigh( _Symbol, PERIOD_D1, 0 ) );
   ObjectMove( 0, t_low_name,          0, get_time(), iLow(  _Symbol, PERIOD_D1, 0 ) );
   ObjectMove( 0, t_high_label_name,   0, shift_time, iHigh( _Symbol, PERIOD_D1, 0 ) );
   ObjectMove( 0, t_low_label_name,    0, shift_time, iLow(  _Symbol, PERIOD_D1, 0 ) );
}

datetime get_time(){ return iTime( _Symbol, PERIOD_CURRENT, 0 ); }
