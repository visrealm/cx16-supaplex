; Commander X16
;
; VERA Vsync helpers
;
; Copyright (c) 2020 Troy Schrapel
;
; This code is licensed under the MIT license
;
; https://github.com/visrealm/supaplex-x16
;
;


CMN_VERA_VSYNC_ASM_ = 1

defaultIrqHandler:
!word $0000

VSYNC_FLAG = $30

registerVsyncIrq:
    lda $0314
    sta defaultIrqHandler
    lda $0315
    sta defaultIrqHandler + 1

    lda #<vSyncIrqhandler
    sta $0314
    lda #>vSyncIrqhandler + 1
    sta $0315
    rts

vSyncIrqhandler:
    lda VERA_ISR
    and #VERA_IEN_VSYNC
    beq .irqDone

    ; Whatever code your program
    ; wanted to execute...
    stz VSYNC_FLAG

    ; Return to whatever had been interrupted:
.irqDone:
    jmp (defaultIrqHandler)
