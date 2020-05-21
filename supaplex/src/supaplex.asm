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

!source "../common/bootstrap.asm"

; -----------------------------------------------------------------------------
; constants
; -----------------------------------------------------------------------------
ECS_ADDRESS  = $7000

; -----------------------------------------------------------------------------
; program entry
; -----------------------------------------------------------------------------

  sei

  ; turn off the display while we're setting things up
  jsr disableDisplay
  
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
!source "src/ecs/sys/anim_s.asm"
!source "src/gameobj.asm"


; -----------------------------------------------------------------------------
; temporarily store the level here. TBD: load it!
; -----------------------------------------------------------------------------

levelNumber:
!byte 1
levelDat:
!binary "bin/level1.dat"
