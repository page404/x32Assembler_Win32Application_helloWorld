.386    ;��ʾָ�,����ǰ���� 16λָ���.
.model flat , stdcall ;model flat :��ʾ�ڴ�ģ��Ϊ flat    stdcall:Ĭ�ϵĵ���Լ��,�����������д,��ô,ÿ���������Ƕ�Ҫ�Լ�д����Լ��.
option casemap:none   ;���ִ�Сд,�����д��һ��,�����ִ�Сд.

;-------�����·�������� RadASM 32λ ����İ�װĿ¼�µ� include �� lib,Ҫ��Ȼ���ɲ��� exe �ļ�
;inc���
include C:\RadASM\masm32\include\windows.inc
include C:\RadASM\masm32\include\kernel32.inc
include C:\RadASM\masm32\include\user32.inc
include myres.inc
;lib���
includelib C:\RadASM\masm32\lib\kernel32.lib
includelib C:\RadASM\masm32\lib\user32.lib

;-------------���ζ�����Ⱥ�˳������ν,ÿ���ε���������һ���εĿ�ʼ,��������һ���ε���������end������һ���εĽ���.

.data    ;���ݶ�,�������ȫ�ֱ����;ֲ�����,������?,Ҳ���Գ�ʼ��.
    

.data?   ;δ��ʼ�������ݶ�,ֻ����?,���ܳ�ʼ��. (������ռ���̿ռ�,�ڴ�ռ仹��ͬ����ռ��)


.const   ;������,�öε�������ֻ����.
    g_szHello db 'Hello world!  please left click!',0    ;dos������$��Ϊ�ַ����Ľ�����,��386������İ汾��,��0��Ϊ�ַ����Ľ�����.
	g_szTitle db 'Page404',0

.code    ;�����   ----- �ڸ�����,�Զ���ĺ���˳��ǳ���Ҫ,�����õ�Ҫ������.����ʶ����.��C�����Զ���ĺ���ԭ��һ��.

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
   ; hInst Ϊȫ�ֱ�������ʱ�ò������Ȳ��ܡ�

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

	invoke RtlZeroMemory, addr @wcex, sizeof @wcex    ;��@wcex�ֲ���������
	
	; wcex.cbSize = sizeof(WNDCLASSEX); 
	mov @wcex.cbSize,sizeof WNDCLASSEX

	; wcex.style = CS_HREDRAW | CS_VREDRAW;
	mov @wcex.style,CS_HREDRAW or CS_VREDRAW
	
	; wcex.lpfnWndProc	= (WNDPROC)WndProc;
	mov @wcex.lpfnWndProc,offset WndProc      ;������д�� WndProc ����
	
	; wcex.cbClsExtra		= 0;
	mov @wcex.cbClsExtra,0
	
	; wcex.cbWndExtra		= 0;
	mov @wcex.cbWndExtra,0
	
	; wcex.hInstance = hInstance;
	;mov @wcex.hInstance,hInstance   �ڴ浽�ڴ棬����
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
	invoke RegisterClassEx,addr @wcex   ;invoke ʹ�þֲ����������� addr ����

    ret
MyRegisterClass endp

WinMain proc hInstance:HINSTANCE
    ;����ֲ������ṹ��
	local @msg:MSG

    ;MyRegisterClass(hInstance);
    invoke MyRegisterClass,hInstance  ;������д�� MyRegisterClass ����
	
	; if (!InitInstance (hInstance, nCmdShow)) 
	; {
		; return FALSE;
	; }
	invoke InitInstance,hInstance ;������д�� InitInstance ����
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
    
	invoke GetModuleHandle,NULL  ;��vc6.0�Զ����ɵ�win32 application�е�WinMain�����д�ϵ�,�ڶ�ջ��������,�ᷢ�� GetModuleHandle ����
	invoke WinMain,eax   ;������д�� WinMain ����
	
	;���� kernel32.dll �����˳�����
	invoke ExitProcess, 0 
end START














