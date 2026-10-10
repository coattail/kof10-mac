/* Close the emulator through its normal window-close path, preserving settings. */
#define UNICODE
#define _UNICODE
#define _WIN32_WINNT 0x0600
#include <windows.h>

static BOOL CALLBACK close_emulator(HWND window, LPARAM unused)
{
    DWORD pid = 0;
    WCHAR path[1024];
    DWORD length = sizeof(path) / sizeof(path[0]);
    HANDLE process;
    (void)unused;
    GetWindowThreadProcessId(window, &pid);
    process = OpenProcess(PROCESS_QUERY_LIMITED_INFORMATION, FALSE, pid);
    if (!process) return TRUE;
    if (QueryFullProcessImageNameW(process, 0, path, &length)
        && lstrcmpiW(path, L"C:\\KOF\\game.exe") == 0)
        PostMessageW(window, WM_CLOSE, 0, 0);
    CloseHandle(process);
    return TRUE;
}

void WINAPI mainCRTStartup(void)
{
    EnumWindows(close_emulator, 0);
    ExitProcess(0);
}
