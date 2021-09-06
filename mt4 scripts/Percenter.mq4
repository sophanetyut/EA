//+------------------------------------------------------------------+
//|                                                    Percenter.mq4 |
//|                              Copyright � 2008, Nazariy S. (WWer) |
//|                         E-mail: nazariy@i.ua, Skype: nazariy1309 |
//+------------------------------------------------------------------+
//| ������ ������������ ��� ���������� �������, �������, ����������� |
//| � ���������� ����������� ���������.                              |
//| ������ ������� �������� ����� � ����� ������� � ������� �����,   |
//| ������ ���������� �� ������� ��� ��� ����������/���������.       |
//| ������ ���������� ��������� �������� ���������� method:          |
//|   1 - ������� ���������� ������                                  |
//|   2 - ������� ���������� ������                                  |
//|   3 - ����������� ���������� ������                              |
//|   4 - ���� �����                                                 |
//| ��������� ��� �������� �� ������ ����� �����:                    |
//|   http://ru.wikipedia.org/wiki/����������_������                 |
//+------------------------------------------------------------------+
#property copyright   "Copyright � 2008, Nazariy S. (WWer)"
#property link        "E-mail: nazariy@i.ua, Skype: nazariy1309"
#property show_inputs

#define E 2.71828182845904523536

extern double i;        // ���������� ������, ���������� � �����
extern int    n,        // ����� �������� ����������
              m,        // ����� �������� ���������� (��� method=3)
              method=2; // ������ ���������� ���������

//+------------------------------------------------------------------+
//| �-��� Percent() ��� ���������� ���������.                        |
//+------------------------------------------------------------------+
double Percent(double i, int n, int m=-1, int method=2)
  {
   double res=0.0;
   switch(method) {
     case 1:  res=n*i+1;
              break;
     case 2:  res=MathPow(1+i,n);
              break;
     case 3:  res=MathPow(1+i/m,m*n);
              break;
     case 4:  res=MathPow(E,i*n);
              break;
     default: return(0);
    }
   return(res);
  }

//+------------------------------------------------------------------+
//| script program start function                                    |
//+------------------------------------------------------------------+
int start()
  {
//----
   Alert(DoubleToStr(Percent(i,n,m,method),8));
//----
   return(0);
  }
//+------------------------------------------------------------------+