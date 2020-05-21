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

!ifndef ADDR_ECS  { !error "Must set address for ECS system to use: ADDR_ECS" }

!zone ecsEntity {

NUM_ENTITY_TYPES         = 16

!macro entityField {
    !for i, 1, NUM_ENTITY_TYPES {
        !byte $00
    }
}

.lastEntityIdsLSB: +entityField
.lastEntityIdsMSB: +entityField

currentEntityId:
.currentEntityIdLSB:
  !byte $00
.currentEntityIdMSB:
  !byte $00

; -----------------------------------------------------------------------------
; ecsEntityCreate: create an entity
; -----------------------------------------------------------------------------
; Inputs:
;  y: entity type
; Outputs:
;  New entity Id stored in currentEntityId
ecsEntityCreate:
  sty .currentEntityIdMSB
  lda .lastEntityIdsLSB, y
  inc
  sta .lastEntityIdsLSB, y
  sta .currentEntityIdLSB
  bne +
  lda .lastEntityIdsMSB, y
  inc
  sta .lastEntityIdsMSB, y
+
  lda .lastEntityIdsMSB, y

  ; if x is 0, we can skip all this
  beq +
  asl
  asl
  asl
  asl
  asl
  ora .currentEntityIdMSB
  sta .currentEntityIdMSB
+
  rts
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

