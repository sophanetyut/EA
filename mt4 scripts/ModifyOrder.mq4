//+------------------------------------------------------------------+
//|                                                (ModifyOrder).mq4 |
//|                                      Copyright � 2005, komposter |
//|                                      mailto:komposterius@mail.ru |
//+------------------------------------------------------------------+
#property copyright "Copyright � 2005, komposter"
#property link      "mailto:komposterius@mail.ru"

/*
-----------------------------�-�-�-�-�-�-�-�---------------------------------
����� �������� ������� ������������ ���������� ������� ��������� �����������:

������ ������������ ��� �����������/��������/�������� �������/����������� ������.
��� ����� ����������:
 1) ������������ � ������ ������������ =), !���������� �������� �� ���������! (��������� ��� ���������,
 	 ���������� � ������������� ������� //+----------------------------------------------+ ),
 	 ��������� ������ ������� ��������� ����� ����
 	 "������" -> "���������" -> "���������" -> "��������� �������������� ������� ���������"
 	 (���������� ��� �������� ������, ������� ����� ���������� ��� ����������� ������)
 2) ���������� ������ �� ������ �������� �� ������/�������, �������(-��) ���������� ��������������.
 
 3) ����������� ��� ����� �� ����������� ������:
		- Open_Price_Line (�� ��������� - �����) - ���� �������� (������ ��� ���������� �������)
		- Stop_Loss_Line (�������) - ������� ���� ����
		- Take_Profit_Line (������) - ������� ���� ������
		- Expiration_Line (�����) - ����� ��������� (������ ��� ���������� �������)

	���� ������� ���� ����/���� ������/����� ��������� - ������ ������� ��������������� �����.
	���� ������� ���������� �����/������� �������  - ������� ����� Open_Price_Line.

 4) ����� �� ����� ������, � ����������� ���� ������ ������ "��".
 
 ��� ����������� ������ ������� � ����� ������ ����� ��������������� ������� "������".
 ���� ���� ����� ������� ������ � ����, ��� � ������ ������ �������, ������� �������� �� komposterius@mail.ru
*/
#include <stdlib.mqh>

int first = 1;
int start()
{
//+------------------------------------------------------------------+
// ������������ ���������� � ������� �� �����, �� ������� ��� "�������" ������, ��
// ���� �������� ������. ��� ����������� �������� ������ ����������� "0",
// ����� ����� ��������� ������ � ������ ������� ���������.
int Order_Find_Radius = 10;

// ���������� ����� ������ Take_Profit/Stop_Loss � ������ Open_Price � ������� �� ���������.
// ���� Take_Profit/Stop_Loss �������������� �� �����, ���������� 0
int Take_Profit = 50;
int Stop_Loss = 50;

// ������������ ���������� �� ����������� ���� (��� �������� �������)
int Slippage = 5;

// ����� ��������� ������, ���������� � ������
// ��� ������� ������� H4 � Expiration_Shift = 3 ����� ��������� �������� ����� 12 ����� ����� ���������
// ���� ���������� ����������� ����� ��������� ��� ���� �������� �������, ������� "0" (��� �������), � ���������� � ��������� ���������
// ���� ����� ��������� ������ �������������� �� �����, ���������� 0
int Expiration_Shift = 0;
// ����� ��������� ������, ���������� � �����
// ��� ����, ���� ������������ ��� ���������, ���������� ���������� Expiration_Shift (��. ���� �� 2 ������) "0" (��� �������)
// ���� ����� ��������� ������ �������������� �� �����, ���������� 0
int Expiration_Shift_H = 0;

// ����� ����������� ������� �� �������
color Buy_Color = Lime; //( ��� ������� BUYSTOP � BUYLIMIT )
color Sell_Color = Red; //( ��� ������� SELLLIMIT � SELLSTOP )

// ����� �����:
color Open_Price_Line_Color = White;
color Stop_Loss_Line_Color = Red;
color Take_Profit_Line_Color = Lime;
color Expiration_Line_Color = Yellow;

//+------------------------------------------------------------------+

double Open_Price_Level, Stop_Loss_Level, Take_Profit_Level;
datetime Expiration_Time;
int _break, error;
double DropPrice = PriceOnDropped();

// ����� ������
for ( int x = 0; x <= Order_Find_Radius; x ++ )
{
	int _OrdersTotal = OrdersTotal();
	for ( int z = _OrdersTotal - 1; z >= 0; z -- )
	{
		OrderSelect( z, SELECT_BY_POS, MODE_TRADES );
		if ( OrderSymbol() == Symbol() )
		{
			if ( ( DropPrice - OrderOpenPrice() )/Point <= x && ( DropPrice - OrderOpenPrice() )/Point >= 0 )
			{ _break = 1; break; }
			if ( ( OrderOpenPrice() - DropPrice )/Point <= x && ( OrderOpenPrice() - DropPrice )/Point >= 0 )
			{ _break = 1; break; }
		}
	}
	if ( _break == 1 ) { break; }
}

if ( _break != 1 )
{
	MessageBox(  "�� ������� ����� �����!\n\n" +
					 "����������� ������ �� ������ �������� �� ���� �������� ������, ������� ������ ��������������	", 
          	 	 "������ ������", 0x00000000 | 0x00000010 | 0x00040000 ); 
	return(0);
}

int _OrderType = OrderType();
int _OrderTicket = OrderTicket();
double _OrderOpenPrice = OrderOpenPrice();
double _OrderStopLoss = OrderStopLoss();
double _OrderTakeProfit = OrderTakeProfit();
datetime _OrderExpiration = OrderExpiration();

// ��������� ��������� ��������:
Open_Price_Level = _OrderOpenPrice;

if ( _OrderStopLoss > 0 )
{ Stop_Loss_Level = _OrderStopLoss; }
else
{
	if ( Stop_Loss > 0 )
	{
		if ( _OrderType == OP_BUY || _OrderType == OP_BUYSTOP || _OrderType == OP_BUYLIMIT )
		{ Stop_Loss_Level = Open_Price_Level - Stop_Loss*Point; }
		else
		{ Stop_Loss_Level = Open_Price_Level + Stop_Loss*Point; }
	}
}

if ( _OrderTakeProfit > 0 )
{ Take_Profit_Level = _OrderTakeProfit; }
else
{
	if ( Take_Profit > 0 )
	{
		if ( _OrderType == OP_BUY || _OrderType == OP_BUYSTOP || _OrderType == OP_BUYLIMIT )
		{ Take_Profit_Level = Open_Price_Level + Take_Profit*Point; }
		else
		{ Take_Profit_Level = Open_Price_Level - Take_Profit*Point; }
	}
}

if ( _OrderExpiration > 0 )
{ Expiration_Time = _OrderExpiration; }
else
{
	if ( _OrderType != OP_BUY && _OrderType != OP_SELL )
	{
		if ( Expiration_Shift > 0 )
		{ Expiration_Time = CurTime() + Period()*60*Expiration_Shift; }
		else
		{
			if ( Expiration_Shift_H > 0 )
				{ Expiration_Time = CurTime() + 3600*Expiration_Shift_H; }
		}
	}
}

// �������� �����:
if ( first == 1 )
{						
	ObjectCreate( "Open_Price_Line", OBJ_HLINE, 0, 0, Open_Price_Level, 0, 0, 0, 0 );
	ObjectSet( "Open_Price_Line", OBJPROP_COLOR, Open_Price_Line_Color );
	ObjectSetText( "Open_Price_Line", "Open_Price_Line", 6, "Arial", Open_Price_Line_Color );

	if ( Stop_Loss_Level > 0 )
	{
		ObjectCreate( "Stop_Loss_Line", OBJ_HLINE, 0, 0, Stop_Loss_Level, 0, 0, 0, 0 );
		ObjectSet( "Stop_Loss_Line", OBJPROP_COLOR, Stop_Loss_Line_Color );
		ObjectSetText( "Stop_Loss_Line", "Stop_Loss_Line", 6, "Arial", Stop_Loss_Line_Color );
	}

	if ( Take_Profit_Level > 0 )
	{
		ObjectCreate( "Take_Profit_Line", OBJ_HLINE, 0, 0, Take_Profit_Level, 0, 0, 0, 0 );
		ObjectSet( "Take_Profit_Line", OBJPROP_COLOR, Take_Profit_Line_Color );
		ObjectSetText( "Take_Profit_Line", "Take_Profit_Line", 6, "Arial", Take_Profit_Line_Color );
	}

	if ( Expiration_Time > 0 )
	{
		ObjectCreate( "Expiration_Line", OBJ_VLINE, 0, Expiration_Time, 0, 0, 0, 0, 0 );
		ObjectSet( "Expiration_Line", OBJPROP_COLOR, Expiration_Line_Color );
		ObjectSetText( "Expiration_Line", "Expiration_Line", 6, "Arial", Expiration_Line_Color );
	}

// ����� ������������
	string Question = "��� �������� ��������� ����������� ����� �� ����������� ������ � ������� \"��\".\n" + 
							"���� ���������� �� ����������� � ��������� ������, ������� \"������\".";
	int  Answer = MessageBox( Question, "����������� ������", 0x00000001 | 0x00000040 | 0x00040000  );
	first = 0;

	// ���� ������ ����� ����� "��" ������ - �������
	if ( Answer != 1 ) { deinit(); return(0); }
}
// ��������� �������� � �������� � �����������:
	Open_Price_Level = NormalizeDouble( ObjectGet( "Open_Price_Line", OBJPROP_PRICE1 ), MarketInfo( Symbol(), MODE_DIGITS ) );
	Stop_Loss_Level = NormalizeDouble( ObjectGet( "Stop_Loss_Line", OBJPROP_PRICE1 ), MarketInfo( Symbol(), MODE_DIGITS ) );
	Take_Profit_Level = NormalizeDouble( ObjectGet( "Take_Profit_Line", OBJPROP_PRICE1 ), MarketInfo( Symbol(), MODE_DIGITS ) );
	Expiration_Time = ObjectGet( "Expiration_Line", OBJPROP_TIME1 );
	
	if ( Open_Price_Level == 0 )
	{
		int order;
		if ( _OrderType == OP_BUY || _OrderType == OP_SELL )
		{
			if ( _OrderType == OP_BUY ) 
			{ order = OrderClose( _OrderTicket, OrderLots(), Bid, Slippage, Buy_Color ); }
			else
			{ order = OrderClose( _OrderTicket, OrderLots(), Ask, Slippage, Sell_Color ); }
		}
		else
		{ order = OrderDelete( _OrderTicket ); }

		if ( order > 0 )
		{
// ���� �� ��, ������� ��� � �������
			Print( "����� �", _OrderTicket, " ������/����� �������!");
			return(0);
		}
		else
		{
// ���� ������ - ������� ��������� � �������
			error = GetLastError();
			Print("������ ��� ��������/��������! GetLastError = ", error, ", ErrorDescription =  \"", ErrorDescription( error ), "\"" );
			MessageBox( "������ ��� ��������/��������! GetLastError = " + error + ", ErrorDescription = \"" + ErrorDescription( error ) + "\"", 
             	 			"������ ��������/�������� ������", 0x00000000 | 0x00000010 | 0x00040000 ); 
			return(-1);
		}
	return(0);
	}
	
	color _Color = Buy_Color;
// ��������� ��� ��������
	if ( _OrderType == OP_BUY )
	{
		if ( Bid - Stop_Loss_Level < MarketInfo( Symbol(), MODE_STOPLEVEL )*Point && Stop_Loss_Level != 0 )
		{
			Answer = MessageBox( "����������� ����������� Stop_Loss_Line (������� �����)!\n" + 
				 		 			 	"\n" +
				 		 			 	"��� Buy - ������� ��� ������ ���� ���� Bid.	\n" + 
				 		 			 	"����������� ������ (" + Symbol() + ") - " + DoubleToStr( MarketInfo( Symbol(), MODE_STOPLEVEL ), 0 ) + " �������.\n" + 
				 		 			 	"\n\n" +
				 		 			 	"����� ������ ����������� � ������, ������� \"������\".\n" +
				 		 			 	"���� ���������� �� �����������, ������� \"������\".", "����������� ������", 0x00000005 | 0x00000030 | 0x00040000 );
			if ( Answer == 4 ) { start(); }
			deinit();
			return(-1);
		}
		if ( Take_Profit_Level - Bid < MarketInfo( Symbol(), MODE_STOPLEVEL )*Point && Take_Profit_Level != 0 )
		{
			Answer = MessageBox( "����������� ����������� Take_Profit_Line (������ �����)!\n" + 
			 		 			 		"\n" +
			 		 			 		"��� Buy - ������� ��� ������ ���� ���� Bid.	\n" + 
			 		 			 		"����������� ������ (" + Symbol() + ") - " + DoubleToStr( MarketInfo( Symbol(), MODE_STOPLEVEL ), 0 ) + " �������.\n" + 
			 		 			 		"\n\n" +
			 		 			 		"����� ������ ����������� � ������, ������� \"������\".\n" +
			 		 			 		"���� ���������� �� �����������, ������� \"������\".", "����������� ������", 0x00000005 | 0x00000030 | 0x00040000 );
			if ( Answer == 4 ) { start(); }
			deinit();
			return(-1);
		}
	}

	if ( _OrderType == OP_BUYSTOP || _OrderType == OP_BUYLIMIT )
	{
		if ( Open_Price_Level - Stop_Loss_Level < MarketInfo( Symbol(), MODE_STOPLEVEL )*Point && Stop_Loss_Level != 0 )
		{
			Answer = MessageBox(  "����������� ����������� Stop_Loss_Line (������� �����)!\n" + 
					 		 			 "\n" +
					 		 			 "��� Buy, BuyLimit � BuyStop - ������� ��� ������ ���� ���� ����� Open_Price_Line.	\n" + 
					 		 			 "����������� ������ (" + Symbol() + ") - " + DoubleToStr( MarketInfo( Symbol(), MODE_STOPLEVEL ), 0 ) + " �������.\n" + 
					 		 			 "\n\n" +
					 		 			 "����� ������ ����������� � ������, ������� \"������\".\n" +
					 		 			 "���� ���������� �� �����������, ������� \"������\".", "����������� ������", 0x00000005 | 0x00000030 | 0x00040000 );
			if ( Answer == 4 ) { start(); }
			deinit();
			return(-1);
		}
		if ( Take_Profit_Level - Open_Price_Level < MarketInfo( Symbol(), MODE_STOPLEVEL )*Point && Take_Profit_Level != 0 )
		{
			Answer = MessageBox(  "����������� ����������� Take_Profit_Line (������ �����)!\n" + 
					 		 			 "\n" +
					 		 			 "��� Buy, BuyLimit � BuyStop - ������� ��� ������ ���� ���� ����� Open_Price_Line.	\n" + 
					 		 			 "����������� ������ (" + Symbol() + ") - " + DoubleToStr( MarketInfo( Symbol(), MODE_STOPLEVEL ), 0 ) + " �������.\n" + 
					 		 			 "\n\n" +
					 		 			 "����� ������ ����������� � ������, ������� \"������\".\n" +
					 		 			 "���� ���������� �� �����������, ������� \"������\".", "����������� ������", 0x00000005 | 0x00000030 | 0x00040000 );
			if ( Answer == 4 ) { start(); }
			deinit();
			return(-1);
		}
		if ( _OrderType == OP_BUYSTOP )
		{
			if ( Open_Price_Level - Bid < MarketInfo( Symbol(), MODE_STOPLEVEL )*Point )
			{
				Answer = MessageBox( "����������� ����������� Open_Price_Line (����� �����)!\n" + 
					 		 			 	"\n" +
					 		 			 	"��� BuyStop - ������ ��� ������ ���� ���� ������� ����.	\n" + 
					 		 			 	"����������� ������ (" + Symbol() + ") - " + DoubleToStr( MarketInfo( Symbol(), MODE_STOPLEVEL ), 0 ) + " �������.\n" + 
					 		 			 	"\n\n" +
					 		 			 	"����� ������ ����������� � ������, ������� \"������\".\n" +
					 		 			 	"���� ���������� �� �����������, ������� \"������\".", "����������� ������", 0x00000005 | 0x00000030 | 0x00040000 );
				if ( Answer == 4 ) { start(); }
				deinit();
				return(-1);
			}
		}
		if ( _OrderType == OP_BUYLIMIT )
		{
			if ( Bid - Open_Price_Level < MarketInfo( Symbol(), MODE_STOPLEVEL )*Point )
			{
				Answer = MessageBox( "����������� ����������� Open_Price_Line (����� �����)!\n" + 
					 		 			 	"\n" +
					 		 			 	"��� BuyLimit - ������ ��� ������ ���� ���� ������� ����.	\n" + 
					 		 			 	"����������� ������ (" + Symbol() + ") - " + DoubleToStr( MarketInfo( Symbol(), MODE_STOPLEVEL ), 0 ) + " �������.\n" + 
					 		 			 	"\n\n" +
					 		 			 	"����� ������ ����������� � ������, ������� \"������\".\n" +
					 		 			 	"���� ���������� �� �����������, ������� \"������\".", "����������� ������", 0x00000005 | 0x00000030 | 0x00040000 );
				if ( Answer == 4 ) { start(); }
				deinit();
				return(-1);
			}
		}

	}
	if ( _OrderType == OP_SELL )
	{
		_Color = Sell_Color;
		if ( Stop_Loss_Level - Ask < MarketInfo( Symbol(), MODE_STOPLEVEL )*Point && Stop_Loss_Level != 0 )
		{
			Answer = MessageBox(  "����������� ����������� Stop_Loss_Line (������� �����)!\n" + 
					 		 			 "\n" +
					 		 			 "��� Sell - ������� ��� ������ ���� ���� Ask.	\n" + 
					 		 			 "����������� ������ (" + Symbol() + ") - " + DoubleToStr( MarketInfo( Symbol(), MODE_STOPLEVEL ), 0 ) + " �������.\n" + 
					 		 			 "\n\n" +
					 		 			 "����� ������ ����������� � ������, ������� \"������\".\n" +
					 		 			 "���� ���������� �� �����������, ������� \"������\".", "����������� ������", 0x00000005 | 0x00000030 | 0x00040000 );
			if ( Answer == 4 ) { start(); }
			deinit();
			return(-1);
		}
		if ( Ask - Take_Profit_Level < MarketInfo( Symbol(), MODE_STOPLEVEL )*Point && Take_Profit_Level != 0 )
		{
			Answer = MessageBox(  "����������� ����������� Take_Profit_Line (������ �����)!\n" + 
					 		 			 "\n" +
					 		 			 "��� Sell - ������� ��� ������ ���� ���� Ask.	\n" + 
					 		 			 "����������� ������ (" + Symbol() + ") - " + DoubleToStr( MarketInfo( Symbol(), MODE_STOPLEVEL ), 0 ) + " �������.\n" + 
					 		 			 "\n\n" +
					 		 			 "����� ������ ����������� � ������, ������� \"������\".\n" +
					 		 			 "���� ���������� �� �����������, ������� \"������\".", "����������� ������", 0x00000005 | 0x00000030 | 0x00040000 );
			if ( Answer == 4 ) { start(); }
			deinit();
			return(-1);
		}
	}
	if ( _OrderType == OP_SELLLIMIT || _OrderType == OP_SELLSTOP )
	{
		_Color = Sell_Color;
		if ( Stop_Loss_Level - Open_Price_Level < MarketInfo( Symbol(), MODE_STOPLEVEL )*Point && Stop_Loss_Level != 0 )
		{
			Answer = MessageBox(  "����������� ����������� Stop_Loss_Line (������� �����)!\n" + 
					 		 			 "\n" +
					 		 			 "��� Sell, SellLimit � SellStop - ������� ��� ������ ���� ���� ����� Open_Price_Line.	\n" + 
					 		 			 "����������� ������ (" + Symbol() + ") - " + DoubleToStr( MarketInfo( Symbol(), MODE_STOPLEVEL ), 0 ) + " �������.\n" + 
					 		 			 "\n\n" +
					 		 			 "����� ������ ����������� � ������, ������� \"������\".\n" +
					 		 			 "���� ���������� �� �����������, ������� \"������\".", "����������� ������", 0x00000005 | 0x00000030 | 0x00040000 );
			if ( Answer == 4 ) { start(); }
			deinit();
			return(-1);
		}
		if ( Open_Price_Level - Take_Profit_Level < MarketInfo( Symbol(), MODE_STOPLEVEL )*Point && Take_Profit_Level != 0 )
		{
			Answer = MessageBox(  "����������� ����������� Take_Profit_Line (������ �����)!\n" + 
					 		 			 "\n" +
					 		 			 "��� Sell, SellLimit � SellStop - ������� ��� ������ ���� ���� ����� Open_Price_Line.	\n" + 
					 		 			 "����������� ������ (" + Symbol() + ") - " + DoubleToStr( MarketInfo( Symbol(), MODE_STOPLEVEL ), 0 ) + " �������.\n" + 
					 		 			 "\n\n" +
					 		 			 "����� ������ ����������� � ������, ������� \"������\".\n" +
					 		 			 "���� ���������� �� �����������, ������� \"������\".", "����������� ������", 0x00000005 | 0x00000030 | 0x00040000 );
			if ( Answer == 4 ) { start(); }
			deinit();
			return(-1);
		}
		if ( _OrderType == OP_SELLLIMIT )
		{
			if ( Open_Price_Level - Ask < MarketInfo( Symbol(), MODE_STOPLEVEL )*Point )
			{
				Answer = MessageBox( "����������� ����������� Open_Price_Line (����� �����)!\n" + 
					 		 			 	"\n" +
					 		 			 	"��� SellLimit - ������ ��� ������ ���� ���� ������� ����.	\n" + 
					 		 			 	"����������� ������ (" + Symbol() + ") - " + DoubleToStr( MarketInfo( Symbol(), MODE_STOPLEVEL ), 0 ) + " �������.\n" + 
					 		 			 	"\n\n" +
					 		 			 	"����� ������ ����������� � ������, ������� \"������\".\n" +
					 		 			 	"���� ���������� �� �����������, ������� \"������\".", "����������� ������", 0x00000005 | 0x00000030 | 0x00040000 );
				if ( Answer == 4 ) { start(); }
				deinit();
				return(-1);
			}
		}
		if ( _OrderType == OP_SELLSTOP )
		{
			if ( Ask - Open_Price_Level < MarketInfo( Symbol(), MODE_STOPLEVEL )*Point )
			{
				Answer = MessageBox( "����������� ����������� Open_Price_Line (����� �����)!\n" + 
					 		 			 	"\n" +
					 		 			 	"��� SellStop - ������ ��� ������ ���� ���� ������� ����.	\n" + 
					 		 			 	"����������� ������ (" + Symbol() + ") - " + DoubleToStr( MarketInfo( Symbol(), MODE_STOPLEVEL ), 0 ) + " �������.\n" + 
					 		 			 	"\n\n" +
					 		 			 	"����� ������ ����������� � ������, ������� \"������\".\n" +
					 		 			 	"���� ���������� �� �����������, ������� \"������\".", "����������� ������", 0x00000005 | 0x00000030 | 0x00040000 );
				if ( Answer == 4 ) { start(); }
				deinit();
				return(-1);
			}
		}
	}

	if ( _OrderType == OP_BUY || _OrderType == OP_SELL )
	{
		if ( Open_Price_Level != _OrderOpenPrice )
		{
			Answer = MessageBox( "������ ������� Open_Price_Line (����� �����) ��� ��� �������� �������!\n" + 
				 		 			 	"\n\n" +
				 		 			 	"����� ���������� ����� � ��������� ��������� � ������ ����������� � ������, ������� \"������\".\n" +
				 		 			 	"���� ���������� �� �����������, ������� \"������\".", "����������� ������", 0x00000005 | 0x00000030 | 0x00040000 );
			if ( Answer == 4 ) { ObjectSet( "Open_Price_Line", OBJPROP_PRICE1, _OrderOpenPrice ); start(); }
			deinit();
			return(-1);
		}
		if ( Expiration_Time != 0 )
		{
				Answer = MessageBox( "������ ������������� Expiration_Line (����� �����) ��� ��� �������� �������!\n" + 
					 		 			 	"\n\n" +
					 		 			 	"����� ������� ����� � ������ ����������� � ������, ������� \"������\".\n" +
					 		 			 	"���� ���������� �� �����������, ������� \"������\".", "����������� ������", 0x00000005 | 0x00000030 | 0x00040000 );
				if ( Answer == 4 ) {	ObjectDelete( "Expiration_Line" ); start(); }
				deinit();
				return(-1);
		}
	}
	else
	{
		if ( Expiration_Time <= CurTime() && Expiration_Time != 0 )
		{
				Answer = MessageBox( "����������� ����������� Expiration_Line (����� �����)!\n" + 
					 		 			 	"\n" +
					 		 			 	"���� ��������� ������ �� ����� ���� � ��������� �������!		\n" + 
					 		 			 	"\n\n" +
					 		 			 	"����� ������ ����������� � ������, ������� \"������\".\n" +
					 		 			 	"���� ���������� �� �����������, ������� \"������\".", "����������� ������", 0x00000005 | 0x00000030 | 0x00040000 );
				if ( Answer == 4 ) { start(); }
				deinit();
				return(-1);
		}
	}
	
// ������� ���� � ������� � �������� �������������� �����
	Print( "OrderTicket=",_OrderTicket, ",_OrderType=",_OrderType, ",Open_Price_Level=",Open_Price_Level, ",Stop_Loss_Level=", Stop_Loss_Level, ",Take_Profit_Level=", Take_Profit_Level, ",Expiration_Time=", Expiration_Time, ",_Color=", _Color );
	int ordermodify = OrderModify( _OrderTicket, Open_Price_Level, Stop_Loss_Level, Take_Profit_Level, Expiration_Time, _Color );
	if ( ordermodify > 0 )
	{
// ���� �� ��, ������� ��� � �������
		OrderPrint();
		Print( "����� �", _OrderTicket, " ������������� �������!");
		return(0);
	}
// ���� ������ - ������� ��������� � �������
	error = GetLastError();
	Print("������ ��� �����������! GetLastError = ", error, ", ErrorDescription =  \"", ErrorDescription( error ), "\"" );
	MessageBox( "������ ��� �����������! GetLastError = " + error + ", ErrorDescription = \"" + ErrorDescription( error ) + "\"", 
             	 	"������ ����������� ������", 0x00000000 | 0x00000010 | 0x00040000 ); 
return(-1);
}

int deinit()
{
// �������� ���� ��������, ��������� ��������
	ObjectDelete( "Open_Price_Line" );
	ObjectDelete( "Stop_Loss_Line" );
	ObjectDelete( "Take_Profit_Line" );
	ObjectDelete( "Expiration_Line" );
return(0);
}

