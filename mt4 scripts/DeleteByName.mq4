//+------------------------------------------------------------------+
//|                                              DeleteByPreName.mq4 |
//|                                                      ����� ����� |
//|                                    http://denis-or-love.narod.ru |
//|Clears the chart of all objects with the name beginning on the specified prefix
//|��� ������� ������� ������� �� �������� �� ������ �� �����        |
//+------------------------------------------------------------------+
#property copyright "����� �����"
#property link      "http://denis-or-love.narod.ru"


#property show_inputs

extern string PreName ="����������� �������";
//+------------------------------------------------------------------+
//| script program start function                                    |
//+------------------------------------------------------------------+
int start()
  {
//----
   for(int k=ObjectsTotal()-1; k>=0; k--)  // �� ���������� ���� �������� 
     {
      string Obj_Name=ObjectName(k);   // ����������� ��� �������
      string Head=StringSubstr(Obj_Name,0,StringLen(PreName));// ��������� ������ ���

      if (Head==PreName)// ������ ������, ..
         {
         ObjectDelete(Obj_Name);
         //Alert(Head+";"+Prefix);
         }                  
     }
//----
   return(0);
  }
//+------------------------------------------------------------------+