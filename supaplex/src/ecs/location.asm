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

.LOCATION_COMPONENT_BANK = RAM_BANK_LOC_COMPONENT
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
  ora #>.ADDR_TILE_X_TABLE
  sta ZP_ECS_TILE_X_TABLE_MSB
  clc
  adc #>(.ADDR_TILE_Y_TABLE - .ADDR_TILE_X_TABLE)
  sta ZP_ECS_TILE_Y_TABLE_MSB
  rts

!ifdef SANITY {
.debugCurrentEntityTypeSanityCheck:

  lda ZP_ECS_TILE_X_TABLE_MSB
  eor ZP_ECS_CURRENT_ENTITY_MSB
  and #$0f
  beq +
  +dbgSanityCheckBreak
+
  rts
}

; -----------------------------------------------------------------------------
; setLocation
; -----------------------------------------------------------------------------
; Inputs:
;   ZP_ECS_CURRENT_ENTITY
;   ZP_CURRENT_CELL_X
;   ZP_CURRENT_CELL_Y
; -----------------------------------------------------------------------------
setLocation:

!ifdef SANITY {
  jsr .debugCurrentEntityTypeSanityCheck
}

  +setRamBank .LOCATION_COMPONENT_BANK

  ; index
  ldy ZP_ECS_CURRENT_ENTITY_LSB

  ; set x location
  lda ZP_CURRENT_CELL_X
  sta (ZP_ECS_TILE_X_TABLE), y
  
  ; set y location
  lda ZP_CURRENT_CELL_Y
  sta (ZP_ECS_TILE_Y_TABLE), y

  ; set this entity in the location map
  jsr ecsLocationSetEntity

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
!ifdef SANITY {
  jsr .debugCurrentEntityTypeSanityCheck
}

  +setRamBank .LOCATION_COMPONENT_BANK
  
  ; index
  ldy ZP_ECS_CURRENT_ENTITY_LSB

  ; get x location
  lda (ZP_ECS_TILE_X_TABLE), y
  sta ZP_CURRENT_CELL_X

  ; get y location
  lda (ZP_ECS_TILE_Y_TABLE), y
  sta ZP_CURRENT_CELL_Y

  rts

} ; ecsLocationComponent


; =============================================================================
!zone ecsLocationSystem {
; =============================================================================

.LOCATION_SYSTEM_BANK = RAM_BANK_LOC_SYSTEM


; -----------------------------------------------------------------------------
; initialise the location system
; -----------------------------------------------------------------------------
ecsLocationSystemInit:
  stz ZP_ECS_TILE_X_TABLE_LSB
  stz ZP_ECS_TILE_Y_TABLE_LSB
  rts


; =============================================================================
; .setLocationAddressToMsbByCell
; -----------------------------------------------------------------------------
; Sets ZP_ECS_LOCATION_SYSTEM for the msb address of ZP_CURRENT_CELL
; -----------------------------------------------------------------------------
!macro setLocationAddressToMsbByCell {

  ; cell address: two rows per 256 byte page
  ; even row [0 -> 119],  odd row [128 -> 247]
  ; [x0, y0, x1, y1, x2, y2, etc.]

  stz ZP_ECS_LOCATION_SYSTEM_LSB
  lda ZP_CURRENT_CELL_Y
  lsr                              ; halve it. we get two rows per 256 byte page
  ror ZP_ECS_LOCATION_SYSTEM_LSB   ; if y was odd, then start at 128 in current page
  ora #>BANKED_RAM_START           ; set high nibble (would need to add if it wasn't a 4KB mutiple)
  sta ZP_ECS_LOCATION_SYSTEM_MSB
  lda ZP_CURRENT_CELL_X            ; double x since we stoe two bytes per cell (entity id)
  asl
  inc  ; add one to get msb. This saves us some time in callers
       ; where we started at lsb, moved to msb, then back again
  ora ZP_ECS_LOCATION_SYSTEM_LSB
  sta ZP_ECS_LOCATION_SYSTEM_LSB
}

; -----------------------------------------------------------------------------
; ecsLocationSetEntity
; -----------------------------------------------------------------------------
; called when a location component value is changed. updates the location map
; Inputs:
;   ZP_ECS_CURRENT_ENTITY, ZP_CURRENT_CELL_X, ZP_CURRENT_CELL_Y
; Also:
;   ZP_ECS_LOCATION_SYSTEM will be set to cell LSB
; -----------------------------------------------------------------------------
ecsLocationSetEntity:
  +setRamBank .LOCATION_SYSTEM_BANK

  +setLocationAddressToMsbByCell

  lda ZP_ECS_CURRENT_ENTITY_MSB
  sta (ZP_ECS_LOCATION_SYSTEM)

  dec ZP_ECS_LOCATION_SYSTEM_LSB ; move to lsb

  lda ZP_ECS_CURRENT_ENTITY_LSB
  sta (ZP_ECS_LOCATION_SYSTEM)
  rts

; -----------------------------------------------------------------------------
; ecsLocationGetEntity
; -----------------------------------------------------------------------------
; return the entity at a given location
; Inputs:
;   ZP_CURRENT_CELL_X, ZP_CURRENT_CELL_Y
; Outputs:
;   ZP_ECS_CURRENT_ENTITY - also ZP_ECS_LOCATION_SYSTEM is set to cell LSB
; -----------------------------------------------------------------------------
ecsLocationGetEntity:
  +setRamBank .LOCATION_SYSTEM_BANK

  +setLocationAddressToMsbByCell

  lda (ZP_ECS_LOCATION_SYSTEM)
  sta ZP_ECS_CURRENT_ENTITY_MSB

  dec ZP_ECS_LOCATION_SYSTEM_LSB ; move to lsb

  lda (ZP_ECS_LOCATION_SYSTEM)
  sta ZP_ECS_CURRENT_ENTITY_LSB
  rts


; -----------------------------------------------------------------------------
; Before we start peeking, ecsLocationGetEntity needs to be called
; -----------------------------------------------------------------------------
!ifdef SANITY { ; debug sanity check
.peekSanityCheck:
  pha
  phx
  phy

  ; check if ecsLocationGetEntity as called
  ; before this
  ldy ZP_ECS_LOCATION_SYSTEM_LSB
  ldx ZP_ECS_LOCATION_SYSTEM_MSB
  jsr ecsLocationGetEntity 
  cpy ZP_ECS_LOCATION_SYSTEM_LSB
  beq +
  +dbgSanityCheckBreak
+
  cpx ZP_ECS_LOCATION_SYSTEM_MSB
  beq +
  +dbgSanityCheckBreak
+  
  ply
  plx
  pla
  rts
}  


; -----------------------------------------------------------------------------
; ecsLocationPeekLeft
; -----------------------------------------------------------------------------
; return the entity (as a temporary entity) left of the current location
; Inputs:
;   ZP_ECS_LOCATION_SYSTEM is set to the current location
; Outputs:
;   ZP_ECS_TEMP_ENTITY : Temporary entity located one cell to the left
; -----------------------------------------------------------------------------
ecsLocationPeekLeft:
  +setRamBank .LOCATION_SYSTEM_BANK

  !ifdef SANITY {
    jsr .peekSanityCheck
  }

  ; update temp cell to point to last cell peeked
  lda ZP_CURRENT_CELL_X
  dec 
  sta ZP_TEMP_CELL_X
  lda ZP_CURRENT_CELL_Y
  sta ZP_TEMP_CELL_Y

  ldy ZP_ECS_LOCATION_SYSTEM_LSB ; backup current location

  dec ZP_ECS_LOCATION_SYSTEM_LSB
  lda (ZP_ECS_LOCATION_SYSTEM)
  sta ZP_ECS_TEMP_ENTITY_MSB

  dec ZP_ECS_LOCATION_SYSTEM_LSB
  lda (ZP_ECS_LOCATION_SYSTEM)
  sta ZP_ECS_TEMP_ENTITY_LSB

  sty ZP_ECS_LOCATION_SYSTEM_LSB ; restore current location

  rts  


; -----------------------------------------------------------------------------
; ecsLocationPeekRight
; -----------------------------------------------------------------------------
; return the entity (as a temporary entity) right of the current location
; Inputs:
;   ZP_ECS_LOCATION_SYSTEM is set to the current location
; Outputs:
;   ZP_ECS_TEMP_ENTITY : Temporary entity located one cell to the right
; -----------------------------------------------------------------------------
ecsLocationPeekRight:
  +setRamBank .LOCATION_SYSTEM_BANK

  !ifdef SANITY {
    jsr .peekSanityCheck
  }

  ; update temp cell to point to last cell peeked
  lda ZP_CURRENT_CELL_X
  inc
  sta ZP_TEMP_CELL_X
  lda ZP_CURRENT_CELL_Y
  sta ZP_TEMP_CELL_Y

  ldy #2

  lda (ZP_ECS_LOCATION_SYSTEM), y
  sta ZP_ECS_TEMP_ENTITY_LSB

  iny
  lda (ZP_ECS_LOCATION_SYSTEM), y
  sta ZP_ECS_TEMP_ENTITY_MSB

  rts  


; -----------------------------------------------------------------------------
; ecsLocationPeekUp
; -----------------------------------------------------------------------------
; return the entity (as a temporary entity) above the current location
; Inputs:
;   ZP_ECS_LOCATION_SYSTEM is set to the current location
; Outputs:
;   ZP_ECS_TEMP_ENTITY : Temporary entity located one cell above
; -----------------------------------------------------------------------------
ecsLocationPeekUp:
  +setRamBank .LOCATION_SYSTEM_BANK

  !ifdef SANITY {
    jsr .peekSanityCheck
  }

  ; update temp cell to point to last cell peeked
  lda ZP_CURRENT_CELL_X
  sta ZP_TEMP_CELL_X
  lda ZP_CURRENT_CELL_Y
  dec
  sta ZP_TEMP_CELL_Y

  ldy ZP_ECS_LOCATION_SYSTEM_LSB
  tya
  eor #$80   ; toggle first bit (switches between odd and even rows)
  sta ZP_ECS_LOCATION_SYSTEM_LSB

  bpl +
    dec ZP_ECS_LOCATION_SYSTEM_MSB ; go back a page
+

  lda (ZP_ECS_LOCATION_SYSTEM)
  sta ZP_ECS_TEMP_ENTITY_LSB

  inc  ZP_ECS_LOCATION_SYSTEM_LSB
  lda (ZP_ECS_LOCATION_SYSTEM)
  sta ZP_ECS_TEMP_ENTITY_MSB

  cpy #$80
  bpl +
    inc ZP_ECS_LOCATION_SYSTEM_MSB ; go forward a page
+

  sty ZP_ECS_LOCATION_SYSTEM_LSB ; restore current location

  rts  



; -----------------------------------------------------------------------------
; ecsLocationPeekDown
; -----------------------------------------------------------------------------
; return the entity (as a temporary entity) below the current location
; Inputs:
;   ZP_ECS_LOCATION_SYSTEM is set to the current location
; Outputs:
;   ZP_ECS_TEMP_ENTITY : Temporary entity located one cell below
; -----------------------------------------------------------------------------
ecsLocationPeekDown:
  +setRamBank .LOCATION_SYSTEM_BANK

  !ifdef SANITY {
    jsr .peekSanityCheck
  }

  ; update temp cell to point to last cell peeked
  lda ZP_CURRENT_CELL_X
  sta ZP_TEMP_CELL_X
  lda ZP_CURRENT_CELL_Y
  inc
  sta ZP_TEMP_CELL_Y

  ldy ZP_ECS_LOCATION_SYSTEM_LSB
  tya
  eor #$80   ; toggle first bit (switches between odd and even rows)
  sta ZP_ECS_LOCATION_SYSTEM_LSB

  bmi +
    inc ZP_ECS_LOCATION_SYSTEM_MSB ; go forward a page
+

  lda (ZP_ECS_LOCATION_SYSTEM)
  sta ZP_ECS_TEMP_ENTITY_LSB

  inc  ZP_ECS_LOCATION_SYSTEM_LSB
  lda (ZP_ECS_LOCATION_SYSTEM)
  sta ZP_ECS_TEMP_ENTITY_MSB

  cpy #$80
  bmi +
    dec ZP_ECS_LOCATION_SYSTEM_MSB ; go back a page
+

  sty ZP_ECS_LOCATION_SYSTEM_LSB ; restore current location

  rts


; -----------------------------------------------------------------------------
; ecsLocationClearTemp
; -----------------------------------------------------------------------------
; clear the temp location (to move into it)
; Inputs:
;   ZP_ECS_CURRENT_ENTITY
;   ZP_ECS_LOCATION_SYSTEM
;   ZP_CURRENT_CELL_X/Y set for current entity
;
;   ZP_TEMP_CELL - location of temporary entity
;   ZP_ECS_TEMP_ENTITY (entity to swap with)
; -----------------------------------------------------------------------------
ecsLocationClearTemp:
  +setRamBank .LOCATION_SYSTEM_BANK

  ldy #0
  jsr ecsEntityCreate
  jsr ecsLocationSetCurrentEntityType
  jmp setLocation
  ; rts


; -----------------------------------------------------------------------------
; ecsLocationSwap
; -----------------------------------------------------------------------------
; return the entity (as a temporary entity) below the current location
; Inputs:
;   ZP_ECS_CURRENT_ENTITY
;   ZP_ECS_LOCATION_SYSTEM
;   ZP_CURRENT_CELL_X/Y set for current entity
;
;   ZP_TEMP_CELL - location of temporary entity
;   ZP_ECS_TEMP_ENTITY (entity to swap with)
; -----------------------------------------------------------------------------
ecsLocationSwap:
  +setRamBank .LOCATION_SYSTEM_BANK

  ; back-up current entity
  lda ZP_ECS_CURRENT_ENTITY_LSB
  sta R7L
  lda ZP_ECS_CURRENT_ENTITY_MSB
  sta R7H

  ; set new entity
  lda ZP_ECS_TEMP_ENTITY_LSB
  sta ZP_ECS_CURRENT_ENTITY_LSB
  lda ZP_ECS_TEMP_ENTITY_MSB
  sta ZP_ECS_CURRENT_ENTITY_MSB

  ; TODO: here, I think we'll need a different temporary
  ;       entity type (wake/transitioning). once it expires
  ;       it can notify its surrounding cells

  ; set temporary entity to current location
  jsr ecsLocationSetCurrentEntityType
  jsr setLocation

  ; restore current entity back
  lda R7L
  sta ZP_ECS_CURRENT_ENTITY_LSB
  lda R7H
  sta ZP_ECS_CURRENT_ENTITY_MSB

  jsr vSetCurrent
  lda tileBlank
  sta VERA_DATA0  
  lda tileBlank + 1
  sta VERA_DATA0

  ; set new location
  lda ZP_TEMP_CELL_X
  sta ZP_CURRENT_CELL_X
  lda ZP_TEMP_CELL_Y
  sta ZP_CURRENT_CELL_Y

  jsr ecsLocationSetCurrentEntityType
  jsr setLocation

  ; Here, we want to look at cells adjacent
  ; the newly blank cell (above for fallers)
  ; and (left and right, above-left and above-right
  ; for rollers) and let them know a space just opened up. 
  ; perhaps we add them to a queue to process on the next frame?
  
  ;jsr adjacentCellClearedCB

  rts

}; ecsLocationSystem