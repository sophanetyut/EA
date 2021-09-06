//+-----------------------------------------------------------------+ 
//| �������� ��� ���������.mq4                                      |
//| ������. ��������� � ����� experts\scripts                       |
//|                                                                 |
//+-----------------------------------------------------------------+
#property copyright "mandorr@gmail.com"
#include <WinUser32.mqh>
//----
string Tickers="EURUSD,GBPUSD,AUDUSD,USDCHF,USDJPY,USDCAD,GBPJPY,GOLD";
void start() 
{
   string title="������", msg="�������� ��� ���������?    ";
   if (MessageBox(msg,title,MB_YESNO|MB_ICONQUESTION)!=IDYES) return;
   string list[], symbol, tickers=StringTrimRight(StringTrimLeft(Tickers));
   int i , index, j;
   i=0;
   index=StringFind(tickers,",",0);
   while (index>0) 
   {
      symbol=StringSubstr(tickers,0,index);
      tickers=StringSubstr(tickers,index+1);
      if (StringLen(symbol)>0) 
      {
         i++;
         ArrayResize(list,i);
         list[i-1]=StringTrimRight(StringTrimLeft(symbol));
      }
      index=StringFind(tickers,",",0);
   }
   if (StringLen(tickers)>0) 
   {
      i++;
      ArrayResize(list,i);
      list[i-1]=StringTrimRight(StringTrimLeft(tickers));
   }
   double x;
   for (i=0; i<ArraySize(list); i++) 
   {
      symbol=list[i];
      msg="����������� ��������� "+symbol+",M1"; Comment (msg);
      for (j=16383; j>=0; j--) x=iClose(symbol,PERIOD_M1 ,j);
      msg="����������� ��������� "+symbol+",M5"; Comment (msg);
      for (j=16383; j>=0; j--) x=iClose(symbol,PERIOD_M5 ,j);
      msg="����������� ��������� "+symbol+",M15"; Comment (msg);
      for (j=16383; j>=0; j--) x=iClose(symbol,PERIOD_M15,j);
      msg="����������� ��������� "+symbol+",M30"; Comment (msg);
      for (j=16383; j>=0; j--) x=iClose(symbol,PERIOD_M30,j);
      msg="����������� ��������� "+symbol+",H1"; Comment (msg);
      for (j=16383; j>=0; j--) x=iClose(symbol,PERIOD_H1 ,j);
      msg="����������� ��������� "+symbol+",H4"; Comment (msg);
      for (j=16383; j>=0; j--) x=iClose(symbol,PERIOD_H4 ,j);
      msg="����������� ��������� "+symbol+",D1"; Comment (msg);
      for (j=16383; j>=0; j--) x=iClose(symbol,PERIOD_D1 ,j);
      msg="����������� ��������� "+symbol+",W1"; Comment (msg);
      for (j=16383; j>=0; j--) x=iClose(symbol,PERIOD_W1 ,j);
      msg="����������� ��������� "+symbol+",MN1"; Comment (msg);
      for (j=16383; j>=0; j--) x=iClose(symbol,PERIOD_MN1,j);
      msg="��������� ��� "+symbol+" ��������"; Comment (msg);
      Sleep(750);
   }
   msg="��������� ��������    "; Comment (msg);
   MessageBox(msg,title,MB_OK|MB_ICONINFORMATION);
   Comment ("");
}
// End