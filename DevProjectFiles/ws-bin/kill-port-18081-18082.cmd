@echo off & setlocal EnableDelayedExpansion

echo ============================================
echo == 端口清理脚本
echo ============================================

title 杀死本机占用端口 kill port

rem ============================================
rem = 输入端口       
rem ============================================
set inputPort[0]=18081
set inputPort[1]=18082

rem ============================================
rem = local vars    
rem ============================================
set port=0
set pid=0
set localAddr=0:0
set localIp=0
rem ==================

for /f "usebackq delims== tokens=1-2" %%a in (`set inputPort`) do (
  set port=%%b
  for /f "tokens=2,5" %%b in ('netstat -ano ^| findstr ":!port!"') do (
    set pid=%%c
    set localAddr=%%b
    rem echo findstr=!port!	Local Address=!localAddr!	pid=!pid!
    for /f "usebackq delims=: tokens=1,2" %%i in (`set localAddr`) do (
      echo 【%%j】!port!
      if %%j==!port! (
        taskkill /f /pid !pid!
        echo 查找端口=!port!	本地地址=!localAddr!	进程pid=!pid!	清理进程成功!
      ) else (
        echo 查找端口=!port!	本地地址=!localAddr!	进程pid=!pid!	非本地端口,不需要清理!
      )
    )
  )
  if !pid!==0 (
    echo 查找端口=!port!	本地地址=!localAddr!	进程pid=!pid! 没有占用,不需要清理! 
  )
)

echo ============================================
echo 端口 !inputPort[0]! !inputPort[1]! !inputPort[2]! !inputPort[3]! !inputPort[4]! !inputPort[5]! 相关进程清理已操作完成！

pause