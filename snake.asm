; ========================================================================================================================================================================
;                                                           JOGO DA COBRA (SNAKE GAME) 
;                                       Catarina Afonso , Guilherme Goncalves, Iris Gaspar 
; ========================================================================================================================================================================

; --- Bibliotecas do Windows e C Runtime ---
includelib ucrt.lib                                         ; Inclui a biblioteca C padrão (Universal CRT)
includelib legacy_stdio_definitions.lib                     ; Inclui definições antigas de Input/Output (para printf)

;---Bibliotecas de Escrita na consola---
extern putchar:proc                                         ; Função C para escrever um caracter
extern printf:proc                                          ; Função C para escrever texto formatado

;---Bibliotecas de Leitura na consola---
extern _getch:proc                                          ; Função C para ler tecla (espera)
extern _kbhit:proc                                          ; Função C para verificar tecla (não espera)
extern scanf:proc

; --- Bibliotecas do Sistema Operativo (Windows) ---
extern system:proc                                          ; Função C para executar comandos cmd (ex: cls)
extern exit:proc                                            ; Função C para terminar o programa
extern GetStdHandle:proc                                    ; API Windows: Obter controlo da consola
extern WriteConsoleA:proc                                   ; API Windows: Escrever na consola (rápido)
extern ExitProcess:proc                                     ; API Windows: Terminar processo
extern Sleep:proc                                           ; API Windows: Pausa (delay)
extern Beep:proc                                            ; API Windows: Som de Beep

; --- Bibliotecas de Manipulação do Cursor ---
extern SetConsoleCursorPosition:proc                        ; API Windows: Mover o cursor
extern SetConsoleCursorInfo:proc                            ; API Windows: Esconder/Mostrar cursor

; --- Biblioteca de Cores ---
extern SetConsoleTextAttribute:proc                         ; API Windows: Mudar cor do texto

; --- Constantes ---
STD_OUTPUT_HANDLE equ -11                                   ; Valor -11 identifica o Ecrã (Saída Padrão)

; ==================================================================================================================================================================================
;                                                   DEFINIÇÃO DE DADOS (VARIÁVEIS, TEXTOS, ETC.)
; ==================================================================================================================================================================================
.data
    
    ; --- Mensagens Jogo da Cobra ---
    titulo0         db "                                                                                                                                          ",13,10,0
    titulo1         db "                                                                                     ##    ####      ####    ####      ####       ##      ",13,10,0
    titulo2         db "                                                                                     ##   ##  ##    ##      ##  ##     ##  ##    ####     ",13,10,0
    titulo3         db "                                                                                     ##   ##  ##    ##      ##  ##     ##  ##   ##  ##    ",13,10,0
    titulo4         db "                                                                                     ##   ##  ##    ##  ##  ##  ##     ##  ##   ######    ",13,10,0
    titulo5         db "                                                                                ##   ##   ##  ##    ##  ##  ##  ##     ##  ##   ##  ##    ",13,10,0
    titulo6         db "                                                                                ##   ##   ##  ##    ##  ##  ##  ##     ##  ##   ##  ##    ",13,10,0
    titulo7         db "                                                                                 #####     ####      ####    ####      ####     ##  ##    ",13,10,0
    espaco          db "                                                                 ",13,10,0
    titulo10        db "                                                                                        ####    ####    #####    #####       ##               ",13,10,0
    titulo11        db "                                                                                       ##      ##  ##   ##  ##   ##  ##     ####               ",13,10,0
    titulo12        db "                                                                                       ##      ##  ##   #####    #####     ##  ##             ",13,10,0
    titulo13        db "                                                                                       ##      ##  ##   ##  ##   ##  ##    ######             ",13,10,0
    titulo14        db "                                                                                       ##      ##  ##   ##  ##   ##  ##    ##  ##             ",13,10,0
    titulo15        db "                                                                                        ####    ####    #####    ##  ##    ##  ##             ",13,10,0 

    ; --------- Textos de Informação ----------
    ; --- Programadores ---
    apresentacao    db "                                                                                      ===========[ PROGRAMADORES ]===========",13,10,0
    nome1           db "                                                                                       º GUILHERME GONCALVES * * * * * ", 13, 10, 0
    nome2           db "                                                                                       º CATARINA AFONSO * * * * * * *", 13, 10, 0
    nome3           db "                                                                                       º IRIS GASPAR * * * * * * * * * ", 13, 10, 0
    ; --- Como Jogar ---
    como            db "Como Jogar?", 13, 10, 0
    jogo1           db "1) Evita Bater na Parede e em Ti mesmo!", 13, 10, 0
    jogo2           db "2) Tenta comer o Maximo de Comida Possivel!", 13, 10, 0
    jogo3           db "3) Pontuacao = Tamanho da tua cobra * Passos", 13, 10, 0
    jogo4           db "Tenta a tua sorte!", 13, 10, 0
    utilizador      db "Insere o teu nome:  ", 0

    ; --- Opções do Menu ---
    menu_opt1       db "                                                                                                     [ 1 ] - Iniciar Jogo", 13, 10, 0
    menu_opt2       db "                                                                                                     [ 2 ] - Programadores", 13, 10, 0
    menu_opt3       db "                                                                                                     [ 3 ] - Sair", 13, 10, 0

    ; --- Utilizador ---
    utilizador_buffer      db 100 dup(0)
    ler_utilizador         db "%99s", 0
    contador_de_jogos      db 0
    high_score_print       db "                                               Highest Score: %I64u",0 
    high_score             dq  0

    
    ; --- Comandos e Utilitários ---
    cls_command     db "cls", 0                                 ; Comando para limpar ecrã
    newline         db 13,10,0                                  ; Quebra de linha (Enter)

    ; --- Caracteres do Jogo ---
    wall_char       db "#",0                                    ; Parede
    space_char      db " ",0                                    ; Espaço vazio (apagar)
    snake_head_char db "@", 0                                   ; Cabeça
    body_char       db "+", 0                                   ; Corpo
    food_char       db "*", 0                                   ; Comida

    ; --- Configurações da Grelha ---
    box_width       dq 80                                       ; Largura (80 colunas)
    box_height      dq 25                                       ; Altura (25 linhas)
    move_delay      dq 100                                      ; Velocidade (ms)

    ; --- Estado do Jogo ---
    score           QWORD 0                 ; Pontuação
    utilizadorjogo  db "Utilizador: %s", 0
    score_format    db "   Score: %I64u",13,10,0
    SnakeDim        QWORD 1                 ; Tamanho da cobra
    food_score      dq 10                   ; Pontos por comida

    ; --- Coordenadas da Comida ---
    foodX           dq ?                    ; X da comida
    foodY           dq ?                    ; Y da comida

    ; --- Memória do Corpo da Cobra (Arrays) ---
    snakeX          dq 200 dup(0)           ; Lista de posições X (até 200)
    snakeY          dq 200 dup(0)           ; Lista de posições Y (até 200)

    ; --- Mensagens Game Over ---
    go_msg1  db "                                                                     ####      ##      ##   ##  ######       ####   ##   ##  ######  #####  ",13,10,0
    go_msg2  db "                                                                    ##  ##    ####     ### ###  ##          ##  ##  ##   ##  ##      ##  ## ",13,10,0
    go_msg3  db "                                                                   ##        ##  ##    ## # ##  ##          ##  ##  ##   ##  ##      ##  ## ",13,10,0
    go_msg4  db "                                                                   ##        ######    ##   ##  ####        ##  ##  ##   ##  ####    #####  ",13,10,0
    go_msg5  db "                                                                   ##  ###   ##  ##    ##   ##  ##          ##  ##  ##   ##  ##      ##  ## ",13,10,0
    go_msg6  db "                                                                    ##  ##   ##  ##    ##   ##  ##          ##  ##   ## ##   ##      ##  ## ",13,10,0
    go_msg7  db "                                                                     #####   ##  ##    ##   ##  ######       ####     ###    ######  ##  ## ",13,10,13,10,0
    go_score db "                                                                                               SCORE FINAL: %I64u",13,10,13,10,0
    go_user  db "                                                                                        Obrigada por teres jogado %s!", 13, 10, 0
    go_exit  db "                                                                                      Prima qualquer tecla para ir para o Menu...",0

    ; --- Configuração do Cursor ---
    cursor_visible  dd 100, 0               ; Tamanho=100, Visível=0 (Falso)

; ============================================================================================================================================================
;                                                                 SECÇÃO DE CÓDIGO
; ============================================================================================================================================================
.code

; ------------------------------------------------------------------------------
; ResetGame: Zera as variáveis para um novo jogo
; ------------------------------------------------------------------------------
ResetGame PROC
    mov rax, 0                          ; Coloca 0 em RAX
    mov [score], rax                    ; Zera o Score na memória
    
    mov rax, 1                          ; Coloca 1 em RAX
    mov [SnakeDim], rax                 ; Reinicia o tamanho da cobra para 1
    
    ret                                 ; Retorna
ResetGame ENDP

; ------------------------------------------------------------------------------
; HideCursor: Esconde o curor na consola
; ------------------------------------------------------------------------------
HideCursor PROC
    sub  rsp, 40                        ; Aloca 40 bytes na stack (Shadow Space)

    mov  ecx, STD_OUTPUT_HANDLE         ; Prepara argumento: Ecrã Padrão
    call GetStdHandle                   ; Pede ao Windows o ID da consola
    
    mov  rcx, rax                       ; Move o ID (Handle) para RCX (1º arg)
    lea  rdx, cursor_visible            ; Carrega endereço da config para RDX (2º arg)
    call SetConsoleCursorInfo           ; Chama função para aplicar configuração

    add  rsp, 40                        ; Liberta stack
    ret                                 ; Retorna
HideCursor ENDP

; ------------------------------------------------------------------------------
; UpdateBody: Move o corpo (copia índice i-1 para i)
; ------------------------------------------------------------------------------
UpdateBody PROC
    mov rcx, [SnakeDim]                 ; Contador = Tamanho da cobra

shift_loop:
    cmp rcx, 0                          ; Verifica se chegou ao pescoço (0)
    je  fim_update                      ; Se sim, acabou

    mov rdx, rcx                        ; Copia índice atual
    dec rdx                             ; RDX = Índice anterior (i-1)

    ; --- Mover X ---
    lea r8, snakeX                      ; Endereço do array X
    mov rax, [r8 + rdx*8]               ; Lê valor da posição anterior
    mov [r8 + rcx*8], rax               ; Escreve na posição atual

    ; --- Mover Y ---
    lea r8, snakeY                      ; Endereço do array Y
    mov rax, [r8 + rdx*8]               ; Lê valor da posição anterior
    mov [r8 + rcx*8], rax               ; Escreve na posição atual

    dec rcx                             ; Decrementa contador
    jmp shift_loop                      ; Repete

fim_update:
    ret                                 ; Retorna
UpdateBody ENDP

; ------------------------------------------------------------------------------
; DrawScore: Desenha a pontuação no topo
; ------------------------------------------------------------------------------
DrawScore PROC
    push rbx                            ; Guarda RBX
    sub  rsp, 32                        ; Aloca stack

    mov  ecx, STD_OUTPUT_HANDLE         ; Pede Handle
    call GetStdHandle
    mov  rbx, rax                       ; Guarda Handle
    xor  rax, rax                       ; RAX = 0
    mov  rdx, rax                       ; RDX = 0 (Coordenada 0,0)
    mov  rcx, rbx                       ; RCX = Handle
    call SetConsoleCursorPosition       ; Move cursor para topo esquerdo

    lea rcx, utilizadorjogo
    lea rdx, utilizador_buffer
    call printf

    lea  rcx, score_format              ; String "SCORE: %d"
    mov  rdx, [score]                   ; Valor do score
    call printf                         ; Imprime

    cmp [contador_de_jogos], 0
    je  fim

    lea rcx, high_score_print
    mov rdx, [high_score]
    call printf

    fim:
    add  rsp, 32                        ; Limpa stack
    pop  rbx                            ; Restaura RBX
    ret

DrawScore ENDP

; ------------------------------------------------------------------------------
; MENU: Mostra opções e retorna escolha
; ------------------------------------------------------------------------------
MENU PROC
    sub  rsp, 40                        ; Aloca stack
    call WaitAndClear

    ; --- Impressão da Arte ASCII ---
    lea rcx, titulo0
    call printf
    lea rcx, titulo0
    call printf

    mov  ecx, STD_OUTPUT_HANDLE
    call GetStdHandle
    mov  rbx, rax                       ; Guardar Handle em RBX

    mov  rcx, rbx
    mov  rdx, 12                        ; 12 = Vermelho Claro
    call SetConsoleTextAttribute

    lea  rcx, titulo1
    call printf
    lea  rcx, titulo2
    call printf

     mov  rcx, rbx
    mov  rdx, 7                       ; 7=Branco
    call SetConsoleTextAttribute


    lea  rcx, titulo3
    call printf
    lea  rcx, titulo4
    call printf

    mov  rcx, rbx
    mov  rdx, 12                        ; 12 = Vermelho Claro
    call SetConsoleTextAttribute

    lea  rcx, titulo5
    call printf
    lea  rcx, titulo6
    call printf

    mov  rcx, rbx
    mov  rdx, 7                       ; 7=Branco
    call SetConsoleTextAttribute

    lea  rcx, titulo7
    call printf
    lea  rcx, espaco
    call printf
    lea  rcx, espaco
    call printf

    mov  rcx, rbx
    mov  rdx, 12                        ; 12 = Vermelho Claro
    call SetConsoleTextAttribute

    lea  rcx, titulo10
    call printf
    lea  rcx, titulo11
    call printf

    mov  rcx, rbx
    mov  rdx, 7                       ; 7=Branco
    call SetConsoleTextAttribute

    lea  rcx, titulo12
    call printf
    lea  rcx, titulo13
    call printf

    mov  rcx, rbx
    mov  rdx, 12                        ; 12 = Vermelho Claro
    call SetConsoleTextAttribute

    lea  rcx, titulo14
    call printf
    lea  rcx, titulo15
    call printf

    mov  rcx, rbx
    mov  rdx, 7                       ; 7=Branco
    call SetConsoleTextAttribute

    ; --- Impressão dos Nomes ---
    lea  rcx, espaco
    call printf
    lea  rcx, espaco
    call printf
    lea  rcx, espaco
    call printf
    lea  rcx, espaco
    call printf
    
   
    ; --- Impressão das Opções ---
    lea  rcx, menu_opt1                 ; "1 - Iniciar"
    call printf
    lea  rcx, menu_opt2                 ; "2 - Sair"
    call printf
    lea rcx, menu_opt3                  ; "3 - Pontuação"
    call printf

    lea rcx, como
    call printf
    lea rcx, jogo1
    call printf
    lea rcx, jogo2
    call printf
    lea rcx, jogo3
    call printf
    lea rcx, espaco
    call printf

    ; --- Ler Tecla ---
    call _getch                         ; Lê caracter do teclado para AL

    add  rsp, 40                        ; Limpa stack
    ret                                 ; Retorna (AL tem a tecla escolhida)
MENU endp

; ------------------------------------------------------------------------------
; WaitAndClear: Limpa o ecrã (versão simplificada)
; ------------------------------------------------------------------------------
WaitAndClear PROC
    push rbp                            ; Guarda base pointer
    mov  rbp, rsp                       ; Configura novo stack frame
    sub  rsp, 32                        ; Aloca stack

    ; Nota: O nome diz "Wait", mas aqui só estamos a limpar
    ; porque o MENU já fez o "Wait" (espera) ao ler a tecla.
    lea  rcx, cls_command               ; Comando "cls"
    call system                         ; Limpa ecrã

    add  rsp, 32                        ; Limpa stack
    pop  rbp                            ; Restaura base pointer
    ret                                 ; Retorna
WaitAndClear endp

; ------------------------------------------------------------------------------
; SpawnHead: MOTOR DO JOGO
; ------------------------------------------------------------------------------
SpawnHead PROC 
    push rbx                            ; Guarda registos importantes
    push r12                            ; R12 = X da Cabeça
    push r13                            ; R13 = Y da Cabeça
    push r14                            ; R14 = Direção X
    push r15                            ; R15 = Direção Y
    sub  rsp, 32                        ; Aloca stack

    mov  ecx, STD_OUTPUT_HANDLE         ; Pede Handle
    call GetStdHandle
    mov  rbx, rax                       ; Guarda Handle em RBX

    ; --- Calcular Centro X ---
    xor  rdx, rdx
    mov  rax, [box_width]
    mov  rcx, 2
    div  rcx
    mov  r12, rax                       ; X Inicial

    ; --- Calcular Centro Y ---
    xor  rdx, rdx
    mov  rax, [box_height]
    mov  rcx, 2
    div  rcx
    add  rax, 1
    mov  r13, rax                       ; Y Inicial

    ; --- Sortear Direção Inicial ---
    rdtsc
    xor  rdx, rdx
    mov  rcx, 4
    div  rcx                            ; Resto 0-3
    
    cmp  rdx, 0
    je   dir_up
    cmp  rdx, 1
    je   dir_down
    cmp  rdx, 2
    je   dir_left

dir_right:
    mov  r14, 1                         ; dX=1
    mov  r15, 0                         ; dY=0
    jmp  start_game_loop
dir_left:
    mov  r14, -1                        ; dX=-1
    mov  r15, 0                         ; dY=0
    jmp  start_game_loop
dir_down:
    mov  r14, 0                         ; dX=0
    mov  r15, 1                         ; dY=1
    jmp  start_game_loop
dir_up:
    mov  r14, 0                         ; dX=0
    mov  r15, -1                        ; dY=-1

; ==============================================================================
; LOOP PRINCIPAL (Corre a cada frame)
; ==============================================================================
start_game_loop:
    call UpdateBody                     ; Atualiza memória do corpo

    ; --- Guardar Posição Atual da Cabeça ---
    lea  rax, snakeX
    mov  [rax], r12                     ; Guarda X na posição 0
    lea  rax, snakeY
    mov  [rax], r13                     ; Guarda Y na posição 0

    ; --- Desenhar Corpo ('+') ---
    mov  rax, r13                       ; Y
    shl  rax, 16                        ; Move Y para cima
    mov  dx, r12w                       ; X
    or   ax, dx                         ; Combina
    mov  rdx, rax                       ; RDX = COORD
    mov  rcx, rbx                       ; Handle
    call SetConsoleCursorPosition       ; Move cursor para onde a cabeça estava

    mov  rcx, rbx                       ; Handle
    lea  rdx, body_char                 ; '+'
    mov  r8, 1
    lea  r9, [rsp+8]
    call WriteConsoleA                  ; Desenha corpo

    ; --- Apagar Cauda ---
    mov  rcx, [SnakeDim]                ; Índice da ponta da cauda
    lea  rax, snakeY
    mov  r8, [rax + rcx*8]              ; Y da cauda
    lea  rax, snakeX
    mov  r9, [rax + rcx*8]              ; X da cauda
    
    mov  rax, r8                        ; Y
    shl  rax, 16
    mov  dx, r9w                        ; X
    or   ax, dx
    mov  rdx, rax                       ; COORD da cauda
    
    mov  rcx, rbx                       ; Handle
    call SetConsoleCursorPosition       ; Move cursor para a cauda
    
    mov  rcx, rbx                       ; Handle
    lea  rdx, space_char                ; " "
    mov  r8, 1
    lea  r9, [rsp+8]
    call WriteConsoleA                  ; Apaga

    ; --- Mover Cabeça (Matemática) ---
    add  r12, r14                       ; Novo X
    add  r13, r15                       ; Novo Y

    ; --- Pontos por Movimento ---
    mov  rax, [SnakeDim]                ; Pontos = Tamanho
    add  [score], rax                   ; Soma ao score
    call DrawScore                      ; Atualiza ecrã

    ; --- Verificar Auto-Colisão ---
    mov  rcx, [SnakeDim]                ; Começa do fim
    dec  rcx                            ; Ignora a cauda que acabou de apagar

check_self_loop:
    cmp  rcx, 0                         ; Chegou ao pescoço?
    je   end_self_check

    lea  r8, snakeX
    mov  rax, [r8 + rcx*8]              ; X do corpo
    cmp  r12, rax                       ; CabeçaX == CorpoX?
    jne  next_body_part

    lea  r8, snakeY
    mov  rax, [r8 + rcx*8]              ; Y do corpo
    cmp  r13, rax                       ; CabeçaY == CorpoY?
    je   game_over                      ; Bateu!

next_body_part:
    dec  rcx                            ; Próximo pedaço
    jmp  check_self_loop
end_self_check:
    
    ; --- Verificar Comida ---
    mov  rax, [foodX]
    cmp  r12, rax
    jne  check_walls
    mov  rax, [foodY]
    cmp  r13, rax
    jne  check_walls

    ; --- Comeu a Fruta ---
    call DrawScore
    add  [SnakeDim], 1                  ; Cresce
    mov rcx, 600                        ; Frequência: 600 Hz 
    mov rdx, 100                        ; Duração: 100 ms (Curto)
    call Beep                           ; Som de Beep
    call SpawnFood                      ; Nova fruta

check_walls:
    ; CIMA (Y < 2)
    cmp  r13, 3
    jl   game_over
    ; LADOS
    mov  rax, [box_width]
    dec  rax
    cmp  r12, rax
    jge  game_over                      ; X >= 79
    cmp  r12, 1
    jle  game_over                      ; X <= 1
    ; BAIXO (Y > 25)
    mov  rax, [box_height]
    cmp  r13, rax
    jg   game_over
    
    ; --- Desenhar Nova Cabeça ('@') ---
    mov  rax, r13
    shl  rax, 16
    mov  dx, r12w
    or   ax, dx
    mov  rdx, rax
    mov  rcx, rbx
    call SetConsoleCursorPosition
    
    mov  rcx, rbx
    lea  rdx, snake_head_char
    mov  r8, 1
    lea  r9, [rsp+8]
    call WriteConsoleA

    ; --- Pausa (Velocidade) ---
    mov  rcx, [move_delay]
    call Sleep

    ; --- Ler Input (Teclas) ---
    call _kbhit
    cmp  rax, 0
    je   start_game_loop                ; Nenhuma tecla, continua
    call _getch
    
    ; WASD
    cmp  al, 'W'
    je   set_dir_up
    cmp  al, 'w'
    je   set_dir_up
    cmp  al, 'S'
    je   set_dir_down
    cmp  al, 's'
    je   set_dir_down
    cmp  al, 'A'
    je   set_dir_left
    cmp  al, 'a'
    je   set_dir_left
    cmp  al, 'D'
    je   set_dir_right
    cmp  al, 'd'
    je   set_dir_right
    
    ; SETAS
    cmp  al, 0E0h                       ; Código especial
    jne  start_game_loop
    call _getch
    cmp  al, 72
    je   set_dir_up
    cmp  al, 80
    je   set_dir_down
    cmp  al, 75
    je   set_dir_left
    cmp  al, 77
    je   set_dir_right

    jmp  start_game_loop

    ; --- Mudar Direção (Bloqueia inversão de marcha) ---
set_dir_up:
    cmp  r15, 1                         ; Se ia para baixo
    je   start_game_loop                ; ignora
    mov  r14, 0
    mov  r15, -1
    jmp  start_game_loop
set_dir_down:
    cmp  r15, -1                        ; Se ia para cima
    je   start_game_loop                ; ignora
    mov  r14, 0
    mov  r15, 1
    jmp  start_game_loop
set_dir_left:
    cmp  r14, 1                         ; Se ia para direita
    je   start_game_loop                ; ignora
    mov  r14, -1
    mov  r15, 0
    jmp  start_game_loop
set_dir_right:
    cmp  r14, -1                        ; Se ia para esquerda
    je   start_game_loop                ; ignora
    mov  r14, 1
    mov  r15, 0
    jmp  start_game_loop

game_over:
    call DrawScore                      ; Garante score final
    add  rsp, 32                        ; Limpa stack
    pop  r15                            ; Restaura registos
    pop  r14
    pop  r13
    pop  r12
    pop  rbx
    ret                                 ; Retorna ao main
SpawnHead ENDP

; ------------------------------------------------------------------------------
; GRELHA: Desenha as paredes (#)
; ------------------------------------------------------------------------------
Grelha PROC
    sub  rsp, 40
    mov  ecx, STD_OUTPUT_HANDLE
    call GetStdHandle
    mov  rbx, rax
    xor  rsi, rsi                       ; Y

next_row:
    mov  rax, rsi
    cmp  rax, [box_height]
    jge  fim
    xor  rdi, rdi                       ; X

next_col:
    mov  rax, rdi
    cmp  rax, [box_width]
    jge  print_newline

    ; Lógica de Borda
    cmp  rsi, 0                         ; Linha 0?
    je   desenha_wall
    mov  rax, [box_height]
    dec  rax
    cmp  rsi, rax                       ; Última linha?
    je   desenha_wall
    cmp  rdi, 0                         ; Coluna 0?
    je   desenha_wall
    mov  rax, [box_width]
    dec  rax
    cmp  rdi, rax                       ; Última coluna?
    je   desenha_wall
    jmp  desenha_space                  ; Senão espaço

desenha_wall:
    mov  rcx, rbx                       ; Handle da consola
    lea  rdx, wall_char                 ; '#'
    mov  r8, 1                          ; Tamanho 1
    lea  r9, [rsp+8]                    ; Espaço para bytes escritos
    call WriteConsoleA                  ; Desenha parede
    jmp  continue_col                   ; Continua

desenha_space:                          
    mov  rcx, rbx                       ; Handle da consola
    lea  rdx, space_char                ; ' '
    mov  r8, 1                          ; Tamanho 1
    lea  r9, [rsp+8]                    ; Espaço para bytes escritos
    call WriteConsoleA                  ; Desenha espaço
continue_col:                           ; Próxima coluna
    inc  rdi                            ; Incrementa X
    jmp  next_col                       ; Repete

print_newline:                          ; Nova linha
    mov  rcx, rbx                       ; Handle da consola
    lea  rdx, newline                   ; Quebra de linha
    mov  r8, 2                          ; Tamanho 2
    lea  r9, [rsp+8]                    ; Espaço para bytes escritos
    call WriteConsoleA                  ; Desenha nova linha
    inc  rsi                            ; Incrementa Y
    jmp  next_row                       ; Repete
fim:
    add  rsp, 40
    ret
Grelha ENDP

; ------------------------------------------------------------------------------
; SpawnFood: Gera comida em posição aleatória
; ------------------------------------------------------------------------------
SpawnFood PROC
    push rbx   
    push rax
    push rcx
    push rdx
    sub  rsp, 32

    mov  ecx, STD_OUTPUT_HANDLE                 ; Pede Handle
    call GetStdHandle                           ; Coloca em RAX
    mov  rbx, rax

    ; Gerar X (1-78)
    rdtsc                                       ; Lê contador
    xor  rdx, rdx                               ; Zera RDX
    mov  rcx, 78                                ; Divisor
    div  rcx                                    ; Divide
    add  rdx, 1                                 ; Garante mínimo 1
    mov  [foodX], rdx                           ; Guarda X

    ; Gerar Y (3-23)
    rdtsc                                       ; Lê contador
    xor  rdx, rdx                               ; Zera RDX
    mov  rcx, 21                                ; Divisor
    div  rcx                                    ; Divide
    add  rdx, 3                                 ; Garante mínimo 3
    mov  [foodY], rdx                           ; Guarda Y

    ; Desenhar
    mov  rax, rdx                               ; Y
    shl  rax, 16
    mov  rdx, [foodX]                           ; X
    or   ax, dx
    mov  rdx, rax                               ; COORD
    mov  rcx, rbx
    call SetConsoleCursorPosition               ; Move cursor

    mov rcx, rbx                                ; RCX = Handle da Consola
    mov rdx, 10                                 ; RDX = 10 (Verde Claro)
    call SetConsoleTextAttribute                ; Aplica a cor

    mov  rcx, rbx                               ; Handle da Consola
    lea  rdx, food_char                         ; '*'
    mov  r8, 1                                  ; Tamanho 1
    lea  r9, [rsp+8]                            ; Espaço para bytes escritos
    call WriteConsoleA                          ; Desenha comida
    
    mov rcx, rbx                                ; RCX = Handle
    mov rdx, 7                                  ; RDX = 7 (Branco Padrão)
    call SetConsoleTextAttribute                ; Aplica a cor


    add  rsp, 32                                ; Limpa stack       
    pop  rdx                        
    pop  rcx
    pop  rax
    pop  rbx
    ret
SpawnFood ENDP

ReadUserName PROC
    sub rsp, 40 
    lea rcx, utilizador                         ; Prompt "Insere o teu nome: "
    call printf                                 ; Imprime prompt

    lea rcx, ler_utilizador                     ; Formato "%s"
    lea rdx, utilizador_buffer                  ; Buffer para o nome
    call scanf

    skip_rest:
        call _kbhit                             ; Verifica se há tecla pressionada
        cmp rax, 0                              ; Se não houver tecla
        je end_read_loop                        ;  pula para o fim
        call _getch                             ; Lê a tecla (descarta)
        jmp skip_rest                           ; Repete

    end_read_loop:
        add rsp, 40             
        ret
ReadUserName ENDP

; ------------------------------------------------------------------------------
; ShowGameOver: Ecrã Final
; ------------------------------------------------------------------------------
ShowGameOver PROC
    sub  rsp, 40

    ; 1º Tom: Agudo e curto
    mov  rcx, 600  ; Frequência de 600 Hz
    mov  rdx, 150  ; Duração de 150 ms
    call Beep     
    
    ; Pequena pausa para separação
    mov  rcx, 100
    call Sleep

    ; 2º Tom: Médio
    mov  rcx, 400  ; Frequência de 400 Hz
    mov  rdx, 200  ; Duração de 200 ms
    call Beep

    ; Pequena pausa
    mov  rcx, 100
    call Sleep

    ; 3º Tom: Grave e mais longo
    mov  rcx, 200  ; Frequência de 200 Hz
    mov  rdx, 400  ; Duração de 400 ms
    call Beep

    inc [contador_de_jogos]                     ; Incrementa contador de jogos

    mov rax, [score]                            ; Carrega score atual
    mov rcx, [high_score]                       ; Carrega high score
    cmp rax,rcx                                 ; Compara
    jle mantem_high_score                       ; Se menor ou igual, mantém

    mov [high_score], rax                       ; Atualiza high score

    mantem_high_score:
    lea  rcx, cls_command                       ; Limpar
    call system                                 ; Limpa ecrã

    ; Imprimir Mensagens ASCII
    lea  rcx, espaco                            ; Espaço
    call printf
    lea  rcx, espaco
    call printf

    mov  ecx, STD_OUTPUT_HANDLE                 ; Pede Handle
    call GetStdHandle
    mov  rbx, rax                               ; Guardar Handle em RBX

    ; --- MUDAR PARA VERMELHO (Código 12) ---
    mov  rcx, rbx
    mov  rdx, 12                                ; 12 = Vermelho Claro
    call SetConsoleTextAttribute                ; Aplica a cor


    lea  rcx, go_msg1
    call printf
    lea  rcx, go_msg2
    call printf
    lea  rcx, go_msg3
    call printf
    lea  rcx, go_msg4
    call printf
    lea  rcx, go_msg5
    call printf
    lea  rcx, go_msg6
    call printf
    lea rcx, go_msg7
    call printf

    mov  rcx, rbx
    mov  rdx, 7                                 ; 7 = Branco Padrão
    call SetConsoleTextAttribute




    ; Imprimir Score
    lea  rcx, go_score                           ; Imprime Score Final
    mov  rdx, [score]                            ; Valor do Score
    call printf 

    ; Imprimir Utilizador
    lea rcx, go_user                             ; Imprime Utilizador
    lea rdx, utilizador_buffer                   ; Endereço do Nome
    call printf

    ; Sair
    lea  rcx, go_exit                            ; Imprime mensagem de saída
    call printf
    call _getch                         ; Esperar tecla
    add  rsp, 40
    ret
ShowGameOver ENDP

; ==============================================================================
; MAIN: Ponto de Entrada / Gestão do Ciclo do Jogo
; ==============================================================================
main proc
    sub  rsp, 40                        ; Aloca stack inicial


main_loop:                              ; Etiqueta do início do ciclo
    lea  rcx, cls_command               ; Limpa Ecrã
    call system
    

    call MENU                           ; Mostra menu e lê tecla (retorna em AL)

    cmp  al, '1'                        ; Opção 1?
    je   iniciar_jogo
    cmp  al, '2'
    je   programadores
    cmp  al, '3'                        ; Opção 3?
    je   sair_jogo
    jmp  main_loop                      ; Inválido, repete

iniciar_jogo:
    call HideCursor 
    lea rcx, espaco
    call printf
    call ReadUserName
    mov rcx, 800         ; Frequência
    mov rdx, 100         ; Duração (ms)
    call Beep
    call ResetGame                      ; Zera variáveis
    call WaitAndClear                   ; Limpa
    call DrawScore                      ; Desenha Score 0
    
    lea  rcx, newline                   ; Desenha Linha Nova
    call printf
    
    call Grelha                         ; Desenha Paredes
    call SpawnFood                      ; Primeira Comida
    call SpawnHead                      ; CORRE O JOGO (Loop interno)
    
    call ShowGameOver                   ; Se morreu, mostra Game Over
    jmp  main_loop                      ; Volta ao Menu

programadores:
        mov  ecx, STD_OUTPUT_HANDLE
        call GetStdHandle
        mov  rbx, rax                       ; Guardar Handle em RBX

        mov rcx, rbx
        mov rdx, 15                          ; 15 = Amarelo
        call SetConsoleTextAttribute
        call HideCursor
        call WaitAndClear 
        
        lea rcx, espaco
        call printf
        lea rcx, espaco
        call printf
        lea rcx, espaco
        call printf
        lea rcx, espaco
        call printf
        lea rcx, espaco
        call printf
        lea rcx, espaco
        call printf
        lea rcx, espaco
        call printf
        lea rcx, espaco
        call printf

        mov rcx, rbx
        mov rdx, 12                          ; 12 = Vermelho Claro
        call SetConsoleTextAttribute
        lea  rcx, apresentacao
        call printf

        mov rcx, rbx
        mov rdx, 10                           ; 10 = Verde Claro
        call SetConsoleTextAttribute
        lea  rcx, espaco
        call printf
        lea  rcx, espaco
        call printf
        lea  rcx, nome1
        call printf

        mov rcx, rbx
        mov rdx, 3                            ; 3 = Ciano Claro
        call SetConsoleTextAttribute
        lea  rcx, nome2
        call printf

        mov rcx, rbx
        mov rdx, 13                           ; 13 = Magenta Claro
        call SetConsoleTextAttribute
        lea  rcx, nome3
        call printf

        lea rcx, espaco
        call printf

        mov rcx, rbx
        mov rdx, 7                            ; 7 = Branco Padrão
        call SetConsoleTextAttribute
        lea rcx, go_exit
        call printf
        call _getch
        jmp main_loop

sair_jogo:
    xor  eax, eax                       ; Retorno 0
    add  rsp, 40
    ret
main endp

end                                     ; Fim do ficheiro