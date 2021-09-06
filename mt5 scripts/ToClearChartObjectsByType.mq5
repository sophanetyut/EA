//+------------------------------------------------------------------+  
//|                                    ToClearChartObjectsByType.mq5 | 
//|                               Copyright © 2017, Nikolay Kositsin | 
//|                              Khabarovsk,   farria@mail.redcom.ru | 
//+------------------------------------------------------------------+  
#property copyright "Copyright © 2017, Nikolay Kositsin"
#property link "farria@mail.redcom.ru"
#property description "Скрипт очищает текущий график от объектов выбранного типа"
#property script_show_confirm //потверждение действия скрипта трейдером
#property script_show_inputs //показывать входные параметры
//+-----------------------------------------------+
//|  ВХОДНЫЕ ПАРАМЕТРЫ СКРИПТА                    |
//+-----------------------------------------------+
input ENUM_OBJECT OBJ_TYPE = -1;    //Тип удаляемых объектов
//+-----------------------------------------------+

//+------------------------------------------------------------------+ 
//| start function                                                   |
//+------------------------------------------------------------------+
void OnStart()
  {
//---- Удаление всех объектов выбранного типа с текущего графика  
   ObjectsDeleteAll(NULL,-1,OBJ_TYPE); 
//----
  }
//+------------------------------------------------------------------+
