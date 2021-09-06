//+------------------------------------------------------------------+
//|                                                DailyResearch.mq4 |
//|                                          Copyright � 2007, DRKNN |
//|                                                    drknn@mail.ru |
//+------------------------------------------------------------------+
#property copyright "Copyright � 2007, DRKNN"
#property link      "drknn@mail.ru"
#property show_inputs
extern int TakeProfit=10;
extern int TaimFame=1440;
//+------------------------------------------------------------------+
//| script program start function                                    |
//+------------------------------------------------------------------+
int start(){
  
  string SMB;
  double SPR;
  int Bar=iBars(SMB,TaimFame);
  double Dlina=0,Dodzh=0,Bych=0,Medv=0,MezhduTenjami=0;
  double TenUp=0,TenDown=0;
  double Up=0,Down=0;
  double O,C,H,L,O1,C1,H1,L1;
  double TwooBych=0,TwooMedw=0,TwooDodzh=0;
  double Nesovpadenie=0;
  double Profit=0;
 
  // ---- ���������� ������ -----------
  SMB=Symbol();
  SPR=MarketInfo(SMB,MODE_SPREAD);
  
  for(int i=Bar;i>0;i--){
    
    O=iOpen(SMB,TaimFame,i); 
    C=iClose(SMB,TaimFame,i);
    H=iHigh(SMB,TaimFame,i);
    L=iLow(SMB,TaimFame,i);
    
     
     
    //------ ������� ���� ������ ����� --------
    if(i<Bar){
      
      O1=iOpen(SMB,TaimFame,i+1); 
      C1=iClose(SMB,TaimFame,i+1);
      H1=iHigh(SMB,TaimFame,i+1);
      L1=iLow(SMB,TaimFame,i+1);
      
      if((O1-C1)>0 && (O-C)>0){// ��� ��������� �������
        TwooMedw++;
         
      }
      if((C1-O1)>0 && (C-O)>0){// ��� ������ �������
        TwooBych++;
      }
      if((C1==O1)&&(C==O)){ // ��� ����� �������
        TwooDodzh++;
      }
      if ( 
          ((O1-C1)>0 && (O-C)<0) || ((C1-O1)>0 && (C-O)<0) || ((C1==O1)&&(C<O)) || ((C1==O1)&&(C>O)) || ((C1<O1)&&(C==O))
          || ((C1>O1)&&(C==O))
         ){//������������ ����� ���� �������� ����
           Nesovpadenie++;
           if((O1-C1)>0 && (O-C)<0){ // ���������� "������-�����"
             if((O-L)>=(TakeProfit+SPR)*Point){//���� ������ ����, ��� ��� ��������� ����
              Profit++;
             }
           }
           
           if((O1-C1)<0 && (O-C)>0){// ���������� "�����-������"
             if((H-O)>=(TakeProfit+SPR)*Point){// �������� ������� ����, ��� ��� ��������� ����
               Profit++;
             }
           }
           if((O1-C1)>0 && O==C){ // ���������� "������-����"
             if((O-L)>=(TakeProfit+SPR)*Point){//���� ������ ����, ��� ��� ��������� ����
              Profit++;
             }
           }
           
           if((O1-C1)<0 && O==C){// ���������� "�����-����"
             if((H-O)>=(10+SPR)*Point){// �������� ������� ����, ��� ��� ��������� ����
               Profit++;
             }
           }
           
           
      }    
          
    }
    
   
    //----- ���� ���� ---------
    if(O>C){
      Dlina=Dlina+(O-C)/Point;
      Medv++;
      TenUp=TenUp+(H-O)/Point;
      Up++;
      TenDown=TenDown+(C-L)/Point;
      Down++;
    }
    if(O<C){
      Dlina=Dlina+(C-O)/Point;
      Bych++;
      TenUp=TenUp+(H-C)/Point;
      Up++;
      TenDown=TenDown+(O-L)/Point;
      Down++;
      
    }
    if(O==C){
      Dodzh++;
      TenUp=TenUp+(H-C)/Point;
      Up++;
      TenDown=TenDown+(O-L)/Point;
      Down++;
       
    }  
    // ------ ���� ���� -------
    MezhduTenjami=MezhduTenjami+(H-L)/Point;
  
  }
  // --------- ��������������� ������� ---------
  Dlina=Dlina/(Bar);//������� ����� �����
  MezhduTenjami=MezhduTenjami/(Bar);//������� ���������� ����� ��� � ��� �����
  TenUp=TenUp/Up;
  TenDown=TenDown/Down;
  
  Alert("������ �������� ��������������� ���������� ����-�����!!!!!");
  Alert("���� ���������� ����� - ����, �� �� �������!");
  Alert("��� ������������ ����� ����������� ������ ",TakeProfit," pt ������� = ",Profit/Nesovpadenie*100," %  (� ������ ������)"); 
  Alert("������������ ����� ���� �������� ���� ������ ",Nesovpadenie," ���. ����������� ��������� = ",Nesovpadenie/Bar*100," %");
  Alert("���������� *��� �����* ������ ",TwooDodzh," ���. ����������� ��������� = ",TwooDodzh/Bar*100," %");
  Alert("���������� *��� ��������* ������ ",TwooMedw," ���. ����������� ��������� = ",TwooMedw/Bar*100," %");
  Alert("���������� *��� �����* ������ ",TwooBych," ���. ����������� ��������� = ",TwooBych/Bar*100," %");
  Alert("������� ������ ���� = ",TenDown," pt");
  Alert("������� ������� ���� = ",TenUp," pt"); 
  Alert("������� ���������� ����� x�� � ��� ����� = ",MezhduTenjami," pt");
  Alert("������� ����� ���� ����� = ",Dlina," pt"); 
  Alert("������ = ",Dodzh,". ����������� ��������� = ",Dodzh/Bar*100," %");
  Alert("��������� ���� = ",Medv,". ����������� ��������� = ",Medv/Bar*100," %");
  Alert("������ ���� = ",Bych,". ����������� ��������� = ",Bych/Bar*100," %");
  Alert("�� ��������� ",TaimFame," ����� ���������������� ",Bar," ����. �� ��� :"); 
  Alert("============  ",SMB,"  ============");
  return(0);
}
//+------------------------------------------------------------------+