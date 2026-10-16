;================================Carson Bogart==================================
;===============================Lab 9 Serial Communication======================
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
RCSAVE	    EQU	    0X23	;used to clear the RcReg by moving in this reg
NEWVALUE    EQU	    0X24	;used as personal flag for when $ recieved
SERVOREG    EQU	    0X25	;used to change pw on servo
ADSAVEH	    EQU	    0X26
ADSAVEL	    EQU	    0X27

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
    BANKSEL	PORTA		;setup portA to use AN0 as analog input
    MOVLW	0X00		;-------/
    MOVWF	PORTA		;------/
    BANKSEL	TRISA		;-----/
    MOVLW	0X01		;----/
    MOVWF	TRISA		;---/
    BANKSEL	ANSEL		;--/
    MOVLW	0X01		;-/
    MOVWF	ANSEL		;/
    BANKSEL	PORTC		;setup portC to receive/transmit
    MOVLW	0X00		;----/
    MOVWF	PORTC		;---/
    BANKSEL	TRISC		;--/
    MOVLW	0X80		;-/
    MOVWF	TRISC		;/
    BANKSEL	PORTB		;setup portB to drive servo use as outputs
    MOVLW	0X00		;setup portB as digital output pins
    MOVWF	PORTB		;------/
    BANKSEL	TRISB		;-----/
    MOVLW	0X00		;----/
    MOVWF	TRISB		;---/
    BANKSEL	ANSELH		;--/
    MOVLW	0X00		;-/
    MOVWF	ANSELH		;/
;================ TIMER 2 SETUP ================================================
    BANKSEL	T2CON		;configure timer2 for desired time
    BCF		T2CON, TOUTPS3	;set timer2 postscaler for desired time
    BCF		T2CON, TOUTPS2	;--/
    BCF		T2CON, TOUTPS1	;-/
    BSF		T2CON, TOUTPS0	;/
    BCF		T2CON, T2CKPS1	;set timer2 prescaler for desired time
    BCF		T2CON, T2CKPS0	;/
    BANKSEL	PR2		;configure pr2 for desired delay time
    MOVLW	D'250'		;load PR2 register with 250
    MOVWF	PR2		;/
    BANKSEL	T2CON		;enable timer2
    BSF		T2CON, TMR2ON	;/
    BANKSEL	PIE1		;enable timer2 interrupt logic
    BSF		PIE1,TMR2IE	;/
    BANKSEL	PIR1		;clear timer 2 flag if one was raised
    BCF		PIR1,TMR2IF	;/
;================== TIMER 2 SETUP END ==========================================
;===================== AD SETUP BEGIN ==========================================
    BANKSEL	ADCON0		;cofigure ADC module
    BCF		ADCON0, ADCS0	;selects conversion clock (fosc/8)
    BSF		ADCON0, ADCS1	;/
    BANKSEL	ADCON1		;sets reference bits to vdd and vss
    BCF		ADCON1, VCFG1	;-/
    BCF		ADCON1, VCFG0	;/	
    BANKSEL	ADCON0		;configure analog channel select bits to use an0
    BCF		ADCON0, CHS3	;---/
    BCF		ADCON0, CHS2	;--/
    BCF		ADCON0, CHS1	;-/
    BCF		ADCON0, CHS0	;/
    BANKSEL	ADCON1		;set conversion result format as left justified
    BCF		ADCON1, ADFM	;/
    BANKSEL	ADCON0		;enable the ADC by setting adon
    BSF		ADCON0, ADON	;/
    BANKSEL	NEWVALUE	;set newvalue to do a conversion first thing
    BSF		NEWVALUE,1	;/
    BANKSEL	PIR1		;clear flag because one will immediately raise
    BCF		PIR1, ADIF	;/		
;================ AD SETUP END =================================================
    BANKSEL	SPBRGH		;load high brg value becuase spbrg calulated 
    MOVLW	0X00		;value for desired baud rate is larger than 8
    MOVWF	SPBRGH		;bits
    BANKSEL	SPBRG		;load low brg value for desired spbrg value
    MOVLW	D'64'		;-/
    MOVWF	SPBRG		;/
    BANKSEL	BAUDCTL		;enable 16 bit register for use
    BCF		BAUDCTL,BRG16	;/
    BANKSEL	TXSTA		;enable asynchronous serial by clearing sync
    BSF		TXSTA,BRGH	;and setting spen and setup high speed baud rate
    BCF		TXSTA,SYNC	;--/
    BANKSEL	RCSTA		;-/
    BSF		RCSTA,SPEN	;/
    BANKSEL	TXSTA		;ensure ninth bit clear
    BCF		TXSTA,TX9	;/
    BSF		TXSTA,TXEN	;enable transmit bit control bit
    BANKSEL	PIR1		;ensure flag of tx is not raised
    BCF		PIR1,TXIF	;/
    BANKSEL	PIE1		;ensure interrupt for tx isn't enabled
    BCF		PIE1,TXIE	;/
    BANKSEL	PIR1		;clear flag for receive
    BCF		PIR1,RCIF	;/
    BANKSEL	PIE1		;enable interrupt for rx
    BSF		PIE1,RCIE	;/
    BANKSEL	RCSTA		;ensure ninth bit rc is disabled
    BCF		RCSTA,RX9	;/
    BANKSEL	RCSTA		;enable continuous receive
    BSF		RCSTA,CREN	;/
    BANKSEL	PIE1		;enable recieve interrupt
    BSF		PIE1,RCIE	;/
    BCF		PIE1,TXIE	;ensure transmit isn't enabled
    BSF		PIE1,TMR2IE	;--/
    BSF		PIE1,ADIE	;enable ad interrupt
    BANKSEL	PIR1		;-/
    BCF		PIR1,TMR2IF	;clear timer 2 flag if one raised
    BCF		PIR1,TXIF	;ensure tx flag is clear
    BSF		INTCON,PEIE	;enable peripheral and global to recieve 
    BSF		INTCON,GIE	;interrupts
    GOTO	MAINBEGIN	;go to main begin after setup complete
; ----------INTERRUPT BEGIN ----------------------------------------------------
INTERRUPT 
    BANKSEL	WSAVE		;ensure in correct bank to save working
    MOVWF	WSAVE		;move working register into wsave		
    MOVF	STATUS, 0	;move status to working register to save
    MOVWF	STATUSSAVE	;save status into statussave
    BANKSEL	PIR1		;test if unread character in the recieve fifo
    BTFSC	PIR1,RCIF	;/
    CALL 	RCSUB		;clears/saves recieve fifo contents
    BANKSEL	PIR1		;ensure in correct bank to test flag
    BTFSC	PIR1,TMR2IF	;test if timer2 is equal to pr2 value
    CALL	T2CHECK		;increment a register to use later
    BANKSEL	PIR1		;ensure in correct bank to test flag
    BTFSC	PIR1,ADIF	;test ad flag 
    CALL	ADSUB		;clear ad flag and set personal flag
    BANKSEL	STATUSSAVE	;ensure in correct bank when restoring status
    MOVF	STATUSSAVE, 0	;restore status save to status     
    MOVWF	STATUS		;/
    MOVF	WSAVE,0		;restore working register values
    RETFIE			;return from interrupt enable
;------------- RC TEST SUB -----------------------------------------------------
RCSUB
    BANKSEL	RCREG		;ensure in correct bank when moving rcreg
    MOVF	RCREG,0		;move recieved value to gpr to clear rcif flag
    MOVWF	RCSAVE		;/
    BANKSEL	NEWVALUE	;set personal flag to indicate a receive
    BSF		NEWVALUE,0	;/
    RETURN  
;------------ TIMER 2 CHECK SUB ------------------------------------------------
T2CHECK	
    BANKSEL	PIR1		;ensure in correct bank to clear flag
    BCF		PIR1,TMR2IF	;clears the flag
    INCF	TCOUNT,1	;increment tcount2 a gpr to count interrupts
    MOVLW	D'200'		;load pr2 with 200
    SUBWF	TCOUNT,0	;subtract tcount2 from 200 to then reset if equ
    BTFSC	STATUS,2	;/
    CALL	RESETSUB	;reset tcount2 and set output bit
    RETURN
;------------- AD SUB ----------------------------------------------------------
ADSUB
    BANKSEL	PIR1		;ensure in correct bank to test adif flag
    BCF		PIR1,ADIF	;/
    BANKSEL	NEWVALUE	;set personal flag to indicate an ad interrupt
    BSF		NEWVALUE,1	;/
    RETURN
;--------------- RX SUB --------------------------------------------------------
    RXSUB
    BANKSEL	NEWVALUE	;ensure in correct bank to test personal flag
    BTFSC	NEWVALUE,3	;test personal flag for $ present on rx
    CALL	SERVODATA	;call to move rcvalue to servo register
    BANKSEL	RCSAVE		;ensure in correct bank to test
    MOVLW	0X24		;test if ascii $ is in the RC reg to tell if 
    SUBWF	RCSAVE,0	;valid data is following
    BTFSC	STATUS,2	;/
    BSF		NEWVALUE,3	;set personal flag for dollar sign present
    BANKSEL	RCSAVE		;ensure in correct bank to test if % is present
    MOVLW	0X25		;ascii % to tell pic to tx
    SUBWF	RCSAVE,0	;-/
    BTFSC	STATUS,2	;/
    CALL	TRANSITIONSUB	;call sub to set and clear personal flags
    BCF		NEWVALUE,0	;clear personal flag to not enter sub again
    RETURN
;------------------ SERVO DATA SUB ---------------------------------------------    
SERVODATA			
    BANKSEL	NEWVALUE	;ensure in correct bank to set/clear flags
    BCF		NEWVALUE,3	;clear dollar sign personal flag
    MOVF	RCSAVE,0	;move rcreg value to pwm register
    MOVWF	SERVOREG	;/
    RETURN
;------------------ TRANSITION SUB ---------------------------------------------
TRANSITIONSUB
    BANKSEL	NEWVALUE	;ensure in correct bank to set/clear flags
    BSF		NEWVALUE,2	;set flag to indicate tx is ready
    BSF		NEWVALUE,4	;set flag to indicate @ symbol
    BCF		NEWVALUE,0	;clear flag to avoid entering rcsub again
    RETURN
;------------------ TX SUB -----------------------------------------------------    
TXSUB
    BANKSEL	TXSTA		;ensure in correct bank to test if tsr is full
    BTFSS	TXSTA,TRMT	;if tsr is empty then return
    RETURN			;/
    BANKSEL	NEWVALUE	;ensure in correct bank to test if @ present
    BTFSC	NEWVALUE,4	;test if @ present
    CALL	TXATSUB		;call sub to move @ into txreg
    BANKSEL	TXSTA		;test if tsr empty
    BTFSS	TXSTA,TRMT	;-/
    RETURN			;/
    BANKSEL	NEWVALUE	;ensure in correct bank to tx high byte
    BTFSC	NEWVALUE,5	;test if high byte present
    CALL	TXADH		;call sub to load high byte in txreg
    BANKSEL	TXSTA		;test if tsr empty
    BTFSS	TXSTA,TRMT	;-/
    RETURN			;/
    BANKSEL	NEWVALUE	;ensure in correct bank to test if low byte
    BTFSC	NEWVALUE,6	;test if low byte present
    CALL	TXADL		;call sub to load low byte in txreg
    BCF		NEWVALUE,2	;clear personal flag to avoid entering txsub
    RETURN
;------------------ TX @ SUB ---------------------------------------------------    
TXATSUB
    BANKSEL	TXREG		;ensure in correct bank to move value in txreg
    MOVLW	0X40		;-/
    MOVWF	TXREG		;/
    BANKSEL	NEWVALUE	;ensure in correct bank to set an clear flags
    BCF		NEWVALUE,4	;clear @ flag
    BSF		NEWVALUE,5	;set high byte flag
    RETURN
;--------------------- TX ADH SUB ----------------------------------------------    
TXADH
    BANKSEL	ADSAVEH		;move advalueH to txreg 
    MOVF	ADSAVEH,0	;--/
    BANKSEL	TXREG		;-/
    MOVWF	TXREG		;/
    BANKSEL	NEWVALUE	;ensure in correct bank to set/clear flags
    BCF		NEWVALUE,5	;clear adh flag
    BSF		NEWVALUE,6	;set adl flag
    RETURN
;--------------------- TX ADL SUB ----------------------------------------------    
TXADL
    BANKSEL	ADSAVEL		;move advalueL to txreg
    MOVF	ADSAVEL,0	;--/	    
    BANKSEL	TXREG		;-/
    MOVWF	TXREG		;/
    BANKSEL	NEWVALUE	;ensure in correct bank to clear flag
    BCF		NEWVALUE,6	;clear adL flag
    RETURN
;--------------------- CONVERSION SUB ------------------------------------------    
CONVERSIONSUB
    BANKSEL	NEWVALUE	;ensure in correct bank to test if rx sub has 
    BTFSC	NEWVALUE,2	;been entered and not exited
    RETURN			;/
    BANKSEL	ADRESH		;move adresh to a register
    MOVF	ADRESH,0	;-/
    MOVWF	ADSAVEH		;/
    BANKSEL	ADRESL		;move adresl to register
    MOVF	ADRESL,0	;--/
    BANKSEL	ADSAVEL		;-/
    MOVWF	ADSAVEL		;/
    BANKSEL	NEWVALUE	;ensure in correct bank to clear ad flag
    BCF		NEWVALUE,1	;/
    BANKSEL	ADCON0		;set the go done bit to start another conversion
    BSF		ADCON0,GO_DONE	;/
    RETURN
;-------------- RESET SUB BEGIN ------------------------------------------------    
RESETSUB
    BANKSEL	PORTB		;ensure in correct bank to reset
    BSF		PORTB,RB7	;set output to change pulse width    
    CLRF	TCOUNT		;clear tcount2 register
    RETURN
; ------- MAIN BEGIN -----------------------------------------------------------
MAINBEGIN
    BANKSEL	NEWVALUE	;test if recieve interrupt was received
    BTFSC	NEWVALUE,0	;/
    CALL	RXSUB		;call sub to receive data from VB
    BANKSEL	NEWVALUE	;test if ad interrupt was recieved
    BTFSC	NEWVALUE,1	;/
    CALL	CONVERSIONSUB	;call sub to save converted values
    BANKSEL	NEWVALUE	;test if % sign is present
    BTFSC	NEWVALUE,2	;/ 
    CALL	TXSUB		;call sub to transmit from pic
    BANKSEL	SERVOREG	;compare servodata and count to set pw
    MOVF	SERVOREG,0	;---/
    SUBWF	TCOUNT,0	;--/
    BTFSC	STATUS,2	;-/
    BCF		PORTB,RB7	;/
    GOTO	MAINBEGIN	;create loop in main
    END
; -------------MAIN BEGIN END --------------------------------------------------






