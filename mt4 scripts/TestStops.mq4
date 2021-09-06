//+------------------------------------------------------------------+
//|                                                    TestStops.mq4 |
//|                      Copyright � 2006, MetaQuotes Software Corp. |
//|                                        http://www.metaquotes.net |
//+------------------------------------------------------------------+
#property copyright "Copyright � 2006, MetaQuotes Software Corp."
#property link      "http://www.metaquotes.net"

#include "..\libraries\stdlib.mq4"
//+------------------------------------------------------------------+
//| script program start function                                    |
//+------------------------------------------------------------------+
int start()
  { 
   int    ticket;                                         // ����� ������ 
   int    digits   =MarketInfo(Symbol(),MODE_DIGITS);     // �������� ���������� ������
   double volume   =MarketInfo(Symbol(),MODE_MINLOT);     // �������� ����������� ���
   double stoplevel=MarketInfo(Symbol(),MODE_STOPLEVEL);  // �������� ����������� ������
//---- ������� ���������
   Print("����������� ���: ",volume," ����������� ������: ",stoplevel);
//---- ��������� ������� ������� �� ����� � ����������� ������ 
//---- �������������� StopLoss � TakeProfit, �������� �� ����
//---- ����������, ��� ����������� ����� � �������� � stoplevel �������
   ticket=OrderSend(Symbol(),OP_BUY,volume,Ask,2,
                    NormalizeDouble(Bid-stoplevel*Point,digits),   // SL
                    NormalizeDouble(Bid+stoplevel*Point,digits));  // TP
   if(ticket<1) 
     {
      Print("��� 1: ������ ",ErrorDescription(GetLastError())); 
      return(-1); 
     }
//---- ������� ������ ��� �������� ����� � ������� �������� ���������
   if(OrderSelect(ticket,SELECT_BY_TICKET)==false)
     {
      Print("��� 2: ������ ",ErrorDescription(GetLastError())); 
      return(-2);
     }
   RefreshRates();  // ������� �������� ���������
//---- ��������� �������������� StopLoss, �� ������ TakeProfit
//---- ��������� ����-���� �� 2 ����� (����� � �� ����������, ���� ����� ��������)
//---- ����������, ��� TakeProfit �� �����������, ���� �� �� ���������
   if(OrderModify(ticket,OrderOpenPrice(),OrderStopLoss()-2*Point,OrderTakeProfit(),0)==false)
     {
      Print("��� 3: ������ ",ErrorDescription(GetLastError())); 
      return(-3);
     }
//---- ������ �����, ������ �� ����������, ������ ���������� � ���������� ����
   if(OrderModify(ticket,OrderOpenPrice(),0,0,0)==false)
     {
      Print("��� 4: ������ ",ErrorDescription(GetLastError())); 
      return(-4);
     }
   RefreshRates();  // ������� �������� ���������
//---- ��������� ����� ��������� ����� �������� � �����
//---- ����������, ��� StopLoss � TakeProfit ��������� ��������
   if(OrderModify(ticket,OrderOpenPrice(),
                  NormalizeDouble(Bid-stoplevel*Point,digits),   // SL
                  NormalizeDouble(Bid+stoplevel*Point,digits),   // TP
                  0)==false)
     {
      Print("��� 5: ������ ",ErrorDescription(GetLastError())); 
      return(-3);
     }
//---- ���� ��������
   Print("���� ������� ��������!");
   return(0);
  }
//+------------------------------------------------------------------+