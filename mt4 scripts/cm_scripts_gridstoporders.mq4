//+------------------------------------------------------------------+
//|                                    cm_scripts_gridstoporders.mq4 |
//|                                Copyright 2015, cmillion@narod.ru |
//+------------------------------------------------------------------+
#property copyright "Copyright 2015, cmillion@narod.ru"
#property link      "������� ��������"
#property version   "1.00"
#property strict
//---
#property show_inputs
//---
#property description "������ ���������� ���� � ����� �������, � ������� �� ��� ������, � � ����������� �� ����� ������ ���� ���������� �������."
#property description "���� ��������� ���� ���� ������� ����, �� ������ ������ Sell � ���� ���� Sell Stop, ���� ����, �� ������ Buy � ���� ���� Buy Stop."
//---
extern int      Step           = 30;       //���������� (� �������) ����� ��������
extern int      Orders         = 5;        //���-�� ������� �����
extern double   Lot            = 0.1;      //����� ������� Stop ������
extern double   K_Lot          = 1;        //��������� ���� Stop ������� 
extern double   PlusLot        = 0.1;      //���������� ��� �������� � ���� ����������� �������
extern int      DigitsLot      = 2;        //���������� �������� ����
extern int      stoploss       = 50;       //������� ����������� SL, ���� 0, �� SL �� ������������
extern int      takeprofit     = 100;      //������� ����������� TP, ���� 0, �� TP �� ������������
extern int      Expiration     = 1440;     //���� ��������� ����������� ������ � �������, ���� 0, �� ���� �� ��������� (1440 - �����)
extern int      attempts       = 10;       //���-�� ������� �������� ������ 
extern int      Magic          = 0;        //���������� ����� ������
//---
string txt;
int n,slippage=3;
datetime expiration;
double STOPLEVEL;
//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
void OnStart()
  {
   if(Expiration>0) expiration=TimeCurrent()+Expiration*60; else expiration=0;
   Comment("������ ������� ",TimeToStr(TimeCurrent(),TIME_DATE|TIME_SECONDS),"\nCopyright � 2015 cmillion@narod.ru");
   STOPLEVEL=MarketInfo(Symbol(),MODE_STOPLEVEL);
   if(Digits==3 || Digits==5) slippage=30;
   double Price;
   double LOT=Lot;
//---
   Price=NormalizeDouble(WindowPriceOnDropped(),Digits);
   int i;
//---
   if(Price>Ask)
     {
      Price=NormalizeDouble(Ask,Digits);
      OPENORDER(OP_BUY,Price,LOT);
      for(i=1; i<=Orders; i++)
        {
         Price=NormalizeDouble(Price+Step*Point,Digits);
         LOT=NormalizeDouble(LOT*K_Lot+PlusLot,DigitsLot);
         OPENORDER(OP_BUYSTOP,Price,LOT);
        }
     }
   if(Price<Bid)
     {
      Price=NormalizeDouble(Bid,Digits);
      OPENORDER(OP_SELL,Price,LOT);
      for(i=1; i<=Orders; i++)
        {
         Price=NormalizeDouble(Price-Step*Point,Digits);
         LOT=NormalizeDouble(LOT*K_Lot+PlusLot,DigitsLot);
         OPENORDER(OP_SELLSTOP,Price,LOT);
        }
     }
   Comment("������ �������� ���� ������, ���������� ",n," �������  ",TimeToStr(TimeCurrent(),TIME_DATE|TIME_SECONDS),"\nCopyright � 2015 cmillion@narod.ru");
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OPENORDER(int ord,double Price,double L)
  {
   int error,err;
   double SL=0,TP=0;
   while(true)
     {
      error=0;
      if(ord==OP_BUY)
        {
         if(takeprofit!=0) TP=NormalizeDouble(Price+takeprofit*Point,Digits); else TP=0;
         if(stoploss!=0) SL=NormalizeDouble(Price-stoploss*Point,Digits); else SL=0;
         error=OrderSend(Symbol(),ord,L,Price,slippage,SL,TP,"cmillion",Magic,expiration,Blue);
        }
      if(ord==OP_SELL)
        {
         if(takeprofit!=0) TP=NormalizeDouble(Price-takeprofit*Point,Digits); else TP=0;
         if(stoploss!=0) SL=NormalizeDouble(Price+stoploss*Point,Digits);  else SL=0;
         error=OrderSend(Symbol(),ord,L,Price,slippage,SL,TP,"cmillion",Magic,expiration,Red);
        }
      if(ord==OP_BUYSTOP)
        {
         if(takeprofit!=0) TP=NormalizeDouble(Price+takeprofit*Point,Digits); else TP=0;
         if(stoploss!=0) SL=NormalizeDouble(Price-stoploss*Point,Digits); else SL=0;
         error=OrderSend(Symbol(),ord,L,Price,slippage,SL,TP,"cmillion",Magic,expiration,Blue);
        }
      if(ord==OP_SELLSTOP)
        {
         if(takeprofit!=0) TP=NormalizeDouble(Price-takeprofit*Point,Digits); else TP=0;
         if(stoploss!=0) SL=NormalizeDouble(Price+stoploss*Point,Digits);  else SL=0;
         error=OrderSend(Symbol(),ord,L,Price,slippage,SL,TP,"cmillion",Magic,expiration,Red);
        }
      if(ord==OP_SELLLIMIT)
        {
         if(takeprofit!=0) TP=NormalizeDouble(Price-takeprofit*Point,Digits); else TP=0;
         if(stoploss!=0) SL=NormalizeDouble(Price+stoploss*Point,Digits);  else SL=0;
         error=OrderSend(Symbol(),ord,L,Price,slippage,SL,TP,"cmillion",Magic,expiration,Blue);
        }
      if(ord==OP_BUYLIMIT)
        {
         if(takeprofit!=0) TP=NormalizeDouble(Price+takeprofit*Point,Digits); else TP=0;
         if(stoploss!=0) SL=NormalizeDouble(Price-stoploss*Point,Digits); else SL=0;
         error=OrderSend(Symbol(),ord,L,Price,slippage,SL,TP,"cmillion",Magic,expiration,Red);
        }
      if(error==-1)
        {
         txt=StringConcatenate(txt,"\nError ",GetLastError());
         if(ord==OP_BUYSTOP)   txt = StringConcatenate(txt,"  OPENORDER BUYSTOP   Ask =",DoubleToStr(Ask,Digits),"   Lot =",DoubleToStr(L,DigitsLot),"   Price =",DoubleToStr(Price,Digits)," (",NormalizeDouble((Price-Ask)/Point,0),")  SL =",DoubleToStr(SL,Digits)," (",NormalizeDouble((Price-SL)/Point,0),")  TP=",DoubleToStr(TP,Digits)," (",NormalizeDouble((TP-Price)/Point,0),")  STOPLEVEL=",STOPLEVEL);
         if(ord==OP_SELLSTOP)  txt = StringConcatenate(txt,"  OPENORDER SELLSTOP  Bid =",DoubleToStr(Bid,Digits),"   Lot =",DoubleToStr(L,DigitsLot),"   Price =",DoubleToStr(Price,Digits)," (",NormalizeDouble((Bid-Price)/Point,0),")  SL =",DoubleToStr(SL,Digits)," (",NormalizeDouble((SL-Price)/Point,0),")  TP=",DoubleToStr(TP,Digits)," (",NormalizeDouble((Price-TP)/Point,0),")  STOPLEVEL=",STOPLEVEL);
         if(ord==OP_SELLLIMIT) txt = StringConcatenate(txt,"  OPENORDER SELLLIMIT Ask =",DoubleToStr(Ask,Digits),"   Lot =",DoubleToStr(L,DigitsLot),"   Price =",DoubleToStr(Price,Digits)," (",NormalizeDouble((Price-Ask)/Point,0),")  SL =",DoubleToStr(SL,Digits)," (",NormalizeDouble((Price-SL)/Point,0),")  TP=",DoubleToStr(TP,Digits)," (",NormalizeDouble((TP-Price)/Point,0),")  STOPLEVEL=",STOPLEVEL);
         if(ord==OP_BUYLIMIT)  txt = StringConcatenate(txt,"  OPENORDER BUYLIMIT  Bid =",DoubleToStr(Bid,Digits),"   Lot =",DoubleToStr(L,DigitsLot),"   Price =",DoubleToStr(Price,Digits)," (",NormalizeDouble((Bid-Price)/Point,0),")  SL =",DoubleToStr(SL,Digits)," (",NormalizeDouble((SL-Price)/Point,0),")  TP=",DoubleToStr(TP,Digits)," (",NormalizeDouble((Price-TP)/Point,0),")  STOPLEVEL=",STOPLEVEL);
         Print(txt);
         Comment(txt,"  ",TimeToStr(TimeCurrent(),TIME_DATE|TIME_SECONDS));
         err++;Sleep(1000);RefreshRates();
        }
      else
        {
         Comment("����� ",error," ������� ��������� ",TimeToStr(TimeCurrent(),TIME_DATE|TIME_SECONDS));
         n++;
         return;
        }
      if(err>attempts) return;
     }
   return;
  }
//+------------------------------------------------------------------+
