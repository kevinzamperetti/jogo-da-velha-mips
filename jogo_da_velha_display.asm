# Kevin Zamperetti Schepke - Arquitetura de Computadores - Projeto - Fase I
# Universidade Fernando Pessoa
# Jogo da velha, utilizando Bitmap Display
#
# Importante: não coloque nenhum outro dado antes do frameBuffer
# Além disso: a ferramenta Bitmap Display deve estar conectada a MARS e definida como
#   display width in pixels: 512
#   display height in pixels: 256
#   base address for display: 0x10010000 (static data)

			.data
frameBuffer:		
			.space 0x80000
buffer_str:		.space 3

insira_linha:          	.asciiz  "Insira a linha: "
insira_coluna:         	.asciiz  "Insira a coluna: "
pula_linha:		.asciiz "\n"
msg_linha_invalida:	.asciiz "Linha inválida! Digite uma linha entre 0 e 2.\n"
msg_coluna_invalida:	.asciiz "Coluna inválida! Digite uma coluna entre 0 e 2.\n"
coluna_preenchida:	.asciiz "Coluna já preenchida! Escolha outra opção de Linha/Coluna.\n"
player1_venceu:		.asciiz "Player 1 (azul) venceu!\n"
player2_venceu:		.asciiz "Player 2 (vermelho) venceu!\n"
jogo_empatado:		.asciiz "Que pena! Jogo empatado!\n"
pontos_player1:		.asciiz "\nTotal de pontos - Player 1 (azul): "
pontos_player2:		.asciiz "\nTotal de pontos - Player 2 (vermelho): "
msg_continua:		.asciiz "\nDeseja continuar?\n(s=sim, x=player1 venceu, o=player2 venceu, r=empate/recomeçar, e=pontuação jogo, f=finalizar jogo): "
msg_letra_incorreta:	.asciiz "\nLetra incorreta."

s:			.asciiz "s"			#Indica que quer continuar jogando
r:			.asciiz "r"			#jogo empatou, indica que deseja recomeçar
x:			.asciiz "x"			#Fim da partida, player1 é o vencedor
o:			.asciiz "o"			#Fim da partida, player2 é o vencedor
p:			.asciiz "p"			#Imprimir o estado atual do tabuleiro (já to fazendo pelo bitmap display)
e:			.asciiz "e"			#Imprimir o número de partidas vencidas por cada um dos jogadores
f:			.asciiz "f"			#Finaliza o programa
teste:			.asciiz "teste"			#Finaliza o programa

			.align 2
array:			.word 0,0,0,0,0,0,0,0,0		#vetor de 9 posicoes (3 linhas / 3 colunas)

			.text
#----------------------------------------------------------------#
# MAIN
#----------------------------------------------------------------#
main:

			addi $s0, $0, 1		#player1 = 1
			addi $s1, $0, 2		#player2 = 2	
			la $s2, array		#armazena endereço de memória do array			
			add $s3, $0, $0		#pontuação - player1 = 1
			add $s4, $0, $0		#pontuação - player2 = 2	

desenho_tabuleiro:
			#Desenho do Primeiro traço na tela
			li $a0,50	#inicio traço
			li $a1,1	#largura traço
			li $a2,40	#altuta traço
			li $a3,120 	#final traço
			jal rectangle
	
			#Desenho do Segundo traço na tela
			li $a0,100	#inicio traço
			li $a1,1	#largura traço
			li $a2,40	#altura traço
			li $a3,120	#final traço
			jal rectangle
			
			#Desenho da primeira linha
			li $a0,10	#inicio da linha
			li $a1,140	#comprimento linha
			li $a2,80	#posição linha
			li $a3,1	#largura linha
			jal rectangle	
	
			#Desenho da segunda linha
			li $a0,10	#inicio da linha
			li $a1,140	#comprimento linha
			li $a2,120	#posiçao linha
			li $a3,1	#largura da linha
			jal rectangle	
	
inicia_jogo:
			#jogo iniciou/reiniciou, limpando o array
			sw $0, 0($s2)
			sw $0, 4($s2)
			sw $0, 8($s2)
			sw $0, 12($s2)
			sw $0, 16($s2)
			sw $0, 20($s2)
			sw $0, 24($s2)
			sw $0, 28($s2)
			sw $0, 32($s2)

jogada_player1:
			jal escolhe_linha_coluna
			move $a0, $v0			#passa retorno da função como parâmetro da função verifica_array
			move $a1, $v1			#passa retorno da função como parâmetro da função verifica_array

			addi $sp, $sp, -8		#altero $sp para guardar $v0 e $v1 na stack
			sw $v0, 0($sp)			#guardo $v0 na stack
			sw $v1, 4($sp)			#guardo $v1 na stack

			jal verifica_array
			addi $t0, $0, -1
			beq $v0, $t0, jogada_player1	#se posição já preenchida ($v0=-1) volta para jogada_player1

			lw $v0, 0($sp)			#recupero $v0 da stack
			lw $v1, 4($sp)			#recupero $v1 da stack
			addi $sp, $sp, 8		#volto estado da stack

			move $a0, $v0			#passo valor de $v0 da stack como parâmetro da função salva_no_array
			move $a1, $v1			#passo valor de $v1 da stack como parâmetro da função salva_no_array
			move $a3, $s0			#parâmetro que indica que é o player1
			move $s7, $s0			#parâmetro que indica que é o player1-ver como passo este 4 parâmetro
			jal salva_no_array

			jal interrupcoes		#função que verifica se players desjam continuar o jogo
			addi $t0, $t0, 2
			beq $v0, $t0, fim_jogo 		#se retorno da função = 2 (digitou f), vai para fim_jogo
			bne $v0, $0, inicia_jogo	#se retorno da função <> 0, inicia_jogo (digitou x/o/r retorna $v0=1)

jogada_player2:		
			jal escolhe_linha_coluna
			move $a0, $v0			#passa retorno da função como parâmetro da função verifica_array
			move $a1, $v1			#passa retorno da função como parâmetro da função verifica_array

			addi $sp, $sp, -8		#altero $sp para guardar $v0 e $v1 na stack
			sw $v0, 0($sp)			#guardo $v0 na stack
			sw $v1, 4($sp)			#guardo $v1 na stack

			jal verifica_array
			addi $t0, $0, -1
			beq $v0, $t0, jogada_player2	#se posição já preenchida ($v0=-1) volta para jogada_player2

			lw $v0, 0($sp)			#recupero $v0 da stack
			lw $v1, 4($sp)			#recupero $v1 da stack
			addi $sp, $sp, 8		#volto estado da stack

			move $a0, $v0			#passo valor de $v0 da stack como parâmetro da função salva_no_array
			move $a1, $v1			#passo valor de $v1 da stack como parâmetro da função salva_no_array
			move $a3, $s1			#parâmetro que indica que é o player2
			move $s7, $s1			#parâmetro que indica que é o player2-ver como passo este 4 parâmetro
			jal salva_no_array
			jal interrupcoes		#função que verifica se players desjam continuar o jogo (interrupções)
			bne $v0, $0, inicia_jogo	#se retorna diferente de 0, inicia_jogo
						
			j jogada_player1

#Estudar a possibilidade de criar uma função para somar a pontuação de acordo com o que digitou.
#Deverá ser chamada na função que verifica o que foi digitado

fim_jogo:
			li $v0,10
			syscall

#----------------------------------------------------------------#
# FUNÇÕES
#----------------------------------------------------------------#
escolhe_linha_coluna:
			la $a0, insira_linha
			li $v0, 4
			syscall	
			li $v0, 5			# leitura da linha
        		syscall   

			addi $t2, $0, 3
			blt $v0, $t2, end_vrf_linha	#linha é menor que 3 vai pro end
			la $a0, msg_linha_invalida	#imprime msg de linha inválida e volta para escolher linha
			li $v0, 4
			syscall
			j escolhe_linha_coluna
end_vrf_linha:
        		move $t0, $v0			#move linha lida para $t0

escolhe_coluna:		la $a0, insira_coluna
			li $v0, 4
			syscall	
			li $v0, 5			# leitura da coluna
        		syscall   

			addi $t2, $0, 3
			blt $v0, $t2, end_vrf_coluna	#coluna é menor que 3 vai pro end
			la $a0, msg_coluna_invalida	#imprime msg de coluna inválida e volta para escolher coluna
			li $v0, 4
			syscall
			j escolhe_coluna
end_vrf_coluna:
          		move $t1, $v0			#move coluna lida para $t1
        		
        		move $v0, $t0			#move linha lida de $t0 para $v0
        		move $v1, $t1			#move coluna lida de $t1 para $v1

			jr $ra

#----------------------------------------------------------------#
verifica_array:
#parâmetros: $a0 = linha
#parâmetros: $a1 = coluna
			addi $t0, $0, 1			
			beq $a0, $0, vrf_linha0		#se linha0
	       		beq $a0, $t0, vrf_linha1	#se linha1
			addi $t0, $0, 2			
			beq $a0, $t0,vrf_linha2		#se linha2

vrf_linha0:		beq $a1, $0, vrf_array_pos0	#se coluna = 0
			beq $a1, $t0, vrf_array_pos4	#se coluna = 1
			addi $t0, $0, 2			
			beq $a1, $t0, vrf_array_pos8	#se coluna = 2			

vrf_array_pos0:		lw $t0, 0($s2) 			#carrega conteúdo da posição 0 do array
			beq $t0, $0, fim_vrf_array	#se posição 0 = 0, vai pro fim da função
			la $a0, coluna_preenchida	#senão gera mensagem de erro
			li $v0, 4
			syscall
			addi $v0, $0, -1		#1 indicando que já está preenchida
			j fim_vrf_array

vrf_array_pos4:		lw $t0, 4($s2) 			#carrega conteúdo da posição 1 do array
			beq $t0, $0, fim_vrf_array	#se posição 1 = 0, vai pro fim da função
			la $a0, coluna_preenchida	#senão gera mensagem de erro
			li $v0, 4
			syscall
			addi $v0, $0, -1		#1 indicando que já está preenchida
			j fim_vrf_array

vrf_array_pos8:		lw $t0, 8($s2) 			#carrega conteúdo da posição 1 do array
			beq $t0, $0, fim_vrf_array	#se posição 1 = 0, vai pro fim da função
			la $a0, coluna_preenchida	#senão gera mensagem de erro
			li $v0, 4
			syscall
			addi $v0, $0, -1			#1 indicando que já está preenchida
			j fim_vrf_array

vrf_linha1:		addi $t0, $0, 1			
			beq $a1, $0, vrf_array_pos12	#se coluna = 0
			beq $a1, $t0, vrf_array_pos16	#se coluna = 1
			addi $t0, $0, 2			
			beq $a1, $t0, vrf_array_pos20	#se coluna = 1			

vrf_array_pos12:	lw $t0, 12($s2) 			#carrega conteúdo da posição 1 do array
			beq $t0, $0, fim_vrf_array	#se posição 1 = 0, vai pro fim da função
			la $a0, coluna_preenchida	#senão gera mensagem de erro
			li $v0, 4
			syscall
			addi $v0, $0, -1			#1 indicando que já está preenchida
			j fim_vrf_array

vrf_array_pos16:	lw $t0, 16($s2) 			#carrega conteúdo da posição 1 do array
			beq $t0, $0, fim_vrf_array	#se posição 1 = 0, vai pro fim da função
			la $a0, coluna_preenchida	#senão gera mensagem de erro
			li $v0, 4
			syscall
			addi $v0, $0, -1			#1 indicando que já está preenchida
			j fim_vrf_array

vrf_array_pos20:	lw $t0, 20($s2) 			#carrega conteúdo da posição 1 do array
			beq $t0, $0, fim_vrf_array	#se posição 1 = 0, vai pro fim da função
			la $a0, coluna_preenchida	#senão gera mensagem de erro
			li $v0, 4
			syscall
			addi $v0, $0, -1			#1 indicando que já está preenchida
			j fim_vrf_array

vrf_linha2:		addi $t0, $0, 1			
			beq $a1, $0, vrf_array_pos24	#se coluna = 0
			beq $a1, $t0, vrf_array_pos28	#se coluna = 1
			addi $t0, $0, 2			
			beq $a1, $t0, vrf_array_pos32	#se coluna = 1			

vrf_array_pos24:	lw $t0, 24($s2) 			#carrega conteúdo da posição 1 do array
			beq $t0, $0, fim_vrf_array	#se posição 1 = 0, vai pro fim da função
			la $a0, coluna_preenchida	#senão gera mensagem de erro
			li $v0, 4
			syscall
			addi $v0, $0, -1			#1 indicando que já está preenchida
			j fim_vrf_array

vrf_array_pos28:	lw $t0, 28($s2) 			#carrega conteúdo da posição 1 do array
			beq $t0, $0, fim_vrf_array	#se posição 1 = 0, vai pro fim da função
			la $a0, coluna_preenchida	#senão gera mensagem de erro
			li $v0, 4
			syscall
			addi $v0, $0, -1			#1 indicando que já está preenchida
			j fim_vrf_array
			
vrf_array_pos32:	lw $t0, 32($s2) 			#carrega conteúdo da posição 1 do array
			beq $t0, $0, fim_vrf_array	#se posição 1 = 0, vai pro fim da função
			la $a0, coluna_preenchida	#senão gera mensagem de erro
			li $v0, 4
			syscall
			addi $v0, $0, -1			#1 indicando que já está preenchida
			j fim_vrf_array
			
fim_vrf_array:		jr $ra

#----------------------------------------------------------------#
salva_no_array:						#verifica linhas e atribui ao array
#parâmetros: $a0 = linha
#parâmetros: $a1 = coluna
#parâmetros: $a3 = player
			beq $a0, $0, linha0		#se linha0
			addi $t0, $0, 1			
        		beq $a0, $t0, linha1		#se linha1
			addi $t0, $0, 2			
			beq $a0, $t0,linha2		#se linha2

linha0:			beq $a1, $0, array_pos0		#se coluna = 0
			addi $t0, $0, 1			
			beq $a1, $t0, array_pos4	#se coluna = 1
			addi $t0, $0, 2			
			beq $a1, $t0, array_pos8	#se coluna = 2			

array_pos0:		sw $a3, 0($s2)			#atribuo 1(player1) na linha0, coluna0
			addi $sp, $sp, -4		#altero $sp para guardar $ra na stack
			sw $ra, 0($sp)			#guardo $ra na stack
			jal desenho_posicao0
			lw $ra, 0($sp)			#recupero $ra da stack
			addi $sp, $sp, 4		#volto estado da stack
			j fim_salva_no_array
array_pos4:		sw $a3, 4($s2)			#atribuo 1(player1) na linha0, coluna1
			addi $sp, $sp, -4		#altero $sp para guardar $ra na stack
			sw $ra, 0($sp)			#guardo $ra na stack
			jal desenho_posicao1
			lw $ra, 0($sp)			#recupero $ra da stack
			addi $sp, $sp, 4		#volto estado da stack
			j fim_salva_no_array
array_pos8:		sw $a3, 8($s2)			#atribuo 1(player1) na linha0, coluna2
			addi $sp, $sp, -4		#altero $sp para guardar $ra na stack
			sw $ra, 0($sp)			#guardo $ra na stack
			jal desenho_posicao2
			lw $ra, 0($sp)			#recupero $ra da stack
			addi $sp, $sp, 4		#volto estado da stack
			j fim_salva_no_array

linha1:			beq $a1, $0, array_pos12	#se coluna = 0
			addi $t0, $0, 1			
			beq $a1, $t0, array_pos16	#se coluna = 1
			addi $t0, $0, 2			
			beq $a1, $t0, array_pos20	#se coluna = 1			

array_pos12:		sw $a3, 12($s2)			#atribuo 1(player1) na linha1, coluna0
			addi $sp, $sp, -4		#altero $sp para guardar $ra na stack
			sw $ra, 0($sp)			#guardo $ra na stack
			jal desenho_posicao3
			lw $ra, 0($sp)			#recupero $ra da stack
			addi $sp, $sp, 4		#volto estado da stack
			j fim_salva_no_array
array_pos16:		sw $a3, 16($s2)			#atribuo 1(player1) na linha1, coluna1
			addi $sp, $sp, -4		#altero $sp para guardar $ra na stack
			sw $ra, 0($sp)			#guardo $ra na stack
			jal desenho_posicao4
			lw $ra, 0($sp)			#recupero $ra da stack
			addi $sp, $sp, 4		#volto estado da stack
			j fim_salva_no_array
array_pos20:		sw $a3, 20($s2)			#atribuo 1(player1) na linha1, coluna2
			addi $sp, $sp, -4		#altero $sp para guardar $ra na stack
			sw $ra, 0($sp)			#guardo $ra na stack
			jal desenho_posicao5
			lw $ra, 0($sp)			#recupero $ra da stack
			addi $sp, $sp, 4		#volto estado da stack
			j fim_salva_no_array

linha2:			beq $a1, $0, array_pos24	#se coluna = 0
			addi $t0, $0, 1			
			beq $a1, $t0, array_pos28	#se coluna = 1
			addi $t0, $0, 2			
			beq $a1, $t0, array_pos32	#se coluna = 1			

array_pos24:		sw $a3, 24($s2)			#atribuo 1(player1) na linha1, coluna0
			addi $sp, $sp, -4		#altero $sp para guardar $ra na stack
			sw $ra, 0($sp)			#guardo $ra na stack
			jal desenho_posicao6
			lw $ra, 0($sp)			#recupero $ra da stack
			addi $sp, $sp, 4		#volto estado da stack
			j fim_salva_no_array
array_pos28:		sw $a3, 28($s2)			#atribuo 1(player1) na linha1, coluna1
			addi $sp, $sp, -4		#altero $sp para guardar $ra na stack
			sw $ra, 0($sp)			#guardo $ra na stack
			jal desenho_posicao7
			lw $ra, 0($sp)			#recupero $ra da stack
			addi $sp, $sp, 4		#volto estado da stack
			j fim_salva_no_array
array_pos32:		sw $a3, 32($s2)			#atribuo 1(player1) na linha1, coluna2
			addi $sp, $sp, -4		#altero $sp para guardar $ra na stack
			sw $ra, 0($sp)			#guardo $ra na stack
			jal desenho_posicao8
			lw $ra, 0($sp)			#recupero $ra da stack
			addi $sp, $sp, 4		#volto estado da stack
			j fim_salva_no_array
			
fim_salva_no_array:	jr $ra

#----------------------------------------------------------------#
interrupcoes:		la $a0, msg_continua
			li $v0, 4
			syscall
			
			la $a0, buffer_str 		#buffer
			li $a1, 3        		#tamanho
			li $v0, 8			#ler string
			syscall

digitou_x:		la $t0, buffer_str		#carrega endereço de memória da letra digitada
			la $t1, x			#carrega endereço de memória de "x"
			lb $t2($t0)  			#carrega o byte da string digitada
			lb $t3($t1)			#carrega o byte de "x"
			bne $t2, $t3, digitou_o		#se não digitou x vai para digitou_o
			la $a0, player1_venceu		#gerar mensagem de que player1 venceu
			li $v0, 4
			syscall				
			addi $s3, $s3, 3		#soma 3 pontos para player1
			addi $s4, $s4, -1		#subtrai um ponto do player2
			bge $s4, $0, continuax		#se >= 0 continua
			add $s4, $0, $0			#senão zera pontuação
continuax:	
			addi $sp, $sp, -4		#altero $sp para guardar $ra na stack
			sw $ra, 0($sp)			#guardo $ra na stack
			jal limpa_tabuleiro
			lw $ra, 0($sp)			#recupero $ra da stack
			addi $sp, $sp, 4		#volto estado da stack
			addi $v0, $0, 1			#passar em $v0=1 indicando que teve um ganhador e deve voltar para inicia_jogo
			j fim_interrupcoes

digitou_o:		la $t0, buffer_str		#carrega endereço de memória da letra digitada
			la $t1, o			#carrega endereço de memória de "o"
			lb $t2($t0)  			#carrega o byte da string digitada
			lb $t3($t1)			#carrega o byte de "o"
			bne $t2, $t3, digitou_r		#se não digitou o vai para digitou_r
			la $a0, player2_venceu		#gerar mensagem de que player1 venceu
			li $v0, 4
			syscall				
			addi $s4, $s4, 3		#soma 3 pontos para player1
			sub $s3, $s3, 1			#subtrai um ponto do player2
			bge $s3, $0, continuao		#se >= 0 continuase negativo, zera pontuação do player2
			add $s3, $0, $0			#senão zera pontuação
continuao:	
			addi $sp, $sp, -4		#altero $sp para guardar $ra na stack
			sw $ra, 0($sp)			#guardo $ra na stack
			jal limpa_tabuleiro
			lw $ra, 0($sp)			#recupero $ra da stack
			addi $sp, $sp, 4		#volto estado da stack
			addi $v0, $0, 1			#passar em $v0=1 indicando que teve um ganhador e deve voltar para inicia_jogo
			j fim_interrupcoes

digitou_r:		la $t0, buffer_str		#carrega endereço de memória da letra digitada
			la $t1, r			#carrega endereço de memória de "o"
			lb $t2($t0)  			#carrega o byte da string digitada
			lb $t3($t1)			#carrega o byte de "o"
			bne $t2, $t3, digitou_e		#se não digitou r vai para digitou_e
			la $a0, jogo_empatado		#gerar mensagem de que player1 venceu
			li $v0, 4
			syscall				

			addi $sp, $sp, -4		#altero $sp para guardar $ra na stack
			sw $ra, 0($sp)			#guardo $ra na stack
			jal limpa_tabuleiro
			lw $ra, 0($sp)			#recupero $ra da stack
			addi $sp, $sp, 4		#volto estado da stack
			addi $v0, $0, 1			#passar em $v0=1 indicando que empatou e deve voltar para inicia_jogo			
			j fim_interrupcoes

digitou_e:		la $t0, buffer_str		#carrega endereço de memória da letra digitada
			la $t1, e			#carrega endereço de memória de "e"
			lb $t2($t0)  			#carrega o byte da string digitada
			lb $t3($t1)			#carrega o byte de "e"
			bne $t2, $t3, digitou_f		#se não digitou e vai para digitou_f
			
			#chamar função exibe_pontuacao e um j interrupções para ver se quer fazer mais alguma coisa
			addi $sp, $sp, -4		#altero $sp para guardar $ra na stack
			sw $ra, 0($sp)			#guardo $ra na stack
			jal exibe_pontuacao
			lw $ra, 0($sp)			#recupero $ra da stack
			addi $sp, $sp, 4		#volto estado da stack
			j interrupcoes	
			
			j fim_interrupcoes
			
digitou_f:		la $t0, buffer_str		#carrega endereço de memória da letra digitada
			la $t1, f			#carrega endereço de memória de "f"
			lb $t2($t0)  			#carrega o byte da string digitada
			lb $t3($t1)			#carrega o byte de "f"
			bne $t2, $t3, digitou_s		#se não digitou f vai para digitou_s
			addi $sp, $sp, -4		#altero $sp para guardar $ra na stack
			sw $ra, 0($sp)			#guardo $ra na stack
			jal limpa_tabuleiro
			lw $ra, 0($sp)			#recupero $ra da stack
			addi $sp, $sp, 4		#volto estado da stack

			#chamar função exibe_pontuacao para imprimir a pontuação dos players
			addi $sp, $sp, -4		#altero $sp para guardar $ra na stack
			sw $ra, 0($sp)			#guardo $ra na stack
			jal exibe_pontuacao
			lw $ra, 0($sp)			#recupero $ra da stack
			addi $sp, $sp, 4		#volto estado da stack

			addi $v0, $0, 2			#passar em $v0=2 indicando que deseja finalizar o programa
			j fim_interrupcoes

digitou_s:		la $t0, buffer_str		#carrega endereço de memória da letra digitada
			la $t1, s			#carrega endereço de memória de "s"
			lb $t2($t0)  			#carrega o byte da string digitada
			lb $t3($t1)			#carrega o byte de "s"
			bne $t2, $t3, letra_incorreta	#se não digitou s vai para letra_incorreta
			addi $v0, $0, 0			#passar em $v0=0 indicando que deseja continuar jogo
			j fim_interrupcoes

letra_incorreta:	la $a0, msg_letra_incorreta
			li $v0, 4
			syscall				
			j interrupcoes

fim_interrupcoes:			
			jr $ra

#----------------------------------------------------------------#
exibe_pontuacao:
			la $a0, pontos_player1
			li $v0, 4
			syscall
			
			li $v0, 1
			move $a0, $s3
			syscall
			
			la $a0, pontos_player2
			li $v0, 4
			syscall

			la $v0, 1
			move $a0, $s4
			syscall

			jr $ra

#----------------------------------------------------------------#
limpa_tabuleiro:	
			addi $sp, $sp, -4		#altero $sp para guardar $ra na stack
			sw $ra, 0($sp)			#guardo $ra na stack

			addi $s7, $0, 3			#passo 3, para quando ir chegar na função rectangle pintar de preto
			jal desenho_posicao0
			jal desenho_posicao1
			jal desenho_posicao2
			jal desenho_posicao3
			jal desenho_posicao4
			jal desenho_posicao5
			jal desenho_posicao6
			jal desenho_posicao7
			jal desenho_posicao8

			lw $ra, 0($sp)			#recupero $ra da stack
			addi $sp, $sp, 4		#volto estado da stack
			jr $ra

#----------------------------------------------------------------#
desenho_posicao0:
			addi $sp, $sp, -4		#altero $sp para guardar $ra na stack
			sw $ra, 0($sp)			#guardo $ra na stack
			li $a0,10	#inicio traço
			li $a1,39	#largura traço
			li $a2,41	#altuta traço
			li $a3,39 	#final traço
			jal rectangle
			lw $ra, 0($sp)			#recupero $ra da stack
			addi $sp, $sp, 4		#volto estado da stack
			jr $ra

#----------------------------------------------------------------#
desenho_posicao1:
			addi $sp, $sp, -4		#altero $sp para guardar $ra na stack
			sw $ra, 0($sp)			#guardo $ra na stack
			li $a0,52	#inicio traço
			li $a1,46	#largura traço
			li $a2,41	#altuta traço
			li $a3,39 	#final traço
			jal rectangle
			lw $ra, 0($sp)			#recupero $ra da stack
			addi $sp, $sp, 4		#volto estado da stack
			jr $ra

#----------------------------------------------------------------#
desenho_posicao2:
			addi $sp, $sp, -4		#altero $sp para guardar $ra na stack
			sw $ra, 0($sp)			#guardo $ra na stack
			li $a0,102	#inicio traço
			li $a1,46	#largura traço
			li $a2,41	#altuta traço
			li $a3,39 	#final traço
			jal rectangle
			lw $ra, 0($sp)			#recupero $ra da stack
			addi $sp, $sp, 4		#volto estado da stack
			jr $ra
	
#----------------------------------------------------------------#
desenho_posicao3:
			addi $sp, $sp, -4		#altero $sp para guardar $ra na stack
			sw $ra, 0($sp)			#guardo $ra na stack
			li $a0,10	#inicio traço
			li $a1,39	#largura traço
			li $a2,81	#altuta traço
			li $a3,39 	#final traço
			jal rectangle	
			lw $ra, 0($sp)			#recupero $ra da stack
			addi $sp, $sp, 4		#volto estado da stack
			jr $ra

#----------------------------------------------------------------#
desenho_posicao4:
			addi $sp, $sp, -4		#altero $sp para guardar $ra na stack
			sw $ra, 0($sp)			#guardo $ra na stack
			li $a0,52	#inicio traço
			li $a1,46	#largura traço
			li $a2,81	#altuta traço
			li $a3,39 	#final traço
			jal rectangle
			lw $ra, 0($sp)			#recupero $ra da stack
			addi $sp, $sp, 4		#volto estado da stack
			jr $ra

#----------------------------------------------------------------#
desenho_posicao5:
			addi $sp, $sp, -4		#altero $sp para guardar $ra na stack
			sw $ra, 0($sp)			#guardo $ra na stack
			li $a0,102	#inicio traço
			li $a1,46	#largura traço
			li $a2,81	#altuta traço
			li $a3,39 	#final traço
			jal rectangle
			lw $ra, 0($sp)			#recupero $ra da stack
			addi $sp, $sp, 4		#volto estado da stack
			jr $ra

#----------------------------------------------------------------#
desenho_posicao6:
			addi $sp, $sp, -4		#altero $sp para guardar $ra na stack
			sw $ra, 0($sp)			#guardo $ra na stack
			li $a0,10	#inicio traço
			li $a1,39	#largura traço
			li $a2,121	#altuta traço
			li $a3,39 	#final traço
			jal rectangle	
			lw $ra, 0($sp)			#recupero $ra da stack
			addi $sp, $sp, 4		#volto estado da stack
			jr $ra

#----------------------------------------------------------------#
desenho_posicao7:
			addi $sp, $sp, -4		#altero $sp para guardar $ra na stack
			sw $ra, 0($sp)			#guardo $ra na stack
			li $a0,52	#inicio traço
			li $a1,46	#largura traço
			li $a2,121	#altuta traço
			li $a3,39 	#final traço
			jal rectangle
			lw $ra, 0($sp)			#recupero $ra da stack
			addi $sp, $sp, 4		#volto estado da stack
			jr $ra

#----------------------------------------------------------------#
desenho_posicao8:
			addi $sp, $sp, -4		#altero $sp para guardar $ra na stack
			sw $ra, 0($sp)			#guardo $ra na stack
			li $a0,102	#inicio traço
			li $a1,46	#largura traço
			li $a2,121	#altuta traço
			li $a3,39 	#final traço
			jal rectangle
			lw $ra, 0($sp)			#recupero $ra da stack
			addi $sp, $sp, 4		#volto estado da stack
			jr $ra

#----------------------------------------------------------------#
rectangle:
			beq $a1,$zero,rectangleReturn 	# largura zero: não desenhe nada
			beq $a3,$zero,rectangleReturn 	# altura zero: não desenhe nada
			
			#testes para definir a cor a ser pintada no tabuleiro
			addi $t0, $0, 1
			bne $t0, $s7, else_if_cor	#se não é player1, vai para cor player2
			li $t0, 0x6495ED #Azul
			j end_cor
else_if_cor:		addi $t0, $0, 2
			bne $t0, $s7, else_if_cor2		#se não é player2, vai para cor default
			li $t0, 0xFF0000 #Vermelho
			j end_cor
else_if_cor2:		addi $t0, $0, 3
			bne $t0, $s7, cor_dft		#se não é player2, vai para cor default
			li $t0, 0x000000 #Preto
			j end_cor
cor_dft:		li $t0,-1 #Branca
end_cor:
			la $t1,frameBuffer
			add $a1,$a1,$a0 		# simplificar os testes de loop, mudando para o primeiro valor muito distante
			add $a3,$a3,$a2
			sll $a0,$a0,2 			# escala x valores para bytes (4 bytes por pixel)
			sll $a1,$a1,2
			sll $a2,$a2,11 			# dimensione y valores para bytes (512 * 4 bytes por linha de exibição)
			sll $a3,$a3,11
			addu $t2,$a2,$t1 		# traduzir valores y para exibir endereços iniciais de linha
			addu $a3,$a3,$t1
			addu $a2,$t2,$a0 		# traduzir valores de y para retângulo de endereços de início de linha
			addu $a3,$a3,$a0
			addu $t2,$t2,$a1 		# e calcular o endereço final da primeira linha de retângulo
			li $t4,0x800 			# bytes por linha de exibição

rectangleYloop:
			move $t3,$a2 			# ponteiro para o pixel atual para o loop X; comece na borda esquerda

rectangleXloop:
			sw $t0,($t3)
			addiu $t3,$t3,4
			bne $t3,$t2,rectangleXloop 	# continue se não ultrapassar a borda direita do retângulo
			
			addu $a2,$a2,$t4 		# avança um valor de linha para a borda esquerda
			addu $t2,$t2,$t4 		# e ponteiros da borda direita
			bne $a2,$a3,rectangleYloop 	# continue indo se não fora do fundo do retângulo

rectangleReturn:
			jr $ra

#----------------------------------------------------------------#
# TESTES
#----------------------------------------------------------------#
#
#................TESTE - loop para ver valores do array
#			add $t5, $0, 9
#			add $t6, $0, 0
#loop1:			beq $t6, $t5, end1
#			lw $t7, 0($s2)
#			addi $s2, $s2, 4 	#vai para próximo endereço de memória de $t3
#			addi $t6, $t6, 1	#i=i+1
#					
#			li $v0, 1
#			move $a0, $t7
#			syscall
#			j loop1
#end1:
