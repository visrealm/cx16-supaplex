; Supaplex - Commander X16
;
; State component
;
; Copyright (c) 2020 Troy Schrapel
;
; This code is licensed under the MIT license
;
; https://github.com/visrealm/supaplex-x16
;

ECS_STATE_ASM_ = 1


; =============================================================================
!zone ecsStateComponent {

; -----------------------------------------------------------------------------
; ecsSetState
; -----------------------------------------------------------------------------
; Inputs:
;   ZP_ECS_CURRENT_ENTITY
;   A: State
; -----------------------------------------------------------------------------
ecsSetState:
  ldy #RAM_BANK_ENEMY_COMPONENT
  sty RAM_BANK

  ldy #ECS_ATTRIBUTE_STATE

  ; set enemy state
  sta (ZP_ECS_CURRENT_ENTITY), y

  ldy #RAM_BANK_ECS_PRIMARY
  sty RAM_BANK

  rts

; -----------------------------------------------------------------------------
; ecsGetState
; -----------------------------------------------------------------------------
; Inputs:
;   ZP_ECS_CURRENT_ENTITY
; Outputs:
;   A: State
; -----------------------------------------------------------------------------
ecsGetState:

  ldy #RAM_BANK_ENEMY_COMPONENT
  sty RAM_BANK

  ldy #ECS_ATTRIBUTE_STATE

  ; set enemy state
  lda (ZP_ECS_CURRENT_ENTITY), y

  ldy #RAM_BANK_ECS_PRIMARY
  sty RAM_BANK

  rts



; -----------------------------------------------------------------------------
; ecsSetState
; -----------------------------------------------------------------------------
; Inputs:
;   ZP_ECS_CURRENT_ENTITY
;   A: State
; -----------------------------------------------------------------------------
ecsSetStateTemp:
  ldy #RAM_BANK_ENEMY_COMPONENT
  sty RAM_BANK

  ldy #ECS_ATTRIBUTE_STATE

  ; set enemy state
  sta (ZP_ECS_TEMP_ENTITY), y

  ldy #RAM_BANK_ECS_PRIMARY
  sty RAM_BANK

  rts

; -----------------------------------------------------------------------------
; ecsGetState
; -----------------------------------------------------------------------------
; Inputs:
;   ZP_ECS_CURRENT_ENTITY
; Outputs:
;   A: State
; -----------------------------------------------------------------------------
ecsGetStateTemp:

  ldy #RAM_BANK_ENEMY_COMPONENT
  sty RAM_BANK

  ldy #ECS_ATTRIBUTE_STATE

  ; set enemy state
  lda (ZP_ECS_TEMP_ENTITY), y

  ldy #RAM_BANK_ECS_PRIMARY
  sty RAM_BANK

  rts  

} ; ecsStateComponent


