;==============Carson Bogart========================
    LIST    p=16F883_g
    #include "p16f883.inc"

; CONFIG1
; __config 0xE0F2
 __CONFIG _CONFIG1, _FOSC_HS & _WDTE_OFF & _PWRTE_OFF & _MCLRE_ON & _CP_OFF & _CPD_OFF & _BOREN_OFF & _IESO_OFF & _FCMEN_OFF & _LVP_OFF
; CONFIG2
; __config 0xFFFF
 __CONFIG _CONFIG2, _BOR4V_BOR40V & _WRT_OFF
 
;------Test Program setup---------------------------
 
;------# DEFINE THE PORT NAMES ---------------------
 
 
 
 
 
;------ END DEFINE ---------------------------------
 
;------ CPU MEMORY MAP -----------------------------

count1	    equ	    0x20	;used for delay loop
	    
	    
;------ END CPU ------------------------------------

;------ ORG BEGIN ----------------------------------
	    
	    ORG		0X000
	    GOTO	SETUP
	    ORG		0X004
	    GOTO	INTERRUPT
	    GOTO	MAINBEGIN
;------- END ORG -----------------------------------
	    
SETUP
	    BANKSEL	PORTB	    ;select PORTB to initialize
	    CLRF	PORTB	    ;clear PORTB to ensure the port is empty
	    BANKSEL	TRISB	    ;select TRISB to change PORTB to inputs
	    MOVLW	0XFF	    ;sets PORTB as inputs
	    MOVWF	TRISB	    ;moves all 1's to TRISB to set PORTB as inputs
	    BANKSEL	ANSELH	    ;select ANSELH 
	    MOVLW	0X00	    ;sets ANSELH to zero
	    MOVWF	ANSELH	    ;makes all of PORTB from analog inputs to digital inputs
	    BANKSEL	PORTC	    ;select PORTC to initialize
	    CLRF	PORTC	    ;clear PORTC to ensure port is empty
	    BANKSEL	TRISC	    ;select TRISC
	    MOVLW	0X00	    ;sets PORTC as outputs
	    MOVWF	TRISC	    ;sets PORTC as outputs
	    
GOTO	    MAINBEGIN		    ;after setup goes to mainbegin
	    
INTERRUPT
	    
	    
	    RETFIE
	    
	    
;------ MAIN ---------------------------------------
MAINBEGIN
	   MOVLW	0X30	    ;moves an ASCii 0 to the working register to start the program
	   BTFSC	PORTB, RB0  ;tests if bit RBO is a 0 or 1
	   MOVLW	0X31	    ;runs this line if RB0 is a 1 skips if 0 moves an ascii 1 to the working register
	   BTFSC	PORTB, RB1  ;tests RB1 bit if a 1 or 0
	   MOVLW	0X32	    ;runs this line if RB1 is a 1 skips if 0 moves an ascii 2 to the working register
	   BTFSC	PORTB, RB2  ;tests RB2 bit if a 1 or 0
	   MOVLW	0X33	    ;runs this line if RB2 is a 1 skips if 0 moves an ascii 3 to the working register
	   BTFSC	PORTB, RB3  ;tests RB3 bit if a 1 or 0
	   MOVLW	0X34	    ;runs this line if RB3 is a 1 skips if 0 moves an ascii 4 to the working register
	   BTFSC	PORTB, RB4  ;tests RB4 bit if a 1 or 0
	   MOVLW	0X35	    ;runs this line if RB4 is a 1 skips if 0 moves an ascii 5 to the working register
	   BTFSC	PORTB, RB5  ;tests RB5 bit if a 1 or 0
	   MOVLW	0X36	    ;runs this line if RB5 is a 1 skips if 0 moves an ascii 6 to the working register
	   BTFSC	PORTB, RB6  ;tests RB6 bit if a 1 or 0
	   MOVLW	0X37	    ;runs this line if RB6 is a 1 skips if 0 moves an ascii 7 to the working register
	   BTFSC	PORTB, RB7  ;tests RB7 bit if a 1 or 0
	   MOVLW	0X38	    ;runs this line if RB7 is a 1 skips if 0 moves an ascii 8 to the working register
	   BANKSEL	PORTC	    ;select PORTC
	   MOVWF	PORTC	    ;move working register to PORTC
	  
GOTO			MAINBEGIN   ;loops back to main begin

	   END
;------- END MAIN ----------------------------------
	  