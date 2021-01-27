;****************************************************************************
;												                            *
;				            ___The Flavi Snake Game__				                *		
;												                            *
;	            Trabalho realizado por:	Bruno Medeiros 71337                *
;												                            *
;****************************************************************************
;												  							*
;				            Fases do Jogo:					  			    *
;												  							*
;	1: O jogador entra e pressiona para comecar   							*
;   2: Usa as Arrows UP,DOWN,LEFT e RIGHT para se movimentar   				*
;	3: Cada vez que acerte numa comida a cobra aumenta o seu tamanho.		*				  
;	4:Se acertar na parede ou nele proprio perde e mostra a pontuacao.		*									  
;												  							*
;												  							*
;												  							*                      
;****************************************************************************   

org 100h
       

;## PARA FAZER ##    

;Implementar Comida na arena   
;Timer para comida!!!!


JMP MENU

;propriedades da snake

s_size  equ 3 ; constante, tamanho da snake

snake dw s_size DUP(0) ;declaracao de uma array com dimensao s_size inicializados com valor 0 com localizacao na variavel snake

tail    dw      ? ;criacao de uma variavel nao inicializada

; Constantes das direcoes da snake.. 
; Cada hexa representa uma arrow do teclado

left    equ     4bh
right   equ     4dh
up      equ     48h
down    equ     50h
  
  
;a direcao pre-definida para a snake se movimentar no inicio
cur_dir db      right  


;variavel auxiliar para o ticker
wait_time dw    0 

x_coord equ 49  ;constante que guarda o valor da coordenada x do limite direito da arena

y_coord db 0  ;usada para o guardar o valor da coordenada y do limite baixo da arena que muda consoante a dificuldade
               
               
;MENSAGENS DO JOGO   

main 	db  09h,"  _______ _             _____             _         ", 0dh,0ah
        db  09h," |__   __| |           / ____|           | |        ", 0dh,0ah
        db  09h,"    | |  | |__   ___  | (___  _ __   __ _| | _____  ", 0dh,0ah
        db  09h,"    | |  | '_ \ / _ \  \___ \| '_ \ / _` | |/ / _ \ ", 0dh,0ah
        db  09h,"    | |  | | | |  __/  ____) | | | | (_| |   <  __/ ", 0dh,0ah
        db  09h,"   _|_|_ |_| |_|\___| |_____/|_| |_|\__,_|_|\_\___| ", 0dh,0ah
        db  09h,"  / ____|                    | |                    ", 0dh,0ah
        db  09h," | |  __  __ _ _ __ ___   ___| |                    ", 0dh,0ah
        db  09h," | | |_ |/ _` | '_ ` _ \ / _ \ |                    ", 0dh,0ah
        db  09h," | |__| | (_| | | | | | |  __/_|                    ", 0dh,0ah
        db  09h,"  \_____|\__,_|_| |_| |_|\___(_)                    ", 0dh,0ah ;codigo para movimentar o cursor para o inicio da proxima linha
	    db  "Regras:",09h,"                                  ", 0dh,0ah 
	    
	    db 0ah,0FEh, "Come tudo que estiver no ecra", 0dh,0ah	
	    db 0FEh,"Pressiona UP ARROW para te movimentares para cima", 0dh,0ah
	    db 0FEh,"Pressiona DOWN ARROW para te movimentares para baixo", 0dh,0ah
	    db 0FEh,"Pressiona LEFT ARROW para te movimentares para a esquerda", 0dh,0ah	
	    db 0FEh,"Pressiona RIGHT ARROW para te movimentares para a direita", 0dh,0ah
	    db 0FEh,"Pressiona ESC para saires do jogo", 0dh,0ah
	     	    
	    db 0ah,0Fh," Selecione uma dificuldade: ", 0dh,0ah
	    db 10h,"Facil (f) ",1ah," Tamanho da Arena: 50x22",0dh,0ah  
	    db 10h,"Medio (m) ",1ah," Tamanho da Arena: 50x17",0dh,0ah
	    db 10h,"Dificl (d) ",1ah," Tamanho da Arena: 50x12",0dh,0ah
	    
	    db "Escolha: $"


modo_facil    db "========== MODO FACIL (50x22) ============", 0dh,0ah 
              db 0feh," Pontos: $"
              
modo_medio    db "========== MODO MEDIO (50x17) ============", 0dh,0ah   
              db 0feh," Pontos: $"
              
modo_dificil  db "========== MODO DIFICIL (50x12) ============", 0dh,0ah   
              db 0feh," Pontos: $"
              
              ;50x
COL1          db 0dh,0ah,0c9h,0cdh,0cdh,0cdh,0cdh,0cdh,0cdh,0cdh,0cdh,0cdh,0cdh,0cdh,0cdh,0cdh,0cdh,0cdh,0cdh,0cdh,0cdh,0cdh,0cdh,0cdh,0cdh,0cdh,0cdh,0cdh,0cdh,0cdh,0cdh,0cdh,0cdh,0cdh,0cdh,0cdh,0cdh,0cdh,0cdh,0cdh,0cdh,0cdh,0cdh,0cdh,0cdh,0cdh,0cdh,0cdh,0cdh,0cdh,0cdh,0bbh,"$"
COL2          db 0dh,0ah,0bah,09h,09h,09h,09h,09h,09h,20h,0bah,"$"
COL3          db 0dh,0ah,0c8h,0cdh,0cdh,0cdh,0cdh,0cdh,0cdh,0cdh,0cdh,0cdh,0cdh,0cdh,0cdh,0cdh,0cdh,0cdh,0cdh,0cdh,0cdh,0cdh,0cdh,0cdh,0cdh,0cdh,0cdh,0cdh,0cdh,0cdh,0cdh,0cdh,0cdh,0cdh,0cdh,0cdh,0cdh,0cdh,0cdh,0cdh,0cdh,0cdh,0cdh,0cdh,0cdh,0cdh,0cdh,0cdh,0cdh,0cdh,0cdh,0bch,"$"


GAME_OVER     db 0dh,0ah,0ah,0ah,0ah,0ah,0ah,0ah,09h,09h,"  ___   __   _  _  ____     __   _  _  ____  ____ ", 0dh,0ah 
              db 09h,09h,                    " / __) / _\ ( \/ )(  __)   /  \ / )( \(  __)(  _ \", 0dh,0ah
              db 09h,09h,                    "( (_ \/    \/ \/ \ ) _)   (  O )\ \/ / ) _)  )   /", 0dh,0ah
              db 09h,09h,                    " \___/\_/\_/\_)(_/(____)   \__/  \__/ (____)(__\_)", 0dh,0ah    
              
              db 0ah,0ah,09h,09h,09h, "Ups... Parece que perdes-te!", 0dh,0ah 
              db 0ah,09h,09h,09h,20h,20h,20h,20h,20h,04h, "  Pontuacao: x  ",04h,0dh,0ah   
              
              db 0ah,0ah,0ah,09h,09h,0AEh,0AEh,0AEh, " Jogo realizado por: Bruno Medeiros ",0AFh,0AFh,0AFh,"$"



  
MENU:

;INT para escrever no ecra
MOV AH, 9         
LEA DX, main
INT 21H   

;Ler a opcao selecionada relativa a dificuldade
MOV AH, 1
INT 21H    

MOV DL, AL ;Guardamos o valor do registo AL no registo DL 

;Para limpar o ecra utilizamos a interrupcao 10h
;Interrupcao que define o video mode para TextMode 80x25 chars e 16 cores
MOV AL, 03H
MOV AH, 0
INT 10H	

JMP ARENA   





ARENA:
 
;Comparar que valor esta guardado no registo DL
;para sabermos que tecla foi pressionada, caso nao tenha
;sido qualquer das pretendidas volta a mostrar o menu novamente
  
CMP DL, 'f'
JE FACIL

CMP Dl, 'm'
JE MEDIO

CMP Dl, 'd'
JE DIFICIL

JNE MENU
RET






FACIL: 
;MODO FACIL POSSUI UMA ARENA MAIOR 50x22


;INT para escrever no ecra
MOV AH, 9         
LEA DX, modo_facil
INT 21H  

;Escreve a primeira borda 
MOV AH,9
LEA DX,COL1
INT 21H

MOV CX, 20 

;variavel para guardar y do tipo: add cx,y e depois add y,offset que sera 2 (texto antes da arena ocupa 2 linhas)

TABULEIRO1:
    MOV AH,9
    LEA DX,COL2
    INT 21H

    LOOP TABULEIRO1

;Escreve a ultima borda 
MOV AH,9
LEA DX,COL3
INT 21H

MOV CX, 1; definimos 1 no contador para saber que e a 1x que vai fazer loop


;Calculo para guardar na variavel y_coord a coordenada y do limite baixo

mov y_coord, 22     ;22 pois e o tamanho definido da arena

add y_coord, 1      ;adicionamos 1 pois esse e o offset so a partir do y=2 e que comeca a ser desenhada a arena


JMP GAME  

 
    
MEDIO:
;MODO MEDIO POSSUI UMA ARENA 50x17

;INT para escrever no ecra
MOV AH, 9         
LEA DX, modo_medio
INT 21H 
                                       

;Escreve a primeira borda 
MOV AH,9
LEA DX,COL1
INT 21H

MOV CX, 15

TABULEIRO2:
    MOV AH,9
    LEA DX,COL2
    INT 21H

    LOOP TABULEIRO2

;Escreve a ultima borda 
MOV AH,9
LEA DX,COL3
INT 21H   

MOV CX, 1; definimos 1 no contador para saber que e a 1x que vai fazer loop


;Calculo para guardar na variavel y_coord a coordenada y do limite baixo

mov y_coord, 17   

add y_coord, 1      ;adicionamos 1 pois esse e o offset so a partir do y=2 e que comeca a ser desenhada a arena



JMP GAME 




DIFICIL:
;MODO DIFICIL POSSUI UMA ARENA 50x12

;INT para escrever no ecra
MOV AH, 9         
LEA DX, modo_dificil
INT 21H 

;Escreve a primeira borda 
MOV AH,9
LEA DX,COL1
INT 21H

MOV CX, 10

TABULEIRO3:
    MOV AH,9
    LEA DX,COL2
    INT 21H

    LOOP TABULEIRO3

;Escreve a ultima borda 
MOV AH,9
LEA DX,COL3
INT 21H


MOV CX, 1; definimos 1 no contador para saber que e a 1x que vai fazer loop


;Calculo para guardar na variavel y_coord a coordenada y do limite baixo

mov y_coord, 12     

add y_coord, 1      ;adicionamos 1 pois esse e o offset so a partir do y=2 e que comeca a ser desenhada a arena


JMP GAME





;INSTRUCAO RESPONSAVEL POR DEFINIR AS COORDENAS 
;ONDE QUEREMOS QUE A CABECA DA SNAKE NASCA 
;APENAS E EXECUTADA UMA VEZ

COORD:

;COORDENADAS DESEJADAS
MOV DH, 10
MOV DL, 20   

;Definimos as coordenadas da cabeca como sendo o valor do registo DX
MOV snake[0], DX

;DECREMENTAMOS PARA NAO ACONTECER NOVAMENTE ESTA INSTRUCAO
DEC CX  
   




GAME:


;SE FOR O PRIMEIRO LOOP OU SEJA NA ATRIBUICAO DAS COORDENADAS DA CABECA
;DA JUMP PARA COORD   
CMP CX, 1
JE COORD


MOV DX, snake[0]; DX fica com as coordenadas da cabeca da snake;

;Funcao que define a posicao do cursor com base no registo DX
MOV     AH, 02h  
INT     10h


;Funcao que escreve no ecra a cabeca da snake na posicao do cursor.

MOV     AL, 0b1h    ;simbolo usada para a cabeca da snake      
MOV     BL, 0ch     ; determina a cor da cobra neste caso e vermelho claro
MOV     CX, 1       ; numero de vezes que escreve o simbolo

MOV     AH, 09h
INT     10h


;Criacao de uma cauda para a snake

MOV     AX, snake[s_size * 2 - 2];coordenadas da cauda guardadas em ax 
MOV     tail, AX;guarda a cauda


call    move_snake  ;chamada a funcao move_snake


;*** Esconde a cauda antiga ***

mov     dx, tail

mov     ah, 02h ;Funcao para definir a posicao do cursor
int     10h

mov     al, ' ' ;Escrever '' significa que estamos a esconder a cauda da snake 
mov     ah, 09h
mov     bl, 0eh ;cor
mov     cx, 1   ;numero de vezes que vamos escrever
int     10h





check_for_key:

;Verificamos se o utilizador carregou em alguma tecla
mov     ah, 01h
int     16h
jz      no_key ;se zero=1 executa no_key pois o utilizador nao pressionou em nenhuma tecla.

;Int para receber a tecla pressionada e guarda-la em A
mov     ah, 00h
int     16h     

;Se Clicar ESC acaba o jogo
cmp     al, 1bh    ; 
je      GameOver  ; 

;Definicao da direcao da snake de acorda com a tecla pressionada
mov     cur_dir, ah





;Instrucao responsavel por definir um ticker para dar loop
;no jogo
no_key:  

;Funcao para receber o time do sistema
;da return de CX:DX = number of clock ticks since midnight.
mov     ah, 00h
int     1ah        


;Comparamos o tempo com o wait_time:

cmp     dx, wait_time
jb      check_for_key;Jump if first operand is Below second operand.if CF=1 then it will jump. 

add     dx, 4
mov     wait_time, dx  ;variavel wait time fica com o valor do registo dx

jmp     GAME   





; ***** Funcao Movimento *****

; Responsavel por movimentar a snake
; Cria uma nova cabeca para a snake


move_snake proc 
  
  
  ; Identificamos a posicao da cauda da snake e guardamos em di  (4)  
  mov   di, s_size * 2 - 2 
  
  
  mov   cx, s_size-1; contador definido de acordo com o tamanho da cauda da snake  

;Loop para movimentar a snake, a cada loop cada pedaco a comecar da cauda
;da snake e atualizado 
move_array: 
      
  mov   ax, snake[di-2];guardamos o valor em ax da proxima posicao      snake[2]-> ultimo pedaco da cauda , snake[0]-> cabeca da snake
                                                                        ;snake[4] e snake[2] correspondem aos 2 pedacos da cauda da snake
                                                                 
                                                                        ;snake[6] snake[4] snake[2] snake[0]
  mov   snake[di], ax; e guardamos na posicao anterior essa posicao  
  
  sub   di, 2  ;subtraimos 2 para calcularmos a proxima posicao 
  
  loop  move_array


;dependendo da tecla que pressionar vai andar numa
;determinada direcao
cmp     cur_dir, left
  je    move_left
cmp     cur_dir, right
  je    move_right
cmp     cur_dir, up
  je    move_up
cmp     cur_dir, down
  je    move_down

jmp     stop_move       ; quando nenhuma tecla e pressionada

 
 ;ESQUERDA
 ;Movimenta a snake um pedaco a esqueda
move_left: 
  
  ;Decrementar a cabeca da snake em 1 unidade (x--)
  ;Caso tenho tocado na extremidade esquerda da arena perde 
  
  mov   al, b.snake[0] ;converte para 8bits o b.snake[0] caso contrario daria erro
  dec   al
  mov   b.snake[0], al  
  
  
  cmp   al, 0
  jne   stop_move         
  je GameOver
 
 ;DIREITA
 ;Movimenta a snake um pedaco a direita 
move_right:   
  
  ;Incrementa a cabeca da snake em 1 unidade (x++)
  ;Caso tenha tocado na extremidade esquerdade definida como coordenada x=49 perde
  mov   al, b.snake[0]
  inc   al
  mov   b.snake[0], al  
  
  cmp al, x_coord
  jne   stop_move
  je GameOver  
  
  
 ;PARA CIMA
 ;Movimenta a snake um pedaco acima 
move_up:   

  mov   al, b.snake[1]
  dec   al
  mov   b.snake[1], al 
  
  cmp   al, 2 
  jne   stop_move 
  je GameOver 
  
   
 ;PARA BAIXO
 ;Movimenta a snake um pedaco abaixo 
move_down:  

  mov   al, b.snake[1]
  inc   al
  mov   b.snake[1], al
  
  cmp al,y_coord
  jne stop_move
  je GameOver


;Instrucao que nos permite voltar acima.
stop_move:
  ret        
    
move_snake endp;fim da funcao
   




;Intrucao que apresenta a mensagem de GameOver
;Ocorre quando o jogador perder ou clicar ESC
GameOver:

;CLEAR SCREEN
MOV AL, 03H
MOV AH, 0
INT 10H	

MOV AH,9
LEA DX,GAME_OVER
INT 21H   


END         