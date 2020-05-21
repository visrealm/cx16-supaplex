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

.queueIdX:     !byte $00
.queueIdY:     !byte $00
.queueIdAnimL: !byte $00
.queueIdAnimH: !byte $00


; keep a full level map. 2 bytes per cell
; that way we can go back and get the entity
; or we can set an animation on a cell without
; needing an entity and we limit the entire
; data requirements to 4KB (plus queues)
; need a lookup from entityId to cell x/y

; keep a queue of active cells (or entities)

; all cell animations are 8 frames long, so can be placed in a queue
; *if* an animation needs to replace the old one (eg. explosion)
; no problem.. it will as the queue will sort it out


registerAnimation:
    ; id and 8 tileId frames
    rts

ecsAnimationSystemInit:
    jsr qCreate
    stx .queueIdX
    rts

; add a new animation component for a given entity
; x: entity id MSB
; y: entity id LSB
ecsAnimationSystemNew:

    rts

animationSystemTick:
    rts


}