//+------------------------------------------------------------------+
//|                                             Visible_Pos.mq4      |
//|                                             Valmars              |
//|                                             valmars@bk.ru        |
//+------------------------------------------------------------------+
#property copyright "Valmars"
#property link      "valmars@bk.ru"
//+------------------------------------------------------------------+
//| script program start function                                    |
//+------------------------------------------------------------------+
int start() 
  { 
   ObjectsDeleteAll(0, OBJ_ARROW); // �������� ���� ������� � �������
   string name;                    // ��� �������-�������
   int Arrow;                      // ��� �������
   double Color;                   // ���� �������
//  �������� ��� ���� �������� � ���������� �������
   for(int i = 0; i < OrdersTotal(); i++)  
	    { 	
	      OrderSelect(i, SELECT_BY_POS);
       // ������� ������ � ������� �� ���������
	      if(OrderSymbol()!=Symbol()) 
		         continue;               // ��������� �����
       // ������� ������ � ������� ���������
       else
         {
           // ����� ��������, ����� �������� ������
           datetime tm_open = OrderOpenTime();
           datetime tm_close = OrderCloseTime();
           double pr_open = OrderOpenPrice(); 
           // ���� ��������, ���� �������� ������
           double pr_close = OrderClosePrice(); 
           //----
           switch(OrderType()) // ��������� �������
             {
               case OP_BUY:       Arrow = 1; Color = Aqua; 
                                  name = "OP_BUY_" + OrderTicket(); 
                                  break;         
               case OP_SELL:      Arrow = 2; Color = Red; 
                                  name = "OP_SELL_" + OrderTicket(); 
                                  break;
               case OP_BUYLIMIT:  Arrow = 1; Color = Yellow; 
                                  name = "OP_BUYLIMIT_" + OrderTicket(); 
                                  break;
               case OP_BUYSTOP:   Arrow = 1; Color = Yellow; 
                                  name = "OP_BUYSTOP_" + OrderTicket(); 
                                  break;
               case OP_SELLLIMIT: Arrow = 2; Color = Yellow; 
                                  name = "OP_SELLLIMIT_" + OrderTicket();
                                  break;
               case OP_SELLSTOP:  Arrow = 2; Color = Yellow; 
                                  name = "OP_SELLSTOP_" + OrderTicket();
                                  break;
             }
           // ������� �������� ������
           ObjectCreate(name, OBJ_ARROW, 0, tm_open, pr_open);      
           ObjectSet(name, OBJPROP_ARROWCODE, Arrow); 
           ObjectSet(name, OBJPROP_COLOR, Color);
         }
     }
//  �������� ��� ���� �������� � �������� �������  
   for(i = 0; i < HistoryTotal(); i++) 
	    { 	
	      OrderSelect(i, SELECT_BY_POS, MODE_HISTORY);
       // ������� ������ � ������� �� ���������
	      if(OrderSymbol() != Symbol())     
		         continue;           // ��������� �����
       else                    // ������� ������ � ������� ���������
         {
           tm_open = OrderOpenTime();
           tm_close = OrderCloseTime();
           pr_open = OrderOpenPrice();
           pr_close = OrderClosePrice();
           //----
           switch(OrderType())
             {
               case OP_BUY:       Arrow = 1; Color = Aqua; 
                                  name = "OP_BUY_" + OrderTicket(); 
                                  break;
               case OP_SELL:      Arrow = 2; Color = Red; 
                                  name = "OP_SELL_" + OrderTicket();
                                  break;
               case OP_BUYLIMIT:  Arrow = 1; Color = Yellow; 
                                  name = "OP_BUYLIMIT_" + OrderTicket();
                                  break;
               case OP_BUYSTOP:   Arrow = 1; Color = Yellow; 
                                  name = "OP_BUYSTOP_" + OrderTicket();
                                  break;
               case OP_SELLLIMIT: Arrow = 2; Color = Yellow; 
                                  name = "OP_SELLLIMIT_" + OrderTicket();
                                  break;
               case OP_SELLSTOP:  Arrow = 2; Color = Yellow; 
                                  name = "OP_SELLSTOP_" + OrderTicket();
                                  break;
             }
           // ������� �������� ������
           ObjectCreate(name, OBJ_ARROW, 0, tm_open,pr_open);   
           ObjectSet(name, OBJPROP_ARROWCODE, Arrow); 
           ObjectSet(name, OBJPROP_COLOR, Color);
           switch(OrderType())
             {
               case OP_BUY:       Color = Aqua; 
                                  name = "CL_BUY_" + OrderTicket(); 
                                  break;
               case OP_SELL:      Color = Red; 
                                  name = "CL_SELL_" + OrderTicket();
                                  break;
               case OP_BUYLIMIT:  Color = Yellow; 
                                  name = "DEL_BUYLIMIT_" + OrderTicket(); 
                                  break;
               case OP_BUYSTOP:   Color = Yellow; 
                                  name = "DEL_BUYSTOP_" + OrderTicket(); 
                                  break;
               case OP_SELLLIMIT: Color = Yellow; 
                                  name = "DEL_SELLLIMIT_" + OrderTicket(); 
                                  break;
               case OP_SELLSTOP:  Color = Yellow; 
                                  name = "DEL_SELLSTOP_" + OrderTicket(); 
                                  break;
             }
           // ������� �������� ������
           ObjectCreate(name, OBJ_ARROW, 0, tm_close, pr_close);    
           ObjectSet(name, OBJPROP_ARROWCODE, 3); 
           ObjectSet(name, OBJPROP_COLOR, Color);
         }
     }
   return(0);
  }
//+------------------------------------------------------------------+