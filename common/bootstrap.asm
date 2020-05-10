; standard bootstrap
; generate SYS 2064 ($810)

*=$0801			; Assembled code should start at $0801

			; (where BASIC programs start)
			; The real program starts at $0810 = 2064

!byte $0C,$08		; $080C - pointer to next line of BASIC code
!byte $0A,$00		; 2-byte line number ($000A = 10)
!byte $9E		    ; SYS BASIC token
!byte "2061"

!byte $00,$00,$00


*=$0810			; Here starts the real program