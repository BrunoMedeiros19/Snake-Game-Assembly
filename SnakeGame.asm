;****************************************************************************
;												                            *
;				      ___The Flavi Snake Game__				                *		
;												                            *
;	            Trabalho realizado por:	Bruno Medeiros 71337                *
;												                            *
;****************************************************************************
;												  							*
;				            Fases do Jogo:					  			    *
;												  							*
;	1: O jogador entra e seleciona uma arena para comecar   				*
;   2: Usa as Arrows UP,DOWN,LEFT e RIGHT para se movimentar   				*
;	3: Cada vez que acerte numa comida outra e gerada		                *				  
;	4: Se acertar na parede ou nele proprio perde e mostra a pontuacao.		*									  
;												  							*
;												  							*
;												  							*                      
;****************************************************************************   

;****************************************************************************
;                                                                           *
;       Coisas que podem ser melhoradas/implementadas no futuro             *
;                                                                           *
;1. Uma vez que a variavel s_size que e o tamanho da cobra foi definida como*  
;   uma constante, a snake nao aumenta de tamanho quando come o que poderia * 
;   ser algo a implementar no futuro.                                       *
;                                                                           *
;2. O sistema de geracao de comida pode ser melhorado no sentido de nao     *
;   existirem bugs associados a este quando mudamos para arenas mais        *
;   pequenas ou quando uma comida e criada na mesma posicao da snake.       *
;   fazendo-a desaparecer                                                   *
;                                                                           *
;3. Caso a snake toca-se nela propria morria, coisa que nao acontece ainda  *
;                                                                           *
;****************************************************************************

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


x_coord equ 49  ;constante que guarda o valor da coordenada x do limite direito da arena
y_coord db 0  ;usada para o guardar o valor da coordenada y do limite baixo da arena que muda consoante a dificuldade

;coordenadas da comida
fruitx db 0
fruity db 0               

score db 0 
  
;MACROS PARA ESCREVER NUMEROS GUARDADOS EM REGISTOS
DEFINE_PRINT_NUM
DEFINE_PRINT_NUM_UNS
               

;MENSAGENS DO JOGO  
 
main    db  09h,09h," |__   __| |           / ____|           | |        ", 0dh,0ah
        db  09h,09h,"    | |  | |__   ___  | (___  _ __   __ _| | _____  ", 0dh,0ah
        db  09h,09h,"    | |  | '_ \ / _ \  \___ \| '_ \ / _` | |/ / _ \ ", 0dh,0ah
        db  09h,09h,"    | |  | | | |  __/  ____) | | | | (_| |   <  __/ ", 0dh,0ah
        db  09h,09h,"   _|_|_ |_| |_|\___| |_____/|_| |_|\__,_|_|\_\___| ", 0dh,0ah
        db  09h,09h,"  / ____|                    | |                    ", 0dh,0ah
        db  09h,09h," | |  __  ____ _ __ ___   ___| |                    ", 0dh,0ah
        db  09h,09h," | | |_ |/ _  | '_ ` _ \ / _ \ |                    ", 0dh,0ah
        db  09h,09h," | |__| | (_| | | | | | |  __/_|                    ", 0dh,0ah
        db  09h,09h,"  \_____|\__,_|_| |_| |_|\___(_)                    ", 0dh,0ah
	    
	    
	    
	    db 0dh,0ah,0ah,"Bem-vindo ao flavi snake v1.0, nota que e possivel que existam alguns bugs associados a geracao de comida mas de qualquer das formas espero que te divirtas!", 0dh,0ah
	    
	    db 0dh,0ah,"Regras:", 0dh,0ah	    	
	    db 0FEh,"Pressiona UP,DOWN,LEFT e RIGHT ARROW para te movimentares", 0dh,0ah
	    db 0FEh,"Pressiona ESC para saires do jogo!", 0dh,0ah 
	    db 0FEh,"Come tudo que estiver no ecra e ganha pontos!!", 0dh,0ah
	     	    
	    db 0dh,0ah ,10h,"Arena1 (1) ",1ah," Tamanho da Arena: 50x22",0dh,0ah  
	    db 10h,"Arena2 (2) ",1ah," Tamanho da Arena: 50x19",0dh,0ah
	    db 10h,"Arena3 (3) ",1ah," Tamanho da Arena: 50x16",0dh,0ah
	    
	    db 0Fh," Escolhe uma arena: ", "$"


modo_facil    db 09h,20h,20h,20h,20h,0AEh,0AEh,20h, "ARENA 1 (50x22)",20h,0AFh,0AFh, 0dh,0ah,"$" 
                      
modo_medio    db 09h,20h,20h,20h,20h,0AEh,0AEh,0AEh,20h, "ARENA 2 (50x19)",20h,0AFh,0AFh,0AFh, 0dh,0ah,"$"               
              
modo_dificil  db 09h,20h,20h,20h,20h,0AEh,0AEh,0AEh,0AEh,20h, "ARENA 3 (50x16)",20h,0AFh,0AFh,0AFh,0AFh, 0dh,0ah,"$" 
              
              
              ;47x simbolos                                                                                                                                                                                                                                                                  ;daqui para a frente tem haver com a tabela de pontos
COL1          db 0dh,0ah,0c9h,0cdh,0cdh,0cdh,0cdh,0cdh,0cdh,0cdh,0cdh,0cdh,0cdh,0cdh,0cdh,0cdh,0cdh,0cdh,0cdh,0cdh,0cdh,0cdh,0cdh,0cdh,0cdh,0cdh,0cdh,0cdh,0cdh,0cdh,0cdh,0cdh,0cdh,0cdh,0cdh,0cdh,0cdh,0cdh,0cdh,0cdh,0cdh,0cdh,0cdh,0cdh,0cdh,0cdh,0cdh,0cdh,0cdh,0cdh,0cdh,0bbh, 09h,0B1H,0B1H,0B1H,0B1H,0B1H,0B1H,0B1H,0B1H,0B1H,0B1H,0B1H,0B1H,0B1H,0B1H,0B1H,0B1H,0B1H,0B1H,0B1H,0B1H,0B1H,0B1H,"$"
COL2          db 0dh,0ah,0bah,09h,09h,09h,09h,09h,09h,20h,0bah,09h,0B1H,09h,09h,20h,20h,20h,20h,20h,0B1H ,"$"
COL3          db 0dh,0ah,0c8h,0cdh,0cdh,0cdh,0cdh,0cdh,0cdh,0cdh,0cdh,0cdh,0cdh,0cdh,0cdh,0cdh,0cdh,0cdh,0cdh,0cdh,0cdh,0cdh,0cdh,0cdh,0cdh,0cdh,0cdh,0cdh,0cdh,0cdh,0cdh,0cdh,0cdh,0cdh,0cdh,0cdh,0cdh,0cdh,0cdh,0cdh,0cdh,0cdh,0cdh,0cdh,0cdh,0cdh,0cdh,0cdh,0cdh,0cdh,0cdh,0bch, 09h,0B1H,0B1H,0B1H,0B1H,0B1H,0B1H,0B1H,0B1H,0B1H,0B1H,0B1H,0B1H,0B1H,0B1H,0B1H,0B1H,0B1H,0B1H,0B1H,0B1H,0B1H,0B1H,"$"


INFO1          db    " *TABELA DE PONTOS*$"
INFO2          db 10h," Pontos: $"
INFO3          db 10h," Boa sorte! ",02h,"$" 
INFO4          db     "_Flavi snake v1.0_$"



GAME_OVER     db 0dh,0ah,0ah,0ah,0ah,0ah,0ah,0ah,09h,09h,"  ___   __   _  _  ____     __   _  _  ____  ____ ", 0dh,0ah 
              db 09h,09h,                                " / __) / _\ ( \/ )(  __)   /  \ / )( \(  __)(  _ \", 0dh,0ah
              db 09h,09h,                                "( (_ \/    \/ \/ \ ) _)   (  O )\ \/ / ) _)  )   /", 0dh,0ah
              db 09h,09h,                                " \___/\_/\_/\_)(_/(____)   \__/  \__/ (____)(__\_)", 0dh,0ah    
              
              db 0ah,0ah,09h,09h,09h, "Ups... Parece que perdes-te!", 0dh,0ah 
              db 0ah,09h,09h,09h,20h,20h,20h,20h,20h,04h, "  Pontuacao:   ",20h,20h,0dh,0ah   
              
              db 0ah,0ah,0ah,09h,09h,0AEh,0AEh,0AEh, " Jogo realizado por: Bruno Medeiros ",0AFh,0AFh,0AFh,"$"

                   
                   
;Funcao responsavel por escrever dentro da tabela de pontuacao

PRINT_TABLE proc
    
MOV DL, 57
MOV DH, 6

;Funcao que define a posicao do cursor com base no registo DX
MOV     AH, 02h  
INT     10h

;INT para escrever na tabela de pontos
MOV AH, 9         
LEA DX, INFO1
INT 21H

;Definicao de coordenadas para o cursor
MOV DL, 57
MOV DH, 9

;Funcao que define a posicao do cursor com base no registo DX
MOV     AH, 02h  
INT     10h   

MOV AH, 9         
LEA DX, INFO2
INT 21H  

MOV DL, 57
MOV DH, 12

;Funcao que define a posicao do cursor com base no registo DX
MOV     AH, 02h  
INT     10h   

MOV AH, 9         
LEA DX, INFO3
INT 21H


MOV DL, 58
MOV DH, 15

;Funcao que define a posicao do cursor com base no registo DX
MOV     AH, 02h  
INT     10h   

MOV AH, 9         
LEA DX, INFO4
INT 21H

ret

PRINT_TABLE endp     




      
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
  
CMP DL, '1'
JE ARENA1

CMP Dl, '2'
JE ARENA2

CMP Dl, '3'
JE ARENA3

JNE MENU
RET




;** ARENA 50x22 **

ARENA1: 


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

;funcao para escrever dentro da tabela
call PRINT_TABLE                      


MOV CX, 1; Definimos 1 no contador para saber que e a 1x que vai fazer loop

 
;Guarda na variavel y_coord a coordenada y do limite baixo desta arena

mov y_coord, 22     ;22 pois e o tamanho definido da arena

add y_coord, 1      ;adicionamos 1 pois esse e o offset da arena


JMP GAME  




 
;** ARENA 50x19 **
    
ARENA2:

MOV AH, 9         
LEA DX, modo_medio
INT 21H 
                                       

MOV AH,9
LEA DX,COL1
INT 21H

MOV CX, 17

TABULEIRO2:
    
MOV AH,9
LEA DX,COL2
INT 21H

LOOP TABULEIRO2


MOV AH,9
LEA DX,COL3
INT 21H   

call PRINT_TABLE  

MOV CX, 1


;Guarda na variavel y_coord a coordenada y do limite baixo desta arena

mov y_coord, 19   

add y_coord, 1     


JMP GAME 





;** ARENA 50x16 **

ARENA3:

MOV AH, 9         
LEA DX, modo_dificil
INT 21H 

MOV AH,9
LEA DX,COL1
INT 21H

MOV CX, 14

TABULEIRO3: 

MOV AH,9
LEA DX,COL2
INT 21H

LOOP TABULEIRO3

MOV AH,9
LEA DX,COL3
INT 21H

call PRINT_TABLE  

MOV CX, 1


;Guarda na variavel y_coord a coordenada y do limite baixo desta arena

mov y_coord, 16     

add y_coord, 1      


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





;Instrucao responsavel por resetar o contado

no_key:  

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
 
MOV AL,DL
MOV AH,0

MOV BX,3

XOR DX, DX; DX=0

DIV BX ; 0-99/ 3 onde o resto fica em AH (numero maximo que pode ser gerado 99/3 = 33  => compativel com todas as arenas

MOV BL, x_coord   ;46  
DEC BL  ; para quando resto for igual a 0 nao spawnar no limite da arena

SUB BL, AL        ;45-resto=x da comid


;Atribuimos esse valor como sendo coordenada x da comida
MOV fruitx, BL
                 
                 
                 
                 
;** Numero Randomico para ser a coordenada y da fruta  

;o y estara entre 4 e 23 logo so podemos gerar esses numeros

;get system time 
MOV AH, 02CH
INT 21H


;dividir o valor obtido de DH por 3 uma vez que gera numeros entre 0 a 99
MOV AL,DL
MOV AH,0          
          
MOV BX,7     ;99/7 (n maximo gerado = 14 => e compativel com todas as arenas

XOR DX, DX; DX=0

DIV BX ; 0-99/ 10 onde o resto fica em AH  

                                                                   
MOV BL, y_coord            
DEC BL

SUB BL, AL       ;46-resto=x da comida

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

MOV DL, 66
MOV DH, 9

;Funcao que define a posicao do cursor com base no registo DX
MOV     AH, 02h  
INT     10h


;Funcao que escreve no ecra score
MOV ah, score 
CALL print_num


;geramos outra comida na arena
CALL fruitgeneration   

RET





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

INT 20h 

END         