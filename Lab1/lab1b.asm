.data 
.align 2 

str :.space 800
str_new:.space 800
.macro print_str (%str)
	.data
my_str: .asciiz %str
	.text
	li $v0, 4
	la $a0, my_str
	syscall
	.end_macro
.text	
.globl main 
main :

	print_str("Please define the dimensions:\n")

	li $v0,5 
	syscall 
	move $s0,$v0		#read the  size of the matrix (N)

	mul $a2,$s0,$s0 	# n = n^2 
	print_str("Now you have to fill the matrix:\n")

	jal read_matrix
	jal matrix_copy

	move $a1,$s0 		#$a1 = N
	jal sub_matrix
	jal print_matrix
	
	#Program end
	li $v0,10 
	syscall



read_matrix:

	li $t0,0		# counter
	
loop:
	bge $t0,$a2,endfill
	print_str("please give an integer:")
	
	li $v0,5 		#Reads int
	syscall 
	
	sw $v0,str($t1)		#str[i] = $v0
	
	addi $t0,$t0,1		#counter++
	sll $t1,$t0,2 		#$t1 = 4*i
	j loop 
	
	
endfill:
	jr $ra
###########################
sub_matrix:
	addi $sp,$sp,-4
	sw $ra ,0($sp)
	
	print_str("\nPlease define the dimensions of the sub matrix:")
	li $v0,5		#reads M
	syscall
	
	move $s0,$v0 		#$s0 = dimension of sub matrix (M)
	
	print_str("\nPlease define the ledt distance:")
	li $v0,5		
	syscall
	
	move $s1,$v0		#$s1 =left distance
	
	print_str("\nPlease define the upper distance:")
	li $v0,5
	syscall
	
	move $s2,$v0 #$s2 = upper distance 
	
	li $t0,0 

	sll $t0,$a1,2		#a1 = (N)
	mul $t0,$t0,$s2 	#4*upper*N
	sll $t1 ,$s1,2 		#$t1 = left*4 
	add $t0 ,$t1,$t0 	#Finds first element of submatrix ($t0)
	
	move $s3,$t0 		# o $s3 = #$t0
	
	li $t0,0
	li $t1,0
	li $t2,0
	li $t3,0
	li $t4,0
	fori:
		bge $t0,$s0,end_sub #exits when i>=M
		li $t1,0	    #j = 0
		
	forj:
		jal change_value
	
		addi $t1,$t1,1 
		addi $s3,$s3,4 	    #+4 from each element of M
		bgt $s0,$t1,forj	
		sub $t3,$a1,$s0	    # $t3 = N-M
		sll $t3,$t3,2 	    #$t3 = 4*(n-m-1)
		add $s3,$s3,$t3	    #finds first element of next row
		addi $t0,$t0,1
		j fori
	 
	 	 
end_sub:	 
	lw $ra ,0($sp)		    #restore initial ra of submatrix		
	addi $sp,$sp,4		    #restore stack space
	jr $ra
	
#Fuction that prints  str_new
print_matrix: 
		li $t0,0
		li $t2,0
	for1:
		bge $t0,$a1,end_print	#$a1 = N
		li $t1,0
		print_str("\n")
	
	for2:
		lw $t3,str_new($t2)	#$t3 = str_new[i] 
		
		move $a0,$t3
		li $v0,1
		syscall
		
		print_str(" ")
		addi $t1,$t1,1
		addi $t2,$t2,4
		bgt $a1,$t1,for2
		addi $t0,$t0,1 
		j for1

end_print:
	jr $ra

#Function that changes the value of an element of submatrix		
change_value:

	addi $sp,$sp,-16
	
	sw $t3 ,12($sp)
	sw $t2 ,8($sp)
	sw $t1 ,4($sp)
	sw $t0 ,0($sp)
	
	move $t0,$s3 		# $t0 = address of element to be changed
	lw $t3 , str($t0)	# $t3 = a[i][j]
	sll $t1,$t3,2 		# $t1 = 4*a[i][j]
	addi $t0,$t0,-4 	# &a[i][j-1]
	lw $t2,str($t0) 	# $t2  = a[i][j-1]
	add $t1,$t2,$t1 	# $t1 = a[i][j-1] + 4 * a[i][j]
	move $t0,$s3 		# $t0 = address of element to be changed
	addi $t0,$t0,+4 	# &a[i][j+1]
	lw $t2 ,str($t0)	# $t2  = a[i][j+1]
	add $t1,$t2,$t1 	# $t1 = a[i][j-1] + 4 * a[i][j] + a[i][j+1]
	move $t0,$s3 		# $t0 = address of element to be changed
	sll $t2,$a1,2		# $t2 = 4 *N
	sub $t0 , $t0, $t2 	# &a[i-1][j]
	lw $t2 , str ($t0)      # $t2 = a[i-1][j]
	add $t1,$t2,$t1 	# $t1 = a[i][j-1] + 4 * a[i][j] + a[i][j+1] +a[i-1][j]
	move $t0,$s3 		#  $t0 = address of element to be changed
	sll $t2,$a1,2		# $t2 = 4 *N
	add $t0 , $t0, $t2 
	lw $t2 , str ($t0)	# $t2 = a[i+1][j]
	add $t1,$t2,$t1 	# $t1 = a[i][j-1] + 4 * a[i][j] + a[i][j+1] +a[i-1][j]  + a[i+1][j]
	
	div $t1,$t1,8		# $t1/8
	sw $t1 ,str_new($s3)	#str_new[] = new_Result
	
	lw $t0 ,0($sp)		
	lw $t1 ,4($sp) 
	lw $t2 ,8($sp)
	lw $t3 ,12($sp)
	
	addi $sp,$sp,16
	jr $ra
	
		
matrix_copy :
	li $t0,0 
	li $t1,0
	
	loop_copy:
		bge $t0,$a2,endcopy
		sll $t1,$t0,2 
		lw $t2,str($t1)
		sw $t2,str_new($t1)
	
		addi $t0,$t0,1 
		j loop_copy	
	endcopy:
 		jr $ra 
