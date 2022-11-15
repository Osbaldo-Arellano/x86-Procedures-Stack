TITLE Program Template     (Proj5_arellano.asm)

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

ARRAYSIZE = 40
HI = 30
LO = 15

.data
intro       BYTE	"Generating, Sorting, and Counting Random Numbers. Programmed by Osbaldo Arellano.",13,10,13,10,0
description BYTE	"This program generates and displays a list of 200 random numbers in the range of",13,10
			BYTE	"15 and 50 inclusive. Next, the median number of the random array is displayed.",13,10
			BYTE	"The program then uses bubble sort to sort the random array in ascending order.",13,10
			BYTE	"The sorted array is then displayed.",13,10 
			BYTE	"Finally, the program displays the number of instances of each random number.",13,10,13,10,0
randTitle   BYTE	"Unsorted random numbers:",13,10,0
medianMssg  BYTE	13,10,13,10,"Median number in the unsorted array: ",0

randArray   DWORD	ARRAYSIZE DUP(?)  

.code
main PROC
	call	Randomize                      ; Generate random seed

	push	OFFSET intro
	push	OFFSET description
	call	introduction

	push	OFFSET randArray
	call	fillArray

	push	OFFSET randTitle
	push	OFFSET randArray
	call	displayList

	push	OFFSET randArray
	push	OFFSET medianMssg
	call	displayMedian
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

	mov     edx, ebx
	call	WriteString

	mov     ebx, 0                         ; EBX to keep track of how many primes are printed (20 per line)
	mov     ecx, ARRAYSIZE
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
	ret     8
displayList ENDP

sortList PROC
	push    ebp
	mov     ebp, esp
	mov     esi, [ebp + 8]


	pop    ebp
	ret    4
sortList ENDP

displayMedian PROC
	push    ebp
	mov     ebp, esp
	mov     esi, [ebp + 12]                ; Points to array
	mov     edx, [ebp + 8]                 ; Points to median message 
	call	WriteString

; --------------------
; If array size is odd, then median will be at index [(ARRAYSIZE/2) + 1]
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
	div     ecx                       	   ; Divide (EAX + EBX) by 2 
	cmp     edx, 0
	jne      _round
	call	WriteDec
	jmp     _done

_round:
	inc     eax
	call	WriteDec
_done:
	pop    ebp
	ret    4 
displayMedian ENDP

END main
