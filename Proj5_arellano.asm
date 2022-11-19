TITLE Arrays, Addressing, and Stack-Passed Parameters     (Proj5_arellano.asm)

; Author: Osbaldo Arellano
; Last Modified: 11/18/2022
; OSU email address: arellano@oregonstate.edu
; Course number/section:   CS271 Section 400
; Project Number:        5         Due Date: 11/20/22
; Description: Generates and displays an array of random numbers in the range of 
;				[15, 50] inclusive. Next, the median number of the random array is displayed.
;				The program then uses bubble sort to sort the random array in ascending order. 
;				The sorted array is then displayed. 
;				Finally, the program displays the number of instances of each random number
;               in the range of [LO...HI].

INCLUDE Irvine32.inc

ARRAYSIZE = 200
HI = 50
LO = 15

.data
intro       BYTE	"Generating, Sorting, and Counting Random Numbers. Programmed by Osbaldo Arellano.",13,10,13,10,0
description BYTE	"This program generates and displays a list of 200 random numbers in the range of",13,10
			BYTE	"15 and 50 inclusive. Next, the median number of the random array is displayed.",13,10
			BYTE	"The program then uses bubble sort to sort the random array in ascending order.",13,10
			BYTE	"The sorted array is then displayed.",13,10 
			BYTE	"Finally, the program displays the number of instances of each random number in the range.",13,10,13,10,0
randTitle   BYTE	"Unsorted random numbers:",13,10,0
sortedTitle BYTE    "Sorted random numbers: ",13,10,0
medianMssg  BYTE	13,10,13,10,"The median value of the array: ",0
countMssg   BYTE	13,10,13,10,"List of instances of each generated number, starting with the smallest value:",13,10,0
goodbye     BYTE	13,10,13,10,"Goodbye, have a great day!",13,10,0

randArray   DWORD	ARRAYSIZE DUP(?)
countArray  DWORD	(HI - LO + 1) DUP(?)       

.code
main PROC
	call	Randomize                      ; Generate random seed

	push	OFFSET intro
	push	OFFSET description
	call	introduction

	push	OFFSET randArray
	call	fillArray

	push    LENGTHOF randArray
	push	OFFSET randTitle
	push	OFFSET randArray
	call	displayList

	push    OFFSET randArray
	call    sortList

	push	OFFSET randArray
	push	OFFSET medianMssg
	call	displayMedian
	
	push    LENGTHOF randArray
	push	OFFSET sortedTitle
	push	OFFSET randArray
	call    displayList

	push   OFFSET countArray
	push   OFFSET randArray
	call   countList

	push    LENGTHOF countArray
	push	OFFSET countMssg
	push	OFFSET countArray
	call    displayList

	push	OFFSET goodbye
	call	farewell

	Invoke ExitProcess,0	
main ENDP	

; ---------------------------------------------------------------------------------
; Name: introduction 
;
; Introduces the title of the program, the authors name, and displays 
; a description of the program. 
;
; Receives: Reference to someIntroMessage. 
;           Reference to someDescriptionMessage. 
;
; Returns: None
; ---------------------------------------------------------------------------------
introduction PROC
	push	ebp
	mov     ebp, esp
	mov     edx, [ebp + 12]                ; Points to intoduction message
	call	WriteString
	mov     edx, [ebp + 8]                 ; Points to description message
	call	WriteString

	pop     ebp
	ret     8
introduction ENDP

; ---------------------------------------------------------------------------------
; Name: fillArray
;
; Calls the Irvine RandomNumber procedure to get a random number in the range
; of [LO...HI]. Fills array (defined as randArray) with generated random numbers. 
; Stops when number of elements in the array is of size ARRAYSIZE (constant). 
; 
;
; Preconditions: A DWORD array of length ARRAYSIZE whose elements are uninitialized. 
;
;
; Postconditions: ECX is used as the loop counter. EDI is used to point to the next 
;                 element in the array. 
;
; Receives: Empty array randArray of type DWORD. 
;
; Returns: randArray with random numbers in the range of [LO...HI] of length ARRAYSIZE.
; ---------------------------------------------------------------------------------
fillArray PROC
	push	ebp
	mov     ebp, esp
	mov     ecx, ARRAYSIZE 
	mov     edi, [ebp + 8]

_fillLoop:		
	mov     eax, HI
	call	RandomRange
	add     eax, LO                        ; Ensures current rand number is greater than LO 
	cmp     eax, HI                        
	jg      _outOfRange
	mov     [edi], eax
	add     edi, 4
	loop	_fillLoop
	jmp     _done

; ------------------------
; Is jumped to when a randomly generated
; number is above HI. ECX is incremented 
; since we didn't push a number into the array. 
; ------------------------
_outOfRange: 
	inc     ecx
	loop	_fillLoop

_done:
	pop     ebp
	ret     4
fillArray ENDP

; ---------------------------------------------------------------------------------
; Name: displayList 
;
; Displays each element in an array. 
;
; Preconditions: Array of type DWORD. 
;
; Postconditions: Modifies ESI to point to the current element in the array. 
;                 Modifies EBX to point to the message that displays to the user. 
;                 Modifies ECX as the loop counter; init to ARRAYSIZE. 
;
; Receives: Reference to someArray.
;           Reference to someTitle.
;           Length of someArray. 
;
; Returns: None
; ---------------------------------------------------------------------------------
displayList PROC
	push	ebp
	mov     ebp, esp
	mov     esi, [ebp + 8]                 ; Points to array
	mov     ebx, [ebp + 12]                ; Points to sorted list or unsorted list message
	mov     ecx, [ebp + 16]                ; Points to array size 

	mov     edx, ebx
	call	WriteString

	mov     ebx, 0                         ; EBX to keep track of how many primes are printed (20 per line)
_displayLoop:
	cmp     ebx, 20
	je      _printLine
	inc     ebx
	mov     eax, [esi]
	call	WriteDec
	mov     al, ' '
	call	WriteChar
	add     esi, 4
	loop	_displayLoop
	jmp     _done

_printLine:
	call	CrLf
	mov     ebx, 0                         ; EBX keeps track of primes printed. Reinit to 0. 
	inc     ecx
	loop	_displayLoop

_done:
	pop     ebp
	ret     12
displayList ENDP

; ---------------------------------------------------------------------------------
; Name: sortList
;
; Uses bubble sort to sort random elements in an array. 
;
; Preconditions: Array whose elements are of type DWORD. 
;
; Postconditions: Modifies ESI to point to array. 
;                 Modifies EAX to keep track of current array index and store array elements.
;				  Modifies EDX to keep track of loop count starting at 0. 
;                 Modifies EBX to store array elements for comparisons. 
;
; Receives: Reference to someArray.
;
; Returns: Sorted array in ascending order. 
; ---------------------------------------------------------------------------------
sortList PROC
	push    ebp
	mov     ebp, esp
	mov     esi, [ebp + 8]                ; Points to unsorted array 

	mov     eax, 0                        ; Keep track of current index
	mov     ecx, ARRAYSIZE - 1 	
	mov     edx, 0                        ; Incremented by 1 each time

; --------------------
; Main loop body that iterates ARRAYSIZE times. 
; After pushing ECX to the stack, ECX is setup
; as the new counter for the inner loop. Which
; equals: 
;        (old ECX value) - (EDX loop counter) - 1
; --------------------
_loop:
	push    ecx                           ; Restored at the end of _loop2
	mov     ecx, ARRAYSIZE
	sub     ecx, edx
	dec     ecx                           ; Inner loop range: (ARRAYSIZE - edx - 1)
	cmp     ecx, 0
	je      _done
	_loop2:
		mov     ebx, eax                      ; EAX = (current index + 4), one index above current number since the elements in the list are DWORDS 
		add     ebx, 4                        ; Comparing one index above the current index. 
		push    ebx
		push    eax                           ; Save index since register will be modified 
		mov     eax, [esi + eax]
		mov     ebx, [esi + ebx]
		cmp     eax, ebx	
		jl      _continue 

; -------------------------
; POPs EAX and EBX values, which were 
; initially array indcies. 
;
; Calls the exchangeElements procedure after 
; pushing registers EAX and EBX that point to 
; the two elements in the array to be swapped. 
; -------------------------
_swap:
	pop     eax
	pop     ebx
	push    eax                           ; Save index. Neeed it after the procedure call. 
	add     eax, esi
	add     ebx, esi 
	push    edx                           ; Save counter register
	push    esi                           ; Save pointer to start of array
	push    ebx                           ; Points to current min
	push    eax                           ; Points to current element in loop iteration
	call	exchangeElements   
	pop     esi
	pop     edx
	pop     eax
	add     eax, 4
	loop	_loop2
	pop     ecx
	add     edx, 1
	mov     eax, 0 
	loop	_loop
	jmp     _done

_continue:
	pop     eax
	pop     ebx
	add     eax, 4
	loop    _loop2

	pop     ecx
	add     edx,1
	mov     eax, 0 
	loop	_loop
	jmp     _done

_done:
	pop     ebp    
	ret     4
sortList ENDP

; ---------------------------------------------------------------------------------
; Name: exchangeElements
;
; Swaps elements in an array. 
;
; Preconditions: Reference to array elements of type DWORD. 
;
; Postconditions: Modifies ESI register to point to the new min element. 
;                 Modifies EDI register to point to the current min element. 
;
; Receives: Refrence newMinElement in array
;           Refrence currentMinElement in array
;
; Returns: Array with swapped elements newMin and currentMin
; ---------------------------------------------------------------------------------
exchangeElements PROC
	push	ebp
	mov     ebp, esp
	mov     esi, [ebp + 8]                   ; Points to new min element 
	mov     edi, [ebp + 12]                  ; Points to current min element

	mov     edx, [edi]
	mov     eax, [esi]
	mov     [esi], edx
	mov     [edi], eax

	pop     ebp
	ret     8
exchangeElements ENDP

; ---------------------------------------------------------------------------------
; Name: displayMedian 
;
; Displays the median of the randomly generated number array. 
;
; Preconditions: Sorted array in ascending order. 
;
; Postconditions: Modifies ESI to point to array.
;                 Modifies EDX to point to message displayed to the user. 
;                 Modifies EBX to store 2 and divide ARRAYSIZE to check if ARRAYSIZE is even.
;                 Modifies ECX to store 2 for divison. 
;
; Receives: Reference to sortedArray 
;           Reference to a message that will be displayed to the user. 
;
; Returns: None
; ---------------------------------------------------------------------------------
displayMedian PROC
	push    ebp
	mov     ebp, esp
	mov     esi, [ebp + 12]                ; Points to array
	mov     edx, [ebp + 8]                 ; Points to median message 
	call	WriteString

; --------------------
; If array size is odd, then median will be at index [(ARRAYSIZE-1)/2]
; --------------------
	mov     ebx, 2
	mov     edx, 0
	mov     eax, ARRAYSIZE
	div     ebx
	cmp     edx, 0 
	je      _isEven
	mov     eax, [esi+eax*4]
	call	WriteDec
	jmp     _done

; --------------------
; If array size is even, we need to calculate the median as:
;	[(ARRAYSIZE/2) + ((ARRAYSIZE/2) + 1)] / 2 
; --------------------
_isEven:
	dec     eax
	mov     ebx, [esi+eax*4]               ; index [(ARRAYSIZE/2)]
	inc     eax
	mov     eax, [esi+eax*4]               ; index [(ARRAYSIZE/2) + 1]
	add     eax, ebx 
	mov     edx, 0
	mov     ecx, 2
	div     ecx                            ; Divide (EAX + EBX) by 2 
	cmp     edx, 0
	jne      _round
	call	WriteDec
	jmp     _done

_round:
	inc     eax                    
	call	WriteDec
_done:
	call	CrLf
	call	CrLf
	pop     ebp
	ret     4 
displayMedian ENDP

; ---------------------------------------------------------------------------------
; Name: countList
;
; Fills an array (countArray) with the number of times each value in the range
; [LO...HI] is detected in the randArray. Count will be zero for elements that 
; apprear zero times. 
;
; Preconditions: countArray of type DWORD.
;                randArray whose elements are DWORDs. 
;
; Postconditions: Modifies ESI to point to randArray.
;                 Modifies EDI to point to countArray. 
;                 Modifies ECX to store the loop count. 
;                 Modifies EBX to to store the total count of each value. 
;                 Modifies EAX check values in range of [LO...HI]
;
; Receives: Reference to randArray
;           Reference to countArray
;
; Returns: countArray whose elements, starting at LO and up to HI, equal the number of times each value in the
;          range of [LO...HI] was detected in randArray. 
; ---------------------------------------------------------------------------------
countList PROC
	push   ebp
	mov    ebp, esp
	mov    esi, [ebp + 8]                ; Points to randArray 
	mov    edi, [ebp + 12]               ; Points to countArray

	mov    ecx, ARRAYSIZE
	mov    eax, LO                        ; Starting number count at LO.
	mov    ebx, 0                         ; Running count of each number in range [LO, HI]
_loop:
	cmp     eax, [esi]                    ; ESI is incremented every iteration to point to next element in sortedArray
	jne     _newCount
	inc     ebx
	add     esi, 4
	loop	_loop
	jmp     _done

; ---------------------
; The next element in the array did not 
; equal the current element. Push the count to
; the current index in the countArray and increment to 
; point to the next index in the countArray. Finally, 
; reset the count and loop back to main loop to check next element. 
; ---------------------
_newCount: 
	mov    [edi], ebx 
	inc    eax
	add    edi, 4
	mov    ebx, 0                         ; Reset the running count 
	jmp    _loop

_done:
	mov    [edi], ebx                     ; Push the last count into the countArray
	pop     ebp
	ret     12
countList ENDP

; ---------------------------------------------------------------------------------
; Name: farewell
;
; Displays a goodbye message to the user. 
;
; Receives: Reference to goodbye messgae that will be displayed to the user

; ---------------------------------------------------------------------------------
farewell PROC
	push	ebp
	mov     ebp, esp
	mov     edx, [ebp + 8]                ; Points to goodbye message
	call	WriteString

	pop     ebp
	ret     4
farewell ENDP

END main
