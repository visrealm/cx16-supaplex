; Supaplex - Commander X16
;
; Copyright (c) 2020 Troy Schrapel
;
; This code is licensed under the MIT license
;
; https://github.com/visrealm/supaplex-x16
;
;

!cpu 65c02

!source "src/zeropage.asm"
!source "src/vram.asm"
!source "src/rambank.asm"

!source "../common/bootstrap.asm"

; -----------------------------------------------------------------------------
; constants
; -----------------------------------------------------------------------------
ADDR_QUEUE_HEADERS = $6000 ; 4KB
ADDR_ECS           = $7000 ; 4KB

; -----------------------------------------------------------------------------
; program entry
; -----------------------------------------------------------------------------

  sei

  ; turn off the display while we're setting things up
  jsr disableDisplay

  ; register our ecs systems
  jsr ecsInit
  
  ; load the tiles from disk to vram
  jsr loadTiles

  ; load the overlay/hub into vram
  jsr loadOverlay

  ; initialise the sfx library
  jsr initialiseSfx

  ; initialise queues
  jsr qInit

  ; load level file
  jsr loadMap

  ; centre map based on player location
  jsr centreMap

  ; set up the hud values
  jsr hudSetup

  ; set up and enable the display
  jsr configDisplay

  ; register the vsync interrupt handler
  jsr registerVsyncIrq

  cli

  stz ZP_PLAYER_SPEED_X
  stz ZP_PLAYER_OFFSET_X
  stz ZP_PLAYER_SPEED_Y
  stz ZP_PLAYER_OFFSET_Y
  stz ZP_FRAME_INDEX

  ; enter the game loop
  jmp waitForVsync

  rts
; -----------------------------------------------------------------------------


!source "../common/kernal/constants.asm"

!source "../common/util.asm"
!source "../common/file.asm"
!source "../common/memory.asm"
!source "../common/queue.asm"
!source "../common/string.asm"

!source "../common/vera/constants.asm"
!source "../common/vera/macros.asm"
!source "../common/vera/vera.asm"
!source "../common/vera/pcx.asm"
!source "../common/vera/text.asm"
!source "../common/vera/vsync.asm"

!source "src/tiles.asm"
!source "src/strings.asm"
!source "src/time.asm"
!source "src/level.asm"
!source "src/display.asm"
!source "src/sfx.asm"
!source "src/input.asm"
!source "src/hud.asm"
!source "src/transform.asm"
!source "src/gameloop.asm"
!source "src/ecs/entity.asm"
!source "src/ecs/systems.asm"
!source "src/ecs/location.asm"
!source "src/ecs/animation.asm"
!source "src/ecs/enemy.asm"
!source "src/ecs/falling.asm"
!source "src/ecs/transitioning.asm"
!source "src/gameobj/murphy.asm"
!source "src/gameobj/sniksnak.asm"
!source "src/gameobj/electron.asm"
!source "src/gameobj/switch.asm"
!source "src/gameobj/gameobj.asm"


; -----------------------------------------------------------------------------
; temporarily store the level here. TBD: load it!
; -----------------------------------------------------------------------------
LEVEL_NUMBER = 24

levelNumber: !byte LEVEL_NUMBER
levelDat: 
!if LEVEL_NUMBER = 0 { !binary "bin/testlevel.sp" }
!if LEVEL_NUMBER = 1 { !binary "bin/level1.dat" }
!if LEVEL_NUMBER = 2 { !binary "bin/level2.dat" }
!if LEVEL_NUMBER = 3 { !binary "bin/level3.dat" }
!if LEVEL_NUMBER = 4 { !binary "bin/level4.dat" }
!if LEVEL_NUMBER = 11 { !binary "bin/level11.dat" }
!if LEVEL_NUMBER = 24 { !binary "bin/level24.dat" }
!if LEVEL_NUMBER = 30 { !binary "bin/level30.dat" }
