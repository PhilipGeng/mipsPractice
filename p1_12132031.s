# by Xu Geng    SID:12132031d
# for Comp 2421 programming assignment 1

.data
prompt: .asciiz "Select a base (2,4,8 or 16) for ouput, input 0 to exit : "
sec: .asciiz "please enter an integer: "

binans: .asciiz " bin: "
quaans: .asciiz" qua: "
octans: .asciiz" oct: "
hexans: .asciiz" hex: "
newl: .asciiz"\n"
 
binary: .space 32
d: .asciiz"                                                                                      "
qua: .space 16
a: .asciiz"                                                                                       "
oct: .space 11
bs: .asciiz"                                                                                        "
hex: .space 8
c: .asciiz"                                                                                          "

.text
 
.globl main

main:

#print a new line when a new input and convertion starts
la $a0,newl
li $v0,4
syscall

#print a line to ask for user input of base
la $a0,prompt
li $v0,4
syscall

#input the base and store in $t8
li $v0,5
syscall
move $t8,$v0

#if the integer==0, exit
beq $t8,$zero,Exit

#print a line to ask for user's input of integer
la $a0,sec
li $v0,4
syscall

#input and store integer in $t0
li $v0,5
syscall
move $t0,$v0

#select loop corresponding to the base
li $t7,2
li $t6,4
li $t5,8
li $t4,16
beq $t8,$t7,binLoop   #if base = 2, enter binary loop
beq $t8,$t6,quaLoop  # similar as above
beq $t8,$t5,octLoop
beq $t8,$t4,hexLoop

#binary loop entrance
binLoop:
la $a0,binans                # print to show that this is a binary number
li $v0,4
syscall

li $t1,32                      # $t1 is counter, binloop should loop 32 times
la $t2,binary               #load address of the binary (this is where the result stores)

Generatebin:
beqz $t1,binPrint      #if counter is 0, means the loop should be terminated      
rol $t0,$t0,1               #rotate to get the leftmost of the number
and $t3,$t0,1             #to test if the number is 0 or 1, the result is stored in $t3
addi $t3,$t3,48          # add 48 to get the ascii code of 0 or 1

sb $t3,0($t2)             # save the ascii code to the result
addi $t1,$t1,-1          #counter  --
addi $t2,$t2,1           #the address of the result expanded by 1 to next byte to store next                                  #bit
j Generatebin           #go back to the loop

binPrint:
la $a0,binary              #this three lines print the result when the loop stops
li $v0,4
syscall
j main                       # jump back to main to start another input

octLoop:                  # octloop is to get the number when base = 8,similar to binloop
la $a0,octans            # oct loop should run one extra time for the starting 2 bits
li $v0,4                     # because to convert a bin to oct, you need to read 3 bits by 3 bits
syscall                      #  there will be 2 bits remain in the front 

li $t1,10                  #  set counter to 10, the extra loop is not included
la $t2,oct                #load address of result

rol $t0,$t0,2           # this is the extra loop. Firstly get the first 2 bits
and $t3,$t0,3         # use an and operation to get the 2 bits
addi $t3,$t3,48      # add 48 to get the ascii code for num 0-7

sb $t3,0($t2)         #store it in result
addi $t2,$t2,1       # address of result expanded
Generateoct:
beqz $t1,octPrint             #if counter = 0, print the result
rol $t0,$t0,3                     # in the 10 times loop, read every 3 bits from left
and $t3,$t0,7                   # use and operation to get the value, need to and 111(7 in                                         # decimal)
addi $t3,$t3,48                # get the ascii code

sb $t3,0($t2)                   # save to result
addi $t1,$t1,-1               #counter --
addi $t2,$t2,1                 # address of result expand
j Generateoct                 # go back to loop 

octPrint:                        #print the result
la $a0,oct
li $v0,4
syscall
j main                             # start another new input

quaLoop:                       # this is to get the number when base = 4
la $a0,quaans                # print a line to indicate this is a base = 4 number 
li $v0,4
syscall

li $t1,16                       # read every 2 bits a time to get a qua number,counter = 16
la $t2,qua                     # load address of result

Generatequa:
beqz $t1,quaPrint        # when counter = 0, print the number
rol $t0,$t0,2                 # get the leftmost 2 bits
and $t3,$t0,3               # get the value of the 2 bits using and operation 
addi $t3,$t3,48            # get the ascii code of the 2 bits

sb $t3,0($t2)                # save the ascii value into result
addi $t1,$t1,-1            # counter --
addi $t2,$t2,1             # expand the address of the result, save next value to next byte
j Generatequa            # go back to loop

quaPrint:                    # print qua result
la $a0,qua
li $v0,4
syscall
j main                         # go back to main to start new input

hexLoop:                    # give numbers when base = 16
la $a0,hexans
li $v0,4
syscall

li $t1,8                        # get hex value from every 4 bits, counter = 8
la $t2,hex                    # load address of result

Generatehex:           
beqz $t1,hexPrint       # if counter = 0, break
rol $t0,$t0,4	# get the leftmost 4 bits
and $t3,$t0,15            #use and operation(and 15) to get the value of the 4 bits  
ble $t3,9,num             # if the value <= 9, means it is a number, jump to num
addi $t3,$t3,55           # this is the condition of value >9, means it is among ABCDEF 
		# shoould add 55 to get the ascii code value
j hexnext                     
num:
addi $t3,$t3,48           # for number , add 48 to get ascii code value
hexnext:             
sb $t3,0($t2)              # save whether the number of char(ABCDEF) to the result
addi $t1,$t1,-1           # counter --
addi $t2,$t2,1             # address of result go to next byte
j Generatehex

hexPrint:		# print out the hex result
la $a0,hex
li $v0,4
syscall

j main                       # go back to main to start a new input

Exit:                         # exit the program
la $v0,10
syscall

