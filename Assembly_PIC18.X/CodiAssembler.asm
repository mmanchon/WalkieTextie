LIST P=18F4321, F=INHX32
	#include <P18F4321.INC>	

;******************
;* CONFIGURACIONS *
;******************
	
	CONFIG	OSC = HS             
	CONFIG	PBADEN = DIG
	CONFIG	WDT = OFF

;*************
;* VARIABLES *
;*************

CONT_TEMPS EQU 0x00		    ;comptador d'interrupcions
RECEPCION EQU 0x01		    ;variable auxiliar on guardem la recepció i enviament de la SIO
SEGONS EQU 0x02			    ;comptador de  segons
BLINK5 EQU 0x03			    ;flag per indicar que estem en mode blinking de 5Hz
BLINK10 EQU 0x04		    ;flag per indicar que estem en mode blinking de 10Hz
ROTATE EQU 0x05			    ;flag per indicar el sentit en el que hem de rotar en mode sliding
F_SLIDE EQU 0x06		    ;flag que s'activa el primer cop que entrem a la funcio slide
AUX_H EQU 0x07			    ;variable auxiliarque utilitzem per tractar els LEDs High en mode slide
AUX_L EQU 0x08			    ;variable auxiliarque utilitzem per tractar els LEDs Low en mode slide
SLIDING EQU 0x09		    ;flag per indicar que estem en mode sliding
F_ENVIA EQU 0x10		    ;flag que s'activa el primer cop que entrem a la funcio d'enviar RF
INDEX EQU 0x11			    ;comptador de bits enviats d'un byte en RF
MAXBIT_H EQU 0x12		    ;comptador low del numero de bytes rebuts per la SIO
MAXBIT_L EQU 0x13		    ;comptador high del numero de bytes rebuts per la SIO
PER10 EQU 0x14			    ;variable on guardem l'equivalent al 10% del numero de bits a enviar
CONTA_BITS_L EQU 0x15		    ;comptador low del numero de btis que portem enviats per RF
CONTA_BITS_H EQU 0x16		    ;comptador high del numero de bits que portem enviats per RF
F_ENVIA_10 EQU 0x17 
F_ENVIA_ID_1 EQU 0x18
F_ENVIA_ID_2 EQU 0x19
F_ENVIA_ID_3 EQU 0x20
F_ENVIA_N EQU 0x21

;*************
;* CONSTANTS *
;*************


;*********************************
; VECTORS DE RESET I INTERRUPCI? *
;*********************************
 
	ORG 0x000000
RESET_VECTOR
	goto MAIN		

	ORG 0x000008
HI_INT_VECTOR
	goto	HIGH_INT	

	ORG 0x000018
LOW_INT_VECTOR
	retfie FAST
	
	ORG 0x000020
	
	DB 0x00, 0x00		    ;Taula que ens dona el valor equivalent al 10% delsbits totals
	DB 0x00, 0x00		    ;a enviar per RF a partir del numero total de bytes que hem d'enviar
	DB 0x00, 0x00
	DB 0x00, 0x00
	DB 0x00, 0x08
	DB 0x08, 0x08
	DB 0x08, 0x08
	DB 0x08, 0x08
	DB 0x08, 0x08
	DB 0x08, 0x10
	DB 0x10, 0x10
	DB 0x10, 0x10
	DB 0x10, 0x10
	DB 0x10, 0x10
	DB 0x10, 0x18
	DB 0x18, 0x18
	DB 0x18, 0x18
	DB 0x18, 0x18
	DB 0x18, 0x18
	DB 0x18, 0x20
	DB 0x20, 0x20
	DB 0x20, 0x20
	DB 0x20, 0x20
	DB 0x20, 0x20
	DB 0x20, 0x28
	DB 0x28, 0x28
	DB 0x28, 0x28
	DB 0x28, 0x28
	DB 0x28, 0x28
	DB 0x28, 0x30
	DB 0x30, 0x30
	DB 0x30, 0x30
	DB 0x30, 0x30
	DB 0x30, 0x30
	DB 0x30, 0x38
	DB 0x38, 0x38
	DB 0x38, 0x38
	DB 0x38, 0x38
	DB 0x38, 0x38
	DB 0x38, 0x40
	DB 0x40, 0x40
	DB 0x40, 0x40
	DB 0x40, 0x40
	DB 0x40, 0x48
	DB 0x48, 0x48
	DB 0x48, 0x48
	DB 0x48, 0x48
	DB 0x48, 0x48
	DB 0x48, 0x50
	DB 0x50, 0x50
	DB 0x50, 0x50
	DB 0x50, 0x50
	DB 0x50, 0x50
	DB 0x50, 0x58
	DB 0x58, 0x58
	DB 0x58, 0x58
	DB 0x58, 0x58
	DB 0x58, 0x58
	DB 0x58, 0x60	
	DB 0x60, 0x60
	DB 0x60, 0x60
	DB 0x60, 0x60
	DB 0x60, 0x60
	DB 0x60, 0x68
	DB 0x68, 0x68
	DB 0x68, 0x68
	DB 0x68, 0x68
	DB 0x68, 0x68
	DB 0x68, 0x70
	DB 0x70, 0x70
	DB 0x70, 0x70
	DB 0x70, 0x70
	DB 0x70, 0x70
	DB 0x70, 0x78
	DB 0x78, 0x78
	DB 0x78, 0x78
	DB 0x78, 0x78
	DB 0x78, 0x78
	DB 0x78, 0x80
	DB 0x80, 0x80
	DB 0x80, 0x80
	DB 0x80, 0x80
	DB 0x80, 0x80
	DB 0x80, 0x88
	DB 0x88, 0x88
	DB 0x88, 0x88
	DB 0x88, 0x88
	DB 0x88, 0x88
	DB 0x88, 0x90
	DB 0x90, 0x90
	DB 0x90, 0x90
	DB 0x90, 0x90
	DB 0x90, 0x90
	DB 0x90, 0x98
	DB 0x98, 0x98
	DB 0x98, 0x98
	DB 0x98, 0x98
	DB 0x98, 0x98
	DB 0x98, 0xA0
	DB 0xA0, 0xA0
	DB 0xA0, 0xA0
	DB 0xA0, 0xA0
	DB 0xA0, 0xA0
	DB 0xA0, 0xA8
	DB 0xA8, 0xA8
	DB 0xA8, 0xA8
	DB 0xA8, 0xA8
	DB 0xA8, 0xA8
	DB 0xA8, 0xB0
	DB 0xB0, 0xB0
	DB 0xB0, 0xB0
	DB 0xB0, 0xB0
	DB 0xB0, 0xB0
	DB 0xB0, 0xB8
	DB 0xB8, 0xB8
	DB 0xB8, 0xB8
	DB 0xB8, 0xB8
	DB 0xB8, 0xB8
	DB 0xB8, 0xC0
	DB 0xC0, 0xC0
	DB 0xC0, 0xC0
	DB 0xC0, 0xC0
	DB 0xC0, 0xC0
	DB 0xC0, 0xC8
	DB 0xC8, 0xC8
	DB 0xC8, 0xC8
	DB 0xC8, 0xC8
	DB 0xC8, 0xC8
	DB 0xC8, 0xD0
	DB 0xD0, 0xD0
	DB 0xD0, 0xD0
	DB 0xD0, 0xD0
	DB 0xD0, 0xD0
	DB 0xD0, 0xD8
	DB 0xD8, 0xD8
	DB 0xD8, 0xD8
	DB 0xD8, 0xD8
	DB 0xD8, 0xD8
	DB 0xD8, 0xE0
	DB 0xE0, 0xE0
	DB 0xE0, 0xE0
	DB 0xE0, 0xE0
	DB 0xE0, 0xE0
	DB 0xE0, 0xE8
	DB 0xE8, 0xE8
	DB 0xE8, 0xE8
	DB 0xE8, 0xE8
	DB 0xE8, 0xE8
	DB 0xE8, 0xF0


;***********************************
;* RUTINES DE SERVEI D'INTERRUPCI? *
;***********************************
	
HIGH_INT
	call RESET_TIMER	    ;carreguem el valor inicial al timer
	incf CONT_TEMPS,1,0	    ;incrementem el comptador d'interrupcions
	movlw 0xC8		    ;200d
	cpfseq CONT_TEMPS,0	    ;mirem si ha passat un segon
	    retfie FAST
	incf SEGONS,1,0		    ;incrementem la variable segons
	clrf CONT_TEMPS, 0	    ;posem el comptador d'interrupcions a 0
	retfie FAST
	
;****************************
;* MAIN I RESTA DE FUNCIONS *
;****************************

INIT_TIMER
;**************************************************************************
;* T0CON 10001000 (estan en orden los bits de abajo)                      *
;* TMR0ON 1 para activar el TIMER0                                        *
;* T08bit 0 para timer de 16bits                                          *
;* T0CS 0 para usar el clock interno                                      *
;* T0SE 0 para ir de low-to-high                                          *
;* PSA 1 para desactivar el prescaler (los siguientes bit son 0 entonces) *
;**************************************************************************
	movlw 0x88
	movwf T0CON,0
	bcf RCON,IPEN,0		    ;Reseteamos el bit IPEN de RCON
;*************************************************************************************************
;* E0h = 1110 0000                                                                               *
;* activamos todas las interrupciones                                                            *
;* activamos el bit de overflow                                                                  * 
;* desactivamos las interrupciones externas y hacemos que el registro de TIMER0 no haga overflow *
;*************************************************************************************************
	movlw 0xE0
	movwf INTCON, 0
	call RESET_TIMER
	return

INIT_VARS
	clrf CONT_TEMPS,0	    ;posem a 0 totes les variables i flags que utilitzarem
	clrf RECEPCION,0
	clrf BLINK5,0
	clrf BLINK10,0
	clrf SEGONS,0
	clrf ROTATE,0
	clrf SLIDING,0
	clrf F_SLIDE,0
	clrf AUX_H,0
	clrf AUX_L,0
	clrf F_ENVIA,0
	clrf INDEX,0
	clrf MAXBIT_H, 0
	clrf MAXBIT_L, 0
	clrf PER10, 0
	clrf CONTA_BITS_L, 0
	clrf CONTA_BITS_H, 0
	clrf F_ENVIA_10,0
	clrf F_ENVIA_ID_1,0
	clrf F_ENVIA_ID_2,0
	clrf F_ENVIA_ID_3,0
	clrf F_ENVIA_N,0
INIT_RAM
	movlw 0x80		    ;inicialitzem els punters de lectura i escriptura de la RAM a la posició inicial del nostre array
	movwf FSR0L, 0
	movwf FSR1L, 0
	clrf FSR0H, 0
	clrf FSR1H, 0
	return

INIT_PORT
	clrf TRISD,0		    ;els ports D i E seran tots de sortida
	clrf TRISE,0		
	clrf TRISA,0		    ;nomes RA0 sera de sortida
	movlw 0x03
	movwf TRISB,0		    ;nomes RB0 i RB1 seran d'entrada
	movlw 0xC0
	movwf TRISC,0		    ;Configurem com entrada els ports de la SIO RC6 y RC7
	clrf LATD, 0		    ;netegem els LEDs
	clrf LATE, 0
	return
	
INIT_SIO
;****************************************************
;* RCSTA 10010000                                   *
;* SPEN 1 Ponemos que podamos recibir               *
;* RX9 0 para recibir 8 bits                        *
;* SREN 0 no nos importa                            *
;* CREN 1 activamos el reciver                      *
;* ADDEN 0 no nos importa porque no tenemos el 9bit *
;* FERR 0 not farming error                         *
;* OERR 0 no overrun error                          *
;* RX9D el noveno bit                               *
;****************************************************
	movlw 0x90
	movwf RCSTA,0
;***********************************************
;* TXSTA 00100110                              *
;* CSRC 0 para transmitir con el clock externo *
;* Tx9 0 transmitiremos 8 bits                 *
;* TXEN 1 enable para poder transmitir         *
;* SYNC 0 ponemos la EUSART asyncrona          * 
;* SENDB 0 break del sincronismo               *
;* BRGH 1 lo ponemos a alta velocidad          *
;* TRMT 1 TSR para enviar datos esta vacio     *
;* TX9D 0 el noveno bit                        *
;***********************************************
	movlw 0x26
	movwf TXSTA,0
	clrf BAUDCON,0
;*********************************************************
;* para que el baudRate = 19.2k tenemos que              *
;* mirar los bits SYNC, BRGH y BRG16 (solo BRGH es 1)    *
;* asi que vamos a la tabla y miramos el valor 31d = 1Fh *
;*********************************************************
	movlw 0x40
	movwf SPBRG,0
	
	return
	
RESET_TIMER
;*******************************
;* tendremos un clock de 10MHz *
;* por lo que iremos a 400ns   *
;* 65539-12.500 = 53039        *
;* interrupcion cada 5ms       *
;*******************************
	movlw 0xCF
	movwf TMR0H,0
	movlw 0x2F
	movwf TMR0L,0
	bcf INTCON,TMR0IF,0	    ;reseteamos el bit de overflow
	return
	
;********
;* MAIN *
;********

MAIN
	call INIT_TIMER		    ;inicialitzacio dels ports, variables i configuracions
	call INIT_VARS
	call INIT_PORT
	call INIT_SIO
	
LOOP
	btfsc PORTB, 0, 0	    ;comrovem si ens han apretat el polsador carrega
	    goto CARREGA_M
	btfsc PORTB, 1, 0	    ;comrovem si ens han apretat el polsador envia
	    goto ENVIA_M
	btfsc PIR1,RCIF,0	    ;comprovem si hem rebut algo per la SIO
	    goto RECEPCION_PC
	btfss BLINK5,0,0	    ;comprovem si hem de fer el blink de 5hz
	    goto CONTINUA	    ;en cas de que no sigui necessari fer blink saltarem a la segeent comprovacio
	movlw 0x14		    ;si hem de fer el blink llavors comparem amb 40d que seran 200ms
	cpfslt CONT_TEMPS,0
	    goto BLINK
CONTINUA
	btfss BLINK10,0,0	    ;comprovem si hem de fer el blink de 10Hz
	    goto CONTINUA_2	    ;en cas de que no sigui necessari fer blink saltarem a la segeent comprovacio
	movlw 0x0A		    ;si hem de fer el blink llavors comparem amb 20d que seran 100ms
	cpfslt CONT_TEMPS,0	    
	    goto BLINK
CONTINUA_2
	btfss SLIDING,0,0	    ;comprova si hem de fer sliding
	    goto CONTINUA_3	    ;en cas de que no sigui necessari fer slide saltarem a la segeent comprovacio
	movlw 0x0A		    ;si hem de fer el slide llavors comparem amb 20d que seran 100ms
	cpfslt CONT_TEMPS,0
	    goto SLIDE
	goto LOOP
	
CONTINUA_3
	clrf F_SLIDE,0		    ;en cas que ja no haguem de fer slide posem a 0 el flag d'inici de slide
	goto LOOP
	
INIT_SLIDE
	clrf LATE,0		    ;posem a 0 slide high
	movlw 0x03		    ;carreguem el valor 0000 0011 inicial del slide low
	movwf LATD,0
	setf F_SLIDE,0		    ;activem el flag d'inici de slilde
	return

RECEPCION_PC
	clrf SLIDING, 0		    ;netegem els flags i posem els LEDs a 0
	clrf BLINK5, 0
	clrf BLINK10, 0
	clrf LATD, 0
	clrf LATE, 0
	movff RCREG, RECEPCION	    ;mirem què hem rebut del PC
	movlw 0x01
	cpfseq RECEPCION
	    goto ENVIA_RF_PC	    ;si el PC ens envia un 2 enviem el missatge de la RAM per RF
CARREGA_PC			    ;si el PC ens envia un 1 carreguem el missatge que ens envia a la RAM
	call INIT_ESCRIPTURA_RAM    ;inicialitzem els punters d'escriptura de la RAM a la posicio inicial
WAIT_BYTE
	btfss PIR1,RCIF,0	    ;esperem a rebre un byte del PC
	    goto WAIT_BYTE
REBUT_PC
	movff RCREG, RECEPCION
	movlw 0x00		    ;si el PC ens envia 0x00 s'ha acabat la recepcio i fem blink, sino guardem a la RAM
	cpfsgt RECEPCION, 0
	    goto SET_BLINK5	    ;activem el flag de blink de 5Hz
	movff RECEPCION, POSTINC0   ;guardem el byte rebut a la RAM
	call INC_MAXBIT
WHILE_TRAMA_PC
	btfsc PIR1, RCIF, 0	    ;esperem a rebre un nou byte
	    goto REBUT_PC
	goto WHILE_TRAMA_PC

SET_BLINK5
	setf BLINK5, 0		    ;activem el flag de blink de 5Hz i tornem al bucle
	goto LOOP
	
INC_MAXBIT
	incf MAXBIT_L, 1, 0	    ;incrementem el numero de bytes que portem llegits de la SIO
	btfss STATUS, C, 0
	    return
	incf MAXBIT_H, 1, 0
	clrf MAXBIT_L, 0
	return
	
	;IMPORTANTE FUNCION PARA SABER SI ESCRIBIMOS BIEN DE LA RAM
	;goto ENVIA_TX
	
;ENVIA_TX
	;call INIT_LECTURA_RAM
;COMPARA_PUNTERS_TX
	;movff RCREG,RECEPCION
	;movf FSR0L,0,0
	;cpfseq FSR1L, 0
	    ;goto DIFERENTS_TX
	;movf FSR0H,0,0
	;cpfseq FSR1H, 0
	    ;goto DIFERENTS_TX
	;goto IGUALS_TX
;DIFERENTS_TX
	;incf INDEX,1,0
	;movff POSTINC1, TXREG
;ENVIA_SIGUIENTE
	;btfsc PIR1,RCIF,0
	    ;goto COMPARA_PUNTERS_TX
	;goto ENVIA_SIGUIENTE
;IGUALS_TX
	;movlw 0x03
	;movwf TXREG,0
	;movff INDEX,LATD
	;goto LOOP
	
ENVIA_RF_PC
	call INIT_LECTURA_RAM	    ;inicialitzem els punters de lectura de la RAM la posicio inicial
	goto COMPARA_PUNTERS
	
CARREGA_M
	clrf SLIDING, 0		    ;netegem els flags i posem els LEDs a 0
	clrf F_SLIDE, 0
	clrf BLINK5, 0
	clrf BLINK10, 0
	clrf LATD, 0
	clrf LATE, 0
	clrf CONT_TEMPS, 0
	call ESPERA_REBOTS	    ;esperem 15ms de rebots
	btfss PORTB, 0, 0	    ;si es 0 eren rebots i esperarem que acabin per tornar al bucle
	    goto WHILE_CARREGA
	call ENVIA_PC		    ;demanem al PC que ens envii el text
	clrf CONT_TEMPS, 0
	clrf SEGONS, 0
ESPERA_10
	btfsc PIR1, RCIF,  0	    ;comprovem si el PC respon amb una trama
	    goto REBUT_2		    ;guardem la trama
	movlw 0x0A
	cpfseq SEGONS, 0	    ;comprovem si han passat 10 segons
	    goto ESPERA_10
	setf SLIDING, 0		    ;si han passat 10 segons passem a fr slide
WHILE_CARREGA
	btfsc PORTA, 0, 0	    ;esperem els rebots de baixada o que deixin de premer el polsador
	    goto WHILE_CARREGA
	goto LOOP
	
INIT_ESCRIPTURA_RAM
	clrf FSR0H,  0		    ;inicialitzem els punters a la primera posició del array a la RAM
	movlw 0x80
	movwf FSR0L, 0
	clrf INDEX, 0
	clrf MAXBIT_H, 0
	clrf MAXBIT_L, 0
	return

ENVIA_PC
	movlw 0x02		    ;enviem la trama 0000 0010 al PC per demanar un text
	movwf TXREG, 0
	return
	
REBUT_2
	call INIT_ESCRIPTURA_RAM    ;si es 1 inicialitzem els punters d'escriptura de la RAM
REBUT
	movff RCREG, RECEPCION	    
	movlw 0x00
	cpfsgt RECEPCION, 0	    ;comprovem si la trama rebuda es 0x00, si ho es hem acabat la recepcio
	    goto SET_BLINK5_M	    ;passem a fer blink de 10Hz
	movff RECEPCION, POSTINC0   ;guardem la trama a la memoria RAM
	call INC_MAXBIT
WHILE_TRAMA
	btfsc PIR1, RCIF, 0	    ;esperem una nova trama del PC
	    goto REBUT
	goto WHILE_TRAMA

SET_BLINK5_M
	setf BLINK5, 0		    ;activem el flag de blink de 10Hz
	goto WHILE_CARREGA	    ;esperem que deixin de premer el polsador
	
ESPERA_REBOTS
	movlw 0x03
	cpfseq CONT_TEMPS, 0	    ;comprovem si han passat 15ms
	    goto ESPERA_REBOTS
	return
		
ENVIA_M
	clrf SLIDING, 0		    ;posem els flags a 0 i netegem els LEDs
	clrf F_SLIDE, 0
	clrf BLINK5, 0
	clrf BLINK10, 0
	clrf LATD, 0
	clrf LATE, 0
	clrf CONT_TEMPS, 0	    ;posem el comptador de temps a 0
	call ESPERA_REBOTS	    ;esperem els rebots del polsador (15ms)
	btfss PORTB, 1, 0
	    goto WHILE_ENVIA
	call INIT_LECTURA_RAM	    ;inicialitzem els punters de lectura de la RAM
COMPARA_PUNTERS
	movf FSR0H, 0, 0
	cpfseq FSR1H, 0		    ;comparem els punters high de lectura i escriptura
	    goto DIFERENTS	    ;si son diferents enviem el valor dels punters
	movf FSR0L, 0, 0
	cpfseq FSR1L, 0		    ;comparem els punters low de lectura i escriptura
	    goto DIFERENTS	    ;si son diferents enviem el valor dels punters
	goto IGUALS		    ;si son iguals hem acabat la transmissio RF
DIFERENTS
	
	btfss F_ENVIA, 0, 0
	    goto INIT_RF	    ;enviem l'inici de transmissio RF i posem F_ENVIA a 1
	btfsc F_ENVIA_10,0,0
	    call ESPERA_10_RF
	btfsc F_ENVIA_N,0,0
	    goto ENVIA_N
	btfsc F_ENVIA_ID_1,0,0
	    goto ENVIA_ID_1
	btfsc F_ENVIA_ID_2,0,0
	    goto ENVIA_ID_2
	btfsc F_ENVIA_ID_3,0,0
	    goto ENVIA_ID_3
	movff POSTINC1, RECEPCION   
NEXT_BIT
	call COMPROVA_LEDS_P
	btfsc RECEPCION, 7, 0	    ;en funcio del bit 0 de la variable recepcion:
	    goto ENVIA_1	    ;enviem un 1 amb codi Manchester
ENVIA_0				    ;enviem un 0 amb codi Manchester
	btfss CONT_TEMPS,0,0	    ;esperem una interrupcio de timer (5ms)
	    goto ENVIA_0
	clrf CONT_TEMPS, 0	    ;posem a 0 el comptador d'interrupcions
	movlw 0x01
	movwf LATA, 0		    ;posem un 1 al RF
ENVIA_0_2
	btfss CONT_TEMPS,0,0	    ;esperem una interrupcio de timer (5ms)
	    goto ENVIA_0_2
	clrf CONT_TEMPS, 0	    ;posem a 0 el comptador d'interrupcions
	clrf LATA, 0		    ;posem un 0 al RF
	goto COMPARA_INDEX

ENVIA_1
	btfss CONT_TEMPS,0,0	    ;esperem una interrupcio de timer (5ms)
	    goto ENVIA_1	    
	clrf CONT_TEMPS, 0	    ;posem a 0 el comptador d'interrupcions
	clrf LATA, 0		    ;posem un 0 al RF
ENVIA_1_2
	btfss CONT_TEMPS,0,0	    ;esperem una interrupcio de timer (5ms)
	    goto ENVIA_1_2
	clrf CONT_TEMPS, 0	    ;posem a 0 el comptador d'interrupcions
	movlw 0x01
	movwf LATA, 0		    ;posem un 1 al RF
	goto COMPARA_INDEX
	
COMPARA_INDEX
	rlncf RECEPCION, 1, 0	    ;rotem la variable per posar el seguent bit a l aposicio 0
	incf INDEX, 1, 0	    ;incrementem el comptador de bits
	movlw 0x08
	cpfseq INDEX, 0		    ;si ja hem enviat 8 bits passem al seguent byte
	    goto NEXT_BIT	    ;anem a enviar el seguent bit
	clrf INDEX, 0		    ;anem a enviar el seguent byte
	goto COMPARA_PUNTERS
	
COMPROVA_LEDS_P
	incf CONTA_BITS_L, 1, 0	    ;incrementem el numer de bits que portem enviats
	movf CONTA_BITS_L, 0
	cpfseq PER10, 0		    ;comparem si hem enviat l'equivalent al 10% dels bits
	    return
	clrf CONTA_BITS_L, 0
	call ROTATE_PER100	    ;si hem enviat el 10% encenem un LED mes
	return
	
ROTATE_PER100
	movlw 0xFF
	cpfseq LATD, 0		    ;si ja tenim tot el LATD ences encenem els del LATE
	    goto INC_PER100
	movlw 0x00
	cpfsgt LATE, 0
	    goto INC_1
	movlw 0x03
	movwf LATE, 0
	return
INC_1
	incf LATE, 1, 0
	return
INC_PER100
	rlncf LATD, 1, 0	    ;rotem el valor dels LEDs, netegem el bit que hem rotat i hi  posem un 1
	movlw 0xFE
	andwf LATD, 1, 0
	incf LATD, 1, 0
	return
	
SET_LEDS_P
	movff MAXBIT_L,CONTA_BITS_L
	movff MAXBIT_H,CONTA_BITS_H
	movlw 0x20
	addwf CONTA_BITS_L, 1, 0    ;sumem 0x20 al valor de bytes totals per accedir a la taula
	btfss STATUS, C, 0
	    goto CONTINUA_SET_LEDS
	clrf CONTA_BITS_L, 0
	incf CONTA_BITS_H, 1, 0
CONTINUA_SET_LEDS
	clrf TBLPTRU, 0		    ;movem els valors als punters de l taula de la flash
	movff CONTA_BITS_H, TBLPTRH
	movff CONTA_BITS_L, TBLPTRL
	tblrd *			    ;llegim el valor de la taula
	movff TABLAT, PER10	    ;copiem el valor de la taula a la variable PER10
	clrf CONTA_BITS_L, 0	    ;posem el comptador de bits enviats a 0
	clrf CONTA_BITS_H, 0
	return
	
SET_SLIDE
	setf SLIDING, 0	;activem el flag que ens indica que hem de fer slide
	goto WHILE_ENVIA

IGUALS
	btfss F_ENVIA, 0, 0
	    goto SET_SLIDE
	clrf F_ENVIA, 0		    ;posem a 0 el flag d'inici de RF
	setf BLINK10, 0		    ;posem a 1 e flag de mode blinking de 10Hz

WHILE_ENVIA
	btfsc PORTB, 1, 0	    ;esperem que es deixi de premer el polsador envia
	    goto WHILE_ENVIA
	goto LOOP

INIT_RF
	setf F_ENVIA, 0		    ;activem el flag de init rf perque no torni a enviar l'inici
	movlw 0xFF
	movwf RECEPCION, 0	    ;carreguem la combinacio 1111 1111b perque s'envii en RF pr indicar l'inici de la trama
	call SET_LEDS_P
	clrf INDEX,0
	setf F_ENVIA_10,0
	goto NEXT_BIT
	
ESPERA_10_RF
	btfss CONT_TEMPS,0,0
	    goto ESPERA_10_RF
	clrf F_ENVIA_10,0
	clrf CONT_TEMPS, 0
	movlw 0x01
	clrf LATA,0
ESPERA_10_RF_2
	cpfseq CONT_TEMPS, 0
	    goto ESPERA_10_RF_2
	clrf CONT_TEMPS,0
	setf F_ENVIA_N,0
	return

ENVIA_ID_1
	movlw 0x01
	movwf RECEPCION,0
	clrf F_ENVIA_ID_1,0
	setf F_ENVIA_ID_2,0
	goto NEXT_BIT

ENVIA_ID_2
	movlw 0x02
	movwf RECEPCION,0
	clrf F_ENVIA_ID_2,0
	setf F_ENVIA_ID_3,0
	goto NEXT_BIT

ENVIA_ID_3
	movlw 0x03
	movwf RECEPCION,0
	clrf F_ENVIA_ID_3,0
	goto NEXT_BIT
	
ENVIA_N
	movlw 0x4E
	movwf RECEPCION,0
	setf F_ENVIA_ID_1,0
	clrf F_ENVIA_N,0
	goto NEXT_BIT

INIT_LECTURA_RAM
	clrf FSR1H, 0		    ;carreguem als punters de lectura la posicio inicial del array a la RAM
	movlw 0x80
	movwf FSR1L, 0
	clrf INDEX, 0
	return
	
BLINK
	clrf CONT_TEMPS,0	    ;posem el cont_temps a 0
	btfss LATD,0,0		    ;mirem si els LEDs estan a 0 o a 1
	    goto SET_LEDS
	clrf LATD,0		    ;posem a 0 els 10LEDs
	clrf LATE,0
	goto LOOP

SET_LEDS
	setf LATD,0		    ;podem a 1 els LEDs
	movlw 0x03
	movwf LATE,0
	goto LOOP

SLIDE
	clrf CONT_TEMPS, 0	    ;posem el comptador d'interrupcions a 0
	btfss F_SLIDE,0,0	    ;si es la primera vegada que iniciem sliding inicialitzem els LEDs
	    call INIT_SLIDE
	movff LATD, AUX_L	    ;copiem el valor dels LEds actual a les variables auxiliars
	movff LATE, AUX_H
	btfsc ROTATE, 0, 0	    ;comprovem cap on hem de girar, si es 1 anem a la dreta
	    goto ROTATE_RIGHT
	rlncf AUX_L, 1, 0	    ;rotem la variable cap a l'esquerra
	movlw 0xFE		    ;netegem el valor que hem introduit al rotar (1111 1110)
	andwf AUX_L, 1, 0
	movlw 0x80		    
	cpfseq AUX_L, 0		    ;si el valor de aux_l es 1000 0000b, haurem de posar un 01 a la part high
	    goto IF_2
	movlw 0x01		    ;posem un 1 a la part high
	movwf AUX_H, 0
	goto FINAL_SLIDE

IF_2
	movlw 0x01		    
	cpfseq AUX_H, 0		    ;si la part high ja es 01, haurem de posar 11
	    goto IF_3
	movlw 0x03		    ;posem 11 a la part high
	movwf AUX_H, 0
	goto FINAL_SLIDE

IF_3
	movlw 0x03
	cpfseq AUX_H, 0		    ;si la part high ja es 11, haurem de posar 01(h) 1000 0000(l) i canviar el sentit
	    goto FINAL_SLIDE
	movlw 0x01		    
	movwf AUX_H, 0		    ;posem un 01 a la part high	    
	movlw 0x80
	movwf AUX_L, 0		    ;posem un 1000 0000 a la part low
	setf ROTATE, 0		    ;canviem el sentit de la rotacio
	goto FINAL_SLIDE
  
ROTATE_RIGHT
	rrncf AUX_L, 1, 0	    ;rotem la variable cap a la dreta
	movlw 0x7F
	andwf AUX_L, 1, 0	    ;posem un 0 a l'esquerra
	movlw 0x01
	cpfseq AUX_H, 0		    ;si a la part high hi ha un 01b haurem de poosar (1100 0000) a la part low
	    goto IF_4
	movlw 0xC0		    ;1100 0000b
	movwf AUX_L, 0
	clrf AUX_H		    ;netegem la part high perque hi volem un 00b
	goto FINAL_SLIDE
	
IF_4
	movlw 0x01
	cpfseq AUX_L, 0		    ;mirem si hem arribat a l'ultim cas de la dreta (0000 0001)
	    goto FINAL_SLIDE
	movlw 0x06
	movwf AUX_L
	clrf ROTATE, 0		    ;canviem el sentit de rotacio
FINAL_SLIDE
	movff AUX_L, LATD	    ;movem els valors de les variables auxiliars als LEDs
	movlw 0x0C
	andwf LATE, 1, 0
	movff AUX_H, LATE
	goto LOOP

;*******
;* END *
;*******
  
	END