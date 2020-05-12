!source "..\common\kernal\constants.asm"
!source "..\common\vera\constants.asm"
!source "..\common\bootstrap.asm"

jmp entry

!source "..\common\string.asm"
!source "..\common\vera\vera.asm"

; program entry
; --------------------------------
entry:


+printStr string1
+printStr string2


jsr	CHRIN	; read input until enter/return is pressed
rts		    ; program exit

; string data
; ---------------------------------
string1 !pet	"hello, tr2oy!!",13,0
string2 !pet	"hello, world!!",13,0

