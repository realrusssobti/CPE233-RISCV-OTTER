.data
my_lut: 
.byte 0x0C, 0x0E, 0x0F, 0x10, 0x18, 0x1C, 0x1E, 0x1F
.byte 0x00, 0x01, 0x02, 0x03, 0x04, 0x06, 0x07, 0x08, #LED output patterns


.text
init:     
	li 	x15, 	0x11004444    	# input port address
	li 	x16, 	0x1100C000    	# LED address
	la 	x6,	ISR 		# load address of ISR into x6
	csrrw 	x0,	mtvec,	x6 	# store address as interrupt vector CSR[mtvec]
	sw 	x0,	0(x16) 		# put LEDs in known state
	li x20, 0 			# value to output to LEDs
	li x21, 0			# sum of inputs
	li x22, 0			# number of interrupts
	li x23, 16			# max number of interrupts
	li x24, 0			# temp value

start:
	nop				# this is literally just an output loop

reset:
	csrrs 	x0,	mstatus,x10 	# enable interrupts: set MIE (bit3) in CSR[mstatus]
	
output:
	la 	x17, 	my_lut 		# load address of LUT into x16
	add 	x17,	x17,	x20 	# add the counter to the address
	lhu 	x9,	0(x17) 		# load the stone value into x9
	sh 	x9,	0(x16) 		# write result to LEDs
	j 	start 			# jump to do this all again

#---------------------------------------------------------------------------------
#---------------------------------------------------------------------------------
ISR:
	csrrc 	x0,	mstatus,x9 	# clear bit7 (MPIE) in CSR[mstatus]
	addi 	x22, x22, 1
	bne 	x22, x23, read_input	
average:
	srli x20, x21, 4 		# divide by 16 for the average and store in output_val
	li x22, 0			# reset the interrupt count
	li x21, 0			# reset the sum
	
read_input:
	lb x24, 0(x15) 			# read input
	add x21, x21, x24 		# add to the sum

done: 	mret 				# return from interrupt
#---------------------------------------------------------------------------------
