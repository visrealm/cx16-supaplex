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

.nextEntityIdsLSB: !byte $00
.nextEntityIdsMSB: !byte $00


; Change of heart. I don't think I should encode the entity type in the
; entity id:
;  1. It's wasteful on attribute storage. 
;  2. Requires a lot of page switching for common attributes
;  3. Requires generating a new entity id when an entity changes
;     from one type to another (this happens a lot)
;
; ECS2: Entity id is literally a pointer.  A Banked address pointer
;   Each attribute has a known bank and offset.  We can fit 4 bytes per bank.
;   The most common ones should be together:
;      entity type, location, animation ?
;      less common, but similar in other bank(s)

; -----------------------------------------------------------------------------
; entity id format
; -----------------------------------------------------------------------------
; byte   |   7   |   6   |   5   |   4   |   3   |   2   |   1   |   0   |
; 0 LSB  [                           index (7:0)                         ]
; 1 MSB  [       index (11:8)           ][          entity type id       ]
; -----------------------------------------------------------------------------

; number of bytes per bank.
; note: this limits the number of entities we can create
;       we're capped at 8KB / ECS_BYTES_PER_BANK entities
ECS_BYTES_PER_BANK = 5

ECS_ATTRIBUTE_ENTITY_TYPE = 0

ecsInit:
  lda #>BANKED_RAM_START
  sta .nextEntityIdsMSB
  stx .nextEntityIdsLSB

  jsr ecsRegisterSystems

  rts


; -----------------------------------------------------------------------------
; ecsEntityCreate: create an entity
; -----------------------------------------------------------------------------
; Inputs: None
; Outputs: New entity Id stored in ZP_ECS_CURRENT_ENTITY
; -----------------------------------------------------------------------------
ecsEntityCreate:
  lda .nextEntityIdsLSB
  sta ZP_ECS_CURRENT_ENTITY_LSB
  clc
  adc #ECS_BYTES_PER_BANK
  sta .nextEntityIdsLSB

  lda .nextEntityIdsMSB
  sta ZP_ECS_CURRENT_ENTITY_MSB
  bcc +
  inc .nextEntityIdsMSB
+
  rts

}
