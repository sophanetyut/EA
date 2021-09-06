//+------------------------------------------------------------------+
//|                                                       Revers.mq4 |
//|                      Copyright � 2005, MetaQuotes Software Corp. |
//|                             http://www.metaquotes.ru/forum/6749/ |
//+------------------------------------------------------------------+
#property copyright "Copyright � 2005, MetaQuotes Software Corp."
#property link      "http://www.metaquotes.ru/forum/6749/"

extern int Slippage = 3;
//+------------------------------------------------------------------+
//| script program start function                                    |
//+------------------------------------------------------------------+
int start()
  {
//----
   int SymbolOrders;         // ���������� ������� �� ������� �������
   int cnt;                  // ������� ������� (��������)
   int buyOrders,sellOrders; // ���������� ������� � ����� (���������� �� �������)
   double buyLots,sellLots;  // ����� ����� �������� ������� � ������� � �������
   double reversLot;         // ����� ������������ ������
   int intLots;              // ��������������� ����������
   int ticket;               // ����� ������������ ������
//----
   if(!IsDemo()) // ������ �� ���������� ������� �� �������� �����
      {
        Alert("������ �� ����� ���������!!!");
        return; // ���������� ������ �������
      }
//----
   if(OrdersTotal() == 0)
      {
        Alert("������ �� �������");
        return; // ���������� ������ �������
      }
//----
   for(cnt = OrdersTotal() - 1; cnt >= 0; cnt--) // ��������� �� �������
     {
       if(OrderSelect(cnt, SELECT_BY_POS, MODE_TRADES)) // ���� ����� ������
          {
            if(OrderSymbol() != Symbol()) 
                continue;  // ���� ��������� ����� �� �� ������ �������
            // - ��������� � ���������� ������  
            if(OrderType() == OP_BUY) 
              {
                buyOrders++;                  // �������� ������� ������� � Buy
                buyLots = buyLots + OrderLots();  // �������� ����� ������� � Buy
              }
            if(OrderType() == OP_SELL) 
              {
                sellOrders++; // �������� ������� ������� � Sell
                sellLots = sellLots + OrderLots();  // �������� ����� ������� � Sell
              }
          }
     }
   // ������ ���������, ������ ����� ��������� - ���� �� ������ � �����.
   if(buyOrders + sellOrders == 0) 
     {
       Alert("�������� ������� �� ������� ", Symbol(), " �������");
       return; // ���������� ������ �������
     }      
   // ����� �� ����� ����� - ������ ������ ���-���� ����
   if(buyOrders*sellOrders != 0) // �� �������� ������ ���� � �������� Buy ���� Sell, 
                                 // �� �� � ������
      {
        Alert("����� �� ������� ", Symbol(), " ", buyOrders, " ������� � ������� � ", 
              sellOrders, "������� � �������. ������ ����������");
        return; // ���������� ������ �������
      }
   // ����� �� ����� ����� - ������ ����� ������ ������ ������ ����  
   if(buyOrders > 0)
     {
       intLots = 2*10*buyOrders;  // ����� ������� ���������� �����      
       reversLot = NormalizeDouble(intLots / 10, 1); // �������� ����� ������������ ������
       RefreshRates();
       ticket = OrderSend(Symbol(), OP_SELL, reversLot, Bid, Slippage, 0, 0, 
                          "revers order", 0, 0, Red);
       if(ticket < 0)
         {
           Alert("�� ������� ������� ����� SELL ", Symbol(), " ", reversLot, " at ", 
                 Bid, "  ������ ", GetLastError());
         }
     }
//----
   if(sellOrders > 0)
     {
       intLots = 2*10*sellOrders; // ����� ������� ���������� �����      
       reversLot = NormalizeDouble(intLots / 10, 1); // �������� ����� ������������ ������
       RefreshRates();
       ticket = OrderSend(Symbol(), OP_BUY, reversLot, Ask, Slippage, 0, 0, 
                          "revers order", 0, 0, Blue);
       if(ticket < 0)
         {
           Alert("�� ������� ������� ����� SELL ", Symbol(), " ", reversLot, " at ", 
                 Ask, "  ������ ", GetLastError());
         }
     }
//----
   return(0);
  }
//+------------------------------------------------------------------+