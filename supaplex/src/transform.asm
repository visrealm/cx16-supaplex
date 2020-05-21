; Supaplex - Commander X16
;
; Transforming between screen, world and tile space
;
; Copyright (c) 2020 Troy Schrapel
;
; This code is licensed under the MIT license
;
; https://github.com/visrealm/supaplex-x16
;
;




; -----------------------------------------------------------------------------
; tileToWorldX: convert horizontal cell index to map pixel
; -----------------------------------------------------------------------------
; inputs:
;   a: Cell index
; outputs:
;   a - Low byte
;   x - High byte
; -----------------------------------------------------------------------------
tileToWorldX:
  ldx #0

  ; times player position by 16 
  ; (1-59, so can safely shift twice before checking carry)
  asl 
  asl
  asl
  bcc+
  ldx #$02  ; set x to 2, because we're 
            ; going to shift one more time
            ; this way we can ignore x in that
+
  asl
  bcc+
  inx
+
  rts
; -----------------------------------------------------------------------------


; -----------------------------------------------------------------------------
; tileToWorldY: convert vertical cell index to map pixel
; -----------------------------------------------------------------------------
; inputs:
;   a: Cell index
; outputs:
;   a - Low byte
;   x - High byte
; -----------------------------------------------------------------------------
tileToWorldY:
  ldx #0
  
  ; (1-22, so can safely shift thrice before checking carry)
  asl
  asl
  asl
  asl
  bcc+
  inx
+
  rts
; -----------------------------------------------------------------------------

; -----------------------------------------------------------------------------
; centreMap: centre the map around the player
; -----------------------------------------------------------------------------
centreMap:
; set starting scroll position 
; based on player location
  lda ZP_PLAYER_CELL_X
  jsr tileToWorldX

  sta ZP_PLAYER_X_L

  lda ZP_PLAYER_OFFSET_X
  beq .afterOffset
  bpl .posOffset
  ; neg offset
  clc
  adc ZP_PLAYER_X_L
  sta ZP_PLAYER_X_L
  bcs .afterOffset
  dex
  bra  .afterOffset
.posOffset:
  clc
  adc ZP_PLAYER_X_L
  sta ZP_PLAYER_X_L
  bcc .afterOffset
  inx
  bra  .afterOffset

.afterOffset:
  lda ZP_PLAYER_X_L
  stx ZP_PLAYER_X_H

; adjust to screen centre
  sec
  sbc #(VISIBLE_AREA_CX - HALF_TILE_SIZE)
  bcs +
  dex  
+

  cpx #$00
  bpl +
-
  lda #BORDER_SIZE
  stz ZP_SCROLL_X_H
  sta ZP_SCROLL_X_L
  bra .afterSetScrollX
+
  bne +
  cmp #BORDER_SIZE
  bcs +
  bra -
+
  +cmp16xa MAX_SCROLL_X
  bcc +
  ldx #>MAX_SCROLL_X
  lda #<MAX_SCROLL_X
+

  stx ZP_SCROLL_X_H
  sta ZP_SCROLL_X_L
.afterSetScrollX:


  lda ZP_PLAYER_CELL_Y
  jsr tileToWorldY

  sta ZP_PLAYER_Y_L

  lda ZP_PLAYER_OFFSET_Y
  beq .afterOffsetY
  bpl .posOffsetY

  ; neg offset
  clc
  adc ZP_PLAYER_Y_L
  sta ZP_PLAYER_Y_L
  bcs .afterOffsetY
  dex
  bra  .afterOffsetY
.posOffsetY:
  clc
  adc ZP_PLAYER_Y_L
  sta ZP_PLAYER_Y_L
  bcc .afterOffsetY
  inx
  bra  .afterOffsetY

.afterOffsetY:
  lda ZP_PLAYER_Y_L
  stx ZP_PLAYER_Y_H
  ; adjust to screen centre
  sec
  sbc #(VISIBLE_AREA_CY - HALF_TILE_SIZE)
  bcs +
  dex
+

  cpx #$00
  bpl +
-
  lda #BORDER_SIZE
  stz ZP_SCROLL_Y_H
  sta ZP_SCROLL_Y_L
  bra .afterSetScrollY
+
  bne +
  cmp #BORDER_SIZE
  bcs +
  bra -
+
  +cmp16xa MAX_SCROLL_Y
  bcc +
  ldx #>MAX_SCROLL_Y
  lda #<MAX_SCROLL_Y
+

  stx ZP_SCROLL_Y_H
  sta ZP_SCROLL_Y_L
.afterSetScrollY:
  rts
; -----------------------------------------------------------------------------
