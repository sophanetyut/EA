//+---------------------------------------------------------------------------+ 
//| Sell Percent.mq4                                                          |
//| ������ ��������� ������� SELL �������� � ������� �� ����������� ��������� |
//+---------------------------------------------------------------------------+
#property copyright "mandorr@gmail.com"
#property show_inputs
//----
#include <WinUser32.mqh>
//----
extern int StopLoss=0;
extern int TakeProfit=11;
extern int Percent=100;
void start()
{
   if (!IsCondition()) return;
   double lots=AccountLots();
   if (lots<=0)
   { 
      string title="������";
      string msg="��� ��������� �������     ";
      MessageBox(msg,title,MB_OK|MB_ICONERROR);
      return;
   }
   int slippage=2;
   double loss=0  ; if (StopLoss  >0) loss  =Bid+StopLoss  *Point;
   double profit=0; if (TakeProfit>0) profit=Bid-TakeProfit*Point;
   OrderSend(Symbol(),OP_SELL,lots,Bid,slippage,loss,profit,NULL,0,0,CLR_NONE);
   ShowError();
}
double AccountLots()
{
   double freemargin=AccountFreeMargin(); if (freemargin<=0) return (0);
   double lotmargin=0;
   string symbol=Symbol();
   string market=MarketType(symbol);
   if (market=="Forex"  ) lotmargin=LotMarginForex  (symbol);
   if (market=="Metalls") lotmargin=LotMarginCFD    (symbol);
   if (market=="CFD"    ) lotmargin=LotMarginCFD    (symbol);
   if (market=="Futures") lotmargin=LotMarginFutures(symbol);
   if (market=="") return (0);
   double lots=0; if (lotmargin>0) lots=0.01*Percent*freemargin/lotmargin;
   double minlot=MarketInfo(symbol,MODE_MINLOT);
   int count=0; if (minlot>0) count=lots/minlot;
   lots=minlot*count;
   return (lots);
}
string MarketType (string symbol)
{
   int len=StringLen(symbol);
   string base;
   if (StringSubstr(symbol,0,1)=="_") return ("Indexes");
   if (StringSubstr(symbol,0,1)=="#")
   {
      base=StringSubstr(symbol,len-1,1);
      if (base=="0") return ("Futures");
      if (base=="1") return ("Futures");
      if (base=="2") return ("Futures");
      if (base=="3") return ("Futures");
      if (base=="4") return ("Futures");
      if (base=="5") return ("Futures");
      if (base=="6") return ("Futures");
      if (base=="7") return ("Futures");
      if (base=="8") return ("Futures");
      if (base=="9") return ("Futures");
      return ("CFD");
   }
   else
   {
      if (symbol=="GOLD"  ) return ("Metalls");
      if (symbol=="SILVER") return ("Metalls");
      if (len==6)
      {
         base=StringSubstr(symbol,0,3);
         if (base=="AUD") return ("Forex");
         if (base=="CAD") return ("Forex");
         if (base=="CHF") return ("Forex");
         if (base=="EUR") return ("Forex");
         if (base=="GBP") return ("Forex");
         if (base=="LFX") return ("Forex");
         if (base=="NZD") return ("Forex");
         if (base=="SGD") return ("Forex");
         if (base=="USD") return ("Forex");
      }
   }
   return ("");
}
double LotMarginForex (string symbol)
{
   double lotsize=MarketInfo(symbol,MODE_LOTSIZE);
   double leverage=AccountLeverage();
   double result=0; if (leverage>0) result=lotsize/leverage;
   string base=StringSubstr(symbol,0,3);
   string �urrency=AccountCurrency();
   double rate_�urrency=1; if (base!=�urrency) rate_�urrency=MarketInfo(base+�urrency,MODE_BID);
   result=rate_�urrency*result;
   return (result);
}
double LotMarginCFD (string symbol)
{
   double bid_symbol=MarketInfo(symbol,MODE_BID);
   double lotsize=MarketInfo(symbol,MODE_LOTSIZE);
   double leverage=10;
   double result=0; if (leverage>0) result=lotsize*bid_symbol/leverage;
   string �urrency=AccountCurrency();
   double rate_�urrency=1; if (�urrency!="USD") rate_�urrency=MarketInfo(�urrency+"USD",MODE_BID);
   result=rate_�urrency*result;
   return (result);
}
double LotMarginFutures (string symbol)
{
   int len=StringLen(symbol);
   double result=0;
   string base=StringSubstr(symbol,0,len-2);
   if (base=="#ENQ" ) result=3750;
   if (base=="#EP"  ) result=3938;
   if (base=="#SLV" ) result=5063;
   if (base=="#GOLD") result=2363;
   if (base=="#CL"  ) result=4725;
   if (base=="#NG"  ) result=8100;
   if (base=="#W"   ) result= 608;
   if (base=="#S"   ) result=1148;
   if (base=="#C"   ) result= 473;
   string �urrency=AccountCurrency();
   double rate_�urrency=1; if (�urrency!="USD") rate_�urrency=MarketInfo(�urrency+"USD",MODE_BID);
   result=rate_�urrency*result;
   return (result);
}
bool IsCondition()
{
   bool result=true;
   string field="     ";
   string msg;
   string title="������"; if (AccountNumber()>0)title=AccountNumber()+": "+title;
   if (!IsConnected())
   {
      msg=msg+"����� � �������� �����������"+field;
      result=false;
   }
   if (!IsTradeAllowed())
   {
      if (!result) msg=msg+"\n";
      msg=msg+"�������� ���������"+field;
      result=false;
   }
   if (!result) MessageBox(msg,title,MB_OK|MB_ICONERROR);
   return (result);
}
void ShowError()
{
   string description;
   int err=GetLastError();
   switch (err)
   {
      case   0: return;
      case   1: description="��� ������, �� ��������� ����������"; break;
      case   2: description="����� ������"; break;
      case   3: description="������������ ���������"; break;
      case   4: description="�������� ������ �����"; break;
      case   5: description="������ ������ ����������� ���������"; break;
      case   6: description="��� ����� � �������� ��������"; break;
      case   7: description="������������ ����"; break;
      case   8: description="������� ������ �������"; break;
      case   9: description="������������ �������� ���������� ���������������� �������"; break;
      case  64: description="���� ������������"; break;
      case  65: description="������������ ����� �����"; break;
      case 128: description="����� ���� �������� ���������� ������"; break;
      case 129: description="������������ ����"; break;
      case 130: description="������������ �����"; break;
      case 131: description="������������ �����"; break;
      case 132: description="����� ������"; break;
      case 133: description="�������� ���������"; break;
      case 134: description="������������ ����� ��� ���������� ��������"; break;
      case 135: description="���� ����������"; break;
      case 136: description="��� ���"; break;
      case 137: description="������ �����"; break;
      case 138: description="����� ����"; break;
      case 139: description="����� ������������ � ��� ��������������"; break;
      case 140: description="��������� ������ �������"; break;
      case 141: description="������� ����� ��������"; break;
      case 145: description="����������� ���������, ��� ��� ����� ������� ������ � �����"; break;
      case 146: description="���������� �������� ������"; break;
      case 147: description="������������� ���� ��������� ������ ��������� ��������"; break;
      default : description="����������� ������"; break;
   }
   string field="     ";
   string msg="������ #"+err+" "+description+field;
   string title="������"; if (AccountNumber()>0)title=AccountNumber()+": "+title;
   MessageBox(msg,title,MB_OK|MB_ICONERROR);
}
// End