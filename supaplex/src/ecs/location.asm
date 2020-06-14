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
; .setCurrentLocationAddress
; -----------------------------------------------------------------------------
; Sets ZP_ECS_LOCATION_SYSTEM for the msb address of ZP_CURRENT_CELL
; -----------------------------------------------------------------------------
!macro setCurrentLocationAddress {

  ; cell address: two rows per 256 byte page
  ; even row [0 -> 119],  odd row [128 -> 247]
  ; [x0, y0, x1, y1, x2, y2, etc.]

  stz ZP_ECS_LOCATION_SYSTEM_LSB
  lda ZP_CURRENT_CELL_Y
  lsr                              ; halve it. we get two rows per 256 byte page
  ror ZP_ECS_LOCATION_SYSTEM_LSB   ; if y was odd, then start at 128 in current page
  ora #>LOCATION_MAP_ADDR           ; set high nibble (would need to add if it wasn't a 4KB mutiple)
  sta ZP_ECS_LOCATION_SYSTEM_MSB
  lda ZP_CURRENT_CELL_X            ; double x since we stoe two bytes per cell (entity id)
  asl
  ora ZP_ECS_LOCATION_SYSTEM_LSB
  sta ZP_ECS_LOCATION_SYSTEM_LSB
}


; =============================================================================
!zone ecsLocationComponent {
; -----------------------------------------------------------------------------
; Used to set and get the location attributes for a given entity
; =============================================================================

; -----------------------------------------------------------------------------
; setLocation
; -----------------------------------------------------------------------------
; Inputs:
;   ZP_ECS_CURRENT_ENTITY
;   ZP_CURRENT_CELL_X
;   ZP_CURRENT_CELL_Y
; -----------------------------------------------------------------------------
ecsSetLocation:
  +ramBankSanityCheck RAM_BANK_LOC_COMPONENT

  phy
  ldy #ECS_ATTRIBUTE_LOCATION_X

  ; set x location
  lda ZP_CURRENT_CELL_X
  sta (ZP_ECS_CURRENT_ENTITY), y

  ; set y location
  iny    ; Y
  lda ZP_CURRENT_CELL_Y
  sta (ZP_ECS_CURRENT_ENTITY), y

  ; set this entity in the location map
  jsr ecsLocationSetEntity

  ply

  rts

; -----------------------------------------------------------------------------
; ecsGetLocation
; -----------------------------------------------------------------------------
; Inputs:
;   ZP_ECS_CURRENT_ENTITY
; Outputs:
;   ZP_CURRENT_CELL_X
;   ZP_CURRENT_CELL_Y
; -----------------------------------------------------------------------------
ecsGetLocation:

  +ramBankSanityCheck RAM_BANK_LOC_COMPONENT

  phy

  ldy #ECS_ATTRIBUTE_LOCATION_X

  ; get x location
  lda (ZP_ECS_CURRENT_ENTITY), y
  sta ZP_CURRENT_CELL_X

  ; get y location
  iny    ; Y
  lda (ZP_ECS_CURRENT_ENTITY), y
  sta ZP_CURRENT_CELL_Y

  +setCurrentLocationAddress
  
  ply

  rts

} ; ecsLocationComponent


; =============================================================================
!zone ecsLocationSystem {
; =============================================================================

LOCATION_MAP_ADDR = ADDR_ECS

; storage for the current 3x3 square of cells
currentNine:
ul: !word $0000
u:  !word $0000
ur: !word $0000
l:  !word $0000
c:  !word $0000
r:  !word $0000
dl: !word $0000
d:  !word $0000
dr: !word $0000

; -----------------------------------------------------------------------------
; initialise the location system
; -----------------------------------------------------------------------------
ecsLocationSystemInit:
  rts



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
  +setCurrentLocationAddress

  lda ZP_ECS_CURRENT_ENTITY_LSB
  sta (ZP_ECS_LOCATION_SYSTEM)

  ldy #1
  lda ZP_ECS_CURRENT_ENTITY_MSB
  sta (ZP_ECS_LOCATION_SYSTEM), y
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
  +setCurrentLocationAddress

  lda (ZP_ECS_LOCATION_SYSTEM)
  sta ZP_ECS_CURRENT_ENTITY_LSB

  ldy #1
  lda (ZP_ECS_LOCATION_SYSTEM), y
  sta ZP_ECS_CURRENT_ENTITY_MSB
  rts


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
; ecsLocationPeekAll
; -----------------------------------------------------------------------------
; scan all adjacent cells and place in currentNine
; Inputs:
;   ZP_ECS_LOCATION_SYSTEM is set to the current location
; Outputs:
;   currentNine : All surrounding entities
; -----------------------------------------------------------------------------
ecsLocationPeekAll:
  ; update temp cell to point to last cell peeked
  lda ZP_CURRENT_CELL_X
  sta ZP_TEMP_CELL_X
  lda ZP_CURRENT_CELL_Y
  dec
  sta ZP_TEMP_CELL_Y

  lda ZP_ECS_LOCATION_SYSTEM_LSB
  eor #$80   ; toggle first bit (switches between odd and even rows)
  sec
  sbc #2
  sta ZP_ECS_LOCATION_SYSTEM_LSB

  bpl +
    dec ZP_ECS_LOCATION_SYSTEM_MSB ; go back a page
+

  ; now, we're pointing at top left
  lda (ZP_ECS_LOCATION_SYSTEM)
  sta ul

  ldy #1
  lda (ZP_ECS_LOCATION_SYSTEM), y
  sta ul + 1

  iny
  lda (ZP_ECS_LOCATION_SYSTEM), y
  sta u

  iny
  lda (ZP_ECS_LOCATION_SYSTEM), y
  sta u + 1

  iny
  lda (ZP_ECS_LOCATION_SYSTEM), y
  sta ur

  iny
  lda (ZP_ECS_LOCATION_SYSTEM), y
  sta ur + 1

  inc ZP_ECS_LOCATION_SYSTEM_MSB

  ; now, we're pointing at bottom left
  lda (ZP_ECS_LOCATION_SYSTEM)
  sta dl

  ldy #1
  lda (ZP_ECS_LOCATION_SYSTEM), y
  sta dl + 1

  iny
  lda (ZP_ECS_LOCATION_SYSTEM), y
  sta d

  iny
  lda (ZP_ECS_LOCATION_SYSTEM), y
  sta d + 1

  iny
  lda (ZP_ECS_LOCATION_SYSTEM), y
  sta dr

  iny
  lda (ZP_ECS_LOCATION_SYSTEM), y
  sta dr + 1

  lda ZP_ECS_LOCATION_SYSTEM_LSB
  eor #$80   ; toggle first bit (switches between odd and even rows)
  sta ZP_ECS_LOCATION_SYSTEM_LSB

  bpl +
    dec ZP_ECS_LOCATION_SYSTEM_MSB ; go forward a page
+

  ; now, we're pointing at left
  lda (ZP_ECS_LOCATION_SYSTEM)
  sta l

  ldy #1
  lda (ZP_ECS_LOCATION_SYSTEM), y
  sta l + 1

  iny
  lda (ZP_ECS_LOCATION_SYSTEM), y
  sta c

  iny
  lda (ZP_ECS_LOCATION_SYSTEM), y
  sta c + 1

  iny
  lda (ZP_ECS_LOCATION_SYSTEM), y
  sta r

  iny
  lda (ZP_ECS_LOCATION_SYSTEM), y
  sta r + 1

  ; reset back to centre from left
  inc ZP_ECS_LOCATION_SYSTEM_LSB
  inc ZP_ECS_LOCATION_SYSTEM_LSB

  rts


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

  ; back-up current entity
  lda ZP_ECS_CURRENT_ENTITY_LSB
  sta R11L
  lda ZP_ECS_CURRENT_ENTITY_MSB
  sta R11H

  ; set new entity
  lda ZP_ECS_TEMP_ENTITY_LSB
  sta ZP_ECS_CURRENT_ENTITY_LSB
  lda ZP_ECS_TEMP_ENTITY_MSB
  sta ZP_ECS_CURRENT_ENTITY_MSB

  ; set temporary entity to current location
  jsr ecsSetLocation
  jsr ecsEntitySetTransitioning
  jsr ecsUpdateTile

  ; restore current entity back
  lda R11L
  sta ZP_ECS_CURRENT_ENTITY_LSB
  lda R11H
  sta ZP_ECS_CURRENT_ENTITY_MSB

  ; set new location
  lda ZP_TEMP_CELL_X
  sta ZP_CURRENT_CELL_X
  lda ZP_TEMP_CELL_Y
  sta ZP_CURRENT_CELL_Y
  jsr ecsSetLocation
  rts




; -----------------------------------------------------------------------------
; ecsLocationSwap2
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
ecsLocationSwap2:

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

  ; set temporary entity to current location
  jsr ecsSetLocation
  jsr ecsUpdateTile

  ; restore current entity back
  lda R7L
  sta ZP_ECS_CURRENT_ENTITY_LSB
  lda R7H
  sta ZP_ECS_CURRENT_ENTITY_MSB

  ; set new location
  lda ZP_TEMP_CELL_X
  sta ZP_CURRENT_CELL_X
  lda ZP_TEMP_CELL_Y
  sta ZP_CURRENT_CELL_Y
  jsr ecsSetLocation
  jsr ecsEntitySetTransitioning
  jsr ecsUpdateTile

  rts  

}; ecsLocationSystem