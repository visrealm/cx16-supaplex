
c:\cx16\acme\acme.exe -f cbm -o tests.prg queue_tests.asm

IF NOT ERRORLEVEL 1 c:\cx16\x16emu\x16emu.exe -prg tests.prg -run
