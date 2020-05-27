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
  +setRamBank RAM_BANK_ECS_PRIMARY
  jsr ecsAnimationSystemInit
  jsr ecsLocationSystemInit
  jsr ecsEnemySystemInit
  jsr ecsFallingSystemInit
  jsr ecsTransitioningSystemInit
  rts

; -----------------------------------------------------------------------------
; tick all ecs systems
; -----------------------------------------------------------------------------
ecsTickSystems:
  +setRamBank RAM_BANK_ECS_PRIMARY
  jsr ecsEnemySystemTick
  jsr ecsFallingSystemTick
  jsr ecsAnimationSystemTick
  jsr ecsTransitioningSystemTick
  rts
  
  ; rts
