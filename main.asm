INCLUDE Irvine32.inc

.data

TAB_SIZE = 20
GUITAR_SIZE = 10
TOTAL_CHORDS = 5

Chords BYTE 5, 4, 3, 2, 1, 0 , 1, 2, 3, 4, 5, 4, 3, 2, 1, 0, 2
Drawn WORD 0
ChordsSize BYTE SIZEOF Chords

.code

AssemblyHero PROC

	MOV ESI, 0 ;We will start with the first Chord at Chords
	
	CALL DrawBase

	MOVZX ECX, ChordsSize

	L1:

	PUSH ECX
	MOV ECX, 0

	CALL CallNext

	POP ECX

	LOOP L1
	

	Call QuitGame

	exit	

AssemblyHero ENDP

Paradinha PROC

	CALL DELAY

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

	MOV EAX, 500
	CALL Paradinha

	RET

CallNext ENDP

WriteXY PROC USES EDX EAX

	CALL gotoXY
	CALL WriteChar

	RET

WriteXY ENDP

; Creates Base Guitar with no chords
; Model: ? - - - - - ?
DrawBase PROC

	MOV ECX, GUITAR_SIZE
	MOV DH, 0
	
	MOV AL, 124

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
			MOV AL, 00

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
		MOVZX ECX, Drawn		
		DEC ECX
		MOV EDX, ECX
		CMP ECX, 0
		JZ GTFO
		MOV ESI, 0
		JMP Go
	NoIntactLines:
		MOV ECX, GUITAR_SIZE
		DEC ECX
		MOV EDX, ECX
		MOVZX ESI, Drawn
		SUB ESI, GUITAR_SIZE

	Go:

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
		MOV AL, 00

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
		MOV AL, 00
		JNE Empty

		CMP BL, 1
		JE G
		CMP BL, 2
		JE R
		CMP BL, 3
		JE Y
		CMP BL, 4
		JE B
		JMP O
		G:
		MOV AX, GREEN
		JMP SetColor
		R:
		MOV AX, RED
		JMP SetColor
		Y:
		MOV AX, YELLOW
		JMP SetColor
		B:
		MOV AX, BLUE
		JMP SetColor
		O:
		MOV AX, LIGHTRED
		JMP SetColor

		SetColor:
		CALL setTextColor

		MOV AL, 48
	Empty: 

		ADD	DL, 5

		CALL WriteXY

		MOV AX, 0Fh
		CALL setTextColor

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