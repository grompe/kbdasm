// This program shows VK_KANA status using Caps Lock indicator

#define _WIN32_WINNT 0x500
#include <windows.h>
#include <tchar.h>
#include <stdint.h>
#include <winioctl.h>


#define IOCTL_KEYBOARD_SET_INDICATORS        CTL_CODE(FILE_DEVICE_KEYBOARD, 0x0002, METHOD_BUFFERED, FILE_ANY_ACCESS)
#define IOCTL_KEYBOARD_QUERY_TYPEMATIC       CTL_CODE(FILE_DEVICE_KEYBOARD, 0x0008, METHOD_BUFFERED, FILE_ANY_ACCESS)
#define IOCTL_KEYBOARD_QUERY_INDICATORS      CTL_CODE(FILE_DEVICE_KEYBOARD, 0x0010, METHOD_BUFFERED, FILE_ANY_ACCESS)

HHOOK  g_hHook;
HANDLE g_hEvent;
static HANDLE kbd;

void failed(const TCHAR *msg) 
{
  MessageBox(NULL, msg, _T("Error"), MB_OK | MB_ICONERROR);
  ExitProcess(1);
}

void OpenKeyboardDevice()
{
  if(!DefineDosDevice(DDD_RAW_TARGET_PATH, "Kbd", "\\Device\\KeyboardClass0"))
  {
    failed(_T("OpenKeyboardDevice()"));
  }

  kbd = CreateFile("\\\\.\\Kbd", GENERIC_WRITE, 0, NULL, OPEN_EXISTING, 0, NULL);
  if (!kbd)
  {
    failed(_T("OpenKeyboardDevice()#2"));
  }
}

void CloseKeyboardDevice()
{
  DefineDosDevice(DDD_REMOVE_DEFINITION, "Kbd", NULL);
  CloseHandle(kbd);
}

int toggle_led(BOOL toggle, int led)
{
  uint32_t input = 0, output = 0;

  DWORD len;
  if(!DeviceIoControl(kbd, IOCTL_KEYBOARD_QUERY_INDICATORS,
    &input, sizeof(input),
    &output, sizeof(output),
    &len, NULL))
  {
    return GetLastError();
  }

  input = output;
  if(toggle)
  {
    input &= ~(led << 16);
  } else {
    input |= led << 16;
  }
  if(!DeviceIoControl(kbd, IOCTL_KEYBOARD_SET_INDICATORS,
          &input, sizeof(input),
          NULL, 0,
          &len, NULL))
    return GetLastError();
  return 0;
}

LRESULT CALLBACK KeyboardHook(int nCode, WPARAM wParam, LPARAM lParam) 
{
  if (nCode == HC_ACTION) 
  {
    KBDLLHOOKSTRUCT *ks = (KBDLLHOOKSTRUCT*)lParam;
    if(wParam == WM_KEYDOWN) 
    {
      UINT key = ks->vkCode;
      UINT kana;
      switch (key)
      {
        case VK_KANA:
          kana = GetKeyState(VK_KANA);
          if (kana == 0 || kana == 1)
          {
            //toggle_led(kana ? 1 : 0, 4);
            toggle_led(kana, 4);
          }
          break;
        default: ;
      }
    }
    if(wParam == WM_KEYUP) 
    {
      UINT key = ks->vkCode;
      switch (key)
      {
        case VK_NUMLOCK:
        case VK_SCROLL:
        case VK_CAPITAL:
          toggle_led(GetKeyState(VK_KANA) ? 0 : 1, 4);
          break;
        default: ;
      }
    }
  }
  return CallNextHookEx(g_hHook, nCode, wParam, lParam);
}

void CALLBACK TimerCallback(HWND hWnd, UINT uMsg, UINT_PTR idEvent, DWORD dwTime)
{
  if (WaitForSingleObject(g_hEvent, 0) == WAIT_OBJECT_0)
    PostQuitMessage(0);
}

void xMain() 
{
  MSG msg;

  g_hEvent = CreateEvent(NULL, TRUE, FALSE, _T("_53_kana_led"));
  if (g_hEvent == NULL)
    failed(_T("CreateEvent()"));

  if (GetLastError() == ERROR_ALREADY_EXISTS) 
  {
    failed(_T("kana_led is already running!"));
  }

  if (SetTimer(NULL, 0, 500, TimerCallback) == 0)
    failed(_T("SetTimer()"));

  g_hHook = SetWindowsHookEx(WH_KEYBOARD_LL, KeyboardHook, GetModuleHandle(0), 0);
  if (!g_hHook)
    failed(_T("SetWindowsHookEx()"));

  OpenKeyboardDevice();
  
  while (GetMessage(&msg, 0, 0, 0)) 
  {
    TranslateMessage(&msg);
    DispatchMessage(&msg);
  }

  CloseKeyboardDevice();

  UnhookWindowsHookEx(g_hHook);
  CloseHandle(g_hEvent);
  ExitProcess(0);
}
