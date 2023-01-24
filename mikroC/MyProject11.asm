
_main:
	LDI        R27, 255
	OUT        SPL+0, R27
	LDI        R27, 0
	OUT        SPL+1, R27

;MyProject11.c,13 :: 		void main() {//F=16MHz Buad Rate 9600 BPS
;MyProject11.c,15 :: 		DDRJ=255;
	LDI        R27, 255
	STS        DDRJ+0, R27
;MyProject11.c,16 :: 		DDRB=255;
	LDI        R27, 255
	OUT        DDRB+0, R27
;MyProject11.c,17 :: 		DDRD=0;
	LDI        R27, 0
	OUT        DDRD+0, R27
;MyProject11.c,18 :: 		uartInit();
	CALL       _uartInit+0
;MyProject11.c,19 :: 		adcInit();
	CALL       _adcInit+0
;MyProject11.c,20 :: 		SREG.B7=1;//global interrupt bit
	IN         R27, SREG+0
	SBR        R27, 128
	OUT        SREG+0, R27
;MyProject11.c,21 :: 		EICRA=3;
	LDI        R27, 3
	STS        EICRA+0, R27
;MyProject11.c,22 :: 		EIMSK=1;
	LDI        R27, 1
	OUT        EIMSK+0, R27
;MyProject11.c,23 :: 		TCCR1A=0b00001001;
	LDI        R27, 9
	STS        TCCR1A+0, R27
;MyProject11.c,24 :: 		TCCR1B=0b00001000;
	LDI        R27, 8
	STS        TCCR1B+0, R27
;MyProject11.c,26 :: 		}
L_end_main:
L__main_end_loop:
	JMP        L__main_end_loop
; end of _main

_btn:
	PUSH       R30
	PUSH       R31
	PUSH       R27
	IN         R27, SREG+0
	PUSH       R27

;MyProject11.c,28 :: 		void btn() org 0x2 //external interrupt for button that exit python app
;MyProject11.c,31 :: 		press=1;
	LDS        R27, _press+0
	SBR        R27, BitMask(_press+0)
	STS        _press+0, R27
;MyProject11.c,33 :: 		}
L_end_btn:
	POP        R27
	OUT        SREG+0, R27
	POP        R27
	POP        R31
	POP        R30
	RETI
; end of _btn

_adcInit:

;MyProject11.c,34 :: 		void adcInit() //adc initial
;MyProject11.c,36 :: 		ADMUX=0b00000000;
	LDI        R27, 0
	STS        ADMUX+0, R27
;MyProject11.c,37 :: 		ADCSRA=0b10001111;
	LDI        R27, 143
	STS        ADCSRA+0, R27
;MyProject11.c,38 :: 		ADCSRB=0b00000000;
	LDI        R27, 0
	STS        ADCSRB+0, R27
;MyProject11.c,39 :: 		DIDR0=0b00000001;
	LDI        R27, 1
	STS        DIDR0+0, R27
;MyProject11.c,40 :: 		}
L_end_adcInit:
	RET
; end of _adcInit

_uartInit:

;MyProject11.c,42 :: 		void uartInit() //usart initial
;MyProject11.c,45 :: 		UCSR0B=0b11011000;  //TXENn, RXENn, TXCIEn, RXCIEn
	LDI        R27, 216
	STS        UCSR0B+0, R27
;MyProject11.c,46 :: 		UCSR0C=0b00000110;  //Asyn mode, size= 8bit
	LDI        R27, 6
	STS        UCSR0C+0, R27
;MyProject11.c,47 :: 		UBRR0H=0;           //F=16MHz Buad Rate 9600 BPS
	LDI        R27, 0
	STS        UBRR0H+0, R27
;MyProject11.c,48 :: 		UBRR0L=103;
	LDI        R27, 103
	STS        UBRR0L+0, R27
;MyProject11.c,49 :: 		}
L_end_uartInit:
	RET
; end of _uartInit

_res:
	PUSH       R30
	PUSH       R31
	PUSH       R27
	IN         R27, SREG+0
	PUSH       R27

;MyProject11.c,51 :: 		void res() org 0x32 //program for USART0 Rx Complete
;MyProject11.c,53 :: 		input_char=UDR0;
	PUSH       R2
	PUSH       R3
	LDS        R16, UDR0+0
	STS        _input_char+0, R16
;MyProject11.c,54 :: 		if(input_char == '1')
	LDS        R16, _input_char+0
	CPI        R16, 49
	BREQ       L__res23
	JMP        L_res0
L__res23:
;MyProject11.c,56 :: 		PORTJ.B0 = ~PINJ.B0; // Replace "output_pin" with the actual pin number that the LED is connected to
	LDS        R27, PINJ+0
	LDS        R0, PORTJ+0
	CLT
	SBRS       R27, 0
	SET
	BLD        R0, 0
	STS        PORTJ+0, R0
;MyProject11.c,57 :: 		}
	JMP        L_res1
L_res0:
;MyProject11.c,59 :: 		else if(input_char=='3') //start ADC
	LDS        R16, _input_char+0
	CPI        R16, 51
	BREQ       L__res26
	JMP        L_res2
L__res26:
;MyProject11.c,61 :: 		startAdc();
	CALL       _startAdc+0
;MyProject11.c,62 :: 		}
	JMP        L_res3
L_res2:
;MyProject11.c,63 :: 		else if(input_char=='5')
	LDS        R16, _input_char+0
	CPI        R16, 53
	BREQ       L__res27
	JMP        L_res4
L__res27:
;MyProject11.c,65 :: 		if(press==1)
	LDS        R27, _press+0
	SBRS       R27, BitPos(_press+0)
	JMP        L_res5
;MyProject11.c,67 :: 		sendData(5);
	LDI        R27, 5
	MOV        R2, R27
	LDI        R27, 0
	MOV        R3, R27
	CALL       _sendData+0
;MyProject11.c,68 :: 		press=0;
	LDS        R27, _press+0
	CBR        R27, BitMask(_press+0)
	STS        _press+0, R27
;MyProject11.c,69 :: 		}
L_res5:
;MyProject11.c,70 :: 		}
	JMP        L_res6
L_res4:
;MyProject11.c,71 :: 		else if(input_char=='M')
	LDS        R16, _input_char+0
	CPI        R16, 77
	BREQ       L__res28
	JMP        L_res7
L__res28:
;MyProject11.c,73 :: 		offPwm();
	CALL       _offPwm+0
;MyProject11.c,74 :: 		}
	JMP        L_res8
L_res7:
;MyProject11.c,77 :: 		pwmVal = ((int)input_char) *2;
	LDS        R16, _input_char+0
	LDI        R17, 0
	LSL        R16
	ROL        R17
	STS        _pwmVal+0, R16
	STS        _pwmVal+1, R17
;MyProject11.c,78 :: 		onPwm(UDR0);
	LDS        R2, UDR0+0
	LDI        R27, 0
	MOV        R3, R27
	CALL       _onPwm+0
;MyProject11.c,79 :: 		}
L_res8:
L_res6:
L_res3:
L_res1:
;MyProject11.c,80 :: 		}
L_end_res:
	POP        R3
	POP        R2
	POP        R27
	OUT        SREG+0, R27
	POP        R27
	POP        R31
	POP        R30
	RETI
; end of _res

_sendData:

;MyProject11.c,82 :: 		void sendData(unsigned dataTX)//send data function
;MyProject11.c,84 :: 		while(UCSR0A.B5==0); //if UDRE0 ==1 (flag set)
L_sendData9:
	LDS        R27, UCSR0A+0
	SBRC       R27, 5
	JMP        L_sendData10
	JMP        L_sendData9
L_sendData10:
;MyProject11.c,85 :: 		UDR0 = dataTX;
	STS        UDR0+0, R2
;MyProject11.c,86 :: 		}
L_end_sendData:
	RET
; end of _sendData

_comAdc:
	PUSH       R30
	PUSH       R31
	PUSH       R27
	IN         R27, SREG+0
	PUSH       R27

;MyProject11.c,87 :: 		void comAdc() org 0x3A{  //program interrupt ADC Conversion Complete
;MyProject11.c,88 :: 		valL=ADCL;
	PUSH       R2
	PUSH       R3
	LDS        R16, ADCL+0
	STS        _valL+0, R16
	LDI        R27, 0
	STS        _valL+1, R27
;MyProject11.c,89 :: 		valH=ADCH;
	LDS        R16, ADCH+0
	STS        _valH+0, R16
	LDI        R27, 0
	STS        _valH+1, R27
;MyProject11.c,90 :: 		sendData(valH);
	LDS        R2, _valH+0
	LDS        R3, _valH+1
	CALL       _sendData+0
;MyProject11.c,91 :: 		delay_ms(200);
	LDI        R18, 17
	LDI        R17, 60
	LDI        R16, 204
L_comAdc11:
	DEC        R16
	BRNE       L_comAdc11
	DEC        R17
	BRNE       L_comAdc11
	DEC        R18
	BRNE       L_comAdc11
;MyProject11.c,92 :: 		sendData(valL);
	LDS        R2, _valL+0
	LDS        R3, _valL+1
	CALL       _sendData+0
;MyProject11.c,93 :: 		}
L_end_comAdc:
	POP        R3
	POP        R2
	POP        R27
	OUT        SREG+0, R27
	POP        R27
	POP        R31
	POP        R30
	RETI
; end of _comAdc

_startAdc:

;MyProject11.c,94 :: 		void startAdc(){
;MyProject11.c,95 :: 		PORTJ.B0 = 0;
	LDS        R27, PORTJ+0
	CBR        R27, 1
	STS        PORTJ+0, R27
;MyProject11.c,96 :: 		PORTJ.B1 = 1;
	LDS        R27, PORTJ+0
	SBR        R27, 2
	STS        PORTJ+0, R27
;MyProject11.c,97 :: 		delay_ms(200);
	LDI        R18, 17
	LDI        R17, 60
	LDI        R16, 204
L_startAdc13:
	DEC        R16
	BRNE       L_startAdc13
	DEC        R17
	BRNE       L_startAdc13
	DEC        R18
	BRNE       L_startAdc13
;MyProject11.c,98 :: 		PORTJ.B1 = 0;
	LDS        R27, PORTJ+0
	CBR        R27, 2
	STS        PORTJ+0, R27
;MyProject11.c,99 :: 		ADCSRA.B6=1; //start convertor
	LDS        R27, ADCSRA+0
	SBR        R27, 64
	STS        ADCSRA+0, R27
;MyProject11.c,101 :: 		}
L_end_startAdc:
	RET
; end of _startAdc

_transComp:
	PUSH       R30
	PUSH       R31
	PUSH       R27
	IN         R27, SREG+0
	PUSH       R27

;MyProject11.c,102 :: 		void transComp() org 0x36{ //program interrupt for USART0 Tx Complete
;MyProject11.c,103 :: 		PORTJ.B1 = 1;
	LDS        R27, PORTJ+0
	SBR        R27, 2
	STS        PORTJ+0, R27
;MyProject11.c,104 :: 		delay_ms(200);
	LDI        R18, 17
	LDI        R17, 60
	LDI        R16, 204
L_transComp15:
	DEC        R16
	BRNE       L_transComp15
	DEC        R17
	BRNE       L_transComp15
	DEC        R18
	BRNE       L_transComp15
;MyProject11.c,105 :: 		PORTJ.B1=0;
	LDS        R27, PORTJ+0
	CBR        R27, 2
	STS        PORTJ+0, R27
;MyProject11.c,106 :: 		}
L_end_transComp:
	POP        R27
	OUT        SREG+0, R27
	POP        R27
	POP        R31
	POP        R30
	RETI
; end of _transComp

_onPwm:

;MyProject11.c,108 :: 		void onPwm(unsigned pwm_val){
;MyProject11.c,109 :: 		TCCR1B=0b00001010;
	LDI        R27, 10
	STS        TCCR1B+0, R27
;MyProject11.c,110 :: 		OCR1CL=pwm_val;
	STS        OCR1CL+0, R2
;MyProject11.c,112 :: 		}
L_end_onPwm:
	RET
; end of _onPwm

_offPwm:

;MyProject11.c,113 :: 		void offPwm(){
;MyProject11.c,114 :: 		TCCR1B=0b00001000;
	LDI        R27, 8
	STS        TCCR1B+0, R27
;MyProject11.c,115 :: 		OCR1CL=0;
	LDI        R27, 0
	STS        OCR1CL+0, R27
;MyProject11.c,116 :: 		}
L_end_offPwm:
	RET
; end of _offPwm
