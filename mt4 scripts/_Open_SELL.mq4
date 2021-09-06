//+------------------------------------------------------------------+
//|                                                   _Open_SELL.mq4 |
//|                                           "������� ��� ��������" |
//|             ������ ��������� SELL �� ���������� ����� FreeMargin |
//|                           Bookkeeper, 2006, yuzefovich@gmail.com |
//+------------------------------------------------------------------+
#property copyright ""
#property link      ""
#property show_inputs // ���� ���� ������� ������ �������� � ��������
//+------------------------------------------------------------------+
extern double Share      = 0.1;  // �������� ����� FreeMargin �� ����:
                                 // = 0 ������� ����������� �����
                                 // = 1 ������� �� ���� ����
extern int    DistSL     = 35;   // ���������� �� SL
extern int    DistTP     = 35;   // ���������� �� TP
extern int    Slippage   = 5;    // ���������������
extern bool   StopLoss   = true; // ������� ��� ���
extern bool   TakeProfit = true; // ������� ��� ���
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void start() 
  {
    int    ticket;
    double SL = 0, TP = 0, Stake, StepDgts;
    double Step = MarketInfo(Symbol(), MODE_MINLOT);   
    int    Dgts = MarketInfo(Symbol(), MODE_DIGITS);     
//----
    if(AccountFreeMargin() < Step*1000*Ask)
      {
        Alert("Open_SELL: No maney...");
        return;
      }
//----
    if(Share > 1.0) 
        Share = 1.0;  // ����� �� ������ ������ ������
//----
    if(Share < 0) 
        Share = 0;   
//----
    if(Step < 0.1) 
        StepDgts = 2;
    else
      {
        if(Step < 1.0) 
            StepDgts = 1;
        else 
            StepDgts = 0;
      }
//----
    Stake = NormalizeDouble(AccountFreeMargin()*Share / 1000 / Ask, StepDgts);
    if(AccountFreeMargin() < Stake*1000*Bid)       // ���������� ������ � �����
        Stake = NormalizeDouble(Stake - Step, StepDgts); // ������ ����� �� �����  
    //���� ���������� ����� ���� ����� ������ ���������� ����������� ����,
    //���� ����� ������� �� ����������� ���
    if(Stake < Step) 
        Stake = Step;
    if(StopLoss == true) 
        SL = Ask + DistSL*Point;
    if(TakeProfit == true) 
        TP = Bid - 2*DistTP*Point;
    ticket = OrderSend(Symbol(), OP_SELL, Stake, Bid, Slippage, NormalizeDouble(SL,Dgts),
                       NormalizeDouble(TP,Dgts), "", 0, 0, CLR_NONE);
    if(ticket <= 0) 
        Alert("Error Open_SELL: ", GetLastError()); 
    return(0);
  }
//+------------------------------------------------------------------+