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

objectFactory:
!word createEmpty
!word createZonk
!word createBase
!word createPlayer
!word createInfotron
!word createRamchip
!word createHardware
!word createExit
!word createDisk
!word createPort
!word createPort
!word createPort
!word createPort
!word createPort
!word createPort
!word createPort
!word createPort
!word createSnikSnak
!word createDisk
!word createTerminal
!word createDisk
!word createPort
!word createPort
!word createPort
!word createElectron
!word createBug
!word createRamchip
!word createRamchip
!word createHardware
!word createHardware
!word createHardware
!word createHardware
!word createHardware
!word createHardware
!word createHardware
!word createHardware
!word createHardware
!word createHardware
!word createRamchip
!word createRamchip

; -----------------------------------------------------------------------------
; Factory functions
; -----------------------------------------------------------------------------
; inputs:
;   A: Object type id
;   A: Object type id
; returns
;   A: MSB byte of queue
;   Y: starting offset (head index)
; -----------------------------------------------------------------------------

createEmpty:
createZonk:
createBase:
createPlayer:
createInfotron:
createRamchip:
createHardware:
createSwitch:
createExit:
createTerminal:
createDisk:
createPort:
createBug:
  rts

createEnemy:
  rts

createSnikSnak:
  jsr createEnemy
  rts

createElectron:
  jsr createEnemy
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



; type structure
; tileId
; flags: empty
;        consumable (can be eaten)
;        pushable
;        pushable_v (perhaps pushable & !canfall?)
;        rounded (rounded objects can fall from rounded objects)
;        explosive (explodes when objects fall on it)
;        explosive_electron
;        invincible
;        enemy
;        port
;        switch (special ports?)
;        canfall



SPRITE_FLAG_CONSUMABLE  = %0000000000000001
SPRITE_FLAG_PUSHABLE    = %0000000000000010
SPRITE_FLAG_ROUNDED     = %0000000000000100
SPRITE_FLAG_EXPLOSIVE   = %0000000000001000
SPRITE_FLAG_EXPLOSIVE_E = %0000000000010000
SPRITE_FLAG_INVINCIBLE  = %0000000000100000
SPRITE_FLAG_ENEMY       = %0000000001000000
SPRITE_FLAG_PORT        = %0000000010000000
SPRITE_FLAG_SWITCH      = %0000000100000000
SPRITE_FLAG_CANFALL     = %0000001000000000
SPRITE_FLAG_MURPHY      = %0000010000000000


!macro spriteType tileId, flags {
    !byte <flags, >flags
}

spriteTypes:

; blank
+spriteType 0, 0

; zonk
+spriteType 1, SPRITE_FLAG_PUSHABLE | SPRITE_FLAG_ROUNDED | SPRITE_FLAG_CANFALL

; base
+spriteType 2, SPRITE_FLAG_CONSUMABLE

; murphy
+spriteType 3, SPRITE_FLAG_MURPHY | SPRITE_FLAG_EXPLOSIVE

; infotron
+spriteType 4, SPRITE_FLAG_MURPHY | SPRITE_FLAG_EXPLOSIVE

; ram chip
+spriteType 5, SPRITE_FLAG_ROUNDED

; hardware
+spriteType 6, SPRITE_FLAG_INVINCIBLE

; exit
+spriteType 7, SPRITE_FLAG_SWITCH

; orange disk
+spriteType 8, SPRITE_FLAG_PUSHABLE | SPRITE_FLAG_EXPLOSIVE | SPRITE_FLAG_CANFALL

; ports
+spriteType 9,  SPRITE_FLAG_PORT ; right
+spriteType 10, SPRITE_FLAG_PORT ; down
+spriteType 11, SPRITE_FLAG_PORT ; left
+spriteType 12, SPRITE_FLAG_PORT ; up
+spriteType 13, SPRITE_FLAG_PORT ; special right
+spriteType 14, SPRITE_FLAG_PORT ; special down
+spriteType 15, SPRITE_FLAG_PORT ; special left
+spriteType 16, SPRITE_FLAG_PORT ; special up

; snik snak
+spriteType 17, SPRITE_FLAG_ENEMY | SPRITE_FLAG_EXPLOSIVE

; yellow disk
+spriteType 18, SPRITE_FLAG_PUSHABLE | SPRITE_FLAG_EXPLOSIVE

; terminal
+spriteType 19, SPRITE_FLAG_SWITCH

; red disk
+spriteType 20, SPRITE_FLAG_CONSUMABLE | SPRITE_FLAG_EXPLOSIVE

; more ports
+spriteType 21, SPRITE_FLAG_PORT ; vert
+spriteType 22, SPRITE_FLAG_PORT ; horz
+spriteType 23, SPRITE_FLAG_PORT ; cross

; electron
+spriteType 24, SPRITE_FLAG_ENEMY | SPRITE_FLAG_EXPLOSIVE_E

; bug
+spriteType 25, SPRITE_FLAG_CONSUMABLE | SPRITE_FLAG_ENEMY

; ram chip (horz)
+spriteType 26, SPRITE_FLAG_ROUNDED
+spriteType 27, SPRITE_FLAG_ROUNDED

; hardware
+spriteType 28, SPRITE_FLAG_INVINCIBLE
+spriteType 29, SPRITE_FLAG_INVINCIBLE
+spriteType 30, SPRITE_FLAG_INVINCIBLE
+spriteType 31, SPRITE_FLAG_INVINCIBLE
+spriteType 32, SPRITE_FLAG_INVINCIBLE
+spriteType 33, SPRITE_FLAG_INVINCIBLE
+spriteType 34, SPRITE_FLAG_INVINCIBLE
+spriteType 35, SPRITE_FLAG_INVINCIBLE
+spriteType 36, SPRITE_FLAG_INVINCIBLE
+spriteType 37, SPRITE_FLAG_INVINCIBLE

; ram chip (horz)
+spriteType 38, SPRITE_FLAG_ROUNDED
+spriteType 39, SPRITE_FLAG_ROUNDED
