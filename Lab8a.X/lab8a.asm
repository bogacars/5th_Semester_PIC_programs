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
    BANKSEL	PORTA		;clear portA and portC
    CLRF	PORTC		;//
    CLRF	PORTA		;/
    BANKSEL	TRISA		;configure portA bit 0 as input
    MOVLW	0X01		;//
    MOVWF	TRISA		;/
    MOVLW	0X00		;configure portC as outputs
    MOVWF	TRISC		;
    BANKSEL	ANSEL		;configure portA as analog inputs 
    MOVLW	0XFF		;//
    MOVWF	ANSEL		;/
    BANKSEL	ADCON0		;cofigure ADC module
    BSF		ADCON0, ADCS0	;selects conversion clock (fosc/8)
    BCF		ADCON0, ADCS1	;/
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
    BANKSEL	NEWVALUE	;set newvalue in main to call conversion sub
    BSF		NEWVALUE,0	;/
    BANKSEL	PIE1		;enable adie to recieve interrupts
    BSF		PIE1, ADIE	;/
    BSF		INTCON, PEIE	;enable peripheral and global
    BSF		INTCON, GIE	;to recieve interrupts
    GOTO 	MAINBEGIN	;go to main after setup
; ----------SETUP END ----------------------------------------------------------
; ----------INTERRUPT BEGIN ----------------------------------------------------
INTERRUPT
    BANKSEL	PORTA		;test the conversion time of the adc
    
    MOVWF	WSAVE		;move working register into wsave
    MOVF	STATUS, 0	;move status to working register to save
    MOVWF	STATUSSAVE	;save status into statussave
    BANKSEL	PIR1		;test if flag has been raised
    BTFSC	PIR1, ADIF	;/
    CALL 	ADSUB		;call sub to clear flag and set personal flag
    MOVF	STATUSSAVE, 0	;restore status save to status   
    MOVWF	STATUS		;/
    MOVF	WSAVE,0		;restore working register values
    BANKSEL	PORTA		;test the conversion time of the adc
    BCF		PORTA,RA1	;/
    RETFIE			;return from interrupt enable
; ---------INTERRUPT END -------------------------------------------------------
; --------- AD SUB BEGIN -------------------------------------------------------
ADSUB
    BCF		PIR1, ADIF	;clear adif flag to recieve other interrupts
    BSF		NEWVALUE,0	;set personal flag for future testing
    RETURN			;return to interrupt
; ---------AD SUB END ----------------------------------------------------------
; ------CONVERSION SUB BEGIN ---------------------------------------------------
CONVERSIONSUB
    BANKSEL	ADRESH		;moves the high register contents to variable
    MOVF	ADRESH,0	;//
    MOVWF	ADRESULTH	;/
    MOVF	ADRESULTH,0	;move variable to output on portC
    BANKSEL	PORTC
    MOVWF	PORTC		;/
    BANKSEL	ADRESL		;moves the low register contents to variable
    MOVF	ADRESL,0	;///
    BANKSEL	ADRESULTL	;//
    MOVWF	ADRESULTL	;/
    BCF		NEWVALUE,0	;clear personal flag telling us interrput occur
    BANKSEL	ADCON0		;set the go bit to start another conversion 
    BANKSEL	PORTA
    BCF		PORTA,RA1	;/
    BSF		ADCON0,GO_DONE	;/
    BANKSEL	PORTA
    BSF		PORTA,RA1
    RETURN
; ------- CONVERSION SUB END ---------------------------------------------------
; ------- MAIN BEGIN -----------------------------------------------------------
MAINBEGIN

    BANKSEL	NEWVALUE	;test if newvalue (interrupt) has been entered
    BTFSC	NEWVALUE,0	;/
    CALL	CONVERSIONSUB	;call sub to save conversion values to output	
    GOTO	MAINBEGIN	;create loop
    END
; -------------MAIN BEGIN END --------------------------------------------------
   



