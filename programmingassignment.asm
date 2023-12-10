.data
sseg: .byte 0x03,0x9F,0x25,0x0D,0x99,0x49,0x41,0x1F,0x01,0x09 # LUT for 7-segs
# ---------------------------------------------------
# SUBROUTINE: 7-SEG Blink and Count Up/Down
# ---------------------------------------------------
.text
init:
    li x5, 0x1100C004 #7-Segment port address
    li x7, 0x11008004 #BTN port address
    li x2, 0x1100C008 # Anode port address
    
    li x8, 0 # 7seg value
    li x11, 0xFFFFFF # Timer value
    li x30, 0 # Counter (used for timer)
    li x13, 0 # Counter (used for 7-seg)
    li x21, 9 #Max counter value 
    li x22, 14 # Anode value

    # set the anode to enable the 7-seg
    sw x22, 0(x2)
    
    call Timer_2Hz

wait_for_press:
    li x13, 0 # reset counter
    la x8, sseg
    lb x8, 0(x8) # get the 7-seg value from LUT
    sw x8, 0(x5)
    lw x9, 0(x7)
    call toggle_off
    beqz x9, wait_for_press
    call wait_for_release
    j count_up

count_up:
    call Timer_2Hz #Delay 1/2sec
    addi x13, x13, 1 # increment counter
    la x8, sseg
    add x8, x8, x13
    lb x8, 0(x8) # get the 7-seg value from LUT
    sw x8, 0(x5)
    beq x8, x21, wait_for_press2
    j count_up

wait_for_release:
    lw x9, 0(x7)
    bnez x9, wait_for_release
    ret


wait_for_press2:
    li x13, 9 # reset counter
    la x8, sseg
    addi x8, x8, 9
    lb x8, 0(x8) # get the 7-seg value from LUT
    sw x8, 0(x5)
    lw x9, 0(x7)
    call toggle_off
    beqz x9, wait_for_press
    call wait_for_release
    j count_down

count_down:
    call Timer_2Hz
    addi x13, x13, -1 # increment counter
    la x8, sseg
    add x8, x8, x13
    lb x8, 0(x8) # get the 7-seg value from LUT
    sw x8, 0(x5)
    beqz x13, wait_for_press
    j count_down


toggle_off:
    call Timer_2Hz
    li x8, 0xF
    sw x8, 0(x5)
    call Timer_2Hz
    ret

# ---------------------------------------------------
# SUBROUTINE: Timer_2Hz
# ---------------------------------------------------

Timer_2Hz:
    beq x30, x11, timer_done
    addi x30, x30, 1
    j Timer_2Hz

timer_done:
    li x30, 0
    ret
