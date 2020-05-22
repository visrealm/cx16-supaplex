; Commander X16
;
; Queue management
;
; Copyright (c) 2020 Troy Schrapel
;
; This code is licensed under the MIT license
;
; https://github.com/visrealm/supaplex-x16
;

CMN_QUEUE_ASM_ = 1

!ifndef ADDR_QUEUE_HEADERS  { !error "Must set address for queue system to use: ADDR_QUEUE_HEADERS" }

QUEUE_HEADER_SIZE = 4

; queue data structure (ADDR_QUEUE_HEADERS)
; 0:  count of queues created
; 1: unused
;   (below repeated for each queue created). page is >ADDR_QUEUE_HEADERS + queue index
; 2: head (page offset)
; 3: tail (page offset)

QUEUE_OFFSET_HEAD = 0
QUEUE_OFFSET_TAIL = 1

; -----------------------------------------------------------------------------
; qInit: Initialise queue manager
; -----------------------------------------------------------------------------
qInit:
  stz ADDR_QUEUE_HEADERS
  rts

; -----------------------------------------------------------------------------
; qInit: create a queue, store its id in address
; -----------------------------------------------------------------------------
!macro qCreate index, addressMsb {
  jsr qCreate
  stx index
  sta addressMsb
}

; -----------------------------------------------------------------------------
; qInit: create a queue
; -----------------------------------------------------------------------------
; Inputs: none
; Returns:
;   x: Queue index
;   a: Queue MSB
; -----------------------------------------------------------------------------
qCreate:
  ; get the current number of queues
  ; increment it and store it
  lda ADDR_QUEUE_HEADERS
  inc
  tax
  stx ADDR_QUEUE_HEADERS

  ; now write the queue header (head and tail will be zero)
  asl ; double it since there are 2 bytes per queue header
  tay
  lda #0
  sta ADDR_QUEUE_HEADERS + QUEUE_OFFSET_HEAD,y
  sta ADDR_QUEUE_HEADERS + QUEUE_OFFSET_TAIL,y
  tya
  clc
  adc #>ADDR_QUEUE_HEADERS
  rts

; -----------------------------------------------------------------------------
; qPushBack: push a value onto the back of a queue
; -----------------------------------------------------------------------------
; inputs:
;   A: value to push
;   X: queue index
; -----------------------------------------------------------------------------
qPush:
qPushBack:
  pha
  phx
  ; get queue tail
  
  txa
  asl
  clc
  adc #>ADDR_QUEUE_HEADERS ; update code below to correct queue
  sta .ldaOffsetPush + 2
  txa   ; find the tail, place in y
  asl
  tax
  ldy ADDR_QUEUE_HEADERS + QUEUE_OFFSET_TAIL, x
  inc ADDR_QUEUE_HEADERS + QUEUE_OFFSET_TAIL, x
  plx
  pla
.ldaOffsetPush
  sta SELF_MODIFY_MSB_ADDR, y
  rts

; -----------------------------------------------------------------------------
; qPopFront: pop a value from the from of the front of the queue
; -----------------------------------------------------------------------------
; inputs:
;   X: queue index
; returns
;   A: value
; -----------------------------------------------------------------------------
qPop:
qPopFront:
  phx
  txa
  clc
  adc #>ADDR_QUEUE_HEADERS ; update code below to correct queue
  sta .ldaOffsetPop + 2
  txa   ; find the head, place in y
  asl
  tax
  ldy ADDR_QUEUE_HEADERS + QUEUE_OFFSET_HEAD, x
  inc ADDR_QUEUE_HEADERS + QUEUE_OFFSET_HEAD, x
  plx
.ldaOffsetPop
  lda SELF_MODIFY_MSB_ADDR, y
  rts

; -----------------------------------------------------------------------------
; qSize: return the queue size
; -----------------------------------------------------------------------------
; inputs:
;   X: queue index
; returns
;   A: size
; -----------------------------------------------------------------------------
qSize:
  txa
  asl ; get offset
  tay
  lda ADDR_QUEUE_HEADERS + QUEUE_OFFSET_TAIL, y
  sec
  sbc ADDR_QUEUE_HEADERS + QUEUE_OFFSET_HEAD, y
  rts

; -----------------------------------------------------------------------------
; qIterate: set up to iterate a queue
; -----------------------------------------------------------------------------
; inputs:
;   X: queue index
; returns
;   A: MSB byte of queue
;   Y: starting offset (head index)
; -----------------------------------------------------------------------------
qIterate:
  txa
  asl ; get offset
  tay
  lda ADDR_QUEUE_HEADERS + QUEUE_OFFSET_HEAD, y
  tay
  txa
  asl
  clc
  adc #>ADDR_QUEUE_HEADERS
  rts
