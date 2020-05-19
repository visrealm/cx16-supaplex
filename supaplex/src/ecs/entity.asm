; Supaplex - Commander X16
;
; ECS entity
;
; Copyright (c) 2020 Troy Schrapel
;
; This code is licensed under the MIT license
;
; https://github.com/visrealm/supaplex-x16
;

ECS_ENTITY_ASM_ = 1

!ifndef ECS_ADDRESS    !error "Must set address for ECS system to use: ECS_ADDRESS"

!zone ecsEntity {

NUM_ENTITY_TYPES         = 16

.lastEntityIdsLSB:
!for i, 0, NUM_ENTITY_TYPES - 1 {
  !byte $00
}

.lastEntityIdsMSB:
!for i, 0, NUM_ENTITY_TYPES - 1 {
  !byte $00
}

currentEntityId:
currentEntityIdLSB:
  !byte $00
currentEntityIdMSB:
  !byte $00

; -----------------------------------------------------------------------------
; ecsEntityCreate: create an entity
; -----------------------------------------------------------------------------
; Inputs:
;  x: entity type
; Outputs:
;  New entity Id stored in currentEntityId
ecsEntityCreate:
  stx currentEntityIdMSB
  lda .lastEntityIdsLSB, x
  inc
  sta .lastEntityIdsLSB, x
  sta .currentEntityIdLSB
  bne +
  lda .lastEntityIdsMSB, x
  inc
  sta .lastEntityIdsMSB, x
+
  lda .lastEntityIdsMSB, x

  ; if x is 0, we can skip all this
  beq +
  asl
  asl
  asl
  asl
  asl
  ora currentEntityIdMSB
  sta currentEntityIdMSB
+
  jsr
}

;Common attributes. 4KB per attribute
;-----------------
;Entity Id / Type  - Not required (inferred)

; Bank  1
;Cell X
;Cell Y

; Bank 2
; Flags
; State?

; Bank 3
;Animation flags
;Animation id


;Cell array = 6KB
;24 rows
;4 bytes per cell

;4 bytes...
;0-1: Entity Id
;2:   Flags (head/tail/direction?)

; Entity id has type encoded:
; [7 - 5]: MSB;  [4 - 0]: type 
; [7 - 0]: LSB

