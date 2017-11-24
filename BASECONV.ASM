TITLE "BASE CONVERTER"
;****************************************************************************
;* Title: BASE CONVERTER                                                    *
;* Author: Ryder Dale Walton                                                *
;* Date: 10/07/2016                                                         *
;* Purpose: This program gets converts decimal values to binary and hex.    *
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

welcome  db     'Welcome to the BASE CONVERTER!', EOS   ; Welcome text
askname  db     'What is your name, user?', EOS         ; Prompt for username
asknum   db     'Enter a dec num from 0 - 65535 : ', EOS; Sum output label
username db     maxLen dup (?)                          ; Username held here
greet    db     'Hello, ', EOS                          ; Greeting for user
enternum db     maxLen dup (?)                          ; User entered num
convnum  db     maxLen dup (?)                          ; Holds conv string
base2    db     ' binary', EOS                          ; Indicates bin num
base10   db     ' decimal = ', EOS                      ; Indicates dec num
base16   db     ' hexadecimal', EOS                     ; Indicates hex num
askagain db     ', convert another number? (Y/N) ', EOS ; Prompt for repeat
repchar  db     'N', EOS                                ; Intention to repeat  
byebye   db     'Goodbye, ', EOS                        ; Departure blessing
inperror db     bell, ' is invalid -- Reenter.', EOS    ; Input error message

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
;* Welcome user, get name, and greet user                                   *
;****************************************************************************
Introduction:
        call    NewLine                    ; Start new display line
        mov     di, OFFSET welcome         ; Position dest index for welcome
        call    StrWrite                   ; Print out welcome to user
        
        call    NewLine                    ; Start new display line
        mov     di, OFFSET askname         ; Position dest index for prompt
        call    StrWrite                   ; Print out prompt for user name        

        call    NewLine                    ; Start new display line
        mov     di, OFFSET username        ; Position desination index
        mov     cx, maxLen                 ; Set string limit for answer
        call    StrRead                    ; Read in the user name
        
        call    NewLine                    ; Start new display line
        mov     di, OFFSET greet           ; Position greeting before name
        call    StrWrite                   ; Write out the greeting text
        mov     di, OFFSET username        ; Position dest index for prompt       
        call    StrWrite                   ; Write out user's name
        call    NewLine                    ; Create space between sections        
 
;****************************************************************************
;* Prompt for number and convert it to bin and hex                          *
;****************************************************************************
Convert:
        call    NewLine                    ; Move to new line for new section
        mov     di, OFFSET asknum          ; Prepare prompt to enter num
        call    StrWrite                   ; Write prompt to enter num

        mov     di, OFFSET enternum        ; Number gets user's entry
        mov     cx, maxLen                 ; Maximum string length
        call    StrRead                    ; Get num string from keyboard
        
        call    NewLine                    ; Prevent overwrite with NewLine
        mov     di, OFFSET enternum        ; Position to display entered num
        call    StrWrite                   ; Show entered num

        mov     di, OFFSET enternum        ; Reset back to entered number
        call    AscToBin                   ; Convert entered num to bin
        jc      NumberErr                  ; CF == 1 means invalid num 

        mov     di, OFFSET base10          ; Position to display dec label
        call    StrWrite                   ; Display the label        
        
        mov     di, OFFSET convnum         ; Position to conv num to string        
        mov     cx, 16                     ; Force 16 char output
        call    BinToAscBin                ; Convert binary num to string
     
        mov     di, OFFSET convnum         ; Move back to front of conv buff
        call    StrWrite                   ; Write out the binary string
        mov     di, OFFSET base2           ; Position to print base        
        call    StrWrite                   ; Print out base to screen
        
        call    NewLine                    ; Display next conversion
        mov     di, OFFSET enternum        ; Reset position at enternum
        call    StrWrite                   ; Display entered num again       
        mov     di, OFFSET base10          ; Prepare to display decimal label
        call    StrWrite                   ; Write label to the screen

        mov     di, OFFSET enternum        ; Prepare to convert to hex
        call    AscToBin                   ; Convert string to binary

        mov     di, OFFSET convnum         ; Prepare to hold hex string
        mov     cx, 4                      ; Set minimum display
        call    BinToAscHex                ; Convert bin to hex string        
        
        mov     di, OFFSET convnum         ; Prepare to display the string
        call    StrWrite                   ; Display the conv num
        mov     di, OFFSET base16          ; Prepare to display hex label
        call    StrWrite                   ; Display hex label
        call    NewLine                    ; Create space for next section
      
;****************************************************************************
;* Prompt user if (s)he would like to enter another number                  *
;****************************************************************************
DoItAgain:
        call    NewLine                    ; Create more space for next prompt
        mov     di, OFFSET username        ; Move offest of username into di
        call    StrWrite                   ; Display Username again
        mov     di, OFFSET askagain        ; Position for the repeat prompt
        call    StrWrite                   ; Display the question on screen

        mov     di, OFFSET repchar         ; Move to the mem loc for char
        mov     cx, 2                      ; Set room for char and 00
        call    StrRead                    ; Read in the character
        
        call    NewLine                    ; Make space for cleaner output
        cmp     repchar, 'Y'               ; See if ZF is set for decision
        jne     CheckLowerY                ; If repchar isn't Y, check for y
        jmp     Convert                    ; If repchar is Y, loop back

;****************************************************************************
;* Print error message if number format is incorrect.                       *
;****************************************************************************
NumberErr:
        mov    di, OFFSET inperror        ; Num format is incorrect
        call   StrWrite                   ; Print error message
        jmp    Convert                    ; Jump back to input stage

;****************************************************************************
;* Print error message if user fails to enter 'Y', 'y', 'N', or 'n'.        *
;****************************************************************************
CharErr:
        mov    di, OFFSET repchar         ; Position pointer to entered char
        call   StrWrite                   ; Write entered char to the screen
        mov    di, OFFSET inperror        ; Invalid char entry at prompt
        call   StrWrite                   ; Display the error to the screen
        jmp    DoItAgain                  ; Jump to the prompt again

;****************************************************************************
;* If entry doesn't equal 'Y', check for 'y' for robustness sake.           *
;****************************************************************************
CheckLowerY:
        cmp     repchar, 'y'              ; Check if lowercase entry exists
        jne     CheckUpperN               ; If not, check for 'N'
        jmp     Convert                   ; If so, redo the loop

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
        jne      CharErr                   ; If not, display an error message
        jmp      Done                      ; If so, exit the program    

;****************************************************************************
;* End of Program: Say goodbye                                              *
;****************************************************************************
Done:
        call    NewLine                    ; Write to screen for readability
        mov     di, OFFSET byebye          ; Say goodbye to user
        call    StrWrite                   ; Print it to the screen
        mov     di, OFFSET username        ; Prepare to say user's name
        call    StrWrite                   ; Print the name         

;****************************************************************************
;* Program termination code.                                                *
;****************************************************************************
        mov     ah, 04Ch                ; DOS function: Exit program
        mov     al, exCode              ; Return exit code value
        int     21h                     ; Call DOS. Terminate program

        END     Start                   ; End of program / entry point