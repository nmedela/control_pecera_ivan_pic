;********************************************************************
;Efecto de luz para pecera											*
;PUERTO A							FLAG							*
;Bit0 E/S                  			Bit0  avisa debe prender um     *
;Bit1 E/S            				Bit1  avisa debe prender dm     *
;Bit2 E/S            				Bit2  avisa debe prender uh     *
;Bit3 E/S            				Bit3  avisa debe prender dh     *
;Bit4 Salida         				Bit4  avisa si estas config 	*
;																	*
;PUERTO B															*
;Bit0   bcd             											*
;Bit1   bcd         												*
;Bit2   bcd            												*
;Bit3   bcd            												*
;Bit4   unidad minutos    											*
;Bit5   decena minutos												*
;Bit6   unidad hora													*
;Bit7   decena hora 												*
;********************************************************************
		list p=16f84A
		#include p16f84.inc

porta	 	equ	 	05h
portb	 	equ	 	06h		 ;el puerto b esta en la posicion 06h de la ram
trisb	 	equ	 	86h		 ;regis de config de puerto b esta en la direcc 86h de la ram
trisa	 	equ	 	85h
status	 	equ	 	03h
opcion   	equ	 	81h
tmr0	 	equ	 	01h							 ;registro de estado esta en la direcc 03h de la ram
contador 	equ	 	0ch
tempo1	 	equ	 	0dh
tempo2	 	equ	 	0eh
tempo3	 	equ	 	0fh
tempo4	 	equ	 	10h
stat     	equ	 	11h
acum	 	equ	 	12h
intcon	 	equ	 	0bh
flag	 	equ	 	13h
veces	 	equ	 	14h
unidad	 	equ	 	15h
decena	 	equ		16h
variables	equ	 	17h
contador2	equ	 	18h		;contador para apagar la alarma despues de 120s
timeraux	equ		19h
horas		equ		1bh
minutos		equ	 	1ch
segundos	equ	 	1dh
numero		equ		1eh

#define	 banco0	bcf	status,5
#define	 banco1	bsf	status,5

			org		00h		  		;arranca la configuracion
			goto	inicio


			org		04h			; INTERRUPCION DEL TIMER!
		
			bcf		intcon,2	;bajo la bandera de int
			movwf	acum		;---------------------
			movf	status,0     ;--UNA ESPECIE DE---- para el acumulador
			banco0	             ;----STACK POINTER--- y para el estado de las cosas
			movwf	stat        ;---------------------
			btfsc	flag,4
			goto	recarga
			incf	timeraux,1	;incremento y si desborda,
			btfss	status,2	;hace el incremento de 1 segundo
			goto	recarga		;rutina de interrupcion		
			incf	minutos,1			; DESDE ACA
			movfw	minutos;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;!!!!!
			sublw	3ch
			btfss	status,2											;CHEQUEAR LA RUTINA DE CONTEO DE HORA MINUTOS Y SEGUNDOS
			goto	recarga2
			clrf	minutos;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;ACA VA SEGUNDOS
			;incf	minutos,1
			;movlw	3ch
			;subwf	minutos,0
			;btfss	status,2
			;goto	recarga2
			;clrf	minutos
			incf	horas,1
			movlw	18h
			subwf	horas,0
			btfss	status,1
			goto	recarga2
			clrf	horas               ; HASTA ACA
			
			
			
recarga2	
			movlw	03ah 		;le vuelvo a cargar las cosas para que vuelva a hacer lo mismo.... con 3bh y b1 en tmr0 me atrasa 2 segundos en 10 minutos.... VA 3ah
			movwf	timeraux
			
recarga		movlw	0e8h
			movwf	tmr0
			btfsc	flag,0
			goto	seguimo
			btfsc	flag,1
			goto	siguemos
			btfsc	flag,2
			goto	siguemos2
			goto	siguemos3
			
seguimo		movfw	minutos
			movwf	variables
			call	bcd
			
			bcf		flag,0
			bsf		flag,1
			goto	unimin
siguemos	movfw	minutos
			movwf	variables
			call	bcd
			
			bcf		flag,1
			bsf		flag,2
			goto	decmin

siguemos2	movfw	horas	;horas
			movwf	variables
			call 	bcd
			bcf		flag,2
			bsf		flag,3
			goto	unihor
siguemos3	movfw	horas	;horas
			movwf	variables
			call 	bcd
			bsf		portb,7
			bcf		flag,3
			bsf		flag,0
			goto	dechor
unimin		movfw	unidad
			andlw	0fh
			movwf	unidad
			movfw	portb
			andlw	00h
			addwf	unidad,0

			andlw	0fh
			movwf	portb
			call	mostrar 
			bsf		portb,4
			goto	hecho
decmin		movfw	decena
			andlw	0fh
			movwf	decena
			movfw	portb
			andlw	00h
			addwf	decena,0
			movwf	portb
			call	mostrar	
			bsf		portb,5
			goto	hecho
unihor		movfw	unidad
			andlw	0fh
			movwf	unidad
			movfw	portb
			andlw	00h
			iorwf	unidad,0
			movwf	portb
			call	mostrar
			bsf		portb,6			
			goto 	hecho
dechor		movfw	decena
			andlw	0fh
			movwf	decena
			movfw	portb
			andlw	00h
			iorwf	decena,0
			movwf	portb
			call	mostrar
			bsf		portb,7
hecho		
			movf	stat,0		;--DUVUELVE-
			movwf	status		;-----EL----
			swapf	acum,1		;---STACK---
			swapf	acum,0		;--POINTER--
			retfie				;regresa de la interrupcion



inicio	clrf	porta
		banco1
		movlw	07h				; me ubico en el banco 1 para configurar puertos
		movwf	trisa		; pta 0 1 2  como entrada para configurar el reloj y pta 3 4 como salida
		clrf	trisb		;ptbs como salidas
		bcf		opcion,3	; pre. como TMR0
		bsf		opcion,0	; 1
		bcf		opcion,1	; 1 CONFIGURO PRE como 1/256  ( creo qe me da unos 50ms) pre= 111 y el tmr0 con 0x3c
		bsf		opcion,2	; 1
		bcf		opcion,5	; clock/4
		banco0				; me vuelvo a ubicar en el banco0
		bsf		intcon,7	;habilito las interrupciones globales
		bcf		intcon,5
		clrf 	porta
		
			clrf	flag	
			clrf  	portb		
			clrf 	contador
			clrf	tempo1
			clrf    tempo2
			movlw	0e8h 		;modifico el tmr0 para que desborde con 230 para 1 seg... para 10 ms 217..   E8!!!
			movwf	tmr0
			movlw	3ah		;memoria auxiliar para ayudar a el tmr0 y asi poder hacer una interrupcion de 1 segundo este me cuenta 17,, para 10ms 156
			movwf	timeraux
			clrf	decena
			clrf	unidad
			clrf	horas
			clrf	minutos
			clrf	segundos
			bsf		flag,0	;porngo que inicie el bit 0 de laflag para que me encienda la unidad de los minutos
			bsf		intcon,5	;habilito interrupcion TMR0
			bsf		flag,4
			bcf		flag,5
			
comienzo		;btfss	flag,5	;si esta en 0 quiere decir que configura los minutos, si esta en 1 configura las horas
ciclo2		btfss	porta,0 ;chequea el pulsador de arriba
			goto	pulsa0	;va a el pulsador de arriba
			btfss	porta,1 ;chequea el pulsador abajo
			goto	pulsa1; va a el pulsador de abajo
			btfss	porta,2
			goto	pulsa2	;va a el pulsador de aceptar
			goto	ciclo2

pulsa0		call	delay		;
			btfsc	porta,0
			goto	ciclo2
suelta0		btfss	porta,0
			goto	suelta0		;hasta que no suelte no sigue el pulsador de arriba
			btfss	flag,5		
			goto	conmin		;salta a incrementar los minutos
			incf	horas,1
			movlw	18h
			subwf	horas,0
			btfss	status,1;
			goto	ciclo2
			clrf	horas
			goto	ciclo2			

conmin		incf	minutos,1
			movlw	3ch
			subwf	minutos,0
			btfss	status,2
			goto	ciclo2
			clrf	minutos
			goto	ciclo2		;se fija con la resta si los minutos pasa os 59 y si pasa lo pone a 0



pulsa1		call	delay		;
			btfsc	porta,1
			goto	ciclo2
suelta1		btfss	porta,1
			goto	suelta1		;hasta que no suelte no sigue el pulsador de arriba
			btfss	flag,5		
			goto	conmin1		;salta a incrementar los minutos
			movfw	horas
			btfss	status,2;
			goto	decc
			movlw	17h
			movwf	horas
			goto	ciclo2			
decc		decf	horas,1
			goto	ciclo2

conmin1		movfw	minutos
			btfss	status,2;
			goto	decc1
			movlw	3bh
			movwf	minutos
			goto	ciclo2		;se fija con la resta si los minutos pasa os 59 y si pasa lo pone a 0
decc1		decf	minutos,1
			goto	ciclo2		
pulsa2:		call	delay		;
			btfsc	porta,2
			goto	ciclo2
suelta2		btfss	porta,2					; aceptar
			goto	suelta2
			btfsc	flag,5
			goto	chequeo
			bsf		flag,5
			goto	ciclo2

chequeo:	
			banco1
			clrf	trisa		; pta 0 1 2 3 4 como salida, para hacer juego de luces y chequeo
			banco0				; me vuelvo a ubicar en el banco0
			clrf	porta
			
chequeo1:	call    invierno
			goto	chequeo1		;HACER CHQUEO DE LAS HORAS PARA IR PRENDIENDO 

invierno:	
			return
		; EL PORTA EMPIEZA COMO ENTRADA PARA CONTROLAR EL RELOJ, EL RA4 TIENE QUE EMPEZAR EN 0, FIJARSE SI USAR LOS 4 PULSADORES,
		; DESPUES SE PONEN COMO SALIDAS Y DE A RATOS VA CHEUQEANDO A VER SI SE APRETO EL PULSADOR, SI SE APRETA PONER TODOS COMO ENTRADA, ASI SE CONFIGURA NUEVAMENTE EL RELOJ
		; cambia la variable horas y minutos.. ver bien que onda si esta bien puesto


mostrar 	movwf	portb
			return			



delay		MOVLW   01H                ; DELAY   ECUACION aproximadamente ( (((((3.tempo4)+5).tempo3)+7).tempo2) / 1Mhz )
			MOVWF   tempo1 
aca1    	MOVLW 	02H                       
  			MOVWF   tempo2
aca			movlw	064h
			movwf	tempo3
aca2		movlw	064h
			movwf	tempo4
aca4		decfsz	tempo4,1
			goto	aca4
			decfsz	tempo3,1
			goto	aca2                                                                
	    	DECFSZ	tempo2,1                                                                             
			GOTO    aca                                                                                                               
			DECFSZ  tempo1,1                                                                                
			GOTO    aca1  
			return	

bcd:		clrf	veces
bcd1		movlw	0ah		
    		subwf	variables,1
			btfss	status,0
			goto	negat
			btfsc	status,2
			goto	cerin
			incf	veces,1
			goto	bcd1
negat		comf	variables
			movfw	variables
			sublw	09h
fini		movwf	unidad
			movfw	veces
			movwf	decena
			return
cerin		incf	veces,1
			clrf	variables
			movfw	variables
			goto	fini

			end