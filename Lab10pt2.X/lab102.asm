;============================Carson Bogart======================================
;=========================Lab 10 Write to EEPROM ===============================
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
;------ END DEFINE ------------------------------------------------------------
;------ CPU MEMORY MAP ---------------------------------------------------------
WSAVE	    EQU	    0X20	;used to save working register in interrupt
STATUSSAVE  EQU	    0X21	;save status in interrupT
TCOUNT	    EQU	    0X22	;used to keep track of timer 2 interrupts
NEWVALUE    EQU	    0X23	;personal flag register 
KEYPADVAL   EQU	    0X24	;saved keypad value press in this register
WRITECOUNT  EQU	    0X25	;counts the times written to eeprom
FINALCOUNT  EQU	    0X26	;writes number of keys presssed to eeprom to
				;play back values when play pressed
COUNT1	    EQU	    0X27	;used in delay for 500ms
COUNT2	    EQU	    0X28	;-/
COUNT3	    EQU	    0X29	;/
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
    BANKSEL	PORTA		;clear portA, portB, and portC to have known
    CLRF	PORTA		;values within the port
    CLRF	PORTB		;-/
    CLRF	PORTC		;/
    BANKSEL	TRISA		;make ra0-ra3 inputs for the keypad rows
    MOVLW	0X0F		;-/
    MOVWF	TRISA		;/
    MOVLW	0X07		;makes rb0-rb2 inputs for 3 buttons
    MOVWF	TRISB		;/
    MOVLW	0X00		;make all of portC outputs for dlg
    MOVWF	TRISC		;/
    BANKSEL	ANSEL		;portA and portB digital I/O pins
    MOVLW	0X00		;---/
    MOVWF	ANSEL		;--/
    MOVLW	0X00		;-/
    MOVWF	ANSELH		;/
    BANKSEL	NEWVALUE	;clear newvalues to have known startup on each
    BCF		NEWVALUE,2	;--/
    BCF		NEWVALUE,1	;-/
    BCF		NEWVALUE,0	;/
    BANKSEL	WRITECOUNT	;clear register to start at 0
    CLRF	WRITECOUNT	;/
    BANKSEL	FINALCOUNT	;clear count to start at 0
    CLRF	FINALCOUNT	;/
;================ TIMER 2 SETUP ================================================
    BANKSEL	T2CON		;configure timer2 for desired time
    BCF		T2CON, TOUTPS3	;set timer2 postscaler to 1:5 for desired time
    BSF		T2CON, TOUTPS2	;--/
    BCF		T2CON, TOUTPS1	;-/
    BCF		T2CON, TOUTPS0	;/
    BSF		T2CON, T2CKPS1	;set timer2 prescaler to 16 for desired time
    BSF		T2CON, T2CKPS0	;/
    BANKSEL	PR2		;configure pr2 for desired delay time
    MOVLW	D'250'		;load PR2 register with 250
    MOVWF	PR2		;/
    BANKSEL	T2CON		;enable timer2
    BSF		T2CON, TMR2ON	;/
;================== TIMER 2 SETUP END ==========================================
;================== READ DATA IN EE AT STARTUP =================================
    BANKSEL	EEADR		;select address where count was saved to recall
    MOVLW	0X20		;move the set address
    MOVWF	EEADR		;/
    BANKSEL	EECON1		;point to the eeprom memory and enable read
    BCF		EECON1,EEPGD	;point at EEPROM	
    BSF		EECON1,RD	;enable read
    BANKSEL	EEDATA		;select data to read from 
    MOVF	EEDATA,0	;move to the register to read
    BANKSEL	FINALCOUNT	;-/
    MOVWF	FINALCOUNT	;/
;================= INTERRUPT SETUP =============================================    
    BANKSEL	IOCB		;enable the interrupt on change portB
    BSF		IOCB,IOCB0	;enable interrupt receive on rb0 (play)
    BSF		IOCB,IOCB1	;enable interrupt receive on rb1 (record)
    BSF		IOCB,IOCB2	;;enable interrupt receive on rb2 (stop)
    BANKSEL	PIE1		;enable timer2 interrupt logic
    BSF		PIE1,TMR2IE	;/
    BANKSEL	PIR1		;clear timer 2 flag if one was raised
    BCF		PIR1,TMR2IF	;/  
    BSF		INTCON,PEIE	;enable peripheral and global to recieve 
    BSF		INTCON,GIE	;interrupts
    GOTO	MAINBEGIN	;go to main begin after setup complete
;========== INTERRUPT BEGIN ====================================================
INTERRUPT 
    BANKSEL	WSAVE		;ensure in correct bank to save working
    MOVWF	WSAVE		;move working register into wsave		
    MOVF	STATUS, 0	;move status to working register to save
    MOVWF	STATUSSAVE	;save status into statussave
    BANKSEL	PIR1		;ensure in correct bank to test flag
    BTFSC	PIR1,TMR2IF	;test if timer2 has equ pr2 value set at 250    
    CALL 	T2CHECK		;call sub to clear flag
    BTFSC	INTCON,RBIF	;test if an interrupt on change portB occured    
    CALL	BUTTONSETSUB	;call sub to tell which button was pressed    
    BANKSEL	STATUSSAVE	;ensure in correct bank when restoring status
    MOVF	STATUSSAVE,0	;restore status save to status     
    MOVWF	STATUS		;/
    MOVF	WSAVE,0		;restore working register values
    RETFIE			;return from interrupt enable
;====================== BUTTON SUB =============================================    
BUTTONSETSUB
    BCF		INTCON,RBIF	;clear flag on portB change
    BANKSEL	NEWVALUE	;ensure in correct bank to set personal flags
    BTFSC	PORTB,RB0	;test if rb0 change has occurred 
    BSF		NEWVALUE,0	;set play flag high
    BTFSC	PORTB,RB1	;test if rb1 change has occurred 
    BSF		NEWVALUE,2	;set record flag high
    BTFSC	PORTB,RB2	;test if rb2 change has occurred
    BCF		NEWVALUE,2	;clear the record flag
    RETURN
;===================== TIMER 2 CHECK SUB =======================================
T2CHECK	
    BANKSEL	PIR1		;ensure in correct bank to clear flag
    BCF		PIR1,TMR2IF	;clears the flag
    INCF	TCOUNT,1	;increment tcount2 a gpr to count interrupts
    MOVLW	D'251'		;load pr2 with 200
    SUBWF	TCOUNT,0	;subtract tcount2 from 200 to then reset if equ
    BTFSC	STATUS,2	;/
    CLRF	TCOUNT
    RETURN   
;--------------------- RECORD SUB ----------------------------------------------    
RECORDSUB
    BANKSEL	PORTC		;banksel to display R when record flag raised
    MOVLW	0X52		;-/        
    MOVWF	PORTC		;/
    CALL	KEYPADSUB	;call keypad sub to grab keypad pressed value
    BANKSEL	NEWVALUE	;test if the stop button has been pressed
    BTFSS	NEWVALUE,2	;/
    GOTO	RETURNSUB	;leave sub to clear flags and return to main    
    BANKSEL	PORTC		;displays returned keypad value from keypadsub
    MOVF	KEYPADVAL,0	;-/
    MOVWF	PORTC		;/
    BANKSEL	PORTB		;test to see if a button has been held or just
    MOVLW	0XF0		;pressed. turn on all rows
    MOVWF	PORTB		;/
    MOVF	PORTA,0		;test if a button was pressed on keypad
    SUBLW	0X00		;if no button was pressed create delay
    BTFSS	STATUS,2	;/
    GOTO	$-3		;goes up 3 lines of code
    BANKSEL	PORTB		;once valid key press clear portB and continue
    MOVLW	0X00		;-/
    MOVWF	PORTB		;/
    BTFSS	NEWVALUE,2	;test if stop button has been pressed
    GOTO	RETURNSUB	;go to sub to clear record flag
    ;write EEPROM start
    BANKSEL	WRITECOUNT	;move register that is incremented in address
    MOVF	WRITECOUNT,0	;to write to multiple addresses
    BANKSEL	EEADR		;-/
    MOVWF	EEADR		;/
    BANKSEL	KEYPADVAL	;move keypad value into the data written to 
    MOVF	KEYPADVAL,0	;EEPROM keypad press
    BANKSEL	EEDATA		;-/
    MOVWF	EEDATA		;/
    BANKSEL	EECON1		;point to EEPROM to write to EEPROM
    BCF		EECON1,EEPGD	;points to EEPROM
    BSF		EECON1,WREN	;set the write enable to be able to write
    BCF		INTCON,GIE	;disable interrupts so write doesn't get 
    BTFSC	INTCON,GIE	;interrupted
    GOTO	$-2		;ensure interrupt disabled, go up 2 lines
    MOVLW	0X55		;charge pump sequence operates over voltage
    MOVWF	EECON2		;range of device
    MOVLW	0XAA		;write 0xAA
    MOVWF	EECON2		;/
    BSF		EECON1,WR	;enable write to begin write
    BTFSC	EECON1,WR	;ensure write is complete
    GOTO	$-1		;go up one line of code to make sure wr disabled
    BANKSEL	EECON1		;point back to flash memory and disable write en
    BSF		EECON1,EEPGD	;point back at flash memory
    BCF		EECON1,WREN	;diable write
    BSF		INTCON,GIE	;enable interrupts 
    ;write EEPROM end
    BANKSEL	WRITECOUNT	;increment a register to keep track of # of 
    INCF	WRITECOUNT,1	;writes to EEPROM
    CALL	DELAYSUB	;delay after incrementing for 500ms
    GOTO	RECORDSUB	;loop back to begin only leave if max or stop
;------------------------ KEYPAD SUB -------------------------------------------
KEYPADSUB
    BTFSS	NEWVALUE,2	;test if the stop flag has been raised
    GOTO	BOTTOMSUB	;goes to the bottom of the sub to return
    MOVLW	D'10'		;test write count and prevent more than 10 from
    SUBWF	WRITECOUNT,0	;being loaded into eeprom
    BTFSC	STATUS,2	;/
    GOTO	RETURNSUB	;call sub to clear record flag 
    BANKSEL	PORTB		;ensure in correct bank to load value keypadval
    CLRF	KEYPADVAL	;ensure keypadvalue clear before writing to it
    MOVLW	0X00		;moves value to call table and do nothing if
    ;col1
    BSF		PORTB, RB7	;set column 1 high to test each row for- 
    BTFSC	PORTA, RA3	; check for value change on a row
    MOVLW	0X31		;key pressed "1"  
    BTFSC	PORTA, RA2	;//////
    MOVLW	0X34		;key pressed "4"  
    BTFSC	PORTA, RA1	;////
    MOVLW	0X37		;key pressed "7" 
    BTFSC	PORTA, RA0	;//
    MOVLW	0X2A		;key pressed "*"  
    BCF		PORTB, RB7	;clear column 1 to stop testing coloumn
    ;col2
    BSF		PORTB, RB6	;set column 2 high to test row for valchange
    BTFSC	PORTA, RA3	;check for value change   
    MOVLW	0X32		;key pressed "2"
    BTFSC	PORTA, RA2	;//////
    MOVLW	0X35		;key pressed "5"
    BTFSC	PORTA, RA1	;////	    
    MOVLW	0X38		;key pressed "8"
    BTFSC	PORTA, RA0	;//
    MOVLW	0X30		;key pressed "0"
    BCF		PORTB, RB6	;clear column to stop testing column
    ;col3
    BSF		PORTB, RB5	;set column 3 high to test row for valchange
    BTFSC	PORTA, RA3	;check for value change
    MOVLW	0X33		;key pressed "3"
    BTFSC	PORTA, RA2	;//////
    MOVLW	0X36		;key pressed "6"
    BTFSC	PORTA, RA1	;////
    MOVLW	0X39		;key pressed "9"
    BTFSC	PORTA, RA0	;//
    MOVLW	0X23		;key pressed "#"
    BCF		PORTB, RB5	;clear column 3 to stop testing 
    ;col4
    BSF		PORTB, RB4	;set column 4 high to test row for valchange
    BTFSC	PORTA, RA3	;check for value change
    MOVLW	0X41		;key pressed "A"
    BTFSC	PORTA, RA2	;////// 
    MOVLW	0X42		;key pressed "B"
    BTFSC	PORTA, RA1	;////
    MOVLW	0X43		;key pressed "C"	  
    BTFSC	PORTA, RA0	;//
    MOVLW	0X44		;key pressed "D"
    BCF		PORTB, RB4	;clear column 4 to stop testing column
    MOVWF	KEYPADVAL	;move any value within W to keypadval register
    SUBLW	0X00		;test if any button has been pressed
    BTFSC	STATUS,2	;/
    GOTO	KEYPADSUB	;loop back to beginning of sub
BOTTOMSUB    
				;return to sub with default value(0x00) or
    RETURN			;value if changed by pressing key
;-------------------- RETURN SUB -----------------------------------------------
RETURNSUB			
    BANKSEL	NEWVALUE	;clear record flag since in record sub
    BCF		NEWVALUE,2	;/
    BANKSEL	TCOUNT		;clear tcount to start at 0
    CLRF	TCOUNT		;/
    BANKSEL	WRITECOUNT	;clear writecount to start at address 0
    ;write EEPROM begin
    MOVF	WRITECOUNT,0	;move writecount value into final count to test
    MOVWF	FINALCOUNT	;at startup used to read back saved values
    BANKSEL	EEADR		;selects the address of 0x20 in EEPROM
    MOVLW	0X20		;--/
    BANKSEL	EEADR		;-/
    MOVWF	EEADR		;/
    BANKSEL	FINALCOUNT	;move final count to data of EEPROM write
    MOVF	FINALCOUNT,0	;--/
    BANKSEL	EEDATA		;-/    
    MOVWF	EEDATA		;/
    BANKSEL	EECON1		;point to storage location and enable write
    BCF		EECON1,EEPGD	;point to EEPROM        
    BSF		EECON1,WREN	;enable write to EEPROM
    BCF		INTCON,GIE	;turn off interrupts
    BTFSC	INTCON,GIE	;ensure interrupts off
    GOTO	$-2		;go up 2 lines of code
    MOVLW	0X55		;charge pump sequence operates over voltage of 
    MOVWF	EECON2		;the device to write
    MOVLW	0XAA		;write 0xAA
    MOVWF	EECON2		;/
    BSF		EECON1,WR	;set write
    BTFSC	EECON1,WR	;ensure write is complete and turned off
    GOTO	$-1		;go up 1 line
    BANKSEL	EECON1		;select memory location and disable write
    BSF		EECON1,EEPGD	;flash memory select    
    BCF		EECON1,WREN	;disable write
    BSF		INTCON,GIE	;enable interrupts
    ;write EEPROM end
    BANKSEL	NEWVALUE	;test if the record button has been pressed
    BTFSC	NEWVALUE,2	;if so then reset the write count
    CLRF	WRITECOUNT	;/
    RETURN			;return to mainbegin since sub was goto not call
;-------------------- PLAY SUB -------------------------------------------------
PLAYSUB
    BANKSEL	WRITECOUNT	;clear writecount to start at 0 when reading
    CLRF	WRITECOUNT	;/
    BANKSEL	TCOUNT		;clear tcount to blink for 1 sec
    CLRF	TCOUNT		;/
    BANKSEL	NEWVALUE	;clear the play flag
    BCF		NEWVALUE,0	;-/
    BCF		NEWVALUE,2	;/
    BANKSEL	PORTC		;move a P onto the dlg to display
    MOVLW	0X50		;-/
    MOVWF	PORTC		;/
    CALL	DELAYSUB	;display for 1 second
    CALL	DELAYSUB	;/
    BANKSEL	PORTC		;display a space to blink the P on display
    MOVLW	0X20		;-/
    MOVWF	PORTC		;/
    CALL	DELAYSUB	;delay for 500ms
    BANKSEL	WRITECOUNT	;ensure writecount is clear before reading
    CLRF	WRITECOUNT	;/
LOOP5
    MOVF	WRITECOUNT,0	;test if current count is equ to # of keypresses    
    SUBWF	FINALCOUNT,0	;will only read # of keypresses 
    BTFSC	STATUS,2	;/
    GOTO	PLAYCLEAR	;clear play flag and writecount
    ;read EEPROM begin 
    BANKSEL	WRITECOUNT	;move writecount in the address to start at 0
    MOVF	WRITECOUNT,0	;and increment through saved values    
    BANKSEL	EEADR		;-/
    MOVWF	EEADR		;/
    BANKSEL	EECON1		;set memory location and enable read
    BCF		EECON1,EEPGD	;point at EEPROM to read    
    BSF		EECON1,RD	;enable read
    BANKSEL	EEDATA		;display the data within the incremented adress
    MOVF	EEDATA,0	;on the dlg
    BANKSEL	PORTC		;-/
    MOVWF	PORTC		;/
    ;read EEPROM end
    BANKSEL	WRITECOUNT	;increment address to read all values saved
    INCF	WRITECOUNT,1	;/    
    CALL	DELAYSUB	;delay for 1 sec to increment slowly through
    CALL	DELAYSUB	;the adresses
    MOVLW	0X20		;display a blank in between read back values
    MOVWF	PORTC		;to ensure if all same value then diffentiate
    CALL	DELAYSUB	;delay for 500ms    
    GOTO	LOOP5		;go back to read again
;------------------- PLAY CLEAR ------------------------------------------------    
PLAYCLEAR
    BANKSEL	NEWVALUE	;clear play flag and record flag
    BCF		NEWVALUE,0	;-/
    BCF		NEWVALUE,2	;/
    BANKSEL	WRITECOUNT	;clear write count to start at 0
    CLRF	WRITECOUNT	;/
    BANKSEL	TCOUNT		;clear tcount to start at 0
    CLRF	TCOUNT		;/
    RETURN
;---------------------- BLINK "S" ----------------------------------------------    
BLINKS
    BANKSEL	TCOUNT		;ensure tcount 0 to get full 1 sec display of s
    CLRF	TCOUNT		;/
    BANKSEL	NEWVALUE	;toggle newvalue to change state on display
    MOVLW	0X02		;--/
    XORWF	NEWVALUE,1	;-/
    BTFSC	NEWVALUE,1	;/
    GOTO	CLEARSUB	;call sub to display a space
    BANKSEL	PORTC		;display s on dlg
    MOVLW	0X53		;"S"
    MOVWF	PORTC		;/
    RETURN
;------------------- CLEAR SUB -------------------------------------------------    
CLEARSUB
    BANKSEL	PORTC		;display a space on the dlg
    MOVLW	0X20		;" "
    MOVWF	PORTC		;/
    RETURN
;--------------------------- DELAY SUB -----------------------------------------   
DELAYSUB
    BANKSEL	COUNT1		;load count1 with value to acheive 500ms
    MOVLW	D'250'		;-/
    MOVWF	COUNT1		;/
LOOP1				;loop 1 start
    MOVLW	0X00		;load count2 with 256 to acheive 500ms
    MOVWF	COUNT2		;/
LOOP2				;loop 2 start			    
    NOP				;no operations (x36)
    NOP				;----------------------------------/
    NOP				;---------------------------------/
    NOP				;--------------------------------/
    NOP				;-------------------------------/
    NOP				;------------------------------/
    NOP				;-----------------------------/
    NOP				;----------------------------/
    NOP				;---------------------------/
    NOP				;--------------------------/
    NOP				;-------------------------/
    NOP				;------------------------/
    NOP				;-----------------------/
    NOP				;----------------------/
    NOP				;---------------------/
    NOP				;--------------------/
    NOP				;-------------------/
    NOP				;------------------/
    NOP				;-----------------/
    NOP				;----------------/
    NOP				;---------------/
    NOP				;--------------/
    NOP				;-------------/
    NOP				;------------/
    NOP				;-----------/
    NOP				;----------/
    NOP				;---------/
    NOP				;--------/
    NOP				;-------/
    NOP				;------/
    NOP				;-----/
    NOP				;----/
    NOP				;---/
    NOP				;--/
    NOP				;-/
    NOP				;/
    DECFSZ	COUNT2,1	;decrement count2 
    GOTO	LOOP2		;go back to loop2 start
    DECFSZ	COUNT1,1	;decerment count1
    GOTO	LOOP1		;go back to loop1 start
    MOVLW	D'249'		;load count3 with desired value for 500ms
    MOVWF	COUNT3		;/
LOOP3				;loop 3 start
    NOP				;no operation (x9) for desired time
    NOP				;-------/
    NOP				;------/
    NOP				;-----/
    NOP				;----/
    NOP				;---/
    NOP				;--/
    NOP				;-/
    NOP				;/
    DECFSZ	COUNT3,1	;decrement count3     
    GOTO	LOOP3		;go back to loop 3 start    
    NOP				;in-line no oeprations (x10) for desired time
    NOP				;--------/
    NOP				;-------/
    NOP				;------/
    NOP				;-----/
    NOP				;----/
    NOP				;---/
    NOP				;--/
    NOP				;-/
    NOP				;/
    RETURN
; ------- MAIN BEGIN -----------------------------------------------------------
MAINBEGIN
    BANKSEL	NEWVALUE	;test if record flag high (button press)
    BTFSC	NEWVALUE,2	;/
    CALL	RECORDSUB	;call sub to write EEPROM
    BANKSEL	NEWVALUE	;test if play button pressed
    BTFSC	NEWVALUE,0	;/
    CALL	PLAYSUB		;call sub to read EEPROM
    BANKSEL	TCOUNT		;1 sec to call sub to display an s
    MOVLW	D'250'		;---/
    SUBWF	TCOUNT,0	;--/  
    BTFSC	STATUS,2	;-/   
    CALL	BLINKS		;/
    GOTO	MAINBEGIN	;loop in main begin
    END
; -------------MAIN BEGIN END --------------------------------------------------


