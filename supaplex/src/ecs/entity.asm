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


; -----------------------------------------------------------------------------
; entity id format
; -----------------------------------------------------------------------------
; byte   |   7   |   6   |   5   |   4   |   3   |   2   |   1   |   0   |
; 0 LSB  [                           index (7:0)                         ]
; 1 MSB  [       index (11:8)           ][          entity type id       ]
; -----------------------------------------------------------------------------



; -----------------------------------------------------------------------------
; ecsEntityCreate: create an entity
; -----------------------------------------------------------------------------
; Inputs:
;  y: entity type
; Outputs:
;  New entity Id stored in currentEntityId
ecsEntityCreate:

  sty ZP_ECS_CURRENT_ENTITY_MSB

  pha
  lda .lastEntityIdsLSB, y
  inc
  sta .lastEntityIdsLSB, y
  sta ZP_ECS_CURRENT_ENTITY_LSB
  bne +
  lda .lastEntityIdsMSB, y
  inc
  sta .lastEntityIdsMSB, y
+
  lda .lastEntityIdsMSB, y


  ; if MSB is 0, we can skip all this
  beq +
  asl
  asl
  asl
  asl
  asl
  ora ZP_ECS_CURRENT_ENTITY_MSB
  sta ZP_ECS_CURRENT_ENTITY_MSB
+
  pla
  rts


; -----------------------------------------------------------------------------
; ecsEntityCreateTemp: reset the msb for a given type
; -----------------------------------------------------------------------------
ecsEntityCreateTemp:
  pha
  sty ZP_ECS_TEMP_ENTITY_MSB
  lda .lastEntityIdsLSB, y
  inc
  sta .lastEntityIdsLSB, y
  sta ZP_ECS_TEMP_ENTITY_LSB
  pla
  rts

}
