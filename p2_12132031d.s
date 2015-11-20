# The program is doing convertion among different numbering systems.

        .data

inputprompt:  .asciiz "Enter a base (2 to 16) for input: "
input: 	  .asciiz "Enter the value:  "
outputprompt:	.asciiz "Enter a base (2 to 16) for output:  "
output: .asciiz"The result is: "
newL:   .asciiz "\n"
result:  .space 32
empty: .asciiz "                                                                    "
number: .space 32

        .text
        .globl main
main:
#Ask for base of input and then store it to $t0
         la $a0,inputprompt		
         li $v0, 4			#Make system call to print string
         syscall

         li $v0, 5		#Make system call to get input of integer
         syscall
         move $t0, $v0			#Store the input base in $t0

#Ask for input and then store it to $t1
         la $a0,input		
         li $v0, 4			#Make system call to print string
         syscall

         li $v0, 8		#Make system call to get input of integer
         la $a0,number
         syscall
         move $t1, $a0			#Store the input in $t1

#Get the length of the input
         addi $t9,$0,-1			#the length of the input
         move $s5,$t1			#copy address of the input in $s5
loop: 
         lb $s6,1($s5)			#read the next digit to test
         addi $s5,$s5,1			#address++
         addi $t9,$t9,1			#length++
         bne $s6,$0,loop			#if digit not null,continue to loop

 #print a new line
         la $a0,newL		
         li $v0, 4			#Make system call to print string
         syscall

         li $v0, 5			#Make system call to get input of 
#Ask for output base and then store it to $t2
         la $a0,outputprompt		
         li $v0, 4			#Make system call to print string
         syscall

         li $v0, 5			#Make system call to get input of integer
         syscall
         move $t2, $v0			#Store the output base in $t2
    
          

#Print " result: "
         la $a0,output		
         li $v0, 4			#Make system call to print string
         syscall
        
         addi $s7,$0,0			#s7 stands for the stack to store $ra
         jal convert
print:
          la $a0,result		       	#print the result
          addi $a0,$a0,32
          sub $a0,$a0,$s4
          move $a1,$s4
          li $v0, 4
          syscall

          li $v0,10
          syscall

# main part for convertion
convert:
         addi $t3,$0,0		# result is in t3
         li $t4,1		#just have a register load 1
         li $t5,60                        	#for ascii table, >60 is char      
         li $t6,48		#for number, char-48 to get the number
         li $t7,55		#for char,-55 to get the number
         sub $t8,$t9,1
         add $t1,$t1,$t8		# go to the last significant digit of input and start
         addi $s0,$0,0		# for reading every digit, s0 as a counter = 0    
         jal todecimal
         jal toresult         
         j print
todecimal:
         subu $sp,$sp,4		#stack pust
         sw $ra,($sp)		
         addi $s4,$0,0		#s4 is the result for current digit
         addi $s1,$0,0		#initialize inner loop counter as 0
         addi $s3,$0,1		#initialize exponent as 1
         addi $s2,$0,0
getexpo:
         beq  $s1,$s0,finishexpo	#if inner loop counter = outerloop
         mult $s3,$t0		# exponent
         mflo $s3		#s3 store the temp exponent
         addi $s1,$s1,1		# increase the inner loop counter
         j getexpo
finishexpo:         	
         lb $s2,0($t1)		#least significant digit haven't been converted 
         blt $s2,$t6,ifnull		#if the least significant digit has nothing(null)
         bgt  $s2,$t5,char         	#if is char (ascii>60),branch
         sub $s2,$s2,$t6		#if is a number,-48
         j afterchar
char:
         sub $s2,$s2,$t7		#if is char, -55
  afterchar:
         mult $s2,$s3		# mult the digit with exponent
         mflo $s4		#save the result in s4
         add  $t3,$s4,$t3		#add the result for current loop in $t3
ifnull:
         sub $t1,$t1,$t4		#t1-1,read the next digit in next cycle
         addi $s0,$s0,1		# increase outerloop counter by 1
         bne $s0,$t9,todecimal
          lw $ra,($sp)
          addu $sp,$sp,4  
          j $ra
toresult:
         subu $sp,$sp,4		#stack pust
         sw $ra,($sp)		    
         la $s0,result		#load the address of result into s0
         li $s1,10		#load the divisor 10 to s1
         addi $s0,$s0,32		#set the to-be-processed digit to the last digit+1 
         addi $s4,$0,0		#counter++
dodivide:
          addi $s4,$s4,1		#counter++
          sub $s0,$s0,$t4		#s0--
          div  $t3,$t2		#decimal result/output base
          mfhi $s2		#remainder
          mflo $t3		#quotient store in t3
          bge $s2,$s1,tochar	#if the remainder>10,jump to tochar
          addi $s2,$s2,48		#if it is number, add 48 to get ascii
          j afterdone          
tochar:
          addi $s2,$s2,55		# if it is char , add 55 to get ascii      
afterdone:
          sb $s2,0($s0)		# save it into result
          bne $t3,$0,dodivide  	# if quotient(t3)!=0, continue to divide
          lw $ra,($sp)
          addu $sp,$sp,4  
          j $ra