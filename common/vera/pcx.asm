; Commander X16
;
; PCX file loader for Vera
;
; Copyright (c) 2020 Troy Schrapel
;
; This code is licensed under the MIT license
;
; https://github.com/visrealm/supaplex-x16
;


CMN_VERA_PCX_ = 1

!zone pcxFile {

; -----------------------------------------------------------------------------
; pcx constants
; -----------------------------------------------------------------------------

PCX_NUM_COLORS      = 16
PCX_PALETTE_OFFSET  = $10
PCX_PIXELS_OFFSET   = $80
PCX_REPEAT_FLAG     = $c0
PCX_REPEAT_CNT_MASK = $3f

; -----------------------------------------------------------------------------
; loadPcxFile: load and decode a PCX file into VRAM
; -----------------------------------------------------------------------------
; xy contains address of filename
; vera already configured:
;   channel 0 for pixel data
;   channel 1 for palette
; -----------------------------------------------------------------------------
loadPcxFile:
TMP_ADDR = $A000
  jsr SETNAM

  lda #$01
  ldx $BA       ; last used device number
  bne +
  ldx #$08      ; default to device 8
+ ldy #$00      ; $00 means: load to new address
  jsr SETLFS

  ldx #<(TMP_ADDR + 2)
  ldy #>(TMP_ADDR + 2)
  lda #$00      ; $00 means: load to memory (not verify)
  jsr LOAD
  bcc .loadedOk ; if carry set, a load error has happened

  brk
  ; load error?
  rts

; if we get this far, the file has loaded to TMP_ADDR
; and x/y contains the address of the last byte read
.loadedOk:

  ; store pointer to the last byte
  stx R2L
  sty R2H

  ldy #PCX_PALETTE_OFFSET
  ldx #PCX_NUM_COLORS

.nextColor:
  lda TMP_ADDR, Y   ; load red, reduce to 4 bits and store in R0L
  lsr
  lsr
  lsr
  lsr
  sta R0L
  iny
  lda TMP_ADDR, Y   ; load green, use high 4 bits and store in R0H
  and #$f0
  sta R0H
  iny
  lda TMP_ADDR, Y    ; load blue, reduce to 4 bits and combine with green
  lsr
  lsr
  lsr
  lsr
  ora R0H
  sta VERA_DATA1   ; store GB byte in vram
  lda R0L
  sta VERA_DATA1   ; store 0R byte in vram
  iny
  dex
  bne .nextColor
  
  lda #<TMP_ADDR
  sta R1L
  lda #>TMP_ADDR
  sta R1H
  ldy #PCX_PIXELS_OFFSET
  
.checkNextPixel:
  lda R1H
  cmp R2H
  bne +
  tya
  cmp R2L
  beq .done

+ ldx #1
  lda (R1),Y
  cmp #PCX_REPEAT_FLAG
  bcc .noSequence  ; if is >= c0 (high 2 bits are set), then we're a sequence

  ; is a sequence, so get the value and count
  and #PCX_REPEAT_CNT_MASK
  tax         ; store count in X
  iny
  bne +
  inc R1H
+
  lda (R1),Y
 
  ; not a sequence
.noSequence:
  sta VERA_DATA0
  dex
  bne .noSequence
  iny
  bne .checkNextPixel
  inc R1H
  bra .checkNextPixel

.done

  lda #$01
  jsr CLOSE

  rts
; -----------------------------------------------------------------------------

}