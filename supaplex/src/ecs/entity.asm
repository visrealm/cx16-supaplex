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

!ifndef CMN_QUEUE_ASM_ !error "Requires queue"
!ifndef ECS_ADDRESS    !error "Must set address for ECS system to use: ECS_ADDRESS"

!zone ecsEntity {

.queueId: !byte $00

; create an entity
ecsEntityCreate:
    jsr


}

;Common attributes
;-----------------
;Entity Id
;Type
;Cell X
;Cell Y
;State
;Animation flags
;Animation id


;Cell array = 6KB
;24 rows
;4 bytes per cell

;4 bytes...
;0-1: Entity Id


