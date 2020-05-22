; Commander X16
;
; Queue unit tests
;
; Copyright (c) 2020 Troy Schrapel
;
; This code is licensed under the MIT license
;
; https://github.com/visrealm/supaplex-x16
;

ADDR_QUEUE_HEADERS = $6000

!source "unittest.asm"
!source "../common/queue.asm"


!macro testSize size {
  +printStr checkSizeStr
  ldx R2
  jsr qSize
  cmp #size

  beq +
  +testFailed
  beq ++
+
  +testPassed
++
}

; -----------------------------------------------------------------------------
runTests:
; -----------------------------------------------------------------------------

  jsr qInit

  jsr testCreateQueue
  +testSize 0
  jsr testCreateQueue2
  +testSize 0

  lda #43
  jsr testQueuePush
  +testSize 1
  jsr testQueuePush
  +testSize 2

  rts



; -----------------------------------------------------------------------------
testCreateQueue:
; -----------------------------------------------------------------------------
  +startTest queueCreateStr

  jsr qCreate

  stx R0
  sta R1

  lda #1
  cmp R0
  beq +
  +testFailed
  rts
+
  +testPassed
  rts

; -----------------------------------------------------------------------------
testCreateQueue2:
; -----------------------------------------------------------------------------
  +startTest queueCreate2Str

  jsr qCreate

  stx R2
  sta R3

  lda #2
  cmp R2
  beq +
  +testFailed
  rts
+
  +testPassed
  rts

; -----------------------------------------------------------------------------
testQueuePush:
; -----------------------------------------------------------------------------
  +startTest queuePushStr

  ldx R2
  lda #43
  jsr qPush
  rts


; -----------------------------------------------------------------------------

checkSizeStr: !pet "  checking size",0
queueCreateStr: !pet "queue create",0
queueCreate2Str: !pet "queue create 2",0
queuePushStr: !pet "queue push",0