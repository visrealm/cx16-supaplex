!cpu 65c02

!source "../common/bootstrap.asm"

jmp entry

!source "../common/kernal/constants.asm"
!source "../common/string.asm"

entry:

+printStr startTests

jsr runTests
rts



!macro startTest testName {
  +printStr testStr
  +printStr testName
}

!macro testPassed {
 +printStr passedStr
}

!macro testFailed {
  +printStr failedStr
}

startTests: !pet "running unit tests",13,"------------------",13,0
newlineStr: !pet 13,0
testStr:    !pet "test: ",0
passedStr:  !pet " - passed",13,0
failedStr:  !pet " - failed",13,0

