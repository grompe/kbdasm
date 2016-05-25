kbdasm by Grom PE
May, 2016

Assembler/disassembler of Windows keyboard layouts in flat assembler


How to use kbdusru_undead keyboard layout
=========================================
1. >make.bat
2. >install.bat
3. >open_control_input.bat
4. Set the new keyboard layout
5. Restart programs you're typing in


How to modify an existing keyboard layout
=========================================
1. >diskbd.bat kbdtarget.dll
2. edit kbdtarget_source.asm
3. >make.bat kbdtarget_source.asm


How to install custom keyboard layout
=====================================
1. >install.bat kbdtarget.dll
2. >open_control_input.bat
3. Set the new keyboard layout
4. Restart programs you're typing in


Note that you can also drag&drop target files on the .bat files.


flat assembler Copyright (c) 1999-2013, Tomasz Grysztar.
http://flatassembler.net/

The rest is public domain.
