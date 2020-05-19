; Supaplex - Commander X16
;
; Display routines
;
; Copyright (c) 2020 Troy Schrapel
;
; This code is licensed under the MIT license
;
; https://github.com/visrealm/supaplex-x16
;
;


SP_DISPLAY_ASM_ = 1

; -----------------------------------------------------------------------------
; configure the display
; -----------------------------------------------------------------------------
configDisplay:
  +vreg VERA_L0_MAPBASE, MAP_BASE_ADDRESS_ODD >> 9
  +vreg VERA_L0_TILEBASE, (TILE_BASE_ADDRESS >> 9) | VERA_TILE_WIDTH_16 | VERA_TILE_HEIGHT_16
  +vreg VERA_L0_CONFIG, VERA_CONFIG_MAP_WIDTH_64 | VERA_CONFIG_MAP_HEIGHT_32 | VERA_CONFIG_4BPP
  +vreg VERA_L0_HSCROLL_H, 1

  +vreg VERA_L1_TILEBASE, (OVERLAY_ADDR >> 9)
  +vreg VERA_L1_CONFIG, VERA_CONFIG_BITMAP_MODE | VERA_CONFIG_4BPP
  +vreg VERA_L1_HSCROLL_H, 10

  +vreg VERA_DC_VIDEO, VERA_VIDEO_LAYER0_ENABLED | VERA_VIDEO_LAYER1_ENABLED | VERA_VIDEO_SPRITES_ENABLED | VERA_VIDEO_OUTPUT_VGA
  +vreg VERA_DC_HSCALE, VERA_SCALE_2x
  +vreg VERA_DC_VSCALE, VERA_SCALE_2x
  +vreg VERA_IEN, 1
  +vreg VERA_ISR, 1

  +vset VERA_SPRITES
  +vWriteByte0 (MURPHY_ADDR >> 5) & $ff
  +vWriteByte0 (MURPHY_ADDR >> 13) & $ff
  +vWriteByte0 VISIBLE_AREA_CX - HALF_TILE_SIZE
  +vWriteByte0 0
  +vWriteByte0 VISIBLE_AREA_CY - HALF_TILE_SIZE
  +vWriteByte0 0
  +vWriteByte0 $08
  +vWriteByte0 $53
