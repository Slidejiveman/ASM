TITLE "SIMPLE CALCULATOR"
;****************************************************************************
;* Title: Simple Calculator                                                 *
;* Author: Ryder Dale Walton                                                *
;* Date: 10/17/2016                                                         *
;* Purpose: This program performs signed add, sub, and comp of two nums.    *
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
maxLen  EQU     8                       ; Maximum entry string length
bell    EQU     7                       ; Bell character -- <ctrl>G

;****************************************************************************
;* Data Section                                                             *
;****************************************************************************
        .DATA

exCode   db     0                                       ; DOS error code

welcome  db     'Please enjoy Simple Calculator!', EOS  ; Welcome text
asknum1  db     'What is the first number?   : ', EOS   ; Prompt for entry 1
asknum2  db     'What is the second number?  : ', EOS   ; Prompt for entry 2
askop    db     'Enter operation (+ / - / C) : ', EOS   ; Prompt for op type
num1str  db     maxLen dup(?)                           ; Hold answer 1
num2str  db     maxLen dup(?)                           ; Hold answer 2
num1     dw     0                                       ; Hold converted num1
num2     dw     0                                       ; Hold converted num2
resltlbl db     'The result is               : ', EOS   ; Result label
resltstr db     maxLen dup(?)                           ; Hold result as str
resltnum dw     0                                       ; Hold result as num
compequ  db     'The numbers are equal.', EOS           ; Show comp is ==
num1grtr db     'The 1st number is greater', EOS        ; Show comp 1 > 2
num2grtr db     'The 2nd number is greater', EOS        ; Show comp 2 > 1
opchar   db     '+', EOS                                ; Hold operation ans
askagain db     'Do another calculation? (Y/N) ', EOS   ; Prompt for repeat
repchar  db     'N', EOS                                ; Intention to repeat  
exitstr  db     'Exiting Program.', EOS                 ; Closing statement
inperror db     bell, 'Invalid Number -- Reenter', EOS  ; Input error message
operror  db     bell, 'Invalid operator --Reenter', EOS ; Op inp error mesg
overerr  db     bell, 'Error -- Overflow', EOS          ; Overflow err mesg

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
;* Ask user to enjoy the experience                                         *
;****************************************************************************
Introduction:
        call    NewLine                    ; Start new display line
        mov     di, OFFSET welcome         ; Position dest index for welcome
        call    StrWrite                   ; Print out welcome to user
 
;****************************************************************************
;* Collect and convert user numbers                                         *
;****************************************************************************       
NumEntry:        
        call    NewLine                    ; Start new display line
        call    NewLine                    ; Add extra emphasis for section
        mov     di, OFFSET asknum1         ; Position dest index for prompt
        call    StrWrite                   ; Ask user for first number        
        mov     di, OFFSET num1str         ; Position desination index
        mov     cx, maxLen                 ; Set string limit for answer
        call    StrRead                    ; Read in first number
 
        mov     di, OFFSET num1str         ; Reset dest index to num1
        call    AscToBin                   ; Convert entered num to bin
        jc      NumberErr                  ; CF == 1 means invalid num         
        mov     num1, ax                   ; Save first conv value for later
        
        call    NewLine                    ; A new line for aesthetics
        mov     di, OFFSET asknum2         ; Position dest index for prompt
        call    StrWrite                   ; Ask user for the second number
        mov     di, OFFSET num2str         ; Position dest index for answer
        mov     cx, maxLen                 ; Set string limit for answer
        call    StrRead                    ; Read in second number     

        mov     di, OFFSET num2str         ; Set dest index to num2 location
        call    AscToBin                   ; Convert entered num to bin
        jc      NumberErr                  ; CF == 1 means invalid num
        mov     num2, ax                   ; Save second conv value for later 
        jmp     CalcType                   ; Jump to avoid memory constraints

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
        
        call    NewLine                    ; Make space for cleaner output
        cmp     repchar, 'Y'               ; See if ZF is set for decision
        jne     CheckLowerY                ; If repchar isn't Y, check for y
        jmp     NumEntry                   ; If repchar is Y, loop back
 
;****************************************************************************
;* Determine type of calculation to perform                                 *
;****************************************************************************        
CalcType:        
        call    NewLine                    ; Call NewLine to prevent OVR
        mov     di, OFFSET askop           ; Move dest index and ask op type
        call    StrWrite                   ; Print out the operation prompt
        mov     di, OFFSET opchar          ; Move dest index to receive ans
        mov     cx, 2                      ; Hold char and 00
        call    StrRead                    ; opchar now holds user selection
        
        cmp     opchar, '+'                ; Compare ascii values for equality
        je      Addition                   ; If equal, jump to add section
        cmp     opchar, '-'                ; Compare ascii values for equality
        je      Subtract                   ; If equal, jump to sub section
        cmp     opchar, 'C'                ; Compare ascii values for equality
        jne     CheckLowerC                ; If not equal, check for little c 
        jmp     Comparison                 ; If equal, user wants comparison

;****************************************************************************
;* Print error message if invalid number entered                            *
;****************************************************************************
NumberErr:
        call   NewLine                    ; Jump a line to prevent OVR
        mov    di, OFFSET inperror        ; Num is invalid is incorrect
        call   StrWrite                   ; Print error message
        jmp    NumEntry                   ; Jump back to input stage

;****************************************************************************
;* Print error message if user fails to enter 'Y', 'y', 'N', or 'n'.        *
;****************************************************************************
RepErr:
        call   NewLine                    ; Create space to prevent OVR
        mov    di, OFFSET inperror        ; Invalid char entry at prompt
        call   StrWrite                   ; Display the error to the screen
        jmp    DoItAgain                  ; Jump to the prompt again

;****************************************************************************
;* Print error message if user fails to enter '+', '-', 'C', or 'c'.        *
;****************************************************************************
OpErr:
        call   NewLine                    ; Create space to prevent OVR 
        mov    di, OFFSET operror         ; Prepare to alert user of error
        call   StrWrite                   ; Display error to the screen
        jmp    CalcType                   ; Give user another change to enter

;****************************************************************************
;* If Overflow, display this to the screen                                  *
;****************************************************************************
OverflowErr:
        call    NewLine                   ; Create space to prevent OVR
        mov     di, OFFSET overerr        ; Prepare to display message
        call    StrWrite                  ; Write out the message
        jmp     DoItAgain                 ; Ask user for another try

;****************************************************************************
;* If entry doesn't equal 'Y', check for 'y' for robustness sake.           *
;****************************************************************************
CheckLowerY:
        cmp     repchar, 'y'              ; Check if lowercase entry exists
        jne     CheckUpperN               ; If not, check for 'N'
        jmp     NumEntry                  ; If so, redo the loop

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
;* If operation type isn't a +, -, or 'C', check for 'c'.                   *
;****************************************************************************
CheckLowerC:
        cmp      opchar, 'c'               ; Compare ascii values for equality
        jne      OpErr                     ; If not equal, error!
        jmp      Comparison                ; If 'c', jump to comparison op

;****************************************************************************
;* The addition section adds two numbers                                    *
;****************************************************************************
Addition:
        mov      ax, num1                  ; Move num1 into ax register 
        add      ax, num2                  ; Add memory to register
        jo       OverflowErr               ; Overflow check here
        mov      resltnum, ax              ; Store result in variable
        mov      di, OFFSET resltstr       ; Move di to receive result str
        mov      cx, 1                     ; Variable chars will be displayed
        call     SBinToAscDec              ; Signed result is returned
        jmp      Result                    ; Jump to display result        
 
;****************************************************************************
;* The subtraction section subtracts two numbers                            *
;****************************************************************************
Subtract:
        mov      ax, num1                  ; Move num1 into ax register 
        sub      ax, num2                  ; Sub from value in register
        jo       OverflowErr               ; Overflow check here
        mov      resltnum, ax              ; Store result in variable
        mov      di, OFFSET resltstr       ; Move di to receive result str
        mov      cx, 1                     ; Variable chars will be displayed
        call     SBinToAscDec              ; Signed result is returned
        jmp      Result                    ; Jump to display result

;****************************************************************************
;* The comparison section compares two numbers                              *
;****************************************************************************
Comparison:
        mov      ax, num1                  ; Move num1 into ax register 
        cmp      ax, num2                  ; Compare two entered num values
        je       CompEqual                 ; If equal, jump to said section
        jg       Num1Greater               ; if num1 greater, jmp to said sec
        
        call     NewLine                   ; Print space to avoid OVR
        mov      di, OFFSET num2grtr       ; If not == or num1, must be num2 
        call     StrWrite                  ; Write message to screen                          
        jmp      DoItAgain                 ; Prompt for another go

;****************************************************************************
;* Comparing the two strings yielded an equal result                        *
;****************************************************************************
CompEqual:
        call     NewLine                   ; Print space to avoid OVR
        mov      di, OFFSET compequ        ; If ==, prepare to display msg
        call     StrWrite                  ; Display message to screen
        jmp      DoItAgain                 ; Prompt for another go

;****************************************************************************
;* Comparing the two strings yielded the first is larger                    *
;****************************************************************************
Num1Greater:
        call     NewLine                   ; Print space to avoid OVR
        mov      di, OFFSET num1grtr       ; If num1 greater, prepare di
        call     StrWrite                  ; Write message to screen
        jmp      DoItAgain                 ; Prompt for another go

;****************************************************************************
;* Show the result of the calculation                                       *
;****************************************************************************
Result:
        call    NewLine                    ; Display NewLine to prevent OVR   
        mov     di, OFFSET resltlbl        ; Prepare to write result label
        call    StrWrite                   ; Display the result label

        mov     di, OFFSET resltstr        ; Prepare to write ans to screen
        call    StrWrite                   ; Display the result on screen 
        jmp     DoItAgain                  ; Ask to repeat after success        

;****************************************************************************
;* End of Program: Print exit notice                                        *
;****************************************************************************
Done:
        call    NewLine                    ; Prevent OVR with a new line
        mov     di, OFFSET exitstr         ; Position di to print string
        call    StrWrite                   ; Print notification of exit         

;****************************************************************************
;* Program termination code.                                                *
;****************************************************************************
        mov     ah, 04Ch                ; DOS function: Exit program
        mov     al, exCode              ; Return exit code value
        int     21h                     ; Call DOS. Terminate program

        END     Start                   ; End of program / entry point