//+------------------------------------------------------------------+
//|                                        ind_FlatEfficiency_v1.mq4 |
//|                                                                * |
//|                                                                * |
//+------------------------------------------------------------------+
#property copyright "Integer"
#property link      "for-good-letter@yandex.ru"
#property show_inputs 

extern int MaxSpread=8; // �� ����������� ������� �� ������� ������ ��������������
extern string SymbolsFile="symbols.set"; // ��� ����� �� ������� �������� (������ ���������� � experts/files)
extern string OutputFile="flateficiensy.txt"; // ��� ����� ��� ���������� �����������
extern int iPeriod=10000; // ���������� ������������ �����

/*

   �������������:

   1. ��������� � experts/files ���� symbols.set � ������� �������� ���� ������ 
      ����� (������ ������ � ���� ������ ����� - ����� �������� - ��������� ���).
   2. ��������� ������ �� ������� ������ ������� ���������� ����������. 
      ������ �������� ��� ���������� ������ �� ���� ��������, �� �� ������
      ���������� ���������� ������������� � iPeriod ���������� � ������ �������, 
      ����� ������������� ��������� ������ �������.
   3. �������� � experts/files ���� _[TimeFrame]_flateficiensy.txt

*/

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {

//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit(){



   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start(){

      OutputFile=fTimeFrameName(Period())+"_"+OutputFile;

      string AllSymbols[];
      double Result[];
      int TickSum[];
      double BarSize[];     
      double BarSizeRelative[];  
      double Deviation[];
      int Reiting[];                 
       
      int h=FileOpen(SymbolsFile,FILE_CSV|FILE_READ);
         if(h>0){
            while(!FileIsEnding(h)){
               string str=FileReadString(h);
                  if(str!=""){
                     //if(iBars(str,0)>10000)
                     if(ND0(MarketInfo(str,MODE_SPREAD))<=MaxSpread){
                        ArrayResize(AllSymbols,ArraySize(AllSymbols)+1);
                        AllSymbols[ArraySize(AllSymbols)-1]=str;
                     }
                  }
            }
         }
         else{
            Alert("��� ����� "+SymbolsFile);
            return(0);
         }
         
      ArrayResize(Result,ArraySize(AllSymbols));
      ArrayResize(TickSum,ArraySize(AllSymbols));   
      ArrayResize(BarSize,ArraySize(AllSymbols));         
      ArrayResize(BarSizeRelative,ArraySize(AllSymbols));
      ArrayResize(Deviation,ArraySize(AllSymbols));
      ArrayResize(Reiting,ArraySize(AllSymbols));      
            
      int BarC=0;
      
      datetime daytimes[];
      bool err=false;
         while(!IsStopped()){
            err=false;            
               for(int i=0;i<ArraySize(AllSymbols);i++){   
                  ArrayCopySeries(daytimes,MODE_TIME,AllSymbols[i],0);
                     if(GetLastError()==4066 || iClose(AllSymbols[i],0,0)==0){
                        Comment("...��� ���������� ������ "+AllSymbols[i]);
                        Sleep(1000);
                        err=true;
                        break;
                     }         
               }   
               if(!err){
                  Comment("...������ OK!");
                  Sleep(400);
                  Comment("...�������");
                  break;
               }
         }
      
      if(err)return(0);
      
      BarC=iBars(AllSymbols[0],0);
         for(i=1;i<ArraySize(AllSymbols);i++){
            BarC=MathMin(BarC,iBars(AllSymbols[i],0));   
         }
         
      iPeriod=MathMin(iPeriod+2,BarC);
      iPeriod-=2;
      
         for(i=0;i<ArraySize(AllSymbols);i++){         
            Result[i]=0;
            TickSum[i]=0;
            BarSize[i]=0;        
            Deviation[i]=0;    
               for(int j=1;j<=iPeriod;j++){
                  Result[i]+=MathAbs(iClose(AllSymbols[i],0,j)-iClose(AllSymbols[i],0,j+1));
                  TickSum[i]+=iVolume(AllSymbols[i],0,j);
                  BarSize[i]+=iHigh(AllSymbols[i],0,j)-iLow(AllSymbols[i],0,j+1);
                  Deviation[i]+=MathPow(iClose(AllSymbols[i],0,j)-iMA(AllSymbols[i],0,iPeriod,0,0,0,1),2);
               }
            //Deviation[i]/=iPeriod;
            Deviation[i]=MathSqrt(Deviation[i]/iPeriod);
            //Alert(AllSymbols[i]," ",Deviation[i]);
            Result[i]/=
                  (iHigh(AllSymbols[i],0,iHighest(AllSymbols[i],0,MODE_HIGH,iPeriod,1))-
                  iLow(AllSymbols[i],0,iLowest(AllSymbols[i],0,MODE_LOW,iPeriod,1)));
            BarSize[i]/=iPeriod;
            BarSize[i]/=MarketInfo(AllSymbols[i],MODE_POINT);  
            BarSizeRelative[i]= BarSize[i]/MarketInfo(AllSymbols[i],MODE_SPREAD);
         }

      h=FileOpen(OutputFile,FILE_CSV|FILE_WRITE,"\t");
         
         if(h>0){
         
         
            FileWrite(h,"�����:");
            FileWrite(h,"");
            
               for(i=0;i<ArraySize(AllSymbols);i++){  
                  FileWrite(h,AllSymbols[i],MarketInfo(AllSymbols[i],MODE_SPREAD));
               }
                         
            FileWrite(h,"");               
               
         
            FileWrite(h,"�������������� "+iPeriod+" (�����) "+fTimeFrameName(Period()));   

            FileWrite(h,"");           
            FileWrite(h,"������ | ������������� ����� | ����� ����� | ������� ������ ���� | ������� ������ ����/����� | ��������");
            FileWrite(h,"");     
            
            //==========================================================================================================================
            
            FileWrite(h,"������������� �� \"������������� �����\"");
            FileWrite(h,"");             
            
               for(i=0;i<ArraySize(AllSymbols);i++){
                  for(j=0;j<ArraySize(AllSymbols);j++){
                     if(Result[i]>Result[j]){ // �� ���
                        fArrayChangeValues_string(AllSymbols,i,j); 
                        fArrayChangeValues_double(Result,i,j);  
                        fArrayChangeValues_int(TickSum,i,j);  
                        fArrayChangeValues_double(BarSize,i,j);
                        fArrayChangeValues_double(BarSizeRelative,i,j); 
                        fArrayChangeValues_double(Deviation,i,j);        
                        fArrayChangeValues_int(Reiting,i,j);                                                                            
                     }
                  }            
               }            
         
               for(i=0;i<ArraySize(AllSymbols);i++){
                  Reiting[i]+=i;
                  FileWrite(h,AllSymbols[i],DS3(Result[i]),TickSum[i],DS0(BarSize[i]),DS3(BarSizeRelative[i]),DS5(Deviation[i]));
               }
               
            //==========================================================================================================================
               
            FileWrite(h,""); 
            FileWrite(h,"������������� �� \"����� �����\"");
            FileWrite(h,"");                   
            
               for(i=0;i<ArraySize(AllSymbols);i++){
                  for(j=0;j<ArraySize(AllSymbols);j++){
                     if(TickSum[i]>TickSum[j]){ // �� ���
                        fArrayChangeValues_string(AllSymbols,i,j); 
                        fArrayChangeValues_double(Result,i,j);  
                        fArrayChangeValues_int(TickSum,i,j);
                        fArrayChangeValues_double(BarSize,i,j);
                        fArrayChangeValues_double(BarSizeRelative,i,j);   
                        fArrayChangeValues_double(Deviation,i,j);  
                        fArrayChangeValues_int(Reiting,i,j);                                                                                                              
                     }
                  }            
               }                        
         
               for(i=0;i<ArraySize(AllSymbols);i++){
                  Reiting[i]+=i;               
                  FileWrite(h,AllSymbols[i],DS3(Result[i]),TickSum[i],DS0(BarSize[i]),DS3(BarSizeRelative[i]),DS5(Deviation[i]));
               }               
               
            //==========================================================================================================================
               
            FileWrite(h,"");       
            FileWrite(h,"������������� �� \"������� ������ ����\"");
            FileWrite(h,""); 
                        
               for(i=0;i<ArraySize(AllSymbols);i++){
                  for(j=0;j<ArraySize(AllSymbols);j++){
                     if(BarSize[i]>BarSize[j]){ // �� ���
                        fArrayChangeValues_string(AllSymbols,i,j); 
                        fArrayChangeValues_double(Result,i,j);  
                        fArrayChangeValues_int(TickSum,i,j);
                        fArrayChangeValues_double(BarSize,i,j);    
                        fArrayChangeValues_double(BarSizeRelative,i,j);  
                        fArrayChangeValues_double(Deviation,i,j);  
                        fArrayChangeValues_int(Reiting,i,j);                                                                                                            
                     }
                  }            
               }                        
         
               for(i=0;i<ArraySize(AllSymbols);i++){
                  Reiting[i]+=i;              
                  FileWrite(h,AllSymbols[i],DS3(Result[i]),TickSum[i],DS0(BarSize[i]),DS3(BarSizeRelative[i]),DS5(Deviation[i]));
               } 
               
            //==========================================================================================================================
               
            FileWrite(h,"");       
            FileWrite(h,"������������� �� \"������� ������ ����/�����\"");
            FileWrite(h,""); 
            
               for(i=0;i<ArraySize(AllSymbols);i++){
                  for(j=0;j<ArraySize(AllSymbols);j++){
                     if(BarSizeRelative[i]>BarSizeRelative[j]){ // �� ���
                        fArrayChangeValues_string(AllSymbols,i,j); 
                        fArrayChangeValues_double(Result,i,j);  
                        fArrayChangeValues_int(TickSum,i,j);
                        fArrayChangeValues_double(BarSize,i,j);    
                        fArrayChangeValues_double(BarSizeRelative,i,j);  
                        fArrayChangeValues_double(Deviation,i,j);  
                        fArrayChangeValues_int(Reiting,i,j);                                                                                                            
                     }
                  }            
               }                        
         
               for(i=0;i<ArraySize(AllSymbols);i++){
                  Reiting[i]+=i;              
                  FileWrite(h,AllSymbols[i],DS3(Result[i]),TickSum[i],DS0(BarSize[i]),DS3(BarSizeRelative[i]),DS5(Deviation[i]));
               }   
               
            //==========================================================================================================================
               
            FileWrite(h,"");       
            FileWrite(h,"������������� �� \"��������\"");
            FileWrite(h,""); 
            
               for(i=0;i<ArraySize(AllSymbols);i++){
                  for(j=0;j<ArraySize(AllSymbols);j++){
                     if(Deviation[i]>Deviation[j]){ // �� ���
                        fArrayChangeValues_string(AllSymbols,i,j); 
                        fArrayChangeValues_double(Result,i,j);  
                        fArrayChangeValues_int(TickSum,i,j);
                        fArrayChangeValues_double(BarSize,i,j);    
                        fArrayChangeValues_double(BarSizeRelative,i,j);  
                        fArrayChangeValues_double(Deviation,i,j);  
                        fArrayChangeValues_int(Reiting,i,j);                                                                                                           
                     }
                  }            
               }                        
         
               for(i=0;i<ArraySize(AllSymbols);i++){
                  Reiting[i]+=i;
                  FileWrite(h,AllSymbols[i],DS3(Result[i]),TickSum[i],DS0(BarSize[i]),DS3(BarSizeRelative[i]),DS5(Deviation[i]));
               }                                               
               


            //==========================================================================================================================
               
            FileWrite(h,"");       
            FileWrite(h,"�������");
            FileWrite(h,""); 
            
               for(i=0;i<ArraySize(AllSymbols);i++){
                  for(j=0;j<ArraySize(AllSymbols);j++){
                     if(Reiting[i]<Reiting[j]){ // �� ���
                        fArrayChangeValues_string(AllSymbols,i,j); 
                        fArrayChangeValues_double(Result,i,j);  
                        fArrayChangeValues_int(TickSum,i,j);
                        fArrayChangeValues_double(BarSize,i,j);    
                        fArrayChangeValues_double(BarSizeRelative,i,j);  
                        fArrayChangeValues_double(Deviation,i,j);  
                        fArrayChangeValues_int(Reiting,i,j);                                                                                                           
                     }
                  }            
               }                        
         
               for(i=0;i<ArraySize(AllSymbols);i++){
                  Reiting[i]+=i;
                  FileWrite(h,AllSymbols[i],DS3(Result[i]),TickSum[i],DS0(BarSize[i]),DS3(BarSizeRelative[i]),DS5(Deviation[i]),"R - "+Reiting[i],"(����� - "+DS0(MarketInfo(AllSymbols[i],MODE_SPREAD))+")");
               }                                               
               
         }
         else{
            Alert("������ ����� "+OutputFile);
            return(0);
         }
      Comment("");
      Alert("������ "+iPeriod+" (�����). ��. ���� "+OutputFile);

   return(0);
}
//+------------------------------------------------------------------+
string DS5(double v){return(DoubleToStr(v,5));}
string DS3(double v){return(DoubleToStr(v,3));}
string DS0(double v){return(DoubleToStr(v,0));}
double ND0(double v){return(NormalizeDouble(v,0));}

string fTimeFrameName(int arg){

   // fTimeFrameName();

   int v;
      if(arg==0){
         v=Period();
      }
      else{
         v=arg;
      }
      switch(v){
         case 0:
            return("0");
         case 1:
            return("M1");
         case 5:
            return("M5");                  
         case 15:
            return("M15");
         case 30:
            return("M30");             
         case 60:
            return("H1");
         case 240:
            return("H4");                  
         case 1440:
            return("D1");
         case 10080:
            return("W1");          
         case 43200:
            return("MN1");
         default:
            return("Wrong TimeFrame");          
      }
}


void fArrayChangeValues_int(int & aArray[], int aIndex1,int aIndex2){
   //fArrayChangeValues_int(,,);
   int tmp;
   tmp=aArray[aIndex1];
   aArray[aIndex1]=aArray[aIndex2];
   aArray[aIndex2]=tmp;
}

void fArrayChangeValues_string(string & aArray[], int aIndex1, int aIndex2){
   string tmp;
   tmp=aArray[aIndex1];
   aArray[aIndex1]=aArray[aIndex2];
   aArray[aIndex2]=tmp;
}
void fArrayChangeValues_double(double & aArray[], int aIndex1, int aIndex2){
   double tmp;
   tmp=aArray[aIndex1];
   aArray[aIndex1]=aArray[aIndex2];
   aArray[aIndex2]=tmp;
}

