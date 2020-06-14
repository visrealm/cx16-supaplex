; Supaplex - Commander X16
;
; Zero page addresses
;
; Copyright (c) 2020 Troy Schrapel
;
; This code is licensed under the MIT license
;
; https://github.com/visrealm/supaplex-x16
;
;


; Available locations
; https://github.com/commanderx16/x16-docs/blob/master/Commander%20X16%20Programmer%27s%20Reference%20Guide.md#ram-contents
;
;   $00 - $7F (128 bytes) user zero page   
;   $A9 - $FF (87 bytes)  if BASIC or FLOAT functions not used
; 
; Not available:
;   $80 - $A8 (41 bytes)

; -----------------------------------------------------------------------------

; $00 - $01 ??
; $02 - $21 Virtual registers (R0 -> R15)

; -----------------------------------------------------------------------------

; the current entity we're working with
ZP_ECS_CURRENT_ENTITY = $22
ZP_ECS_CURRENT_ENTITY_LSB = ZP_ECS_CURRENT_ENTITY
ZP_ECS_CURRENT_ENTITY_MSB = ZP_ECS_CURRENT_ENTITY + 1

; a temporary entity (when we're querying other entities)
ZP_ECS_TEMP_ENTITY = $24
ZP_ECS_TEMP_ENTITY_LSB = ZP_ECS_TEMP_ENTITY
ZP_ECS_TEMP_ENTITY_MSB = ZP_ECS_TEMP_ENTITY + 1

ZP_TEMP_CELL_X     = $26
ZP_TEMP_CELL_Y     = $27

ZP_CURRENT_OBJECT_TYPE = $28  ; tileId/object type

;
; $29 - $2f unused
;

ZP_TILE_TABLE       = $30
ZP_TILE_TABLE_L     = ZP_TILE_TABLE
ZP_TILE_TABLE_H     = ZP_TILE_TABLE + 1

ZP_ECS_CURRENT_ANIM_ID = $32
ZP_ECS_CURRENT_ANIM_FL = $33

ZP_CURRENT_CELL_X        = $34
ZP_CURRENT_CELL_Y        = $35

  ; $36 - $3d unused


ZP_ECS_LOCATION_SYSTEM  = $3e
ZP_ECS_LOCATION_SYSTEM_LSB = ZP_ECS_LOCATION_SYSTEM
ZP_ECS_LOCATION_SYSTEM_MSB = ZP_ECS_LOCATION_SYSTEM + 1

ZP_ECS_STATE_CURRENT   = $40

;
; $41 - $6f unused
;

ZP_LAST_SECOND      = $70
ZP_CURRENT_SECOND   = $71

ZP_TIME_SECONDS_BCD = $72
ZP_TIME_MINUTES_BCD = $73
ZP_TIME_HOURS_BCD   = $74

ZP_FRAME_INDEX      = $75


;
; $78 - $7f unused
;

; -----------------------------------------------------------------------------
; \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \
;  \ \ \ \ \ \ \ \ \ \ \ \ $80 - $A8: not available  \ \ \ \ \ \ \ \ \ \ \ \ \
; \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \
; -----------------------------------------------------------------------------

ZP_SCROLL_X      = $a9
ZP_SCROLL_X_L    = ZP_SCROLL_X
ZP_SCROLL_X_H    = ZP_SCROLL_X + 1
ZP_SCROLL_Y      = $ab
ZP_SCROLL_Y_L    = ZP_SCROLL_Y
ZP_SCROLL_Y_H    = ZP_SCROLL_Y + 1

ZP_PLAYER_X      = $ad
ZP_PLAYER_X_L    = ZP_PLAYER_X
ZP_PLAYER_X_H    = ZP_PLAYER_X + 1
ZP_PLAYER_Y      = $af
ZP_PLAYER_Y_L    = ZP_PLAYER_Y
ZP_PLAYER_Y_H    = ZP_PLAYER_Y + 1

ZP_PLAYER_CELL_X = $b1
ZP_PLAYER_CELL_Y = $b2
ZP_PLAYER_INPUT  = $b3
ZP_PLAYER_ENTITY     = $b4
ZP_PLAYER_ENTITY_LSB = ZP_PLAYER_ENTITY
ZP_PLAYER_ENTITY_MSB = ZP_PLAYER_ENTITY + 1

;
; $b6 - $bf unused
;

ZP_NUM_INFOTRONS   = $c0
ZP_PLAYER_SPEED_X  = $c1
ZP_PLAYER_OFFSET_X = $c2
ZP_PLAYER_SPEED_Y  = $c3
ZP_PLAYER_OFFSET_Y = $c4

;
; $c5 - $ff unused
;
