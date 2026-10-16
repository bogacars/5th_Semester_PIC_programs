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

COUNT1	    equ	    0X20	    ;used for delay loop 1
COUNT2	    equ	    0X21	    ;used for delay loop 2
COUNT3	    equ	    0X22	    ;used for delay loop 3
	    
;------ END CPU ----------------------------------------------------------------

;------ ORG BEGIN --------------------------------------------------------------
	    
	    ORG	    0X000	    ;start at memory location at 0x000
	    GOTO    SETUP	    ;goes to setup to initialize ports
	    ORG	    0X004	    ;interrupt vector
	    GOTO    INTERRUPT   ;goes to interupt when one is present
	    GOTO    MAINBEGIN   ;goes to main begin to start program
;------- END ORG ---------------------------------------------------------------
	    
SETUP
	   BANKSEL  PORTC	    ;initialize PORTC
	   CLRF	    PORTC	    ;/
	   BANKSEL  TRISC	    ;select TRISC to make PORTC outputs
	   MOVLW    0X00	    ;//
	   MOVWF    TRISC	    ;/
	   MOVLW    0X35	    ;load ascii 5 at startup to toggle
	   MOVWF    PORTC
	   GOTO	    MAINBEGIN	    ;after setup goes to mainbegin
;------Interrupt begin ---------------------------------------------------------	    
INTERRUPT
	    
	   RETFIE
	
;------ Interrupt end ----------------------------------------------------------
	    
;------ MAIN -------------------------------------------------------------------
MAINBEGIN		    
	   MOVLW    D'243'	    ;\
	   MOVWF    COUNT1	    ;move 243 to count1 to begin loop 1
LOOP1				    ;loop 1 begin
	   MOVLW    0X00	    ;\
	   MOVWF    COUNT2	    ;move 0 to count2 to begin loop 2
LOOP2				    ;loop 2 begin
	   NOP			    ;no operation for desired delay in loop 2
	   NOP			    ;////
	   NOP			    ;///
	   NOP			    ;//
	   NOP			    ;/
	   DECFSZ   COUNT2, 1	    ;decrement count 2 from 0 to 255
	   GOTO	    LOOP2	    ;executes if count 2 is 0
	   DECFSZ   COUNT1, 1	    ;decrement count 1 from 243 to 0
	   GOTO	    LOOP1	    ;executes when count 1 is 0
	   MOVLW    D'233'	    ;\
	   MOVWF    COUNT3	    ;move 233 to count 3 to begin loop 3
LOOP3				    ;begin loop 3
	   NOP			    ;no operation for desired delay in loop 3
	   NOP			    ;//
	   NOP			    ;/
	   DECFSZ   COUNT3, 1	    ;decrement count 3 from 233 to 
	   GOTO	    LOOP3	    ;executes when count 3 is 0
	   NOP			    ;in line no operations to make accurate
	   NOP			    ;//
	   NOP			    ;/
	
	
	   MOVLW    0X05	    
	   XORWF    PORTC,1	    ;xor 5 with 5 from PortC, from setup, to 
				    ;/to toggle between 5 and zero
	   GOTO	    MAINBEGIN	    ;loops back to main begin to be continuous
	   END			    ;main begin end
;------- END MAIN --------------------------------------------------------------
	  