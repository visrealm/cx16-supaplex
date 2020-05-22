; Supaplex - Commander X16
;
; Location component and system
;
; Copyright (c) 2020 Troy Schrapel
;
; This code is licensed under the MIT license
;
; https://github.com/visrealm/supaplex-x16
;

ECS_LOCATION_ASM_ = 1

!ifndef CMN_QUEUE_ASM_ !error "Requires queue"

; =============================================================================
!zone ecsLocationComponent {
; -----------------------------------------------------------------------------
; Used to set and get the location attributes for a given entity
; =============================================================================

.LOCATION_COMPONENT_BANK = 10
.ADDR_TILE_X_TABLE  = BANKED_RAM_START
.ADDR_TILE_Y_TABLE  = BANKED_RAM_START + $1000

; -----------------------------------------------------------------------------
; ecsLocationSetCurrentEntityType
; -----------------------------------------------------------------------------
; Inputs:
;   ZP_ECS_CURRENT_ENTITY
; -----------------------------------------------------------------------------
ecsLocationSetCurrentEntityType:
  lda ZP_ECS_CURRENT_ENTITY_MSB
  ; TODO - check for index (11:8)
  and #$0f
  clc
  adc #>.ADDR_TILE_X_TABLE
  sta ZP_ECS_TILE_X_TABLE_MSB
  adc #>(.ADDR_TILE_Y_TABLE - .ADDR_TILE_X_TABLE)
  sta ZP_ECS_TILE_Y_TABLE_MSB


  rts

; -----------------------------------------------------------------------------
; setLocation
; -----------------------------------------------------------------------------
; Inputs:
;   ZP_ECS_CURRENT_ENTITY
;   ZP_CURRENT_CELL_X
;   ZP_CURRENT_CELL_Y
; -----------------------------------------------------------------------------
setLocation:
  +setRamBank .LOCATION_COMPONENT_BANK
  phy

  ; index
  ldy ZP_ECS_CURRENT_ENTITY_LSB

  ; set x location
  lda ZP_CURRENT_CELL_X
  sta (ZP_ECS_TILE_X_TABLE), y
  
  ; set y location
  lda ZP_CURRENT_CELL_Y
  sta (ZP_ECS_TILE_Y_TABLE), y

  ply
  rts

; -----------------------------------------------------------------------------
; getLocation
; -----------------------------------------------------------------------------
; Inputs:
;   ZP_ECS_CURRENT_ENTITY
; Outputs:
;   ZP_CURRENT_CELL_X
;   ZP_CURRENT_CELL_Y
; -----------------------------------------------------------------------------
getLocation:
  +setRamBank .LOCATION_COMPONENT_BANK
  
  phy

  ; index
  ldy ZP_ECS_CURRENT_ENTITY_LSB

  ; get x location
  lda (ZP_ECS_TILE_X_TABLE), y
  sta ZP_CURRENT_CELL_X

;  +dbgBreak

  ; get y location
  lda (ZP_ECS_TILE_Y_TABLE), y
  sta ZP_CURRENT_CELL_Y

  ply
  rts

} ; ecsLocationComponent


; =============================================================================
!zone ecsLocationSystem {
; =============================================================================

; -----------------------------------------------------------------------------
; initialise the location system
; -----------------------------------------------------------------------------
ecsLocationSystemInit:
  stz ZP_ECS_TILE_X_TABLE_LSB
  stz ZP_ECS_TILE_Y_TABLE_LSB
  rts

}; ecsLocationSystem