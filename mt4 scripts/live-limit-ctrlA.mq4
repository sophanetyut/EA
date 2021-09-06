//+------------------------------------------------------------------+
//|                                             live-limit-ctrlA.mq4 |
//|                                Copyright � 2009, Borys Chekmasov |
//|                                     http://uatrader.blogspot.com |
//|                                     version 2.3                  |
//+------------------------------------------------------------------+
//| ������ ������������ ��� ���������� �������� ����������� �� ����� |
//| �������. �������� �� ������� ����� � ������ "GO!". ���������� �� |
//| ��   �������,   �   ��������   �����������   ������������   ����.| 
//| ��� ��������� ������ ������� ������� ������� ��������� �������   |
//| ������������ ����� � ������������ ������ (MoneyRisk, � ��������) |  
//| � ������������ ������ � ����� (ProfitLoss) �� ���������� �������.|
//+------------------------------------------------------------------+
#property copyright "Copyright � 2009, Borys Chekmasov"
#property link      "http://uatrader.blogspot.com"


double Lots = 0.1; //������ ����
double MoneyRisk = 30; //���� �� ������ (� ��������)
double ProfitLoss=3;//��������� ������� ������� � ������� �����

double open_level, stop_level, profit_level;
double symbol_mode, symbol_tik_sise,symbol_tikk_value,symbol_lotsize,leverage_lev ;
double delta_stop;


int start()
  {
//----

symbol_mode = MarketInfo (Symbol(),MODE_PROFITCALCMODE);
symbol_tik_sise = MarketInfo (Symbol(),MODE_TICKSIZE);
symbol_tikk_value = MarketInfo (Symbol(),MODE_TICKVALUE);
symbol_lotsize = MarketInfo (Symbol(),MODE_LOTSIZE);
leverage_lev = AccountLeverage();

// ��������� ����
 switch (symbol_mode)
 {
 case 0: // Forex, � ������ ������� �� �������� �������� � ������ ����� �������� ����
   if (StringSubstr(Symbol(), 3, 3)=="USD") delta_stop = MoneyRisk/(Lots*symbol_lotsize);
   if (StringSubstr(Symbol(), 0, 3)=="USD") delta_stop =(Bid*MoneyRisk)/(Lots*symbol_lotsize);
   if (StringFind(Symbol(), "USD", 0) == -1) // ���������
   {
    if (MarketInfo("USD"+StringSubstr(Symbol(), 3, 3),MODE_BID)>0) delta_stop = (MarketInfo("USD"+StringSubstr(Symbol(), 3, 3),MODE_BID)*MoneyRisk)/(Lots*symbol_lotsize);
    if (MarketInfo(StringSubstr(Symbol(), 0, 3)+"USD",MODE_BID)>0) delta_stop = MoneyRisk/(Lots*symbol_lotsize*MarketInfo(StringSubstr(Symbol(), 0, 3)+"USD",MODE_BID));
   }    
 break;
 case 1: //CFD �����, �������� �� �����������!!
   delta_stop = MoneyRisk/(Lots*symbol_lotsize);
 break;
 default: // �����, �������� �� �����������!!
    delta_stop = (MoneyRisk*symbol_tik_sise)/(Lots*symbol_tikk_value);
 break;
 }

if (ObjectFind("GO!")>0)
{
//���������� �������:
open_level = ObjectGet("GO!", OBJPROP_PRICE1);
if (open_level>Bid) OrderSend(Symbol(),OP_SELLLIMIT,Lots,open_level,0,(open_level+delta_stop),(open_level-(delta_stop*ProfitLoss)),"",777,0,Red);
if (open_level<Bid) OrderSend(Symbol(),OP_BUYLIMIT,Lots,open_level,0,(open_level-delta_stop),(open_level+(delta_stop*ProfitLoss)),"",777,0,Red);
 }
//----
   return(0);
  }
//+------------------------------------------------------------------+

