//+------------------------------------------------------------------+
//|                                             SaveHistoryToHST.mq5 |
//|                                                        avoitenko |
//|                        https://login.mql5.com/ru/users/avoitenko |
//+------------------------------------------------------------------+
#property copyright "avoitenko"
#property link      "https://login.mql5.com/ru/users/avoitenko"
#property version   "1.00"

#property script_show_inputs

#define OFFLINE_HEADER_SIZE 148 // LONG_VALUE + 64 + 12 + 4 * LONG_VALUE + 13 * LONG_VALUE
#define OFFLINE_RECORD_SIZE 44  // 5 * DOUBLE_VALUE + LONG_VALUE

input uint DATA_COUNT=5000;// ������� ������� � �����

MqlRates rates[];
//+------------------------------------------------------------------+
//|   OnStart()                                                      |
//+------------------------------------------------------------------+
void OnStart()
  {
//--- �������� ��������� DATA_COUNT
   if(DATA_COUNT==0)
     {
      printf("������, ������� ����� �������� DATA_COUNT (%d), ���������� ��������: >0",DATA_COUNT);
      return;
     }
//--- �������� ��������� ������
   uint count=CopyRates(_Symbol,_Period,0,DATA_COUNT,rates);
   if(count<DATA_COUNT)
     {
      printf("������������ ������ � ������� (%d), ���������� %d �����",count,DATA_COUNT);
      return;
     }

   int period=PeriodSeconds(_Period)/60;

//--- ���������� ����� HST �����
   if(!WriteOfflineHeader("!"+_Symbol,period,_Digits)) return;

//--- ���������� ������ HST �����
   for(uint i=0;i<DATA_COUNT;i++)
     {
      if(!WriteOfflineBar("!"+_Symbol,period,0,rates[i]))return;
     }
//--- ����� ���� � ������������ �����
   Print("���� � ������������ �����: ",TerminalInfoString(TERMINAL_DATA_PATH),"MQL5\\Files\\",OfflineFileName("!"+_Symbol,period));
  }
//+------------------------------------------------------------------+
bool WriteOfflineHeader(string symbol,int period,int digits)
//+------------------------------------------------------------------+
  {
   int    version=400;
   string c_copyright="(C)opyright 2011, Andrey Voytenko";
   int    i_unused[13];

   ResetLastError();
   int F=FileOpen(OfflineFileName(symbol,period),FILE_BIN|FILE_ANSI|FILE_WRITE);
   if(F==INVALID_HANDLE)
     {
      Print(__FUNCTION__," �������� FileOpen ��������, ������ ",GetLastError());
      return(false);
     }

   FileSeek(F,0,SEEK_SET);
   FileWriteInteger(F,version,INT_VALUE);
   FileWriteString(F,c_copyright,64);
   FileWriteString(F,symbol,12);
   FileWriteInteger(F,period,INT_VALUE);
   FileWriteInteger(F,digits,INT_VALUE);
   FileWriteInteger(F,(int)TimeCurrent(),INT_VALUE); // timesign
   FileWriteInteger(F,(int)TimeCurrent(),INT_VALUE); // last_sync
   FileWriteArray(F,i_unused,0,13);

   FileClose(F);
   return(true);
  }
//+------------------------------------------------------------------+
bool WriteOfflineBar(string symbol,int period,int bars_back,MqlRates &data)
//+------------------------------------------------------------------+
  {
   ResetLastError();
   int F=FileOpen(OfflineFileName(symbol,period),FILE_BIN|FILE_ANSI|FILE_READ|FILE_WRITE);
   if(F==INVALID_HANDLE)
     {
      Print(__FUNCTION__," �������� FileOpen ��������, ������ ",GetLastError());
      return(false);
     }

   int position=bars_back*OFFLINE_RECORD_SIZE;
   FileSeek(F,-position,SEEK_END);

   if(FileTell(F)>=OFFLINE_HEADER_SIZE)
     {
      FileWriteInteger(F,(int)data.time,INT_VALUE);
      FileWriteDouble(F, data.open);
      FileWriteDouble(F, data.low);
      FileWriteDouble(F, data.high);
      FileWriteDouble(F, data.close);
      FileWriteDouble(F, data.tick_volume);
     }

   FileClose(F);
   return(true);
  }
//+------------------------------------------------------------------+
string OfflineFileName(string symbol,int period)
//+------------------------------------------------------------------+
  {
   return(StringSubstr(symbol,0,12)+IntegerToString(period)+".hst");
  }
//+------------------------------------------------------------------+
