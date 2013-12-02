INCLUDE Irvine32.inc

IntParaString PROTO,buffer_B:PTR BYTE
;lalala
.data
CIMA = 1
DIREITA = 2
BAIXO = 3
ESQUERDA = 4
YMAXIMO = 22
XMAXIMO = 79
COMIDA = 254
VAZIO = 255
PONTO = 219
tempoMaxComida = 50
cobraPontosX BYTE 20, 21, 22, 1700 dup (?)
cobraPontosY BYTE 5, 5, 5, 1700 dup (?)
contPontosCobra WORD 3
cobraIndiceUltimo WORD 0
comidaX BYTE ?
comidaY BYTE ?
bufferPontuacoes BYTE 4096 DUP(0)
pontuacao BYTE 12 DUP(0),0
melhoresPontuacoes DWORD 0,0,0,0,0
nomePontuacao1 BYTE 20 DUP(0)
nomePontuacao2 BYTE 20 DUP(0)
nomePontuacao3 BYTE 20 DUP(0)
nomePontuacao4 BYTE 20 DUP(0)
nomePontuacao5 BYTE 20 DUP(0)
pontuacaoAtual DWORD 0
countLinhaPontuacao BYTE 5
arquivoPontuacoes BYTE "melhoresPontuacoes.txt",0
handlePontuacoes DWORD ?
topoPontuacoes2 BYTE "			Pontuacao	Nome",0
snakeInicio BYTE " ***************************** SNAKE GAME ****************************",0
topoPontuacoes BYTE " ######################## MELHORES PONTUACOES ########################",0
fimPontuacoes BYTE " #####################################################################",0
mensagemComecarJogo BYTE "ENTER: Comecar o jogo | ESC: Voltar ao menu",0
mensagemControlesJogo BYTE "P: Pausa o jogo | Setas Direcionais: Controlam a minhoca",0
mensagemErroArquivo BYTE "Erro ao abrir o arquivo de pontuações!",13, 10, 0
mensagemPausa BYTE "PAUSADO",0
mensagemDesPausa BYTE "       ",0
nomeSeVazio BYTE "???",0
mensagemRecorde BYTE "Parabens! Voce fez uma das 5 melhores pontuacoes!. Digite seu nome: ",0
finalTelaMinhoca BYTE "-------------------------------------------------------------------------------",0
mensagemPontuacao BYTE "Pontuacao Atual: ",0
mensagemMelhorPontuacao BYTE "Melhor Pontuacao: ",0
TempoInicial dWord ?
tempoComida DWORD 0
velocidade Dword 60
direcaoAtual DWORD DIREITA
colidiu DWORD 0 


.code


Snake PROC

inicioJogo:	
		mov ax, 0Fh							;Volta a cor original
		call setTextColor
		call  clrscr
		call exibeMelhoresPontuacoes
leTecla:
		mov eax,10
		call Delay
		call ReadKey
		cmp ah, 1Ch ; ENTER
		je comecaJogo
		cmp ah, 01h ;ESC
		jne leTecla
		jmp saiJogo
comecaJogo:
		call clrscr
		call GetMseconds
		mov tempoInicial, eax

		call geraComida
		call mostraCabecalhoPontuacao
	GameLoop:
	
		call GetMseconds
		sub eax, tempoInicial
		cmp eax, velocidade
		jb GameLoop
			call GetMseconds
			mov tempoInicial, eax
			call identificaDirecao
			cmp ebx,-1
			je FimDeJogo
			call verificaColisao
			call autoColisao				;nao altera valor de colidiu anterior
			cmp colidiu, 1
				je FimDeJogo
			call come
			call movimentaEDesenha
			
		
	jmp GameLoop

	FimDeJogo:
		;REINICIA PARÂMETROS PARA RECOMEÇAR O JOGO
		mov colidiu,0
		mov direcaoAtual,DIREITA
		mov cobraIndiceUltimo, 0
		Mov cobraPontosX, 20
		mov cobraPontosX[1], 21
		mov cobraPontosX[2], 22
		mov cobraPontosY, 5
		mov cobraPontosY[1], 5
		mov cobraPontosY[2], 5
		mov contPontosCobra, 3
		call atualizaMelhoresPontuacoes
		call escreveArquivoPontuacao
		mov pontuacaoAtual,0
		jmp inicioJogo
SaiJogo:		
ret
Snake ENDP

movimentaEdesenha PROC
	pushad
	inc tempoComida
	;ESCREVE UM CARACTER EM BRANCO NO LUGAR DO ULTIMO PONTO DA COBRA
	movsx ebp, cobraIndiceUltimo
	mov dh, cobraPontosY[ebp]			;Parâmetros para gotXY
	mov dl, cobraPontosX[ebp]			;Parâmetros para gotXY
	mov al, VAZIO							;Caracter em branco
	call gotoXY
	call WriteChar

	mov esi, ebp			;guarda posição do ultimo ponto da cobra em esi

	;ATUALIZA ebp PARA APONTAR PARA O PRIMEIRO PONTO DA COBRA
	dec ebp
	cmp ebp, -1					
	jne NaoAtualizaIndice
		movzx ebp, contPontosCobra
		dec ebp
	NaoAtualizaIndice:

	cmp direcaoAtual, CIMA
		je direcaoCima
	cmp direcaoAtual, DIREITA
		je direcaoDireita
	cmp direcaoAtual, BAIXO
		je direcaoBaixo
	cmp direcaoAtual, ESQUERDA
		je direcaoESQUERDA
	jmp Retorna
	
	;PEGA O ULTIMO PONTO E COLOCA NA FRENTE DO PRIMEIRO
	DirecaoCima:
		mov al, cobraPontosY[ebp]
		dec al
		mov cobraPontosY[esi], al
		mov al, cobraPontosX[ebp]
		mov cobraPontosX[esi], al
		jmp Retorna
	DirecaoBaixo:
		mov al, cobraPontosY[ebp]
		inc al
		mov cobraPontosY[esi], al
		mov al, cobraPontosX[ebp]
		mov cobraPontosX[esi], al
		jmp Retorna
	DirecaoEsquerda:				
		mov al, cobraPontosX[ebp]
		dec al
		mov cobraPontosX[esi], al
		mov al, cobraPontosY[ebp]
		mov cobraPontosY[esi], al
		jmp Retorna
	DirecaoDireita:
		mov al, cobraPontosX[ebp]
		inc al
		mov cobraPontosX[esi], al
		mov al, cobraPontosY[ebp]
		mov cobraPontosY[esi], al
		jmp Retorna
	
	Retorna:
	;ESCREVE NOVO PRIMEIRO PONTO DA COBRA NA TELA
	mov dh, cobraPontosY[esi]			;Parâmetros para gotXY
	mov dl, cobraPontosX[esi]			;Parâmetros para gotXY
	mov al, PONTO 						;Caracter ponto
	call gotoXY
	call WriteChar

	;ATUALIZA O PONTEIRO PARA O ÚLTIMO PONTO DA COBRA
	inc esi
	mov eax, esi
	cmp ax, contPontosCobra
	jne NaoATualizaUltimo
		mov ax, 0
	NaoAtualizaUltimo:
	mov cobraIndiceUltimo, ax

	popad
	ret
movimentaEdesenha ENDP

identificaDirecao PROC
	mov ebx,0
	call ReadKey

	;Verifica quais teclas foram apertadas, pelo codigo em ax(retornado por ReadKey!)
	cmp ah, 48h		
		je SetaCima
	cmp ah, 75				
		je SetaEsquerda
	cmp ah, 4Dh
		je SetaDireita
	cmp ah, 50h
		je SetaBaixo
	cmp ah, 19h
		je TeclaP
	cmp ah, 01h;esc
		je TeclaESC
	ret
	
	SetaCima:
		cmp direcaoAtual, BAIXO
		je Nao_muda_direcao
		mov direcaoAtual, CIMA
		ret
	SetaEsquerda:
		cmp direcaoAtual, DIREITA
		je Nao_muda_direcao
		mov direcaoAtual, ESQUERDA
		ret
	SetaDireita:
		cmp direcaoAtual, ESQUERDA
		je Nao_muda_direcao
		mov direcaoAtual, DIREITA
		ret
	SetaBaixo:
		cmp direcaoAtual, CIMA
		je Nao_muda_direcao
		mov direcaoAtual, BAIXO
		ret
	TeclaP:
		mov dh, 24			;Parâmetros para gotXY
		mov dl, 30			;Parâmetros para gotXY
		call GotoXY
		mov edx, OFFSET mensagemPausa
		call WriteString
	TeclaPLoop:
		mov eax,10
		call Delay
		call ReadKey
		cmp ah, 19h
		jne TeclaP
		mov dh, 24			;Parâmetros para gotXY
		mov dl, 30			;Parâmetros para gotXY
		call GotoXY
		mov edx, OFFSET mensagemDesPausa
		call WriteString
		ret
	TeclaESC:
		mov ebx,-1;verifica se é pra sair

Nao_muda_direcao:
ret
identificaDirecao ENDP


verificaColisao PROC
	pushad
	movzx ebp, cobraIndiceUltimo

	;ATUALIZA ebp PARA APONTAR PARA O PRIMEIRO PONTO DA COBRA
	dec ebp
	cmp ebp, -1					
	jne NaoAtualizaIndice
		movsx ebp, contPontosCobra
		dec ebp
	NaoAtualizaIndice:

	cmp cobraPontosY[ebp],0d
	je  PossivelColisaoCima
	cmp cobraPontosX[ebp],0d
	je  PossivelColisaoEsquerda
	cmp cobraPontosY[ebp], YMAXIMO
	je  PossivelColisaoBaixo
	cmp cobraPontosX[ebp], XMAXIMO
	je  PossivelColisaoDireita
	jmp NaoColidiu

	PossivelColisaoCima:
			cmp direcaoAtual,CIMA
			jne NaoColidiu
			mov colidiu,1 ; colidiu no limite de cima
			jmp NaoColidiu
	PossivelColisaoEsquerda:
			cmp direcaoAtual,ESQUERDA
			jne NaoColidiu
			mov colidiu,1 ; colidiu no limite da esquerda
			jmp NaoColidiu
	PossivelColisaoBaixo:
			cmp direcaoAtual,BAIXO
			jne NaoColidiu
			mov colidiu,1 ; colidiu no limite de baixo
			jmp NaoColidiu
	PossivelColisaoDireita:
			cmp direcaoAtual,DIREITA
			jne NaoColidiu
			mov colidiu,1 ; colidiu no limite da direita
			jmp NaoColidiu
	NaoColidiu:
	popad
	ret
verificaColisao ENDP

exibeMelhoresPontuacoes PROC
	mov edx,OFFSET snakeInicio
	call WriteString
	mov dh,2
	mov dl,0
	call GotoXY
	mov edx, OFFSET topoPontuacoes
	call WriteString
	call Crlf
	mov edx, OFFSET topoPontuacoes2
	call WriteString
	call Crlf
	mov ebx,0
	mov edx,OFFSET arquivoPontuacoes
	call OpenInputFile
	cmp eax,INVALID_HANDLE_VALUE
	jne abriuArquivo
	call exibeMensagemErroArquivo
	mov ebx,-1
abriuArquivo:
		mov handlePontuacoes,eax
		mov ecx,4096 
		mov edx,OFFSET bufferPontuacoes
		call ReadFromFile
		mov eax,handlePontuacoes
		call CloseFile

		mov ecx, 5
		mov esi, OFFSET bufferPontuacoes
		mov edi, OFFSET pontuacao
		mov ebx, OFFSET melhoresPontuacoes
LoopPontuacoes:
		mov al, [esi]
		cmp al,'/'
		je achouPontuacao
		mov BYTE PTR [edi],al
		inc edi
		inc esi
		jmp LoopPontuacoes
achouPontuacao:
		mov al, 'K'
		mov BYTE PTR [edi], al
		mov edx, OFFSET pontuacao
		push ecx
		mov ecx, SIZEOF pontuacao
		call ParseDecimal32
		pop ecx
		mov [ebx],eax
		add ebx,4
		mov dh, countLinhaPontuacao
		mov dl, 24
		inc countLinhaPontuacao
		call GotoXY
		call WriteDec
		call Crlf
		inc esi
		mov edi, OFFSET pontuacao
		loop LoopPontuacoes

		mov ecx, 5
		mov countLinhaPontuacao,5
		mov eax,6
		sub eax,ecx
		call offsetNomePontuacao
LoopNomePontuacoes:
		mov al, [esi]
		cmp al,'/'
		je achouNomePontuacao
		mov BYTE PTR [edx],al
		inc edx
		inc esi
		jmp LoopNomePontuacoes
achouNomePontuacao:
		mov al, 0
		mov BYTE PTR [edx], al
		add ebx,4
		mov dh, countLinhaPontuacao
		mov dl, 40
		inc countLinhaPontuacao
		call GotoXY
		mov eax,6
		sub eax,ecx
		call offsetNomePontuacao
		call WriteString
		call Crlf
		inc esi
		mov eax,6
		mov ebx,ecx
		sub ebx,1
		sub eax,ebx
		call offsetNomePontuacao
		loop LoopNomePontuacoes
		mov dh,11
		mov dl,16
		call GotoXY
		mov countLinhaPontuacao,5
		mov edx, OFFSET mensagemComecarJogo
		call WriteString
		call Crlf
		mov dh,12
		mov dl,10
		call GotoXY
		mov edx, OFFSET mensagemControlesJogo
		call WriteString
		call Crlf
		mov edx, OFFSET fimPontuacoes
		call WriteString
	ret
exibeMelhoresPontuacoes ENDP

exibeMensagemErroArquivo PROC
	mov edx, OFFSET mensagemErroArquivo
	call WriteString
	call WaitMsg
	ret
exibeMensagemErroArquivo ENDP

offsetNomePontuacao PROC
	cmp eax,1
	jne COMP2
	mov edx, OFFSET nomePontuacao1
	ret
COMP2:
		cmp eax,2
		jne COMP3
		mov edx, OFFSET nomePontuacao2
		ret
COMP3:
		cmp eax,3
		jne COMP4
		mov edx, OFFSET nomePontuacao3
		ret
COMP4:
		cmp eax,4
		jne COMP5
		mov edx, OFFSET nomePontuacao4
		ret
COMP5:
		cmp eax,5
		jne RetornaSemValor
		mov edx, OFFSET nomePontuacao5
		ret
RetornaSemValor:
		mov edx,-1
ret
offsetNomePontuacao ENDP

escreveArquivoPontuacao PROC
	mov edx,OFFSET arquivoPontuacoes
	call CreateOutputFile
	mov ecx,5
	mov esi, OFFSET melhoresPontuacoes
	mov edi, OFFSET bufferPontuacoes
	push eax
LOOP_NUMEROS_PONT:
	push ecx
	mov eax,[esi]
	invoke IntParaString,OFFSET pontuacao
LOOP_NUMEROS_PONT2:
	mov bl,[edx]
	mov BYTE PTR [edi],bl
	inc edx
	inc edi
	loop LOOP_NUMEROS_PONT2
EscreveProximaPontuacao:
	pop ecx
	add esi,4
	mov BYTE PTR [edi],'/'
	inc edi
	loop LOOP_NUMEROS_PONT
	
	mov ebx,0
LOOP_NOMES_PONT:
	inc ebx
	mov eax,ebx
	call offsetNomePontuacao
	invoke Str_length,edx
	mov ecx,eax
	mov esi, edx
LOOP_INTERNO_NOMES_PONT:

	mov dl,[esi]
	mov BYTE PTR [edi],dl
	inc esi
	inc edi
	loop LOOP_INTERNO_NOMES_PONT

	mov BYTE PTR [edi],'/'
	inc edi
	cmp ebx,5
	jb LOOP_NOMES_PONT
	mov BYTE PTR [edi],0
	mov edx,OFFSET bufferPontuacoes
	invoke Str_length,edx
	mov ecx,eax
	pop eax
	push eax
	call WriteToFile
	
	pop eax
	call CloseFile
	ret
escreveArquivoPontuacao ENDP

;-----------------------------------------------------
IntParaString PROC USES edi ebx,
		buffer_B:PTR BYTE
		LOCAL neg_flag:BYTE
; Escreve inteiro em uma string
; em ASCII decimal.
; Receives: EAX = o inteiro e buffer_B um ponteiro a uma string que tem 12 posicoes
; Returns:  EDX = o endereço p/ a string, ECX = o tamanho da string
;-----------------------------------------------------
WI_Bufsize = 12
true  =   1
false =   0


	mov   neg_flag,false    ; assume neg_flag is false
	or    eax,eax             ; is AX positive?
	jns   WIS1              ; yes: jump to B1
	neg   eax                ; no: make it positive
	mov   neg_flag,true     ; set neg_flag to true

WIS1:
	mov   ecx,0              ; digit count = 0
	mov   edi,buffer_B
	add   edi,(WI_Bufsize-1)
	mov   ebx,10             ; will divide by 10

WIS2:
	mov   edx,0              ; set dividend to 0
	div   ebx                ; divide AX by 10
	or    dl,30h            ; convert remainder to ASCII
	dec   edi                ; reverse through the buffer
	mov   [edi],dl           ; store ASCII digit
	inc   ecx                ; increment digit count
	or    eax,eax             ; quotient > 0?
	jnz   WIS2              ; yes: divide again

	; Insert the sign.
	cmp   neg_flag,false    	; was the number positive?
	jz    WIS3              	; yes
	dec   edi	; back up in the buffer
	inc   ecx               	; increment counter
	mov   BYTE PTR [edi],'-' 	; no: insert negative sign

WIS3:	; retorna numero
	mov  edx,edi

	ret
IntParaString ENDP

atualizaMelhoresPontuacoes PROC
	mov edi,OFFSET melhoresPontuacoes
	mov eax,pontuacaoAtual
	add edi,16 ; aponta pro ultimo
	mov edx,1
	mov esi,0
	mov ecx,5
LOOP_ATUALIZA:
	cmp melhoresPontuacoes[esi],eax
	ja PONTUACAO_MENOR
	je PONTUACAO_MENOR
	mov ecx,5
	sub ecx,edx
	jz NOVA_ATUALIZA
LOOP_INTERNO_ATUALIZA:
	mov ebx,[edi-4]
	mov DWORD PTR [edi], ebx
	sub edi,4
	loop LOOP_INTERNO_ATUALIZA
NOVA_ATUALIZA:
	mov DWORD PTR [edi],eax
	jmp FIM_ATUALIZA
PONTUACAO_MENOR:
	inc edx
	add esi,4
	loop LOOP_ATUALIZA
	ret
FIM_ATUALIZA:
	mov ebx,0
	mov ecx,5
	sub ecx,edx
	jz NOVO_NOME
	push edx
LOOP_ATUALIZA_NOMES:
	mov eax,5
	sub eax,ebx
	call offsetNomePontuacao
	mov esi,edx
	sub eax,1
	call offsetNomePontuacao
	invoke Str_copy,edx,esi
	inc ebx
	loop LOOP_ATUALIZA_NOMES
	pop edx
NOVO_NOME:
	mov eax,edx
	mov edx,OFFSET mensagemRecorde
	call clrscr
	call WriteString
	call offsetNomePontuacao
	mov ecx,20
	call ReadString
	cmp BYTE PTR [edx],0
	jne NomeValido
	mov esi,OFFSET nomeSeVazio
	invoke Str_copy,esi,edx
NomeValido:
	ret
atualizaMelhoresPontuacoes ENDP

come PROC
	movzx ebp, cobraIndiceUltimo

	;ATUALIZA ebp PARA APONTAR PARA O PRIMEIRO PONTO DA COBRA
	dec ebp
	cmp ebp, -1					
	jne NaoAtualizaIndice
		movsx ebp, contPontosCobra
		dec ebp
	NaoAtualizaIndice:
	
	mov al, comidaX
	cmp al, cobraPontosX[ebp]
	jne Nao_Come
		mov ah, comidaY
		cmp ah, cobraPontosY[ebp]
		jne Nao_come
			movzx ebp, contPontosCobra
			mov cobraPontosX[ebp], al
			mov cobraPontosY[ebp], ah
			movzx ecx, cobraIndiceUltimo
			Trocar_Posicoes_no_vetor:
				xchg al, cobraPontosX[ebp]
				xchg cobraPontosX[ebp-1], al
				xchg cobraPontosX[ebp], al
				xchg al, cobraPontosY[ebp]
				xchg cobraPontosY[ebp-1], al
				xchg cobraPontosY[ebp], al
				dec ebp
				cmp ebp, ecx
				jne Trocar_posicoes_no_vetor
			inc ebp
			mov eax, ebp
			mov cobraIndiceUltimo, ax
			inc contPontosCobra
			call atualizaPontuacao
			call geraComida
	Nao_Come:

ret
come ENDP

geraComida PROC
	GERA_COMIDA:
		mov eax, XMAXIMO
		call randomize
		call randomRange
		mov comidaX, al
		mov eax, YMAXIMO
		call randomize
		call randomRange
		mov comidaY, al
		;VEFIFICA SE COMIDA ESTA NA COBRA
		mov al, comidaX						;valor a ser procurado
		movzx ecx, contPontosCobra			;nro de itens no vetor
		mov edi, OFFSET cobraPontosX		;ponteiro pro vetor
		repne scasb							;faz a busca
		jnz Comida_ok						;zf = 1 se encontrou
			mov al, comidaY
			movzx ecx, contPontosCobra
			mov edi, OFFSET cobraPontosY
			repne scasb
			jz GERA_COMIDA
Comida_ok:
		mov tempoComida,0
		mov ax, yellow							;Define cor da comida como verde
		call setTextColor
		mov dh, comidaY
		mov dl, comidaX
		mov al, COMIDA
		call gotoXY
		call writeChar
		mov ax, 0Fh							;Volta a cor original
		call setTextColor
ret
geraComida ENDP

atualizaPontuacao PROC USES eax ebx ecx edx
	mov eax,tempoMaxComida
	mov ebx,tempoComida
	movzx ecx,contPontosCobra
	sub ecx,1
	cmp ebx,eax
	ja SemPontoExtra
	je SemPontoExtra
	sub eax,ebx
	mov edx,0
	mov ebx,2
	div ebx
	mul ecx
	add pontuacaoAtual,eax
	jmp EscrevePontuacao
SemPontoExtra:
	mov eax,ecx
	add pontuacaoAtual,eax
EscrevePontuacao:
	call mostraPontuacaoAtual
	ret
atualizaPontuacao ENDP

mostraPontuacaoAtual PROC uses edx eax
	mov dh, 24			;Parâmetros para gotXY
	mov dl, 18			;Parâmetros para gotXY
	call GotoXY
	mov eax,pontuacaoAtual
	call WriteDec
	ret
mostraPontuacaoAtual ENDP

mostraCabecalhoPontuacao PROC
	mov dh, 23			;Parâmetros para gotXY
	mov dl, 0			;Parâmetros para gotXY
	call GotoXY
	mov edx, OFFSET finalTelaMinhoca
	call WriteString
	mov dh, 24			;Parâmetros para gotXY
	mov dl, 0			;Parâmetros para gotXY
	call GotoXY
	mov edx, OFFSET mensagemPontuacao
	call WriteString
	mov dh, 24			;Parâmetros para gotXY
	mov dl, 50			;Parâmetros para gotXY
	call GotoXY
	mov edx, OFFSET mensagemMelhorPontuacao
	call WriteString
	mov dh, 24			;Parâmetros para gotXY
	mov dl, 68			;Parâmetros para gotXY
	call GotoXY
	mov eax, melhoresPontuacoes[0]
	call WriteDec
	ret
mostraCabecalhoPontuacao ENDP

autoColisao PROC
	pushad

	movzx ebp, cobraIndiceUltimo
	;ATUALIZA ebp PARA APONTAR PARA O PRIMEIRO PONTO DA COBRA
	dec ebp
	cmp ebp, -1					
	jne NaoAtualizaIndice
		movsx ebp, contPontosCobra
		dec ebp
	NaoAtualizaIndice:

	mov ax, -1
	xchg al, cobraPontosX[ebp]			;é usado exchange para q o próprio primeiro ponto não seja considerado na busca
	xchg ah, cobraPontosY[ebp]
	movzx ecx, contPontosCobra			;nro de itens no vetor
	mov edi, 0							;ponteiro pro vetor
	Procura_em_x:
		;repne scasb
		cmp al, cobraPontosX[edi]
		je Procura_em_y
		inc edi
		loop Procura_em_x
		jmp Sem_autocolisao
			Procura_em_y:
			cmp ah, cobraPontosY[edi]
			je Autocolidiu
			inc edi
			loop procura_em_x
			jmp Sem_autocolisao
			Autocolidiu:
				mov colidiu, 1
		
	Sem_Autocolisao:
	xchg al, cobraPontosX[ebp]
	xchg ah, cobraPontosY[ebp]

popad
ret
autoColisao ENDP

END	Snake

;lalalal
;maismais