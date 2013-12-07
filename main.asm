INCLUDE Irvine32.inc

.data

TAB_SIZE = 20
TAB_SCORE = 5
TAB_REPORT = 10

REPORT_LINE = 5
GUITAR_SIZE = 10
TOTAL_CHORDS = 5

KEY_ERROR = 58h
KEY_SUCCESS = 0DCh

SCORE_SUCCESS_BASE = 500

SIDEBAR_TOTAL = 3
SIDEBAR_SCORE = 0
SIDEBAR_HITS = 1
SIDEBAR_STREAK = 2

Chords BYTE 1, 2, 1, 2, 1, 1, 1, 2, 2, 2, 1, 2, 1, 1, 2, 2, 0,0,0,0,0,0,0,0,0,0
;Chords BYTE 5, 4, 3, 2, 1, 0 , 1, 2, 3, 4, 5, 4, 3, 2, 1, 0, 2, 0, 0, 0, 0, 0, 0
;Chords BYTE 5, 0, 4, 0, 3, 0, 2, 0, 1, 0, 0, 0, 1, 0, 2, 0, 3, 0
Drawn WORD 0
ChordsSize BYTE SIZEOF Chords
InputPressed BYTE 0
InputChanged BYTE 0
ReportShown BYTE 0
score DWORD	0
hits DWORD 0
streak DWORD 0
STRING_Score db "Score: ", 0
STRING_Hits db "Hits: ", 0
STRING_Streak db "Streak: ", 0
STRING_Miss db "Miss!", 0
STRING_Hit db "HIT!", 0

.code

AssemblyHero PROC

	MOV ESI, 0 ;We will start with the first Chord at Chords
	

	CALL StartGame

	GameLoop:

		MOVZX EAX, ChordsSize
		CMP AX, Drawn
		JE QuitLoop

		CALL CallNext
		CALL GetInput

	JMP GameLoop

	QuitLoop:

	CALL QuitGame

	exit	

AssemblyHero ENDP

StartGame PROC

CALL DrawBase
CALL DrawInput

RET

StartGame ENDP

Paradinha PROC

	CALL DELAY

	RET

Paradinha ENDP


QuitGame PROC

	MOV DH, 15
	MOV DL, 0

	CALL gotoXY

	RET

QuitGame ENDP

CallNext PROC USES ECX EAX

	MOV ECX, 0

	
	CALL DrawNext
	CALL DrawChords_Down
	CALL UpdateSideBar

	MOV EAX, 700
	CALL Paradinha

	CALL DrawInput_Next
	


	CMP InputPressed, 1
	JNE Continue

	MOV InputPressed, 0
	CALL DrawInput

	CMP ReportShown, 1
	JNE Continue

	MOV ReportShown, 0
	CALL ClearReport

	Continue:

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
	
	MOV AL, 219

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

	CALL DrawSideBar

	RET

DrawBase ENDP

DrawSideBar PROC

	MOV EBX, 0
	MOV DH, 0
	ADD DL, TAB_SCORE

	MOV ECX, SIDEBAR_TOTAL

	L1:

	CALL gotoXY
	PUSH EDX

	CMP EBX, SIDEBAR_SCORE
	JNE H
	MOV EDX, OFFSET STRING_Score
	JMP Write
	H:
	CMP EBX, SIDEBAR_HITS
	JNE S
	MOV EDX, OFFSET STRING_Hits
	JMP Write
	S:
	MOV EDX, OFFSET STRING_Streak

	Write:
	CALL WriteString

	POP EDX

	INC DH
	INC EBX

	LOOP L1

	RET

DrawSideBar ENDP

UpdateScore PROC USES EAX EDX

	INC hits
	MOV EAX, SCORE_SUCCESS_BASE
	CMP EAX, 0
	
	JE Update

	MOV EDX, streak
	MUL EDX

	Update:

	ADD score, EAX
	INC streak

	RET

UpdateScore ENDP

ReportXY PROC

	MOV DH, REPORT_LINE
	MOV DL, TAB_REPORT
	CALL gotoXY

	RET

ReportXY ENDP

ClearReport PROC USES ECX EAX

	CALL ReportXY

	MOV ECX, 5

	L1:

		MOV AL, 00
		CALL WriteXY
		INC DL

	LOOP L1 

	RET

ClearReport ENDP

WriteMiss PROC USES EAX EDX

	CALL ReportXY

	MOV AX, RED
	CALL setTextColor

	MOV EDX, OFFSET STRING_Miss
	CALL WriteString

	MOV ReportShown, 1


	RET

WriteMiss ENDP

WriteHit PROC USES EAX EDX

	CALL ReportXY

	MOV AX, GREEN
	CALL setTextColor

	MOV EDX, OFFSET STRING_Hit
	CALL WriteString

	MOV ReportShown, 1

	RET

WriteHit ENDP

UpdateSideBar PROC USES ECX EBX EAX	EDX

	MOV EBX, 0
	MOV DH, 0
	MOV DL, GUITAR_SIZE
	ADD DL, 35
	ADD DL, TAB_SCORE
	ADD DL, 15

	MOV ECX, SIDEBAR_TOTAL

	L1:

	CALL gotoXY
	PUSH EDX

	CMP EBX, SIDEBAR_SCORE
	JNE H
	MOV EAX, score
	JMP Write
	H:
	CMP EBX, SIDEBAR_HITS
	JNE S
	MOV EAX, hits
	JMP Write
	S:
	MOV EAX, streak

	Write:
	CALL WriteDec

	POP EDX

	INC DH
	INC EBX

	LOOP L1

	RET

UpdateSideBar ENDP

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

		MOV AL, 016h
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
	INC ESI

	CMP AL, 0
	JNE G
	CALL DrawChord_None
	RET

	G:
	CALL DrawChord_Color
	RET


DrawNext ENDP

DrawInput PROC

	MOV DH, GUITAR_SIZE
	
	MOV AL, 219

	MOV DL, TAB_SIZE
	MOV BH, TAB_SIZE

	CALL WriteXY
	PUSH EAX

	MOV ECX, TOTAL_CHORDS
	INC ECX


	L2:

		ADD BH, 5
		MOV DL, BH
		MOV AL, 016h

		CALL WriteXY

	LOOP L2

	POP EAX

	MOV DL, BH

	CALL WriteXY
	INC DH

	RET

DrawInput ENDP

DrawInput_Chord PROC USES ESI

	MOV DH, GUITAR_SIZE
	MOV BH, TAB_SIZE

	MOV DL, TAB_SIZE

	PUSH EAX

	CMP AL, 61H
	JE A

	CMP AL, 73H
	JE S

	CMP AL, 64H
	JE D

	CMP AL, 66H
	JE F

	JMP G

	A:
		MOV CX, GREEN
		MOV BL, 1
		ADD DL, 5
	JMP Continue
	S:
		MOV CX, RED
		MOV BL, 2
		ADD DL, 10
	JMP Continue
	D:
		MOV CX, YELLOW
		MOV BL, 3
		ADD DL, 15
	JMP Continue
	F:
		MOV CX, BLUE
		MOV BL, 4
		ADD DL, 20
	JMP Continue
	G:
		MOV CX, LIGHTRED
		MOV BL, 5
		ADD DL, 25
		
	Continue:

	PUSH EAX
	MOVZX EAX, Drawn
	INC EAX
	CMP AX, GUITAR_SIZE
	POP EAX
	JG NoIntactLines

	JMP Error
	NoIntactLines:

	MOVZX ESI, Drawn
	SUB ESI, GUITAR_SIZE

	MOV AL, Chords[ESI]

	CMP AL, BL
	JNE Error

	CALL UpdateScore
	CALL WriteHit
	
	MOV AL, KEY_SUCCESS
	JMP Write
	Error:
	MOV AL, KEY_ERROR
	MOV streak, 0
	CALL ClearStreak
	CALL WriteMiss

	Write:

	PUSH EAX
	MOV EAX, ECX
	CALL setTextColor
	MOV ECX, 0
	POP EAX

	CALL WriteXY

	POP EAX

	MOV AX, 0Fh
	CALL setTextColor

	RET

DrawInput_Chord ENDP

ClearStreak PROC USES ECX EDX EAX

	MOV DH, 2
	MOV DL, GUITAR_SIZE
	ADD DL, 35
	ADD DL, TAB_SCORE
	ADD DL, 15	

	MOV ECX, 4

	L1:


		INC DL
		MOV AL, 00
		CALL WriteXY
		

	LOOP L1
	
	RET

ClearStreak ENDP

DrawInput_Next PROC USES ESI

	MOV EAX, GUITAR_SIZE
	CMP AX, Drawn

	JG Continue

	CMP InputChanged, 1
	JNE DoDraw

	CALL DrawInput

	DoDraw:

	MOV DH, GUITAR_SIZE
	MOV DL, TAB_SIZE
	MOV BH, TAB_SIZE

	MOVZX ESI, Drawn
	SUB ESI, GUITAR_SIZE

	MOV AL, Chords[ESI]

	CMP AL, 0
	JE Continue

	CMP AL, 1
	JE G
	CMP AL, 2
	JE R
	CMP AL, 3
	JE Y
	CMP AL, 4
	JE B
	JMP O
	G:
	MOV AX, GREEN
	ADD DL, 5
	JMP SetColor
	R:
	MOV AX, RED
	ADD DL, 10
	JMP SetColor
	Y:
	MOV AX, YELLOW
	ADD DL, 15
	JMP SetColor
	B:
	MOV AX, BLUE
	ADD DL, 20
	JMP SetColor
	O:
	MOV AX, LIGHTRED
	ADD DL, 25
	JMP SetColor

	SetColor:
	CALL setTextColor

	MOV AL, 016h

	CALL WriteXY

	MOV AX, 0Fh
	CALL setTextColor

	MOV InputChanged, 1

	Continue:

	RET

DrawInput_Next ENDP

GetInput PROC

	;MOV EBX, 0

	CALL ReadKey

	;Pressed A
	CMP AL, 61H
	JE ChordPressed

	;Pressed S
	CMP AL, 73H
	JE ChordPressed

	;Pressed D
	CMP AL, 64H
	JE ChordPressed

	;Pressed F
	CMP AL, 66H
	JE ChordPressed

	;Pressed G
	CMP AL, 67H
	JE ChordPressed

	RET

	ChordPressed:
	MOV InputPressed, 1
	CALL DrawInput_Chord

	RET

GetInput ENDP

END	AssemblyHero