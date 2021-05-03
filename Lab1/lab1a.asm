.text 
.globl main 
 main:
 	li $s0, 0x00112233
 	li $t0, 0x1023B818
 	
 	li $t1, 7
 	li $t3, 0x000000FF
 	li $t4, 0x00008000
 	li $t5, 0x00000100
 	
 	#Krataei ta 2 MSByte tou $s0
 	srl $s0,$s0,16
 	sll $s0,$s0,16
 	#Krataei t0 LSByte tou $t0
 	sll $t2,$t0,24
 	srl $t2,$t2,24
 	and $t2,$t2,$t3		# $t3 & $t2
 	
 	#bitflip
 loop:
 	 and $t3,$t4,$t0	
 	 srlv $s3,$t3,$t1
 	 
 	 and $t6,$t5,$t0 
 	 sllv $s6,$t6,$t1
 	 
 	 or $s0,$s0,$s6		# $s6 | $s0
 	 or $s0,$s0,$s3 			 
 	 addi $t1,$t1,-2
 	 sll $t5,$t5,1
 	 srl $t4,$t4,1
 	 bgtz $t1,loop	
 	 
 	 
 	 or $s0,$s0,$t2
 	 li $v0 , 34
 	 move $a0 , $s0
 	 syscall
 	 
 	 #Program end
 	 li $v0,10
 	 syscall
