; Supaplex - Commander X16
;
; ECS falling objects
;
; Copyright (c) 2020 Troy Schrapel
;
; This code is licensed under the MIT license
;
; https://github.com/visrealm/supaplex-x16
;


ECS_FALLING_ASM_ = 1

!ifndef CMN_QUEUE_ASM_ !error "Requires queue"



; =============================================================================
!zone ecsFallingComponent {
; -----------------------------------------------------------------------------
; Used to set and get the fall attributes for a given entity
; =============================================================================


} ; ecsFallingComponent





; =============================================================================
!zone ecsFallingSystem {
; -----------------------------------------------------------------------------

; -----------------------------------------------------------------------------
; falling "awake" queues
; -----------------------------------------------------------------------------
.entityLsbQueueId:  !byte $00
.entityMsbQueueId:  !byte $00

.entityLsbQueueMsb: !byte $00
.entityMsbQueueMsb: !byte $00


; -----------------------------------------------------------------------------
; ecsFallingSystemInit
; -----------------------------------------------------------------------------
; Initialise the falling system
; -----------------------------------------------------------------------------
ecsFallingSystemInit:
  rts



; -----------------------------------------------------------------------------
; ecsFallingSystemTick
; -----------------------------------------------------------------------------
; Called for each frame
; -----------------------------------------------------------------------------
ecsFallingSystemTick:
  rts



} ; ecsFallingSystem