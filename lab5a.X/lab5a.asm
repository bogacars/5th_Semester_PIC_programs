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
 COUNT1	 EQU	   0X20		    ;used to load for delay loop
;------ END CPU ----------------------------------------------------------------

;------ ORG BEGIN --------------------------------------------------------------
	    
	 ORG	    0X000	    ;start at memory location at 0x000
	 GOTO	    SETUP	    ;goes to setup to initialize ports
	 ORG	    0X004	    ;interrupt vector
	 GOTO	    INTERRUPT	    ;goes to interupt when one is present
	 GOTO	    MAINBEGIN	    ;goes to main begin to start program
;------- END ORG ---------------------------------------------------------------
;------- SETUP BEGIN -----------------------------------------------------------	    
SETUP
	 BANKSEL    PORTA	    ;initialize PORTB
	 CLRF	    PORTA	    ;//
	 BANKSEL    TRISA	    ;/
	 MOVLW	    0X00	    ;select TrisB to make PORTB inputs
	 MOVWF	    TRISA	    ;/
	 BANKSEL    ANSEL	    ;select ANSLEH to configure digital inputs
	 MOVLW	    0X00	    ;//
	 MOVWF	    ANSEL	    ;/
	 BANKSEL    PORTC	    ;initialize PORTC
	 CLRF	    PORTC	    ;/
	 BANKSEL    TRISC	    ;select TRISC to make PORTC outputs
	 MOVLW	    0XFF	    ;//
	 MOVWF	    TRISC	    ;/
	 BANKSEL    PORTC	    ;preload PortB
	 MOVLW	    0X01	    ;//
	 MOVWF	    PORTC	    ;/
	 GOTO	    MAINBEGIN	    ;after setup goes to mainbegin
;------ SETUP END --------------------------------------------------------------
;------ Interrupt begin --------------------------------------------------------	    
INTERRUPT
	    RETFIE
;------ Interrupt end ----------------------------------------------------------
DELAYSUB
	    
;delay for 500us to get 1 KHz on the output
	MOVLW	    D'163'	    ;load count1 with 163 to decrement
	MOVWF	    COUNT1	    ;///
LOOP1				    ;//
	DECFSZ	    COUNT1,1	    ;/
	GOTO	    LOOP1	    ;loop if value not zero
	RETURN	    MAINBEGIN	    ;return to mainbegin if 0 is present
;------ MAIN -------------------------------------------------------------------
MAINBEGIN 
	
	CALL	    DELAYSUB	    ;call delay sub
	MOVLW	    0X01	    ;anything input on PortB will be output on 
	XORWF	    PORTC, 0	    ;Portc when xor with a zero
	MOVWF	    PORTA	    ;/

	GOTO	    MAINBEGIN	    ;loops back to main begin to be continuous
	End
;------- END MAIN --------------------------------------------------------------

