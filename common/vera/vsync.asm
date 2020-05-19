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

defaultIrqHandler: !le16 $0000

VSYNC_FLAG = $30

registerVsyncIrq:
    sei
    lda $0314
    sta defaultIrqHandler
    lda $0315
    sta defaultIrqHandler + 1

    lda #<vSyncIrqhandler
    sta $0314
    lda #>vSyncIrqhandler + 1
    sta $0315
    cli
    rts


vSyncIrqhandler:
    lda $9F27
    and #$01
    beq .irqDone

    ; Whatever code your program
    ; wanted to execute...
    stz VSYNC_FLAG


    ;lda #$01
    
    ;sta $9F27

    ; Return to whatever had been interrupted:
.irqDone:
    jmp (defaultIrqHandler)
