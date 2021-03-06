//+------------------------------------------------------------------+
//|                                               KEG_volatility.mq4 |
//|                                         Copyright 2020, IceSeed. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright     "Copyright 2020, IceSeed."
#property link          "/"
#property version       "1.00"
#property icon          "../../Images/res.ico"
#property description   "\n"
#property strict
#property indicator_chart_window


enum position{
   LEFT_UPPER  = 0,  //左上
   RIGHT_UPPER = 1,  //右上
   LEFT_LOWER  = 2,  //左下
   RIGHT_LOWER = 3   //右下
};

input int      inp_period      = 30;          // 指定期間
input color    inp_color       = clrTomato;   //文字色
input int      inp_fontsize    = 10;          //フォントサイズ
input position inp_position    = RIGHT_LOWER; //表示位置
input bool     inp_period_view = true;        //期間の表示

string   prefix      = "KEG_vola_";
string   text_name   = prefix + "text";
string   value_name  = prefix + "value";

double   digits      = MathPow( 10, Digits() - 1 );


int OnInit()
{
   create();
   set_value( calc( 0 ), calc( 1 ), calc( inp_period ) );
   
   return INIT_SUCCEEDED;
}
void OnDeinit( const int reason )
{
   ObjectsDeleteAll( 0, prefix );
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
   set_value( calc( 0 ), calc( 1 ), calc( inp_period ) );
   
   return rates_total;
}

double calc( int shift )
{
   double candle_hl  = 0;
   double candle_ave = 0;
   double vola_ave   = 0;
   
   int i = shift == 0 ? 0 : 1;
   for( ; shift >= i; i++ )
   {
      candle_hl   = iHigh( Symbol(), PERIOD_D1, i ) - iLow( Symbol(), PERIOD_D1, i );
      candle_hl  *= digits;
      
      vola_ave   += NormalizeDouble( candle_hl, _Digits );
   }
   if( shift == 0 )
      return vola_ave;

   vola_ave /= shift;   
   return vola_ave;
}

void set_value( double today, double yesterday, double setting_period )
{
   ObjectSetString( 0, value_name, OBJPROP_TEXT, 
                    StringFormat( "%3.1fpips", today )     + "/" + 
                    StringFormat( "%3.1fpips", yesterday ) + "/" + 
                    StringFormat( "%3.1fpips", setting_period ) );
}
void create()
{
   ENUM_BASE_CORNER  corner=CORNER_LEFT_LOWER;
   ENUM_ANCHOR_POINT anchor=ANCHOR_LEFT_LOWER;
   if( inp_position == 0 )
   {
      corner = CORNER_LEFT_UPPER;
      anchor = ANCHOR_LEFT_UPPER;
   }else if( inp_position == 1 )
   {
      corner = CORNER_RIGHT_UPPER;
      anchor = ANCHOR_RIGHT_UPPER;   
   }else if( inp_position == 2 )
   {
      corner = CORNER_LEFT_LOWER;
      anchor = ANCHOR_LEFT_LOWER;
   }else if( inp_position == 3 )
   {
      corner = CORNER_RIGHT_LOWER;
      anchor = ANCHOR_RIGHT_LOWER;      
   }
   
   if( inp_period_view )
      ObjectCreate( 0, text_name,  OBJ_LABEL, 0, 0, 0 );
   ObjectCreate( 0, value_name, OBJ_LABEL, 0, 0, 0 );
   
   ObjectSetInteger( 0, text_name,     OBJPROP_XDISTANCE, 1 );
	ObjectSetInteger( 0, text_name,     OBJPROP_YDISTANCE, 15 );
	ObjectSetInteger( 0, value_name,    OBJPROP_XDISTANCE, 1 );
	ObjectSetInteger( 0, value_name,    OBJPROP_YDISTANCE, 2 );
   ObjectSetInteger( 0, text_name,     OBJPROP_CORNER,   corner );
   ObjectSetInteger( 0, value_name,    OBJPROP_CORNER,   corner );
   ObjectSetInteger( 0, text_name,     OBJPROP_ANCHOR,   anchor );
   ObjectSetInteger( 0, value_name,    OBJPROP_ANCHOR,   anchor );
   ObjectSetInteger( 0, text_name,  OBJPROP_FONTSIZE,    inp_fontsize );
   ObjectSetInteger( 0, value_name, OBJPROP_FONTSIZE,    inp_fontsize - 1 );
   ObjectSetString(  0, text_name,  OBJPROP_FONT,        "ＭＳ　ゴシック" );
   ObjectSetString(  0, value_name, OBJPROP_FONT,        "ＭＳ　ゴシック" );
   ObjectSetInteger( 0, text_name,  OBJPROP_COLOR,       inp_color );
   ObjectSetInteger( 0, value_name, OBJPROP_COLOR,       inp_color );
   ObjectSetInteger( 0, text_name,  OBJPROP_SELECTABLE,  false );
   ObjectSetInteger( 0, value_name, OBJPROP_SELECTABLE,  false );
   ObjectSetInteger( 0, text_name,  OBJPROP_SELECTED,    false );
   ObjectSetInteger( 0, value_name, OBJPROP_SELECTED,    false );   
   
   ObjectSetString( 0, text_name,  OBJPROP_TEXT, "【 当日 / 昨日 / " + string(inp_period) + "日 】" );
}
