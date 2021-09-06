//+------------------------------------------------------------------+
//|                                   Multichart Visual Analyser.mq4 |
//|                                                          Strator |
//|                                                  k-v-p@yandex.ru |
//+------------------------------------------------------------------+
//|������ ������������ ��� ����������� ������� �������� ����������   |
//|�������� ��� �� ������������ ��������� ���������                  |
//+------------------------------------------------------------------+
//������ ������� �� ����� ��� "���������" ����������� �������: ��� ������������ �����
//� �������� ���������.
//��� ����������� ������������� ������-���� �� ���� ��������
//������������� ����������� ���������������� �� ����� "���������" ��������.
//��� ������� ������� �� ���������� ������, ���������� ������� ����� �� ����� �� ���,
//��� ���� ���������������� "���������" �������� ����������� �� ���� ������.

#property copyright "Strator"
#property link      "k-v-p@yandex.ru"

#define id          "MCVA Script"
#define vline1_name "MCVA vl1_time"
#define vline2_name "MCVA vl2_time"
#define linreg_name "MCVA lr"

//���������� ��������� ���������� ����������
datetime glvar_prv_time1;
datetime glvar_prv_time2;
//������� ��������� ���������� ����������
datetime glvar_cur_time1;
datetime glvar_cur_time2;

//���������� ��������� ����������� ��������
datetime vline_prv_time1;   //���������� ��������� ������ ������������ �����
datetime vline_prv_time2;   //���������� ��������� ������ ������������ �����
datetime linreg_prv_time1;  //���������� ��������� ����� ���������� �������� ���������
datetime linreg_prv_time2;  //���������� ��������� ������ ���������� �������� ���������

//������� ��������� ����������� ��������
datetime vline_cur_time1;
datetime vline_cur_time2;
datetime linreg_cur_time1;
datetime linreg_cur_time2;

//���� ��� ����������� �����
bool redraw=false;

//+------------------------------------------------------------------+
//| Script initialization function                                   |
//+------------------------------------------------------------------+
int init()
  {
  //�������� ������� ���������� ���������� ��������
  int value=GlobalVariableGet(id);
  GlobalVariableSet(id, value+1);
  return(0);
  }

//+------------------------------------------------------------------+
//| Script deinitialization function                                 |
//+------------------------------------------------------------------+
int deinit()
  {
  //�������� ������� ���������� ���������� ��������
  //���� ��������� ������������ ��������� �������, �� ������ ���������� ����������
  int value=GlobalVariableGet(id);
  if (value>1) GlobalVariableSet(id, value-1);
  else 
    {
    GlobalVariableDel(id);
    GlobalVariableDel(vline1_name);
    GlobalVariableDel(vline2_name);
    }
  //������ ����������� �������
  ObjectDelete(vline1_name);
  ObjectDelete(vline2_name);
  ObjectDelete(linreg_name);
  RedrawChart();
  return(0);
  }

//+------------------------------------------------------------------+
//| script program start function                                    |
//+------------------------------------------------------------------+
int start()
  {
  while (!IsStopped())
    {
    //���� ���������� ���������� <id> ���� �������, ��������� ������ �������
    if (!GlobalVariableCheck(id)) break;
    //�������� ���������������� ����������
    RefreshRates();
    //�������� ���� ����������� �����
    redraw=false;
    //��������� ���������
    main();
    //������������ ����, ���� ��� ����������
    if (redraw) RedrawChart();
    //�������� ���������� �������
    Pause();
    }
  return(0);
  }

void main()
  {
  //�������� �� ������� � �������� ����������� ���������� ����������
  GlobalVariablesCheckPresent();
  //�������� �� ������� � �������� ����������� ����������� ��������
  ObjectsCheckPresent();
  //�������� �� ��������� ���������� ����������
  GlobalVariablesCheckModify();
  //�������� �� ��������� ��������� ����������� �������� �� �����
  ObjectsCheckModify();  
  }

void ObjectsCheckModify()
  {
  vline_cur_time1=ObjectGet(vline1_name, OBJPROP_TIME1);
  vline_cur_time2=ObjectGet(vline2_name, OBJPROP_TIME1);
  linreg_cur_time1=ObjectGet(linreg_name, OBJPROP_TIME1);
  linreg_cur_time2=ObjectGet(linreg_name, OBJPROP_TIME2);
  if (vline_cur_time1!=vline_prv_time1) GlobalVariableSet(vline1_name, vline_cur_time1);
  if (vline_cur_time2!=vline_prv_time2) GlobalVariableSet(vline2_name, vline_cur_time2);
  if (linreg_cur_time1!=linreg_prv_time1) GlobalVariableSet(vline1_name, linreg_cur_time1);
  if (linreg_cur_time2!=linreg_prv_time2) GlobalVariableSet(vline2_name, linreg_cur_time2);
  GlobalVariablesCheckModify();
  }
  
void GlobalVariablesCheckModify()
  {
  glvar_cur_time1=GlobalVariableGet(vline1_name);
  glvar_cur_time2=GlobalVariableGet(vline2_name);
  if (glvar_cur_time1!=glvar_prv_time1 || glvar_cur_time2!=glvar_prv_time2)
    {
    ObjectSet(vline1_name, OBJPROP_TIME1, glvar_cur_time1);
    ObjectSet(vline2_name, OBJPROP_TIME1, glvar_cur_time2);
    ObjectSet(linreg_name, OBJPROP_TIME1, MathMin(glvar_cur_time1, glvar_cur_time2));
    ObjectSet(linreg_name, OBJPROP_TIME2, MathMax(glvar_cur_time1, glvar_cur_time2));
    
    glvar_prv_time1=glvar_cur_time1;
    glvar_prv_time2=glvar_cur_time2;
    
    vline_prv_time1=ObjectGet(vline1_name, OBJPROP_TIME1);
    vline_prv_time2=ObjectGet(vline2_name, OBJPROP_TIME1);
    linreg_prv_time1=ObjectGet(linreg_name, OBJPROP_TIME1);
    linreg_prv_time2=ObjectGet(linreg_name, OBJPROP_TIME2);
    
    redraw=true;
    }  
  }
  
void GlobalVariablesCheckPresent()
  {
  if (!GlobalVariableCheck(vline1_name)) 
    {
    GlobalVariableSet(vline1_name, Time[0]);
    glvar_prv_time1=GlobalVariableGet(vline1_name);
    }
  if (!GlobalVariableCheck(vline2_name))
    {
    GlobalVariableSet(vline2_name, Time[100]);
    glvar_prv_time2=GlobalVariableGet(vline2_name);
    }
  }

void ObjectsCheckPresent()
  {
  glvar_cur_time1=GlobalVariableGet(vline1_name);
  glvar_cur_time2=GlobalVariableGet(vline2_name);
  
  //���� ������ � ������ <vline1_name> (������ ������������ �����) �� ������, ������� ���
  if (ObjectFind(vline1_name)<0)
    {
    ObjectCreate(vline1_name, OBJ_VLINE, 0, glvar_cur_time1, 0);
    ObjectSet(vline1_name, OBJPROP_STYLE, STYLE_DASH);
    ObjectSet(vline1_name, OBJPROP_COLOR, Red);
    vline_prv_time1=glvar_cur_time1;
    redraw=true;
    }
  
  //���� ������ � ������ <vline2_name> (������ ������������ �����) �� ������, ������� ���
  if (ObjectFind(vline2_name)<0)
    {
    ObjectCreate(vline2_name, OBJ_VLINE, 0, glvar_cur_time2, 0);
    ObjectSet(vline2_name, OBJPROP_STYLE, STYLE_DASH);
    ObjectSet(vline2_name, OBJPROP_COLOR, Red);
    vline_prv_time2=glvar_cur_time2;
    redraw=true;
    }
  //���� ������ � ������ <linreg_name> (�������� ���������) �� ������, ������� ���
  if (ObjectFind(linreg_name)<0)
    {
    datetime time1=MathMin(glvar_cur_time1, glvar_cur_time2);
    datetime time2=MathMax(glvar_cur_time1, glvar_cur_time2);
    ObjectCreate(linreg_name, OBJ_REGRESSION, 0, time1, 0, time2, 0);
    ObjectSet(linreg_name, OBJPROP_STYLE, STYLE_DASH);
    ObjectSet(linreg_name, OBJPROP_COLOR, Red);
    linreg_prv_time1=time1;
    linreg_prv_time2=time2;
    redraw=true;
    }
  }

void Pause()
  {
  static datetime lastmove;
  if (redraw) lastmove=TimeLocal();
  if (TimeLocal()-lastmove>5) Sleep(1000);
  else Sleep(10);
  }

void RedrawChart()
  {
  WindowRedraw();
  }

