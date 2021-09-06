//+----------------------------------------------------------------------------+
//|                                                        GroupOfHistory.mq4  |
//|                                                    ��� ����� �. aka KimIV  |
//|                                                       http://www.kimiv.ru  |
//|    27.02.2006  ����������� ������� ����� (Group of History).               |
//|  ������ ��������� ������ ������ ������ �� ������� �����, ����������        |
//|  ������ �� ���������� � ���������� �������� � ���������� � ����.           |
//|  02.02.2006  ������� ������� ������ � �������� �������� ����������         |
//|              �������� ��������� gohGroup:                                  |
//|              1-���, 2-������, 3-�����, 4-�����������                       |
//|  06.02.2006  �� ������� alextur'� ������� ������� �����.                   |
//|  15.12.2006  �� ������� Alfa ������� ������� � ����� ������� ���������     |
//|              ������ � ����� ���������� ���������.                          |
//+----------------------------------------------------------------------------+
#property copyright "��� ����� �. aka KimIV"
#property link      "http://www.kimiv.ru"
#property show_inputs
//------- ������� ��������� ������� --------------------------------------------
extern string gohOutFileName = "GroupOfHistory.csv";
extern int    gohGroup       = 3; // 1-���, 2-������, 3-�����, 4-�����������
extern int    gohProfit      = 1; // 1-������, 2-������ ������
//+----------------------------------------------------------------------------+
//|  script program start function                                             |
//+----------------------------------------------------------------------------+
void start()
  {
   int      i;           // ������� ������
   int      n;           // ������ �������� �������, ����� ������
   int      ot;          // ��� ��������
   int      ks[];        // ���������� ������
   string   nm[];        // ������������ ������
   double   op[], ou[];  // ����� ������� � ������
   double   mb[];        // �������� �������
   double   dd[];        // ��������, ������
   double   td[];        // ������� ��������
   datetime od[];        // ���� ������� ��������� ������
   datetime cd[];        // ���� ���������� ���������
   string   st, text="";
   FileDelete(gohOutFileName);
   switch (gohGroup)
     {
       case 1: text = "���";         
               break;
       case 2: text = "������";      
               break;
       case 3: text = "�����";       
               break;
       case 4: text = "�����������"; 
               break;
     }
   text = text + ";����.����.;���.����.;���.��.;������;�����;������;������;���������";
   WritingLineInFile(gohOutFileName, text);
   for(i = 0; i < HistoryTotal(); i++)
     {
       if(OrderSelect(i, SELECT_BY_POS, MODE_HISTORY))
         {
           ot = OrderType();
           if(ot == OP_BUY || ot == OP_SELL)
             {
               switch(gohGroup)
                 {
                   case 1: if(ot == OP_BUY) 
                               st = "Buy"; 
                           else 
                               st = "Sell"; 
                           break;
                   case 2: st = OrderSymbol(); 
                           break;
                   case 3: if(OrderMagicNumber() == 0) 
                               st = ""; 
                           else 
                               st = OrderMagicNumber(); 
                           break;
                   case 4:  st = StrTran(OrderComment(), "[sl]", "");
                            st = StrTran(st, "[tp]", "");
                            break;
                 }
               n = ArrayFind(nm, st);
               if(n + 1 > ArraySize(op))
                 {
                   ArrayResize(op, n + 1);
                   ArrayResize(ou, n + 1);
                   ArrayResize(mb, n + 1);
                   ArrayResize(dd, n + 1);
                   ArrayResize(td, n + 1);
                   ArrayResize(ks, n + 1);
                   ArrayResize(od, n + 1);
                   ArrayResize(cd, n + 1);
                 }
               if(OrderProfit() > 0)
                 {
                   if(gohProfit == 2) 
                       op[n] += OrderProfit();
                   else 
                       op[n] += MathAbs(OrderOpenPrice() - OrderClosePrice()) / 
                                        MarketInfo(OrderSymbol(), MODE_POINT);
                 } 
               else 
                 {
                   if(gohProfit == 2) 
                       ou[n] += OrderProfit();
                   else 
                       ou[n] -= MathAbs(OrderOpenPrice() - OrderClosePrice()) / 
                                        MarketInfo(OrderSymbol(), MODE_POINT);
                 }
               if(gohProfit == 2) 
                   op[n] += OrderSwap();
               if(mb[n] < op[n] + ou[n]) 
                   mb[n] = op[n] + ou[n];
               td[n] = mb[n] - op[n] - ou[n];
               if(dd[n] < td[n]) 
                   dd[n] = td[n];
               if(od[n] == 0) 
                   od[n] = OrderOpenTime();
               if(cd[n] < OrderCloseTime()) 
                   cd[n] = OrderCloseTime();
               ks[n]++;
             }
         }
     }
   for(i = 0; i < ArraySize(nm); i++)
     {
       text = nm[i] + ";" + StrTran(DoubleToStr(op[i] + ou[i], 2), ".", ",") + ";" +
              StrTran(DoubleToStr(op[i], 2), ".", ",") + ";" +
              StrTran(DoubleToStr(ou[i], 2), ".", ",") + ";" +
              StrTran(DoubleToStr(dd[i], 2), ".", ",") + ";" +
              StrTran(DoubleToStr(td[i], 2), ".", ",") + ";" +
              StrTran(DoubleToStr(ks[i], 0), ".", ",") + ";" +
              TimeToStr(od[i], TIME_DATE) + ";" +
              TimeToStr(cd[i], TIME_DATE);
       WritingLineInFile(gohOutFileName, text);
     }
   text = "����������� ���� " + gohOutFileName;
   Comment(text); 
   Print(text);
  }
//+----------------------------------------------------------------------------+
//|  ���� ������� ������� ���� STRING � ���������� ��� ������.                 |
//|  ��� ���������� �������� �������� ��������� �����.                         |
//|  ���������:                                                                |
//|    nm - ������ ��������� ���� STRING (��������� �� ������)                |
//|    st - ������� �������� ��������                                          |
//+----------------------------------------------------------------------------+
int ArrayFind(string& nm[], string st)
  {
   int i, p;
   for(i = 0; i < ArraySize(nm); i++)
     {
       if(StringLen(st) > 0)
         {
           p = StringFind(nm[i], st);
           if(p >= 0) 
               return(i);
         } 
       else 
           if(StringLen(nm[i]) == 0) 
               return(i);
     }
   i = ArrayResize(nm, ArraySize(nm) + 1) - 1;
   nm[i] = st;
   return(i);
  }
//+----------------------------------------------------------------------------+
//|  ������ ���������                                                          |
//|  ���������:                                                                |
//|    str     - ��������� ������, � ������� ������������ ������               |
//|    strfrom - ���������� ���������                                          |
//|    strto   - ���������� ���������                                          |
//+----------------------------------------------------------------------------+
string StrTran(string str, string strfrom, string strto)
  {
   int    n;
   string outstr = "", tempstr;
   for(n = 0; n < StringLen(str); n++)
     {
       tempstr = StringSubstr(str, n, StringLen(strfrom));
       if(tempstr == strfrom)
         {
           outstr = outstr + strto;
           n = n + StringLen(strfrom) - 1;
         } 
       else 
           outstr = outstr + StringSubstr(str, n, 1);
     }
   return(outstr);
  }
//+----------------------------------------------------------------------------+
//|  ������ ������ � ����                                                      |
//+----------------------------------------------------------------------------+
void WritingLineInFile(string FileName, string text)
  {
   int file_handle = FileOpen(FileName, FILE_READ|FILE_WRITE, " ");
	  if(file_handle > 0)
	    {
		     FileSeek(file_handle, 0, SEEK_END);
		     FileWrite(file_handle, text);
		     FileClose(file_handle);
	    }
  }
//+----------------------------------------------------------------------------+

