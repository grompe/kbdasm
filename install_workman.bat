@echo off
if not exist layouts\workman.dll call make layouts\workman.asm
install layouts\workman.dll 07440409 00d2 "US+W" "Workman US-Custom"
