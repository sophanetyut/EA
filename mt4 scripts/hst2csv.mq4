//+------------------------------------------------------------------+
//|                                                      hst2csv.mq4 |
//|                              Copyright � 2007, Kiriyenko Dmitriy |
//|                                      http://kiriyenko.moikrug.ru |
//+------------------------------------------------------------------+
#property copyright "Copyright � 2007, Kiriyenko Dmitriy"
#property link      "http://kiriyenko.moikrug.ru"
//----
#property show_inputs
//----
#include <WinUser32.mqh>
#include <stdlib.mqh>
//----
#define FILE_NAME "hst2csv.ex4"
#define WRONG_FILE_EXT "�������� ��� �����: ����� �������� ������ *.hst �����"
#define WRONG_FILE_EXT_HDR "������ ������� ������"
//----
extern string input_file_name = "EURUSD5.hst";
extern bool   input_file_in_history = true;
//----
int hst_handle;
int err;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int start()
  {
// ����������� ���� �������� �����
   if(file_ext(input_file_name) != "hst")
     {
       MessageBox(WRONG_FILE_EXT,WRONG_FILE_EXT_HDR, MB_OK | MB_ICONSTOP);
       return(-3);
     }
// �������� �������� �����
   if(input_file_in_history)
       hst_handle = FileOpenHistory(input_file_name, FILE_BIN | FILE_READ);
   else
       hst_handle = FileOpen(input_file_name, FILE_BIN | FILE_READ);
   err = GetLastError();
   if(hst_handle < 0 || err > 0) 
       return(error_out(err, "�������� �������� �����"));
// ������ ���������
   FileSeek(hst_handle, 68, SEEK_SET);
   err = GetLastError();
   if(err > 0) 
       return(error_out(err, "�������� �� ������� ����� � �������"));
   string hst_symbol = FileReadString(hst_handle, 12);
   int hst_period = FileReadInteger(hst_handle, LONG_VALUE);
   err = GetLastError();
   if(err > 0) 
       return (error_out(err, "������ ��������� *.hst �����"));
   FileSeek(hst_handle, 64, SEEK_CUR);
   err = GetLastError();
   if(err > 0) 
       return(error_out(err, "�������� �� ������� ����� � ������ ���������"));
// ������� ������� �������� ����
   string csv_file_name = StringConcatenate(hst_symbol, hst_period, ".csv");
   int csv_handle = FileOpen(csv_file_name, FILE_CSV | FILE_WRITE);
   err = GetLastError();
   if(csv_handle < 0 || err > 0) 
       return(error_out(err,"�������� ��������� �����"));
// ���� ������� ���� �� ����������
   while(!FileIsEnding(hst_handle))
     {
       err = GetLastError();
       if(err > 0) 
           return(error_out(err, "�������� EOF ��� ��������� �����"));
       // ���������� ������ �� �������� �����
       int bar_time = FileReadInteger(hst_handle, LONG_VALUE);
       double bar_open = FileReadDouble(hst_handle, DOUBLE_VALUE);
       double bar_low = FileReadDouble(hst_handle, DOUBLE_VALUE);
       double bar_high = FileReadDouble(hst_handle, DOUBLE_VALUE);
       double bar_close = FileReadDouble(hst_handle, DOUBLE_VALUE);
       double bar_volume = FileReadDouble(hst_handle, DOUBLE_VALUE);
       err = GetLastError();
       if(err == 4099) 
           break; // ���� ���� ����������, ��������� ����
       if(err > 0) 
           return(error_out(err,"������ �� �������� �����"));
       // �������������� ������� � ������
       string bar_time_str = StringConcatenate(TimeToStr(bar_time, TIME_DATE), ";",
                                               TimeToStr(bar_time, TIME_MINUTES));
       // ���������� ������ � �������� ����
       FileWrite(csv_handle, bar_time_str, bar_open, bar_high, bar_low, 
                 bar_close, bar_volume);
       err = GetLastError();
       if(err > 0) 
           return(error_out(err,"������ � ��������� ����"));
     }
   err = GetLastError();
   if(err > 0) 
       return(error_out(err, "�������� EOF ��� ��������� �����"));
// �������� ������
   FileClose(hst_handle);
   FileClose(csv_handle);
   err = GetLastError();
   if(err > 0) 
       return(error_out(err, "�������� ������"));
   MessageBox("� ����� ��������� MT4: \Experts\files\ ������ ����:\n\n" + csv_file_name,
              "�������������� ����� ������� ���������", MB_OK | MB_DEFBUTTON1);
   err = GetLastError();
   if(err > 0) 
       return(error_out(err, "����� ��������� � ���������� ������"));
   return(0);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int error_out(int err, string where)
  {
    if(err == 0) 
        return;
    string message = StringConcatenate("������ �", err, ":\"", 
                                       ErrorDescription(err), "\"\n",
                                       "�������� ��� ���������� �������� \"", 
                                       where,"\"");
    string caption = StringConcatenate("�������� ������ � ������: \"", 
                                       FILE_NAME, "\"!");
    MessageBox(message,caption,MB_OK | MB_ICONSTOP);
    return(err);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string file_ext(string file_name)
  {
    string result = StringSubstr(file_name, 
                                 StringLen(input_file_name) - 3, 3);
    int err = GetLastError();
    if(err > 0) 
        return(error_out(err, "��������� �������� ������-����� �����"));
    return (result);
  }
//+------------------------------------------------------------------+

