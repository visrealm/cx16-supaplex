c:\cx16\acme\acme.exe -f cbm -DDEBUG=1 -DSANITY=1 -r supaplex.rpt -o bin\supaplex.prg src\supaplex.asm

IF NOT ERRORLEVEL 1 call run
