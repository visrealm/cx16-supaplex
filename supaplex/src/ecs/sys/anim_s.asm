; Supaplex - Commander X16
;
; Animation system
;
; Copyright (c) 2020 Troy Schrapel
;
; This code is licensed under the MIT license
;
; https://github.com/visrealm/supaplex-x16
;

; controls all of the animation components

ECS_SYS_ANIM_ASM_ = 1

!ifndef CMN_QUEUE_ASM_ !error "Requires queue"

!zone ecsAnimationSystem {

ANIM_SYSTEM_BANK   = 10
ADDR_ANIM_ID_TABLE = BANKED_RAM_START
ADDR_ANIM_FL_TABLE = BANKED_RAM_START + $1000


; -----------------------------------------------------------------------------
; animation queues
; -----------------------------------------------------------------------------
.queueIdX:      !byte $00
.queueIdY:      !byte $00
.queueIdAnimId: !byte $00
.queueIdAnimFl: !byte $00

.queueMsbX:      !byte $00
.queueMsbY:      !byte $00
.queueMsbAnimId: !byte $00
.queueMsbAnimFl: !byte $00

; 0: repeat[7]  reverse[6]  rate? additional id? unused? [5-4] step[3-0]
; 1: animId[7 - 0]

TMP_ANIM_DEF_ADDR = R3
TMP_ANIM_DEF_ADDR_L = R3L
TMP_ANIM_DEF_ADDR_H = R3H

TMP_ANIM_FL = R2


; -----------------------------------------------------------------------------
; NOTES
; -----------------------------------------------------------------------------

; keep a full level map. 2 bytes per cell
; that way we can go back and get the entity
; or we can set an animation on a cell without
; needing an entity and we limit the entire
; data requirements to 4KB (plus queues)
; need a lookup from entityId to cell x/y

; keep a queue of active cells (or entities)

; all cell animations are 8 frames (16 bytes) long, so can be placed in a queue
; *if* an animation needs to replace the old one (eg. explosion)
; no problem.. it will as the queue will sort it out



; -----------------------------------------------------------------------------
; animation definition macros
; -----------------------------------------------------------------------------
!macro animDefByte tileAddress {
    !byte (tileAddress - tileTable) >> 1
}

!macro animDef id, tile0, tile1, tile2, tile3, tile4, tile5, tile6, tile7 {
  +animDefByte tile0
  +animDefByte tile1
  +animDefByte tile2
  +animDefByte tile3
  +animDefByte tile4
  +animDefByte tile5
  +animDefByte tile6
  +animDefByte tile7
}

; -----------------------------------------------------------------------------
; animation definitions
; -----------------------------------------------------------------------------
animationDefs:
snikU2L: +animDef 0, tileSnikUp, tileSnikUp, tileSnikUl, tileSnikUl, tileSnikUl, tileSnikUl, tileSnikL, tileSnikL
snikL2D: +animDef 1, tileSnikL, tileSnikL, tileSnikDl, tileSnikDl, tileSnikDl, tileSnikDl, tileSnikDn, tileSnikDn
snikD2R: +animDef 2, tileSnikDn, tileSnikDn, tileSnikDr, tileSnikDr, tileSnikDr, tileSnikDr, tileSnikR, tileSnikR
snikR2U: +animDef 3, tileSnikR, tileSnikR, tileSnikUr, tileSnikUr, tileSnikUr, tileSnikUr, tileSnikUp, tileSnikUp
termGreen: +animDef 4, tileConsoleGn1, tileConsoleGn2, tileConsoleGn3, tileConsoleGn4, tileConsoleGn5, tileConsoleGn6, tileConsoleGn7, tileConsoleGn8

; -----------------------------------------------------------------------------
; animation callbacks
; an entity-type specific function is called when an animation completes
; -----------------------------------------------------------------------------
animationCallbacks:
  !word emptyAnimCB
  !word zonkAnimCB
  !word playerAnimCB
  !word baseAnimCB
  !word yellowDiskAnimCB
  !word redDiskAnimCB
  !word orangeDiskAnimCB
  !word terminalAnimCB
  !word portAnimCB
  !word exitAnimCB
  !word bugAnimCB
  !word infotronAnimCB
  !word electronAnimCB
  !word snikSnakAnimCB
  !word ramAnimCB
  !word hardwareAnimCB

emptyAnimCB:
zonkAnimCB:
playerAnimCB:
baseAnimCB:
yellowDiskAnimCB:
redDiskAnimCB:
orangeDiskAnimCB:
terminalAnimCB:
portAnimCB:
exitAnimCB:
bugAnimCB:
infotronAnimCB:
electronAnimCB:
ramAnimCB:
hardwareAnimCB:
  rts

snikSnakAnimCB:
  rts


; -----------------------------------------------------------------------------
; initialise the animation system
; -----------------------------------------------------------------------------
ecsAnimationSystemInit:
  +qCreate .queueIdX, .queueMsbX
  sta .smcTickX - 1

  +qCreate .queueIdY, .queueMsbY
  sta .smcTickY - 1

  +qCreate .queueIdAnimId, .queueMsbAnimId
  sta .smcTickAnimId - 1
  
  +qCreate .queueIdAnimFl, .queueMsbAnimFl
  sta .smcTickAnimFl - 1
  sta .smcTickAnimFl2 - 1
  rts

; add a new animation component for a given entity
; a: animation id
; x: animation flags
ecsAnimationStart:
  phx
  ldx .queueIdAnimId
  jsr qPush

  pla
  ldx .queueIdAnimFl
  jsr qPush

  lda ZP_CURRENT_CELL_X
  ldx .queueIdX
  jsr qPush

  lda ZP_CURRENT_CELL_Y
  ldx .queueIdY
  jsr qPush
  rts



ecsAnimationSystemTick:
  +vchannel0
  ldx .queueIdAnimId
  jsr qSize
  beq .end

  sta R9 ; store queue size in R0
  jsr qIterate

.loop:
  lda $1000, y
.smcTickY:
  sta ZP_CURRENT_CELL_Y

  lda $1000, y
.smcTickX:
  sta ZP_CURRENT_CELL_X
  jsr vSetCurrent

  lda $1000, y
.smcTickAnimId:
  stz TMP_ANIM_DEF_ADDR_H
  asl
  rol TMP_ANIM_DEF_ADDR_H
  asl
  rol TMP_ANIM_DEF_ADDR_H
  asl
  rol TMP_ANIM_DEF_ADDR_H
  adc #<animationDefs
  sta TMP_ANIM_DEF_ADDR_L
  lda TMP_ANIM_DEF_ADDR_H
  adc #>animationDefs
  sta TMP_ANIM_DEF_ADDR_H

  lda $1000, y
.smcTickAnimFl:
  sta TMP_ANIM_FL
  phy

  ; process the animation
  and #$07 ; get step
  tax
  inc
  bit #$08
  beq +
  lda #0
+
  ply
  sta $1000, y
.smcTickAnimFl2:  
  phy
+
  txa
  tay
  lda (TMP_ANIM_DEF_ADDR), y ; get tile id

  asl
  tay
  lda (ZP_TILE_TABLE), y

  sta VERA_DATA0
  iny
  lda (ZP_TILE_TABLE), y
  sta VERA_DATA0

  ply
  bit #$08
  bne +
  ;ldx .queueIdX
  ;jsr qPop
  ;ldx .queueIdY
  ;jsr qPop
  ;ldx .queueIdAnimId
  ;jsr qPop
  ;ldx .queueIdAnimFl
  ;jsr qPop
+
  iny

  dec R9
  bne .loop


.end:
  rts


}