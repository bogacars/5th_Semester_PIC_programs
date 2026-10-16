;==============Carson Bogart====================================================
    LIST    p=16F883_g
    #include "p16f883.inc"

; CONFIG1
; __config 0xE0F2
 __CONFIG _CONFIG1, _FOSC_HS & _WDTE_OFF & _PWRTE_OFF & _MCLRE_ON & _CP_OFF & _CPD_OFF & _BOREN_OFF & _IESO_OFF & _FCMEN_OFF & _LVP_OFF
; CONFIG2
; __config 0xFFFF
 __CONFIG _CONFIG2, _BOR4V_BOR40V & _WRT_OFF
 ;------Test Program setup-------------------------------------------------------
 
;------# DEFINE THE PORT NAMES -------------------------------------------------
 
 
;------ END DEFINE -------------------------------------------------------------
 
;------ CPU MEMORY MAP ---------------------------------------------------------
COUNT1		EQU	0X20
SAVEDTONE	EQU	0X30
KEYPADDATA	EQU	0X40
;------ END CPU ----------------------------------------------------------------

;------ ORG BEGIN --------------------------------------------------------------
	    
	 ORG	    0X000	    ;start at memory location at 0x000
	 GOTO	    SETUP	    ;goes to setup to initialize ports
	 ORG	    0X004	    ;interrupt vector
	 GOTO	    INTERRUPT	    ;goes to interupt when one is present
	 GOTO	    MAINBEGIN	    ;goes to main begin to start program
;------- END ORG ---------------------------------------------------------------

;---------- SETUP BEGIN --------------------------------------------------------
SETUP
	 BANKSEL    PORTA	    ;clear portA,B,and C
	 CLRF	    PORTA	    ;///
	 CLRF	    PORTB	    ;//
	 CLRF	    PORTC	    ;/
	 BANKSEL    TRISA	    ;config portA as outputs
	 MOVLW	    0X00	    ;//
	 MOVWF	    TRISA	    ;/
	 MOVLW	    0X0F	    ;config portB as output/input to read keypad
	 MOVWF	    TRISB	    ;//
	 MOVLW	    0XFF	    ;config portC as inputs
	 MOVWF	    TRISC	    ;/
	 BANKSEL    ANSELH	    ;config portB as digital inputs
	 MOVLW	    0X00	    ;//
	 MOVWF	    ANSELH	    ;/
	 MOVLW	    0X00	    ;config portA as digital i/o pins
	 MOVWF	    ANSEL	    ;/
	 MOVLW	    0X05	    ;preload PCH with 5 to acsess table
	 MOVWF	    PCLATH	    ;/
	 BANKSEL    PORTB	    ;banksel portB to ensure in right bank
	 GOTO	    MAINBEGIN	    ;goto main begin to start program
;--------- SETUP END -----------------------------------------------------------
	
;---------- INTERRUPT BEGIN ----------------------------------------------------
INTERRUPT
	    RETFIE		    ;return from interrupt enable
;------ Interrupt end ----------------------------------------------------------
	    
;------- DELAY SUB BEGIN -------------------------------------------------------
DELAYSUB
;creates delay value for count1 value returned from table
	MOVF	    SAVEDTONE,0	    ;move savedtone to working to load count1
	MOVWF	    COUNT1	    ;moves savedtone from working to count1
LOOP1				    ;begin loop 1
	DECFSZ	    COUNT1,1	    ;decrement count 1 by 1 till count1 equ 0
	GOTO	    LOOP1	    ;loop continue
	RETURN			    ;return to call delay sub line +1
; -------- DELAY SUB END -------------------------------------------------------
	
	
;------------ KEYPAD READ SUB BEGIN --------------------------------------------	
KEYSUB
;reads the keypad values
	 MOVLW	    0X10	    ;moves value to call table and do nothing if
	 MOVWF	    KEYPADDATA	    ;no values change during the sub
	 
	 BSF	    PORTB, RB4	    ;set column 1 high to test each row for- 
	 BTFSC	    PORTB, RB0	    ; check for value change on a row
	 MOVLW	    0X0E	    ;key pressed "1"  
	 BTFSC	    PORTB, RB1	    ;//////
	 MOVLW	    0X0B	    ;key pressed "4"  
	 BTFSC	    PORTB, RB2	    ;////
	 MOVLW	    0X08	    ;key pressed "7" 
	 BTFSC	    PORTB, RB3	    ;//
	 MOVLW	    0X00	    ;key pressed "*"  
	 BCF	    PORTB, RB4	    ;clear column 1 to stop testing coloumn
	 
	 BSF	    PORTB, RB5	    ;set column 2 high to test row for valchange
	 BTFSC	    PORTB, RB0	    ;check for value change   
	 MOVLW	    0X0D	    ;key pressed "2"
	 BTFSC	    PORTB, RB1	    ;//////
	 MOVLW	    0X0A	    ;key pressed "5"
	 BTFSC	    PORTB, RB2	    ;////	    
	 MOVLW	    0X07	    ;key pressed "8"
	 BTFSC	    PORTB, RB3	    ;//
	 MOVLW	    0X0F	    ;key pressed "0"
	 BCF	    PORTB, RB5	    ;clear column to stop testing column
	 
	 BSF	    PORTB, RB6	    ;set column 3 high to test row for valchange
	 BTFSC	    PORTB, RB0	    ;check for value change
	 MOVLW	    0X0C	    ;key pressed "3"
	 BTFSC	    PORTB, RB1	    ;//////
	 MOVLW	    0X09	    ;key pressed "6"
	 BTFSC	    PORTB, RB2	    ;////
	 MOVLW	    0X06	    ;key pressed "9"
	 BTFSC	    PORTB, RB3	    ;//
	 MOVLW	    0X01	    ;key pressed "#"
	 BCF	    PORTB, RB6	    ;clear column 3 to stop testing 
	 
	 BSF	    PORTB, RB7	    ;set column 4 high to test row for valchange
	 BTFSC	    PORTB, RB0	    ;check for value change
	 MOVLW	    0X05	    ;key pressed "A"
	 BTFSC	    PORTB, RB1	    ;//////
	 MOVLW	    0X04	    ;key pressed "B"
	 BTFSC	    PORTB, RB2	    ;////
	 MOVLW	    0X03	    ;key pressed "C"
	 BTFSC	    PORTB, RB3	    ;//
	 MOVLW	    0X02	    ;key pressed "D"
	 BCF	    PORTB, RB7	    ;clear column 4 to stop testing column
	 
	 BTFSC	    KEYPADDATA,0X10
	 GOTO	    KEYSUB
	 
	 RETURN			    ;return to sub with default value(0x10) or,
				    ;value if changed by pressing key
	
;------ KEYPAD READ SUB END ----------------------------------------------------
	 
;------ MAIN -------------------------------------------------------------------
MAINBEGIN 
	
	CALL	    KEYSUB	    ;call keypad read sub to read keypad
	CALL	    TABLE	    ;call table to pick a value
	MOVWF	    SAVEDTONE	    ;saves table value in file to use in delay
	CALL	    DELAYSUB	    ;call delay sub to pull speaker
	MOVLW	    0X01	    ;move 1 to working register to toggle with,
	XORWF	    PORTA,1	    ;portC and mov to working register 
	CALL	    DELAYSUB	    ;call delay sub to push speaker out
	MOVLW	    0X01	    ;move 1 to working register to toggle with,
	XORWF	    PORTA,1	    ;portC and mov to working register	

	GOTO	    MAINBEGIN	    ;loops back to main begin to be continuous
	
;------- END MAIN --------------------------------------------------------------

;------- TABLE BEGIN -----------------------------------------------------------

	ORG	0X500		    ;start at memory location 500
TABLE	
	ADDWF	PCL,1		    ;add 1 to the low PC bits to chose values
	RETLW	0X30		    ;#
	RETLW	0X34		    ;*
	RETLW	0X39		    ;D
	RETLW	0X3D	     	    ;C
	RETLW	0X44		    ;B
	RETLW	0X4D		    ;A
	RETLW	0X57		    ;9
	RETLW	0X5D		    ;8
	RETLW	0X68		    ;7
	RETLW	0X75		    ;6
	RETLW	0X7D		    ;5
	RETLW	0X8B		    ;4
	RETLW	0X9D		    ;3
	RETLW	0XB2		    ;2
	RETLW	0XD3		    ;1
	RETLW	0XEE		    ;0
	
END
;----------------------- TABLE END ---------------------------------------------
