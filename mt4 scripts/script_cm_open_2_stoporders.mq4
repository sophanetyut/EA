//+------------------------------------------------------------------+
//|                                  script_cm_open_2_stoporders.mq4 |
//|                                Copyright 2016, cmillion@narod.ru |
//|                                               http://cmillion.ru |
//+------------------------------------------------------------------+
#property copyright "Copyright 2016, cmillion@narod.ru"
#property link      "http://cmillion.ru"
#property version   "1.00"
#property strict
#property show_inputs
#property description "������ �������� ��������������� ���� ������� � ��������� �����"
#property description "����� ������������ ������, ������ ���������"
/*--------------------------------------------------------------------
� ������������ �����(������� � ����������) ������������ 
��� ���������� ������ ������� � ������� �� ���������� � ������� (�������� � 
����������) �� ������� ����, � TP � SL � ������� (�������� � ����������). 
����� ������������ ������ �� �������, ��������������� ���������.
����� ������ ����������� ���� ������.
//--------------------------------------------------------------------*/
extern int      level          = 10,       //���������� �� ������� ���� �� �������
stoploss       = 50,       //������� ����������� SL, ���� 0, �� SL �� ������������
takeprofit     = 50,       //������� ����������� TP, ���� 0, �� TP �� ������������
Magic          = 0;        //���������� ����� ������
extern double   Lot            = 0.1;      //����� �������
extern datetime TimeSet=D'2016.01.06 01:08'; //����� ����������� �������, ���� ������� ����� ������ ��������������, �� ������������ �����
int slippage=3;
double STOPLEVEL;
//--------------------------------------------------------------------
void OnStart()
  {
   if(Digits==3 || Digits==5) {level*=10;stoploss*=10;takeprofit*=10;slippage*=10;}
   while(TimeCurrent()<TimeSet)
     {
      if(IsStopped()) {Comment("�������������� �������� ������� ",TimeToStr(TimeCurrent(),TIME_DATE|TIME_SECONDS));return;}
      Sleep(1000);
      Comment(TimeToStr(TimeCurrent(),TIME_SECONDS),"\n������ �������� ��������������� ���� ������� � ",
              TimeToStr(TimeSet,TIME_DATE|TIME_SECONDS),"\n",WindowExpertName(),"\n",
              "�� ����������� ������� �������� ",TimeToStr(TimeSet-TimeCurrent(),TIME_SECONDS));
     }
//---
   string txt=NULL;
   RefreshRates();
   STOPLEVEL=MarketInfo(Symbol(),MODE_STOPLEVEL);
   if(level<STOPLEVEL) level=(int)STOPLEVEL;
   double SL,TP,Price=NormalizeDouble(Ask+level*Point,Digits);
   if(takeprofit!=0)
     {
      if(takeprofit<STOPLEVEL) TP=NormalizeDouble(Price+STOPLEVEL*Point,Digits);
      else  TP=NormalizeDouble(Price+takeprofit*Point,Digits);
     }
   else TP=0;
   if(stoploss!=0)
     {
      if(stoploss<STOPLEVEL) SL=NormalizeDouble(Price-STOPLEVEL*Point,Digits);
      else  SL=NormalizeDouble(Price-stoploss*Point,Digits);
     }
   else SL=0;
   if(OrderSend(Symbol(),OP_BUYSTOP,Lot,Price,slippage,SL,TP,NULL,Magic,0,clrBlue)!=-1)
      txt=StringConcatenate(txt,"����� BUYSTOP ������� ��������� ",TimeToStr(TimeCurrent(),TIME_DATE|TIME_SECONDS),"\n");
   else txt=StringConcatenate(txt,"\nError ",GetLastError(),"  OPENORDER BUYSTOP     Ask =",DoubleToStr(Ask,Digits),
      "   Price =",DoubleToStr(Price,Digits)," (",NormalizeDouble((Price-Ask)/Point,0),")  SL =",DoubleToStr(SL,Digits),
      " (",NormalizeDouble((Price-SL)/Point,0),")  TP=",DoubleToStr(TP,Digits)," (",NormalizeDouble((TP-Price)/Point,0),")  STOPLEVEL=",STOPLEVEL,"\n");

   Price=NormalizeDouble(Bid-level*Point,Digits);
   if(takeprofit!=0)
     {
      if(takeprofit<STOPLEVEL) TP=NormalizeDouble(Price-STOPLEVEL*Point,Digits);
      else  TP=NormalizeDouble(Price-takeprofit*Point,Digits);
     }
   else TP=0;
   if(stoploss!=0)
     {
      if(stoploss<STOPLEVEL) SL=NormalizeDouble(Price+STOPLEVEL*Point,Digits);
      else  SL=NormalizeDouble(Price+stoploss*Point,Digits);
     }
   else SL=0;
   if(OrderSend(Symbol(),OP_SELLSTOP,Lot,Price,slippage,SL,TP,NULL,Magic,0,clrRed)!=-1)
      txt=StringConcatenate(txt,"����� SELLSTOP ������� ��������� ",TimeToStr(TimeCurrent(),TIME_DATE|TIME_SECONDS),"\n");
   else txt=StringConcatenate(txt,"\nError ",GetLastError(),"  OPENORDER SELLSTOP     Bid =",DoubleToStr(Bid,Digits),
      "   Price =",DoubleToStr(Price,Digits)," (",NormalizeDouble((Bid-Price)/Point,0),")  SL =",DoubleToStr(SL,Digits),
      " (",NormalizeDouble((SL-Price)/Point,0),")  TP=",DoubleToStr(TP,Digits)," (",NormalizeDouble((Price-TP)/Point,0),")  STOPLEVEL=",STOPLEVEL,"\n");
   Comment(txt);

//---
   while(true)
     {
      if(IsStopped()) {Comment("�������������� �������� ������� ",TimeToStr(TimeCurrent(),TIME_DATE|TIME_SECONDS));return;}
      int TicketB=0,TicketS=0,OT,j;
      for(j=OrdersTotal(); j>=0; j--)
        {
         if(OrderSelect(j,SELECT_BY_POS,MODE_TRADES))
           {
            OT=OrderType();
            if(OrderSymbol()==Symbol() && OT>1 && OrderMagicNumber()==Magic)
              {
               if(OT==OP_BUYSTOP) TicketB=OrderTicket();
               if(OT==OP_SELLSTOP) TicketS=OrderTicket();
              }
           }
        }
      if(TicketB>0 && TicketS==0) if(OrderDelete(TicketB)) break;
      if(TicketS>0 && TicketB==0) if(OrderDelete(TicketS)) break;
      if(TicketS==0 && TicketB==0) break;
      Comment("������ �������� ��������������� ���� �������\n",WindowExpertName(),"\n",txt,
              "���� �������� ������ �� ������� ",TimeToStr(TimeCurrent(),TIME_SECONDS));
      Sleep(1000);
     }
   Comment("������ \"",WindowExpertName(),"\" �������� ���� ������ ",TimeToStr(TimeCurrent(),TIME_DATE|TIME_SECONDS));
  }
//--------------------------------------------------------------------
