# Supaplex for the Commander x16

Planned clone of the classic PC and Amiga game Supaplex for the [Commander X16](https://github.com/commanderx16) r37.

Currently using [ACME Assembler](https://github.com/commanderx16).

Not really fit for public consumption, but making public anyway. This project is very new and subject to significant changes.

#### Latest video of the game running on the emulator
[![Adventures in Assembly 3 - Supaplex for the Commander X16.](https://img.visualrealmsoftware.com/youtube/thumb/6pXfGgCJt8A)](http://www.youtube.com/watch?v=6pXfGgCJt8A "Adventures in Assembly [3] - Supaplex for the Commander X16.")

#### Run instructions

If you don't want to set up my build environment (I don't blame you). You can run the latest build by copying the files from:

```
supaplex/bin
```
In to your emulator folder. Then, run the emulator and:

```
LOAD "SUPAPLEX.PRG"

RUN
```

#### Build instructions

Build batch files currently expect a given layout:

```c:\cx16
c:\cx16\x16emu    <-- the emulator
c:\cx16\acme      <-- acme assembler
c:\cx16\code      <-- this repository
```

To build, head to c:\cx16\code\supaplex:

```
build.bat / b.bat   <-- build the project
run.bat / r.bat     <-- run it
br.bat              <-- build and run

c:\cx16\code\supaplex\src  <-- source files (also some in code\common)
c:\cx16\code\supaplex\bin  <-- output files - the disk image for the cx16
c:\cx16\code\supaplex\res  <-- various resources used to generate the final level, image, tile files
```
