;================================Carson Bogart==================================
;===============================Lab 7 Stop Light================================
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
TCOUNT2	    EQU	    0X20	;used to increment on timer2 interrupt
WSAVE	    EQU	    0X21	;used to save working register in interrupt
STATUSSAVE  EQU	    0X22	;save status in interrupt
NEWVALUE    EQU	    0X23	;used as personal flag
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
    BSF		PORTC,RC7
    BANKSEL	TRISC		;setup portB and portC as inputs/outputs
    MOVLW	0X00		;portC outputs
    MOVWF	TRISC		;/
    MOVLW	0XFF		;portB inputs
    MOVWF	TRISB		;/
    BANKSEL	ANSELH		;configure portB as digital inputs
    CLRF	ANSELH		;/
;------------------ TIMER 2 SETUP BEGIN ----------------------------------------
    BANKSEL	PIE1		;enable trm2 overflow interrupt
    BSF		PIE1,TMR2IE	;/
    BANKSEL	T2CON		;configure timer2 for desired time
    BSF		T2CON, TOUTPS3	;set timer2 postscaler for desired time
    BSF		T2CON, TOUTPS2	;///
    BCF		T2CON, TOUTPS1	;//
    BCF		T2CON, TOUTPS0	;/
    BSF		T2CON, T2CKPS1	;set timer2 prescaler for desired time
    BSF		T2CON, T2CKPS0	;/
    BANKSEL	PR2		;configure pr2 for desired delay time
    MOVLW	D'240'		;//
    MOVWF	PR2		;/
    BANKSEL	T2CON		;enable timer2
    BSF		T2CON, TMR2ON	;/
;------------------ TIMER 2 SETUP END ------------------------------------------   
;------------------ INTCON SETUP BEGIN -----------------------------------------   
    BANKSEL	IOCB		;enable interrupts
    BSF		IOCB,IOCB1	;enable interrupt on change portB bit 1
    BSF		IOCB,IOCB2	;enable interrupt on change portB bit 2
    BSF		INTCON, RBIE	;enable portB change interrupt
    BSF		INTCON, PEIE	;enable peripherals
    BSF		INTCON, GIE	;enable global interrupt to recieve flags
    BANKSEL	PORTC		;bankselect portC to ensure in correct bank
;----------------- INTCON SETUP END --------------------------------------------    
    GOTO	MAINBEGIN	;go to main begin to execute main program	    
;------------ SETUP END --------------------------------------------------------
    
;------------ INTERRRUPT BEGIN -------------------------------------------------
INTERRUPT
    MOVWF	WSAVE		;move working register into wsave
    MOVF	STATUS, 0	;move status to working register to save
    MOVWF	STATUSSAVE	;save status into statussave
    BANKSEL	PIR1		;test tmr2 flag for interrupt
    BTFSC	PIR1, TMR2IF	;/
    CALL	TMR2OVERFLOW	;call sub to clear tmr2 flag
    BTFSC	INTCON, RBIF	;test if interrupt on change portB flag set
    CALL	CARCHECK	;call sub to clear flag if set
    MOVF	STATUSSAVE, 0	;restore status save to status
    MOVWF	STATUS		;/
    MOVF	WSAVE,0		;restore working register values
    RETFIE			;return from interrupt enable
; ----------- INTERRUPT END ----------------------------------------------------
;------------ CARCHECK SUB -----------------------------------------------------
CARCHECK
    BANKSEL	PORTB		;sub to clear flag from portB change
    BCF		INTCON, RBIF	;clear flag
    BTFSC	PORTB, RB2	;test if rb2 value changed
    BSF		NEWVALUE,0	;set newvalue bit 0 high for personal flag
    BTFSC	PORTB, RB1	;test if rb1 value changed
    BSF		NEWVALUE,1	;set newvalue bit 1 high as personal flag
    RETURN			;returns to interrupt
;------------ CARCHECK SUB END -------------------------------------------------
    
;------------ TMR2 OVERFLOW SUB BEGIN ------------------------------------------
TMR2OVERFLOW				
    BANKSEL	PIR1		;clear timer2 flag
    BCF		PIR1, TMR2IF	;/
    BANKSEL	PORTC
    BCF		PORTC,RC7
    INCF	TCOUNT2, 1	;increment tcount2 register to test timer2-
    RETURN			;overflow amount  
;------------ TMR2 OVERFLOW SUB END --------------------------------------------
    
;------------ LIGHT STATE 1 SUB BEGIN ------------------------------------------
LIGHTSTATE1
    BANKSEL	PORTC		;select portC to move values to output
    MOVLW	B'10111110'	;move values of NS: green EW: red to outputs
    MOVWF	PORTC		;outputs are active low
    BANKSEL	TCOUNT2		;ensure tcount2 is selected to test again
    RETURN			
;------------ LIGHTSTATE 1 SUB END ---------------------------------------------
  
;------------ LIGHT STATE 2 SUB BEGIN ------------------------------------------
LIGHTSTATE2
    BANKSEL	PORTC		;select portC to move values to output
    MOVLW	B'10111101'	;moves values of NS: Yellow EW: Red to outputs
    MOVWF	PORTC		;outputs are active low
    BANKSEL	TCOUNT2		;ensure tcount2 is selected to test again
    RETURN			
;------------ LIGHTSTATE 2 SUB END ---------------------------------------------
    
;------------ LIGHT STATE 3 SUB BEGIN ------------------------------------------
LIGHTSTATE3
    BANKSEL	PORTC		;select portC to move values to output
    MOVLW	B'11101011'	;move values of NS: red EW: green to outputs
    MOVWF	PORTC		;outputs are active low
    BANKSEL	TCOUNT2		;ensure tcount2 is selected to test again
    RETURN			
;------------ LIGHTSTATE 3 SUB END ---------------------------------------------
       
;------------ LIGHT STATE 4 SUB BEGIN ------------------------------------------
LIGHTSTATE4 
    BANKSEL	PORTC		;select portC to move values to output
    MOVLW	B'11011011'	;move values of NS: red EW: Yellow to outputs
    MOVWF	PORTC		;outputs are active low
    BANKSEL	TCOUNT2		;ensure tcount2 is selected to test again
    RETURN			
;------------ LIGHTSTATE 4 SUB END ---------------------------------------------    

;------------ N/S SUB BEGIN ----------------------------------------------------
NSSUB
    BANKSEL	NEWVALUE	;select newvalue to ensure in correct bank
    MOVLW	D'1'		;move a 1 to working to subtract and test 0 bit
    SUBWF	NEWVALUE,0	;/
    BTFSC	STATUS,2	;test if ns button has been pressed
    CLRF	TCOUNT2		;clear tcount2 to add more green time
    CLRF	NEWVALUE	;clear newvalue register
    RETURN	
;-------------- N/S SUB END ----------------------------------------------------
    
;--------------- E/W SUB BEGIN -------------------------------------------------
 EWSUB	
    BANKSEL	NEWVALUE	;select newvalue to ensure in correct bank
    MOVLW	D'2'		;move a 2 to working to subtract and test bit 0
    SUBWF	NEWVALUE,0	;/
    BTFSC	STATUS,2	;test if ew button has been pressed
    CALL	LOADCOUNT	;call sub to load tcount2 to add more green time
    CLRF	NEWVALUE	;clear newvalue register
    RETURN
;---------------- E/W SUB END --------------------------------------------------
;---------------- LOAD COUNT SUB BEGIN -----------------------------------------
 LOADCOUNT
    BANKSEL	TCOUNT2		;ensure in correct bank
    MOVLW	D'120'		;load 120 in count to add more green time if ew
    MOVWF	TCOUNT2		;button is pressed
    RETURN
;----------------- LOAD COUNT SUB END ------------------------------------------   
 
;------ MAIN -------------------------------------------------------------------
MAINBEGIN   
    MOVLW	0X00		;move 0 to subtract from current tcount2 value
    SUBWF	TCOUNT2,0	;/
    BTFSC	STATUS,2	;test if value resulted in zero bit
    CALL	LIGHTSTATE1	;call lightsub to display contents in sub
    MOVLW	D'99'		;move 99 to subtract from current tcount2 value
    SUBWF	TCOUNT2,0	;/
    BTFSC	STATUS,2	;test if value resulted in zero bit
    CALL	NSSUB		;call ns sub to test if ns button was pressed 
    MOVLW	D'100'		;move 100 to subtract from current tcount2 value
    SUBWF	TCOUNT2,0	;/
    BTFSC	STATUS,2	;test if value resulted in zero bit
    CALL	LIGHTSTATE2	;call lightsub to display contents in sub
    MOVLW	D'120'		;move 120 to subtract from current tcount2 value
    SUBWF	TCOUNT2,0	;/
    BTFSC	STATUS,2	;test if value resulted in zero bit
    CALL	LIGHTSTATE3	;call lightsub to display sub contents
    MOVLW	D'219'		;move 219 to subtract from current tcount2 value
    SUBWF	TCOUNT2,0	;test before yellow display to test car present
    BTFSC	STATUS,2	;test if value resulted in zero bit
    CALL	EWSUB		;call ew sub to test if ew button was pressed
    MOVLW	D'220'		;move 220 to subtract from current tcount2 value
    SUBWF	TCOUNT2,0	;/
    BTFSC	STATUS,2	;test if value resulted in zero bit
    CALL	LIGHTSTATE4	;call light sub to display sub contents
    MOVLW	D'240'		;move 240 to subtract from current tcount2 value
    SUBWF	TCOUNT2,0	;/
    BTFSC	STATUS,2	;test if count has reached max
    CLRF	TCOUNT2		;clear tcount2 value
    GOTO	MAINBEGIN
    END				;end program
;------- END MAIN --------------------------------------------------------------





