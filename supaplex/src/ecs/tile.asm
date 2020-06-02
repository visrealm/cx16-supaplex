; Supaplex - Commander X16
;
; Tile component
;
; Copyright (c) 2020 Troy Schrapel
;
; This code is licensed under the MIT license
;
; https://github.com/visrealm/supaplex-x16
;

ECS_TILE_ASM_ = 1


; =============================================================================
!zone ecsTileComponent {
; -----------------------------------------------------------------------------
; Used to set and get the tile attributes for a given entity
; =============================================================================

; -----------------------------------------------------------------------------
; setTile
; -----------------------------------------------------------------------------
; Inputs:
;   ZP_ECS_CURRENT_ENTITY
;   A: tileId
; -----------------------------------------------------------------------------
ecsSetTile:
  +ramBankSanityCheck RAM_BANK_TILE_COMPONENT

  phy
  ldy #ECS_ATTRIBUTE_TILE_ID

  ; set tile id
  sta (ZP_ECS_CURRENT_ENTITY), y

  jsr ecsUpdateTile

  ply

  rts

; -----------------------------------------------------------------------------
; ecsGetTile
; -----------------------------------------------------------------------------
; Inputs:
;   ZP_ECS_CURRENT_ENTITY
; Outputs:
;   A: tileId
; -----------------------------------------------------------------------------
ecsGetTile:
  +ramBankSanityCheck RAM_BANK_TILE_COMPONENT

  phy
  ldy #ECS_ATTRIBUTE_TILE_ID

  ; get tile id
  lda (ZP_ECS_CURRENT_ENTITY), y
  
  ply

  rts

; -----------------------------------------------------------------------------
; ecsUpdateTile - update VRAM
; -----------------------------------------------------------------------------
; Inputs:
;   ZP_ECS_CURRENT_ENTITY
; -----------------------------------------------------------------------------
ecsUpdateTile:
  phx
  phy
  pha
  jsr ecsGetLocation
  jsr vSetCurrent
  jsr ecsGetTile
  jsr outputTile
  pla
  ply
  plx
  rts

} ; ecsTileComponent

