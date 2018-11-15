@del starter.o
@del starter.nes
@del starter.map.txt
@del starter.labels.txt
@del starter.nes.ram.nl
@del starter.nes.0.nl
@del starter.nes.1.nl
@echo.
@echo Compiling...
cc65\bin\ca65 .\src\starter.asm -g -o starter.o
@IF ERRORLEVEL 1 GOTO failure
@echo.
@echo Linking...
cc65\bin\ld65 -o starter.nes -C starter.cfg starter.o -m starter.map.txt -Ln starter.labels.txt --dbgfile starter.nes.dbg
@IF ERRORLEVEL 1 GOTO failure
@echo.
@echo Success!
@time /t
@pause
@GOTO endbuild
:failure
@echo.
@echo Build error!
@pause
:endbuild
