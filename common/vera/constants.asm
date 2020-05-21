; Commander X16
;
; Vera constants
;
; Copyright (c) 2020 Troy Schrapel
;
; This code is licensed under the MIT license
;
; https://github.com/visrealm/supaplex-x16
;

CMN_VERA_CONSTANTS_ = 1

VERA_ADDRx_L      = $9F20
VERA_ADDRx_M      = $9F21
VERA_ADDRx_H      = $9F22
VERA_DATA0        = $9F23
VERA_DATA1        = $9F24
VERA_CTRL         = $9F25
VERA_IEN          = $9F26
VERA_ISR          = $9F27
VERA_IRQLINE_L    = $9F28
VERA_DC_VIDEO     = $9F29
VERA_DC_HSCALE    = $9F2A
VERA_DC_VSCALE    = $9F2B
VERA_DC_BORDER    = $9F2C
VERA_DC_HSTART    = $9F29
VERA_DC_HSTOP     = $9F2A
VERA_DC_VSTART    = $9F2B
VERA_DC_VSTOP     = $9F2C
VERA_L0_CONFIG    = $9F2D
VERA_L0_MAPBASE   = $9F2E
VERA_L0_TILEBASE  = $9F2F
VERA_L0_HSCROLL_L = $9F30
VERA_L0_HSCROLL_H = $9F31
VERA_L0_VSCROLL_L = $9F32
VERA_L0_VSCROLL_H = $9F33
VERA_L1_CONFIG    = $9F34
VERA_L1_MAPBASE   = $9F35
VERA_L1_TILEBASE  = $9F36
VERA_L1_HSCROLL_L = $9F37
VERA_L1_HSCROLL_H = $9F38
VERA_L1_VSCROLL_L = $9F39
VERA_L1_VSCROLL_H = $9F3A
VERA_AUDIO_CTRL   = $9F3B
VERA_AUDIO_RATE   = $9F3C
VERA_AUDIO_DATA   = $9F3D
VERA_SPI_DATA     = $9F3E
VERA_SPI_CTRL     = $9F3F

; ADDRx_H increments
; -----------------------------------------------------------------------------
VERA_INCR_0   = $00
VERA_INCR_1   = $10
VERA_INCR_2   = $20
VERA_INCR_4   = $30
VERA_INCR_8   = $40
VERA_INCR_16  = $50
VERA_INCR_32  = $60
VERA_INCR_64  = $70
VERA_INCR_128 = $80
VERA_INCR_256 = $90
VERA_INCR_512 = $A0
VERA_INCR_40  = $B0
VERA_INCR_80  = $C0
VERA_INCR_160 = $D0
VERA_INCR_320 = $E0
VERA_INCR_640 = $F0

VERA_DECR     = $08


; Interrupts
; -----------------------------------------------------------------------------
VERA_IEN_VSYNC  = $01
VERA_IEN_LINE   = $02
VERA_IEN_SPRCOL = $04
VERA_IEN_AFLOW  = $08


; DC_VIDEO
; -----------------------------------------------------------------------------
VERA_VIDEO_SPRITES_ENABLED  = $40
VERA_VIDEO_LAYER1_ENABLED   = $20
VERA_VIDEO_LAYER0_ENABLED   = $10
VERA_VIDEO_OUTPUT_DISABLED  = $00
VERA_VIDEO_OUTPUT_VGA       = $01
VERA_VIDEO_OUTPUT_NTSC      = $02
VERA_VIDEO_OUTPUT_RGB       = $03

; DC_SCALE
; -----------------------------------------------------------------------------
VERA_SCALE_1x               = $80
VERA_SCALE_2x               = $40
VERA_SCALE_4x               = $20

; Lx_CONFIG
; -----------------------------------------------------------------------------
VERA_CONFIG_1BPP          = $0
VERA_CONFIG_2BPP          = $1
VERA_CONFIG_4BPP          = $2
VERA_CONFIG_8BPP          = $3

VERA_CONFIG_BITMAP_MODE   = $4

VERA_CONFIG_MAP_WIDTH_32  = ($0 << 4)
VERA_CONFIG_MAP_WIDTH_64  = ($1 << 4)
VERA_CONFIG_MAP_WIDTH_128 = ($2 << 4)
VERA_CONFIG_MAP_WIDTH_256 = ($3 << 4)

VERA_CONFIG_MAP_HEIGHT_32  = ($0 << 6)
VERA_CONFIG_MAP_HEIGHT_64  = ($1 << 6)
VERA_CONFIG_MAP_HEIGHT_128 = ($2 << 6)
VERA_CONFIG_MAP_HEIGHT_256 = ($3 << 6)

; Lx_TILEBASE
; -----------------------------------------------------------------------------
VERA_TILE_WIDTH_8   = $00
VERA_TILE_WIDTH_16  = $01
VERA_TILE_HEIGHT_8  = $00
VERA_TILE_HEIGHT_16 = $02

; Other Vera addresses
; -----------------------------------------------------------------------------
VERA_PALETTE = $1FA00
VERA_SPRITES = $1FC00

; Sprites
; -----------------------------------------------------------------------------
VERA_SPRITE_DISABLED  = $00 << 2
VERA_SPRITE_BELOW_L0  = $01 << 2
VERA_SPRITE_BELOW_L1  = $02 << 2
VERA_SPRITE_ABOVE_L1  = $03 << 2
VERA_SPRITE_HFLIP     = $01
VERA_SPRITE_VFLIP     = $02
VERA_SPRITE_WIDTH_8   = $00 << 4
VERA_SPRITE_WIDTH_16  = $01 << 4
VERA_SPRITE_WIDTH_32  = $02 << 4
VERA_SPRITE_WIDTH_64  = $03 << 4
VERA_SPRITE_HEIGHT_8  = $00 << 6
VERA_SPRITE_HEIGHT_16 = $01 << 6
VERA_SPRITE_HEIGHT_32 = $02 << 6
VERA_SPRITE_HEIGHT_64 = $03 << 6
