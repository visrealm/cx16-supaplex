; Supaplex - Commander X16
;
; VRAM addresses
;
; Copyright (c) 2020 Troy Schrapel
;
; This code is licensed under the MIT license
;
; https://github.com/visrealm/supaplex-x16
;


; VERA memory map:
; -----------------------------------------------------------------------------
;  $0000      (0) -  $09FF   (4095) - (64 x 32 x 2 = 4,096 bytes) even frame map
;  $1A00   (4096) -  $19FF   (8191) - (64 x 32 x 2 = 4,096 bytes) odd frame map
;  $2000   (8192) -  $3FFF  (16383) - (8,192 bytes) UNUSED
;  $4000  (16384) -  $BFFF  (49151) - (16 x 16 x 128 = 32,768 bytes) L0 tiles
;  $C000  (49152) - $155FF  (87551) - (320 x 240 / 2 = 38,400 bytes) L1 overlay
; $15600  (87552) - $1F9BF (129471) - (41,920 bytes) UNUSED
;
; $1F9C0 - $1F9FF	PSG registers
; $1FA00 - $1FBFF	Palette
; $1FC00 - $1FFFF	Sprite attributes
;


; -----------------------------------------------------------------------------
; VRAM addresses
; -----------------------------------------------------------------------------
VRADDR_MAP_BASE_EVEN  = $0000
VRADDR_MAP_BASE_ODD   = $1000
VRADDR_TILE_BASE      = $4000
VRADDR_OVERLAY        = $C000
