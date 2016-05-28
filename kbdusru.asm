="utf8"
; kbdasm by Grom PE. Public domain.
; kbdusru - US/RU hybrid keyboard layout with Caps Lock remapped to Kana
;           to switch languages

format PE64 DLL native 5.0 at 5ffffff0000h on "nul" as "dll" ; Build for 64-bit Windows
;format PE DLL native 5.0 at 5fff0000h on "nul" as "dll" ; Build for 32-bit Windows or WOW64

MAKE_DLL equ 1

include "base.inc"

WOW64 = 0 ; Use when assembling for 32-bit subsystem for 64-bit OS (Is this ever needed?)
USE_DEAD_KEYS = 1
USE_LIGATURES = 1 ; There is a bug in Firefox, if ligatures contain more than
                  ; 4 characters, it won't start up if that layout is default;
                  ; if the layout is switched to, Firefox then hangs.
                  ; See also:
                  ; http://www.unicode.org/mail-arch/unicode-ml/y2015-m08/0012.html
USE_KANA = 1 ; Use Kana key to switch between English and Russian layout
DEBUG = 0

section ".data" readable executable

keynames:
    dp 01h, "ESC"
    dp 0Eh, "BACKSPACE"
    dp 0Fh, "TAB"
    dp 1Ch, "ENTER"
    dp 1Dh, "CTRL"
    dp 2Ah, "SHIFT"
    dp 36h, "RIGHT SHIFT"
    dp 37h, "NUMMULT"
    dp 38h, "ALT"
    dp 39h, "SPACE"
    dp 3Ah, "CAPSLOCK"
    dp 3Bh, "F1"
    dp 3Ch, "F2"
    dp 3Dh, "F3"
    dp 3Eh, "F4"
    dp 3Fh, "F5"
    dp 40h, "F6"
    dp 41h, "F7"
    dp 42h, "F8"
    dp 43h, "F9"
    dp 44h, "F10"
    dp 45h, "Pause"
    dp 46h, "SCROLL LOCK"
    dp 47h, "NUM 7"
    dp 48h, "NUM 8"
    dp 49h, "NUM 9"
    dp 4Ah, "NUM SUB"
    dp 4Bh, "NUM 4"
    dp 4Ch, "NUM 5"
    dp 4Dh, "NUM 6"
    dp 4Eh, "NUM PLUS"
    dp 4Fh, "NUM 1"
    dp 50h, "NUM 2"
    dp 51h, "NUM 3"
    dp 52h, "NUM 0"
    dp 53h, "NUM DECIMAL"
    dp 57h, "F11"
    dp 58h, "F12"
    dp 0, 0

palign

keynamesExt:
    dp 1Ch, "NUM ENTER"
    dp 1Dh, "Right Ctrl"
    dp 35h, "NUM DIVIDE"
    dp 37h, "Prnt Scrn"
    dp 38h, "RIGHT ALT"
    dp 45h, "Num Lock"
    dp 46h, "Break"
    dp 47h, "HOME"
    dp 48h, "UP"
    dp 49h, "PGUP"
    dp 4Bh, "LEFT"
    dp 4Dh, "RIGHT"
    dp 4Fh, "END"
    dp 50h, "DOWN"
    dp 51h, "PGDOWN"
    dp 52h, "INSERT"
    dp 53h, "DELETE"
    dp 54h, "<00>"
    dp 56h, "Help"
    dp 5Bh, "Left Windows"
    dp 5Ch, "Right Windows"
    dp 5Dh, "Application"
    dp 0, 0

palign

if used keynamesDead
keynamesDead:
    dp "´ACUTE"
    dp "˝DOUBLE ACUTE"
    dp "`GRAVE"
    dp "^CIRCUMFLEX"
    dp '¨UMLAUT'
    dp "~TILDE"
    dp "ˇCARON"
    dp "°RING"
    dp "¸CEDILLA"
    dp "¯MACRON" 
    dp 0

palign
end if

if used ligatures
ligatures: .:
    dw "M" ; VKey
    dw 3   ; Modifiers; Shift + AltGr; basically is the column number in vk2wchar* tables that contains WCH_LGTR
    du "ಠ_ಠ", WCH_NONE ; If less than max characters are used, the rest must be filled with WCH_NONE
ligature_size = $ - .
if DEBUG
    dw VK_CLEAR ; VKey
    dw 0        ; Modifiers
    du "v05."
end if
    db ligatureEntry dup 0

palign
end if

if USE_DEAD_KEYS
  deadkeys_if_used = deadkeys
  keynamesDead_if_used = keynamesDead
else
  deadkeys_if_used = 0
  keynamesDead_if_used = 0
end if

if USE_LIGATURES
  ligatureMaxChars = (ligature_size - 4) / 2
  if ligatureMaxChars > 4
    err "4 characters is max for a ligature on Windows XP or if you use Firefox"
  end if
;  if ligatureMaxChars > 16
;    err "16 characters is max for a ligature on Windows 7"
;  end if
  ligatureEntry = ligature_size
  ligatures_if_used = ligatures
else
  ligatureMaxChars = 0
  ligatureEntry = 0
  ligatures_if_used = 0
end if

KbdTables:
    dp modifiers
    dp vk2wchar
    dp deadkeys_if_used
    dp keynames         ; Names of keys
    dp keynamesExt
    dp keynamesDead_if_used
    dp scancode2vk      ; Scan codes to virtual keys
    db scancode2vk.size / 2
    palign
    dp e0scancode2vk
    dp e1scancode2vk
    dw KLLF_ALTGR       ; Locale flags
    dw KBD_VERSION
    db ligatureMaxChars ; Maximum ligature table characters
    db ligatureEntry    ; Count of bytes in each ligature row
    palign
    dp ligatures_if_used
    dd 0, 0             ; Type, subtype

palign

vk2bits:
    db VK_SHIFT,   KBDSHIFT
    db VK_CONTROL, KBDCTRL
    db VK_MENU,    KBDALT
if USE_KANA
    db VK_KANA,    KBDKANA
end if
    db 0, 0

palign

modifiers:
    dp vk2bits
    dw modifiers_max
.start:
    db 0            ; ---- --- ---- -----
    db 1            ; ---- --- ---- SHIFT
    db 4            ; ---- --- CTRL -----
    db 5            ; ---- --- CTRL SHIFT
    db SHFT_INVALID ; ---- ALT ---- -----
    db SHFT_INVALID ; ---- ALT ---- SHIFT
    db 2            ; ---- ALT CTRL ----- (Alt+Ctrl = AltGr)
    db 3            ; ---- ALT CTRL SHIFT
if USE_KANA
    db 6            ; KANA --- ---- -----
    db 7            ; KANA --- ---- SHIFT
    db SHFT_INVALID ; KANA --- CTRL -----
    db SHFT_INVALID ; KANA --- CTRL SHIFT
    db SHFT_INVALID ; KANA ALT ---- -----
    db SHFT_INVALID ; KANA ALT ---- SHIFT
    db 8            ; KANA ALT CTRL -----
    db 9            ; KANA ALT CTRL SHIFT
end if
modifiers_max = $ - .start - 1

palign

vk2wchar1:
if DEBUG
    vkrow1 VK_CLEAR,   0, WCH_LGTR
end if
    vkrow1 VK_NUMPAD0, 0, "0"
    vkrow1 VK_NUMPAD1, 0, "1"
    vkrow1 VK_NUMPAD2, 0, "2"
    vkrow1 VK_NUMPAD3, 0, "3"
    vkrow1 VK_NUMPAD4, 0, "4"
    vkrow1 VK_NUMPAD5, 0, "5"
    vkrow1 VK_NUMPAD6, 0, "6"
    vkrow1 VK_NUMPAD7, 0, "7"
    vkrow1 VK_NUMPAD8, 0, "8"
    vkrow1 VK_NUMPAD9, 0, "9"
    dw 0, 0, 0

palign

vk2wchar2:
if ~ USE_KANA
    vkrow2 VK_DECIMAL,  0, ".", "."
end if
    vkrow2 VK_TAB,      0, 9,   9
    vkrow2 VK_ADD,      0, "+", "+"
    vkrow2 VK_DIVIDE,   0, "/", "/"
    vkrow2 VK_MULTIPLY, 0, "*", "*"
    vkrow2 VK_SUBTRACT, 0, "-", "-"
    dw 0, 0, 2 dup 0

palign

vk2wchar4:
if ~ USE_KANA
  if USE_DEAD_KEYS
    vkrow4 VK_GRAVE,      0,                    "`",      "~",      WCH_DEAD, WCH_DEAD
    vkrow4 -1,            0,                    WCH_NONE, WCH_NONE, "`",      "~"
  else
    vkrow4 VK_GRAVE,      0,                    "`",      "~",      WCH_NONE, WCH_NONE
  end if
    vkrow4 "1",           0,                    "1",      "!",      "¡",      "¹"
    vkrow4 "2",           0,                    "2",      "@",      "²",      "½"
    vkrow4 "3",           0,                    "3",      "#",      "³",      "⅓"
    vkrow4 "4",           0,                    "4",      "$",      "£",      "¢"
    vkrow4 "5",           0,                    "5",      "%",      "€",      "‰"
  if USE_DEAD_KEYS
    vkrow4 "6",           0,                    "6",      "^",      WCH_DEAD, WCH_DEAD
    vkrow4 -1,            0,                    WCH_NONE, WCH_NONE, "^",      "ˇ"
  else
    vkrow4 "6",           0,                    "6",      "^",      "^",      "ˇ"
  end if
    vkrow4 "7",           0,                    "7",      "&",      "＆",      "•"
    vkrow4 "8",           0,                    "8",      "*",      "∞",      "×"
    vkrow4 "9",           0,                    "9",      "(",      "‘",      "“"
    vkrow4 "0",           0,                    "0",      ")",      "’",      "”"
end if ; ~ USE_KANA
    vkrow4 VK_MINUS,      0,                    "-",      "_",      "—",      "–"
    vkrow4 VK_EQUALS,     0,                    "=",      "+",      "≠",      "±"
if ~ USE_KANA
    vkrow4 "Q",           CAPLOK + CAPLOKALTGR, "q",      "Q",      "ä",      "Ä"
    vkrow4 "W",           CAPLOK + CAPLOKALTGR, "w",      "W",      "å",      "Å"
    vkrow4 "E",           CAPLOK + CAPLOKALTGR, "e",      "E",      "é",      "É"
    vkrow4 "R",           CAPLOK,               "r",      "R",      "®",      "©"
    vkrow4 "T",           CAPLOK + CAPLOKALTGR, "t",      "T",      "þ",      "Þ"
    vkrow4 "Y",           CAPLOK + CAPLOKALTGR, "y",      "Y",      "ü",      "Ü"
    vkrow4 "U",           CAPLOK + CAPLOKALTGR, "u",      "U",      "ú",      "Ú"
    vkrow4 "I",           CAPLOK + CAPLOKALTGR, "i",      "I",      "í",      "Í"
    vkrow4 "O",           CAPLOK + CAPLOKALTGR, "o",      "O",      "ó",      "Ó"
    vkrow4 "P",           CAPLOK + CAPLOKALTGR, "p",      "P",      "ö",      "Ö"
    vkrow4 "A",           CAPLOK + CAPLOKALTGR, "a",      "A",      "á",      "Á"
    vkrow4 "S",           CAPLOK,               "s",      "S",      "ß",      "§"
    vkrow4 "D",           CAPLOK + CAPLOKALTGR, "d",      "D",      "ð",      "Ð"
    vkrow4 "F",           CAPLOK,               "f",      "F",      "█",      "▓"
    vkrow4 "G",           CAPLOK,               "g",      "G",      "░",      "▒"
    vkrow4 "H",           CAPLOK,               "h",      "H",      "▀",      "▌"
    vkrow4 "J",           CAPLOK,               "j",      "J",      "▄",      "▐"
    vkrow4 "K",           CAPLOK,               "k",      "K",      "ø",      "Ø"
    vkrow4 "L",           CAPLOK + CAPLOKALTGR, "l",      "L",      "ł",      "Ł"
  if USE_DEAD_KEYS
    vkrow4 VK_SEMICOLON,  0,                    ";",      ":",      "°",      WCH_DEAD
    vkrow4 -1,            0,                    WCH_NONE, WCH_NONE, WCH_NONE, "°"
    vkrow4 VK_APOSTROPHE, 0,                    "'",      '"',      WCH_DEAD, WCH_DEAD
    vkrow4 -1,            0,                    WCH_NONE, WCH_NONE, "´",      "¨"
  else
    vkrow4 VK_SEMICOLON,  0,                    ";",      ":",      "°",      "¶"
    vkrow4 VK_APOSTROPHE, 0,                    "'",      '"',      "´",      "¨"
  end if
    vkrow4 "Z",           CAPLOK + CAPLOKALTGR, "z",      "Z",      "æ",      "Æ"
    vkrow4 "X",           CAPLOK + CAPLOKALTGR, "x",      "X",      "œ",      "Œ"
    vkrow4 "C",           CAPLOK + CAPLOKALTGR, "c",      "C",      "ç",      "Ç"
    vkrow4 "V",           CAPLOK + CAPLOKALTGR, "v",      "V",      "ő",      "Ő"
    vkrow4 "B",           CAPLOK + CAPLOKALTGR, "b",      "B",      "ű",      "Ű"
    vkrow4 "N",           CAPLOK + CAPLOKALTGR, "n",      "N",      "ñ",      "Ñ"
  if USE_LIGATURES
    vkrow4 "M",           CAPLOK,               "m",      "M",      "µ",      WCH_LGTR
  else
    vkrow4 "M",           CAPLOK,               "m",      "M",      "µ",      WCH_NONE
  end if
  if USE_DEAD_KEYS
    vkrow4 VK_COMMA,      0,                    ",",      "<",      WCH_DEAD, "←"
    vkrow4 -1,            0,                    WCH_NONE, WCH_NONE, "¸",      WCH_NONE
    vkrow4 VK_PERIOD,     0,                    ".",      ">",      WCH_DEAD, "→"
    vkrow4 -1,            0,                    WCH_NONE, WCH_NONE, "¯",      WCH_NONE
  else
    vkrow4 VK_COMMA,      0,                    ",",      "<",      "«",      "←"
    vkrow4 VK_PERIOD,     0,                    ".",      ">",      "»",      "→"
  end if
    vkrow4 VK_SLASH,      0,                    "/",      "?",      "¿",      "̶" ; combining long stroke overlay
end if ; ~ USE_KANA
    dw 0, 0, 4 dup 0

palign

vk2wchar5:
if ~ USE_KANA
    vkrow5 VK_LBRACKET,  0, "[", "{", "«",      "↑",      01Bh
    vkrow5 VK_RBRACKET,  0, "]", "}", "»",      "↓",      01Dh
    vkrow5 VK_BACKSLASH, 0, "\", "|", "¬",      WCH_NONE, 01Ch
end if
    vkrow5 VK_OEM_102,   0, "\", "|", WCH_NONE, WCH_NONE, 01Ch
    vkrow5 VK_BACK,      0, 8,   8,   WCH_NONE, WCH_NONE, 07Fh
    vkrow5 VK_ESCAPE,    0, 27,  27,  WCH_NONE, WCH_NONE, 01Bh
    vkrow5 VK_RETURN,    0, 13,  13,  WCH_NONE, WCH_NONE, 10
    vkrow5 VK_SPACE,     0, " ", " ", " ",      WCH_NONE, " "
    vkrow5 VK_CANCEL,    0, 3,   3,   WCH_NONE, WCH_NONE, 3
    dw 0, 0, 5 dup 0

palign

if USE_KANA
; For compact view:
; CAPLOK + CAPLOKALTGR + KANALOK = 13
; CAPLOK + KANALOK = 9
; KANALOK = 8
WNO = WCH_NONE
WDE = WCH_DEAD
WLG = WCH_LGTR
vk2wchar10:
    vkrow10 VK_DECIMAL,    8,  ".", ".", ".", ".", WNO, WNO, ",", ",", ",", ","
  if USE_DEAD_KEYS
    vkrow10 VK_GRAVE,      8,  "`", "~", WDE, WDE, WNO, WNO, "ё", "Ё", "`", "~"
    vkrow10 -1,            8,  WNO, WNO, "`", "~", WNO, WNO, WNO, WNO, WNO, WNO
  else
    vkrow10 VK_GRAVE,      8,  "`", "~", WNO, WNO, WNO, WNO, "ё", "Ё", "`", "~"
  end if
    vkrow10 "1",           8,  "1", "!", "¡", "¹", WNO, WNO, "1", "!", "¡", "¹"
    vkrow10 "2",           8,  "2", "@", "²", "½", WNO, WNO, "2", '"', "@", "²"
    vkrow10 "3",           8,  "3", "#", "³", "⅓", WNO, WNO, "3", "№", "#", "³"
    vkrow10 "4",           8,  "4", "$", "£", "¢", WNO, WNO, "4", ";", "$", "£"
    vkrow10 "5",           8,  "5", "%", "€", "‰", WNO, WNO, "5", "%", "€", "‰"
  if USE_DEAD_KEYS
    vkrow10 "6",           8,  "6", "^", WDE, WDE, WNO, WNO, "6", ":", "^", "ˇ"
    vkrow10 -1,            8,  WNO, WNO, "^", "ˇ", WNO, WNO, WNO, WNO, WNO, WNO
  else
    vkrow10 "6",           8,  "6", "^", "^", "ˇ", WNO, WNO, "6", ":", "^", "ˇ"
  end if
    vkrow10 "7",           8,  "7", "&", "＆", "•", WNO, WNO, "7", "?", "&", "＆"
    vkrow10 "8",           8,  "8", "*", "∞", "×", WNO, WNO, "8", "*", "∞", "×"
    vkrow10 "9",           8,  "9", "(", "‘", "“", WNO, WNO, "9", "(", "„", "“"
    vkrow10 "0",           8,  "0", ")", "’", "”", WNO, WNO, "0", ")", "“", "”"
    vkrow10 VK_BACKSLASH,  8,  "\", "|", "¬", WNO, 1Ch, WNO, "\", "/", "|", "¬"
    vkrow10 "Q",           13, "q", "Q", "ä", "Ä", WNO, WNO, "й", "Й", "q", "Q"
    vkrow10 "W",           13, "w", "W", "å", "Å", WNO, WNO, "ц", "Ц", "w", "W"
    vkrow10 "E",           13, "e", "E", "é", "É", WNO, WNO, "у", "У", "e", "E"
    vkrow10 "R",           9,  "r", "R", "®", "©", WNO, WNO, "к", "К", "r", "R"
    vkrow10 "T",           13, "t", "T", "þ", "Þ", WNO, WNO, "е", "Е", "t", "T"
    vkrow10 "Y",           13, "y", "Y", "ü", "Ü", WNO, WNO, "н", "Н", "y", "Y"
    vkrow10 "U",           13, "u", "U", "ú", "Ú", WNO, WNO, "г", "Г", "u", "U"
    vkrow10 "I",           13, "i", "I", "í", "Í", WNO, WNO, "ш", "Ш", "i", "I"
    vkrow10 "O",           13, "o", "O", "ó", "Ó", WNO, WNO, "щ", "Щ", "o", "O"
    vkrow10 "P",           13, "p", "P", "ö", "Ö", WNO, WNO, "з", "З", "p", "P"
    vkrow10 VK_LBRACKET,   9,  "[", "{", "«", "↑", 1Bh, WNO, "х", "Х", "[", "{"
    vkrow10 VK_RBRACKET,   9,  "]", "}", "»", "↓", 1Dh, WNO, "ъ", "Ъ", "]", "}"
    vkrow10 "A",           13, "a", "A", "á", "Á", WNO, WNO, "ф", "Ф", "a", "A"
    vkrow10 "S",           9,  "s", "S", "ß", "§", WNO, WNO, "ы", "Ы", "s", "S"
    vkrow10 "D",           13, "d", "D", "ð", "Ð", WNO, WNO, "в", "В", "d", "D"
    vkrow10 "F",           9,  "f", "F", "█", "▓", WNO, WNO, "а", "А", "f", "F"
    vkrow10 "G",           9,  "g", "G", "░", "▒", WNO, WNO, "п", "П", "g", "G"
    vkrow10 "H",           9,  "h", "H", "▀", "▌", WNO, WNO, "р", "Р", "h", "H"
    vkrow10 "J",           9,  "j", "J", "▄", "▐", WNO, WNO, "о", "О", "j", "J"
    vkrow10 "K",           9,  "k", "K", "ø", "Ø", WNO, WNO, "л", "Л", "k", "K"
    vkrow10 "L",           13, "l", "L", "ł", "Ł", WNO, WNO, "д", "Д", "l", "L"
  if USE_DEAD_KEYS
    vkrow10 VK_SEMICOLON,  8,  ";", ":", "°", WDE, WNO, WNO, "ж", "Ж", "°", WNO
    vkrow10 -1,            8,  WNO, WNO, WNO, "°", WNO, WNO, WNO, WNO, WNO, WNO
    vkrow10 VK_APOSTROPHE, 8,  "'", '"', WDE, WDE, WNO, WNO, "э", 'Э', "'", WNO
    vkrow10 -1,            8,  WNO, WNO, "´", "¨", WNO, WNO, WNO, WNO, WNO, WNO
  else
    vkrow10 VK_SEMICOLON,  8,  ";", ":", "°", "¶", WNO, WNO, "ж", "Ж", "°", WNO
    vkrow10 VK_APOSTROPHE, 8,  "'", '"', "´", "¨", WNO, WNO, "э", 'Э', "'", WNO
  end if
    vkrow10 "Z",           13, "z", "Z", "æ", "Æ", WNO, WNO, "я", "Я", "z", "Z"
    vkrow10 "X",           13, "x", "X", "œ", "Œ", WNO, WNO, "ч", "Ч", "x", "X"
    vkrow10 "C",           13, "c", "C", "ç", "Ç", WNO, WNO, "с", "С", "c", "C"
    vkrow10 "V",           13, "v", "V", "ő", "Ő", WNO, WNO, "м", "М", "v", "V"
    vkrow10 "B",           13, "b", "B", "ű", "Ű", WNO, WNO, "и", "И", "b", "B"
    vkrow10 "N",           13, "n", "N", "ñ", "Ñ", WNO, WNO, "т", "Т", "n", "N"
  if USE_LIGATURES
    vkrow10 "M",           9,  "m", "M", "µ", WLG, WNO, WNO, "ь", "Ь", "m", "M"
  else
    vkrow10 "M",           9,  "m", "M", "µ", WNO, WNO, WNO, "ь", "Ь", "m", "M"
  end if
  if USE_DEAD_KEYS
    vkrow10 VK_COMMA,      8,  ",", "<", WDE, "←", WNO, WNO, "б", "Б", "<", "«"
    vkrow10 -1,            8,  WNO, WNO, "¸", WNO, WNO, WNO, WNO, WNO, WNO, WNO
    vkrow10 VK_PERIOD,     8,  ".", ">", WDE, "→", WNO, WNO, "ю", "Ю", ">", "»"
    vkrow10 -1,            8,  WNO, WNO, "¯", WNO, WNO, WNO, WNO, WNO, WNO, WNO
  else
    vkrow10 VK_COMMA,      8,  ",", "<", "«", "←", WNO, WNO, "б", "Б", "<", "«"
    vkrow10 VK_PERIOD,     8,  ".", ">", "»", "→", WNO, WNO, "ю", "Ю", ">", "»"
  end if
    vkrow10 VK_SLASH,      8,  "/", "?", "¿", "̶", WNO, WNO, ".", ",", "/", "/"
    dw 0, 0, 10 dup 0

palign
end if

vk2wchar:
    dp vk2wchar1, 0401h
    dp vk2wchar2, 0602h
    dp vk2wchar4, 0A04h
    dp vk2wchar5, 0C05h
if USE_KANA
    dp vk2wchar10, 160Ah
end if
    dp 0, 0

palign

e1scancode2vk:
    dw 1Dh, VK_PAUSE
    dw 0, 0

palign

; On scancodes, see: https://www.win.tue.nl/~aeb/linux/kbd/scancodes.html

e0scancode2vk:
    dw 10h, KBDEXT + VK_MEDIA_PREV_TRACK
    dw 19h, KBDEXT + VK_MEDIA_NEXT_TRACK
    dw 1Ch, KBDEXT + VK_RETURN
    dw 1Dh, KBDEXT + VK_RCONTROL
    dw 20h, KBDEXT + VK_VOLUME_MUTE
    dw 21h, KBDEXT + VK_LAUNCH_APP2
    dw 22h, KBDEXT + VK_MEDIA_PLAY_PAUSE
    dw 24h, KBDEXT + VK_MEDIA_STOP
    dw 2Eh, KBDEXT + VK_VOLUME_DOWN
    dw 30h, KBDEXT + VK_VOLUME_UP
    dw 32h, KBDEXT + VK_BROWSER_HOME
    dw 35h, KBDEXT + VK_DIVIDE
    dw 37h, KBDEXT + VK_SNAPSHOT
    dw 38h, KBDEXT + VK_RMENU
    dw 46h, KBDEXT + VK_CANCEL
    dw 47h, KBDEXT + VK_HOME
    dw 48h, KBDEXT + VK_UP
    dw 49h, KBDEXT + VK_PGUP
    dw 4Bh, KBDEXT + VK_LEFT
    dw 4Dh, KBDEXT + VK_RIGHT
    dw 4Fh, KBDEXT + VK_END
    dw 50h, KBDEXT + VK_DOWN
    dw 51h, KBDEXT + VK_NEXT
    dw 52h, KBDEXT + VK_INSERT
    dw 53h, KBDEXT + VK_DELETE
    dw 5Bh, KBDEXT + VK_LWIN
    dw 5Ch, KBDEXT + VK_RWIN
    dw 5Dh, KBDEXT + VK_APPS
    dw 5Eh, KBDEXT + VK_POWER ; You can reassign these two, but they also do
    dw 5Fh, KBDEXT + VK_SLEEP ; their original action unless disabled elsewhere
;    dw 63h, 0FFh ; WakeUp button
    dw 65h, KBDEXT + VK_BROWSER_SEARCH
    dw 66h, KBDEXT + VK_BROWSER_FAVORITES
    dw 67h, KBDEXT + VK_BROWSER_REFRESH
    dw 68h, KBDEXT + VK_BROWSER_STOP
    dw 69h, KBDEXT + VK_BROWSER_FORWARD
    dw 6Ah, KBDEXT + VK_BROWSER_BACK
    dw 6Bh, KBDEXT + VK_LAUNCH_APP1
    dw 6Ch, KBDEXT + VK_LAUNCH_MAIL
    dw 6Dh, KBDEXT + VK_LAUNCH_MEDIA_SELECT
    dw 0, 0

palign

scancode2vk: .:
    du 0FFh, VK_ESCAPE, "1234567890", VK_MINUS, VK_EQUALS, VK_BACK
    du VK_TAB, "QWERTYUIOP", VK_LBRACKET, VK_RBRACKET, VK_RETURN
    du VK_LCONTROL, "ASDFGHJKL", VK_SEMICOLON, VK_APOSTROPHE, VK_GRAVE
    du VK_LSHIFT, VK_BACKSLASH, "ZXCVBNM", VK_COMMA, VK_PERIOD, VK_SLASH
    du KBDEXT+VK_RSHIFT, KBDMULTIVK+VK_MULTIPLY
if USE_KANA
    du VK_LMENU, " ", VK_KANA
else
    du VK_LMENU, " ", VK_CAPITAL
end if
    du VK_F1, VK_F2, VK_F3, VK_F4, VK_F5, VK_F6, VK_F7, VK_F8, VK_F9, VK_F10
    du KBDEXT+KBDMULTIVK+VK_NUMLOCK, KBDMULTIVK+VK_SCROLL
    du KBDSPECIAL+KBDNUMPAD+VK_HOME, KBDSPECIAL+KBDNUMPAD+VK_UP, KBDSPECIAL+KBDNUMPAD+VK_PGUP, VK_SUBTRACT
    du KBDSPECIAL+KBDNUMPAD+VK_LEFT, KBDSPECIAL+KBDNUMPAD+VK_CLEAR, KBDSPECIAL+KBDNUMPAD+VK_RIGHT, VK_ADD
    du KBDSPECIAL+KBDNUMPAD+VK_END, KBDSPECIAL+KBDNUMPAD+VK_DOWN, KBDSPECIAL+KBDNUMPAD+VK_PGDN
    du KBDSPECIAL+KBDNUMPAD+VK_INSERT, KBDSPECIAL+KBDNUMPAD+VK_DELETE
    du VK_SNAPSHOT, 0FFh, VK_OEM_102, VK_F11, VK_F12, VK_CLEAR, VK_OEM_WSCTRL
    du VK_OEM_FINISH, VK_OEM_JUMP, VK_EREOF, VK_OEM_BACKTAB, VK_OEM_AUTO
    du 0FFh, 0FFh, VK_ZOOM, VK_HELP, VK_F13, VK_F14, VK_F15, VK_F16, VK_F17
    du VK_F18, VK_F19, VK_F20, VK_F21, VK_F22, VK_F23
    du VK_OEM_PA3, 0FFh, VK_OEM_RESET, 0FFh, VK_ABNT_C1, 0FFh, 0FFh, VK_F24
    du 0FFh, 0FFh, 0FFh, 0FFh, VK_OEM_PA1, VK_TAB, 0FFh, VK_ABNT_C2
.size = $ - .

palign

if used deadkeys
deadkeys:
    du "A´Á", 0, "a´á", 0
    du "Æ´Ǽ", 0, "æ´ǽ", 0
    du "C´Ć", 0, "c´ć", 0
    du "E´É", 0, "e´é", 0
    du "G´Ǵ", 0, "g´ǵ", 0
    du "I´Í", 0, "i´í", 0
    du "K´Ḱ", 0, "k´ḱ", 0
    du "L´Ĺ", 0, "l´ĺ", 0
    du "M´Ḿ", 0, "m´ḿ", 0
    du "N´Ń", 0, "n´ń", 0
    du "O´Ó", 0, "o´ó", 0
    du "Ø´Ǿ", 0, "ø´ǿ", 0
    du "P´Ṕ", 0, "p´ṕ", 0
    du "R´Ŕ", 0, "r´ŕ", 0
    du "S´Ś", 0, "s´ś", 0
    du "U´Ú", 0, "u´ú", 0
    du "W´Ẃ", 0, "w´ẃ", 0
    du "Y´Ý", 0, "y´ý", 0
    du "Z´Ź", 0, "z´ź", 0
    du "'´́", 0 ; combining acute
    du "´´˝", DKF_DEAD
    du " ´´", 0

    du "O˝Ő", 0, "o˝ő", 0
    du "U˝Ű", 0, "u˝ű", 0
    du "'˝̋", 0 ; combining double acute
    du " ˝˝", 0
    
    du "A°Å", 0, "a°å", 0
    du "U°Ů", 0, "u°ů", 0
    du "I°İ", 0, "i°ı", 0 ; cheat for Turkish support
    du ";°̊", 0 ; combining ring
    du "°°̊", 0 ; combining ring
    du " °°", 0
    
    du 'A¨Ä', 0, 'a¨ä', 0
    du 'E¨Ë', 0, 'e¨ë', 0
    du 'H¨Ḧ', 0, 'h¨ḧ', 0
    du 'I¨Ï', 0, 'i¨ï', 0
    du 'O¨Ö', 0, 'o¨ö', 0
    du 'U¨Ü', 0, 'u¨ü', 0
    du 'W¨Ẅ', 0, 'w¨ẅ', 0
    du 'X¨Ẍ', 0, 'x¨ẍ', 0
    du 'Y¨Ÿ', 0, 'y¨ÿ', 0
    du "'¨̈", 0 ; combining diaeresis
;    du "¨¨̈", 0 ; combining diaeresis ; If this line is uncommented,
; due to bug in Firefox, switching to this layout and then typing a character
; causes it to insert AltGr+(Shift)+dead key accodiated with VK_APOSTROPHE
    du ' ¨¨', 0
    
    du "A^Â", 0, "a^â", 0
    du "C^Ĉ", 0, "c^ĉ", 0
    du "E^Ê", 0, "e^ê", 0
    du "G^Ĝ", 0, "g^ĝ", 0
    du "H^Ĥ", 0, "h^ĥ", 0
    du "I^Î", 0, "i^î", 0
    du "J^Ĵ", 0, "j^ĵ", 0
    du "O^Ô", 0, "o^ô", 0
    du "S^Ŝ", 0, "s^ŝ", 0
    du "U^Û", 0, "u^û", 0
    du "W^Ŵ", 0, "w^ŵ", 0
    du "Y^Ŷ", 0, "y^ŷ", 0
    du "Z^Ẑ", 0, "z^ẑ", 0
    du "^^̂", 0 ; combining circumflex
    du "6^̂", 0 ; combining circumflex
    du " ^^", 0

    du "AˇǍ", 0, "aˇǎ", 0
    du "CˇČ", 0, "cˇč", 0
    du "DˇĎ", 0, "dˇď", 0
    du "EˇĚ", 0, "eˇě", 0
    du "GˇǦ", 0, "gˇǧ", 0
    du "HˇȞ", 0, "hˇȟ", 0
    du "IˇǏ", 0, "iˇǐ", 0
    du "KˇǨ", 0, "kˇǩ", 0
    du "LˇĽ", 0, "lˇľ", 0
    du "NˇŇ", 0, "nˇň", 0
    du "OˇǑ", 0, "oˇǒ", 0
    du "RˇŘ", 0, "rˇř", 0
    du "SˇŠ", 0, "sˇš", 0
    du "TˇŤ", 0, "tˇť", 0
    du "UˇǓ", 0, "uˇǔ", 0
    du "ZˇŽ", 0, "zˇž", 0
    du "ˇˇ̌", 0 ; combining caron
    du "^ˇ̌", 0 ; combining caron
    du "6ˇ̌", 0 ; combining caron
    du " ˇˇ", 0

    du "A`À", 0, "a`à", 0
    du "E`È", 0, "e`è", 0
    du "I`Ì", 0, "i`ì", 0
    du "N`Ǹ", 0, "n`ǹ", 0
    du "O`Ò", 0, "o`ò", 0
    du "U`Ù", 0, "u`ù", 0
    du "W`Ẁ", 0, "w`ẁ", 0
    du "Y`Ỳ", 0, "y`ỳ", 0
    du "``̀", 0 ; combining grave
    du " ``", 0

    du "A~Ã", 0, "a~ã", 0
    du "E~Ẽ", 0, "e~ẽ", 0
    du "I~Ĩ", 0, "i~ĩ", 0
    du "N~Ñ", 0, "n~ñ", 0
    du "O~Õ", 0, "o~õ", 0
    du "U~Ũ", 0, "u~ũ", 0
    du "V~Ṽ", 0, "v~ṽ", 0
    du "Y~Ỹ", 0, "y~ỹ", 0
    du "~~̃", 0 ; combining tilde
    du "`~̃", 0 ; combining tilde
    du " ~~", 0

; ogonek:  ˛ Ąą    Ęę    Įį      Ǫǫ      Ųų
; cedilla: ¸   ÇçḐḑ  ĢģḨḩ  ĶķĻļŅņ  ŖŗŞşŢţ
    du "A¸Ą", 0, "a¸ą", 0
    du "C¸Ç", 0, "c¸ç", 0
    du "D¸Ḑ", 0, "d¸ḑ", 0
    du "E¸Ę", 0, "e¸ę", 0
    du "G¸Ģ", 0, "g¸ģ", 0
    du "H¸Ḩ", 0, "h¸ḩ", 0
    du "I¸Į", 0, "i¸į", 0
    du "K¸Ķ", 0, "k¸ķ", 0
    du "L¸Ļ", 0, "l¸ļ", 0
    du "N¸Ņ", 0, "n¸ņ", 0
    du "O¸Ǫ", 0, "o¸ǫ", 0
    du "R¸Ŗ", 0, "r¸ŗ", 0
    du "S¸Ş", 0, "s¸ş", 0
    du "T¸Ţ", 0, "t¸ţ", 0
    du "U¸Ų", 0, "u¸ų", 0
    du "Z¸Ż", 0, "z¸ż", 0 ; cheat for Polish support
    du ",¸̧", 0 ; combining cedilla
    du "¸¸̧", 0 ; combining cedilla
    du " ¸¸", 0
    
    du "A¯Ā", 0, "a¯ā", 0
    du "Æ¯Ǣ", 0, "æ¯ǣ", 0
    du "E¯Ē", 0, "e¯ē", 0
    du "G¯Ḡ", 0, "g¯ḡ", 0
    du "I¯Ī", 0, "i¯ī", 0
    du "Y¯Ȳ", 0, "y¯ȳ", 0
    du ".¯̄", 0 ; combining macron
    du "¯¯̄", 0 ; combining macron
    du " ¯¯", 0

    dw 4 dup 0

palign
end if

data export
export "kbdusru.dll", KbdLayerDescriptor, "KbdLayerDescriptor"
end data

palign

KbdLayerDescriptor:
if detected_32bit
    mov    eax,KbdTables
    cdq
else
    lea    rax,[KbdTables]
end if
    ret

palign

store_strings

section '.rsrc' data readable resource

directory RT_VERSION,versions
resource versions,1,LANG_NEUTRAL,version
versioninfo version,VOS_NT_WINDOWS32,VFT_DLL,VFT2_DRV_KEYBOARD,0,1200,\
    'CompanyName','by Grom PE',\
    'FileDescription','US+RU Customized Keyboard Layout',\
    'FileVersion','1.0',\
    'InternalName','kbdusru',\
    'LegalCopyright','Public domain. No rights reserved.',\
    'OriginalFilename','kbdusru.dll',\
    'ProductName','kbdasm',\
    'ProductVersion','1.0'

section '.reloc' data readable discardable fixups
