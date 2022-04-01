.data
	Plaintxt:
		.asciz "Please enter the plaintext: "
		lenPltxt = .-Plaintxt
	
	InputShift:
		.asciz "\nPlease enter the shift value: "
		lenInShft = .-InputShift

	Ciphertxt:
		.asciz "\nYour ciphertext is: "
		lenCptxt = .-Ciphertxt

	var_x:
		.int 10

.bss
	.comm Output, 51
	.comm Shift, 4
	.comm Input, 51
.text

	.globl _start
	
	.type CaesarCipher, @function

	CaesarCipher:				# This is the function that execute the CaesarCipher
			pushl %ebp		# Store the current value of EBP on the stack	
			movl %esp, %ebp		# Make EBP point to the top of the stack

			movl %eax, %ecx		# Storing the length of the shift value in ECX
			sub $1, %ecx		# Subtracting 1 to ignore the \n
			movl $0, %edx		# Resetting EDX to 0

		LoadShift:			# Assigning the source for the shift value
			movl 12(%ebp), %esi	# Moving the shift value to ESI by pointing to the position on the stack

		StringToInteger:		# Determingin the numberical value and postion of integer
			lodsb			# Load byte into EAX
			sub $0x30, %eax		# Subtract 0x30 to get the numerical value
			cmp $3, %ecx		# Check to see if the byte that was loaded was from the 100s place
			je three_or_two_digit	# If 100s place, jump to arthimetic for 100s		
			cmp $2, %ecx		# Check to see if the byte that was loaded was from the 10s place
			je three_or_two_digit	# If 10s place, jump to arthimetic for 10s
			cmp $1, %ecx		# Check to see if the byte was loaded was from the 1s place
			je one_digit		# If 1s place, jump to arthimetic for 1s

		three_or_two_digit:		# Conversion for 100s and 10s
			add %eax, %edx		# Add the numerical value in EAX to EDX
			imul $10, %edx		# Multiply the numerical value in EDX by 10
			dec %ecx		# Decrement to the next position
			jmp StringToInteger	# Jump back to StringToInteger to determine the next place

		one_digit:			# Conversion for 1s
			add %eax, %edx		# Add the numerical value in EAX to EDX
			movl %edx, var_x	# Store the value in EDX as an integer into var_x

		Load_String:			# Assigning the source and destination for the Plaintext and Ciphertext
			movl 8(%ebp), %esi	# Moving the input string to ESI by pointing to the position on the stack
			movl $Output, %edi	# Declaring the destination that the encoded bytes will be stored at

		Loop_String:			# The encoder		
			lodsb			# Load byte into EAX
			cmp $32, %eax		# Check to see if the byte is a space character
			je Looptwo_String	# If space character, jump to Looptwo_String
			cmp $10, %eax		# Check to see if the byte is a \n 
			je Loopthree_String	# If \n, jump to Loopthree_String
			sub $65, %eax		# Subtract the value in EAX by 65 to determine the position before doing the modulo arthimetic
			add var_x, %eax		# Add the shift value to EAX
			movl $0, %edx		# Resetting the remainder register before dividing
			movl $26, %ebx		# Move the value 26 into EBX to perform the modulo division
			idiv %ebx		# Divide the value in EAX by 26
			add $65, %edx		# Add the value of the remainder in EDX by 65
			movl %edx, %eax		# Move the encoded byte value from EDX to EAX
			stosb			# Store the byte into Output
			jmp Loop_String		# Jump back to the beginning to encode the next byte
		
		Looptwo_String:			# To store the space character as it will not need to be encoded
			stosb			# Store the space character into Output
			jmp Loop_String		# Jump back to Loop_string to encode the next byte

		Loopthree_String:		# To store the \n as it will not need to be encoded and stop the encoding process
			stosb			# Store the \n into Output

		Output_Text:			# Output the ciphertext prompt
			movl $4, %eax		# syscall for write()
			movl $1, %ebx		# File descriptor for stdout
			movl $Ciphertxt, %ecx	# Store address of the ciphertext prompt in ECX
			movl $lenCptxt, %edx	# Store the length of the ciphertext prompt in EDX
			int $0x80		# Interrupt to execute the syscall

		Output_Result:			# Output the encoded ciphertext
			movl $4, %eax		# syscall for write()
			movl $1, %ebx		# File descriptor for stdout
			movl $Output, %ecx	# Store address of the encoded ciphertext in ECX
			movl $51, %edx		# Store the length of the encoded ciphertext in EDX (50 + 1  for \n)
			int $0x80		# Interrupt to execute the syscall

			movl %ebp, %esp		# Restore the old value of ESP
			popl %ebp		# Restore the old value of EBP
			ret			# change EIP to jump to "addl $8, %esp"

			
	_start:

		User_Prompt_String: 		# Display the user prompt
			movl $4, %eax		# syscall for write()
			movl $1, %ebx 		# File descriptor for stdout
			movl $Plaintxt, %ecx 	# Store address of the plaintext prompt in ECX
			movl $lenPltxt, %edx 	# Store the length of the plaintext prompt in EDX
			int $0x80 		# Interrupt to execute the syscall

		User_Input_String: 		# Read and store the user input
			movl $3, %eax 		# syscall for read()
			movl $0, %ebx		# File descriptor for stdin
			movl $Input, %ecx	# Store address of the input string in ECX
			movl $51, %edx		# Store the length of the string in EDX (50 + 1 for \n)
			int $0x80		# Interrupt to execute the syscall

		User_Prompt_Shift:		# Display shift value prompt
			movl $4, %eax		# syscall for write()
			movl $1, %ebx		# File descriptor for stdout
			movl $InputShift, %ecx	# Store address of the inputshift prompt in ECX
			movl $lenInShft, %edx	# Store the length of the inputshift prompt in EDX
			int $0x80		# Interrupt to execute the syscall

		User_Input_Shift:		# Read and store the user input for shift
			movl $3, %eax		# syscall for read()
			movl $0, %ebx		# File descriptor for stdin
			movl $Shift, %ecx	# Store address of the shift value in ECX
			movl $4, %edx		# Store the length of the shift vale in EDX (3 + 1 for \n)
			int $0x80

			pushl $Shift   		# Push Shift value on the stack
			pushl $Input  		# Push input string on the stack

			call CaesarCipher	# Call to the CaesarCipher function
			
			addl $8, %esp		# adjust the stack pointer
		
		Exit:				# Exit the program
			movl $1, %eax		# syscall for exit()
			movl $0, %ebx		# File descriptor
			int $0x80		# Interrupt to execute for syscall