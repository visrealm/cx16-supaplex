; PCX file support
; load and decode a PCX file into VRAM

; filename:   zero-terminated string
; vramArress: address to load the pixel data
; palOffset:  0-15 - high nibble of palette address offset



; XY contains address of filename
; vera already configured:
;   channel 0 for pixel data
;   channel 1 for palette
loadPcxFile:
!zone
TMP_ADDR = $8000
  jsr SETNAM

  lda #$01
  ldx $BA       ; last used device number
  bne .skip
  ldx #$08      ; default to device 8
.skip
  ldy #$00      ; $00 means: load to new address
  jsr SETLFS

  ldx #<TMP_ADDR
  ldy #>TMP_ADDR
  lda #$00      ; $00 means: load to memory (not verify)
  jsr LOAD
  bcs .error    ; if carry set, a load error has happened

  ; store pointer to the last byte
  stx R2L
  sty R2H

  ldy #$0e   ; palette offset
  ldx #$10   ; 16 colors
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
  ldy #$7e
  
.checkNextPixel
  lda R1H
  cmp R2H
  bne .nextPixel
  tya
  cmp R2L
  beq .done

.nextPixel:
  ldx #1
  lda (R1),Y
  cmp #$c0
  bcc .noseq  ; if is >= c0 (high 2 bits are set), then we're a sequence
  and #$3f
  tax         ; store count in X
  iny
  beq .increaseAddress2

.afterIncrease2  
  lda (R1),Y
 
  ; not a sequence
.noseq:
  sta VERA_DATA0

.addressOk:
  dex
  bne .noseq
  iny
  beq .increaseAddress
  bra .checkNextPixel

  ; looped over, increase high byte
.increaseAddress:  
  lda R1H
  inc
  sta R1H
  bra .checkNextPixel

  ; looped over, increase high byte
.increaseAddress2:  
  lda R1H
  inc
  sta R1H
  bra .afterIncrease2

.done
  rts

.error

  ; Accumulator contains BASIC error code

  ; most likely errors:
  ; A = $05 (DEVICE NOT PRESENT)
  ; A = $04 (FILE NOT FOUND)
  ; A = $1D (LOAD ERROR)
  ; A = $00 (BREAK, RUN/STOP has been pressed during loading)

  ;... error handling ...
  rts