TITLE "Example Program #1"
;****************************************************************************
;* Title: Example Program #1                                                *
;* Author: Ryder Dale Walton                                                *
;* Date: 9/21/2016                                                          *
;* Purpose: This program gets two numbers and prints out the sum            *
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
maxLen  EQU     40                      ; Maximum entry string length
bell    EQU     7                       ; Bell character -- <ctrl>G

;****************************************************************************
;* Data Section                                                             *
;****************************************************************************
        .DATA

exCode   db     0                                       ; DOS error code

enter1   db     'Enter first number : ', EOS            ; Prompt for 1st num
enter2   db     'Enter second number: ', EOS            ; Prompt for 2nd num
sumout   db     'The sum is         : ', EOS            ; Sum output label
number1  dw     0                                       ; First number
number2  dw     0                                       ; Second number
sum      dw     0                                       ; Sum
buffer   db     maxLen dup (?)                          ; Input/Output buffer
inperror db     bell, 'Invalid number -- Reenter.', EOS ; Input error message
sumerror db     bell, 'The sum is too large.', EOS      ; Sum error message

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
;* Get the first number                                                     *
;****************************************************************************
First:
        call    NewLine                    ; Start new display line
        mov     di, OFFSET enter1          ; Display message to enter
        call    StrWrite                   ;     first number

        mov     di, OFFSET buffer          ; Buffer will get user's entry
        mov     cx, maxLen                 ; Maximum string Length
        call    StrRead                    ; Get entry from keyboard

        call    AscToBin                   ; Convert string to binary --> ax
        mov     number1, ax                ; Save value into variable
        jnc     Second                     ; Jump if cf is 0--no error
        call    NewLine
        mov     di, OFFSET inperror        ; Else display error message
        call    StrWrite
        jmp     First                      ; Let user try again

;****************************************************************************
;* Get the second number                                                    *
;****************************************************************************
Second:
        call    NewLine                    ; Start new display line
        mov     di, OFFSET enter2          ; Display message to enter
        call    StrWrite                   ;    second number

        mov     di, OFFSET buffer          ; Buffer will get user's entry
        mov     cx, maxLen                 ; Maximum string length
        call    StrRead                    ; Get entry from keyboard
        
        call    AscToBin                   ; Convert string to binary --> ax
        mov     number2, ax                ; Save value into variable
        jnc     GetSum                     ; Jump if cf is 0--no error
        call    NewLine
        mov     di, OFFSET inperror        ; else display error message
        call    StrWrite                   
        jmp     Second                     ; Let user try again

;****************************************************************************
;* Calculate the sum and print it out.                                      *
;****************************************************************************
GetSum:
        call    NewLine
        mov     ax, number1               ; Put firsst number into ax
        add     ax, number2               ; Add second number to ax
        jc      TooBig                    ; Carry set means answer is too big
        mov     sum, ax                   ; Save ax into variable
        mov     di, OFFSET buffer         ; Point to buffer string
        mov     ax, sum                   ; Number argument for BinToAscDec
        mov     cx, 1                     ; Length argument for BinToAscDec
        call    BinToAscDec               ; Convert sum to string for printing
        call    StrWrite                  ; Send buffer to screen
        jmp     Done

;****************************************************************************
;* Print error message if the sum is too big.                               *
;****************************************************************************
TooBig:
        mov    di, OFFSET sumerror        ; Print out "Sum too big"
        call   StrWrite                   ; Error message

;****************************************************************************
;* End of Program                                                           *
;****************************************************************************
Done:
        call    NewLine
        call    NewLine

;****************************************************************************
;* Program termination code.                                                *
;****************************************************************************
        mov     ah, 04Ch                ; DOS function: Exit program
        mov     al, exCode              ; Return exit code value
        int     21h                     ; Call DOS. Terminate program

        END     Start                   ; End of program / entry point