//+------------------------------------------------------------------+
//|                                                         Info.mq4 |
//|                                      Copyright � 2008, EvgeTrofi |
//+------------------------------------------------------------------+
#property copyright "Copyright � 2008, EvgeTrofi"

#include <WinUser32.mqh>

int start()
{
 if (!IsConnected())
 {
  MessageBox("����� � �������� ����������� ��� ��������\t","��������!",MB_OK|MB_ICONERROR);
  return(-1);
 }
 string str2;
 string str="������������\t\t���������\t\t��������\t��.���.\t\n\n";
 str=StringConcatenate(str,"�����\t\t\tSPREAD\t\t\t",MarketInfo(Symbol(),MODE_SPREAD),"\t\t�������\t\n\n");
 str=StringConcatenate(str,"���. ����\t\tSTOPLEVEL\t\t",MarketInfo(Symbol(),MODE_STOPLEVEL),"\t\t�������\t\n\n");
 str=StringConcatenate(str,"1 ��� * 1 ����� =\t\tTICKVALUE\t\t",MarketInfo(Symbol(),MODE_TICKVALUE),"\t\t",AccountCurrency(),"\t\n\n");
 switch(MarketInfo(Symbol(),MODE_SWAPTYPE))
 {
  case 0:
   str2="�������";
   break;
  case 1:
   str2=Symbol();
   break;
  case 2:
   str2="%";
   break;
  case 3:
   str2=AccountCurrency();
   break;
 }
 str=StringConcatenate(str,"���� �������\t\tSWAPLONG\t\t",MarketInfo(Symbol(),MODE_SWAPLONG),"\t\t",str2,"\t\n\n");
 str=StringConcatenate(str,"���� �������\t\tSWAPSHORT\t\t",MarketInfo(Symbol(),MODE_SWAPSHORT),"\t\t",str2,"\t\n\n");
 str=StringConcatenate(str,"����������� ���\t\tMINLOT\t\t\t",MarketInfo(Symbol(),MODE_MINLOT),"\n\n");
 str=StringConcatenate(str,"��� ����\t\tLOTSTEP\t\t\t",MarketInfo(Symbol(),MODE_LOTSTEP),"\n\n");
 double MaxLot = MarketInfo(Symbol(),MODE_MAXLOT);
 if(MaxLot>AccountFreeMargin()*0.99/MarketInfo(Symbol(),MODE_MARGINREQUIRED))//��� 0.99 - ����������� ������
    MaxLot=AccountFreeMargin()*0.99/MarketInfo(Symbol(),MODE_MARGINREQUIRED);
 str=StringConcatenate(str,"������������ ��� = AccountFreeMargin() / MARGINREQUIRED = ",MaxLot,"\n\n");
 str=StringConcatenate(str,"��� �� �������� 100 ������� = AccountFreeMargin() / 100 / TICKVALUE = ",AccountFreeMargin()/100/MarketInfo(Symbol(),MODE_TICKVALUE),"\n\n");
 
 if(MarketInfo(Symbol(),MODE_TRADEALLOWED)==0)
  str2="���������";
 else
  str2="���������";
 str=StringConcatenate(str,"\n�������� �� ����������� ",Symbol()," ",str2,"\n\n");
 MessageBox(str,"���������� �� ����������� "+Symbol(),MB_OK|MB_ICONINFORMATION);
 
 return(0);
}

VALUE = ",AccountFreeMargin()/100/MarketInfo(Symbol(),MODE_TICKVALUE),"\n\n");
 
 if(MarketInfo(Symbol(),MODE_TRADEALLOWED)==0)
  str2="���������";
 else
  str2="���������";
 str=StringConcatenate(str,"\n�������� �� ����������� ",Symbol()," ",str2,"\n\n");
 MessageBox(str,"���������� �� ����������� "+Symbol()+" �� "+TimeToStr(TimeCurrent(),TIME_DATE|TIME_SECONDS),MB_OK|MB_ICONINFORMATION);
 
 return(0);
}


