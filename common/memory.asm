; Commander X16
;
; Memory subroutines
;
; Copyright (c) 2020 Troy Schrapel
;
; This code is licensed under the MIT license
;
; https://github.com/visrealm/supaplex-x16
;
;

CMN_MEMORY_ASM_ = 1

!zone memcpy {

; -----------------------------------------------------------------------------
; memcpy: Copy a fixed number of bytes from src to dest
; -----------------------------------------------------------------------------
; Inputs:
;  src: source address
;  dst: destination address
;  cnt: number of bytes
; -----------------------------------------------------------------------------
!macro memcpy src, dst, cnt {
  lda #<src
  sta R0L
  lda #>src
  sta R0H

  lda #<dst
  sta R1L
  lda #>dst
  sta R1H

  ldy #<cnt

  !if cnt <= 255 {
    jsr memcpySinglePage 
  } else {
    ldx #>cnt
    jsr memcpyMultiPage
  }
}

; -----------------------------------------------------------------------------
; memcpySinglePage: Copy up to 255 bytes 
; -----------------------------------------------------------------------------
; Inputs:
;  R0: src address
;  R1: dst address
;  Y:  bytes
; -----------------------------------------------------------------------------
memcpySinglePage:
  lda (R0), Y
  sta (R1), Y
  dey
  bne memcpySinglePage
  rts
; -----------------------------------------------------------------------------


; -----------------------------------------------------------------------------
; memcpyMultiPage: Copy an up to 2^15 bytes 
; -----------------------------------------------------------------------------
; Inputs:
;  R0: src address
;  R1: dst address
;  X:  bytes MSB
;  Y:  bytes LSB
; -----------------------------------------------------------------------------
memcpyMultiPage:
  lda R0L
  sta .loadIns + 1
  lda R0H
  sta .loadIns + 2

  lda R1L
  sta .storeIns + 1
  lda R1H
  sta .storeIns + 2

.loadIns:
  lda SELF_MODIFY_ADDR, Y
  
.storeIns:
  sta SELF_MODIFY_ADDR, Y
  dey
  bne .loadIns
  inc .loadIns + 2
  inc .storeIns + 2
  dex
  bne .loadIns

  rts
; -----------------------------------------------------------------------------

}




!zone mem2reg {

; -----------------------------------------------------------------------------
; mem2regSinglePage: Copy up to 255 bytes from ram to a register stream
; -----------------------------------------------------------------------------
; Inputs:
;  R0: src address
;  R1: output register address
;  X:  bytes
; -----------------------------------------------------------------------------
!macro mem2regSinglePage outReg {
  ldy #0
-
  lda (R0), y
  sta outReg
  iny
  dex
  bne -
}
; -----------------------------------------------------------------------------


; -----------------------------------------------------------------------------
; mem2reg: Copy a fixed number of bytes from src to dest
; -----------------------------------------------------------------------------
; Inputs:
;  src: source address
;  dst: destination register stream address
;  cnt: number of bytes
; -----------------------------------------------------------------------------
!macro mem2reg src, dst, cnt {
  lda #<src
  sta R0L
  lda #>src
  sta R0H

  ldx #<cnt

  !if cnt <= 255 {
    +mem2regSinglePage dst
  } else {
    lda #<dst
    sta mem2regMultiPageStoreIns + 1
    lda #>dst
    sta mem2regMultiPageStoreIns + 2
    ldy #>cnt
    jsr mem2regMultiPage
  }
}


; -----------------------------------------------------------------------------
; mem2regMultiPage: Copy memory to a register stream 
; -----------------------------------------------------------------------------
; Inputs:
;  R0: src address
;  R1: output register address
;  X:  bytes LSB
;  Y:  bytes MSB
; -----------------------------------------------------------------------------
mem2regMultiPage:
  lda R0L
  sta .loadIns + 1
  lda R0H
  sta .loadIns + 2

  iny
  
  txa
  bne +
  dey
+

 
.loadIns:
  lda $ffff
  
mem2regMultiPageStoreIns:
  sta $ffff
  +inc16 .loadIns + 1
  dex
  bne .loadIns
  dey
  bne .loadIns

  rts
; -----------------------------------------------------------------------------

}