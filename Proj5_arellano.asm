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

ARRAYSIZE = 200
HI = 50
LO = 15

.data
intro       BYTE	"Generating, Sorting, and Counting Random Numbers. Programmed by Osbaldo Arellano.",13,10,13,10,0
description BYTE	"This program generates and displays a list of 200 random numbers in the range of",13,10
			BYTE	"15 and 50 inclusive. Next, the median number of the random array is displayed.",13,10
			BYTE	"The program then uses bubble sort to sort the random array in ascending order.",13,10
			BYTE	"The sorted array is then displayed.",13,10 
			BYTE	"Finally, the program displays the number of instances of each random number.",13,10,13,10,0
randTitle   BYTE	"Unsorted random numbers:",13,10,0

randNum     DWORD	?
randArray   DWORD	ARRAYSIZE DUP(?)  

.code
main PROC
	call	Randomize 

	push	OFFSET intro
	push	OFFSET description
	call	introduction

	push	OFFSET randArray
	call	fillArray

	push	OFFSET randTitle
	push	OFFSET randArray
	call	displayList



	Invoke ExitProcess,0	; exit to operating system
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
	sub     eax, 15                        ; If current number is greater than HI, subtract LO to keep it in range.  
	mov     [edi], eax
	add     edi, 4
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
	pop    ebp
	ret    8
displayList ENDP

; (insert additional procedures here)

END main
