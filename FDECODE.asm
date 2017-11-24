TITLE "FLOATING POINT DECODER"
;****************************************************************************
;* Title: FLOATING POINT DECODER                                            *
;* Author: Ryder Dale Walton                                                *
;* Date: 12/09/2016                                                         *
;* Purpose: This program converts a hex float encoding into decimal.        *
;****************************************************************************
;* Grading: Correctness   ______                                            *
;*          Style         ______                                            *
;*          Documentation ______    Total ______                            *
;****************************************************************************

        .MODEL  small
        STACK   256

;****************************************************************************
;* Equates Section                                                          *
;****************************************************************************

EOS     EQU     0                       ; End of string
bell    EQU     7                       ; Bell character -- <ctrl>G

;****************************************************************************
;* Data Section                                                             *
;****************************************************************************
        .DATA

exCode   db     0                                         ; DOS error code

welcome  db     'Floating Point Decoder', EOS             ; Welcome text
inperror db     bell, 'Invalid -- Reenter', EOS           ; Input error mesg
askagain db     'Perform another calculation? (Y/N) ', EOS; Prompt to repeat
repchar  db     'N', EOS                                  ; Intention to rep
exitstr  db     'Program terminated.', EOS                ; Show exit msg

;****************************************************************************
;* Code Section                                                             *
;****************************************************************************
        .CODE

;****************************************************************************
;* External procedures from STRINGS.OBJ & STRIO.OBJ                         *
;****************************************************************************

        EXTRN   StrLength:proc, StrRead:proc
        EXTRN   StrWrite:proc, NewLine:proc

;****************************************************************************
;* External procedures from BINASC.OBJ                                      *
;****************************************************************************

        EXTRN   BinToAscHex:proc, SBinToAscDec:proc, BinToAscDec:proc
        EXTRN   BinToAscBin:proc, AscToBin:proc

;****************************************************************************
;* Main entry point of program.                                             *
;****************************************************************************
Start:  
        mov     ax, @data               ; Initialize DS to address
        mov     ds, ax                  ;  of data segment
        mov     es, ax                  ; Make es = ds

;****************************************************************************
;* Start of Main Program                                                    *
;****************************************************************************
        mov      di, OFFSET welcome      ; Prepare di to print welcome
        call     StrWrite                ; Print welcome msg to the screen

Begin:
        call     NewLine                 ; print formatting space
        call     NewLine                 ; Create space to prevent OVR
        call     PrintPrompt             ; SubRoutine that asks for user input
        call     Decode                  ; SubRoutine that performs main logic
        jmp      DoItAgain               ; Ask user if another run is desired

;****************************************************************************
;* Prompt user if (s)he would like to perform another calculation           *
;****************************************************************************
DoItAgain:
        call    NewLine                    ; Allow extra space for new prompt
        mov     di, OFFSET askagain        ; Position for the repeat prompt
        call    StrWrite                   ; Display the question on screen

        mov     di, OFFSET repchar         ; Move to the mem loc for char
        mov     cx, 2                      ; Set room for char and 00
        call    StrRead                    ; Read in the character
        
        cmp     repchar, 'Y'               ; See if ZF is set for decision
        jne     CheckLowerY                ; If repchar isn't Y, check for y
        jmp     Begin                      ; If repchar is Y, loop back

;****************************************************************************
;* If entry doesn't equal 'Y', check for 'y' for robustness sake.           *
;****************************************************************************
CheckLowerY:
        cmp     repchar, 'y'               ; Check if lowercase entry exists
        jne     CheckUpperN                ; If not, check for 'N'
        jmp     Begin                      ; If so, redo the loop
        
;****************************************************************************
;* If entry isn't 'Y' or 'y', check to see if it is 'N'.                    *
;****************************************************************************
CheckUpperN:
        cmp      repchar, 'N'              ; Check to see if 'N' was entered
        jne      CheckLowerN               ; If not, check for 'n'
        jmp      Done                      ; If so, exit the program

;****************************************************************************
;* If entry isn't 'N', check to see if it is 'n'.                           *
;****************************************************************************
CheckLowerN:
        cmp      repchar, 'n'              ; Check to see if 'n' was entered
        jne      RepErr                    ; If not, display an error message
        jmp      Done                      ; If so, exit the program    
      
;****************************************************************************
;* Print error message if user fails to enter 'Y', 'y', 'N', or 'n'.        *
;****************************************************************************
RepErr:
        call   NewLine                    ; Create space to prevent OVR
        mov    di, OFFSET inperror        ; Invalid char entry at prompt
        call   StrWrite                   ; Display the error to the screen
        jmp    DoItAgain                  ; Jump to the prompt again

;****************************************************************************
;* Print error message if user fails to enter valid number.                 *
;****************************************************************************
InputError:
        call   NewLine                    ; Create space to avoid OVR
        mov    di, OFFSET inperror        ; Invalid number at prompt
        call   StrWrite                   ; Display error to screen
        jmp    Begin                      ; Allow  user to start over

;****************************************************************************
;* End of Program.                                                          *
;****************************************************************************
Done:
        call   NewLine                    ; Avoid OVR
        call   NewLine                    ; Logical section print
        mov    di, OFFSET exitstr         ; Prepare exit message
        call   StrWrite                   ; Print exit message to screen

;****************************************************************************
;* Program termination code.                                                *
;****************************************************************************
        mov     ah, 04Ch                ; DOS function: Exit program
        mov     al, exCode              ; Return exit code value
        int     21h                     ; Call DOS. Terminate program

;****************************************************************************
;* PrintPrompt Subroutine asks user to enter a hex num to convert.          *
;****************************************************************************
PrintPrompt:
        .DATA
hexprmt   db    'Please enter high 16-bits of hex num followed by h: ', EOS 
                                                            ; Collection prmt
        .CODE
        mov     di, OFFSET hexprmt       ; Position di to write init prompt
        call    StrWrite                 ; Write prompt to Screen
        ret

;****************************************************************************
;* Decode accepts the hex number and decodes it by converting it to decimal.*
;****************************************************************************
Decode:
        .DATA
entered    db    7 dup(?)                              ; The numstr to decode
sign       db    '+', EOS                              ; Pos sign to print out
printsent  db    'The value of this number is ', EOS   ; Label for print outs
zero       db    ' zero', EOS                          ; Zero special case
NaN        db    ' NaN', EOS                           ; Not a number case
infinity   db    ' infinity', EOS                      ; + or - infinity case
negexpend  db    '0.0', EOS                            ; neg exponent print 0.0
decend     db    '.0', EOS                             ; decorates decoded int
magnum     dw    0                                     ; holds pos exp value
        .CODE
        
ReadInput:           ; read in input from the user.
        mov  di, OFFSET entered                        ; Hold's entered value
        mov  cx, 7                                     ; Max number to accepts
        call StrRead                                   ; Read in keyboard input
        call AscToBin                                  ; conv bin num to hex=>ax
        jc   InputError                                ; unsuccessful conversion
        
FindSign:            ; determine whether number is pos or neg
        mov  sign, '+'                                 ; always reset sign
        shl  ax, 1                                     ; shift high bit to CF
        jnc  Exponent                                  ; Sign is positive
        inc  sign                                      ; Inc twice for ascii val
        inc  sign                                      ; change to value for '-'

Exponent:            ; Determine exponent value in ah
        cmp ax, 0000h                                  ; handle special case 0
        je  PrintZero                                  ; jump to that logic
        cmp ah, 0FFh                                   ; Check for all 1 exponent
        jne Unbias                                     ; if not, unbias
        cmp al, 00h                                    ; Check for infinity case
        je  PrintInfinity                              ; if == go to that logic
        jmp PrintNaN                                   ; Must not be a number

Unbias:              ; Unbias the exponent to determine next branch
        sub  ah, 7Fh                                   ; Subtract (signed) 127
        test ah, 80h                                   ; if high bit is 1, negative
        jnz  PrintNegExp                               ; Just show 0.0 in this case
        mov  cl, 15                                    ; total num of bits - 1
        sub  cl, ah                                    ; use diff to shr later

Magnitude:           ; Find the magnitude for printing since positive exponent
        shl  ax, 7                                     ; move magnitude to ah
        or   ax, 8000h                                 ; Add hidden 1 back in
        shr  ax, cl                                    ; shift until int is left
        mov  magnum, ax                                ; Save value before newline
        jmp  PrintMagnitude                            ; Print pos exp value

PrintZero:           ; Entered number is zero.
        call NewLine                                   ; formatting space
        mov  di, OFFSET printsent                      ; Print opening text
        call StrWrite                                  ; Write to screen
        mov  di, OFFSET zero                           ; Prepare to print zero
        call StrWrite                                  ; Write Zero to Screen
        jmp  DoItAgain                                 ; Try for repeat

PrintInfinity:       ; Entered number is + or - infinity
        call NewLine                                   ; formatting space
        mov  di, OFFSET printsent                      ; prepare opening text
        call StrWrite                                  ; write to screen
        mov  di, OFFSET sign                           ; prepare sign for print
        call StrWrite                                  ; print sign to screen
        mov  di, OFFSET infinity                       ; finally prepare "infinity"
        call StrWrite                                  ; print to screen
        jmp  DoItAgain                                 ; Try for repeat

PrintNaN:            ; Entered number is not a number
        call NewLine                                   ; formatting space
        mov  di, OFFSET printsent                      ; Print opening text
        call StrWrite                                  ; Print to screen
        mov  di, OFFSET NaN                            ; prepare to print NaN
        call StrWrite                                  ; Print to the screen
        jmp  DoItAgain                                 ; Try for repeat

PrintNegExp:         ; Exponent is negative, so print 0.0 with leading int
        call NewLine                                   ; formatting space
        mov  di, OFFSET printsent                      ; prepare opening text
        call StrWrite                                  ; print to screen
        mov  di, OFFSET negexpend                      ; print 0.0 in this case
        call StrWrite                                  ; Write it to screen
        jmp  DoItAgain                                 ; Try for repeat

PrintMagnitude:      ; Print the positive exponent solution
        call NewLine                                   ; Print formatting space
        mov  di, OFFSET printsent                      ; prepare leading text
        call StrWrite                                  ; write to screen
        mov  di, OFFSET sign                           ; prepare sign to screen
        call StrWrite                                  ; write sign to screen
        mov  di, OFFSET entered                        ; hold converted number
        mov  cx, 1                                     ; minimum output size
        mov  ax, magnum                                ; value to print
        call BinToAscDec                               ; converted in di
        mov  di, OFFSET entered                        ; prepare to write num
        call StrWrite                                  ; write to screen
        mov  di, OFFSET decend                         ; prepare the .0
        call StrWrite                                  ; print end of string
        ret                                            ; End of SubRoutine

;****************************************************************************
;* END of program marker. Add nothing below this point. It will be ignored! *
;****************************************************************************
        END     Start                   ; End of program / entry point