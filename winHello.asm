.386    ;表示指令集,再往前就是 16位指令集了.
.model flat , stdcall ;model flat :表示内存模型为 flat    stdcall:默认的调用约定,如果不在这里写,那么,每个函数我们都要自己写调用约定.
option casemap:none   ;区分大小写,如果不写这一行,不区分大小写.

;-------这里的路径必须是 RadASM 32位 软件的安装目录下的 include 跟 lib,要不然生成不了 exe 文件
;inc相关
include C:\RadASM\masm32\include\windows.inc
include C:\RadASM\masm32\include\kernel32.inc
include C:\RadASM\masm32\include\user32.inc
include myres.inc
;lib相关
includelib C:\RadASM\masm32\lib\kernel32.lib
includelib C:\RadASM\masm32\lib\user32.lib

;-------------各段定义的先后顺序无所谓,每个段的声明就是一个段的开始,当遇到下一个段的声明或者end就是上一个段的结束.

.data    ;数据段,用来存放全局变量和局部变量,可以用?,也可以初始化.
    

.data?   ;未初始化的数据段,只能用?,不能初始化. (几乎不占磁盘空间,内存空间还是同样会占用)


.const   ;常量段,该段的内容是只读的.
    g_szHello db 'Hello world!  please left click!',0    ;dos下是以$作为字符串的结束符,在386及往后的版本中,以0作为字符串的结束符.
	g_szTitle db 'Page404',0

.code    ;代码段   ----- 在该例中,自定义的函数顺序非常重要,被调用的要放上面.否则识别不了.跟C语言自定义的函数原理一样.

WndProc proc hWnd:HWND,message:UINT,wParam:WPARAM,lParam:LPARAM

    ; int wmId, wmEvent;
	
	; PAINTSTRUCT ps;
	local @ps:PAINTSTRUCT
	
	; HDC hdc;
	local @hdc:HDC
	
	local @rt:RECT
	
	; TCHAR szHello[MAX_LOADSTRING];
	; LoadString(hInst, IDS_HELLO, szHello, MAX_LOADSTRING);

	; switch (message) 
	; {
		; case WM_COMMAND:
			; wmId    = LOWORD(wParam); 
			; wmEvent = HIWORD(wParam); 
			; // Parse the menu selections:
			; switch (wmId)
			; {
				; case IDM_ABOUT:
				   ; DialogBox(hInst, (LPCTSTR)IDD_ABOUTBOX, hWnd, (DLGPROC)About);
				   ; break;
				; case IDM_EXIT:
				   ; DestroyWindow(hWnd);
				   ; break;
				; default:
				   ; return DefWindowProc(hWnd, message, wParam, lParam);
			; }
			; break;
		; case WM_PAINT:
			; hdc = BeginPaint(hWnd, &ps);
			; // TODO: Add any drawing code here...
			; RECT rt;
			; GetClientRect(hWnd, &rt);
			; DrawText(hdc, szHello, strlen(szHello), &rt, DT_CENTER);
			; EndPaint(hWnd, &ps);
			; break;
		; case WM_DESTROY:
			; PostQuitMessage(0);
			; break;
		; default:
			; return DefWindowProc(hWnd, message, wParam, lParam);
   ; }
   ; return 0;
   
    .if message == WM_LBUTTONDOWN
    invoke MessageBox, NULL, offset g_szHello, offset g_szTitle, MB_OK

  .elseif message == WM_PAINT
    invoke BeginPaint, hWnd, addr @ps
    mov @hdc, eax
    invoke GetClientRect, hWnd, addr @rt
    invoke DrawText, @hdc, offset g_szHello, sizeof g_szHello - 1,
      addr @rt, DT_CENTER or DT_VCENTER or DT_SINGLELINE
    invoke EndPaint, hWnd, addr @ps

  .elseif message == WM_DESTROY
    invoke PostQuitMessage, 0

  .else
    invoke DefWindowProc, hWnd, message, wParam, lParam
    ret
  .endif
	
	xor eax,eax
	
	ret
WndProc endp

InitInstance proc hInstance:HINSTANCE

   ; HWND hWnd;
   local @hWnd:HWND

   ; hInst = hInstance; // Store instance handle in our global variable
   ; hInst 为全局变量，暂时用不到，先不管。

   ; hWnd = CreateWindow(szWindowClass, szTitle, WS_OVERLAPPEDWINDOW,CW_USEDEFAULT, 0, CW_USEDEFAULT, 0, NULL, NULL, hInstance, NULL);

						 
	invoke CreateWindowEx, NULL, offset g_szHello, offset g_szTitle, 
    WS_OVERLAPPEDWINDOW, CW_USEDEFAULT, 0, CW_USEDEFAULT, 0, 
    NULL, NULL, hInstance, NULL
	
   mov @hWnd,eax

   ; if (!hWnd)
   ; {
      ; return FALSE;
   ; }
   .if !@hWnd
       mov eax,FALSE
   .endif

   ; ShowWindow(hWnd, nCmdShow);
   invoke ShowWindow,@hWnd,SW_SHOW
   
   ; UpdateWindow(hWnd);
   invoke UpdateWindow,@hWnd

   ; return TRUE;
   mov eax,TRUE

    ret
InitInstance endp

MyRegisterClass proc hInstance:HINSTANCE

    ; WNDCLASSEX wcex;
	local @wcex:WNDCLASSEX

	invoke RtlZeroMemory, addr @wcex, sizeof @wcex    ;给@wcex局部变量清零
	
	; wcex.cbSize = sizeof(WNDCLASSEX); 
	mov @wcex.cbSize,sizeof WNDCLASSEX

	; wcex.style = CS_HREDRAW | CS_VREDRAW;
	mov @wcex.style,CS_HREDRAW or CS_VREDRAW
	
	; wcex.lpfnWndProc	= (WNDPROC)WndProc;
	mov @wcex.lpfnWndProc,offset WndProc      ;我们重写了 WndProc 函数
	
	; wcex.cbClsExtra		= 0;
	mov @wcex.cbClsExtra,0
	
	; wcex.cbWndExtra		= 0;
	mov @wcex.cbWndExtra,0
	
	; wcex.hInstance = hInstance;
	;mov @wcex.hInstance,hInstance   内存到内存，报错
	push hInstance
	pop @wcex.hInstance
	
	; wcex.hbrBackground	= (HBRUSH)(COLOR_WINDOW+1);
	mov @wcex.hbrBackground,COLOR_WINDOW+1
	
	; wcex.lpszClassName	= szWindowClass;
	mov @wcex.lpszClassName,offset g_szHello
	
	;wcex.hIcon	= LoadIcon(hInstance, (LPCTSTR)IDI_HELLOWORLD);
	invoke LoadIcon, hInstance, IDI_HELLO
	mov @wcex.hIcon, eax
	
	;wcex.lpszMenuName	= (LPCSTR)IDC_HELLOWORLD;
	mov @wcex.lpszMenuName, IDM_TESTSDK
	
	;wcex.hIconSm = LoadIcon(wcex.hInstance, (LPCTSTR)IDI_SMALL);
	invoke LoadIcon, hInstance, IDI_HELLO
    mov @wcex.hIconSm, eax

	; return RegisterClassEx(&wcex);
	invoke RegisterClassEx,addr @wcex   ;invoke 使用局部变量必须用 addr 修饰

    ret
MyRegisterClass endp

WinMain proc hInstance:HINSTANCE
    ;定义局部变量结构体
	local @msg:MSG

    ;MyRegisterClass(hInstance);
    invoke MyRegisterClass,hInstance  ;我们重写了 MyRegisterClass 函数
	
	; if (!InitInstance (hInstance, nCmdShow)) 
	; {
		; return FALSE;
	; }
	invoke InitInstance,hInstance ;我们重写了 InitInstance 函数
	.if !eax
	    mov eax,FALSE
		ret
	.endif
	
	; while (GetMessage(&msg, NULL, 0, 0)) 
	; {
		; if (!TranslateAccelerator(msg.hwnd, hAccelTable, &msg)) 
		; {
			; TranslateMessage(&msg);
			; DispatchMessage(&msg);
		; }
	; }
	invoke GetMessage,addr @msg,NULL,0,0
	.while eax
	    invoke DispatchMessage,addr @msg
		invoke GetMessage,addr @msg,NULL,0,0
	.endw

	;return msg.wParam;
	mov eax,@msg.wParam
	
    ret
WinMain endp

START:
    
	invoke GetModuleHandle,NULL  ;在vc6.0自动生成的win32 application中的WinMain函数中打断点,在堆栈中往上找,会发现 GetModuleHandle 函数
	invoke WinMain,eax   ;我们重写了 WinMain 函数
	
	;调用 kernel32.dll 正常退出程序
	invoke ExitProcess, 0 
end START














