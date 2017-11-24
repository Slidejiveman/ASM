TITLE "CRAMER'S RULE"
;****************************************************************************
;* Title: CRAMER'S RULE                                                     *
;* Author: Ryder Dale Walton                                                *
;* Date: 11/11/2016                                                         *
;* Purpose: This program solves systems of equations with Cramer's Rule.    *
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

welcome  db     'System of Equation Solver', EOS          ; Welcome text
inperror db     bell, 'Invalid -- Reenter', EOS           ; Input error mesg
askagain db     'Solve another system? (Y/N) ', EOS       ; Prompt to repeat
repchar  db     'N', EOS                                  ; Intention to rep
exitstr  db     'Thank you for the algebra.', EOS         ; Show exit msg

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
        call     NewLine                 ; Create space to prevent OVR
        call     PrintPrompt             ; SubRoutine that asks for user input
        call     CollectCoefficients     ; SubRoutine that collects user input
        mov      di, OFFSET params       ; array as returned from SubRoutine
        call     CramersRule             ; SubRoutine that calculates solution
        mov      bx, OFFSET reslt        ; array returned from subroutine
        call     PrintSolution           ; Print out answer
        jmp      DoItAgain               ; Ask user if another run is desired

;****************************************************************************
;* Prompt user if (s)he would like to perform another calculation           *
;****************************************************************************
DoItAgain:
        call    NewLine                    ; Create space for readability
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
;* PrintPrompt Subroutine asks user to enter coefficients.                   *
;****************************************************************************
PrintPrompt:
        .DATA
coeffprmt   db    'Please enter coefficient values : ', EOS ; Collection prmt
        .CODE
        call    NewLine                  ; Logical section print
        mov     di, OFFSET coeffprmt     ; Position di to write init prompt
        call    StrWrite                 ; Write prompt to Screen
        ret

;****************************************************************************
;* CollectCoefficients collects the 6 coefficients from the user.           *
;****************************************************************************
CollectCoefficients:
        .DATA
printlet    dw    0                                        ; Hold let chars
printequ    db    ' = ', EOS                               ; print equals sign
params      dw    6 dup (?)                                ; Save input words        
        .CODE
        mov    si, 'a'                 ; increment to print higher letters
        mov    bx, 0                   ; index for params
ploop:                                 ; loop to print letters and =    
        call   NewLine                 ; Create space for next section.
        mov    ax, si                  ; transition si to ax in order to print
        mov    printlet, ax            ; save printlet value from ax
        mov    di, OFFSET printlet     ; Prepare to write letter to screen
        call   StrWrite                ; Print letter to screen
        mov    di, OFFSET printequ     ; prepare to print the equals sign
        call   StrWrite                ; Print it to the screen
    
        mov    di, OFFSET params[bx]   ; prepare to accept input
        mov    cx, 5                   ; Allow up to 4 chars and EOS
        call   StrRead                 ; Accept input from keyboard
        call   AscToBin                ; Convert string to useable number
        jc     InputError              ; If invalid entry, jump to error
        cmp    ax, -128                ; Check lower bound, limit signed byte
        jl     InputError              ; If less than lower bound, jump
        cmp    ax, 127                 ; Check upper bound, limit signed byte
        jg     InputError              ; If greater than upper bound, jump
        mov    params[bx], ax          ; move value into the params array
    
        inc    si                      ; add one to prepare for next letter
        add    bx, 2                   ; prepare for next word to go into array
        cmp    si, 'f'                 ; compare with upper bound letter
        jbe    ploop                   ; until si is higher than f, printlet
        ret                            ; Return to main program
        
;****************************************************************************
;* PrintSolution prints out the calculated result.                          *
;****************************************************************************
PrintSolution:
        .DATA
answerstr   db   'Here is the solution: ', EOS       ; Solution label
xlabel      db   'x = ', EOS                         ; To print x label
ylabel      db   ', y = ', EOS                       ; To print y label 
resltstr    dw   2 dup (?)                           ; buffer for di
        .CODE
        call  NewLine                                ; Prevent OVR
        call  NewLine                                ; Logical section print
        mov   di, OFFSET answerstr                   ; prepare answer label
        call  StrWrite                               ; print label to screen
        
        mov   di, OFFSET xlabel                      ; prepare x label to print
        call  StrWrite                               ; print label to screen
        mov ax, [bx]                                 ; Indexed value into ax
        mov di, OFFSET resltstr                      ; Set offset to string loc
        mov cx, 1                                    ; allow variable chars
        call SBinToAscDec                            ; These are signed nums
        call StrWrite                                ; Print to screen

        mov di, OFFSET ylabel                        ; prepare y label to print
        call StrWrite                                ; print label to screen
        mov ax, [bx + 2]                             ; grab y indexed value
        mov di, OFFSET resltstr + 2                  ; move print offset too
        mov cx, 1                                    ; ensure variable length
        call SBinToAscDec                            ; convert to signed nums
        call StrWrite                                ; print to screen
        ret                                          ; Return to main program

;****************************************************************************
;* CramersRule performs the main calculation of program.                    *
;****************************************************************************
CramersRule:
        .DATA
lores dw    0                                       ; hold lower 16 bit reslt
detr  dw    0                                       ; hold Determinant D 
detrx dw    0                                       ; hold determinant dx
detry dw    0                                       ; hold determinant dy   
reslt dw    2 dup (?)                               ; word 1 = x, word 2 = y
nores db    'System has no single solution.', EOS   ; Str for no result
        .CODE 
;Collect the D determinant
        mov    ax, [di + 2]             ; Second word is b
        mov    bx, [di + 6]             ; Fourth word is d
        imul   bx                       ; dx:ax <= ax * bx = b*d
        mov    lores, ax                ; save the lower part of result
        mov    ax, [di]                 ; First word is a
        mov    bx, [di + 8]             ; fifth word is e
        imul   bx                       ; dx:ax <= ax * bx = a*e
        sub    ax, lores                ; ax <= ae - bd = D
        cmp    ax, 0                    ; Check for no solution case
        je     NoSolution               ; If == 0, then no solution
        mov    detr, ax                 ; ax is now determinant D

;Now collect the dx  determinant
        mov    ax, [di + 2]             ; Second word is b
        mov    bx, [di + 10]            ; Sixth word is f
        imul   bx                       ; dx:ax <= ax * bx = b*f
        mov    lores, ax                ; save the lower part of result
        mov    ax, [di + 4]             ; third word is c
        mov    bx, [di + 8]             ; fifth word is e
        imul   bx                       ; dx:ax <= ax * bx = c*e
        sub    ax, lores                ; ax <= ce - bf = Dx
        mov    detrx, ax                ; ax is now determinant Dx

;Now collect the dy determinant
        mov    ax, [di + 4]             ; Third word is c
        mov    bx, [di + 6]             ; Fourth word is d
        imul   bx                       ; dx:ax <= ax * bx = c*d
        mov    lores, ax                ; save the lower part of result
        mov    ax, [di]                 ; first word is a
        mov    bx, [di + 10]            ; Sixth word is f
        imul   bx                       ; dx:ax <= ax * bx = a*f
        sub    ax, lores                ; ax <= af - cd = Dy
        mov    detry, ax                ; ax is now determinant Dx

;Calculate x and y and store them in result array
        cwd                             ; convert signed val to dword size
        idiv   detr                     ; divide by determinant D
        mov    reslt + 2, ax            ; dx:ax / detr(word) => ax(q) && dx(r)

        mov    ax, detrx                ; Now do Dx
        cwd                             ; convert to signed double word
        idiv   detr                     ; divide by determinant D
        mov    reslt, ax                ; dx:ax / detr(word) => ax(q) && dx(r)
        ret                             ; Return when calculation completed

;****************************************************************************
;* If D == 0, there is no solution, so the calculation short circuits.      *
;****************************************************************************
NoSolution:                           ; Print there is no solution and leave
        call   NewLine                ; Avoid OVR
        call   NewLine                ; Print NewLine for aesthetics
        mov    di, OFFSET nores       ; Prepare di to read string
        call   StrWrite               ; Print message to screen
        jmp    DoitAgain              ; Ask for another try 

;****************************************************************************
;* END of program marker. Add nothing below this point. It will be ignored! *
;****************************************************************************
        END     Start                   ; End of program / entry point