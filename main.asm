INCLUDE Irvine32.inc

.data

TAB_SIZE = 20
GUITAR_SIZE = 10
TOTAL_CHORDS = 5

Chords BYTE 1, 2, 3, 3, 2, 1
Drawn WORD 0
ChordsSize BYTE SIZEOF Chords

.code

AssemblyHero PROC

	MOV ecx, 0
	MOV ESI, 0 ;We will start with the first Chord at Chords
	
	;CALL DumpRegs
	CALL DrawBase
	CALL CallNext
	;CALL CallNext
	;CALL CallNext

	

	Call QuitGame

	exit	

AssemblyHero ENDP

QuitGame PROC

	MOV DH, 15
	MOV DL, 0

	CALL gotoXY

	RET

QuitGame ENDP

CallNext PROC

	CALL DrawChords_Down

	CALL DrawNext

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

	ret

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

		;MOV ECX, TOTAL_CHORDS
		;INC ECX
		MOV ECX, 6


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

DrawChords_Down PROC



DrawChords_Down ENDP

DrawChord_None PROC

	MOV EDX, TAB_SIZE
	MOV DH, 0

	MOV ECX, TOTAL_CHORDS

	L1:

		ADD	DL, 5
		MOV AL, 45

		CALL WriteXY

	LOOP L1

	RET

DrawChord_None ENDP

DrawChord_Color PROC USES EAX

	MOV EDX, TAB_SIZE
	MOV DH, 0
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

DrawNext PROC

	INC Drawn

	MOV AL, Chords[ESI]

	CMP AL, 0
	JNE G
	CALL DrawChord_None
	RET

	G:
	CALL DrawChord_Color
	RET

	;Call DumpRegs





	;CMP Drawn, GUITAR_SIZE
	
	;JGE Before
	; If we are here then Drawn < GUITAR_SIZE
	; So we will have to edi
		

	;Before:
	; This label is reached if the number of Drawn lines is >= GUITAR_SIZE
	; This means that we will edit only the first house of chords


DrawNext ENDP

END	AssemblyHero