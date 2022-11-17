TITLE Arrays, Addressing, and Stack-Passed Parameters     (Proj5_arellano.asm)

; Author: Osbaldo Arellano
; Last Modified: 11/14/2022
; OSU email address: arellano@oregonstate.edu
; Course number/section:   CS271 Section 400
; Project Number:        5         Due Date: 11/20/22
; Description: Generates and displays an array of random numbers in the range of 
;				[15, 50] inclusive. Next, the median number of the random array is displayed.
;				The program then uses bubble sort to sort the random array in ascending order. 
;				The sorted array is then displayed. 
;				Finally, the program displays the number of instances of each random number. 

INCLUDE Irvine32.inc

ARRAYSIZE = 200
HI = 30
LO = 5

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

_outOfRange: 
	inc     ecx
	loop	_fillLoop

_done:
	pop     ebp
	ret     4
fillArray ENDP

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

sortList PROC
	push    ebp
	mov     ebp, esp
	mov     esi, [ebp + 8]                ; Points to unsorted array 

	mov     eax, 0                        ; Keep track of current index
	mov     ecx, ARRAYSIZE - 1 	
	mov     edx, 0                        ; Incremented by 1 each time
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

exchangeElements PROC
	push	ebp
	mov     ebp, esp
	mov     esi, [ebp + 8]                   ; Points to first element incurrent loop iteration
	mov     edi, [ebp + 12]                  ; Points to current min element

	mov     edx, [edi]
	mov     eax, [esi]
	mov     [esi], edx
	mov     [edi], eax

	pop     ebp
	ret     8
exchangeElements ENDP

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

farewell PROC
	push	ebp
	mov     ebp, esp
	mov     edx, [ebp + 8]                ; Points to goodbye message
	call	WriteString

	pop     ebp
	ret     4
farewell ENDP

END main
