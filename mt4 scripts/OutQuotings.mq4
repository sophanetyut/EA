//+------------------------------------------------------------------+
//|                                                  OutQuotings.mq4 |
//|                                           ��� ����� �. aka KimIV |
//|                                              http://www.kimiv.ru |
//|                                                                  |
//|    28.01.2006                                                    |
//|  ������ ��� �������� ��������� �� ��������� ������ � ����.       |
//+------------------------------------------------------------------+
#property copyright "��� ����� �. aka KimIV"
#property link      "http://www.kimiv.ru"
#property show_inputs

extern datetime BeginDate = D'2005.11.11';
extern datetime EndDate   = D'2005.12.21';
extern string   Separator = ",";

//+------------------------------------------------------------------+
//| script program start function                                    |
//+------------------------------------------------------------------+
void start()
{
  int    i, b=0, bb=0, eb;
  string comm, st;
  string fn=Symbol()+Period()+" "+
         TimeToStr(BeginDate, TIME_DATE)+"-"+
         TimeToStr(EndDate, TIME_DATE)+".csv";

  for (i=Bars; i>0; i--)
  {
    if (Time[i]>=BeginDate && Time[i]<=EndDate)
    {
      if (bb==0) bb=i;       // ��������� ����� ������� ����
      st=TimeToStr(Time[i], TIME_DATE)+Separator+
         TimeToStr(Time[i], TIME_MINUTES)+Separator+
         DoubleToStr(Open[i], Digits)+Separator+
         DoubleToStr(High[i], Digits)+Separator+
         DoubleToStr(Low[i], Digits)+Separator+
         DoubleToStr(Close[i], Digits)+Separator+
         DoubleToStr(Volume[i], 0);
      WritingLineInFile(fn, st);
      b++;
      eb=i;        // ��������� ����� ���������� ����
    }
  }

  comm="������: "+TimeToStr(Time[bb], TIME_DATE|TIME_MINUTES)+"\n";
  comm=comm+"�����: "+TimeToStr(Time[eb], TIME_DATE|TIME_MINUTES)+"\n";
  comm=comm+"��������� �����: "+DoubleToStr(b, 0);

  Comment(comm);
}

//+------------------------------------------------------------------+
//| ������ ������ � ����                                             |
//+------------------------------------------------------------------+
void WritingLineInFile(string FileName, string text)
{
  int file_handle=FileOpen(FileName, FILE_READ|FILE_WRITE, " ");

	if (file_handle>0)
	{
		FileSeek(file_handle, 0, SEEK_END);
		FileWrite(file_handle, text);
		FileClose(file_handle);
	}
}
//+------------------------------------------------------------------+

