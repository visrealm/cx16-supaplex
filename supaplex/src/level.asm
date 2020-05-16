; Supaplex - Commander X16
;
; Level structure
;
; Copyright (c) 2020 Troy Schrapel
;
; This code is licensed under the MIT license
;
; https://github.com/visrealm/supaplex-x16
;
;

; level structure:
; infotrons required
; name
; gravity

	
	LEVEL_TILES_BYTES          = 1440
  LEVEL_HAS_GRAVITY_OFFSET   = LEVEL_TILES_BYTES + 4
  LEVEL_NAME_OFFSET          = LEVEL_TILES_BYTES + 6
	LEVEL_FREEZE_ZONKS_OFFSET  = LEVEL_TILES_BYTES + 29
	LEVEL_NUM_INFOTRONS_OFFSET = LEVEL_TILES_BYTES + 30
	LEVEL_NUM_SPECIAL_OFFSET   = LEVEL_TILES_BYTES + 31
	LEVEL_SPECIAL_OFFSET 	     = LEVEL_TILES_BYTES + 32
	LEVEL_NUM_SPECIAL 		     = 10
	LEVEL_SPECIAL_BYTES 		   = 6

  