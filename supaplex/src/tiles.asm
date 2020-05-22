; Supaplex - Commander X16
;
; Tile definitions
;
; Copyright (c) 2020 Troy Schrapel
;
; This code is licensed under the MIT license
;
; https://github.com/visrealm/supaplex-x16
;
;


TILE_SIZE         = 16
HALF_TILE_SIZE    = TILE_SIZE / 2
TILE_SIZE_BYTES   = 16 * 16 / 2  ; 16 x 16 x 4bpp

; -----------------------------------------------------------------------------
; tileset addresses
; -----------------------------------------------------------------------------
STATIC_ADDR = VRADDR_TILE_BASE
PODIZO_ADDR = STATIC_ADDR + TILE_SIZE_BYTES * 32
MURPHY_ADDR = PODIZO_ADDR + TILE_SIZE_BYTES * 32
INFOTR_ADDR = MURPHY_ADDR + TILE_SIZE_BYTES * 16
SNIKSN_ADDR = INFOTR_ADDR + TILE_SIZE_BYTES * 16
TERMIN_ADDR = SNIKSN_ADDR + TILE_SIZE_BYTES * 16
BUGBAS_ADDR = TERMIN_ADDR + TILE_SIZE_BYTES * 16
EXPLOD_ADDR = BUGBAS_ADDR + TILE_SIZE_BYTES * 16
ELECTR_ADDR = EXPLOD_ADDR + TILE_SIZE_BYTES * 16
FONT_ADDR =   ELECTR_ADDR + TILE_SIZE_BYTES * 16

; -----------------------------------------------------------------------------
; palette indexes
; -----------------------------------------------------------------------------
STATIC_PAL  = 1
PODIZO_PAL  = 2
MURPHY_PAL  = 14
INFOTR_PAL  = 4
SNIKSN_PAL  = 5
TERMIN_PAL  = 6
BUGBAS_PAL  = 7
EXPLOD_PAL  = 8
ELECTR_PAL  = 9

; -----------------------------------------------------------------------------
; tile flags
; -----------------------------------------------------------------------------
TILE_FLIP_H = $04
TILE_FLIP_V = $08

; -----------------------------------------------------------------------------
; load the tiles from disk into vram
; -----------------------------------------------------------------------------
loadTiles:
  +setRamBank 0
  +vLoadPcx staticPcx,  STATIC_ADDR, STATIC_PAL
  +vLoadPcx podizoPcx,  PODIZO_ADDR, PODIZO_PAL
  +vLoadPcx murphyPcx,  MURPHY_ADDR, MURPHY_PAL
  +vLoadPcx infotrPcx,  INFOTR_ADDR, INFOTR_PAL
  +vLoadPcx sniksnPcx,  SNIKSN_ADDR, SNIKSN_PAL
  +vLoadPcx terminPcx,  TERMIN_ADDR, TERMIN_PAL
  +vLoadPcx bugbasPcx,  BUGBAS_ADDR, BUGBAS_PAL
  +vLoadPcx explodPcx,  EXPLOD_ADDR, EXPLOD_PAL
  +vLoadPcx electrPcx,  ELECTR_ADDR, ELECTR_PAL

  lda #<tileTable
  sta ZP_TILE_TABLE_L
  lda #>tileTable
  sta ZP_TILE_TABLE_H

  rts


; -----------------------------------------------------------------------------
; tile definitions
; -----------------------------------------------------------------------------
; two bytes per tile in the VERA tile format:
;
; Offset	Bit 7	Bit 6	Bit 5	Bit 4	Bit 3	Bit 2	Bit 1	Bit 0
; 0	        [ Tile index (7:0)                                            ]
; 1	        [ Palette offset              ][V-flip][H-flip][Tile index 9:8]
;
; -----------------------------------------------------------------------------
!macro tileDef index, tilesetAddr, tileOffset, tilePalette, tileFlags {
    
    .tilesetOffset = (tilesetAddr - VRADDR_TILE_BASE) / TILE_SIZE_BYTES

    ; tile offset
    .tileOffset    = .tilesetOffset + tileOffset

    ; tile index (7:0)
    !byte .tileOffset & $ff

    ; palette offset (7:4), flags, tile offset (9:8)
    !byte (tilePalette << 4) | tileFlags | (.tileOffset >> 8)
}

!align 255,0
tileTable:
tileBlank:        +tileDef   0, PODIZO_ADDR, 17, PODIZO_PAL, 0
tileZonk:         +tileDef   1, PODIZO_ADDR, 14, PODIZO_PAL, 0
tileBase:         +tileDef   2, STATIC_ADDR, 0, STATIC_PAL, 0
tileMurphy:       +tileDef   3, MURPHY_ADDR, 0, MURPHY_PAL, 0
tileInfo:         +tileDef   4, INFOTR_ADDR, 0, INFOTR_PAL, 0
tile6502Sm:       +tileDef   5, STATIC_ADDR, 1, STATIC_PAL, 0
tileBlock:        +tileDef   6, STATIC_ADDR, 2, STATIC_PAL, 0
tileExit:         +tileDef   7, STATIC_ADDR, 3, STATIC_PAL, 0
tileDiskOr:       +tileDef   8, PODIZO_ADDR, 5, PODIZO_PAL, 0
tilePortRt:       +tileDef   9, PODIZO_ADDR, 0, PODIZO_PAL, 0
tilePortDn:       +tileDef  10, PODIZO_ADDR, 1, PODIZO_PAL, 0
tilePortLt:       +tileDef  11, PODIZO_ADDR, 0, PODIZO_PAL, TILE_FLIP_H
tilePortUp:       +tileDef  12, PODIZO_ADDR, 1, PODIZO_PAL, TILE_FLIP_V
tileSpPortRt:     +tileDef  13, PODIZO_ADDR, 0, PODIZO_PAL, 0
tileSpPortDn:     +tileDef  14, PODIZO_ADDR, 1, PODIZO_PAL, 0
tileSpPortLt:     +tileDef  15, PODIZO_ADDR, 0, PODIZO_PAL, TILE_FLIP_H
tileSpPortUp:     +tileDef  16, PODIZO_ADDR, 1, PODIZO_PAL, TILE_FLIP_V
tileSnikSnak:     +tileDef  17, SNIKSN_ADDR, 0, SNIKSN_PAL, 0
tileDiskYellow:   +tileDef  18, PODIZO_ADDR, 6, PODIZO_PAL, 0
tileTerm:         +tileDef  19, TERMIN_ADDR, 0, TERMIN_PAL, 0
tileDiskRed:      +tileDef  20, PODIZO_ADDR, 7, PODIZO_PAL, 0
tilePortV:        +tileDef  21, PODIZO_ADDR, 2, PODIZO_PAL, 0
tilePortH:        +tileDef  22, PODIZO_ADDR, 3, PODIZO_PAL, 0
tilePortX:        +tileDef  23, PODIZO_ADDR, 4, PODIZO_PAL, 0
tileElectron:     +tileDef  24, ELECTR_ADDR, 0, ELECTR_PAL, 0
tileBugBase:      +tileDef  25, STATIC_ADDR, 0, STATIC_PAL, 0
tile6502L:        +tileDef  26, STATIC_ADDR, 10, STATIC_PAL, 0
tile6502R:        +tileDef  27, STATIC_ADDR, 11, STATIC_PAL, 0
tileButton:       +tileDef  28, STATIC_ADDR, 4, STATIC_PAL, 0
tileLedG:         +tileDef  29, STATIC_ADDR, 5, STATIC_PAL, 0
tileLedB:         +tileDef  30, STATIC_ADDR, 6, STATIC_PAL, 0
tileLedR:         +tileDef  31, STATIC_ADDR, 7, STATIC_PAL, 0
tileWarning:      +tileDef  32, STATIC_ADDR, 12, STATIC_PAL, 0
tilePcb1:         +tileDef  33, STATIC_ADDR, 13, STATIC_PAL, 0
tilePcb2:         +tileDef  34, STATIC_ADDR, 14, STATIC_PAL, 0
tilePcb3:         +tileDef  35, STATIC_ADDR, 15, STATIC_PAL, 0
tilePcb4:         +tileDef  36, STATIC_ADDR, 8, STATIC_PAL, 0
tilePcb5:         +tileDef  37, STATIC_ADDR, 9, STATIC_PAL, 0
tile6502T:        +tileDef  38, STATIC_ADDR, 1, STATIC_PAL, 0
tile6502B:        +tileDef  39, STATIC_ADDR, 1, STATIC_PAL, 0
tileClock:        +tileDef  40, STATIC_ADDR, 31, STATIC_PAL, 0
tileMurphySad:    +tileDef  41, MURPHY_ADDR, 4, MURPHY_PAL, 0
tilePushRt:       +tileDef  42, MURPHY_ADDR, 5, MURPHY_PAL, TILE_FLIP_H
tilePushLt:       +tileDef  43, MURPHY_ADDR, 5, MURPHY_PAL, 0
tileLookUp:       +tileDef  44, MURPHY_ADDR, 6, MURPHY_PAL, 0
tileLookDn:       +tileDef  45, MURPHY_ADDR, 7, MURPHY_PAL, 0
tileShrink1:      +tileDef  46, MURPHY_ADDR, 9, MURPHY_PAL, 0
tileShrink2:      +tileDef  47, MURPHY_ADDR, 10, MURPHY_PAL, 0
tileShrink3:      +tileDef  48, MURPHY_ADDR, 11, MURPHY_PAL, 0
tileShrink4:      +tileDef  49, MURPHY_ADDR, 12, MURPHY_PAL, 0
tileShrink5:      +tileDef  50, MURPHY_ADDR, 13, MURPHY_PAL, 0
tileShrink6:      +tileDef  51, MURPHY_ADDR, 14, MURPHY_PAL, 0
tileShrink7:      +tileDef  52, MURPHY_ADDR, 15, MURPHY_PAL, 0
tileShrink8:      +tileDef  53, PODIZO_ADDR, 17, PODIZO_PAL, 0
tileMurphyUhOh:   +tileDef  54, MURPHY_ADDR, 8, MURPHY_PAL, 0
tileBug1:         +tileDef  55, BUGBAS_ADDR, 0, BUGBAS_PAL, 0
tileBug2:         +tileDef  56, BUGBAS_ADDR, 1, BUGBAS_PAL, 0
tileBug3:         +tileDef  57, BUGBAS_ADDR, 2, BUGBAS_PAL, 0
tileBug4:         +tileDef  58, BUGBAS_ADDR, 3, BUGBAS_PAL, 0
tileBug5:         +tileDef  59, BUGBAS_ADDR, 4, BUGBAS_PAL, 0
tileBaseEat1:     +tileDef  60, STATIC_ADDR, 24, STATIC_PAL, 0
tileBaseEat2:     +tileDef  61, STATIC_ADDR, 25, STATIC_PAL, 0
tileBaseEat3:     +tileDef  62, STATIC_ADDR, 26, STATIC_PAL, 0
tileBaseEat4:     +tileDef  63, STATIC_ADDR, 27, STATIC_PAL, 0
tileBaseEat5:     +tileDef  64, STATIC_ADDR, 28, STATIC_PAL, 0
tileBaseEat6:     +tileDef  65, STATIC_ADDR, 29, STATIC_PAL, 0
tileBaseEat7:     +tileDef  66, STATIC_ADDR, 30, STATIC_PAL, 0
tileElectronEat1: +tileDef  67, ELECTR_ADDR, 5, ELECTR_PAL, 0
tileElectronEat2: +tileDef  68, ELECTR_ADDR, 6, ELECTR_PAL, 0
tileElectronEat3: +tileDef  69, ELECTR_ADDR, 7, ELECTR_PAL, 0
tileElectronEat4: +tileDef  70, ELECTR_ADDR, 8, ELECTR_PAL, 0
tileElectronEat5: +tileDef  71, ELECTR_ADDR, 9, ELECTR_PAL, 0
tileElectronEat6: +tileDef  72, ELECTR_ADDR, 10, ELECTR_PAL, 0
tileElectronEat7: +tileDef  73, ELECTR_ADDR, 11, ELECTR_PAL, 0
tileDiskEat1:     +tileDef  74, PODIZO_ADDR, 8, PODIZO_PAL, 0
tileDiskEat2:     +tileDef  75, PODIZO_ADDR, 9, PODIZO_PAL, 0
tileDiskEat3:     +tileDef  76, PODIZO_ADDR, 10, PODIZO_PAL, 0
tileDiskEat4:     +tileDef  77, PODIZO_ADDR, 11, PODIZO_PAL, 0
tileDiskEat5:     +tileDef  78, PODIZO_ADDR, 12, PODIZO_PAL, 0
tileDiskEat6:     +tileDef  79, PODIZO_ADDR, 13, PODIZO_PAL, 0
tileDiskEat7:     +tileDef  80, PODIZO_ADDR, 14, PODIZO_PAL, 0
tileExplod1:      +tileDef  81, EXPLOD_ADDR, 0, EXPLOD_PAL, 0
tileExplod2:      +tileDef  82, EXPLOD_ADDR, 1, EXPLOD_PAL, 0
tileExplod3:      +tileDef  83, EXPLOD_ADDR, 2, EXPLOD_PAL, 0
tileExplod4:      +tileDef  84, EXPLOD_ADDR, 3, EXPLOD_PAL, 0
tileExplod5:      +tileDef  85, EXPLOD_ADDR, 4, EXPLOD_PAL, 0
tileExplod6:      +tileDef  86, EXPLOD_ADDR, 5, EXPLOD_PAL, 0
tileExplod7:      +tileDef  87, EXPLOD_ADDR, 6, EXPLOD_PAL, 0
tileInfoExplod7:  +tileDef  88, EXPLOD_ADDR, 0, EXPLOD_PAL, 0
tileInfoExplod6:  +tileDef  89, EXPLOD_ADDR, 1, EXPLOD_PAL, 0
tileInfoExplod5:  +tileDef  90, EXPLOD_ADDR, 2, EXPLOD_PAL, 0
tileInfoExplod4:  +tileDef  91, EXPLOD_ADDR, 7, EXPLOD_PAL, 0
tileInfoExplod3:  +tileDef  92, EXPLOD_ADDR, 8, EXPLOD_PAL, 0
tileInfoExplod2:  +tileDef  93, EXPLOD_ADDR, 9, EXPLOD_PAL, 0
tileInfoExplod1:  +tileDef  94, EXPLOD_ADDR, 10, EXPLOD_PAL, 0
tileSnikUr:       +tileDef  95, SNIKSN_ADDR, 1, SNIKSN_PAL, TILE_FLIP_H
tileSnikUp:       +tileDef  96, SNIKSN_ADDR, 0, SNIKSN_PAL, 0
tileSnikUl:       +tileDef  97, SNIKSN_ADDR, 1, SNIKSN_PAL, 0
tileSnikL:        +tileDef  98, SNIKSN_ADDR, 2, SNIKSN_PAL, 0
tileSnikDl:       +tileDef  99, SNIKSN_ADDR, 1, SNIKSN_PAL, TILE_FLIP_V
tileSnikDn:       +tileDef 100, SNIKSN_ADDR, 0, SNIKSN_PAL, TILE_FLIP_V
tileSnikDr:       +tileDef 101, SNIKSN_ADDR, 1, SNIKSN_PAL, TILE_FLIP_V | TILE_FLIP_H
tileSnikR:        +tileDef 102, SNIKSN_ADDR, 2, SNIKSN_PAL, TILE_FLIP_H
tileConsoleGn1:   +tileDef 103, TERMIN_ADDR, 0, TERMIN_PAL, 0
tileConsoleGn2:   +tileDef 104, TERMIN_ADDR, 1, TERMIN_PAL, 0
tileConsoleGn3:   +tileDef 105, TERMIN_ADDR, 2, TERMIN_PAL, 0
tileConsoleGn4:   +tileDef 106, TERMIN_ADDR, 3, TERMIN_PAL, 0
tileConsoleGn5:   +tileDef 107, TERMIN_ADDR, 4, TERMIN_PAL, 0
tileConsoleGn6:   +tileDef 108, TERMIN_ADDR, 5, TERMIN_PAL, 0
tileConsoleGn7:   +tileDef 109, TERMIN_ADDR, 6, TERMIN_PAL, 0
tileConsoleGn8:   +tileDef 110, TERMIN_ADDR, 7, TERMIN_PAL, 0
tileConsoleRd1:   +tileDef 111, TERMIN_ADDR, 0, TERMIN_PAL, 0
tileConsoleRd2:   +tileDef 112, TERMIN_ADDR, 1, TERMIN_PAL, 0
tileConsoleRd3:   +tileDef 113, TERMIN_ADDR, 2, TERMIN_PAL, 0
tileConsoleRd4:   +tileDef 114, TERMIN_ADDR, 3, TERMIN_PAL, 0
tileConsoleRd5:   +tileDef 115, TERMIN_ADDR, 4, TERMIN_PAL, 0
tileConsoleRd6:   +tileDef 116, TERMIN_ADDR, 5, TERMIN_PAL, 0
tileConsoleRd7:   +tileDef 117, TERMIN_ADDR, 6, TERMIN_PAL, 0
tileConsoleRd8:   +tileDef 118, TERMIN_ADDR, 7, TERMIN_PAL, 0
tileElectron1:    +tileDef 119, ELECTR_ADDR, 0, ELECTR_PAL, 0
tileElectron2:    +tileDef 120, ELECTR_ADDR, 1, ELECTR_PAL, 0
tileElectron3:    +tileDef 121, ELECTR_ADDR, 2, ELECTR_PAL, 0
tileElectron4:    +tileDef 122, ELECTR_ADDR, 3, ELECTR_PAL, 0
tileElectron5:    +tileDef 123, ELECTR_ADDR, 4, ELECTR_PAL, 0
tileElectron6:    +tileDef 124, ELECTR_ADDR, 5, ELECTR_PAL, 0
tileElectron7:    +tileDef 125, ELECTR_ADDR, 6, ELECTR_PAL, 0
tileElectron8:    +tileDef 126, ELECTR_ADDR, 7, ELECTR_PAL, 0
tileSnikUp1:      +tileDef 127, SNIKSN_ADDR, 0, SNIKSN_PAL, 0
tileSnikUp2:      +tileDef 128, SNIKSN_ADDR, 0, SNIKSN_PAL, 0
tileSnikUp3:      +tileDef 129, SNIKSN_ADDR, 0, SNIKSN_PAL, 0
tileSnikUp4:      +tileDef 130, SNIKSN_ADDR, 5, SNIKSN_PAL, 0
tileSnikUp5:      +tileDef 131, SNIKSN_ADDR, 5, SNIKSN_PAL, 0
tileSnikUp6:      +tileDef 132, SNIKSN_ADDR, 4, SNIKSN_PAL, 0
tileSnikUp7:      +tileDef 133, SNIKSN_ADDR, 4, SNIKSN_PAL, 0
tileSnikUp8:      +tileDef 134, SNIKSN_ADDR, 3, SNIKSN_PAL, 0
tileSnikDn1:      +tileDef 135, SNIKSN_ADDR, 0, SNIKSN_PAL, TILE_FLIP_V
tileSnikDn2:      +tileDef 136, SNIKSN_ADDR, 0, SNIKSN_PAL, TILE_FLIP_V
tileSnikDn3:      +tileDef 137, SNIKSN_ADDR, 0, SNIKSN_PAL, TILE_FLIP_V
tileSnikDn4:      +tileDef 138, SNIKSN_ADDR, 4, SNIKSN_PAL, TILE_FLIP_V
tileSnikDn5:      +tileDef 139, SNIKSN_ADDR, 4, SNIKSN_PAL, TILE_FLIP_V
tileSnikDn6:      +tileDef 140, SNIKSN_ADDR, 5, SNIKSN_PAL, TILE_FLIP_V
tileSnikDn7:      +tileDef 141, SNIKSN_ADDR, 5, SNIKSN_PAL, TILE_FLIP_V
tileSnikDn8:      +tileDef 142, SNIKSN_ADDR, 3, SNIKSN_PAL, TILE_FLIP_V
tileMurphyLeft1:  +tileDef 143, MURPHY_ADDR, 4, MURPHY_PAL, 0
tileMurphyLeft2:  +tileDef 144, MURPHY_ADDR, 4, MURPHY_PAL, 0
tileMurphyLeft3:  +tileDef 145, MURPHY_ADDR, 4, MURPHY_PAL, 0
tileMurphyLeft4:  +tileDef 146, MURPHY_ADDR, 4, MURPHY_PAL, 0
tileMurphyLeft5:  +tileDef 147, MURPHY_ADDR, 2, MURPHY_PAL, 0
tileMurphyLeft6:  +tileDef 148, MURPHY_ADDR, 2, MURPHY_PAL, 0
tileMurphyLeft7:  +tileDef 149, MURPHY_ADDR, 1, MURPHY_PAL, 0
tileMurphyLeft8:  +tileDef 150, MURPHY_ADDR, 1, MURPHY_PAL, 0
tileMurphyRight1: +tileDef 151, MURPHY_ADDR, 4, MURPHY_PAL, TILE_FLIP_H
tileMurphyRight2: +tileDef 152, MURPHY_ADDR, 4, MURPHY_PAL, TILE_FLIP_H
tileMurphyRight3: +tileDef 153, MURPHY_ADDR, 4, MURPHY_PAL, TILE_FLIP_H
tileMurphyRight4: +tileDef 154, MURPHY_ADDR, 4, MURPHY_PAL, TILE_FLIP_H
tileMurphyRight5: +tileDef 155, MURPHY_ADDR, 2, MURPHY_PAL, TILE_FLIP_H
tileMurphyRight6: +tileDef 156, MURPHY_ADDR, 2, MURPHY_PAL, TILE_FLIP_H
tileMurphyRight7: +tileDef 157, MURPHY_ADDR, 1, MURPHY_PAL, TILE_FLIP_H
tileMurphyRight8: +tileDef 158, MURPHY_ADDR, 1, MURPHY_PAL, TILE_FLIP_H
tileZonkRoll1:    +tileDef 159, PODIZO_ADDR, 16, PODIZO_PAL, 0
tileZonkRoll2:    +tileDef 160, PODIZO_ADDR, 15, PODIZO_PAL, 0
tileZonkRoll3:    +tileDef 161, PODIZO_ADDR, 16, PODIZO_PAL, TILE_FLIP_H
tileZonkRoll4:    +tileDef 162, PODIZO_ADDR, 14, PODIZO_PAL, 0
tileZonkRoll5:    +tileDef 163, PODIZO_ADDR, 16, PODIZO_PAL, 0
tileZonkRoll6:    +tileDef 164, PODIZO_ADDR, 15, PODIZO_PAL, 0
tileZonkRoll7:    +tileDef 165, PODIZO_ADDR, 16, PODIZO_PAL, TILE_FLIP_H
tileZonkRoll8:    +tileDef 166, PODIZO_ADDR, 14, PODIZO_PAL, 0
tileInfoRoll1:    +tileDef 167, INFOTR_ADDR, 1, INFOTR_PAL, 0
tileInfoRoll2:    +tileDef 168, INFOTR_ADDR, 2, INFOTR_PAL, 0
tileInfoRoll3:    +tileDef 169, INFOTR_ADDR, 3, INFOTR_PAL, 0
tileInfoRoll4:    +tileDef 170, INFOTR_ADDR, 4, INFOTR_PAL, 0
tileInfoRoll5:    +tileDef 171, INFOTR_ADDR, 1, INFOTR_PAL, TILE_FLIP_H | TILE_FLIP_V
tileInfoRoll6:    +tileDef 172, INFOTR_ADDR, 2, INFOTR_PAL, TILE_FLIP_H | TILE_FLIP_V
tileInfoRoll7:    +tileDef 173, INFOTR_ADDR, 3, INFOTR_PAL, TILE_FLIP_H | TILE_FLIP_V
tileInfoRoll8:    +tileDef 174, INFOTR_ADDR, 4, INFOTR_PAL, TILE_FLIP_H | TILE_FLIP_V
tileEdgeBr:       +tileDef 175, STATIC_ADDR, 16, STATIC_PAL, 0
tileEdgeBl:       +tileDef 176, STATIC_ADDR, 17, STATIC_PAL, 0
tileEdgeTr:       +tileDef 177, STATIC_ADDR, 18, STATIC_PAL, 0
tileEdgeTl:       +tileDef 178, STATIC_ADDR, 19, STATIC_PAL, 0
tileEdgeR:        +tileDef 179, STATIC_ADDR, 20, STATIC_PAL, 0
tileEdgeL:        +tileDef 180, STATIC_ADDR, 21, STATIC_PAL, 0
tileEdgeB:        +tileDef 181, STATIC_ADDR, 22, STATIC_PAL, 0
tileEdgeT:        +tileDef 182, STATIC_ADDR, 23, STATIC_PAL, 0
tileSnikLeft1:    +tileDef 183, SNIKSN_ADDR, 2, SNIKSN_PAL, 0
tileSnikLeft2:    +tileDef 184, SNIKSN_ADDR, 5, SNIKSN_PAL, 0
tileSnikLeft3:    +tileDef 185, SNIKSN_ADDR, 6, SNIKSN_PAL, 0
tileSnikLeft4:    +tileDef 186, SNIKSN_ADDR, 7, SNIKSN_PAL, 0
tileSnikLeft5:    +tileDef 187, SNIKSN_ADDR, 7, SNIKSN_PAL, 0
tileSnikLeft6:    +tileDef 188, SNIKSN_ADDR, 6, SNIKSN_PAL, 0
tileSnikLeft7:    +tileDef 189, SNIKSN_ADDR, 5, SNIKSN_PAL, 0
tileSnikLeft8:    +tileDef 190, SNIKSN_ADDR, 2, SNIKSN_PAL, 0
tileSnikRight1:   +tileDef 191, SNIKSN_ADDR, 2, SNIKSN_PAL, TILE_FLIP_H
tileSnikRight2:   +tileDef 192, SNIKSN_ADDR, 5, SNIKSN_PAL, TILE_FLIP_H
tileSnikRight3:   +tileDef 193, SNIKSN_ADDR, 6, SNIKSN_PAL, TILE_FLIP_H
tileSnikRight4:   +tileDef 194, SNIKSN_ADDR, 7, SNIKSN_PAL, TILE_FLIP_H
tileSnikRight5:   +tileDef 195, SNIKSN_ADDR, 7, SNIKSN_PAL, TILE_FLIP_H
tileSnikRight6:   +tileDef 196, SNIKSN_ADDR, 6, SNIKSN_PAL, TILE_FLIP_H
tileSnikRight7:   +tileDef 197, SNIKSN_ADDR, 5, SNIKSN_PAL, TILE_FLIP_H
tileSnikRight8:   +tileDef 198, SNIKSN_ADDR, 2, SNIKSN_PAL, TILE_FLIP_H
