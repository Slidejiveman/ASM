TITLE "FREQUENCY COUNTER"
;****************************************************************************
;* Title: Frequency Counter                                                 *
;* Author: Ryder Dale Walton                                                *
;* Date: 10/24/2016                                                         *
;* Purpose: This program counts the occurrences of each letter in a string. *
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
maxLen  EQU     255                     ; Maximum buffer length
maxEntr EQU     255                     ; Maximum entry string length
bell    EQU     7                       ; Bell character -- <ctrl>G

;****************************************************************************
;* Data Section                                                             *
;****************************************************************************
        .DATA

exCode   db     0                                            ; DOS error code
prmpt1   db     'Please enter a character string : ', EOS    ; Prompt for 1st num
prmpt2   db     'The string entered is : ', EOS              ; Show entry result
buffer   db     maxLen dup (?)                               ; Holds answer
prmptagn db     'Please go right ahead : ', EOS              ; Flavor string
tbltitl  db     'Character Frequency Table : ', EOS          ; Table name string
charhead db     'Character', EOS                             ; Char col header
freqhead db     'Frequency', EOS                             ; Freq col header
dashes   db     '---------', EOS                             ; Go under cols
spacnine db     '         ', EOS                             ; Spacing for heads
spacsvtn db     '                 ', EOS                     ; Spacing to handle
spacsxtn db     '                ', EOS                      ;  two digit format
spacfour db     '    ', EOS                                  ; Spaces b4 letter
counters db     26 dup (?)                                   ; Counts for chars
cntrstr  db     26 dup (?)                                   ; Str vers. of cntrs
printlet dw     0                                            ; Hold letter chars
askagain db     'Process another string? (Y/N) ', EOS        ; Prompt to repeat
repchar  db     'N', EOS                                     ; Intention to rep
exitstr  db     'Thanks for using the FreqCounter.', EOS     ; Show exit msg
inperror db     bell, 'Invalid -- Reenter', EOS              ; Input error mesg

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
;* Prompt user for the input sting to be analyzed.                          *
;****************************************************************************
        call    NewLine                 ; Create space for each run
		mov     di, OFFSET prmpt1       ; Prepare to ask for user input
		call    StrWrite                ; Write message to the string
		
StringPrompt:
        call    NewLine                 ; Format to match assignment sheet
		mov     di, OFFSET buffer       ; Prepare to read in user answer
		mov     cx, maxEntr             ; Holds the user's input
		call    StrRead                 ; Read in the user's input
		
		call    NewLine                 ; Create a NewLine to prevent OVR
		mov     di, OFFSET prmpt2       ; Prepare to display entry prompt
		call    StrWrite                ; Write message to the screen
		call    NewLine                 ; Add a newline for aesthetics
		mov     di, OFFSET buffer       ; Prepare to echo user input back output
		call    StrWrite                ; Write input out to the screen

;****************************************************************************
;* Zero out the counter values for clean runs                               *
;****************************************************************************
ZeroTable:
        mov     si, 0                   ; use si to index counters
		mov     cx, 26                  ; use cx as a loop counters
zloop:  mov     counters[si], 0         ; Zero out byte at offset si
        inc     si                      ; point si to next byte
		dec     cx                      ; decrement counter to stop
		jnz     zloop                   ; if not 0, then do it again

;****************************************************************************
;* Convert input alphabetic characters to upper case and count them.        *
;****************************************************************************
        mov     si, OFFSET 0            ; use source index to access buffer
ToUpper:
        mov     al, buffer[si]          ; use register indirect addressing
		cmp     al, EOS                 ; check for end of string termination
		je      CountChars              ; If equal to 00, move to next section
		cmp     al, 'a'                 ; Don't mask less than 61 hex
		jb      ucontinue               ;   because unpredictable results
		cmp     al, 'z'                 ; Don't mask over 7A hex. Unnecessary.
		ja      ucontinue               ; Still need to increment and continue
		and     al, 11011111b           ; mask to convert lower to uppercase
		mov     buffer[si], al          ; save new value into place si points

ucontinue:
        inc     si                      ; increment pointer to next byte
		jmp     ToUpper                 ; jump to beginning of uppercase loop

CountChars:
		mov     si, OFFSET 0            ; Reset si to beginning of buffer
cloop:  mov     al, buffer[si]          ; Give value of current byte to reg
		cmp     al, EOS                 ; Test to see if it is 00
		je      PrintTable              ; If == 00, convert nums to string
		
		sub     buffer[si], 'A'         ; Get diff. of cur. val. and 'A'
		mov     al, buffer[si]          ; Save result in al byte
		cmp     al, 0                   ; Test result for lower bound error
		jb      ccontinue                ; If out of bounds, jump ahead
		cmp     al, 25                  ; Test result for upper bound error
		ja      ccontinue                ; If out of bounds, jump ahead
		mov     ah, 0                   ; High byte must be 0 because the
		mov     di, ax                  ;    registers work with words
		inc     counters[di]            ; Use di for indirect access inc
		
ccontinue:
        inc     si                      ; increment si to next byte
		jmp     cloop                   ; Restart the counting loop

;****************************************************************************
;* Print out the table with frequency counts.                               *
;****************************************************************************
PrintTable:
        call   NewLine                  ; Create space to prevent OVR
		call   NewLine                  ; Create space for the table title
		mov    di, OFFSET tbltitl       ; Prepare to print table title
		call   StrWrite                 ; Print title to the screen
		
		call   NewLine                  ; Create space for first table line
		call   NewLine                  ; Create blank space for heading
        mov    di, OFFSET charhead      ; List first character header
		call   StrWrite                 ; Write the column to the string
		mov    di, OFFSET spacnine      ; Space for next column header
		call   StrWrite                 ; Write spaces to the screen
		mov    di, OFFSET freqhead      ; Move di to the frequency header
		call   StrWrite                 ; Print out the frequency header
		mov    di, OFFSET spacnine      ; Prepare to pring the spaces between
		call   StrWrite                 ; Write the spaces to the screen
		mov    di, OFFSET spacnine      ; Prepare additionals space between
		call   StrWrite                 ;     between the major columns
		mov    di, OFFSET charhead      ; Prepare the next major column
		call   StrWrite                 ; Write the charhead to the screen
		mov    di, OFFSET spacnine      ; Prepare to write out the spaces
		call   StrWrite                 ; Write the spaces before the freqhead
		mov    di, OFFSET freqhead      ; Prepare the frequency header
		call   StrWrite                 ; Print out the final frequency head
		
		call   NewLine                  ; Begin the second line of the table
		mov    di, OFFSET dashes        ; Prepare to print dashes under headers
		call   StrWrite                 ; Write the dashes to the screen
		mov    di, OFFSET spacnine      ; Space for next column header
		call   StrWrite                 ; Write spaces to the screen
		mov    di, OFFSET dashes        ; Prepare to print dashes under headers
		call   StrWrite                 ; Write dashes to the screen
		mov    di, OFFSET spacnine      ; Prepare to pring the spaces between
		call   StrWrite                 ; Write the spaces to the screen
		mov    di, OFFSET spacnine      ; Prepare additionals space between
		call   StrWrite                 ;     between the major columns
		mov    di, OFFSET dashes        ; Prepare to print dashes under headers
		call   StrWrite                 ; Write the dashes to the screen
		mov    di, OFFSET spacnine      ; Space for next column header
		call   StrWrite                 ; Write spaces to the screen
		mov    di, OFFSET dashes        ; Prepare to print dashes under headers
		call   StrWrite                 ; Write the dashes to the screen

		mov    si, 0                    ; Move 0 into si for indexing
		mov    bx, 13                   ; Hold offset for two columns.
tloop:  call   NewLine                  ; Prepare the other lines of table
		mov    di, OFFSET spacfour      ; Print spaces to center letter
		call   StrWrite                 ; Print spaces to the screen
		add    si, 'A'                  ; Adding 'A' to si, shows A-M
		mov    ax, si                   ; transition si to ax
		mov    printlet, ax             ; save ax's value in printlet
		mov    di, OFFSET printlet      ; Prepare letter for printing
		call   StrWrite                 ; Print first letter to screen
		mov    di, OFFSET spacsxtn      ; I have decided to show two digits
		call   StrWrite                 ;    this spacing facilitates that

		sub    si, 'A'                  ; Remove the added difference
		mov    al, counters[si]         ; Move current counter to low byte
		mov    ah, 0                    ; 0 to high byte for to make word
		mov    di, OFFSET cntrstr[si]   ; Move di to hold num char
		mov    cx, 2                    ; Print only 1 character
		call   BinToAscDec              ; Convert counter number here
		call   StrWrite                 ; Write the num to the screen
		
		mov    di, OFFSET spacsvtn      ; Prepare to print spaces
		call   StrWrite                 ; Print the spaces to the screen
		mov    di, OFFSET spacnine      ; Print spaces to center letter
		call   StrWrite                 ; Print spaces to the screen
		
		add    si, 'N'                  ; Adding 'N' to si, shows N-Z
		mov    ax, si                   ; transition si to ax
		mov    printlet, ax             ; save ax's value in printlet
		mov    di, OFFSET printlet      ; Prepare letter for printing
		call   StrWrite                 ; Print first letter to screen
		mov    di, OFFSET spacsxtn      ; I have decided to show two digits
		call   StrWrite                 ;    this spacing facilitates that
		
		sub    si, 'N'                  ; To return to original value
		mov    al, counters[bx+si]      ; mov current count + base offset
		mov    ah, 0                    ; 0 to high byte to make a word
		mov    di, OFFSET cntrstr[bx+si]; Move di to hold offset num char
		mov    cx, 2                    ; Print only 1 character
		call   BinToAscDec              ; Convert counter number here
		call   StrWrite                 ; Write the num to the screen
		
		inc    si                       ; Prepare si for next runs
		cmp    si, 13                   ; Compare si sinc cx is in use
		je     DoItAgain                ; If equal, proceed
		jmp    tloop                    ; If not equal, loop back again

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
		jmp     FlavorPrompt               ; If repchar is Y, loop back

;****************************************************************************
;* If entry doesn't equal 'Y', check for 'y' for robustness sake.           *
;****************************************************************************
CheckLowerY:
        cmp     repchar, 'y'              ; Check if lowercase entry exists
        jne     CheckUpperN               ; If not, check for 'N'
		jmp     FlavorPrompt              ; If so, redo the loop

;****************************************************************************
;* If the user decides to go again, print some flavor text for interest.    *
;****************************************************************************		
FlavorPrompt:
		call    NewLine                   ; Prevent overwrite
		mov     di, OFFSET prmptagn       ; Prepare some flavor text
		call    StrWrite                  ; Write flavor text to screen
		jmp     StringPrompt              ; Return to main string routine
		
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
;* End of Program.                                                          *
;****************************************************************************
Done:
       call   NewLine                     ; Create space to prevent OVR
	   mov    di, OFFSET exitstr          ; Prepare to show the exit msg
	   call   StrWrite                    ; Write message to string

;****************************************************************************
;* Program termination code.                                                *
;****************************************************************************
        mov     ah, 04Ch                ; DOS function: Exit program
        mov     al, exCode              ; Return exit code value
        int     21h                     ; Call DOS. Terminate program

        END     Start                   ; End of program / entry point