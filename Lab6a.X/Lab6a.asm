;================================Carson Bogart==================================
;===============================Lab 6 Interrupts================================
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
COUNT1	    EQU	    0X20	;used for delay
COUNT2	    EQU	    0X21	;//
COUNT3	    EQU	    0X22	;/
WSAVE	    EQU	    0X23	;used to save working register in interrupt
STATUSSAVE  EQU	    0X24	;save status in interrupt
NEWVALUE    EQU	    0X25	;used as personal flag
;------ END CPU ----------------------------------------------------------------

;------ ORG BEGIN --------------------------------------------------------------
    ORG		0X000		;start at memory location 0 in hard drive
    GOTO	SETUP		;go to setup to intialize ports
    ORG		0X004		;interrupt vector
    GOTO	INTERRUPT	;go to interrupt when interrupt present
    GOTO	MAINBEGIN	;go to main begin after interrupt
;------- END ORG ---------------------------------------------------------------
    
;------------ SETUP BEGIN ------------------------------------------------------
SETUP
    BANKSEL	PORTC		;clear both portC and portB 
    CLRF	PORTC		;//
    CLRF	PORTB		;/
    BANKSEL	TRISC		;setup portB and portC as inputs/outputs
    MOVLW	0X00		;portC outputs
    MOVWF	TRISC		;/
    MOVLW	0XFF		;portB inputs
    MOVWF	TRISB		;/
    BANKSEL	ANSELH		;configure portB as digital inputs
    CLRF	ANSELH		;/
    BANKSEL	IOCB		;enable interrupts
    BSF		IOCB,IOCB1	;enable interrupt on change portB bit 1
    BSF		IOCB,IOCB2	;enable interrupt on change portB bit 2
    BSF		INTCON, RBIE	;enable portB change interrupt
    BSF		INTCON, GIE	;enable global interrupt to recieve flags
    BANKSEL	PORTC		;bankselect portC to ensure in correct bank
    GOTO	MAINBEGIN	;go to main begin to execute main program
	    
;------------ SETUP END --------------------------------------------------------
    
;------------ INTERRRUPT BEGIN -------------------------------------------------
INTERRUPT
    MOVWF	WSAVE		;move working register into wsave
    MOVF	STATUS, 0	;move status to working register to save
    MOVWF	STATUSSAVE	;save status into statussave
    BTFSC	INTCON, RBIF	;test if interrupt on change portB flag set
    CALL	CLRRBIF		;call sub to clear flag if set
    MOVF	STATUSSAVE, 0	;restore status save to status
    MOVWF	STATUS		;/
    MOVF	WSAVE,0		;restore working register values
    RETFIE			;return from interrupt enable
; ----------- INTERRUPT END ----------------------------------------------------
    
;------------ CLEAR RBIF SUB ---------------------------------------------------
CLRRBIF				;sub to clear flag from portB change
    BANKSEL	PORTB		;bankselect portB to ensure in correct bank    
    BTFSC	PORTB,RB2	;test if bit 2 is set on portB
    CALL	DELAY7		;if bit set call delay sub
    MOVLW	0X01		;preload working to load newvalue if bit 1 set
    BTFSC	PORTB,RB1	;test if bit 1 is set
    MOVWF	NEWVALUE	;load 1 into newvalue to call delay 6 in main
    BCF		INTCON, RBIF	;clear flag
    RETURN			;returns to interrupt
;------------ CLEAR RBIF SUB END -----------------------------------------------
    
;------------ DELAY 6 SUB BEGIN ------------------------------------------------
DELAY6				;delay for 1.75sec
	    
    MOVLW	0X36		;display a 6 on dlg
    MOVWF	PORTC		;/
	    
    MOVLW	D'253'		;load count 1 with 253 for desired delay
    MOVWF	COUNT1		;/
LOOP1				;loop 1 begin 
    MOVLW	0X00		;load count 2 with 0 for desired delay
    MOVWF	COUNT2		;/
LOOP2				;loop 2 begin
    NOP				;nop to attain desired delay time
    NOP				;///////////////////////
    NOP				;//////////////////////
    NOP				;/////////////////////
    NOP				;////////////////////
    NOP				;///////////////////
    NOP				;//////////////////
    NOP				;/////////////////
    NOP				;////////////////
    NOP				;///////////////
    NOP				;//////////////
    NOP				;/////////////
    NOP	    			;////////////
    NOP				;///////////
    NOP				;//////////
    NOP				;/////////
    NOP				;////////
    NOP				;///////
    NOP				;//////
    NOP				;/////
    NOP				;////
    NOP				;///
    NOP				;//
    NOP				;/
	    
    DECFSZ	COUNT2,1	;decrement count 2 if not zero	   
    GOTO	LOOP2		;go to loop 2 when not zero
    DECFSZ	COUNT1,1	;decrement count 1 when not zero
    GOTO	LOOP1		;go to loop 2 when not zero
    MOVLW	D'249'		;load count 3 with 249 for desired delay
    MOVWF	COUNT3		;/
LOOP3				;loop 3 begin
    DECFSZ	COUNT3, 1	;decrement count 3 if not zero
    GOTO	LOOP3		;goto loop 3 when not zero
    NOP				;no operation
	    
    CLRF	NEWVALUE	;clear newvalue to remove a loop in mainbegin
	    
    RETURN			
	    
;------------ DELAY 6 SUB END --------------------------------------------------
    
;------------ DELAY 7 SUB BEGIN ------------------------------------------------
DELAY7				;delay for 2.5 seconds
    MOVLW	0X37		;display 7 on dlg when called
    MOVWF	PORTC		;/
	    
    MOVLW	D'250'		;load count 1 with 250 for desired delay
    MOVWF	COUNT1		;/
LOOP4				;loop 4 begin
    MOVLW	0X00		;load count 2 with 0 for desired delay
    MOVWF	COUNT2		;/
LOOP5				;loop 5 begin
    NOP				;no operation to attain desired delay time
    NOP				;///////////////////////////////////
    NOP				;//////////////////////////////////
    NOP				;/////////////////////////////////
    NOP				;////////////////////////////////
    NOP				;///////////////////////////////
    NOP				;//////////////////////////////
    NOP				;/////////////////////////////
    NOP				;////////////////////////////
    NOP				;///////////////////////////
    NOP				;//////////////////////////
    NOP				;/////////////////////////
    NOP				;////////////////////////
    NOP				;///////////////////////
    NOP				;//////////////////////
    NOP				;/////////////////////
    NOP				;////////////////////
    NOP				;///////////////////
    NOP				;//////////////////
    NOP				;/////////////////
    NOP				;////////////////
    NOP				;///////////////
    NOP				;//////////////
    NOP				;/////////////
    NOP				;////////////
    NOP				;///////////
    NOP				;//////////
    NOP				;/////////
    NOP				;////////
    NOP				;///////    
    NOP				;//////
    NOP				;/////
    NOP				;////
    NOP				;///
    NOP				;//
    NOP				;/
    DECFSZ	COUNT2,1	;decerement count2 skips next line if zero
    GOTO	LOOP5		;/
    DECFSZ	COUNT1,1	;decrement count1 skips next line if zero
    GOTO	LOOP4		;/
    MOVLW	D'249'		;load count3 with 249 to attain desired delay
    MOVWF	COUNT3		;/
LOOP6				;loop 6 begin
    NOP				;no operation to attain desired delay time
    NOP				;////////
    NOP				;///////
    NOP				;//////
    NOP				;/////
    NOP				;////
    NOP				;///
    NOP				;//
    NOP				;/
    DECFSZ	COUNT3, 1	;decrement count3 or skip if count at 0
    GOTO	LOOP6		;/
    NOP				;no operation to attain desired delay time
    NOP				;/////////
    NOP				;////////
    NOP				;///////
    NOP				;//////
    NOP				;/////
    NOP				;////
    NOP				;///
    NOP				;//
    NOP				;/
	    
    MOVLW	0X36		;display 6 for remainder of the display time of
    BTFSC	NEWVALUE,0	;6 if interrupted by 7
    MOVWF	PORTC		;/
    
    RETURN			
;------------ DELAY 7 SUB END --------------------------------------------------
	 

;------ MAIN -------------------------------------------------------------------
MAINBEGIN
    MOVLW	0X31		;display one at all times
    MOVWF	PORTC		;/
    BTFSC	NEWVALUE,0	;test newvalue if set then display for x time
    CALL	DELAY6		;/
    GOTO	MAINBEGIN	;creates loop
    END				;end program
;------- END MAIN --------------------------------------------------------------


