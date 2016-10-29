TITLE "SIEVE OF ERATOSTHENES"
;****************************************************************************
;* Title: SIEVE OF ERATOSTHENES                                             *
;* Author: Ryder Dale Walton                                                *
;* Date: 11/2/2016                                                          *
;* Purpose: This program runs the SIEVE OF ERATOSTHENES algorithm           *
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

uprbound dw     0                                         ; upbound for alg
buffer   db     6 dup (?)                                 ; User input buffer
inperror db     bell, 'Invalid -- Reenter', EOS           ; Input error mesg
askagain db     'Create another List? (Y/N) ', EOS        ; Prompt to repeat
repchar  db     'N', EOS                                  ; Intention to rep
exitstr  db     'You are welcome back anytime!', EOS      ; Show exit msg

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
Begin:
       call     NewLine                 ; Create space to prevent OVR
       call     PrintPrompt             ; SubRoutine that asks for user input
       call     CollectUpperBound       ; SubRoutine that collects user input
       call     PrintNumberHeader       ; SubRoutine that prints header text
       call     Sieve                   ; SubRoutine for the algorithm
       call     ClearPrimes             ; Clear primes array between runs	   

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
	mov    di, OFFSET exitstr         ; Prepare exit message
	call   StrWrite                   ; Print exit message to screen

;****************************************************************************
;* Program termination code.                                                *
;****************************************************************************
        mov     ah, 04Ch                ; DOS function: Exit program
        mov     al, exCode              ; Return exit code value
        int     21h                     ; Call DOS. Terminate program

;****************************************************************************
;* PrintPrompt Subroutine displays introductory message                     *
;****************************************************************************
PrintPrompt:
        .DATA
lmtprmpt    db    'Enter stopping value ( 2 - 10000) : ', EOS ; Upperbound
        .CODE
	mov     di, OFFSET lmtprmpt     ; Position di to write init prompt
	call    StrWrite                ; Write prompt to Screen
	ret

;****************************************************************************
;* ReadUpperBound collects the upperbound needed for sieve algorithm.       *
;****************************************************************************
CollectUpperBound:
        .CODE
	mov    di, OFFSET buffer        ; collect user input into buffer
	mov    cx, 6                    ; Set maximum input length
	call   StrRead                  ; Read input string to buffer
        call   AscToBin                 ; Convert string to usuable number
        jc     InputError               ; If a carry, invalid num entered
	cmp    ax, 2                    ; Check lower bound
	jb     InputError               ; If < 2, invalid. Reenter.
	cmp    ax, 10000                ; Check upper bound
	ja     InputError               ; if > 10000, invalid. Reenter.
	mov    uprbound, ax             ; Save number for later use
	ret                             ; Return to main program
		
;****************************************************************************
;* PrintNumberHeader prints out the header for the prime number list.       *
;****************************************************************************
PrintNumberHeader:
        .DATA
primehead   db   'Here are the primes from 2 - ', EOS       ; Heading text
colon       db   ' : ', EOS                                 ; Print after num 
        .CODE
	call   NewLine                  ; Create logical space
	mov    di, OFFSET primehead     ; Prepare to print bulk of header
	call   StrWrite                 ; Print most of header to screen
	
	mov    di, OFFSET buffer        ; Prepare to print entered number
	call   StrWrite                 ; Print the number to screen
		
	mov    di, OFFSET colon         ; Prepare colon to the screen
	call   StrWrite                 ; Print colon to string
	call   NewLine                  ; Create space to prevent OVR
	call   NewLine                  ; Create additional space for logic
	ret                             ; Return to main program

;****************************************************************************
;* Sieve handles the main algorithm and its printing.                       *
;****************************************************************************
Sieve:
        .DATA
primes    db    10001 dup (0)        ; Create binary array to track primes
spaceone  db    ' ', EOS             ; Single space for spacing the primes
printable db    0                    ; Used to receive conversion string
		.CODE 
        mov    si, 2                 ; Use si to inc through primes
oloop:                               ; Outer loop: printing&basenums
        cmp    primes[si], 0         ; Check if zero in given location
        jne    continue              ; If not zero, move on
	mov    ax, si                ; If equal, we need to print the value
	mov    cx, 4                 ; Print with 4 character minimum
	mov    di, OFFSET printable  ; explicitly set di value
        call   BinToAscDec           ; Convert to string for printing
	call   StrWrite              ; Print number to screen
	inc    primes[si]            ; Set primes at this location to 1
        mov    di, OFFSET spaceone   ; Ready for separator space
        call   StrWrite              ; Print said space

	mov    bx, si                ; Go through the multiples of prime
iloop:                               ; Inner loop handles the multiples
	add    bx, si                ; Add to bx, the value in si during loop
	cmp    bx, uprbound          ; Check for bx passing upbound
	ja     continue              ; Once above, increment and go outer
	inc    primes[bx]            ; Mark each multiple with a 1
        jmp    iloop                 ; Otherwise, perform the inner again
	
continue:
        inc    si                    ; increment si for next round
        cmp    si, uprbound          ; Check if upbound is crossed
        jb     oloop                 ; Prompt to go again
	mov    si, 0                 ; If finished, return si to 0
        mov    bx, 0                 ; If finished, clear bx
        ret                          ; Return when oloop pass uprbound
		
;****************************************************************************
;* ClearPrimes clears out the prime array between runs for good data.       *
;****************************************************************************
ClearPrimes:
       mov     si, 0                 ; use si to index the array
       mov     cx, uprbound          ; use upperbound to zero out

zloop:       
       mov     primes[si], 0         ; zero out the current location
       inc     si                    ; point si to next byte
       dec     cx                    ; decrement counter
       jnz     zloop                 ; If count not 0, run loop again       
       ret                           ; return if count is 0

;****************************************************************************
;* END of program marker. Add nothing below this point. It will be ignored! *
;****************************************************************************
        END     Start                   ; End of program / entry point