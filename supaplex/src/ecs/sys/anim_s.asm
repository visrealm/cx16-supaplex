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

.queueId: !byte $00

ecsAnimationSystemInit:
    jsr qCreate
    stx .queueId
    rts

; add a new animation component for a given entity
; x: entity id MSB
; y: entity id LSB
ecsAnimationSystemNew:

    rts

animationSystemTick:
    rts


}