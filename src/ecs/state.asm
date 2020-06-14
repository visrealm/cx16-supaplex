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

  +ramBankSanityCheck RAM_BANK_STATE_COMPONENT

  ldy #ECS_ATTRIBUTE_STATE

  ; set enemy state
  sta (ZP_ECS_CURRENT_ENTITY), y

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

  +ramBankSanityCheck RAM_BANK_STATE_COMPONENT

  ldy #ECS_ATTRIBUTE_STATE

  ; set enemy state
  lda (ZP_ECS_CURRENT_ENTITY), y

  rts



; -----------------------------------------------------------------------------
; ecsSetState
; -----------------------------------------------------------------------------
; Inputs:
;   ZP_ECS_CURRENT_ENTITY
;   A: State
; -----------------------------------------------------------------------------
ecsSetStateTemp:

  +ramBankSanityCheck RAM_BANK_STATE_COMPONENT

  ldy #ECS_ATTRIBUTE_STATE

  ; set enemy state
  sta (ZP_ECS_TEMP_ENTITY), y

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

  +ramBankSanityCheck RAM_BANK_STATE_COMPONENT

  ldy #ECS_ATTRIBUTE_STATE

  ; set enemy state
  lda (ZP_ECS_TEMP_ENTITY), y

  rts  

} ; ecsStateComponent


