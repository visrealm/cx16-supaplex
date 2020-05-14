; Commander X16
;
; Utility subroutines and macros
;
; Copyright (c) 2020 Troy Schrapel
;
; This code is licensed under the MIT license
;
; https://github.com/visrealm/supaplex-x16
;
;

!macro dec16 addr {
  lda addr
  bne +
  dec addr + 1
+
  dec addr
}

!macro inc16 addr {
  inc addr
  bne +
  inc addr + 1
+
}