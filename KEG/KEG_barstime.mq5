//+------------------------------------------------------------------+
//|                                                 KEG_bartimes.mq4 |
//|                        Copyright 2020, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright     "Copyright 2020, IceSeed."
#property link          ""
#property version       "1.00"
#property icon          "../../Images/res.ico"
#property description   "\n詳しい説明は上記リンクからご覧下さい。"
#property strict
#property indicator_chart_window


#include <KEG/Common.mqh>
#include <KEG/Technical.mqh>
CTechnical Tech;


enum position{
   LEFT_UPPER  = 0,  //左上
   RIGHT_UPPER = 1,  //右上
   LEFT_LOWER  = 2,  //左下
   RIGHT_LOWER = 3   //右下
};

input int               limit_time     = 5;           //スタイルを変える時間(n分)
input int               formal_size    = 10;          //通常サイズ
input color             formal_color   = clrWhite;    //通常カラー
input int               limit_size     = 15;          //リミットサイズ
input color             limit_color    = clrYellow;   //リミットカラー
input position          inp_position   = RIGHT_LOWER; //表示位置
input int               x              = 4;           //x座標
input int               y              = 4;           //y座標


int      i_font_size    = formal_size;
color    c_font_color   = formal_color;

string   prefix         = "KEG_bartimes_";

string   str_curr_name  = prefix + "curr";
string   str_my_name    = prefix + "my";

int OnInit()
{
   EventSetMillisecondTimer( 1000 );
   create( str_curr_name,  x, y ); //create label obj
   
   return INIT_SUCCEEDED;
}
void OnDeinit( const int reason )
{
   ObjectsDeleteAll( 0, prefix );
   EventKillTimer();
}

void OnTimer()
{
   calc( str_curr_name, PERIOD_CURRENT ); //timer calc, obj_name; timeframe;
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
   return rates_total;
}

void calc( string name, ENUM_TIMEFRAMES _timeframe )
{
   string str_obj_text;
	datetime min = 0;
	int sec      = 0;
	
	str_obj_text = "Curr : ";
	
	if( _timeframe == PERIOD_CURRENT )
	   min = Tech.time( 0 ) + PeriodSeconds( _timeframe ) - TimeCurrent();
   else
      min = iTime( _Symbol, _timeframe, 0 ) + PeriodSeconds( _timeframe ) - TimeCurrent();
   
	sec = (int)min % 60;
	min = ( (int)min - (int)min % 60 ) / 60;
	
	if( Period() <= PERIOD_H1 ) //Add "時間" for more than 1 hour.
	{
	   fontchange( 0, (int)min );
		str_obj_text += IntegerToString( min ) + " 分 " + IntegerToString( sec ) + " 秒";
   }else
   {
		int hour = min >= 60 ? (int)min / 60 : 0;
		int m1   = (int)min - ( hour * 60 );
		fontchange( hour, m1 );
		
		str_obj_text += IntegerToString( hour ) + " 時間 " + IntegerToString( m1 ) + " 分 " + IntegerToString( sec ) + " 秒";
	}
	ObjectSetString(  0, name, OBJPROP_TEXT,        str_obj_text );
   ObjectSetInteger( 0, name, OBJPROP_FONTSIZE,    i_font_size );
   ObjectSetInteger( 0, name, OBJPROP_COLOR,       c_font_color );
}

void fontchange( int h1, int k1 )
{
   if( h1 == 0 && k1 <= limit_time )
   {
      i_font_size  = limit_size;
      c_font_color = limit_color;
   }else{
      i_font_size  = formal_size;
      c_font_color = formal_color;
   }
}


void create( string name, int _x, int _y )
{
   ENUM_BASE_CORNER  corner = CORNER_LEFT_LOWER;
   ENUM_ANCHOR_POINT anchor = ANCHOR_LEFT_LOWER;
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
   
	ObjectCreate( 0, name, OBJ_LABEL, 0, 0, 0 );
	
	ObjectSetInteger( 0, name, OBJPROP_XDISTANCE,   _x );
	ObjectSetInteger( 0, name, OBJPROP_YDISTANCE,   _y );
	ObjectSetInteger( 0, name, OBJPROP_CORNER,      corner );
	ObjectSetInteger( 0, name, OBJPROP_ANCHOR,      anchor );
   ObjectSetInteger( 0, name, OBJPROP_FONTSIZE,    i_font_size );
   ObjectSetInteger( 0, name, OBJPROP_COLOR,       c_font_color );
   ObjectSetString(  0, name, OBJPROP_TEXT,        "." );
}
