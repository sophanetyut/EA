//+------------------------------------------------------------------+
//|                                                 ZigzagPoints.mq4 |
//|                      Copyright � 2007, MetaQuotes Software Corp. |
//|                                        http://www.metaquotes.ru/ |
//+------------------------------------------------------------------+
#property copyright "Copyright � 2007, MetaQuotes Software Corp."
#property link      "http://www.metaquotes.ru/"

#property show_inputs

extern string startDate="2007.10.01";
extern string stopDate="2007.12.16";

//+------------------------------------------------------------------+
//| script program start function                                    |
//+------------------------------------------------------------------+
int start()
  {
//----
   if (Period()!=PERIOD_H1) 
      {
      Alert("��������� �� ��������!!!");
      return;
      }
      
   int i,first,next,firstPointBar,lastPointBar;
   firstPointBar=iBarShift(NULL,0,StrToTime(startDate));
   lastPointBar=iBarShift(NULL,0,StrToTime(stopDate));
   // ����� ������ �����
   // firstPointBar=
   double breaking=0;
   i=firstPointBar;
   while (breaking==0.0)
      {
      breaking=iCustom(NULL,0,"Zigzag",12,5,3,0,i);
      i++;
      }
   i--;   
   first=i;
   Print("Time=",TimeToStr(Time[first]),"   price=",breaking);
   
   breaking=0.0;
   i=first-1;
   while (breaking==0.0)
      {
      breaking=iCustom(NULL,0,"Zigzag",12,5,3,0,i);
      i--;
      }
   i++;   
   next=i;
   Print("Time=",TimeToStr(Time[next]),"   price=",breaking);

   double a,b;
   double y1,y2;
   y1=iCustom(NULL,0,"Zigzag",12,5,3,0,first);
   y2=iCustom(NULL,0,"Zigzag",12,5,3,0,next);
   a=(y1-y2)/(first-next);
   b=y1-a*first;
   
   double startPrice=a*firstPointBar+b;
   
//***********************************************************************************************************
   // ����� ������ �����
   // lastPointBar=
   breaking=0;
   i=lastPointBar;
   while (breaking==0.0)
      {
      breaking=iCustom(NULL,0,"Zigzag",12,5,3,0,i);
      i++;
      }
   i--;   
   first=i;
   Print("Time=",TimeToStr(Time[first]),"   price=",breaking);
   
   breaking=0.0;
   i=first-1;
   while (breaking==0.0)
      {
      breaking=iCustom(NULL,0,"Zigzag",12,5,3,0,i);
      i--;
      }
   i++;   
   next=i;
   Print("Time=",TimeToStr(Time[next]),"   price=",breaking);

   y1=iCustom(NULL,0,"Zigzag",12,5,3,0,first);
   y2=iCustom(NULL,0,"Zigzag",12,5,3,0,next);
   a=(y1-y2)/(first-next);
   b=y1-a*first;

   double stopPrice=a*lastPointBar+b;
   Print("������ �����   : �����=",TimeToStr(Time[firstPointBar]),"  price=",startPrice);
   Print("��������� �����: �����=",TimeToStr(Time[lastPointBar]),"  price=",stopPrice);

   //  � ��� ���� ���������� ������ � ��������� �����. ������ ����� ��������� ����� ����
   
   double Summ; //  ����� � �������
   double lastpeak=startPrice;
   double currZZ;
   for (i=firstPointBar;i>=lastPointBar;i--)
      {
      currZZ=iCustom(NULL,0,"Zigzag",12,5,3,0,i);
      if (currZZ!=0)
         {
         Summ+=MathAbs(currZZ-lastpeak);
         lastpeak=currZZ;
         }
      }
   double point=MarketInfo(Symbol(),MODE_POINT);
   Summ/=point;
   Print("����� ������� ����� ��������� Zigzag\'a �� �������� ������� �������� ",DoubleToStr(Summ,0),"  �������");      
//----
   return(0);
  }
//+------------------------------------------------------------------+