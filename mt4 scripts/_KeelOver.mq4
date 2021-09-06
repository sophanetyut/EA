//+------------------------------------------------------------------+
//|                                                    _KeelOver.mq4 |
//|                                           "������� ��� ��������" |
//|                ���������:  ������ ��������� ��� �������� ������� |
//|                � ��������� ���� �� ������� ���� ����� Buy � Sell |
//|                ��������: ���� ����� ����� Buy � Sell ����� - ��� |
//|                                     ������� ������ ����� ������� |
//|                           Bookkeeper, 2006, yuzefovich@gmail.com |
//+------------------------------------------------------------------+
#property copyright ""
#property link      ""
#property show_inputs // ���� ���� ������� ������ �������� � ��������
//----
extern int    DistSL    =35;   // StopLoss � �������
extern int    DistTP    =35;   // TakeProfit � �������
extern int    Slippage  =7;    // ���������������
extern bool   StopLoss  =true; // ������� ��� ���
extern bool   TakeProfit=true; // ������� ��� ���
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void start()
  {
   int    Total, i, Pos, ticket, MinLotDgts;
   bool   Result;
   double MinLot=MarketInfo(Symbol(), MODE_MINLOT);
   double SL=0, TP=0, Stake, BuyLots=0, SellLots=0;
   Total=OrdersTotal();
   if(Total > 0) // ���� ���� ������
     {
      for(i=Total - 1; i>=0; i--)
        {
         if(OrderSelect(i, SELECT_BY_POS, MODE_TRADES)==true)
           {
            Pos=OrderType();
            Stake=OrderLots();
            if((OrderSymbol()==Symbol()) &&
               (Pos==OP_BUY || Pos==OP_SELL)) // ������� ������ �������� Buy � Sell
              {                                   // � �������� ����
               if(Pos==OP_BUY)
                 {
                  BuyLots=BuyLots + Stake;    // ��������� ���� �������� Buy
                  Result=OrderClose(OrderTicket(), OrderLots(), Bid , Slippage);
                  if(Result!=true)
                     Alert("KeelOver: CloseBuyError = ", GetLastError());
                 }
               else
                 {
                  SellLots=SellLots + Stake;  // ��������� ���� �������� Sell
                  Result=OrderClose(OrderTicket(), OrderLots(), Ask , Slippage);
                  if(Result!=true)
                     Alert("KeelOver: CloseSellError = ", GetLastError());
                 }
              }
           }
        }
      if(MinLot < 0.1)
         MinLotDgts=2;
      else
        {
         if(MinLot < 1.0)
            MinLotDgts=1;
         else
            MinLotDgts=0;
        }
      Stake=NormalizeDouble(BuyLots - SellLots, MinLotDgts);
      if(Stake!=0) // ���� ���� ��� ��������������
        {
         if(Stake > 0) // ��������
           {
            RefreshRates();
            if(StopLoss==true)
               SL=NormalizeDouble(Ask + DistSL*Point, Digits);
            if(TakeProfit==true)
               TP=NormalizeDouble(Bid - 2*DistTP*Point, Digits);
            ticket=OrderSend(Symbol(), OP_SELL, Stake, Bid , Slippage, SL, TP, "");
            if(ticket<=0)
               Alert("KeelOver: OpenSellError: ", GetLastError());
           }
         else // ��������
           {
            Stake=-Stake;
            RefreshRates();
            if(StopLoss==true)
               SL=NormalizeDouble(Bid - DistSL*Point, Digits);
            if(TakeProfit==true)
               TP=NormalizeDouble(Ask + 2*DistTP*Point, Digits);
            ticket=OrderSend(Symbol(), OP_BUY, Stake, Ask , Slippage, SL, TP, "");
            if(ticket<=0)
               Alert("KeelOver: OpenBuyError: ", GetLastError());
           }
        }
      else
         Alert("KeelOver: BuyLots = SellLots");
     }
   return;
  }
//+------------------------------------------------------------------+

