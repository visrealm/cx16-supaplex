; Supaplex - Commander X16
;
; SFX management
;
; Copyright (c) 2020 Troy Schrapel
;
; This code is licensed under the MIT license
;
; https://github.com/visrealm/supaplex-x16
;
;


SP_SFX_ASM_ = 1

!zone sfx {

SFX_BASE_ID       = 0
SFX_INFOTRON_ID   = 1

SFX_COUNT         = 2

sfxBaseFilename:     !text "base.raw", 0
sfxInfotronFilename: !text "infotron.raw", 0


!macro sfxField {
    !for i, 1, SFX_COUNT {
        !byte $00
    }
}

; table of sfx data
sfxData: 
sfxRamBank:       +sfxField
sfxRamMSB:        +sfxField
sfxFileLengthLSB: +sfxField
sfxFileLengthMSB: +sfxField

SFX_MAX_RAM_OFFSET = (BANKED_RAM_END - BANKED_RAM_START)
!macro initSfxId sfxId, filename, ramBank, ramOffset {
    !if sfxId >= SFX_COUNT { !error "Invalid SFX id" }
    !if <ramOffset != 0 { !warn  "RAM offset LSB will be ignored" }
    !if ramOffset > SFX_MAX_RAM_OFFSET { !error "Invalid MSB Ram offset" }

.ramAddress = $A000 + ramOffset

    +setRamBank ramBank
    +loadFile filename, .ramAddress

    ldx #sfxId

    lda #>.ramAddress
    sta R1

    jsr doInitSfx
}

doInitSfx:
    lda R2H
    sec
    sbc R1
    sta sfxFileLengthMSB, x
    lda R2L
    sta sfxFileLengthLSB, x
    lda RAM_BANK
    sta sfxRamBank, x
    lda R1
    sta sfxRamMSB, x
    rts


; -----------------------------------------------------------------------------
; initialiseSfx: initialise sfx library
; -----------------------------------------------------------------------------
initialiseSfx:
  +initSfxId SFX_BASE_ID,     sfxBaseFilename,     2, $000
  +initSfxId SFX_INFOTRON_ID, sfxInfotronFilename, 5, $100
  +vreg VERA_AUDIO_CTRL, $18
  +vreg VERA_AUDIO_RATE, $10
  rts


; -----------------------------------------------------------------------------
; sfxPlay: play a sound
; -----------------------------------------------------------------------------
!macro sfxPlay sfxId {
    ldx #sfxId
    jsr sfxPlay
}

; -----------------------------------------------------------------------------
; sfxPlay: play a sound
; -----------------------------------------------------------------------------
; Inputs:
;   x: SFX id
; -----------------------------------------------------------------------------
sfxPlay:
  pha
  phy
  lda sfxRamBank, x
  sta RAM_BANK
  stz R0L
  lda sfxRamMSB, x
  sta R0H
  lda #<VERA_AUDIO_DATA
  sta mem2regMultiPageStoreIns + 1
  lda #>VERA_AUDIO_DATA
  sta mem2regMultiPageStoreIns + 2
  ldy sfxFileLengthMSB, x
  lda sfxFileLengthLSB, x
  tax
  jsr mem2regMultiPage
  ply
  pla
  rts

} ; zone