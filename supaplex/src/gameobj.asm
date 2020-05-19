; Supaplex - Commander X16
;
; Game objects
;
; Copyright (c) 2020 Troy Schrapel
;
; This code is licensed under the MIT license
;
; https://github.com/visrealm/supaplex-x16
;
;

ECS_ADDRESS = $7000

!source "src/ecs/entity_type.asm"

; by object type?   zonk, infotron, snik, electron, bug?
; by characteristic?  fallers, enemies
; components: animation, movement
;  each object contains a list of its component ids
; sniksnak1: animId, moveId, etc.

; animation system
;  list of animation components
;   each containing: cell index, tile queue

; on level load, object factory (jump table?)
; 
; gameObject logic:
; most objects are "sleeping"
; objects can be woken by adjacent movement

; sniksnak logic:
; states:
;   - moving
;   - searching
;   

; a: tileId
createGameObject:
  phx
  pha
  tax ; look up entity type
  lda spriteTypes, x

  asl ; double it since objectFactory contains words
  tax
  pla
  jmp (objectFactory, x)
  ; rts handled in function call



; Object factory. Maps to entity type
objectFactory:
!word createEmpty
!word createZonk
!word createPlayer
!word createBase
!word createDisk
!word createDisk
!word createDisk
!word createTerminal
!word createPort
!word createExit
!word createBug
!word createInfotron
!word createElectron
!word createSnikSnak
!word createRam
!word createHardware
!word createHardware
!word createHardware
!word createHardware
!word createHardware
!word createHardware

; -----------------------------------------------------------------------------
; Factory functions
; -----------------------------------------------------------------------------
; inputs:
;   A: tileId
;   X: Double object type id
; returns
;   A: MSB byte of queue
;   Y: starting offset (head index)
; -----------------------------------------------------------------------------

createEmpty:
createZonk:
createBase:
createPlayer:
createInfotron:
createRam:
createHardware:
createSwitch:
createExit:
createTerminal:
createDisk:
createPort:
createBug:

  plx
  rts

createEnemy:

  rts

createSnikSnak:
  jsr createEnemy
  plx
  rts

createElectron:
  jsr createEnemy
  plx
  rts


; structure of a game object
; x cell
; y cell
; facing [2] (up, left, down, right) | type [6]
; status [3] (static, moving, searching, exploding, falling, consumed) | step ()
; from direction (0 = none, 1, 2, 3, 4)

; animation sequences

sniksnakTurnNW:
!byte 121,122,123,0



!macro spriteType tileId, entityType {
    !byte entityType
}


; Sprite types: Map to the level file tile index
spriteTypes:
+spriteType 0, ENTITY_TYPE_EMPTY
+spriteType 1, ENTITY_TYPE_ZONK
+spriteType 2, ENTITY_TYPE_BASE
+spriteType 3, ENTITY_TYPE_PLAYER
+spriteType 4, ENTITY_TYPE_INFOTRON
+spriteType 5, ENTITY_TYPE_RAM
+spriteType 6, ENTITY_TYPE_HARDWARE
+spriteType 7, ENTITY_TYPE_EXIT
+spriteType 8, ENTITY_TYPE_ORANGE_DISK
+spriteType 9,  ENTITY_TYPE_PORT ; right
+spriteType 10, ENTITY_TYPE_PORT ; down
+spriteType 11, ENTITY_TYPE_PORT ; left
+spriteType 12, ENTITY_TYPE_PORT ; up
+spriteType 13, ENTITY_TYPE_PORT ; special right
+spriteType 14, ENTITY_TYPE_PORT ; special down
+spriteType 15, ENTITY_TYPE_PORT ; special left
+spriteType 16, ENTITY_TYPE_PORT ; special up
+spriteType 17, ENTITY_TYPE_SNIK_SNAK
+spriteType 18, ENTITY_TYPE_YELLOW_DISK
+spriteType 19, ENTITY_TYPE_TERMINAL
+spriteType 20, ENTITY_TYPE_RED_DISK
+spriteType 21, ENTITY_TYPE_PORT ; vert
+spriteType 22, ENTITY_TYPE_PORT ; horz
+spriteType 23, ENTITY_TYPE_PORT ; cross
+spriteType 24, ENTITY_TYPE_ELECTRON
+spriteType 25, ENTITY_TYPE_BUG
+spriteType 26, ENTITY_TYPE_RAM
+spriteType 27, ENTITY_TYPE_RAM
+spriteType 28, ENTITY_TYPE_HARDWARE
+spriteType 29, ENTITY_TYPE_HARDWARE
+spriteType 30, ENTITY_TYPE_HARDWARE
+spriteType 31, ENTITY_TYPE_HARDWARE
+spriteType 32, ENTITY_TYPE_HARDWARE
+spriteType 33, ENTITY_TYPE_HARDWARE
+spriteType 34, ENTITY_TYPE_HARDWARE
+spriteType 35, ENTITY_TYPE_HARDWARE
+spriteType 36, ENTITY_TYPE_HARDWARE
+spriteType 37, ENTITY_TYPE_HARDWARE
+spriteType 38, ENTITY_TYPE_RAM
+spriteType 39, ENTITY_TYPE_RAM
