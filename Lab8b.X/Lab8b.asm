;================================Carson Bogart==================================
;===============================Lab 8 A/D converter=============================
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
STATUSSAVE  EQU	    0X21	;save status in interrupt
NEWVALUE    EQU	    0X22	;used as personal flag
ADRESULTH   EQU	    0X23	;used to save 8 bit ad conversion result high
ADRESULTL   EQU	    0X24	;used to save 8 bit ad conversion result low
ADVALUE	    EQU	    0X25	;used to shift the value right to output servo
TCOUNT2	    EQU	    0X26	;used to keep track of timer2 interrupts
ADVALUEL    EQU	    0X27
;------ END CPU ----------------------------------------------------------------
;------ ORG BEGIN --------------------------------------------------------------
    ORG		0X000		;start at memory location 0 in hard drive
    GOTO	SETUP		;go to setup to intialize ports
    ORG		0X004		;interrupt vector
    GOTO	INTERRUPT	;go to interrupt when interrupt present
    GOTO	MAINBEGIN	;go to main begin after interrupt
;------- END ORG ---------------------------------------------------------------
;----------------- SETUP BEGIN -------------------------------------------------
SETUP
    BANKSEL	PORTA		;clear portA and portC
    CLRF	PORTC		;////
    CLRF	PORTA		;///
    CLRF	PORTB		;//
    BANKSEL	TRISA		;configure portA bit 0 as input
    MOVLW	0X01		;//
    MOVWF	TRISA		;/
    MOVLW	0X00		;configure portC as outputs
    MOVWF	TRISC		;/
    MOVLW	0X00		;configure portB as outputs
    MOVWF	TRISB		;/
    BANKSEL	ANSEL		;configure portA as analog inputs 
    MOVLW	0X01		;//
    MOVWF	ANSEL		;/
    MOVLW	0X00		;configure portB as digital outputs
    MOVWF	ANSELH		;/
;===================== AD SETUP BEGIN ==========================================
    BANKSEL	ADCON0		;cofigure ADC module
    BCF		ADCON0, ADCS0	;selects conversion clock (fosc/8)
    BSF		ADCON0, ADCS1	;/
    BANKSEL	ADCON1		;sets reference bits to vdd and vss
    BCF		ADCON1, VCFG1	;//
    BCF		ADCON1, VCFG0	;/	
    BANKSEL	ADCON0		;configure analog channel select bits to use an0
    BCF		ADCON0, CHS3	;////
    BCF		ADCON0, CHS2	;///
    BCF		ADCON0, CHS1	;//
    BCF		ADCON0, CHS0	;/
    BANKSEL	ADCON1		;set conversion result format as left justified
    BCF		ADCON1, ADFM	;/
    BANKSEL	ADCON0		;enable the ADC by setting adon
    BSF		ADCON0, ADON	;/
    BANKSEL	PIR1		;clear flag because one will immediately raise
    BCF		PIR1, ADIF	;/		
;================ AD SETUP END =================================================
;================ TIMER 2 SETUP ================================================
    BANKSEL	PIE1		;enable timer2 and clear flag at the beginning
    BSF		PIE1,TMR2IE	;///
    BANKSEL	PIR1		;//
    BCF		PIR1,TMR2IF	;/    
    BANKSEL	T2CON		;configure timer2 for desired time
    BCF		T2CON, TOUTPS3	;set timer2 postscaler for desired time
    BCF		T2CON, TOUTPS2	;///
    BCF		T2CON, TOUTPS1	;//
    BSF		T2CON, TOUTPS0	;/
    BCF		T2CON, T2CKPS1	;set timer2 prescaler for desired time
    BCF		T2CON, T2CKPS0	;/
    BANKSEL	PR2		;configure pr2 for desired delay time
    MOVLW	D'250'		;//
    MOVWF	PR2		;/
    BANKSEL	T2CON		;enable timer2
    BSF		T2CON, TMR2ON	;/
;================== TIMER 2 SETUP END ==========================================
    BANKSEL	PIE1		;enable interrupts
    BSF		PIE1, ADIE	;/
    BSF		INTCON, PEIE	;enable peripheral and global
    BSF		INTCON, GIE	;to recieve interrupts
    GOTO 	MAINBEGIN	;go to main after setup
; ----------SETUP END ----------------------------------------------------------
; ----------INTERRUPT BEGIN ----------------------------------------------------
INTERRUPT
    MOVWF	WSAVE		;move working register into wsave
    MOVF	STATUS,0	;move status to working register to save
    MOVWF	STATUSSAVE	;save status into statussave
    BANKSEL	PIR1		;test if flag has been raised
    BTFSC	PIR1, TMR2IF	;/
    CALL 	T2CHECK		;call sub to clear flag and set personal flag
    BTFSC	PIR1,ADIF	;test the ad flag to see if went off
    CALL	ADSUB		;call sub to clear flag
    MOVF	STATUSSAVE,0	;restore status save to status   
    MOVWF	STATUS		;/
    MOVF	WSAVE,0		;restore working register values
    RETFIE			;return from interrupt enable
; ---------INTERRUPT END -------------------------------------------------------
; --------- AD SUB BEGIN -------------------------------------------------------
ADSUB
    BANKSEL	PIR1		;ensure in correct bank to clear flag
    BCF		PIR1, ADIF	;clear adif flag to recieve other interrupts
    BSF		NEWVALUE,0	;set personal flag for future testing
    RETURN			;return to interrupt
; ---------AD SUB END ----------------------------------------------------------
; ---------T2CHECK SUB BEGIN ---------------------------------------------------
T2CHECK
    BANKSEL	PIR1		;ensure in correct bank to clear flag
    BCF		PIR1,TMR2IF	;/
    INCF	TCOUNT2,1	;increment tcount2 to compare with advalue
    MOVLW	D'200'		;test if tcount2 is equal to 200
    SUBWF	TCOUNT2,0	;//
    BTFSC	STATUS,2	;test zero bit if tcount2 is equal to 200 
    CALL	SETOUTPUT	;call sub to clear tcount2 and set output
    RETURN
;----------- T2CHECK SUB END ---------------------------------------------------
;---------------- SET OUTPUT SUB BEGIN -----------------------------------------
SETOUTPUT
    BANKSEL	PORTB		;set output bit when tcount2 is equal to 200
    BSF		PORTB,RB7	;/
    CLRF	TCOUNT2		;clear tcount2 to restart count value
    RETURN
;----------------- SET OUTPUT SUB END ------------------------------------------
;-------CONVERSION SUB BEGIN ---------------------------------------------------
CONVERSIONSUB
    BANKSEL	ADRESH		;moves the high register contents to variable
    MOVF	ADRESH,0	;//
    MOVWF	ADRESULTH	;/
    MOVF	ADRESULTH,0	;move variable to output on portC	
    BANKSEL	PORTC		;display the value on adresulth on portC LEDS
    MOVWF	PORTC		;/   
    MOVF	ADRESULTH,0	;move adresultH into the register advalue
    MOVWF	ADVALUE		;/
    RRF		ADVALUE,0	;rotate advalue right placing lsb in msb
    MOVWF	ADVALUE		;/
    RRF		ADVALUE,0	;continue until upper four bits are rotated to 
    MOVWF	ADVALUE		;the four lower bits
    RRF		ADVALUE,0	;////
    MOVWF	ADVALUE		;///
    RRF		ADVALUE,0	;//
    MOVWF	ADVALUE		;/
    MOVLW	0X0F		;mask the advalue register for bottom 4 values
    ANDWF	ADVALUE,1	;/
    MOVLW	0X07		;add 7 to the advalue to compare with tcount2
    ADDWF	ADVALUE, 1	;/	
    BANKSEL	ADRESL		;moves the low register contents to variable
    MOVF	ADRESL,0	;///
    BANKSEL	ADRESULTL	;//
    MOVWF	ADRESULTL	;/
    BCF		NEWVALUE,0	;clear personal flag telling us interrput occur
    RETURN
;-------- CONVERSION SUB END ---------------------------------------------------
;----------- GOSUB BEGIN -------------------------------------------------------
GOSUB
    BANKSEL	ADCON0		;set go bit to start another conversion
    BSF		PORTA,RA3
    BSF		ADCON0,GO_DONE	;/
    BCF		PORTA,RA3
    BCF		NEWVALUE,1	;clear personal flag
    RETURN
;----------- GOSUB END ---------------------------------------------------------      
;========= CHECK UPPER AND LOWER BOUNDS OF ASSIGNED VALUES =====================    
CHECKLOWBYTE
    MOVLW	D'255'		;test if the low byte results in a carry 
    ADDWF	ADRESULTL,0	;//
    BTFSS	STATUS,0	;/
    CALL	CONDITION1	;display lower bound led
    RETURN  
TLOFFSUB
    MOVLW	D'254'		;test if the low byte results in a carry
    ADDWF	ADRESULTL,0	;//
    BTFSS	STATUS,0	;/
    CALL	CONDITION2	;turn off both leds in between upper and lower
    RETURN
;============ DISPLAY ASSIGNED VALUES ==========================================
CONDITION1
    BANKSEL	PORTA		;turns on lower bound led
    BSF		PORTA,RA1	;/
    BCF		PORTA,RA2	;make sure high led stays off
    RETURN
CONDITION2
    BANKSEL	PORTA		;turn off both leds becuase of in between states
    BCF		PORTA,RA1	;//
    BCF		PORTA,RA2	;/
    RETURN
;============ DISPLAY LOW REGISTER VALUES ======================================
LSBSUB
    BSF		NEWVALUE,1	;set personal flag to test after leaving sub
    BTFSC	ADRESULTL,7	;test if the msb in the low register is clear
    BSF		PORTB,RB0	;set the output led
    BTFSS	ADRESULTL,7	;test if msb is set
    BCF		PORTB,RB0	;clear output led
    BTFSC	ADRESULTL,6	;show the bottom of the 10 bits for accurate
    BSF		PORTB,RB1	;measurements when turning high and low led on
    BTFSS	ADRESULTL,6	;and off
    BCF		PORTB,RB1	;/
    RETURN   
TESTBOUNDSUB
    ;================= TEST LOW BOUDARIES ======================================
    BANKSEL	ADRESULTH	;test if adresulth results in carry to display
    MOVF	ADRESULTH,0	;lower led when below assigned value of 37
    SUBLW	D'10'		;//
    BTFSC	STATUS,0	;/
    CALL	CHECKLOWBYTE	;if no carry occured check low register values
    MOVF	ADRESULTH,0	;to decide what number is present on the input
    SUBLW	D'8'		;above this number turn led off 8 is msbs of 
    BTFSS	STATUS,0	;high register
    CALL	TLOFFSUB	;/
    
    ;================ TEST HIGH BOUNDARIES =====================================
    BANKSEL	ADRESULTH	;test the high register value to set/clear when
    MOVF	ADRESULTH	;the value goes above of below set value 
    MOVLW	D'250'		;///
    SUBWF	ADRESULTH,0	;//
    BTFSC	STATUS,0	;/
    GOTO	LOWSUB		;if a borrow is present test the exact count
    BANKSEL	PORTA		;if no borrow then keep the led off
    BCF		PORTA,RA2	;/
    RETURN
 LOWSUB	
    MOVLW	D'250'		;test if the number is equal to 250
    BANKSEL	ADRESULTH	;///
    SUBWF	ADRESULTH,0	;//
    BTFSC	STATUS,2	;/
    GOTO	LOWSUB2		;tests the low byte value
    BANKSEL	PORTA		;if zero is present then turn on the led
    BSF		PORTA,RA2	;/
    RETURN
LOWSUB2
    BANKSEL	ADRESULTL	;test the low register to see if the led should
    MOVF	ADRESULTL	;be on
    MOVLW	D'128'		;//
    SUBWF	ADRESULTL,0	;/
    BTFSC	STATUS,0	;check if borrow present and if so keep led off
    GOTO	SETSUB		;calls a sub to set the output when borrow
    BANKSEL	PORTA		;keeps led off
    BCF		PORTA,RA2	;/
    RETURN
SETSUB	
    BANKSEL	PORTA		;if borrow present when testing low byte turn
    BSF		PORTA,RA2	;led on
    RETURN
; ------- MAIN BEGIN -----------------------------------------------------------
MAINBEGIN
    BANKSEL	TCOUNT2		;ensure correct bank
    MOVLW	D'150'		;test if the count is equal to 150 
    SUBWF	TCOUNT2,0	;150 because the pic isn't doing anything at 
    BTFSC	STATUS,2	;that specific count
    CALL	LSBSUB		;set personal flag to test
    BTFSC	NEWVALUE,1	;test personal flag
    CALL	GOSUB		;set the go bit to start another conversion
    BANKSEL	NEWVALUE	;test if newvalue (interrupt) has been entered
    BTFSC	NEWVALUE,0	;/
    CALL	CONVERSIONSUB	;call sub to save conversion values to output
    BANKSEL	PORTB		;ensure in correct bank
    MOVF	ADVALUE,0	;test if advalue and tcount2 are equal to change
    SUBWF	TCOUNT2,0	;output pulse width
    BTFSC	STATUS,2	;//
    BCF		PORTB,RB7	;/
    MOVLW	D'170'
    SUBWF	TCOUNT2,0
    BTFSC	STATUS,2
    CALL	TESTBOUNDSUB
    GOTO	MAINBEGIN	;create loop
    END
; -------------MAIN BEGIN END --------------------------------------------------


