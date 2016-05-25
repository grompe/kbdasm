@echo off
gcc -m32 -Wall -O2 -fno-ident -fomit-frame-pointer -fno-exceptions -fno-asynchronous-unwind-tables -flto -s kana_led.c -nostdlib -lkernel32 -luser32 -lshell32 -lmsvcrt -Wl,-e_xMain -mwindows
