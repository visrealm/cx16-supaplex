; Supaplex - Commander X16
;
; RAM banks
;
; Copyright (c) 2020 Troy Schrapel
;
; This code is licensed under the MIT license
;
; https://github.com/visrealm/supaplex-x16
;

; Central place to keep track of RAM banks used

RAM_BANK_SCRATCH        = 0

; sound effects
RAM_BANK_SFX_BASE       = 2
RAM_BANK_SFX_INFOTRON   = 2

; ECS
RAM_BANK_ECS_PRIMARY     = 10
RAM_BANK_ENTITY_TYPE     = RAM_BANK_ECS_PRIMARY
RAM_BANK_LOC_COMPONENT   = RAM_BANK_ECS_PRIMARY
RAM_BANK_ANIM_COMPONENT  = RAM_BANK_ECS_PRIMARY

RAM_BANK_ECS_SECONDARY   = 11
RAM_BANK_ENEMY_COMPONENT = RAM_BANK_ECS_SECONDARY
