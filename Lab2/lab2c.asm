.data 
	msg4: .asciiz "Enter number of disk: "

.macro print(%x,%y,%z)

.data 
msg1: .asciiz "Move disk "
msg2: .asciiz " from peg "
msg3: .asciiz " to peg "
msg4: .asciiz "\n"
.text 
	li $v0,4 
	la $a0,msg1
	syscall 
	
	li $v0,1
	move $a0,%x
	syscall

	li $v0,4 
	la $a0,msg2
	syscall 
	
	li $v0,1
	move $a0,%y
	syscall
	
	li $v0,4 
	la $a0,msg3
	syscall 

	li $v0,1
	move $a0,%z
	syscall
	
	li $v0,4 
	la $a0,msg4
	syscall 
	
.end_macro 

.text 
.globl main 

main:

	li $v0,4
	la $a0,msg4 
	syscall 

	li $v0,5 
	syscall 
	move $a0,$v0  #diabazei to n
	move $s4,$a0
	li $a1,1
	li $a2,2
	li $a3,3

	jal vavel

	li $v0 ,10 
	syscall 


vavel:

    
    addi $sp, $sp, -20 	# ousiastika theloyme stin prwti dimioyrgia tis stoibas
    sw   $ra, 0($sp)    #na apo8ikeusoyme mono tin arxiki ra kai oxi ta orismata 
    sw   $s0, 4($sp)	#ka8ws kai genika den 8eloyme na exoyme stin stoiba tin timi n=1
    sw   $s1, 8($sp)	
    sw   $s2, 12($sp)
    sw   $s3, 16($sp)

    move $s0, $a0 #pername tin timi toy $a0  
    move $s1, $a1
    move $s2, $a2
    move $s3, $a3

    
    beq $s0, 1, exit1  #otan n=1 pigaine kai ektypwse


        addi $a0, $s0, -1  #miwnei tin timi n kata 1 pernwntas tin sto $a0 
        move $a1, $s1	   #wste meta tin klisi tis vavel na kanei sw ton $s0 
        move $a2, $s3      # kai oxi to $s0 -1 
   	 	           #me aytin tin diadikasia den kanoyme sw tin timi n=1 
        move $a3, $s2      #kai sti seira 75 epanaferoyme tin timi poy 8eloume ston $s0
        jal vavel
	
        

    vavel2:
print($s0,$s1,$s3)  # symfwna me tinn c ektypwsi
        addi $a0, $s0, -1
        move $a1, $s2
        move $a2, $s1
        move $a3, $s3
        jal vavel 
        
        
  
    exit:

        lw   $ra, 0($sp)       
        lw   $s0, 4($sp)
        lw   $s1, 8($sp)
        lw   $s2, 12($sp)
        lw   $s3, 16($sp)
        addi $sp, $sp, 20     
        jr $ra

   
    exit1:

        print($s0,$s1,$s3)
        beq $s0,1,exit    #i sun8ki uparxei wste na min paei stin vavel 2 me tin timi 1 
        j vavel2          #afou 8a perastei ston $a0 = 0 addi $a0,$s0,-1.
        		  #Opote otan n=1 pigaine stin exit
			  #gia na epanaferei tis times poy yparxoyn stin stoiba 