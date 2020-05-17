; Supaplex - Commander X16
;
; Copyright (c) 2020 Troy Schrapel
;
; This code is licensed under the MIT license
;
; https://github.com/visrealm/supaplex-x16
;
;

!source "../common/kernal/constants.asm"
!source "../common/vera/constants.asm"
!source "../common/bootstrap.asm"

SCROLL_X      = $a0
SCROLL_X_L    = SCROLL_X
SCROLL_X_H    = SCROLL_X + 1
SCROLL_Y      = $a2
SCROLL_Y_L    = SCROLL_Y
SCROLL_Y_H    = SCROLL_Y + 1

PLAYER_X      = $a4
PLAYER_X_L    = PLAYER_X
PLAYER_X_H    = PLAYER_X + 1
PLAYER_Y      = $a6
PLAYER_Y_L    = PLAYER_Y
PLAYER_Y_H    = PLAYER_Y + 1

PLAYER_SPEED = 2

LAST_SECOND = $70
CURRENT_SECOND = $71
TIME_SECONDS = $72
TIME_MINUTES = $73
TIME_HOURS   = $74

PLAYER_CELL_X = $b0
PLAYER_CELL_Y = $b1
PLAYER_INPUT  = $b4

NUM_INFOTRONS   = $c3
PLAYER_SPEED_X  = $c4
PLAYER_OFFSET_X = $c5
PLAYER_SPEED_Y  = $c6
PLAYER_OFFSET_Y = $c7

PLAYER_FACING = $c8

FRAME_INDEX   = $d3

SPRITE_TYPE_TABLE = $d0 ; - $91 ; lookup to spriteTypes in gameobj.asm

; set up sprite types table
lda #<spriteTypes
sta SPRITE_TYPE_TABLE
lda #>spriteTypes
sta SPRITE_TYPE_TABLE + 1

stz PLAYER_SPEED_X
stz PLAYER_OFFSET_X
stz PLAYER_SPEED_Y
stz PLAYER_OFFSET_Y
stz PLAYER_FACING

jmp entry


; VERA memory map:
;    $00     (0) -   $9FF  (2559) - (2560 bytes): UNUSED
;   $A00  (2560) -  $19FF  (6655) - (64 x 32 x 2 = 4096 bytes): even frame map
;  $1A00  (6656) -  $29FF (10751) - (64 x 32 x 2 = 4096 bytes): odd frame map
;  $2A00 (10752) -  $3FFF (16383) - (5632 bytes): UNUSED
;  $4000 (16384) -  $BFFF (49151) - (16 x 16 x 128 = 32768 bytes): L0 tiles
;  $C000 (49152) - $155FF (87551) - (320 x 240 / 2 = 38400 bytes): L1 overlay
; $15600 (87552) - $1F9BF (129471) - (41920 bytes): UNUSED

TILE_SIZE         = 16
HALF_TILE_SIZE    = TILE_SIZE / 2
MAP_TILES_X = 60
MAP_TILES_Y = 24
MAP_TILES   = MAP_TILES_X * MAP_TILES_Y
MAP_PIXELS_X = MAP_TILES_X * TILE_SIZE
MAP_PIXELS_Y = MAP_TILES_Y * TILE_SIZE

DISPLAY_SIZE_X  = 320
DISPLAY_SIZE_Y  = 240
BOTTOM_PANEL_SIZE_Y  = 24
VISIBLE_AREA_X  = DISPLAY_SIZE_X
VISIBLE_AREA_Y  = DISPLAY_SIZE_Y - BOTTOM_PANEL_SIZE_Y
VISIBLE_AREA_CX = VISIBLE_AREA_X / 2
VISIBLE_AREA_CY = VISIBLE_AREA_Y / 2

BORDER_SIZE = 8
MAX_SCROLL_X = MAP_PIXELS_X - VISIBLE_AREA_X - BORDER_SIZE
MAX_SCROLL_Y = MAP_PIXELS_Y - VISIBLE_AREA_Y - BORDER_SIZE

MAP_BASE_ADDRESS_EVEN  =  $A00
MAP_BASE_ADDRESS_ODD   = $1A00
TILE_BASE_ADDRESS = $4000


!source "../common/util.asm"
!source "../common/string.asm"
!source "../common/vera/vsync.asm"
!source "../common/vera/macros.asm"


; program entry
; --------------------------------
entry:
  +vreg VERA_DC_VIDEO, $00

  STATIC_ADDR = TILE_BASE_ADDRESS
  PODIZO_ADDR = (STATIC_ADDR + (128*32))
  MURPHY_ADDR = (PODIZO_ADDR + (128*32))
  INFOTR_ADDR = (MURPHY_ADDR + (128*16))
  SNIKSN_ADDR = (INFOTR_ADDR + (128*16))
  TERMIN_ADDR = (SNIKSN_ADDR + (128*16))
  BUGBAS_ADDR = (TERMIN_ADDR + (128*16))
  EXPLOD_ADDR = (BUGBAS_ADDR + (128*16))
  ELECTR_ADDR = (EXPLOD_ADDR + (128*16))
  FONT_ADDR =   (ELECTR_ADDR + (128*16)) 
  OVERLAY_ADDR = $C000
  OVERLAY_BOTTOM_ADDR = (OVERLAY_ADDR + (160*(240 - 24)))

  +vClear OVERLAY_ADDR, OVERLAY_BOTTOM_ADDR - OVERLAY_ADDR

  +vLoadPcx staticPcx, STATIC_ADDR, 1
  +vLoadPcx podizoPcx, PODIZO_ADDR, 2
  +vLoadPcx murphyPcx, MURPHY_ADDR, 3
  +vLoadPcx infotrPcx, INFOTR_ADDR, 4
  +vLoadPcx sniksnPcx, SNIKSN_ADDR, 5
  +vLoadPcx terminPcx, TERMIN_ADDR, 6
  +vLoadPcx bugbasPcx, BUGBAS_ADDR, 7
  +vLoadPcx explodPcx, EXPLOD_ADDR, 8
  +vLoadPcx electrPcx, ELECTR_ADDR, 9
  +vLoadPcx overlayPcx, OVERLAY_BOTTOM_ADDR, 10
  +vLoadPcx fontPcx,    FONT_ADDR, 10

  jsr qInit

  jsr loadMap

  jsr centreMap

  jsr configDisplay
  
  jsr hudSetup
  
  stz FRAME_INDEX

  jsr registerVsyncIrq

  jmp gameLoop

  rts  


!source "src/strings.asm"
!source "src/text.asm"
!source "src/time.asm"
!source "src/level.asm"
!source "src/display.asm"
!source "src/input.asm"
!source "src/hud.asm"
!source "src/transform.asm"
!source "src/gameloop.asm"
!source "src/queue.asm"
!source "../common/vera/vera.asm"
!source "../common/vera/pcx.asm"


!align 255, 0
tileMap:
!binary "src/tilemap.bin"

levelNumber:
!byte 1
levelDat:
!binary "bin/level1.dat"


playerName:
!text "TROY",0


levelRows:
!for i, 0, MAP_TILES_Y - 1 {
  !word levelDat + (i * MAP_TILES_X)
}


!source "src/gameobj.asm"