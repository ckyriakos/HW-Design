
.data
.align 2 
	str1: .space 400 
	
	str2: .space 400
msg1:
	.asciiz "Enter first string: "
msg2:
	.asciiz "Enter second string: "
msg_false:
	.asciiz "Result:0"
	
msg_true:
	.asciiz "Result:1"
.text 
.globl main

main:

	#Prints msg1
	li $v0,4
	la $a0,msg1
	syscall 

	#Reads str1
	li $v0,8
	la $a0 ,str1
	li $a1,11 
	syscall 

	#Prints msg2 
	li $v0,4
	la $a0,msg2
	syscall 

	#Reads str2
	li $v0,8
	la $a0,str2
	li $a1,11
	syscall 


	#Length of str1
	la $a0,str1	
	jal strlen 
	move $s1,$s0


	#Length of str2
	la $a0,str2
	jal strlen
	move $s2 ,$s0

	#compares length of two strings
	bne  $s1,$s2,exit_false
 	
	la $a0,str1	#Pass str1 as argument of function 
	jal function 
	
	la $a0,str2
	jal function 	#Pass str2 as argument of function
	
	j strcmp 

	#Function to measure length of str 
	strlen:	 	
	 	li $s0 ,0 
	
	loop:
		add $t1,$s0,$a0 #$t1 = &str[i] (i = metritis)	
		lbu $t2, 0($t1) #$t2 = str[i]
		beq $t2 ,$zero ,exit_strlen #exits if str[i]==0 	
 		addi $s0,$s0,1
 		j loop
 	
 	exit_strlen: 
 		addi $s0,$s0,-1	
 		jr $ra  #telos synartisis 
	


	
function:
	li $t1,0 
		
	for1:
		move $t2,$t1		#j = i
		bge $t1,$s1,endfor 
	
	for2:
		add $t3,$t1,$a0  	
		lb $s3,0($t3)		#$s3 = str[i]
	
		add $t4,$t2,$a0
		lb $s4,0($t4)		#$s4 = str[j]
		bgt  $s4,$s3,else 
		
		#swap
		move  $s0,$s3		#temp = str[i]
		sb $s4 ,0($t3)		#str[i] = str[j]
		sb $s0 ,0($t4)		#str[j] = temp
	
	else:
		addi $t2,$t2,1
		bge $s1,$t2,for2
		addi $t1,$t1,1
		j for1
	endfor:	
		jr $ra 
	
	
	
strcmp:
	li $t0,0			#counter
	la $a0,str1			
	la $a1,str2
	
	loop_cmp:
		add $t4,$t0,$a0
		add $t5,$t0,$a1
	
		lb $s4,0($t4)		#str1[i] = $s4
		lb $s5,0($t5)		#str2[i] = $s5
	
		bne $s4,$s5,exit_false  #Exits if str1[i] != str2[i]
		beq $t0,$s1,exit_true	#Exits if i = strlen
		addi $t0,$t0,1
	j loop_cmp
	
	
exit_false:
	#Prints 0
	li $v0,4
	la $a0,msg_false
	syscall 
	
	#Program end
	li $v0,10 
	syscall 

exit_true:
	#Prints 1
	li $v0,4
	la $a0,msg_true 
	syscall 
	
	#Program end
	li $v0,10 
	syscall 	
 	
	
	
	
	
	
	

