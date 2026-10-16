;================================Carson Bogart==================================
;===============================Lab 10 Write to EEPROM =========================
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
WSAVE	    EQU	    0X20	;used to save working register in interrupt
STATUSSAVE  EQU	    0X21	;save status in interrupT
TCOUNT	    EQU	    0X22	;used to keep track of timer 2 interrupts
NEWVALUE    EQU	    0X23
KEYPADVAL   EQU	    0X24
WRITECOUNT  EQU	    0X25
FINALCOUNT  EQU	    0X26
COUNT1	    EQU	    0X27
COUNT2	    EQU	    0X28
COUNT3	    EQU	    0X29

;------ END CPU ----------------------------------------------------------------
;------ ORG BEGIN --------------------------------------------------------------
    ORG		0X000		;start at memory location 0 in hard drive
    GOTO	SETUP		;go to setup to intialize ports
    ORG		0X004		;interrupt vector
    GOTO	INTERRUPT	;go to interrupt when interrupt present
    GOTO	MAINBEGIN	;go to main begin after interrupt
;------- END ORG ---------------------------------------------------------------
;------ SETUP BEGIN ------------------------------------------------------------
SETUP
    BANKSEL	PORTA
    CLRF	PORTA
    CLRF	PORTB
    CLRF	PORTC
    BANKSEL	TRISA
    MOVLW	0X00
    MOVWF	TRISA
    MOVLW	0X7F
    MOVWF	TRISB
    MOVLW	0X00
    MOVWF	TRISC
    BANKSEL	ANSEL
    MOVLW	0X00
    MOVWF	ANSEL
    MOVLW	0X00
    MOVWF	ANSELH
;================ TIMER 2 SETUP ================================================
    BANKSEL	T2CON		;configure timer2 for desired time
    BCF		T2CON, TOUTPS3	;set timer2 postscaler for desired time
    BSF		T2CON, TOUTPS2	;--/
    BCF		T2CON, TOUTPS1	;-/
    BCF		T2CON, TOUTPS0	;/
    BSF		T2CON, T2CKPS1	;set timer2 prescaler for desired time
    BSF		T2CON, T2CKPS0	;/
    BANKSEL	PR2		;configure pr2 for desired delay time
    MOVLW	D'250'		;load PR2 register with 250
    MOVWF	PR2		;/
    BANKSEL	T2CON		;enable timer2
    BSF		T2CON, TMR2ON	;/
    
;================== TIMER 2 SETUP END ==========================================
    BANKSEL	IOCB
    BSF		IOCB,IOCB0
    BSF		IOCB,IOCB1
    BSF		IOCB,IOCB2
    BANKSEL	PIE1		;enable timer2 interrupt logic
    BSF		PIE1,TMR2IE	;/
    BANKSEL	PIR1		;clear timer 2 flag if one was raised
    BCF		PIR1,TMR2IF	;/  
    BSF		INTCON,PEIE	;enable peripheral and global to recieve 
    BSF		INTCON,GIE	;interrupts
    GOTO	MAINBEGIN	;go to main begin after setup complete
; ----------INTERRUPT BEGIN ----------------------------------------------------
INTERRUPT 
    BANKSEL	WSAVE		;ensure in correct bank to save working
    MOVWF	WSAVE		;move working register into wsave		
    MOVF	STATUS, 0	;move status to working register to save
    MOVWF	STATUSSAVE	;save status into statussave
    BANKSEL	PIR1		
    BTFSC	PIR1,TMR2IF	
    CALL 	T2CHECK		
    BTFSC	INTCON,RBIF	
    CALL	BUTTONSETSUB	
    BANKSEL	STATUSSAVE	;ensure in correct bank when restoring status
    MOVF	STATUSSAVE, 0	;restore status save to status     
    MOVWF	STATUS		;/
    MOVF	WSAVE,0		;restore working register values
    RETFIE			;return from interrupt enable
    
    
    
    
KEYPADSUB
    
    MOVLW	0X10		;moves value to call table and do nothing if
    BSF		PORTB, RB4	;set column 1 high to test each row for- 
    BTFSC	PORTB, RB0	; check for value change on a row
    MOVLW	0X31		;key pressed "1"  
    BTFSC	PORTB, RB1	;//////
    MOVLW	0X34		;key pressed "4"  
    BTFSC	PORTB, RB2	;////
    MOVLW	0X37		;key pressed "7" 
    BTFSC	PORTB, RB3	;//
    MOVLW	0X2A		;key pressed "*"  
    BCF		PORTB, RB4	;clear column 1 to stop testing coloumn
    BSF		PORTB, RB5	;set column 2 high to test row for valchange
    BTFSC	PORTB, RB0	;check for value change   
    MOVLW	0X32		;key pressed "2"
    BTFSC	PORTB, RB1	;//////
    MOVLW	0X35		;key pressed "5"
    BTFSC	PORTB, RB2	;////	    
    MOVLW	0X38		;key pressed "8"
    BTFSC	PORTB, RB3	;//
    MOVLW	0X30		;key pressed "0"
    BCF		PORTB, RB5	;clear column to stop testing column
	 
    BSF		PORTB, RB6	;set column 3 high to test row for valchange
    BTFSC	PORTB, RB0	;check for value change
    MOVLW	0X33		;key pressed "3"
    BTFSC	PORTB, RB1	;//////
    MOVLW	0X36		;key pressed "6"
    BTFSC	PORTB, RB2	;////
    MOVLW	0X39		;key pressed "9"
    BTFSC	PORTB, RB3	;//
    MOVLW	0X23		;key pressed "#"
    BCF		PORTB, RB6	;clear column 3 to stop testing 
	 
    BSF		PORTB, RB7	;set column 4 high to test row for valchange
    BTFSC	PORTB, RB0	;check for value change
    MOVLW	0X41		;key pressed "A"
    BTFSC	PORTB, RB1	;////// 
    MOVLW	0X42		;key pressed "B"
    BTFSC	PORTB, RB2	;////
    MOVLW	0X43		;key pressed "C"	  
    BTFSC	PORTB, RB3	;//
    MOVLW	0X44		;key pressed "D"
    BCF		PORTB, RB7	;clear column 4 to stop testing column
    RETURN			;return to sub with default value(0x10) or,
				;value if changed by pressing key
    
BUTTONSETSUB
    BCF		INTCON,RBIF
    BANKSEL	PORTB
    BTFSC	PORTB,
    CALL	PLAYSETSUB
    BTFSC	PORTB,RB1
    CALL	RECORDSETSUB
    BTFSC	PORTB,RB2
    CALL	STOPSETSUB
    RETURN
    
PLAYSETSUB
    BANKSEL	NEWVALUE
    BSF		NEWVALUE,0
    RETURN

STOPSETSUB
    BANKSEL	NEWVALUE
    BSF		NEWVALUE,1
    RETURN
    
RECORDSETSUB
    BANKSEL	NEWVALUE
    BSF		NEWVALUE,2
    RETURN

;------------ TIMER 2 CHECK SUB ------------------------------------------------
T2CHECK	
    BANKSEL	PIR1		;ensure in correct bank to clear flag
    BCF		PIR1,TMR2IF	;clears the flag
    INCF	TCOUNT,1	;increment tcount2 a gpr to count interrupts
    MOVLW	D'251'		;load pr2 with 200
    SUBWF	TCOUNT,0	;subtract tcount2 from 200 to then reset if equ
    BTFSC	STATUS,2	;/
    CALL	BLINKS
    RETURN
BLINKS
    BANKSEL	PORTC
    MOVLW	0X53
    XORWF	PORTC,1
    CLRF	TCOUNT
    RETURN
    

RETURNSUB
    BANKSEL	NEWVALUE
    BCF		NEWVALUE,2
    RETURN
    
    
    
RECORDSUB
    BANKSEL	PORTC
    MOVLW	0X52
    MOVWF	PORTC
    BSF		NEWVALUE,3
    BCF		NEWVALUE,2
    CALL	KEYPADSUB
    BANKSEL	KEYPADVAL
    MOVWF	KEYPADVAL
    BANKSEL	NEWVALUE
    BTFSC	NEWVALUE,1
    GOTO	RETURNSUB
    BANKSEL	KEYPADVAL
    MOVLW	0X16
    SUBWF	KEYPADVAL,0
    BTFSC	STATUS,2
    GOTO	RECORDSUB
    MOVF	KEYPADVAL,0
    MOVWF	PORTC
    CALL	DELAYSUB
    MOVF	WRITECOUNT,0
    BANKSEL	EEADR
    MOVWF	EEADR
    BANKSEL	KEYPADVAL
    MOVF	KEYPADVAL,0
    BANKSEL	EEDAT
    MOVWF	EEDAT
    BANKSEL	EECON1
    BCF		EECON1,EEPGD
    BSF		EECON1,WREN
    BCF		INTCON,GIE
    BTFSC	INTCON,GIE
    GOTO	$-2
    MOVLW	0X55
    MOVWF	EECON2
    MOVLW	0XAA
    MOVWF	EECON2
    BSF		EECON1,WR
    BSF		INTCON,GIE
    BTFSC	EECON1,WR
    GOTO	$-1
    BCF		EECON1,WREN
    BANKSEL	NEWVALUE
    INCF	WRITECOUNT,1
    GOTO	RECORDSUB
    
   
DELAYSUB
    MOVLW	D'250'
    MOVWF	COUNT1
LOOP1
    MOVLW	0X00
    MOVWF	COUNT2
LOOP2
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    DECFSZ	COUNT2,1
    GOTO	LOOP2
    DECFSZ	COUNT1,1
    MOVLW	D'249'
    MOVWF	COUNT3
LOOP3
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    DECFSZ	COUNT3,1
    GOTO	LOOP3
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    RETURN
; ------- MAIN BEGIN -----------------------------------------------------------
MAINBEGIN
    BANKSEL	NEWVALUE
    

    BTFSC	NEWVALUE,1
    BCF		NEWVALUE,2
    BTFSC	NEWVALUE,2
    CALL	RECORDSUB
;    MOVLW	D'250'
;    SUBWF	TCOUNT,0
;    BTFSC	STATUS,2
;    GOTO	MAINBEGIN
    ;MOVLW	0X53
    ;XORWF	PORTC,1
;    MOVLW	0X53
;    MOVWF	PORTC
    GOTO	MAINBEGIN
    END
; -------------MAIN BEGIN END --------------------------------------------------


