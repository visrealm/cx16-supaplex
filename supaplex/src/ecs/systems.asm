; Supaplex - Commander X16
;
; ECS Systems
;
; Copyright (c) 2020 Troy Schrapel
;
; This code is licensed under the MIT license
;
; https://github.com/visrealm/supaplex-x16
;


; -----------------------------------------------------------------------------
; register all ecs systems
; -----------------------------------------------------------------------------
ecsRegisterSystems:
  jsr ecsAnimationSystemInit
  jsr ecsLocationSystemInit
  jsr ecsEnemySystemInit
  jmp ecsFallingSystemInit
  ; rts

; -----------------------------------------------------------------------------
; tick all ecs systems
; -----------------------------------------------------------------------------
ecsTickSystems:
  jsr ecsEnemySystemTick
  +setRamBank RAM_BANK_ECS_PRIMARY

  jsr ecsFallingSystemTick
  ;jmp ecsAnimationSystemTick
  rts
  
  ; rts
