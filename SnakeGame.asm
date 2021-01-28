;****************************************************************************
;												                            *
;				            ___The Flavi Snake Game__				        *		
;												                            *
;	            Trabalho realizado por:	Bruno Medeiros 71337                *
;												                            *
;****************************************************************************
;												  							*
;				            Fases do Jogo:					  			    *
;												  							*
;	1: O jogador entra e pressiona para comecar   							*
;   2: Usa as Arrows UP,DOWN,LEFT e RIGHT para se movimentar   				*
;	3: Cada vez que acerte numa comida outra e gerada		                *				  
;	4:Se acertar na parede ou nele proprio perde e mostra a pontuacao.		*									  
;												  							*
;												  							*
;												  							*                      
;****************************************************************************   


;** PARA FAZER **  
  
;verificar bugs de geracao de comida... 
;pensar em maneiras de enriquecer o jogo (dificuldades do jogo -> ver como posso incluir isso didaticamente)



org 100h
include "emu8086.inc"  
JMP MENU


; ** propriedades da snake **

s_size  equ 3 ; tamanho da snake

snake dw s_size DUP(0) ;declaracao de uma array com dimensao 3 inicializados com valor 0 com localizacao na variavel snake

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
wait_time dw 0 


x_coord equ 49  ;constante que guarda o valor da coordenada x do limite direito da arena
y_coord db 0  ;usada para o guardar o valor da coordenada y do limite baixo da arena que muda consoante a dificuldade

;coordenadas da comida
fruitx db 0
fruity db 0               

score db 0 
  
;MACROS PARA ESCREVER NUMEROS
DEFINE_PRINT_NUM
DEFINE_PRINT_NUM_UNS
               

;MENSAGENS DO JOGO  
 
main 	db  09h,"  _______ _             _____             _         ", 0dh,0ah
        db  09h," |__   __| |           / ____|           | |        ", 0dh,0ah
        db  09h,"    | |  | |__   ___  | (___  _ __   __ _| | _____  ", 0dh,0ah
        db  09h,"    | |  | '_ \ / _ \  \___ \| '_ \ / _` | |/ / _ \ ", 0dh,0ah
        db  09h,"    | |  | | | |  __/  ____) | | | | (_| |   <  __/ ", 0dh,0ah
        db  09h,"   _|_|_ |_| |_|\___| |_____/|_| |_|\__,_|_|\_\___| ", 0dh,0ah
        db  09h,"  / ____|                    | |                    ", 0dh,0ah
        db  09h," | |  __  ____ _ __ ___   ___| |                    ", 0dh,0ah
        db  09h," | | |_ |/ _  | '_ ` _ \ / _ \ |                    ", 0dh,0ah
        db  09h," | |__| | (_| | | | | | |  __/_|                    ", 0dh,0ah
        db  09h,"  \_____|\__,_|_| |_| |_|\___(_)                    ", 0dh,0ah
	    
	    db  "Regras:",09h,"                                  ", 0dh,0ah 
	    
	    db 0ah,0FEh,"Come tudo que estiver no ecra", 0dh,0ah	
	    db 0FEh,"Pressiona UP ARROW para te movimentares para cima", 0dh,0ah
	    db 0FEh,"Pressiona DOWN ARROW para te movimentares para baixo", 0dh,0ah
	    db 0FEh,"Pressiona LEFT ARROW para te movimentares para a esquerda", 0dh,0ah	
	    db 0FEh,"Pressiona RIGHT ARROW para te movimentares para a direita", 0dh,0ah
	    db 0FEh,"Pressiona ESC para saires do jogo!", 0dh,0ah
	     	    
	    db 0ah,0Fh," Selecione uma dificuldade: ", 0dh,0ah
	    db 10h,"Facil (f) ",1ah," Tamanho da Arena: 50x22",0dh,0ah  
	    db 10h,"Medio (m) ",1ah," Tamanho da Arena: 50x17",0dh,0ah
	    db 10h,"Dificl (d) ",1ah," Tamanho da Arena: 50x12",0dh,0ah
	    
	    db "Escolha: $"


modo_facil    db 09h,20h,20h,20h,20h,0AEh,0AEh,20h, "MODO FACIL (50x22)",20h,0AFh,0AFh, 0dh,0ah 
              db 0feh," Pontos: ", 09h,09h,09h,020h,020h,20h,20h,20h,20h, "Boa sorte!",02h,"$"
              
modo_medio    db 09h,20h,20h,20h,20h,0AEh,0AEh,0AEh,20h, "MODO MEDIO (50x17)",20h,0AFh,0AFh,0AFh, 0dh,0ah 
              db 0feh," Pontos: ", 09h,09h,09h,020h,020h,20h,20h,20h,20h, "Boa sorte!",02h,"$"
              
modo_dificil  db 09h,20h,20h,20h,20h,0AEh,0AEh,0AEh,0AEh,20h, "MODO DIFICIL (50x12)",20h,0AFh,0AFh,0AFh,0AFh, 0dh,0ah 
              db 0feh," Pontos: ", 09h,09h,09h,020h,020h,20h,20h,20h,20h, "Boa sorte!",02h,"$"
              
              ;50x 
COL1          db 0dh,0ah,0c9h,0cdh,0cdh,0cdh,0cdh,0cdh,0cdh,0cdh,0cdh,0cdh,0cdh,0cdh,0cdh,0cdh,0cdh,0cdh,0cdh,0cdh,0cdh,0cdh,0cdh,0cdh,0cdh,0cdh,0cdh,0cdh,0cdh,0cdh,0cdh,0cdh,0cdh,0cdh,0cdh,0cdh,0cdh,0cdh,0cdh,0cdh,0cdh,0cdh,0cdh,0cdh,0cdh,0cdh,0cdh,0cdh,0cdh,0cdh,0cdh,0bbh,"$"
COL2          db 0dh,0ah,0bah,09h,09h,09h,09h,09h,09h,20h,0bah,"$"
COL3          db 0dh,0ah,0c8h,0cdh,0cdh,0cdh,0cdh,0cdh,0cdh,0cdh,0cdh,0cdh,0cdh,0cdh,0cdh,0cdh,0cdh,0cdh,0cdh,0cdh,0cdh,0cdh,0cdh,0cdh,0cdh,0cdh,0cdh,0cdh,0cdh,0cdh,0cdh,0cdh,0cdh,0cdh,0cdh,0cdh,0cdh,0cdh,0cdh,0cdh,0cdh,0cdh,0cdh,0cdh,0cdh,0cdh,0cdh,0cdh,0cdh,0cdh,0cdh,0bch,"$"


GAME_OVER     db 0dh,0ah,0ah,0ah,0ah,0ah,0ah,0ah,09h,09h,"  ___   __   _  _  ____     __   _  _  ____  ____ ", 0dh,0ah 
              db 09h,09h,                                " / __) / _\ ( \/ )(  __)   /  \ / )( \(  __)(  _ \", 0dh,0ah
              db 09h,09h,                                "( (_ \/    \/ \/ \ ) _)   (  O )\ \/ / ) _)  )   /", 0dh,0ah
              db 09h,09h,                                " \___/\_/\_/\_)(_/(____)   \__/  \__/ (____)(__\_)", 0dh,0ah    
              
              db 0ah,0ah,09h,09h,09h, "Ups... Parece que perdes-te!", 0dh,0ah 
              db 0ah,09h,09h,09h,20h,20h,20h,20h,20h,04h, "  Pontuacao:   ",20h,20h,0dh,0ah   
              
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




;** MODO FACIL POSSUI UMA ARENA MAIOR 50x22 **

FACIL: 


;INT para escrever no ecra
MOV AH, 9         
LEA DX, modo_facil
INT 21H  

;Escreve a primeira borda 
MOV AH,9
LEA DX,COL1
INT 21H

MOV CX, 20 

TABULEIRO1:

;escreve a segunda coluna
MOV AH,9
LEA DX,COL2
INT 21H

LOOP TABULEIRO1

;Escreve a ultima coluna 
MOV AH,9
LEA DX,COL3
INT 21H

MOV CX, 1; Definimos 1 no contador para saber que e a 1x que vai fazer loop

 
;Guarda na variavel y_coord a coordenada y do limite baixo desta arena

mov y_coord, 22     ;22 pois e o tamanho definido da arena

add y_coord, 2      ;adicionamos 2 pois esse e o offset so a partir do y=2 e que comeca a ser desenhada a arena antes temos y=0 e y=1


JMP GAME  




 
;** MODO MEDIO POSSUI UMA ARENA 50x17 **
    
MEDIO:

MOV AH, 9         
LEA DX, modo_medio
INT 21H 
                                       

MOV AH,9
LEA DX,COL1
INT 21H

MOV CX, 15

TABULEIRO2:
    
MOV AH,9
LEA DX,COL2
INT 21H

LOOP TABULEIRO2


MOV AH,9
LEA DX,COL3
INT 21H   

MOV CX, 1


;Guarda na variavel y_coord a coordenada y do limite baixo desta arena

mov y_coord, 17   

add y_coord, 2      ;adicionamos 2 pois esse e o offset so a partir do y=2 e que comeca a ser desenhada a arena antes temos y=0 e y=1


JMP GAME 





;**  MODO DIFICIL POSSUI UMA ARENA 50x12 **

DIFICIL:

MOV AH, 9         
LEA DX, modo_dificil
INT 21H 

MOV AH,9
LEA DX,COL1
INT 21H

MOV CX, 10

TABULEIRO3: 

MOV AH,9
LEA DX,COL2
INT 21H

LOOP TABULEIRO3

MOV AH,9
LEA DX,COL3
INT 21H


MOV CX, 1


;Guarda na variavel y_coord a coordenada y do limite baixo desta arena

mov y_coord, 12     

add y_coord, 2      ;adicionamos 2 pois esse e o offset so a partir do y=2 e que comeca a ser desenhada a arena antes temos y=0 e y=1


JMP GAME
 
 



;########################################################
;#                                                      #
;# INSTRUCAO RESPONSAVEL POR DEFINIR AS COORDENADAS     #
;# ONDE QUEREMOS QUE A CABECA DA SNAKE NASCA            #
;#         (APENAS E EXECUTADA UMA VEZ)                 #
;#                                                      #
;########################################################
                                                   
COORD:                                             

;COORDENADAS DESEJADAS

MOV DH, 10
MOV DL, 20   

;Definimos as coordenadas da cabeca como sendo o valor do registo DX
MOV snake[0], DX  


;DECREMENTAMOS PARA NAO ACONTECER NOVAMENTE ESTA INSTRUCAO
DEC CX 

call fruitgeneration    ;criacao da comida inicial 
   




GAME:


;SE FOR O PRIMEIRO LOOP OU SEJA NA ATRIBUICAO DAS COORDENADAS DA CABECA
;DA JUMP PARA COORD   
CMP CX, 1
JE COORD


;DX fica com as coordenadas da primeira pos da snake (head)
MOV DX, snake[0]

;Funcao que define a posicao do cursor com base no registo DX
MOV     AH, 02h  
INT     10h


;Funcao que escreve no ecra a cabeca da snake na posicao do cursor.

MOV     AL, 0b1h    ; simbolo usada para a cabeca da snake      
MOV     BL, 0ch     ; determina a cor da cobra neste caso e vermelho claro
MOV     CX, 1       ; numero de vezes que escreve o simbolo

MOV     AH, 09h
INT     10h


;Criacao de uma cauda para a snake

MOV     AX, snake[s_size * 2 - 2]   ;coordenadas da cauda guardadas em ax 

MOV     tail, AX                    ;guarda a cauda


CALL    move_snake  ;chamada da funcao move_snake


;##################################
;                                 #
; *** Esconde a cauda antiga ***  #
;                                 #
;################################## 

MOV     dx, tail

MOV     ah, 02h ;Funcao para definir a posicao do cursor
INT     10h

MOV     al, ' ' ;Escrever '' significa que estamos a esconder a cauda da snake 
MOV     ah, 09h  

MOV     cx, 1   ;numero de vezes que vamos escrever
INT     10h





;Intrucao que verifica se o utilizador pressionou alguma tecla

check_for_key:


;Verificamos se o utilizador carregou em alguma tecla  
MOV     ah, 01h
INT     16h
JZ      no_key ;se zero=1 executa no_key pois o utilizador nao pressionou em nenhuma tecla.
 
 
;Int para receber a tecla pressionada e guarda-la em A
MOV     ah, 00h
INT     16h     


;Se Clicar ESC acaba o jogo 
CMP     al, 1bh     
JE      GameOver   


;Definicao da direcao da snake de acordo com a tecla pressionada que fica guardada em ah
MOV     cur_dir, ah





;Instrucao responsavel por definir um ticker para dar loop no jogo

no_key:  

;Funcao para receber o timer do sistema
MOV     ah, 00h
INT     1ah        

;Comparamos o tempo com o wait_time:
CMP     dx, wait_time
JB      check_for_key;Da jump se o dx estiver abaixo de wait_time(CF=1)

;add     dx, 4
MOV     wait_time, dx  ;variavel wait time fica com o valor do registo dx

MOV CX, 0

JMP     GAME   





; *******   Funcao Movimento   ********

; -> Responsavel por movimentar a snake
; -> Criar uma nova cabeca para a snake


move_snake proc 
  
  
; Identificamos a posicao da cauda da snake e guardamos em di  (4)  
MOV   di, s_size * 2 - 2 
   
MOV   cx, s_size-1; contador definido de acordo com o tamanho da cauda da snake  
  
  
  
;Loop para atualizar as coordenadas da snake
 
move_array: 
      
MOV   ax, snake[di-2];guardamos o valor em ax da proxima posicao       snake[2]-> ultimo pedaco da cauda , snake[0]-> cabeca da snake
                                                                        
                                                                                                                                         
MOV   snake[di], ax; e guardamos na posicao anterior essa posicao  
  
SUB   di, 2  ;subtraimos 2 para calcularmos a proxima posicao 
  
LOOP  move_array


;dependendo da tecla que pressionar vai andar numa determinada direcao

CMP     cur_dir, left
  JE    move_left
CMP     cur_dir, right
  JE    move_right
CMP     cur_dir, up
  JE    move_up
CMP     cur_dir, down
  JE    move_down


;quando nenhuma tecla e pressionada:

JMP     stop_move 


 
 ;          ** ESQUERDA **
 ;Movimenta a snake um pedaco a esqueda
move_left: 
  
  ;Decrementar a cabeca da snake em 1 unidade (x--) 
  
  MOV   ax, snake[0] 
  DEC   al
  MOV   b.snake[0], al  
  
  ;Caso tenho tocado na extremidade esquerda da arena (x=0) perde
  
  CMP   al, 0  
  JE    GameOver
  JNE   stop_move         


 
 ;          ** DIREITA **
 ;Movimenta a snake um pedaco a direita 
move_right:   
  
  ;Incrementa a cabeca da snake em 1 unidade (x++)
  
  MOV   ax, snake[0]
  INC   al
  MOV   b.snake[0], al  
  
  ;Caso tenha tocado na extremidade direita definida como coordenada x=49 perde 
  
  CMP al, x_coord
  JE    GameOver
  JNE   stop_move  

  
  
 ;      ** PARA CIMA **
 ;Movimenta a snake um pedaco acima 
move_up:   
  
  ;Decrementamos pois estamos a subir (y--)
  MOV   ax, snake[1]
  DEC   al
  MOV   b.snake[1], al 
  
  ;Caso tenha tocado na extremidade em cima definida como y=2 perde
  
  CMP   al, 2 
  JE    GameOver
  JNE   stop_move 
 
  
   
 ;      ** PARA BAIXO **
 ;Movimenta a snake um pedaco abaixo 
move_down:  
  
  ;incrementamos pois estamos a descer (y++)
  MOV   ax, snake[1]
  INC   al
  MOV   b.snake[1], al
  
  ;Caso tenha tocado na extremidade em baixa definida na selecao da arena perde
  
  CMP al,y_coord
  JE    GameOver
  JNE   stop_move


stop_move:    
  
  ;Enquanto a snake nao morreu vamos comparar as coordenadas
  ;da cabeca da snake com as coordenadas da comida que foi gerada!
  
  MOV   ax, snake[0] 
  
  ;Se a cabeca da snake tiver na mesma coordenada y que da comida da jump
  
  CMP ah, fruity
  JE CheckFood
  
RET
    
move_snake endp




;-------------------------------------------------
;                                                 |
;   **** Funcao que gera comida na arena ****     | 
;_________________________________________________|

fruitgeneration proc 


; ** Numero Randomico para ser a coordenada x da fruta

;get system time 
MOV AH, 02CH
INT 21H


;dividir o valor obtido de DH por 3 uma vez que gera numeros entre 0 a 99
MOV AX, DX
MOV BX,3

XOR DX, DX; DX=0

DIV BX ; 0-99/ 3 onde o resto fica em AH (numero maximo que pode ser gerado 99/3 = 33 

MOV BL, x_coord   ;46
SUB BL, AH        ;46-resto=x da comid
DEC BL


;Atribuimos esse valor como sendo coordenada x da comida
MOV fruitx, BL
                 
                 
                 
                 
;** Numero Randomico para ser a coordenada y da fruta  

;o y estara entre 4 e 23 logo so podemos gerar esses numeros

;get system time 
MOV AH, 02CH
INT 21H


;dividir o valor obtido de DH por 3 uma vez que gera numeros entre 0 a 99
MOV AX, DX

MOV BX,5

XOR DX, DX; DX=0

DIV BX ; 0-99/ 10 onde o resto fica em AH  

                                                                   
MOV BL, y_coord
SUB BL, AH       ;46-resto=x da comida
DEC BL

MOV fruity, BL 


;Definicao das coordenadas no registo
MOV DL, fruitx
MOV DH, fruity
                
                
                                  
;Funcao que define a posicao do cursor com base no registo DX
MOV     AH, 02h  
INT     10h

MOV     AL, 0feh    ; simbolo usada para representar a comida      
MOV     BL, 0ah     ; cor verde claro
MOV     CX, 1       ; numero de vezes que escreve o simbolo

MOV     AH, 09h
INT     10h


DEC CX

ret
fruitgeneration endp





;Intrucao complementar para verificar se a cabeca da snake
;se encontra na mesma pos x que a comida

CheckFood:

CMP al, fruitx
JE AtributeFood
RET





;Intrucao que e executada quando a cabeca da snake esta na mesma
;pos que a comida, ou seja, a snake comeu

AtributeFood:  

;beep sound
MOV ah,02
MOV dl,07h
INT 21h   


;incrementa o score
inc score

MOV DL, 9
MOV DH, 1

;Funcao que define a posicao do cursor com base no registo DX
MOV     AH, 02h  
INT     10h


;Funcao que escreve no ecra score
MOV ah, score 
CALL print_num


;geramos outra comida na arena
CALL fruitgeneration   

RET



;proc timer
          
;GET SYSTEM TIME.
  ;mov  ah, 2ch
  ;int  21h ;RETURN SECONDS IN DH.  
  
  
;CHECK IF ONE SECOND HAS PASSED. 
  ;cmp  dh, seconds
  ;je   no_change  
  
  
;IF NO JUMP, ONE SECOND HAS PASSED. VERY IMPORTANT : PRESERVE SECONDS TO
;USE THEM TO COMPARE WITH NEXT SECONDS. THIS IS HOW WE KNOW ONE SECOND
;HAS PASSED.
 
  ;mov  seconds, dh  
  
  
;DISPLAY TEXT EVERY SECOND.
;MOV DL, 32
;MOV DH, 1

;Funcao que define a posicao do cursor com base no registo DX
;MOV     AH, 02h  
;INT     10h


;Funcao que escreve no ecra score
;mov ah, seconds 

;call print_num   
  
;no_change:    
;ret           
;timer endp    




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

;coordenadas para apresentar o score
MOV DL, 43
MOV DH, 15

;Funcao que define a posicao do cursor com base no registo DX
MOV     AH, 02h  
INT     10h

;Funcao que escreve no ecra o score
MOV ah, score 
CALL print_num


END         