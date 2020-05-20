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
        !byte $00 ; filename LSB
    }
}

; table of sfx data
sfxData: 
sfxRamBank:       +sfxField
sfxRamMSB:        +sfxField
sfxFileLengthLSB: +sfxField
sfxFileLengthMSB: +sfxField


!macro initSfxId sfxId, filename, ramBank, ramMSB {
    !if sfxId >= SFX_COUNT { !error "Invalid SFX id" }

    +setRamBank ramBank
    +loadFile filename, ramMSB << 8

    ldx #sfxId
    lda R2H
    sec
    sbc #ramMSB
    sta sfxFileLengthMSB, x
    lda R2L
    sta sfxFileLengthLSB, x
    lda #ramBank
    sta sfxRamBank, x
    lda #ramMSB
    sta sfxRamMSB, x
}

; -----------------------------------------------------------------------------
; initialiseSfx: initialise sfx library
; -----------------------------------------------------------------------------
initialiseSfx:
    +initSfxId SFX_BASE_ID,     sfxBaseFilename,     2, $A0
    +initSfxId SFX_INFOTRON_ID, sfxInfotronFilename, 2, $A1
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
  phx
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
  plx
  ply
  pla
  rts

} ; zone