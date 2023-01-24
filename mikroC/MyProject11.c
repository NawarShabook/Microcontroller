
unsigned char input_char; //var for RX

unsigned int valL, valH; //vars for store ADC value
unsigned pwmVal;
void adcInit(); //function for initial ADC
void uartInit(); //function for initial uart
void startAdc(); //function for start adc
void sendData(unsigned); //function for send data over uart
void onPwm(unsigned);    //function for turn on the pwm with value
void offPwm();     //function for turn off the pwm
bit press;  //variable for button that should exit the app
void main() {//F=16MHz Buad Rate 9600 BPS

    DDRJ=255;
    DDRB=255;
    DDRD=0;
    uartInit();
    adcInit();
    SREG.B7=1;//global interrupt bit
    EICRA=3; //rising edge of INT0
    EIMSK=1;
    TCCR1A=0b00001001; //Fast PWM, 8-bit
    TCCR1B=0b00001000;

}

void btn() org 0x2 //external interrupt for button that exit python app
{
   press=1;
}
void adcInit() //adc initial
{
     ADMUX=0b00000000; //ADC0 ,ADLAR=0
     ADCSRA=0b10001111; //Enable, no start, enable interrupt, 128 Division Factor
     ADCSRB=0b00000000;
     DIDR0=0b00000001;
}

void uartInit() //usart initial
{
     //UCSR0A=0 flags
     UCSR0B=0b11011000;  //TXENn, RXENn, TXCIEn, RXCIEn
     UCSR0C=0b00000110;  //Asyn mode, size= 8bit
     UBRR0H=0;           //F=16MHz Buad Rate 9600 BPS
     UBRR0L=103;
}

void res() org 0x32 //program for USART0 Rx Complete
{
     input_char=UDR0;
       if(input_char == '1')
       {
          PORTJ.B0 = ~PINJ.B0; // toggle the LED is connected to
       }

       else if(input_char=='3') //start ADC
       {
          startAdc();
       }
       else if(input_char=='5') //check the button
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
          pwmVal = ((int)input_char) *2;  //convert to int and multi with 2
          onPwm(pwmVal);
        }
}

void sendData(unsigned dataTX)//send data function
{
    while(UCSR0A.B5==0); //if UDRE0 ==1 (flag set)
    UDR0 = dataTX;
}
void comAdc() org 0x3A{  //program interrupt ADC Conversion Complete
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
  ADCSRA.B6=1; //start convertor

}
void transComp() org 0x36{ //program interrupt for USART0 Tx Complete
    PORTJ.B1 = 1;
    delay_ms(200);
    PORTJ.B1=0;
}

void onPwm(unsigned pwm_val){
 TCCR1B=0b00001010;  //start the timer
 OCR1CL=pwm_val;

}
void offPwm(){
  TCCR1B=0b00001000;  //stop the timer
  OCR1CL=0;
}