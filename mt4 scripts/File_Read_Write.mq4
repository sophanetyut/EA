//+------------------------------------------------------------------+
//|                                              File Read Write.mq4 |
//|                      Copyright � 2008, MetaQuotes Software Corp. |
//|                                       http://www.metaquotes.net/ |
//+------------------------------------------------------------------+
#property copyright "Copyright � 2008, MetaQuotes Software Corp."
#property link      "http://www.metaquotes.net/"

// ��������� ��� ������� _lopen
#define OF_READ               0
#define OF_WRITE              1
#define OF_READWRITE          2
#define OF_SHARE_COMPAT       3
#define OF_SHARE_DENY_NONE    4
#define OF_SHARE_DENY_READ    5
#define OF_SHARE_DENY_WRITE   6
#define OF_SHARE_EXCLUSIVE    7

#import "kernel32.dll"
   int _lopen  (string path, int of);
   int _lcreat (string path, int attrib);
   int _llseek (int handle, int offset, int origin);
   int _lread  (int handle, string buffer, int bytes);
   int _lwrite (int handle, string buffer, int bytes);
   int _lclose (int handle);
#import

// _lopen  : ���p����� ��������� ����. ����p�����: ��������� �����.
// _lcreat : ������� ��������� ����.   ����p�����: ��������� �����.
// _llseek : ������������� ��������� � ���p���� �����. ����p�����: 
// ����� �������� ���������.
// _lread  : ��������� �� ���p����� ����� ��������� ����� ����. 
// ����p�����: ����� ��������� ����; 0 - ���� ����� �����.
// _lwrite : ���������� ������ �� ����p� � ��������� ����. ����p�����: 
// ����� ���������� ����.
// _lclose : ���p����� ��������� ����. ����p�����: 0.
// � ������ ����������� ����p����� ��� ������� ���������� �������� 
// HFILE_ERROR=-1.
 
// path   : ��p���, ��p��������� ���� � ��� �����.
// of     : ������ ��������.
// attrib : 0 - ������ ��� ������; 1 - ������ ������; 2 - ��������� ��� 
// 3 - ���������.
// handle : �������� ���������.
// offset : ����� ����, �� ����p�� ��p��������� ���������.
// origin : ��������� ��������� ����� � ���p������� ��p��������: 0 - 
// ���p�� �� ������; 1 - � ������� �������; 2 - ����� �� ����� �����.
// buffer : �p���������/������������ ����p.
// bytes  : ����� ����������� ����.
 
// ������� �������� (�������� of):
// int OF_READ            =0; // ������� ���� ������ ��� ������
// int OF_WRITE           =1; // ������� ���� ������ ��� ������
// int OF_READWRITE       =2; // ������� ���� � ������ ������/������
// int OF_SHARE_COMPAT    =3; // ��������� ���� � ������ ������ 
// ����������� �������. � ���� ������ ����� ������� ����� ������� ������ 
// ���� ����� ���������� ���. ��� ������� ������� ���� ���� � ����� ������
// ������, ������� ���������� HFILE_ERROR.
// int OF_SHARE_DENY_NONE =4; // ��������� ���� � ������ ������ ������� 
// ��� ������� �� ������/������ ������ ���������. ��� ������� �������� 
// ������� ����� � ������ OF_SHARE_COMPAT, ������� ���������� HFILE_ERROR.
// int OF_SHARE_DENY_READ =5; // ��������� ���� � ������ ������ ������� � 
// �������� �� ������ ������ ���������. ��� ������� �������� ������� ����� 
// � ������� OF_SHARE_COMPAT �/��� OF_READ ��� OF_READWRITE, ������� 
// ���������� HFILE_ERROR.
// int OF_SHARE_DENY_WRITE=6; // ���� �����, ������ � �������� �� ������.
// int OF_SHARE_EXCLUSIVE =7; // ������ �������� � ������ ��������� �� 
// ������ � ����� ����� � ������� ������/������. ���� � ���� ������ ����� 
// ������� ������ ���� ��� (������� ���������). ��� ��������� ������� 
// �������� ����� ����� ���������.
//+------------------------------------------------------------------+
//|   ��������� ���� � ������� ������ � ����������                   |
//+------------------------------------------------------------------+
string ReadFile (string path) 
  {
    int handle=_lopen (path,OF_READ);           
    if(handle<0) 
      {
        Print("������ �������� ����� ",path); 
        return ("");
      }
    int result=_llseek (handle,0,0);      
    if(result<0) 
      {
        Print("������ ��������� ���������" ); 
        return ("");
      }
    string buffer="";
    string char1="x";
    int count=0;
    result=_lread (handle,char1,1);
    while(result>0) 
      {
        buffer=buffer+char1;
        char1="x";
        count++;
        result=_lread (handle,char1,1);
     }
    result=_lclose (handle);              
    if(result<0)  
      Print("������ �������� ����� ",path);
    return (buffer);
  }
 
//+------------------------------------------------------------------+
//|  �������� ���������� ������ �� ���������� ����                   |
//+------------------------------------------------------------------+
void WriteFile (string path, string buffer) 
  {
    int count=StringLen (buffer); 
    int result;
    int handle=_lopen (path,OF_WRITE);
    if(handle<0) 
      {
        handle=_lcreat (path,0);
        if(handle<0) 
          {
            Print ("������ �������� ����� ",path);
            return;
          }
        result=_lclose (handle);
     }
    handle=_lopen (path,OF_WRITE);               
    if(handle<0) 
      {
        Print("������ �������� ����� ",path); 
        return;
      }
    result=_llseek (handle,0,0);          
    if(result<0) 
      {
        Print("������ ��������� ���������"); 
        return;
      }
    result=_lwrite (handle,buffer,count); 
    if(result<0)  
        Print("������ ������ � ���� ",path," ",count," ����");
    result=_lclose (handle);              
    if(result<0)  
        Print("������ �������� ����� ",path);
  }
//+------------------------------------------------------------------+
//| script program start function                                    |
//+------------------------------------------------------------------+
int start()
  {
//----
    string buffer=ReadFile("C:\\Text.txt");
    int count=StringLen(buffer);
    Print("��������� ����:",count);
    WriteFile("C:\\Text2.txt",buffer);   
//----
   return(0);
  }
//+------------------------------------------------------------------+