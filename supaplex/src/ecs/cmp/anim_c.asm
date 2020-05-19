; Supaplex - Commander X16
;
; Animation component
;
; Copyright (c) 2020 Troy Schrapel
;
; This code is licensed under the MIT license
;
; https://github.com/visrealm/supaplex-x16
;

ECS_CMP_ANIM_ASM_ = 1

; animation component applied to a game object
; controls the sequence of tile ids to be displayed
; for a given state

; each contains:
; 0: repeat[7]  reverse[6]  unused[5-4] step[3-0]
; 1: animId[7 - 0]

; Single cell animations
; ----------------------
; snik turn x 4 (+ rev)
; terminal x 2
; electron x 1
; infotron slurp
; bug
; base slurp
; explode
; infotron explode
; red disk slurp
; murphy exit
; murphy attempt push (+rev)

; Multi-cell animations
; ---------------------
; snik move x 8 (2 cells, 4 directions);
; electron move x 4 (2 cells, 2 directions) (+ rev)
; infotron roll 2x (2 cells) (+ rev)
; infotron fall 2x (2 cells)
; zonk roll 2x (2 cells) (+ rev)
; zonk fall 2x (2 cells)
; orange disk x4 (2 cells, 2 directions) (+rev)
; yellow disk x4 (2 cells, 2 directions) (+rev)
; murphy move x4 (2 cells, 2 directions) (+rev)
; murphy push x2 (2 cells, 1 directions) (+rev)