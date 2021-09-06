//+------------------------------------------------------------------+
//|                                        holes_history_data_v2.mq4 |
//|                                         Copyright � 2005 Bagadul |
//|                                             bagbagadul@yandex.ru |
//+------------------------------------------------------------------+
#property copyright "Copyright � 2005 Bagadul"
#property link      "bagbagadul@yandex.ru"
#property show_inputs
/* 
������ ��� �������� � ������ ������� ������������� ���� (����� "����") � ������� (������� ����), ���������� 
�� ������, ������������ � ���, �������� �� ���� ������������ � ������������ ��� ������������� ��������, 
������� ��������� ��������� �������� - H4, ��� ������� ���������� ������ �������� ��� (������� � ����������� - 48 �����), 
��������� ������� ��� ������� ������ ��� ���������. ��� �������� ������ �� �������, � ���� ������������ 
������, ��� ����� ������: (������ ����� ����� �������� � ��������� �������)
1. ���������� ������������� ����� �� ����������� (M1,5,15,30), ������� ��� ����� 
   ������������ ��� ���� 
2. ���������� ������������� ����� (����������� ��������), ������� ��� ������ �� 
   ��������  (�� ��������� 20 �����); 
��� �������� ���� �������� 1 � 2, ��� ��������� ���� ��� ����� ������� ���������. 
3. ���������� ������������� ������, ������� ��� ����� ������������ ��� ���

����� ��������� ��� ������. 
��� ���������, � ���� ��� �������� ������� �����������, ���������� ��������� � *.txt ����.
��� ������ �� MT4 build 182.

!!! ���� ������ ������� "�������" ��� ������������ ������ ��� ����� ��������, �� ��������� ������ 
    ����� ��������� ���������� � �����, ���������� ����������� (***������� �������� ���).  

*/
//+-------------------------------------------------------------------+ 
// ���������� ������������� ����� �� ������ �����������, ������� ��� ����� ������������
extern string Filter = "����������� ��������";
extern bool bars_ignore     = true; // ��������� 
extern int  bars_ignore_M1  = 3;    // (�� ���������)
extern int  bars_ignore_M5  = 3;
extern int  bars_ignore_M15 = 2;
extern int  bars_ignore_M30 = 2;
//+------------------- 
// ���������� ������������� �����, ������� ��� ������ �� ��������
extern int breakup_min = 20; // ����������� �������� (������ ���� > 0 � >= bars_min)
// ���������� ������������� ������ �� ������ �����������, ������� ��� ����� ������������
extern bool gap_ignore      = true; // ���������
extern int  gap_min         = 5;    // (�� ���������)
//+-------------------------------------------------------------------+ 
string begin_week_sessions = "00:00"; // ����� ������ ��������� ������ (��:��) (�� ���������)
bool   new_file = true;
int    handle;
//+-------------------
#include <WinUser32.mqh>
//+-------------------
int start()
   {

//+------------------------------
string time_frame;   // ���������
int    duration_bar; // ������������ ���� � ���.
int    hole_min;     // ���������� ������������� �����, ������� ��� ����� ������������ 

switch ( Period() )
        {
         case 1:     time_frame = "M1";  duration_bar = 60;    hole_min = bars_ignore_M1;  break;
         case 5:     time_frame = "M5";  duration_bar = 300;   hole_min = bars_ignore_M5;  break;
         case 15:    time_frame = "M15"; duration_bar = 900;   hole_min = bars_ignore_M15; break;
         case 30:    time_frame = "M30"; duration_bar = 1800;  hole_min = bars_ignore_M30; break;
         case 60:    time_frame = "H1";  duration_bar = 3600;  hole_min = 1;               break;
         case 240:   time_frame = "H4";  duration_bar = 14400; hole_min = 1;               break;
         default: MessageBox("��������� ������ ���������� � �������� M1-H4.\n\n�������� ������ ���������.", 
                             "����������� ������ ��������� (������)", MB_OK | MB_ICONWARNING | MB_DEFBUTTON1); 
         return(0);
         }
if (hole_min < 1) hole_min = 1; 
if (bars_ignore == false) hole_min = 1;

if (gap_min < 0) gap_min = 0;
if (gap_ignore == false) gap_min = 0;

//+------------------------------
// ������ ���� ������� ��� �����
datetime  bar_day   = TimeDay   (Time[Bars - 1]);
datetime  bar_month = TimeMonth (Time[Bars - 1]);
datetime  bar_year  = TimeYear  (Time[Bars - 1]);
string zero_day_begin, zero_month_begin;

if (bar_day < 10) zero_day_begin = "0"; else zero_day_begin = "";
if (bar_month < 10) zero_month_begin = "0"; else zero_month_begin = "";
string date_start = zero_day_begin + bar_day + "." + zero_month_begin + bar_month + "." + bar_year; // ��������� ����
 
bar_day   = TimeDay   (Time[0]);
bar_month = TimeMonth (Time[0]);
bar_year  = TimeYear  (Time[0]);
string zero_day_end, zero_month_end;

if (bar_day < 10) zero_day_end = "0"; else zero_day_end = "";
if (bar_month < 10) zero_month_end = "0"; else zero_month_end = "";
string date_end = zero_day_end + bar_day + "." + zero_month_end + bar_month + "." + bar_year; // �������� ����

string file_name = Symbol() + "_" + time_frame + "_holes_" + date_start + "-" + date_end + ".txt";

//+------------------------------    
if (breakup_min < hole_min)
    { 
     int warning_1 = MessageBox("�������� ���������� ������������� ����� ������ ����������:\n\nhole_min <= breakup_min\n\n" + 
                                "��������  - breakup_min, ����� ��������� ��  - hole_min.", "����������� ������� ��������: " + 
                                "hole_min, breakup_min", MB_OKCANCEL | MB_ICONWARNING | MB_DEFBUTTON1); 
     if (warning_1 == 1) breakup_min = hole_min;  else return(0);
     }
     
//+------------------------------
// ����������� ������� �������� ���������� ���� ��������� ��������� ������ (��:��)
datetime ews;
string   end_week_sessions; // ����� ��������� ��������� ������
 
for (int i = 0; i < Bars; i++ )
     {
      datetime time  = iTime(NULL, 0, Bars - i );
      int day_week = TimeDayOfWeek(time);
      
      if (day_week == 5)
          {
           datetime initial_time = StrToTime(TimeToStr(time,TIME_DATE|TIME_MINUTES));
     
           if (initial_time > ews) ews = initial_time;
           }
      end_week_sessions = TimeToStr(ews,TIME_MINUTES);     
      }
//+------------------------------
// ������ ������ ������� 
int    week_seconds = 604800; // ���������� ������ � ������
double weeks;                 // ��������� ��������� ���� � ���������� ������ � ������

//+-------------------
// �������� ��� � ���.
datetime holiday = StrToTime(begin_week_sessions) - StrToTime(end_week_sessions) + (24*3600*3) - duration_bar;

//+-------------------
int hole_range; // �������� ����
int bars_hole;  // ����� � ����
   
int holes_total_amount;   // ����� ���������� ���
int breakup_total_amount; // ����� ���������� ��������
int bars_hole_amount;     // ����� ���������� ����� � �����
int bars_breakup_amount;  // ����� ���������� ����� � ��������

int gap_total_amount;     // ����� ���������� �����
int gap_holes;            // ����� ��� � �����
int gap_breakups;         // ����� ��� � ��������

int hole_max;             // �������� ������������ ����
int breakup_max;          // �������� ������������� �������
int gap_max;              // �������� ������������� ����
bool note_ = false;
double months, days, hours, minutes, seconds;
int n = 1;
string line_2   = "-----------------------------------------------------------------------------------------------------------" +
                  "-----------------------------------------------------------------------------------------------------------\n";
string perenos  = "\n";
//+-------------------
for (int h = 0; h < Bars; h++ )
    {
//+-------------------
// ����� �������� � ����������� ����� � �������  
datetime bar_time_current  = iTime(NULL, 0, Bars - h - 2);
datetime bar_time_previous = iTime(NULL, 0, Bars - h - 1);

// ���� �������� �������� � ���� �������� ����������� ����� � �������  
double open_price_current   = NormalizeDouble(Open[Bars - h - 2],4);
double close_price_previous = NormalizeDouble(Close[Bars - h - 1],4);

// ��� � pips��
double pips_gap = NormalizeDouble(MathAbs(open_price_current - close_price_previous)/Point,0);  

//+-------------------
// ����������� �������� ���������� � ������ ����������
int time_frame_range = bar_time_current - bar_time_previous; 

//+-------------------
if (time_frame_range > duration_bar) // ���������� ������ � ���� ��������� ���������
    {
     string note_1, note_8; // ����������
     
     if (time_frame_range > week_seconds) // ���������� ������ � ���� ��������� ���������� ������ � ������
         {
          weeks = MathFloor(time_frame_range / week_seconds); // �������� ���� � ��������� ���������
                   
          if (TimeDayOfWeek(bar_time_previous) > TimeDayOfWeek(bar_time_current) )
              hole_range      = time_frame_range - holiday * (1 + weeks) - duration_bar;
              else hole_range = time_frame_range - (holiday * weeks) - duration_bar;
        
          note_1 = "(***������� �������� ���)";
          } 
           else
               {
                weeks = 0;
                
                if (TimeDayOfWeek(bar_time_previous) > TimeDayOfWeek(bar_time_current) )
                    {
                     hole_range = time_frame_range - holiday - duration_bar;
                     note_1 = "(***������� �������� ���)";
                     } 
                      else 
                          {
                           hole_range = time_frame_range - duration_bar;
                           note_1 = "";
                           }
                }
          bars_hole = hole_range / duration_bar;

          if (bars_hole >= hole_min && pips_gap >= gap_min)
              { 
               holes_total_amount++;          // ����� ���������� ��� (�����������)
               bars_hole_amount += bars_hole; // ����� ���������� ����� � ����� (�����������)
               
               string gap;
               if (pips_gap >= gap_min) 
                   {
                    gap_holes += pips_gap; // ����� ��� � ����� 
                    gap = DoubleToStr(pips_gap,0);
                    
                    if (pips_gap == 0) n = 0; 
                    }
                    else gap = "-";
                               
               string _gap_;
              
               if (holes_total_amount < 10) _gap_ = "     ";
               else if (holes_total_amount >= 10 && holes_total_amount < 100) _gap_ = "   ";
               else if (holes_total_amount >= 100 && holes_total_amount < 1000) _gap_ = " ";
               else _gap_ = "";

               seconds   = bars_hole * duration_bar;
               hours = MathFloor(seconds / 3600);
               minutes = seconds / 3600 - hours;
               string duration_hole;
               string zero_h4 = "", zero_m4 = ""; 
     
               if (hours < 10) zero_h4 = "0"; 
               if (minutes * 60 < 10) zero_m4 = "0"; 
     
               duration_hole = zero_h4 + DoubleToStr(hours,0) + ":" + zero_m4 + DoubleToStr(minutes * 60,0);  
               
               if (hours > 24)  
                   {
                    days = MathFloor(hours / 24); hours = hours - days * 24;
                    if (hours < 10) zero_h4 = "0";
                    duration_hole = DoubleToStr(days,0) + " day(s)  " + zero_h4 + DoubleToStr(hours,0) + ":" + zero_m4 + DoubleToStr(minutes * 60,0);  

                    if (days > 30)   
                        {
                         months = MathFloor(days / 30); days = days - months * 30;
                         duration_hole = DoubleToStr(months,0) + " month(s)  " + DoubleToStr(days,0) + " day(s)  " + zero_h4 + DoubleToStr(hours,0) + ":" + zero_m4 + DoubleToStr(minutes * 60,0);  
                         }
                    }   
               //+-------------------
               // ����� ������ ��������� ���� 
               datetime hole_day_begin_;
               string   hole_time_begin_;
               int      ny_month_begin;
                              
               if (StrToTime(TimeToStr(bar_time_previous + duration_bar,TIME_MINUTES)) == StrToTime(end_week_sessions) + duration_bar && 
                   TimeDayOfWeek(bar_time_previous + duration_bar) == 5)
                   {
                    hole_day_begin_  = TimeDay(bar_time_previous + duration_bar + holiday); 
                    hole_time_begin_ = TimeToStr(bar_time_previous + duration_bar + holiday, TIME_MINUTES );
                    ny_month_begin   = TimeMonth(bar_time_previous + duration_bar + holiday);
                    note_1           = "";
                    }
                     else 
                         {
                          hole_day_begin_  = TimeDay(bar_time_previous + duration_bar);
                          hole_time_begin_ = TimeToStr(bar_time_previous + duration_bar, TIME_MINUTES );
                          ny_month_begin   = TimeMonth(bar_time_previous + duration_bar);
                          } 
     
               datetime hole_day_begin   = hole_day_begin_;
               datetime hole_month_begin = TimeMonth(bar_time_previous + duration_bar);
               datetime hole_year_begin  = TimeYear(bar_time_previous + duration_bar);
               string   hole_time_begin  = hole_time_begin_;
               
               if (hole_day_begin < 10) zero_day_begin = "0"; else zero_day_begin = "";
               if (hole_month_begin < 10) zero_month_begin = "0"; else zero_month_begin = "";
               //+------------------- 
               // ����� ��������� ��������� ���� 
               datetime hole_day_end   = TimeDay(bar_time_current);
               datetime hole_month_end = TimeMonth(bar_time_current);
               datetime hole_year_end  = TimeYear(bar_time_current);
               string   hole_time_end  = TimeToStr(bar_time_current, TIME_MINUTES );
               
               if (hole_day_end < 10) zero_day_end = "0"; else zero_day_end = "";
               if (hole_month_end < 10) zero_month_end = "0"; else zero_month_end = "";
               
               //+------------------- 
               if (ny_month_begin == 12 && TimeMonth(bar_time_current) == 1) note_8 = "NewYear  "; 
               else note_8 = ""; 
               
               //+-------------------
               if (bars_hole >= breakup_min)
                   {
                    breakup_total_amount++;           // ����� ���������� �������� (�����������)
                    bars_breakup_amount += bars_hole; // ����� ���������� ����� � �������� (�����������)
                    gap_breakups += pips_gap;         // ����� ��� � �������� 
                    }
               if (hole_max < bars_hole && bars_hole < breakup_min)
                   {
                    hole_max = bars_hole;                 // ������������ ����
                    int number_hole = holes_total_amount; // �/� ����� 
                    } 
               if (breakup_max <= bars_hole && bars_hole >= breakup_min)
                   {
                    breakup_max = bars_hole;                 // ������������ ������
                    int number_breakup = holes_total_amount; // �/� ����� 
                    }     
               if (gap_max <= pips_gap)
                   {
                    gap_max = pips_gap;                  // ������������ ���
                    int number_gap = holes_total_amount; // �/� ����� 
                    }     

//+------------------------------
// �������� ������� *.txt �����
if (new_file)
    {
string line_1   = "__________________________________________________________________________________________________________________________" + "\n";
string headline = "�/�  �\t|  *��������  (���� / �����)\t\t\t|  ������  (bars)\t|  ������������  (��:��)\t|  **Gap  (pips)\t|  ����������" + "\n";
                
FileDelete(file_name);// �������� ������ ����������� ����� � ����� �� ������  
handle = FileOpen(file_name, FILE_WRITE | FILE_READ, " ");
FileSeek (handle, 2400, SEEK_END);
FileWrite(handle, perenos, line_1, headline, line_2);
new_file = false;
     }
if (note_1 != "") note_ = true;
//+-------------------
string hole = "   " + holes_total_amount + _gap_ + "\t  " + zero_day_begin + hole_day_begin + "." + 
              zero_month_begin + hole_month_begin + "." + hole_year_begin + " [" + hole_time_begin + 
              "]\t       -\t" + zero_day_end + hole_day_end + "." + zero_month_end + hole_month_end + "." + hole_year_end + 
              " [" + hole_time_end + "]\t  " +  bars_hole + "\t\t   " + duration_hole + "\t\t\t   " + gap + "\t\t   " + note_8 + note_1 + "\n"; 

FileWrite(handle, hole );

//+-------------------
// ������������ ���� � ������
string hole_range_max    = "�/�  �  - " + number_hole + "\n";
string breakup_range_max = "�/�  �  - " + number_breakup + "\n";
string gap_range_max = "�/�  �  - " + number_gap + "\n";

              }
     }
}
//+------------------------------ 
// �������� ������ *.txt ����� 
if (hole_min > 1) string note_2 = "\t( ���� �������� < " + hole_min + " bars - ������������ ��������� ������������� ��������� )";
    
string note_3;
if (hole_min == breakup_min) note_3 = "�������� <�������>, �������� �������� ������������� �������� )";
else note_3 = hole_min + " - " + breakup_min + " bars )\t" + note_2; 

double bars_hole_amount_     = bars_hole_amount;     
double bars_breakup_amount_  = bars_breakup_amount;  
double holes_total_amount_   = holes_total_amount;   
double breakup_total_amount_ = breakup_total_amount; 
double gap_holes_            = gap_holes;
double gap_total_amount_     = gap_total_amount;
double bars_                 = Bars;

string hole_average_size_; 
string info_10, info_11, info_12, info_13, info_21, info_22, info_23;

string grade_hole_chart_ = DoubleToStr( (bars_hole_amount_ - bars_breakup_amount_)/ bars_ * 100, 2);
string quality_chart__   = DoubleToStr( (bars_ - bars_hole_amount_ + bars_breakup_amount_ ) / bars_ * 100, 2);

if (holes_total_amount != breakup_total_amount)
    {
     seconds = (bars_hole_amount - bars_breakup_amount) * duration_bar;
     hours   = MathFloor(seconds / 3600);
     minutes = seconds / 3600 - hours;
     
     string duration_holes;
     string zero_h1 = "", zero_m1 = ""; 
     
     if (hours < 10) zero_h1 = "0"; 
     if (minutes * 60 < 10) zero_m1 = "0"; 
      
     duration_holes = zero_h1 + DoubleToStr(hours,0) + ":" + zero_m1 + DoubleToStr(minutes * 60,0);  
     
     if (hours > 24)  
         {
          days = MathFloor(hours / 24); hours = hours - days * 24;
          if (hours < 10) zero_h1 = "0";
          duration_holes = DoubleToStr(days,0) + " day(s)  " + zero_h1 + DoubleToStr(hours,0) + ":" + zero_m1 + DoubleToStr(minutes * 60,0);  

          if (days > 30)   
              {
               months = MathFloor(days / 30); days = days - months * 30;
               duration_holes = DoubleToStr(months,0) + " month(s)  " + DoubleToStr(days,0) + " day(s)  " + zero_h1 + DoubleToStr(hours,0) + ":" + zero_m1 + DoubleToStr(minutes * 60,0);  
               }
          }      
     hole_average_size_ = DoubleToStr( (bars_hole_amount_ - bars_breakup_amount_)/(holes_total_amount_ - breakup_total_amount_), 2);
     info_10 = "����������   -\t\t\t" + (holes_total_amount - breakup_total_amount) + "\n";
     info_11 = "������   -\t\t\t" + (bars_hole_amount - bars_breakup_amount) + " bars\n";
     info_23 = "������������   -\t\t\t" + duration_holes + " ��:��\n";
     info_12 = "������������ ������   -\t\t" + hole_max + " bars\t\t" + hole_range_max;
     info_13 = "������� ������   -\t\t\t" + hole_average_size_ + " bars\n";
     info_21 = "������� ��������� �������    -\t" + grade_hole_chart_ + " %\n";
     info_22 = "�������� �������    -\t\t" + quality_chart__  + " %\n";
     }
      else 
          {
           info_10 = "����������   -\t\t\t-\n";
           info_11 = "������   -\t\t\t-\n";
           info_23 = "������������   -\t\t\t-\n";
           info_12 = "������������ ������   -\t\t-\n";
           info_13 = "������� ������   -\t\t\t-\n";
           info_21 = "������� ��������� �������    -\t-\n";
           info_22 = "�������� �������    -\t\t-\n";
           }

string grade_hole_chart     = DoubleToStr(bars_hole_amount_ / bars_ * 100, 2);
string grade_breakup_chart  = DoubleToStr(bars_breakup_amount_ / bars_ * 100, 2);
string quality_chart        = DoubleToStr( (bars_ - bars_hole_amount_) / bars_ * 100, 2);
string quality_chart_       = DoubleToStr( (bars_ - bars_breakup_amount_) / bars_ * 100, 2);

//+-------------------
string line_3 = " -----------------------------------------------------------------------------------------------------------" +
                "-----------------------------------------------------------------------------------------------------------" + "\n";
string shapka = "����� �� ������������� ����� � ������ �������. ���������� - " + Symbol() + ". ��������� [" + time_frame + "].\n";
string info_1 = "������    -\t\t\t" + date_start + " �.  -  " + date_end + " �.\n";
string info_2 = "����� � �������   -\t\t\t" + Bars + " bars\n";

seconds = Time[0] - Time[Bars - 1];
hours   = MathFloor(seconds / 3600);
minutes = seconds / 3600 - hours;

double years;      
string duration_period;
string zero_h5 = "", zero_m5 = ""; 
     
if (hours < 10) zero_h5 = "0"; 
if (minutes * 60 < 10) zero_m5 = "0"; 
      
duration_period = zero_h4 + DoubleToStr(hours,0) + ":" + zero_m5 + DoubleToStr(minutes * 60,0);  
  
if (hours > 24)  
    {
     days = MathFloor(hours / 24); hours = hours - days * 24; 
     if (hours < 10) zero_h5 = "0";
     duration_period = DoubleToStr(days,0) + " day(s)  " + zero_h5 + DoubleToStr(hours,0) + ":" + zero_m5 + DoubleToStr(minutes * 60,0);  

     if (days > 30)   
         {
          months = MathFloor(days / 30); days = days - months * 30;
          duration_period = DoubleToStr(months,0) + " month(s)  " + DoubleToStr(days,0) + " day(s)  " + zero_h5 + DoubleToStr(hours,0) + ":" + zero_m5 + DoubleToStr(minutes * 60,0);  

          if (months > 12) 
              {
               years  = MathFloor(months / 12); months = months - years * 12;
               duration_period = DoubleToStr(years,0) + " year(s)  " + DoubleToStr(months,0) + " month(s)  " + DoubleToStr(days,0) + " day(s)  " + zero_h5 + DoubleToStr(hours,0) + ":" + zero_m5 + DoubleToStr(minutes * 60,0);  
               }
          }
     }     

string info_26 = "������������   -\t\t\t" + duration_period + " ��:��\n";
string line_4 = "_____________________________________________________";
string info_3 = "����� ������ ��� � �������� \n";
string info_4;

//+-------------------
if (holes_total_amount != 0)
    {
 //+------------------------------
seconds = bars_hole_amount * duration_bar;
hours   = MathFloor(seconds / 3600);
minutes = seconds / 3600 - hours;
string duration_holes_; 
string zero_h2 = "", zero_m2 = "";
 
if (hours < 10) zero_h2 = "0"; 
if (minutes * 60 < 10) zero_m2 = "0"; 

duration_holes_ = zero_h2 + DoubleToStr(hours,0) + ":" + zero_m2 + DoubleToStr(minutes * 60,0);  

if (hours > 24)  
    {
     days = MathFloor(hours / 24); hours = hours - days * 24;
     if (hours < 10) zero_h2 = "0";
     duration_holes_ = DoubleToStr(days,0) + " day(s)  " + zero_h2 + DoubleToStr(hours,0) + ":" + zero_m2 + DoubleToStr(minutes * 60,0);  

     if (days > 30)   
         {
          months = MathFloor(days / 30); days = days - months * 30;
          duration_holes_ = DoubleToStr(months,0) + " month(s)  " + DoubleToStr(days,0) + " day(s)  " + zero_h2 + DoubleToStr(hours,0) + ":" + zero_m2 + DoubleToStr(minutes * 60,0);  
          }
     }   

string hole_average_size = DoubleToStr(bars_hole_amount_ / holes_total_amount_, 2);
string gap_average_size  = DoubleToStr(gap_holes_ / holes_total_amount_, 2);

FileSeek (handle, 0, SEEK_END);
FileWrite(handle, line_1);
FileSeek (handle, 0, SEEK_SET);
info_4 = "����������  -\t\t\t" + holes_total_amount + "\n";
string info_5 = "������   -\t\t\t" + bars_hole_amount + " bars\n";
string info_24 = "������������   -\t\t\t" + duration_holes_ + " ��:��\n";
string info_6 = "������� ������   -\t\t\t" + hole_average_size + " bars\n";

string note_7;
if (gap_min != 0) note_7 = "**"; else note_7 = " ";
string info_27 = "Gap" + note_7 + "   -\t\t\t\t" + gap_holes + " pips\n";
string info_28 = "������������ Gap   -\t\t" + gap_max + " pips\t\t" + gap_range_max;
string info_31 = "������� Gap   -\t\t\t" + gap_average_size + " pips" + "   \t( Gap / ���������� )\n";

string info_7 = "������� ����� ��������� �������    -\t" + grade_hole_chart + " %\n";
string info_8 = "�������� �������    -\t\t" + quality_chart + " %\n";


string info_9 = "����  ( " + note_3 + "\n";

//+-------------------
string info_14 = "������� ( " + breakup_min + " bars � ����)\n";
string info_15, info_16, info_17, info_18, info_19, info_20, info_25;
     
if (breakup_total_amount != 0)          
    {
     seconds = bars_breakup_amount * duration_bar;
     hours   = MathFloor(seconds / 3600);
     minutes = seconds / 3600 - hours;
     string duration_breakups;
     string zero_h3 = "", zero_m3 = ""; 
     
     if (hours < 10) zero_h3 = "0"; 
     if (minutes * 60 < 10) zero_m3 = "0";
          
     duration_breakups = zero_h3 + DoubleToStr(hours,0) + ":" + zero_m3 + DoubleToStr(minutes * 60,0);  

     if (hours > 24)  
         {
          days = MathFloor(hours / 24); hours = hours - days * 24;
          if (hours < 10) zero_h3 = "0";
          duration_breakups = DoubleToStr(days,0) + " day(s)  " + zero_h3 + DoubleToStr(hours,0) + ":" + zero_m3 + DoubleToStr(minutes * 60,0);  

          if (days > 30)   
              {
               months = MathFloor(days / 30); days = days - months * 30;
               duration_breakups = DoubleToStr(months,0) + " month(s)  " + DoubleToStr(days,0) + " day(s)  " + zero_h3 + DoubleToStr(hours,0) + ":" + zero_m3 + DoubleToStr(minutes * 60,0);  
               }
          }   
          string breakup_average_size = DoubleToStr(bars_breakup_amount_ / breakup_total_amount_, 2);
          info_15 = "����������   -\t\t\t" + breakup_total_amount + "\n";
          info_16 = "������   -\t\t\t" + bars_breakup_amount + " bars\n";
          info_25 = "������������   -\t\t\t" + duration_breakups + " ��:��\n";
          info_17 = "������������ ������   -\t\t" + breakup_max + " bars\t\t" + breakup_range_max;
          info_18 = "������� ������   -\t\t\t" + breakup_average_size + " bars\n";
          info_19 = "������� ����������� �������    -\t" + grade_breakup_chart + " %\t\t( ��� ����� ��� )\n";
          info_20 = "�������� �������    -\t\t" + quality_chart_ + " %\t\t( ��� ����� ��� )\n";
          }
          else
               {
                info_15 = "����������   -\t\t\t-\n";
                info_16 = "������   -\t\t\t-\n";
                info_25 = "������������   -\t\t\t-\n";
                info_17 = "������������ ������   -\t\t-\n";
                info_18 = "������� ������   -\t\t\t-\n";
                info_19 = "������� ����������� �������    -\t-\n";
                info_20 = "�������� �������    -\t\t-\n";
                }
//+-------------------
string note_4  = "     *�������� ���������� �������� �������� ������� �������������� ����, � ������������� �������� �������� ����,\n        ���������� �� ��������� ������������� �����.\n";
string note_9 = "       =Gap � �����= �� ����� ���� ������, � ���� ���������� ����� �����, � ���� ���������� ������� � ������� ��� �� � ����� ����.\n";

string note_10;
if (n != 0) note_10 = "  **";
else note_10 = "  **Gap = 0  pips - �� �������� ������ ���������� ���������, � ���� ���������, ��� ���� ������������ �� ������� ������� (�� ����).\n";

string note_5;
if (gap_ignore == true && gap_min >= 1) note_5 = "  **���� � Gap < " + gap_min + "  pips - ������������ ��������� ������������� ���������.\n" + note_9; 
else note_5 = note_10 + note_9;

string note_6 = "";
if (note_ == true) note_6 = "***����� ��������� ������    -\t" + TimeToStr(StrToTime(end_week_sessions) + duration_bar,TIME_MINUTES) + " ��:��";

FileWrite(handle, line_3, shapka, line_2, info_1, info_2, info_26, line_4, perenos, info_3, info_4, info_5, info_24, info_6, info_27, 
          info_28, info_31, info_7, info_8, line_4, perenos, info_9,  info_10, info_11, info_23, info_12, info_13, info_21, info_22, 
          line_4, perenos, info_14, info_15, info_16, info_25, info_17, info_18, info_19, info_20, line_4, perenos, note_4, perenos, note_5, perenos, note_6);
}
 else 
     {
      FileDelete(file_name);
      handle = FileOpen(file_name, FILE_WRITE | FILE_READ, " ");
      info_4 = "����������  -\t\t\t�� ������ ������� ��� � �������� �� ����������\n";
      FileWrite(handle, line_3, shapka, line_2, info_1, info_2, line_4, perenos, info_3, info_4, line_4);
      }
FileClose(handle);

MessageBox("� ����� ��������� MT4: \Experts\files\ ������ ���� ������:\n\n" + file_name, 
           "������ ������ ������� ������� ��������", MB_OK | MB_DEFBUTTON1);
return(0);
}
//+------------------------------------------------------------------+

