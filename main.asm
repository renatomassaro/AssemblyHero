INCLUDE Irvine32.inc

.data

TAB_SIZE = 20
GUITAR_SIZE = 10
TOTAL_CHORDS = 5

Chords BYTE 5, 4, 3, 2, 1, 0 , 1, 2, 3
Drawn WORD 0
ChordsSize BYTE SIZEOF Chords

.code

AssemblyHero PROC

	MOV ECX, 0
	MOV ESI, 0 ;We will start with the first Chord at Chords
	
	CALL DrawBase
	CALL Paradinha
	CALL CallNext
	CALL Paradinha
	CALL CallNext
	CALL Paradinha
	CALL CallNext
	CALL Paradinha
	CALL CallNext
	CALL Paradinha
	CALL CallNext
	CALL Paradinha
	CALL CallNext
	CALL Paradinha
	CALL CallNext
	CALL Paradinha
	CALL CallNext
	CALL Paradinha
	CALL CallNext

	

	Call QuitGame

	exit	

AssemblyHero ENDP

Paradinha PROC

	PUSH ESI
	PUSH EBP

	mov bp, 13690
	mov si, 13690
	delay2:
	dec bp
	nop
	jnz delay2
	dec si
	cmp si,0    
	jnz delay2

	POP EBP
	POP ESI

Paradinha ENDP


QuitGame PROC

	MOV DH, 15
	MOV DL, 0

	CALL gotoXY

	RET

QuitGame ENDP

CallNext PROC

	

	CALL DrawNext
	CALL DrawChords_Down
	INC ESI

	;Call DumpRegs

	RET

CallNext ENDP

WriteXY PROC USES EDX EAX

	;MOV dh, 0			;Parâmetros para gotXY
	;MOV dl, TAB_SIZE			;Parâmetros para gotXY
	;MOV al, 30							;Caracter em branco
	CALL gotoXY
	CALL WriteChar

	RET

WriteXY ENDP

; Creates Base Guitar with no chords
; Model: ? - - - - - ?
DrawBase PROC

	MOV ECX, GUITAR_SIZE
	MOV DH, 0
	
	MOV AL, 63
	;ADD AH, 20

	L1:

		MOV DL, TAB_SIZE
		MOV BH, TAB_SIZE

		CALL WriteXY

		PUSH ECX
		PUSH EAX

		MOV ECX, TOTAL_CHORDS
		INC ECX


		L2:

			ADD BH, 5
			MOV DL, BH
			MOV AL, 45

			CALL WriteXY

		LOOP L2

		POP EAX
		POP ECX

		MOV DL, BH

		CALL WriteXY
		INC DH

	LOOP L1

	RET

DrawBase ENDP

DrawChords_Down PROC USES EAX EBX EDX ESI

	MOV ECX, GUITAR_SIZE
	MOV ECX, EDX
	MOV EBX, 0
	MOV ESI, 0

	MOV AX, Drawn
	CMP AX, GUITAR_SIZE


	JG NoIntactLines

		;If we are here then Drawn Lines < Guitar_Size. (We have intact lines)
		;By intact lines I mean default lines from DrawBase
		;That means different loop and ID information
		; Loop = Drawn - 1
		; Id = Dr - LINE

		MOV ESI, 0
		MOVZX ECX, Drawn		
		DEC ECX
		MOV EDX, ECX
		CMP ECX, 0
		JZ GTFO

	NoIntactLines:

	
	MOV EAX, ECX
	MOV EDX, 0
	MOV DL, 0

	L0:

		INC DL
		PUSH EDX
		

	LOOP L0

	MOV ECX, EAX
	MOV EAX, DWORD PTR Drawn

	L1:

		MOV AL, Chords[ESI]

		;MOV EDX, EBX

		POP EDX


		;Call WriteDec

		;CALL DumpRegs

		MOV BH, DL

		CMP EAX, 0
		JNE Colored
			CALL DrawChord_None
		JMP Back
		Colored:
			CALL DrawChord_Color
		Back:


		INC ESI
		INC EBX

	LOOP L1

	;call DumpRegs

	GTFO:

	RET


DrawChords_Down ENDP

DrawChord_None PROC	USES EAX EDX

	MOV EDX, TAB_SIZE
	MOV DH, BH

	MOV ECX, TOTAL_CHORDS

	L1:

		ADD	DL, 5
		MOV AL, 45

		CALL WriteXY

	LOOP L1

	RET

DrawChord_None ENDP

DrawChord_Color PROC USES EAX EBX ECX EDX

	;Call DumpRegs
	    
	MOV EDX, TAB_SIZE
	MOV DH, BH
	MOV BL, 0

	MOV ECX, TOTAL_CHORDS

	L1:
		INC BL
		CMP BL, AL
		PUSH EAX
		MOV AL, 45
		JNE Empty

		MOV AL, 48
	Empty: 

		ADD	DL, 5

		CALL WriteXY

		POP EAX

	LOOP L1

	RET

DrawChord_Color ENDP

DrawNext PROC USES EAX EBX

	INC Drawn

	; Level = 0, Drawn on Line 0	
	MOV BH, 0 

	MOV AL, Chords[ESI]

	CMP AL, 0
	JNE G
	CALL DrawChord_None
	RET

	G:
	CALL DrawChord_Color
	RET


DrawNext ENDP

END	AssemblyHero