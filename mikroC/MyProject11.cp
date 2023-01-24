#line 1 "E:/University docs/Fourth year/Controllers/my project/MyProject11.c"

unsigned char input_char;

unsigned int valL, valH;
unsigned pwmVal;
void adcInit();
void uartInit();
void startAdc();
void sendData(unsigned);
void offPwm();
void onPwm(unsigned);
bit press;
void main() {

 DDRJ=255;
 DDRB=255;
 DDRD=0;
 uartInit();
 adcInit();
 SREG.B7=1;
 EICRA=3;
 EIMSK=1;
 TCCR1A=0b00001001;
 TCCR1B=0b00001000;

}

void btn() org 0x2
{

 press=1;

}
void adcInit()
{
 ADMUX=0b00000000;
 ADCSRA=0b10001111;
 ADCSRB=0b00000000;
 DIDR0=0b00000001;
}

void uartInit()
{

 UCSR0B=0b11011000;
 UCSR0C=0b00000110;
 UBRR0H=0;
 UBRR0L=103;
}

void res() org 0x32
{
 input_char=UDR0;
 if(input_char == '1')
 {
 PORTJ.B0 = ~PINJ.B0;
 }

 else if(input_char=='3')
 {
 startAdc();
 }
 else if(input_char=='5')
 {
 if(press==1)
 {
 sendData(5);
 press=0;
 }
 }
 else if(input_char=='M')
 {
 offPwm();
 }
 else
 {
 pwmVal = ((int)input_char) *2;
 onPwm(UDR0);
 }
}

void sendData(unsigned dataTX)
{
 while(UCSR0A.B5==0);
 UDR0 = dataTX;
}
void comAdc() org 0x3A{
 valL=ADCL;
 valH=ADCH;
 sendData(valH);
 delay_ms(200);
 sendData(valL);
}
void startAdc(){
 PORTJ.B0 = 0;
 PORTJ.B1 = 1;
 delay_ms(200);
 PORTJ.B1 = 0;
 ADCSRA.B6=1;

}
void transComp() org 0x36{
 PORTJ.B1 = 1;
 delay_ms(200);
 PORTJ.B1=0;
}

void onPwm(unsigned pwm_val){
 TCCR1B=0b00001010;
 OCR1CL=pwm_val;

}
void offPwm(){
 TCCR1B=0b00001000;
 OCR1CL=0;
}
