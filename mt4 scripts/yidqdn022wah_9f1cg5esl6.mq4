//+------------------------------------------------------------------+
//|   21 ������� 2008 �.                            ������ �����.mq4 |
//|                                                     Yuriy Tokman |
//|  ICQ# 481971287                            yuriytokman@gmail.com |
//+------------------------------------------------------------------+
#property copyright "Yuriy Tokman"
#property link      "yuriytokman@gmail.com  ICQ# 481971287 "

#property show_inputs

extern double ������_������� = 10; // ������ ����

//+------------------------------------------------------------------+
//| script program start function                                    |
//+------------------------------------------------------------------+
int start()
  {
//----
   double Prots = ������_�������/100;
   double Lots=MathFloor(AccountFreeMargin()*Prots/MarketInfo(Symbol(),MODE_MARGINREQUIRED)
               /MarketInfo(Symbol(),MODE_LOTSTEP))*MarketInfo(Symbol(),MODE_LOTSTEP);// ���� 
   Alert ("����.����� ", Lots);
//----
   return(0);
  }
//+------------------------------------------------------------------+