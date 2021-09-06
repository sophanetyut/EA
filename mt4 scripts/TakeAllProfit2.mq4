//+------------------------------------------------------------------+
//| TakeAllProfit2.mq4
//| Version 2
//|
//| Fix Bug the slow, this is using the while loop bug by MT4
//| Fix the New version MT4 not working
//+------------------------------------------------------------------+

#property copyright "Copyright K Lam 2015"
#property link      "http://www.FxKillU.net/"
#property show_confirm
#include <stdlib.mqh>

#define MAGICMA  20151214
#define Version  20151214
#define Flowing 9
#define OP_CLOSEBUY  71
#define OP_CLOSESELL 72

extern string Name_Expert = "Take All Trades";
extern string PSymbol = "Any";//Any for any Symbol "USDCAD" else 
extern int TakeProfitPoint = 1;//temp no use..... any profit will close the easy to take at a day inside!
extern int MiniProfit = 1; //any profit will close the easy to take at a day inside!
extern int MagicKey = 0;//fix key or 0 for any
extern int Timeout=60*1;//1 Minute

//+------------------------------------------------------------------+
//| cal the point range
//+------------------------------------------------------------------+
double GetSlippage(string XSymbol)
{
   double bid   =MarketInfo(XSymbol,MODE_BID);
   double ask   =MarketInfo(XSymbol,MODE_ASK);
   double point =MarketInfo(XSymbol,MODE_POINT);
   return((ask-bid)/point);
}

//+------------------------------------------------------------------+
//| Check Server and wait server ready
//+------------------------------------------------------------------+
bool NBusy() //Not busy
{
   int cnt=10;
   int Waitfor;
   datetime StartWait=TimeCurrent();//datetime Waitfor,StartWait=TimeCurrent();

   for(cnt=10;cnt>=0;cnt--) {//while(count>=0) { // while always delay much! do not use
      Waitfor=TimeCurrent()-StartWait;
      if(IsTradeContextBusy()) cnt=10;
         else break;
         
      if(Waitfor > Timeout) {      //if(Waitfor > timeout) break;
         Print("Server Timeout! Wait ",Timeout," seconds. TradeContext Not free.");      
         return(false);
         }
      }
   
   if(Waitfor!=0) { //Comment("\n   ",Waitfor," seconds. Wait Server TradeContext free.");
      Print(Waitfor," seconds. Wait Server TradeContext free.");
      }
return(true);
}

//+------------------------------------------------------------------+
//| script "TakeAllProfit Profit last to 0 order"
//+------------------------------------------------------------------+
int TakeAllProfit(string TPSymbol,int MKey)
{
   bool result;
   int err;
   int TPCnt; //return closed count
   int OType,TradeTick;
   double price,OrderProfitCash,RealProfit;
   string CSymbol;
   
   if(OrdersTotal()==0) return(0);   
   if(NBusy()) {Print("Trade context is busy. Please wait");}

   for(TradeTick=OrdersTotal()-1; TradeTick >=0; TradeTick--) {//count form 0       //for(TimeOut=20;TimeOut > 0;TimeOut--) if(!IsTradeAllowed()) Sleep(10);
      if(OrderSelect(TradeTick,SELECT_BY_POS,MODE_TRADES)==false) continue; //      if(OrderSelect(TradeTick,SELECT_BY_POS,MODE_TRADES)) {
      
      if((TPSymbol=="Any") || 
         (OrderSymbol()==TPSymbol && MKey == 0) ||
         (OrderSymbol()==TPSymbol && OrderMagicNumber() == MKey)) {      
      
         OrderProfitCash = OrderProfit()+OrderCommission()+OrderSwap();
         if(OrderProfitCash < MiniProfit) continue;//step out not Close
         
         OType=OrderType();
         CSymbol=OrderSymbol();
         result=true;
         if(OType==OP_BUY || OType==OP_SELL) {
            RefreshRates();
            
            if(OType==OP_BUY) price=MarketInfo(CSymbol,MODE_BID);
            if(OType==OP_SELL) price=MarketInfo(CSymbol,MODE_ASK);// Bid; // not the chart price!!price=Ask;            
            
            if(NBusy())//wait server ready
               result=OrderClose(OrderTicket(),OrderLots(),price,GetSlippage(CSymbol),CLR_NONE);
            } //not buy or sell do nothings

         if(!result) {
            err=GetLastError();
            if(!IsTesting()) Print("TakeProfit Error=",err,ErrorDescription(err)," price=",price," Slippage=",GetSlippage(CSymbol));
            //TPCnt++;
            } else {TPCnt++; err=0; RealProfit+=OrderProfit();//closed in good working
               if(!IsTesting()) Print("TakeProfit OrderProfit = ", OrderProfitCash);}
         //if(error==129 || error==135 || error==146) Sleep(100);// RefreshRates(); 138                              
         if(err==129 || err==135 || err==138 ) RefreshRates();
         }//if((TPSymbol=="Any") || 
      } //for
   if(TPCnt>0 && !IsTesting()) Print(TPCnt," Order Closed Profit @ All =",RealProfit);

return(TPCnt);
}

//+------------------------------------------------------------------+
//| Main Programe
//+------------------------------------------------------------------+
int start()
{
   int    Cnt;
   int CloseNo;
   string Staring;
   
   Staring = "Staring Take Profit, Balance: "+ AccountBalance()+" Equity: "+AccountEquity()+"Last Profit "+AccountProfit();
   Print("Staring Take Profit, Balance: ", AccountBalance()," Equity: ",AccountEquity(),"Last Profit ",AccountProfit());
   
   CloseNo=OrdersTotal();
   Cnt=TakeAllProfit(PSymbol,MagicKey);
   Print(Cnt, "Order Been Closed ");
   
   CloseNo=CloseNo-OrdersTotal();
   Print(Staring);
   Print(CloseNo," Orders Closed, Balance: ", AccountBalance()," Equity: ",AccountEquity(),"Last Profit ",AccountProfit());
   
return(0);
}
//+------------------------------------------------------------------+