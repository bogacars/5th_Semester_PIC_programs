;==============Carson Bogart===============
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
	    MOVLW	0X0F	    ;sets half of PORTB to inputs and outputs
	    MOVWF	TRISB	    ;moves all 1's to TRISB to set PORTB as inputs
	    BANKSEL	ANSELH	    ;select ANSELH
	    MOVLW	0X00	    ;sets ANSELH to zero
	    MOVWF	ANSELH	    ;makes all of PORTB from analog inputs to digital inputs
	    BANKSEL	PORTC	    ;select PORTC to initialize
	    CLRF	PORTC	    ;clear PORTC to ensure port is empty
	    BANKSEL	TRISC	    ;select TRISC
	    MOVLW	0X00	    ;sets PORTC as outputs
	    MOVWF	TRISC	    ;sets PORTC as outputS
	   
	   
	    
GOTO	    MAINBEGIN
	    
INTERRUPT
	    
	    
	    RETFIE
	    
	    
;------ MAIN ---------------------------------------
MAINBEGIN
	
	 
	 MOVLW	    0X00
	 
	 
	 
	 BSF	    PORTB, RB7	    ;sets RB7 (column 1) as 1's to test the rows
	 BTFSC	    PORTB, RB0	    ;tests RB0 (row 1) to see if a 1 is present
	 MOVLW	    0X41	    ;skips if RB0 is a 0 if a 1 then loads an ASCii A
	 BTFSC	    PORTB, RB1	    ;tests RB1 (row 2) to see if a 1 is present
	 MOVLW	    0X42	    ;skips if RB1 is a 0 if a 1 then loads an ASCii B
	 BTFSC	    PORTB, RB2	    ;tests RB2 (row 3) to see if a 1 is present
	 MOVLW	    0X43	    ;skips if RB2 is a 0 if a 1 then loads an ASCii C
	 BTFSC	    PORTB, RB3	    ;tests RB3 (row 4) to see if a 1 is present
	 MOVLW	    0X44	    ;skips if RB3 is a 0 if a 1 then loads an ASCii D
	 BCF	    PORTB, RB7	    ;clears RB7 (column 1) to begin testing other columns
	 
	 BSF	    PORTB, RB6	    ;sets RB6 (column 2) as 1's to test the rows
	 BTFSC	    PORTB, RB0	    ;tests RB0 (row 1) to see if a 1 is present
	 MOVLW	    0X33	    ;skips if RB0 is a 0 if a 1 then loads an ASCii 3
	 BTFSC	    PORTB, RB1	    ;tests RB1 (row 2) to see if a 1 is present
	 MOVLW	    0X36	    ;skips if RB1 is a 0 if a 1 then loads an ASCii 6
	 BTFSC	    PORTB, RB2	    ;tests RB2 (row 3) to see if a 1 is present
	 MOVLW	    0X39	    ;skips if RB2 is a 0 if a 1 then loads an ASCii 9
	 BTFSC	    PORTB, RB3	    ;tests RB3 (row 4) to see if a 1 is present
	 MOVLW	    0X23	    ;skips if RB3 is a 0 if a 1 then loads an ASCii #
	 BCF	    PORTB, RB6	    ;clears RB6 (column 2) to begin testing other columns
	 
	 BSF	    PORTB, RB5	    ;sets RB5 (column 3) as 1's to test the rows
	 BTFSC	    PORTB, RB0	    ;tests RB0 (row 1) to see if a 1 is present
	 MOVLW	    0X32	    ;skips if RB0 is a 0 if a 1 then loads an ASCii 2
	 BTFSC	    PORTB, RB1	    ;tests RB1 (row 2) to see if a 1 is present
	 MOVLW	    0X35	    ;skips if RB1 is a 0 if a 1 then loads an ASCii 5
	 BTFSC	    PORTB, RB2	    ;tests RB2 (row 3) to see if a 1 is present
	 MOVLW	    0X38	    ;skips if RB2 is a 0 if a 1 then loads an ASCii 8
	 BTFSC	    PORTB, RB3	    ;tests RB3 (row 4) to see if a 1 is present
	 MOVLW	    0X30	    ;skips if RB3 is a 0 if a 1 then loads an ASCii 0
	 BCF	    PORTB, RB5	    ;clears RB5 (column 3) to begin testing other columns
	 
	 BSF	    PORTB, RB4	    ;sets RB4 (column 4) as 1's to test the rows
	 BTFSC	    PORTB, RB0	    ;tests RB0 (row 1) to see if a 1 is present
	 MOVLW	    0X31	    ;skips if RB0 is a 0 if a 1 then loads an ASCii 1
	 BTFSC	    PORTB, RB1	    ;tests RB1 (row 2) to see if a 1 is present
	 MOVLW	    0X34	    ;skips if RB1 is a 0 if a 1 then loads an ASCii 4
	 BTFSC	    PORTB, RB2	    ;tests RB2 (row 3) to see if a 1 is present
	 MOVLW	    0X37	    ;skips if RB2 is a 0 if a 1 then loads an ASCii 7
	 BTFSC	    PORTB, RB3	    ;tests RB3 (row 4) to see if a 1 is present
	 MOVLW	    0X2A	    ;skips if RB3 is a 0 if a 1 then loads an ASCii *
	 BCF	    PORTB, RB4	    ;clears RB4 (column 4)
	 
	 BANKSEL    PORTC	    ;selects PORTC
	 MOVWF	    PORTC	    ;moves the working register to PORTC
	 
	 
	 GOTO	    MAINBEGIN	    ;goes back to mainbegin
	 

	   END
;------- END MAIN ----------------------------------
	  


