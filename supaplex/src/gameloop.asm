; Supaplex - Commander X16
;
; The main game loop
;
; Copyright (c) 2020 Troy Schrapel
;
; This code is licensed under the MIT license
;
; https://github.com/visrealm/supaplex-x16
;
;


SP_GAMELOOP_ASM_ = 1


; -----------------------------------------------------------------------------
; loop to wait for vsync
; -----------------------------------------------------------------------------
waitForVsync:
  !byte $CB  ; WAI instruction
  lda VSYNC_FLAG
  bne waitForVsync

  ; flow on through to the.... 

; -----------------------------------------------------------------------------
; main game loop
; -----------------------------------------------------------------------------
gameLoop:
  jsr displaySetScroll

  jsr doInput

  jsr ecsTickSystems

  jsr checkTime

  jsr centreMap

  jsr updateMurphy

  ;+dbgBreak

  inc ZP_FRAME_INDEX

  lda #1
  sta VSYNC_FLAG

	bra waitForVsync