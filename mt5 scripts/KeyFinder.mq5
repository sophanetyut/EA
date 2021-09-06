//+------------------------------------------------------------------+
//|                                                    KeyFinder.mq5 |
//|                                                   Trofimov Pavel |
//|                                               trofimovpp@mail.ru |
//+------------------------------------------------------------------+
#property copyright "Trofimov Pavel"
#property link      "trofimovpp@mail.ru"
#property version   "1.00"
#property description "��������! ������ �������� ���������� � �������� �����!"
#property description "������������ ������������� �������� ��� ��������� �� ����� 1000 �����!"
#property script_show_inputs
//--- input parameters
input int      MinDimesion=5;//����������� ����������� �����
input int      MaxBars=300;//���������� �������������� �����
//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
void OnStart()
  {
//---
//�������� ����������� ������� ��� �������������� ���������� �����
   int SMaxBars=Bars(Symbol(),0),iMaxBars=MaxBars;
   if(SMaxBars<MaxBars) 
     {
      iMaxBars=SMaxBars;
      Comment("�������� MaxBars ����� ������� �������."+"\n"+"��� �������� ����� ������������ "+IntegerToString(SMaxBars)+" �����.");
     };
   int clean=CleanChart();//������ ������ ��� ��������� ����������
   MqlRates  rates_array[];
   string Com="";
   int iCod=CopyRates(Symbol(),Period(),0,iMaxBars,rates_array);//���������� ��������� �������
   iCod=iCod-1;//������ ������������� �������� � �������
   Com="�������...�����!";
   Comment(Com);
   if(iCod>0)
     {
      FindUpKeyPoints(iCod,rates_array);//����� ������� �������� �����
      Com=Com+"\n"+"���������� ������� �����."+"\n";
      Comment(Com);
      FindLowKeyPoints(iCod,rates_array);//����� ������ �������� �����
      Comment("��������� ���������");
     }
   else Comment("����������� ���� ��� ���������!!!");
  }
//+------------------------------------------------------------------+
//|                  ����� ������� �������� �����                    |
//+------------------------------------------------------------------+
void FindUpKeyPoints(int temp_iCod,MqlRates &temp_rates[])
  {
   int HD=1;
   for(int i=temp_iCod-MinDimesion; i>(MinDimesion-1); i--)//���� �� ����� �� ��������� - MinDimension �� �������� + MinDimension
     {
      HD=getHighDimension(temp_rates,i,temp_iCod);//�������� ����������� �����
      if((HD>=MinDimesion) || (HD==-1))
        {//������� ����� ���� �������� ��� ������� MinDimension
         string Ob_Name="KF_Label"+IntegerToString(i);
         if(HD!=-1)
           {
            ObjectCreate(0,Ob_Name,OBJ_TEXT,0,temp_rates[i].time,temp_rates[i].high);
            ObjectSetInteger(0,Ob_Name,OBJPROP_ANCHOR,0,ANCHOR_LOWER);
            ObjectSetString(0,Ob_Name,OBJPROP_TEXT,0,IntegerToString(HD));
            ObjectSetInteger(0,Ob_Name,OBJPROP_COLOR,clrRed);
           }
         else 
           { //���� �� ����� ���������� ����������� ��������� �������
            ObjectCreate(0,Ob_Name,OBJ_ARROW,0,temp_rates[i].time,temp_rates[i].high);
            ObjectSetInteger(0,Ob_Name,OBJPROP_ARROWCODE,0,159);
            ObjectSetInteger(0,Ob_Name,OBJPROP_ANCHOR,0,ANCHOR_BOTTOM);
            ObjectSetInteger(0,Ob_Name,OBJPROP_COLOR,clrRed);
           };
        };
     };
  }
//+------------------------------------------------------------------+
//|                    ����� ������ �������� �����                   |
//+------------------------------------------------------------------+   
void FindLowKeyPoints(int temp_iCod,MqlRates &temp_rates[])
  {
   int LD=1;//�������������� ����������� �����
   bool iCreate;
   for(int i=temp_iCod-MinDimesion; i>(MinDimesion-1); i--)
     {
      LD=getLowDimension(temp_rates,i,temp_iCod);
      if((LD>=MinDimesion) || (LD==-1))
        {
         string Ob_Name="KF_Label"+IntegerToString(i)+"_1";//���������� �� ����� ��� ��� � ��� ����� ���� ��������� �������
         if(LD!=-1) 
           {
            iCreate=ObjectCreate(0,Ob_Name,OBJ_TEXT,0,temp_rates[i].time,temp_rates[i].low);
            if(iCreate) 
              {
               ObjectSetInteger(0,Ob_Name,OBJPROP_ANCHOR,0,ANCHOR_UPPER);
               ObjectSetString(0,Ob_Name,OBJPROP_TEXT,0,IntegerToString(LD));
               ObjectSetInteger(0,Ob_Name,OBJPROP_COLOR,clrGreen);
              }
            else Comment("�� ���� ������� ������");
           }
         else 
           {
            iCreate=ObjectCreate(0,Ob_Name,OBJ_ARROW,0,temp_rates[i].time,temp_rates[i].low);
            if(iCreate) 
              {
               ObjectSetInteger(0,Ob_Name,OBJPROP_ARROWCODE,0,159);
               ObjectSetInteger(0,Ob_Name,OBJPROP_ANCHOR,0,ANCHOR_TOP);
               ObjectSetInteger(0,Ob_Name,OBJPROP_COLOR,clrGreen);
              }
            else Comment("�� ���� ������� ������");
           };
        };
     };
  }
//+------------------------------------------------------------------+
//|                ����������� ����������� ������� �����             |
//+------------------------------------------------------------------+
int getHighDimension(MqlRates &tmpRates[],int tmp_i,int tmp_iCod)
  {
   int k=1;
   while((tmpRates[tmp_i].high>tmpRates[tmp_i+k].high) && (tmpRates[tmp_i].high>tmpRates[tmp_i-k].high) && ((tmp_i+k)<(tmp_iCod)) && ((tmp_i-k)>0)) k++;
   if(((tmp_i+k)==tmp_iCod) || ((tmp_i-k)==0)) k=-1;
   return(k);
  }
//+------------------------------------------------------------------+
//|                ����������� ����������� ������ �����              |
//+------------------------------------------------------------------+
int getLowDimension(MqlRates &tmpRates[],int tmp_i,int tmp_iCod)
  {
   int k=1;
   while((tmpRates[tmp_i].low<tmpRates[tmp_i+k].low) && (tmpRates[tmp_i].low<tmpRates[tmp_i-k].low) && ((tmp_i+k)<(tmp_iCod)) && ((tmp_i-k)>0)) k++;
   if(((tmp_i+k)==tmp_iCod) || ((tmp_i-k)==0)) k=-1;
   return(k);
  }
//+-------------------------------------------------------------------------------+
//| ������� ������� �� ��������� �������� �������� � ������ ���������� ���������� |
//+-------------------------------------------------------------------------------+
int CleanChart()
  {
   string Label="KF_Label";
   int obj_total=ObjectsTotal(0,0,-1),n=0;
   for(int obj=obj_total-1; obj>=0; obj--)
     {
      string objname=ObjectName(0,obj,0,-1);
      if(StringFind(objname,Label)>=0) ObjectDelete(0,objname);
      n++;
     }
   return(n);
  }
//+------------------------------------------------------------------+
