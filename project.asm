
# Mahmoud Khatib 1200275
# Razi Atyani 1200028


.data
matrix:              .space 1500     # Assuming a 10x31 matrix, each cell is initialized with 'n'      
filename:            .asciiz  "calender.txt"
output:               .asciiz "calender.txt"
buffer:              .space   1000      # Buffer to store the read data
line:                .space   1024
newline:             .asciiz  "\n" 
separator:           .asciiz  ": "  # Separator to print between parts
buffer1:             .space 10
dash:    .asciiz "-"
colon:  .asciiz ":"
q:.asciiz","
space:   .asciiz " "    # ASCII representation of a space character

num1:   .word   0       # memory location to store the first number
num2:   .word   0       # memory location to store the second number

delimiter:      .asciiz " "
chars_to_find:  .asciiz "MLH"
error_msg1:   .asciiz "Error: Unable to open the file\n"
error: .asciiz "invalid Input"
menu_msg:    .asciiz "\nMenu:\n1. View the Calendar\n2. View Statistics \n3. Add a new appointment\n4. Delete an appointment\n5. Exit\nEnter your choice: "
invalid_msg: .asciiz "pleasr enter a correct input\n"

output_char: .asciiz "o"
tab: .asciiz "\t"

time_slots: .asciiz "8\t9\t10\t11\t12\t1\t2\t3\t4\t5\n"
hyphen_line: .asciiz "\n-------------------------------\n"

semi_column: .asciiz ":"
new_line: .asciiz "\n"
day_string: .asciiz "day "
decimal_point: .asciiz "."

num_of_days_prompt: .asciiz "please enter number of days\n"
view_calender_menu: .asciiz "\n1. view per day\n2. view per set of days\n3. view for a slot in a given day\nYour choice: "
enter_day_prompt: .asciiz "\nplease enter the day you wish to view: "
view_calender_prompt_2: .asciiz "please enter the number of days: "
view_calender_prompt_3: .asciiz "please enter the day you wish to view: "

wrong_slot: .asciiz"there is conflict in this slot "

add_appointment:.asciiz "please enter the day to add appointment"
del_appointment: .asciiz "\nplease enter the day to delete appointment from: "
startTime: .asciiz  " Enter the Start Time\n "  
endTime: .asciiz  " Enter the End Time\n "
type:.asciiz"what type of appointment do you want to store"
del_type: .asciiz "\nWhat type of appointment do you want to delete (L, H, M):"

view_stats_msg: .asciiz "Lectures\tOffice Hours\tMeetings\n"
lect_oh_msg: .asciiz "\nRatio between lectures and office hours: "
avg_lec_msg: .asciiz "\nAverage lectures per day: "

lecture_symbol: .byte 'L'
office_symbol: .byte 'H'
meetings_symbol: .byte 'M'


.text
# <============================================= Main =============================================>

main:
	li $t0, 0          # Initialize row index
fill_loop:
	bge $t0, 31, here  # Exit loop if row index >= 31
    
	li $t1, 0          # Initialize column index
col_loop_fill:
	bge $t1, 10, next_row_fill  # Exit inner loop if column index >= 10
    
    # Calculate the index in the matrix (assuming 32-bit integers)
	mul $t2, $t0, 10    # Multiply row index by the number of columns
	add $t2, $t2, $t1   # Add column index to get the overall index
	mul $t2, $t2, 1

    # Now, you can use the matrix address + offset to access elements
	la $t3, matrix      # Load the base address of the matrix
	add $t3, $t3, $t2   # Add the offset to get the address of the current element

    # Store a value in the matrix
	li $t4, 110         # The value to store in the matrix element
	sb $t4, 0($t3)      # Store the value at the calculated address

    # Increment column index and repeat inner loop
	addi $t1, $t1, 1
	j col_loop_fill

next_row_fill:
    # Increment row index and repeat outer loop
	addi $t0, $t0, 1
	j fill_loop

here:
	jal read_file_store
                                                                                    
# ----------------------------------------------- End Main -------------------------------------------

                                                                                                                                                          
menu:   
# <=============================================== Menu ===============================================>

	# Display the menu 
	la $a0, menu_msg    # Load the address of the menu_msg into $a0
   	li $v0, 4           # System call for print_str
    	syscall

    	# Get user input
    	li $v0, 5           # System call for read_int
    	syscall
    	move $t0, $v0       # Save the user input in $t0

    	# Process user input
    	beq $t0, 1, View_the_Calendar   # Branch to View_the_Calendar if the user entered 1
    	beq $t0, 2, View_Statistics  # Branch to View_Statistics if the user entered 2
    	beq $t0, 3, Add  # Branch to Add if the user entered 3
    	beq $t0, 4, delete   # Branch to delete if the user entered 4
    	beq $t0, 5, exit     # Branch to exit if the user entered 5

    	# Invalid input, display an error message
    	li $v0, 4           # System call for print_str
    	la $a0, error   # Load the address of the error_msg into $a0
    	syscall
    	j main              # Jump back to the main loop

# ----------------------------------------------- End Menu --------------------------------------------------


# <============================================ View Calender ===============================================>
View_the_Calendar:
	li $t4, 0 # t4 = numOfDays

	li $v0, 4
	la $a0, view_calender_menu
	syscall
	
	# take user input
	li $v0, 5
	syscall
	
	move $t5, $v0 # t5 = user input
	
	# print the prompt for the chosen option
	li $v0, 4
	
	# if t5 == 1: print prmot 1, elseif t5 == 2: print prompt 2, else: print prompt 3
	beq $t5, 1, prompt_1
	beq $t5, 2, prompt_2
	beq $t5, 3, prompt_3
	
	jal wrong_input
	j View_the_Calendar

prompt_1:
	li $t4, 1 # t4 = number of loops = 1
	j for_each_day
prompt_2:
	la $a0, view_calender_prompt_2
	syscall
	
	# take user input
	li $v0, 5
	syscall

	move $t4, $v0 	# t4 = number of days
	j for_each_day
	
prompt_3:
	la $a0, view_calender_prompt_3
	li $v0 ,4
	syscall
	li $v0,5
	syscall
	move $t1 ,$v0
	bgt $t1,31,wrong_input1
	blt $t1,1,wrong_input1
	la $a0, startTime
	li $v0 ,4
	syscall
	
	li $v0,5
	syscall
	
	move $t2 ,$v0
	bgt $t2,12,wrong_input1
	blt $t2,1,wrong_input1
	beq $t2 ,6,wrong_input1
	beq $t2 ,7,wrong_input1
	blt $t2 ,8 ,add121
         
s:     
	la $a0, endTime
	li $v0 ,4
	syscall
	      
	li $v0,5
	syscall
	move $t3 ,$v0
	bgt $t3,12,wrong_input1
	blt $t3,1,wrong_input1
	beq $t3 ,6,wrong_input1
	beq $t3 ,7,wrong_input1
	blt $t3 ,8 ,add122

slot:  
	bgt $t2 ,$t3, wrong_input1

	move $s2 ,$t2
	move $s3,$t3

	li $v0, 4
	la $a0, hyphen_line
	syscall
	# print day number
	li $v0, 1	
	move $a0, $t1
	syscall
	subi $t1,$t1,1
	# print semi-column
	li $v0, 4
	la $a0, semi_column
	syscall
	# print new line
	la $a0, new_line
	syscall
loop5:
	bgt $s2 ,$s3 ,loopEnd
	move $a0 ,$s2
	li $v0,1
	syscall
	addi $s2,$s2,1
	la $a0 ,delimiter
	li $v0,4
	syscall
	b loop5
loopEnd:         # print new line
	la $a0, new_line
	syscall
	
	la $t4, matrix           # Load the base address of the matrix
	mul $t5, $t1, 10         # Assuming 10 columns in each row, use $t9 for calculation
	subi $t2 $t2 ,8
	subi $t3 $t3 , 8
	add $t5, $t5, $t2
	add $t4, $t4 ,$t5
    
slotDay: 
	bgt $t2, $t3, endLoop  # Exit loop if start time >= end time

    # Calculate the memory address for the current row and column
  
	lb $a0, 0($t4)  # Store the character in the current cell
	li $v0 ,11
	syscall 
	la $a0 ,delimiter
	li $v0,4
	syscall        

    # Increment column index
	addi $t2, $t2, 1
	addi $t4,$t4 ,1

    # Repeat the loop
	j slotDay

endLoop:
     
	b menu  # Assuming there's a read loop to continue with your program
	
for_each_day:
	# prepare the index to print the correct day
	la $t0, matrix # t0 = array[0][0]
	
	# prompt to ask user for input
	li $v0, 4
	la $a0, enter_day_prompt
	syscall
	
	# ask user for day numebr
	li $v0, 5
	syscall
	
	move $t5, $v0
	
	# separate each day with line
	li $v0, 4
	la $a0, hyphen_line
	syscall
	
	# print the word day
	la $a0, day_string
	syscall
	
	# print day number
	li $v0, 1	
	move $a0, $t5
	syscall
	
	# print semi-column
	li $v0, 4
	la $a0, semi_column
	syscall
	
	# print new line
	la $a0, new_line
	syscall
	
	subi $t5, $t5, 1 # t5 = index of the required day
	mul $t5, $t5, 10
	add $t0, $t0, $t5
	
	jal print_day_info
	subi $t4, $t4, 1
	bgtz $t4 for_each_day
	
	j menu

# <------------------------------------------- End View Calender --------------------------------------------


# <========================================== View Statistics =================================================>
View_Statistics:
	la $t0, matrix
     	li $t1, 0 # num Of Lectures
     	li $t2, 0 # num of office hours
     	li $t3, 0 # num of meetings
     	li $t4, 0 # num of days
     	li $t5, 0 # count
     	li $t6, 0 # buffer
     	li $t7, 0 # total cells discovered
     	
     	li $s0, 0
     	li $s1, 0
     	li $s2, 0
     	
     	lb $s0, lecture_symbol
     	lb $s1, office_symbol
     	lb $s2, meetings_symbol
     	
     	# prev result
     	li $t8, 0
     	lb $t8, ($t0)
     	

for_all_days_stats:  	
	lb $t6, ($t0) # current value
	jal compare_and_sub
	
     	beq $t6, $s0, if_lecture
     	beq $t6, $s1, if_officeHours
     	beq $t6, $s2, if_meetings
     	j finish_slot
     	
if_lecture:
	addi $t1, $t1, 1
	j finish_slot
if_officeHours:
	addi $t2, $t2, 1
	j finish_slot
if_meetings:
	addi $t3, $t3, 1
	j finish_slot

finish_slot:	
	addi $t5, $t5, 1 # inc count
	addi $t0, $t0, 1 # inc matrix index
	addi $t7, $t7, 1 # inc number of cells discovered
	move $t8, $t6
	
	blt $t5, 10, for_all_days_stats
	
	
	# new day reached
	li $t5, 0 
	addi $t4, $t4, 1 # inc num of days
	
	li $t6, 0
	jal compare_and_sub
	
	li $t8, 0
	lb $t8, ($t0)
	
	blt $t7, 310, for_all_days_stats
	
# end of loop
	# print the results
	li $v0, 4
	la $a0, view_stats_msg
	syscall
	
	# print lectures
	li $v0, 1 
	move $a0, $t1 
	syscall
	
	# print tab
	li $v0, 4
	la $a0, tab
	syscall
	
	# print office hours
	li $v0, 1
	move $a0, $t2
	syscall
	
	# print tab
	li $v0, 4
	la $a0, tab
	syscall
	
	# print meetings
	li $v0, 1
	move $a0, $t3
	syscall
	
	# print num of days
	li $v0, 4
	la $a0, new_line
	syscall
	
	li $v0, 1
	move $a0, $t4
	syscall
	
	# print lec to oh ratio
	li $v0, 4
	la $a0, lect_oh_msg
	syscall
	
	# Convert $t1 to float in $f1
	mtc1 $t1, $f1         # Move $t1 to floating-point register $f1
	cvt.s.w $f1, $f1      # Convert integer to float in $f1

	# Convert $t2 to float in $f2
	mtc1 $t2, $f2         # Move $t2 to floating-point register $f2
	cvt.s.w $f2, $f2      # Convert integer to float in $f2

	# Divide $f1 by $f2
	div.s $f3, $f1, $f2   # Perform floating-point division and store result in $f3
	
	# Print the result as a floating-point number
	li $v0, 2              # syscall code for printing a float
	mov.s $f12, $f3        # Move the result to $f12
	syscall

	# Print newline
	li $v0, 4
	la $a0, newline
	syscall
	
	la $a0, avg_lec_msg
	syscall
	
	li $t9, 31
	mtc1 $t9, $f9
	cvt.s.w $f9, $f9
	
	div.s $f12, $f1, $f9
	li $v0, 2
	syscall

	# Return to main
	j menu

# --------------------------------------------- End View Statistics ------------------------------------------
	

# =========================================== Add Appointment ===========================================>
Add:
	la $a0, add_appointment
	li $v0 ,4
	syscall
	
	li $v0,5
	syscall
	
	move $t1 ,$v0
	bgt $t1,31,wrong_input2
	blt $t1,1,wrong_input2
	la $a0, startTime
	li $v0 ,4
	syscall
	
	li $v0,5
	syscall
	move $t2 ,$v0
	bgt $t2,12,wrong_input2
	blt $t2,1,wrong_input2
	beq $t2 ,6,wrong_input2
	beq $t2 ,7,wrong_input2
	blt $t2 ,8 ,add123
         
k:
	la $a0, endTime
	li $v0 ,4
	syscall
	      
	li $v0,5
	syscall
	move $t3 ,$v0
	bgt $t3,12,wrong_input2
	blt $t3,1,wrong_input2
	beq $t3 ,6,wrong_input2
	beq $t3 ,7,wrong_input2
	blt $t3 ,8 ,add124
         
adding_app:
	subi $t1,$t1,1
	subi $t2 $t2 ,8
	subi $t3 $t3 , 8  
	mul $t4, $t1, 10            # Assuming each row has 10 elements
	add $t4, $t4, $t2           # $t4 = row index * number of columns + start column

    # Calculate the index of the last element in the specified row and end column
	mul $t7, $t1, 10            # Assuming each row has 10 elements
	add $t7, $t7, $t3           # $t7 = row index * number of columns + end column
 
    # Loop to check each cell in the specified range
loop6:
        # Load the character at the current cell in the matrix
	lb $t5, matrix($t4)

        # Compare the character with 'n'
	li $t6, 'n'

        # Branch to ADD if the characters do not match
        bne $t5, $t6, wrong_slot_add

        # Increment the index to move to the next cell
        addi $t4, $t4, 1

        # Check if we have reached the end column
        bne $t4, $t7, loop6
        
	la $a0,type
	li $v0 ,4
	syscall
	
	li $v0,12
	syscall
	
	move $t8,$v0
	
fill_column_loop4:
	bgt $t2, $t3, loop_end4  # Exit loop if start time >= end time

    # Calculate the memory address for the current row and column
	la $t4, matrix           # Load the base address of the matrix
	mul $t5, $t1, 10         # Assuming 10 columns in each row, use $t9 for calculation
	add $t5, $t5, $t2
	add $t4, $t4, $t5
	sb $t8, 0($t4)  # Store the character in the current cell

    # Increment column index
	addi $t2, $t2, 1

    # Repeat the loop
	j fill_column_loop4

loop_end4:
	b menu

wrong_slot_add:
    # Code for the ADD label goes here
    # This is the code that will be executed if the character is not 'n'
    # You can add any additional logic or operations here
	la $a0, wrong_slot
	li $v0 ,4
	syscall
	
	j Add


# <=========================================== Delete Appointment ===========================================>
delete:
	li $v0, 4           # System call for print_str
	la $a0, del_appointment
	syscall
     
	la $t0, matrix
	li $t1, 0 # day number
	li $t2, 0 # start time
	li $t3, 0 # end time
	li $t4, 0 # type
	li $t9, 1 # prev
	li $s0, 0
	li $s7, 0 # flag for deletion

	# read day
	li $v0, 5
     	syscall
	move $t1, $v0
	bgt $t1,31, wrong_input_del
	blt $t1,1, wrong_input_del
     
	li $v0, 4
	la $a0, startTime
	syscall

read_the_time:
	# read start time
	li $v0, 5
	syscall
	move $t2, $v0
	bgt $t2,12,wrong_input_del_2
        blt $t2,1,wrong_input_del_2
        beq $t2 ,6,wrong_input_del_2
        beq $t2 ,7,wrong_input_del_2
        blt $t2 ,8 ,del_125
        
read_end_time_k:
	li $v0, 4
	la $a0, endTime
	syscall
	
	# read end time
	li $v0, 5
	syscall
	move $t3, $v0
	
	bgt $t3, 12, wrong_input_del_2
        blt $t3, 1, wrong_input_del_2
        beq $t3, 6, wrong_input_del_2
        beq $t3, 7, wrong_input_del_2
        blt $t3, 8, del_126
read_type:
	# read type
	li $v0, 4
	la $a0, del_type
	syscall
	
	li $v0, 12
	syscall
	move $t6, $v0
	
	subi $t1, $t1, 1
	mul $t5, $t1, 10
	add $t0, $t0, $t5
	
	subi $t2, $t2, 8
	subi $t3, $t3, 8
	
	add $t0, $t0, $t2
	sub $t8, $t3, $t2 # number of iterations
	addi $t8, $t8, 1
	
	lb $t9, ($t0)
	li $s0, 'n'

	# Loop to check each cell in the specified range
deleting_loop:
        # Load the character at the current cell in the matrix
        lb $t7, ($t0)
        
        beqz $t8, deleting_end
	bne $t7, $t6, loop_update
	beq $t9, $s0, skip_cond
	bne $t9, $t7, second_cond_del
	j skip_cond
	
second_cond_del:
	bgtz $s7, deleting_end
	
skip_cond:
        sb $s0, ($t0)
        li $s7, 1
loop_update:
        subi $t8, $t8, 1
        addi $t0, $t0, 1
        move $t9, $t7
        
        j deleting_loop
        
deleting_end:
	j menu

# ------------------------------------------ End Delete Appointment ---------------------------------------


# <=========================================== Exit program ===========================================>
exit: 

	# Open file
	li   $v0, 13            # System call code for open file
	la   $a0, output      # Load address of the filename
	li   $a1, 1             # Flag for write access
	li   $a2, 0             # Mode (not used when opening)
	syscall                 # Make the system call

	move $s0, $v0           # Save the file descriptor for later use

	li $t0, 0          # Initialize row index
fill_loop1:
	bge $t0, 31, print_matrix1  # Exit loop if row index >= 31

	li $t1, 0          # Initialize column index
col_loop_fill1:
	bge $t1, 10, next_row_fill1  # Exit inner loop if column index >= 10

    # Calculate the index in the matrix (assuming 32-bit integers)
	mul $t2, $t0, 10    # Multiply row index by the number of columns
	add $t2, $t2, $t1   # Add column index to get the overall index
	mul $t2, $t2, 1    # Multiply by 4 to get the byte offset (assuming 32-bit integers)

    # Now, you can use the matrix address + offset to access elements
	la $t3, matrix      # Load the base address of the matrix
	add $t3, $t3, $t2   # Add the offset to get the address of the current element

    # Increment column index and repeat inner loop
	addi $t1, $t1, 1
	j col_loop_fill1

next_row_fill1:
    # Increment row index and repeat outer loop
	addi $t0, $t0, 1
	j fill_loop1

print_matrix1:
    # Example: Print the matrix
	li $t0, 0          # Initialize row index for printing
	
print_row_loop1:
	bge $t0, 31, exit_print1  # Exit loop if row index >= 31

	move $t7, $t0
	add $t7, $t7, 1
	move $a0,$t7
	jal  int2str





    # Print the row index
	li $v0, 1         # System call code for print_int
	move $a0, $t7       # Row index to print
	syscall

    # Print a separator ":"
	li $v0, 4           # System call code for print_str
	la $a0, colon       # Address of the colon string
	syscall
	
	li $v0, 15               # System call code for write to a file
	move $a0, $s0            # File descriptor
	la $a1, colon           # Buffer address
	li $a2, 1                # Number of bytes to write (adjust as needed)
	syscall
  
	li $t1, 0          # Initialize column index for printing
	li $t4, -1         # Initialize the previous character to an invalid value

col_loop_print1:
	bge $t1, 10, next_row_print1  # Exit inner loop if column index >= 10

    # Calculate the index in the matrix (assuming 32-bit integers)
	mul $t2, $t0, 10    # Multiply row index by the number of columns
	add $t2, $t2, $t1   # Add column index to get the overall index
	mul $t2, $t2, 1     # Multiply by 4 to get the byte offset (assuming 32-bit integers)

    # Now, you can use the matrix address + offset to access elements
	la $t3, matrix      # Load the base address of the matrix
	add $t3, $t3, $t2   # Add the offset to get the address of the current element

	move $t6,$t5
	
    # Load the value from the matrix element
	lb $t5, 0($t3)

    # Check if the current character is the same as the previous one
	beq $t5, $t4, skip_print1
	bne $t5,$t4,razit

again:
	beq $t5,110,skip_print1

	# Print newline
	li $v0, 4
	la $a0, space
	syscall
	
	li $v0, 15               # System call code for write to a file
	move $a0, $s0            # File descriptor
	la $a1, space          # Buffer address
	li $a2, 1                # Number of bytes to write (adjust as needed)
	syscall
	
	move $t9,$t1
	addi $t9,$t9,8
	bgt $t9,12,fff

rrr:	

    # If different, print the column index
	li $v0, 1         # System call code for print_int
	move $a0, $t9       # Column index to print
	syscall
	
	move $a0,$t9
	jal  int2str

    # Print a separator "-"
	li $v0, 4           # System call code for print_str
	la $a0, dash        # Address of the dash string
	syscall
	
	li $v0, 15               # System call code for write to a file
	move $a0, $s0            # File descriptor
	la $a1, dash          # Buffer address
	li $a2, 1                # Number of bytes to write (adjust as needed)
	syscall	    

skip_print1:
    # Update the previous character
	move $t4, $t5

    # Increment column index and repeat inner loop
	addi $t1, $t1, 1
	j col_loop_print1

next_row_print1:
    # If the last character in the row is the same as the previous one, print the end column
	beq $t5, $t4, print_end_column1

    # Print a newline
	li $v0, 4           # System call code for print_str
	la $a0, newline     # Address of the newline string
	syscall
	
	li $v0, 15               # System call code for write to a file
	move $a0, $s0            # File descriptor
	la $a1, newline         # Buffer address
	li $a2, 1                # Number of bytes to write (adjust as needed)
	syscall

razit:
	beq $t1,0,again
	beq $t6,110,again
     
	move $t9,$t1
	addi $t9,$t9,7
	bgt $t9,12,ffff
	
rrrr:	
# Print the end column index
	li $v0, 1         # System call code for print_int
	move $a0, $t9       # Column index to print
	syscall
	
	move $a0,$t9
	jal  int2str
    
    # Print newline
	li $v0, 4
	la $a0, space
	syscall
	
	li $v0, 15               # System call code for write to a file
	move $a0, $s0            # File descriptor
	la $a1, space         # Buffer address
	li $a2, 1                # Number of bytes to write (adjust as needed)
	syscall	
		
	li    $s7, 0x48  
	beq $t6,$s7,hh
hi:	
    # Print the character after the end column
	li $v0, 11          # System call code for print_int
	move $a0, $t6       # Character to print
	syscall
	
	move $a0,$t6
	la $a1, buffer           # Load the address of the buffer into $a1
	sb $a0, 0($a1)           # Store the character in the buffer

# Print the content of the buffer to a file
	li $v0, 15               # System call code for write to a file
	move $a0, $s0            # File descriptor
	la $a1, buffer           # Buffer address
	li $a2, 1                # Number of bytes to write (adjust as needed)
	syscall

    # Print a separator "-"
	li $v0, 4           # System call code for print_str
	la $a0, q       # Address of the dash string
	syscall
	
	li $v0, 15               # System call code for write to a file
	move $a0, $s0            # File descriptor
	la $a1, q         # Buffer address
	li $a2, 1                # Number of bytes to write (adjust as needed)
	syscall
	
	b again
     
print_end_column1:
	beq $t6,110,.
	move $t9,$t1
	addi $t9,$t9,7
	bgt $t9,12,fffff
	
rrrrr:
    # Print the end column index
	li $v0, 1         # System call code for print_int
	move $a0, $t9       # Column index to print
	syscall
	
	move $a0,$t9
	jal  int2str
     # Print newline
	li $v0, 4
	la $a0, space
	syscall
	
	li $v0, 15               # System call code for write to a file
	move $a0, $s0            # File descriptor
	la $a1, space          # Buffer address
	li $a2, 1                # Number of bytes to write (adjust as needed)
	syscall	
    
     # Print the character after the end column
	li    $s7, 0x48 
	beq $t6,$s7,hhhh
	
hhh:     
	li $v0, 11          # System call code for print_int
	move $a0, $t6       # Character to print
	syscall
	
	move $a0,$t6
	la $a1, buffer           # Load the address of the buffer into $a1
	sb $a0, 0($a1)           # Store the character in the buffer

# Print the content of the buffer to a file
# Assuming $a2 contains the file descriptor for the open file
	li $v0, 15               # System call code for write to a file
	move $a0, $s0            # File descriptor
	la $a1, buffer           # Buffer address
	li $a2, 1                # Number of bytes to write (adjust as needed)
	syscall
	
.:
    # Print a newline
	li $v0, 4           # System call code for print_str
	la $a0, newline     # Address of the newline string
	syscall
	
	li $v0, 15               # System call code for write to a file
	move $a0, $s0            # File descriptor
	la $a1, newline         # Buffer address
	li $a2, 1                # Number of bytes to write (adjust as needed)
	syscall

    # Increment row index and repeat outer loop
	addi $t0, $t0, 1
	j print_row_loop1

exit_print1:
	li $v0, 16          # System call for close file
	move $a0, $s0       # File descriptor
	syscall
	
   # Exit the program
	li $v0, 10   # Exit syscall
	syscall

fffff:
	subi $t9,$t9,12
	b rrrrr
ffff:
	subi $t9,$t9,12
	b rrrr
fff:
	subi $t9,$t9,12
	b rrr
hhhh:
  
	li   $v0, 4                # System call code for print_str
	la  $a0, output_char   # Load the address of the output string
	syscall
	
   # Write to file
	li $v0, 15               # System call code for write to a file
	move $a0, $s0            # File descriptor
	la $a1, output_char         # Buffer address
	li $a2, 1              # Number of bytes to write (adjust as needed)
	syscall    

	b hhh
	
hh:
	li $v0, 15               # System call code for write to a file
	move $a0, $s0            # File descriptor
	la $a1, output_char         # Buffer address
	li $a2, 1              # Number of bytes to write (adjust as needed)
	syscall 
	
	li $v0, 4                # System call code for print_str
	la $a0, output_char      # Load the address of the output string
	syscall

	j hi

# ---------------------------------------- End Exit program --------------------------------------------


# <======================================== Compare and Sub ===============================================>
compare_and_sub: # t1=lec, t2=oh, t3=meeting, s3=prevResult, t6 = currentRead, s0=L, s1=H, s2=M
	bne $t6, $t8, curr_neq_prev
	j end_cmp_and_sub
curr_neq_prev:
	beq $t8, $s0, sub_lec
	beq $t8, $s1, sub_office
	beq $t8, $s2, sub_meeting
	j end_cmp_and_sub
sub_lec:
	subi $t1, $t1, 1
	j end_cmp_and_sub
sub_office:
	subi $t2, $t2, 1
	j end_cmp_and_sub
sub_meeting:
	subi $t3, $t3, 1
	j end_cmp_and_sub
	
end_cmp_and_sub:
	jr $ra
# <======================================== End Compare and Sub ===============================================>

# <======================================== Print Day Info ===============================================>
print_day_info:
	li $v0, 4
	la $a0, time_slots
	syscall
	
	# t0 = array[0][0] from above
	li $t1, 0 # count = 0
	
printing_day: # for (slot in day: print slot)	
	li $v0, 11 # print char
	lb $a0, ($t0)
	syscall
	
	# seprate each time slot with a tab 
	li $v0, 4
	la $a0, tab
	syscall
	
	addi $t0, $t0, 1
	addi $t1, $t1, 1 # this is the counter to know when we finish a certain line
	
	bne $t1, 10, printing_day
	
	# return
	jr $ra
# <-------------------------------------- End Print Day Info ---------------------------------------------->

# <======================================== Wrong Input ===============================================>
wrong_input:
	li $v0, 4
	la $a0, invalid_msg
	syscall
	
	jr $ra
	
wrong_input1:
	li $v0, 4
	la $a0, invalid_msg
	syscall
	
	j prompt_3
	
		
wrong_input2:
	li $v0, 4
	la $a0, invalid_msg
	syscall
	
	j Add
	
wrong_input_del:
	li $v0, 4
	la $a0, invalid_msg
	syscall
	
	j delete
	
wrong_input_del_2:
	li $v0, 4
	la $a0, invalid_msg
	syscall
	
	j read_the_time
	
# <======================================== End Wrong Input ===============================================>        
     
         
add121:
	addi $t2,$t2,12
	j s

add122:
	addi $t3,$t3,12 
	j slot                                   
         
add123:
	addi $t2,$t2,12     
	j k       

add124:
	addi $t3,$t3,12 
	j   adding_app                                           

del_125:
	addi $t2, $t2, 12
	j read_end_time_k
	
del_126:
	addi $t3, $t3, 12
	j read_type

	
int2str:
	blt $a0,10,lessthan10 
	j TwoDigits
	
lessthan10:
	addiu $a0,$a0,48
		
# Store the character in the buffer
	la $a1, buffer           # Load the address of the buffer into $a1
	sb $a0, 0($a1)           # Store the character in the buffer

# Print the content of the buffer to a file
# Assuming $a2 contains the file descriptor for the open file
	li $v0, 15               # System call code for write to a file
	move $a0, $s0            # File descriptor
	la $a1, buffer           # Buffer address
	li $a2, 1                # Number of bytes to write (adjust as needed)
	syscall

        # Make system call to redirect output	
	jr $ra
	
TwoDigits:
	div $a0,$a0,10
	mfhi $t2
				
	li $v0,11
	addiu $a0,$a0,48
	
	la $a1, buffer1           # Load the address of the buffer into $a1
	sb $a0, 0($a1)           # Store the character in the buffer

	addiu $t2,$t2,48
	move $a0, $t2
		
		
		# Print the content of the buffer to a file
# (Assuming you've opened the file and have the file descriptor in $s0)

	la $a1, buffer           # Load the address of the buffer into $a1
	sb $a0, 0($a1)           # Store the character in the buffer

# Print the content of the buffer to a file
# Assuming $a2 contains the file descriptor for the open file
	li $v0, 15               # System call code for write to a file
	move $a0, $s0            # File descriptor
	la $a1, buffer1           # Buffer address
	li $a2, 1               # Number of bytes to write (adjust as needed)
	syscall
	
	li $v0, 15               # System call code for write to a file
	move $a0, $s0            # File descriptor
	la $a1, buffer           # Buffer address	
	li $a2, 1                # Number of bytes to write (adjust as needed)
	syscall
	
# Print the content of the buffer to a file
# Assuming $a2 contains the file descriptor for the open file
	jr $ra			
																									


read_file_store:
	la $s1 buffer
	la $s2 line
	li $s3 0      # current line length

    # open file
	li $v0 13     # syscall for open file
	la $a0 filename    # input file name
	li $a1 0      # read flag
	li $a2 0      # ignore mode 
	syscall       # open file 
	
	move $s0 $v0  # save the file descriptor 

read_loop:
    # read byte from file
	li $v0 14     # syscall for read file
	move $a0 $s0  # file descriptor 
	move $a1 $s1  # address of dest buffer
	li $a2 1      # buffer length
	syscall       # read byte from file

    # keep reading until bytes read <= 0
	blez $v0 read_done

    # naively handle exceeding line size by exiting
	slti $t0 $s3 1024
	beqz $t0 read_done

    # if current byte is a newline, consume line
	lb $s4 ($s1)
	li $t0 10
	beq $s4 $t0 consume_line

    # if current byte is a colon, split the line
	li $t0 58   # ASCII code for colon
	beq $s4 $t0 split_line
    
	li $t0  44
	beq $s4 $t0 split_second

    # otherwise, append byte to line
	add $s5 $s3 $s2
	sb $s4 ($s5)

    # increment line length
	addi $s3 $s3 1
	b read_loop

split_line:
    # null terminate line
	add $s5 $s3 $s2
	sb $zero ($s5)

    # reset bytes read
	li $s3 0

     #print the first part before the colon
	move $a0 $s2
     
	j  call_function1  
  # If length is neither 1 nor 2, end the program

h:
	move $t7 ,$v0

    # move to the next part after the colon
	add $t1 $s2 $s3  # Calculate the offset to move to the next part after the colon
	addi $s2 $t1 1   # Move to the next part after the colon

	b read_loop

consume_line:
    # null terminate line
	add $s5 $s3 $s2
	sb $zero ($s5)

    # reset bytes read
	li $s3 0

    # print line (or consume it some other way)
	move $a0 $s2
	lb $a2 ,0($a0)
	bne $a2,32,read_loop
  
	j findChar  

	b read_loop

read_done:
    # close file
	li $v0 16     # syscall for close file
	move $a0 $s0  # file descriptor to close
	syscall       # close file

	jr $ra

call_function1:
convert_char_to_int:
	move $a0, $s2  # Load address of the string into $a0
	li $v0, 0      # Initialize the result in $v0 to 0

convert_loop:
	lb $t1, 0($a0)  # Load a byte from the current address in $a0
	beqz $t1, end_convert_loop  # If the byte is zero (null terminator), exit the loop

  # Convert ASCII character to integer (assuming ASCII values for '0' to '9')
	sub $t1, $t1, '0'  # Convert ASCII to integer

  # Multiply the current result by 10 and add the new digit
	mul $v0, $v0, 10   # Multiply current result by 10
	add $v0, $v0, $t1  # Add the new digit

	addi $a0, $a0, 1    # Move to the next character in the string
	j convert_loop      # Repeat the loop

end_convert_loop:
	j h  # Return from the function

split_second:

    # null terminate line
	add $s5 $s3 $s2
	sb $zero ($s5)

    # reset bytes read
	li $s3 0

     # print the first part before the colon
	move $a0, $s2
    
	j split_third
	
	b read_loop
     
findChar:
 # Set the characters to find
	la $a1, chars_to_find
	lb $t1, 0($a1)  
	move $t3 ,$a0
    
	li $t9, 'L'        # ASCII code for 'L'
	li $t4, 'M'       # ASCII code for 'M'
	li $t5, 'H'       # ASCII code for 'H'

loop3:
	lb $t2, 0($t3)   # Load the current character from the string

        beq $t2, $t9, char_found  # If 'L' found, branch to 'char_found' label
        beq $t2, $t4, char_found # If 'M' found, branch to 'char_found' label
        beq $t2, $t5, char_found # If 'H' found, branch to 'char_found' label

        addi $t3, $t3, 1   # Move to the next character in the string
        bnez $t2, loop3     # If not the end of the string, repeat the loop

        # If the loop reaches here, the characters 'L', 'M', or 'H' are not found
        li $t8, 0          # Set $t8 to 0 (character not found)
        jr $ra             # Return from the function

char_found:
	move $t8, $t2      # Save the found character in $t8            # Return from the function
	move $v0,$t8
	b  r1        # Return from the function

split_third:
        
	j lastChar  
         # Load the address of the input string
      
r1:      # if th char is L or M or H 
	move $a0 $v0
	move $t8,$a0
	j splitString         # Jump to the splitString function
          
f:               
	move $a0, $s2         # Load the address of the substring after the delimiter
	li $t9 , 0
	
loop:     
	lb $s4 0($s2)
	beq $s4 , 32 ,increment1
        beq $s4 ,45 ,increment2
        bge $s4, 76, letter    
        li $t1, 48             
        li $t2, 57              
        bge $s4, $t1, Number    
        addi $s2 ,$s2,1
        beqz $s4,read_loop 
        b loop

Number: 
	addi $t9 ,$t9,1
	sub $s4 ,$s4 ,'0'
	move $a0 $s4
	move $k1 ,$s4

	addi $s2 ,$s2,1
	beq $t9 ,2 counter
	b loop
	
letter:
	li $t9 ,0

	beq $s4 ,79 , increment
	addi $s2 ,$s2,1
	b loop

increment:
	addi $s2 ,$s2 ,2
	li $t9 ,0
	b loop

increment1:
	addi $s2,$s2,1
	li $t9 ,0
	b loop
	
increment2:
	addi $s2 ,$s2,1
	move $a0, $s2  # Load address of the string into $a0
	li $v0, 0
	
convert_loop1:
      # Initialize the result in $v0 to 0
	lb $t1, 0($a0)  # Load a byte from the current address in $a0
	beqz $t1, end_convert_loop1  # If the byte is zero (null terminator), exit the loop

  # Convert ASCII character to integer (assuming ASCII values for '0' to '9')
	sub $t1, $t1, '0'  # Convert ASCII to integer

  # Multiply the current result by 10 and add the new digit
	mul $v0, $v0, 10   # Multiply current result by 10
	add $v0, $v0, $t1  # Add the new digit

	addi $a0, $a0, 1    # Move to the next character in the string
	j convert_loop1      # Repeat the loop

end_convert_loop1:
	move $k0,$v0
	b store
   
counter:
	sub $s2 $s2,1
	lb  $t6 ,($s2) 
	sub $s2 $s2,1
	lb  $t5 ,($s2) 
	sub $t6 , $t6 ,'0'
	sub $t5, $t5, '0'
	mul $t5, $t5,10
	add $t5,$t6,$t5
	move $t6,$t5
	move $a0,$t6

	move $k1,$a0
 
	addi $s2,$s2,2
	li $t9 ,0
	b loop

lastChar:
	move $t0, $a0           # Copy the address of the input string to $t0
    
findEnd:
	lb $t1, 0($t0)          # Load the byte at the current address into $t1
	beq $t1, $zero, endFind  # If the byte is zero (null terminator), exit the loop
	addi $t0, $t0, 1        # Move to the next byte in the string
	j findEnd               # Repeat the loop

endFind:
    # $t0 now points to the null terminator
	subi $t0, $t0, 1       # Move back to the last character

    # Load the last character into $v0
	lb $v0, 0($t0)
	j r1

    # Function to split a string
splitString:
	li $v0, 4             # Print string system call code
	move $a0, $s2         # Load the address of the substring after the delimiter

        la $a1, delimiter     # Load the address of the delimiter
        lb $t0, 0($a1)        # Load the delimiter character

        move $t1, $s2         # Copy the address of the input string to $t1

        # Count occurrences of the delimiter
        li $t4, 0            # Initialize delimiter count to 0

loop1:
        lb $t2, 0($t1)       # Load the current character from the input string
        beq $t2, $zero, end  # If the current character is null (end of string), exit the loop

        beq $t2, $t0, found_delimiter # Check if the current character is the delimiter

        j next_character

found_delimiter:
        addi $t4, $t4, 1      # Increment delimiter count

        # Check if it's the second occurrence
        beq $t4, 2, end_loop1

        j next_character

end_loop1:
	sb $zero, 0($t1)      # Null-terminate the substring at the second occurrence of the delimiter

next_character:
        addi $t1, $t1, 1      # Move to the next character in the input string
        j loop1

end:
      b f

store:
    # Adjust the row index for memory address calculation
	move $t9, $t7  # Copy the original value of $t7 to $t9
	sub $t9, $t9, 1  # Subtract 1 from $t9 for memory address calculation
    
	beq $k1,1,one
	beq $k1,2,one
	beq $k1,3,one
	beq $k1,4,one
	beq $k1,5,one
      
success: 
	beq $k0,1,two
	beq $k0,2,two
	beq $k0,3,two
	beq $k0,4,two
	beq $k0,5,two
    # Calculate the index in the matrix

correct:
	sub $k0, $k0, 8
	sub $k1, $k1, 8

fill_column_loop:
	bgt $k1, $k0, loop_end  # Exit loop if start time >= end time

    # Calculate the memory address for the current row and column
	la $t3, matrix           # Load the base address of the matrix
	mul $t2, $t9, 10         # Assuming 10 columns in each row, use $t9 for calculation
	add $t2, $t2, $k1
	add $t3, $t3, $t2
	sb $t8, 0($t3)  # Store the character in the current cell

    # Increment column index
	addi $k1, $k1, 1

    # Repeat the loop
	j fill_column_loop

loop_end:
	b read_loop  # Assuming there's a read loop to continue with your program

one:
	addi $k1,$k1 ,12
	b success
 
two:
	addi $k0, $k0, 12
	b correct
