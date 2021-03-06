//+------------------------------------------------------------------+
//|                                                KEG_breakeven.mq5 |
//|                                  Copyright 2022, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright     "Copyright 2022, IceSeed."
#property link          "https://www.gogojungle.co.jp/tools/indicators/37847"
#property version       "1.00"
#property icon          "../../Images/res.ico"
#property indicator_chart_window

#include <KEG/Common.mqh>
#include <KEG/Technical.mqh>
CTechnical Tech;

input color             bk_clr       = clrRed;              //ラインカラー
input ENUM_LINE_STYLE   bk_style     = STYLE_DASHDOTDOT;    //ラインスタイル
input int               bk_width     = 1;                   //ライン幅

string obj_name = "KEG_breakeven";


int OnInit()
{
   if( PositionsTotal() > 0 )
      create( calc() );
   else{
      if( ObjectFind( 0, obj_name ) != -1 )
         ObjectDelete( 0, obj_name );
   }
   
   return INIT_SUCCEEDED;
}
void OnDeinit( const int reason )
{
   ObjectDelete( 0, obj_name );
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
   
   if( OrdersTotal() >= 0 )
      create( calc() );
   else{
      if( ObjectFind( 0, obj_name ) != -1 )
         ObjectDelete( 0, obj_name );
   }
      
   return rates_total;
}


double calc()
{
   double d_ret   = 0;
   double equity  = 0;
   double lots    = 0;
   MqlTick tick;
   
   for( int i = 0; i < PositionsTotal(); i++ )
   {
      ulong ticket = PositionGetTicket( i );
      if( ticket != 0 )
      {
         if( PositionGetString( POSITION_SYMBOL ) != Symbol() )
            continue;
         
         long type = PositionGetInteger( POSITION_TYPE );
         if( type == OP_BUY )
            lots += PositionGetDouble( POSITION_VOLUME );
         else if( type == OP_SELL )
            lots -= PositionGetDouble( POSITION_VOLUME );
         else
            continue;
         
         equity += PositionGetDouble( POSITION_PROFIT ) + PositionGetDouble( POSITION_SWAP );
      }
   }
   
   if( lots == 0 )
      return 0;

   SymbolInfoTick( _Symbol, tick );
   double   COP    = lots * SymbolInfoDouble( Symbol(), SYMBOL_TRADE_TICK_VALUE );
   double   val    = tick.bid - ( Point() * equity / COP );
   string   even   = DoubleToString( val, Digits() );
   
   d_ret = (double)even;   
   
   return d_ret;
}

void create( double price )
{
   ObjectCreate( 0, obj_name, OBJ_TREND, 0, get_right_time(), price, Tech.time( 0 ), price );
   
   ObjectSetInteger( 0, obj_name, OBJPROP_COLOR,       bk_clr );
   ObjectSetInteger( 0, obj_name, OBJPROP_STYLE,       bk_style );
   ObjectSetInteger( 0, obj_name, OBJPROP_WIDTH,       bk_width );
   ObjectSetInteger( 0, obj_name, OBJPROP_BACK,        true );
   ObjectSetInteger( 0, obj_name, OBJPROP_SELECTABLE,  false );
   ObjectSetString(  0, obj_name, OBJPROP_TEXT,        "BREAK_EVEN" );  
   ObjectSetInteger( 0, obj_name, OBJPROP_RAY_RIGHT,   false );
}

datetime get_right_time()
{
   return datetime( Tech.time( 0 ) + ChartGetInteger( 0, CHART_VISIBLE_BARS ) * Period() * 60 );
}
