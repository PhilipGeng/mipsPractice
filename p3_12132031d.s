#  This is a program to compute the Fibonacci sequence
#  Showing the use of stack in recursive function
#  In addition, how to structure the recursive function 
#  with the assembly language
	.data
prompt1: .asciiz "Enter a number: "
prompt2: .asciiz "Sequence 1: "
prompt3: .asciiz "Sequence 2: "
prompt4: .asciiz "please input a positive one!!!!!!!!!"
com: .asciiz" , "
nl: .asciiz "\n"

         	.text
        	.globl  main
main:
      	li     $v0,4  	                 #   print string service
     	la     $a0,prompt1       #   get address of prompt1
     	syscall
#read integer
readinteger:
	li     $v0,5   	#   read user input (positive integer)
	syscall                          #   $v0 gets the integer
	blt $v0,0,inputpositive
	move  $t0,$v0	#    store a copy in $t0
                  
#prepare for recursive function call
	addi $a0,$t0,0	#move t0 to a0 for function call
#build another stack to save result
	addi $t2,$sp,0	#save the initial sp
	addi $t3,$t2,8	#add sp by 8 to store the result
	addi $t2,$t3,0	#t2=t3 at first, finally t3 stores the 0,t2 stores 				#biggest

	sw $0,($t3)                 #t3=0
	
	jal     fibrecur
	addi $t2,$t2,4	#store the final result in result stack
	sw   $v0,($t2)

                  addi   $t4,$t3,0	#store a copy of t3
			#pring sequence 1	
#prompt for sequence 1
	la    $a0,prompt2
	li     $v0,4
	syscall 
pl1:
                  lw $a0,($t4)	# load number in result stack from little ones
                  li   $v0,1
                  syscall
                  addi $t4,$t4,4
                  la $a0,com
                  li  $v0,4
                  syscall
                  ble   $t4,$t2,pl1	# if not reach top, go ahead

     	addi   $t4,$t2,0	#store a copy of t2
# newline
                  la    $a0,nl
	li    $v0,4
	syscall
#prompt for sequence 2
	la    $a0,prompt3
	li     $v0,4
	syscall 
pl2:
     	lw $a0,($t4)	# load number in result stack from big ones
                  li   $v0,1
                  syscall
                  addi $t4,$t4,-4
                  la $a0,com
                  li  $v0,4
                  syscall
                  bge   $t4,$t3,pl2	# if not reach bottom, go ahead

#exit program:
	li  $v0,10
	syscall

#fib subroutine
fibrecur:	
	sub    $sp,$sp,4
	sw     $ra,($sp)	#push $ra
	sub    $sp,$sp,4
	sw     $s0,($sp)	#save position value
	sub    $sp,$sp,4
	sw     $s1,($sp)	#save a temp value of fib(n),save fib(n-1),what we 				#need
	
	move $s0,$a0	#s0=a0 get position
	li        $t1,1	# get 1
	beq    $s0,$zero,fib0	# if 0	
	beq    $s0,$t1,fib1	# if 1
	
	sub    $a0,$s0,1	#n-1
	jal fibrecur		#get fib(n-1)
	move $s1,$v0	#store temp result (fib(n-1)) into $s1

	lw      $s2,($t2)            #load the largest number in fib result stack
	bge   $s1,$s2,store      # if the new number is larger, store it
back:	
	sub    $a0,$s0,2	#n-2
	jal fibrecur		#get fib(n-2)
	add    $v0,$s1,$v0	#get value of fib(n-1)+fib(n-2)

	
	
epilog:
#Return value is already in $v0
	lw      $s1,($sp)
	addi    $sp,$sp,4
	lw      $s0,($sp)
	addi    $sp,$sp,4
	lw      $ra,($sp)
	addi    $sp,$sp,4
	jr        $ra
fib0:
	li        $v0,0	#return 0
	j         epilog	#calculate +0
fib1:
	li        $v0,1	#return 1
	j         epilog	# calculate +1

store:
	addi $t2,$t2,4	#store a new number in result stack
	sw   $s1,($t2)
	j back
inputpositive:
	la $a0,prompt4
	li $v0,4
	syscall
	j main
#end

