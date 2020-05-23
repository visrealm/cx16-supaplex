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

!source "src/ecs/entity_type.asm"


; -----------------------------------------------------------------------------
; createGameObject
; -----------------------------------------------------------------------------
; Create a game object. THis is called for every tile loaded
;
; Inputs:
;  A: TileId (as set in the level file)
;  ZP_CURRENT_CELL_X, ZP_CURRENT_CELL_Y
; -----------------------------------------------------------------------------
createGameObject:
  phx
  phy
  pha
  tax ; look up entity type
  lda spriteTypes, x
  tay
  asl ; double it since objectFactory contains words
  tax

  pla
  pha
  jsr .doCreate
  pla
  ply
  plx
  rts

; -----------------------------------------------------------------------------
; JSR wrapper for objectFactory
; -----------------------------------------------------------------------------
.doCreate  
  jsr ecsEntityCreate
  jsr ecsLocationSetCurrentEntityType
  jsr setLocation

  jmp (objectFactory, x)


; -----------------------------------------------------------------------------
; objectFactory
; -----------------------------------------------------------------------------
; Callback for each object type. called when an object of that type is created
;
; Inputs:
;  A: TileId (as set in the level file)
;  ZP_ECS_CURRENT_ENTITY
;  ZP_CURRENT_CELL_X, ZP_CURRENT_CELL_Y
; -----------------------------------------------------------------------------
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

; -----------------------------------------------------------------------------
; placeholder callbacks (not yet implemented)
; -----------------------------------------------------------------------------
createEmpty:
createBase:
createRam:
createHardware:
createSwitch:
createExit:
createDisk:
createPort:
createBug:
createZonk:
createInfotron:
  rts




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
