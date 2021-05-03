
.data
uncompressed: .word
12, -23, 0, 3, 0, 0, 0, 2, 0, 0, 0, 0, 0, -22, 0, 0,
0, 0, 1, 0, 0, 0, -10, 11, -100, 0, 0, 0, 0, 34, 0, 5, -1, 0, 0, 0, 0, 0, 0, 5, 0, 0, 0, 0, 0, 0, 0, -2,
0, 0, 0, 0, 0, 0, 0, 0, 9, 0, 0, 0, 0, 0, 0, 0, 0X111B

compressed :.space 800

msg1:
	.asciiz "("
 msg2: 
 	.asciiz ","
msg3: 
	.asciiz  ")"
	

.macro print(%x,%y)
	

	.text 
	
	li $v0,4 
	la $a0 ,msg1
	syscall 
	
	li $v0,1 
	move $a0,%x
	syscall 
	   
	li $v0,4 
	la $a0 ,msg2
	syscall 
	
	li $v0,1 
	move $a0,%y
	syscall

	li $v0,4 
	la $a0 ,msg3
	syscall 
	
.end_macro 
	
	.text
	.globl main 
	
main:
	la $a0 ,uncompressed 		#$a0 adress of uncompressed(initial) array
	la $a1 ,compressed 		#$a1 adress of compressed(new) array


	jal function 

	#end of program	
	li $v0,10 
	syscall
	
	
	
function :

	 #initialization of reg
	 li $t0,0	
	 li $t1,0
	 li $t2,0
	 li $t4,0
	 li $s3 ,0x111b		#s3 = last object
	 
	 addi $t1,$a0,0		#pass argument for uncompressed to $t1
	 addi $t4,$a1,0		#pass argument for compressed to $t4
	 
#Loop to read the uncompressed	 
loop:
	
	 lw $s0,0($t1)	
	 addi $t1,$t1,4 
 
	 bnez $s0,exit1 
	 addi $t2,$t2,1 
	 
	 j loop 
	 
#when reading is done,  proceeds to the compression 
exit1:	


	sw $t2 ,0($t4)
	addi $t4,$t4,4
	sw $s0 , 0($t4)
	addi $t4,$t4,4
	beq $s3,$s0,exit2 
	li $t2,0
	j loop  

exit2:
	addi $t4,$a1,0
	loop2:
		lw $s1,0($t4)
		addi $t4,$t4,4
	 	lw $s2,0($t4)
	 	addi $t4,$t4,4
	 	beq $s2,$s3,exit3
	 	print($s1,$s2)
	 	
	 	j loop2
	 	
#outputs (_,0x111b)	 	
exit3:
	li $v0,4 
	la $a0 ,msg1
	syscall 
	
	li $v0,1 
	move $a0,$s1
	syscall 
	   
	li $v0,4 
	la $a0 ,msg2
	syscall 
	
	li $v0,34		#prin hex (for 0x111b)
	move $a0,$s2
	syscall

	li $v0,4 
	la $a0 ,msg3
	syscall 
	
	jr $ra
