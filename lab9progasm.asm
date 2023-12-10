# Programming Assignment
# Write an interrupt driven RISC-V MCU assembly language program that does the following. The program outputs the average of the four most recent values that were on the switches when the RISC-V MCU received an interrupt to the LEDs. Assume there are 16 LEDs and 16 switches. Interpret the 16-bit switch values as unsigned binary numbers. Use the port addresses associated with the standard RISC-V wrapper (not from Experiment 6) for this problem.
# • Don’t perform any IO in the interrupt service routine
#• Assume an external device generates the interrupt
#• Minimize the number of instructions in your solution

init: #set up registers
    li t0, 0x1100C000 #address of LEDs
    li t2, 0x11008000 #address of switches
    li a1, 0 #initialize average to 0
    li a2, 0 #initialize counter to 0
    li a3, 0 #initialize val1 to 0
    li a4, 0 #initialize val2 to 0
    li a5, 0 #initialize val3 to 0
    li a6, 0 #initialize val4 to 0

    # set up ISR
    la 	x6,	ISR 		# load address of ISR into x6
    lw s1, 0(t2)
    csrrw 	x0,	mtvec,	x6 	# store address as interrupt vector CSR[mtvec]

main: #main loop
    csrrs 	x0,	mstatus,x10 	# enable interrupts: set MIE (bit3) in CSR[mstatus]

compute_average: #compute average of 4 most recent values
    add a1, a1, a3 #add val1 to average
    add a1, a1, a4 #add val2 to average
    add a1, a1, a5 #add val3 to average
    add a1, a1, a6 #add val4 to average
    srai a1, a1, 2 #divide average by 4

output: #output average to LEDs
sw a1, 0(t0) #output average to LEDs
j main


ISR: #interrupt service routine
    addi a2, a2, 1 #increment counter
modulo: # get the remainder after dividing by 4, without using the remainder instruction
    andi a7, a2, 3 #get remainder after dividing by 4
    beqz a7, val1 #if remainder is 0, go to val1
    addi a7, a7, -1
    beqz a7, val2
    addi a7, a7, -1
    beqz a7, val3
    addi a7, a7, -1
    beqz a7, val4
    j done

val1: #store value of switch in val1
    addi a3, s1, 0
    j done
val2: #store value of switch in val2
    addi a4, s1, 0
    j done
val3: #store value of switch in val3
    addi a5, s1, 0
    j done
val4: #store value of switch in val4    
    addi a6, s1, 0
    j done

done: #return to main
    mret


