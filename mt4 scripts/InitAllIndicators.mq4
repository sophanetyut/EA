//+------------------------------------------------------------------+
//|                                            InitAllIndicators.mq4 |
//|                                 		 (C)opyright � 2008, Ilnur |
//|                                        http://www.metaquotes.net |
//+------------------------------------------------------------------+

// ������ ��� ����������������� ���� �����������, ������������� �������� ����.
// ��� ������ ������� ���������� ��������� ����� ������� �� ��������� DLL:
// ������ -> ���������  -> ��������� -> ��������� ������ DLL.

#property copyright "(C)opyright � 2008, Ilnur"
#property link      "http://www.metaquotes.net"

#include <WinUser32.mqh>

#import "user32.dll"
	int GetAncestor(int hWnd, int gaFlags);
	int GetLastActivePopup(int hWnd);
	int GetDlgItem(int hDlg, int nIDDlgItem);
#import

#define PAUSE 100

#define VK_HOME 0x24
#define VK_DOWN 0x28

#define GA_ROOT 2

#define TVM_GETCOUNT 0x1105

//+------------------------------------------------------------------+
//| �������� ���� "������ �����������" � ���������� ��� ����������   |
//+------------------------------------------------------------------+
int GetListDialog(int hOwnedWnd)
{
	int hDlgWnd;
//---- �������� ���� "������ �����������"
	PostMessageA(hOwnedWnd,WM_COMMAND,35419,0);
	Sleep(PAUSE);
//---- ���������� ���������� ����
	hDlgWnd = GetLastActivePopup(hOwnedWnd);
//----
	return(hDlgWnd);
}

//+------------------------------------------------------------------+
//| �������� ���� ������� ���������� � ���������� ��� ����������     |
//+------------------------------------------------------------------+
int GetPropertyDialog(int hOwnedWnd, int hListDlg)
{
	int hDlgWnd;
//---- �������� ���� ������� ���������� ����������
	PostMessageA(hListDlg,WM_COMMAND,0x48B,GetDlgItem(hListDlg,0x48B));
	Sleep(PAUSE);
//---- ���������� ���������� ����
	hDlgWnd = GetLastActivePopup(hOwnedWnd);
//----
	return(hDlgWnd);
}

//+------------------------------------------------------------------+
//| �������� ������� �������	                                     	|
//+------------------------------------------------------------------+
void start()
{
	int hParentWnd, hListDlg, hTreeView, hPropDlg;
	int nTreeCount;
//---- �������� ���������� ��������� ���� ���������
	hParentWnd = GetAncestor(WindowHandle(Symbol(),Period()),GA_ROOT);

	if(hParentWnd!=0)
	{
	//---- �������� ���� "������ �����������"
		hListDlg = GetListDialog(hParentWnd);
	//---- ������� ������ �����������
		hTreeView = GetDlgItem(hListDlg,0x48C); //
	//---- ���������� ����� ����� ������
		nTreeCount = SendMessageA(hTreeView,TVM_GETCOUNT,0,0);
	//---- ������������� ������ �� ������� ������� ������
		PostMessageA(hTreeView,WM_KEYDOWN,VK_HOME,0);
	//---- � ����� ���������� ���� ������
		for(int i=1; i<nTreeCount; i++)
		{
		//---- ������� ������ �� ��������� ������� ������
			PostMessageA(hTreeView,WM_KEYDOWN,VK_DOWN,0);
		//---- ��������� ���������� ������ "��������"
			if(IsWindowEnabled(GetDlgItem(hListDlg,0x48B))==0) continue;
		//---- �������� ���� ������� ����������� ����������
			hPropDlg = GetPropertyDialog(hParentWnd,hListDlg);
		//---- �������� ������ "��"
			PostMessageA(hPropDlg,WM_COMMAND,0x001,GetDlgItem(hPropDlg,0x001));
		}
	//---- ��������� ���� "������ �����������"
		PostMessageA(hListDlg,WM_COMMAND,0x001,GetDlgItem(hListDlg,0x001));
	}
}

