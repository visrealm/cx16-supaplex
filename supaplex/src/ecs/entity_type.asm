; Supaplex - Commander X16
;
; ECS entity types
;
; Copyright (c) 2020 Troy Schrapel
;
; This code is licensed under the MIT license
;
; https://github.com/visrealm/supaplex-x16
;

ECS_ENTITY_TYPE_ASM_ = 1

!ifndef ECS_ADDRESS { !error "Must set address for ECS system to use: ECS_ADDRESS" }

!zone ecsEntityType {

; -----------------------------------------------------------------------------
; entity types
; -----------------------------------------------------------------------------
ENTITY_TYPE_EMPTY        = 0 ; need?
ENTITY_TYPE_ZONK         = 1
ENTITY_TYPE_PLAYER       = 2
ENTITY_TYPE_BASE         = 3
ENTITY_TYPE_YELLOW_DISK  = 4
ENTITY_TYPE_RED_DISK     = 5
ENTITY_TYPE_ORANGE_DISK  = 6
ENTITY_TYPE_TERMINAL     = 7
ENTITY_TYPE_PORT         = 8
ENTITY_TYPE_EXIT         = 9 ; need?
ENTITY_TYPE_BUG          = 10
ENTITY_TYPE_INFOTRON     = 11
ENTITY_TYPE_ELECTRON     = 12
ENTITY_TYPE_SNIK_SNAK    = 13
ENTITY_TYPE_RAM          = 14
ENTITY_TYPE_HARDWARE     = 15

NUM_ENTITY_TYPES         = 16

; -----------------------------------------------------------------------------
; entity flags
; -----------------------------------------------------------------------------
ENTITY_FLAGL_CONSUMABLE  = %00000001
ENTITY_FLAGL_PUSHABLE    = %00000010
ENTITY_FLAGL_ROUNDED     = %00000100
ENTITY_FLAGL_EXPLOSIVE   = %00001000
ENTITY_FLAGL_CANFALL     = %00010000
ENTITY_FLAGL_INVINCIBLE  = %00100000
ENTITY_FLAGL_ENEMY       = %01000000
ENTITY_FLAGL_PORT        = %10000000

ENTITY_FLAGH_SWITCH      = %00000001
ENTITY_FLAGH_EXPLOSIVE_E = %00000010
ENTITY_FLAGH_MURPHY      = %00000100


; -----------------------------------------------------------------------------
; entity types flags
; -----------------------------------------------------------------------------
entityTypeFlags1: !zone {
.empty:  !byte $00
.zonk:   !byte ENTITY_FLAGL_PUSHABLE | ENTITY_FLAGL_ROUNDED | ENTITY_FLAGL_CANFALL
.player: !byte ENTITY_FLAGL_EXPLOSIVE
.base:   !byte ENTITY_FLAGL_CONSUMABLE
.disky:  !byte ENTITY_FLAGL_PUSHABLE | ENTITY_FLAGL_EXPLOSIVE
.diskr:  !byte ENTITY_FLAGL_CONSUMABLE | ENTITY_FLAGL_EXPLOSIVE
.disko:  !byte ENTITY_FLAGL_PUSHABLE | ENTITY_FLAGL_EXPLOSIVE | ENTITY_FLAGL_CANFALL
.term:   !byte $00
.port:   !byte ENTITY_FLAGL_PORT
.exit:   !byte $00
.bug:    !byte ENTITY_FLAGL_CONSUMABLE | ENTITY_FLAGL_ENEMY 
.infotr: !byte ENTITY_FLAGL_CONSUMABLE | ENTITY_FLAGL_CANFALL | ENTITY_FLAGL_ROUNDED
.electr: !byte ENTITY_FLAGL_ENEMY | ENTITY_FLAGL_EXPLOSIVE
.snik:   !byte ENTITY_FLAGL_ENEMY | ENTITY_FLAGL_EXPLOSIVE
.ram:    !byte ENTITY_FLAGL_ROUNDED
.hardwr: !byte ENTITY_FLAGL_INVINCIBLE 
}


entityTypeFlags2: !zone {
.empty:  !byte $00
.zonk:   !byte $00
.player: !byte ENTITY_FLAGH_MURPHY
.base:   !byte $00
.disky:  !byte $00
.diskr:  !byte $00
.disko:  !byte $00
.term:   !byte ENTITY_FLAGH_SWITCH
.port:   !byte $00
.exit:   !byte ENTITY_FLAGH_SWITCH
.bug:    !byte $00
.infotr: !byte $00
.electr: !byte ENTITY_FLAGH_EXPLOSIVE_E
.snik:   !byte $00
.ram:    !byte $00
.hardwr: !byte $00
}


} ; zone