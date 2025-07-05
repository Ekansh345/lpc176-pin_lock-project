FIO1DIR  EQU 0x2009C020
FIO1MASK EQU 0x2009C030
FIO1PIN  EQU 0x2009C034
FIO1SET  EQU 0x2009C038
FIO1CLR  EQU 0x2009C03C

FIO2DIR  EQU 0x2009C040
FIO2MASK EQU 0x2009C050
FIO2PIN  EQU 0x2009C054
FIO2SET  EQU 0x2009C058
FIO2CLR  EQU 0x2009C05C		
		
		AREA RESET,DATA,READONLY
		EXPORT __Vectors
__Vectors
		DCD 0X10008000
		DCD Reset_Handler
		ALIGN
		AREA MYCODE,CODE,READONLY
	    ENTRY
		EXPORT Reset_Handler
Reset_Handler
		LDR R11, =attempts_left      ; checks if we've used up 3 attempts
		LDRB R12,[R11]
		CMP R12,#0
		BEQ.W Stop         
		
        LDR R0, =user_pin_flash
        LDR R1, =user_pin_ram
emulator_loop                        ;emulates user input
        LDRB R2, [R0], #1     
        STRB R2, [R1], #1
        CMP R2, #0
        BNE emulator_loop
		

		LDR R0, =correct_pins
pin_check		
next_candidate
		LDR R1, =user_pin_ram
		LDRB R4,[R0]                 ; checks if we've reached end of list
		CMP R4,#0
		BEQ access_denied
		
		MOV R2,#0                     ; counter for checking each byte of the pin
		MOV R3,R0                     
bytewise_pin_check
		LDRB R5,[R3], #1
		LDRB R6,[R1], #1
		CMP R5,R6
		BNE skip_candidate
		ADD R2,R2,#1
		CMP R2,#4
		BNE bytewise_pin_check
		B.W pin_matched
skip_candidate
		ADD R0,R0, #5
        B next_candidate

pin_matched	                  ; unlocks password and displays success message
		LDR R5, =password_source_encrypted
		LDR R6, =password_destination
decrypt_loop
        LDRB R7,[R5], #1
        CMP R7, #0
        BEQ decrypt_done
        EORS R7,R7, #0xAA       ; XOR-decrypt
        STRB R7,[R6], #1
        B decrypt_loop
decrypt_done
		
		LDR R8, =success_message_source
		LDR R9, =success_message_destination
copy_message
        LDRB R10, [R8], #1
        STRB R10, [R9], #1
        CMP R10, #0
        BNE copy_message
		
; LED BLINKING IF PIN IS RIGHT
        LDR R0, =FIO1DIR    
        LDR R1, =0xB0000000      ; P1.28, P1.29, P1.31
        STR R1, [R0]
        LDR R0, =FIO2DIR
        LDR R1, =0x7C            ; P2.2–P2.6
        STR R1, [R0]

        LDR R2, =FIO1SET
        LDR R3, =FIO1CLR
        LDR R4, =FIO2SET
        LDR R5, =FIO2CLR
		
		;LED forward blink
		LDR R6, =0x10000000  ;pin 28
		MOV R7, #0    ;counter
led_forward_p1
		STR R6,[R2]
		BL delay
		STR R6,[R3]
		ADD R7,R7, #1
		CMP R7, #2
		MOVNE R6,R6,LSL #1
		MOVEQ R6,R6,LSL #2
		CMP R7,#3
		BNE led_forward_p1
		
		MOV R6, #0X04  ;pin 2
led_forward_p2
		STR R6,[R4]
		BL delay
		STR R6,[R5]
		ADD R7,R7, #1
		MOV R6,R6,LSL #1
		CMP R7, #8
		BNE led_forward_p2
		
		;LED reverse blink
		MOV R6, #0x40   ;pin 6
		MOV R7,#0
led_reverse_p2
		STR R6,[R4]
		BL delay
		STR R6,[R5]
		ADD R7,R7, #1
		MOV R6,R6,LSR #1
		CMP R7, #5
		BNE led_reverse_p2
		
		LDR R6, =0X80000000  ;pin 31
led_reverse_p1
		STR R6,[R2]
		BL delay
		STR R6,[R3]
		ADD R7,R7, #1
		CMP R7, #7
		MOVNE R6,R6,LSR #2
		MOVEQ R6,R6,LSR #1
		CMP R7, #8
		BNE led_reverse_p1
		
		B.W Stop
		
delay
		LDR R8, =0xFFF00         ; delay for led blinking 
delay_loop
		SUBS R8,R8, #1
		BNE delay_loop
		BX LR
; END OF LED BLINKING

access_denied 
		LDRB R12,[R11]
		SUB R12,R12,#1
		STRB R12,[R11]
		CMP R12,#0
		BEQ Stop
		
		LDR R0, =0x11111111                     ; gives a timeout/delay of around 10s between consecutive user attempts
delay_if_wrong
		SUBS R0,R0, #1
		BNE delay_if_wrong
		
		B.W Reset_Handler
		
Stop B Stop
		
		AREA MYDATA, DATA, READWRITE
user_pin_ram SPACE 5
password_destination SPACE 32
success_message_destination SPACE 32

		AREA CONSTANTS, DATA, READONLY
attempts_left DCB 3
user_pin_flash DCB "4232",0
correct_pins
		DCB "1234",0
		DCB "4231",0
		DCB "5678",0
		DCB 0
password_source_encrypted  DCB 0xEF,0xE1,0xEB,0xE4,0xF9,0xE2,0x9B,0x98,0x99,0
success_message_source DCB "ACCESS GRANTED",0
			
		END 
