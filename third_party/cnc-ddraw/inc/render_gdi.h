#ifndef RENDER_GDI_H
#define RENDER_GDI_H

#define WIN32_LEAN_AND_MEAN
#include <windows.h>


DWORD WINAPI gdi_render_main(void);
extern LONG g_gdi_live_resize;

#endif
