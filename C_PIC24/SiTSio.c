#include <p24FJ32GA002.h>
#include "SiTSio.h"

static char BufferRX[BUFFER_RX_SIZE];
static char* BufferTX[BUFFER_TX_SIZE];
static unsigned char IniciTx, IniciRx, FiTx, FiRx;
static unsigned char  QuantsRX, QuantsTX;
static char estat;

static void PosaRX(char);
static char TreuRX(void);
static void PosaTX(char*);
static char* TreuTX(void);

void SiInit(void){
    // Unlock registers
    __builtin_write_OSCCONL(OSCCON & 0xBF);  //Datasheet dixit (pag 110)

    RPOR1bits.RP2R= 3;
    RPINR18bits.U1RXR= 4; //Vull el RP4 de input

    //Lock registers
    __builtin_write_OSCCONL(OSCCON | 0x40);  //Datasheet dixit (pag 110)

    //Configurem la SIO

    U1BRG=103; //9600 bauds  
    U1MODEbits.UARTEN = 1;
    U1MODEbits.UEN=0; //Sense flow control
    U1MODEbits.BRGH=0;
    U1MODEbits.PDSEL = 0; //8 bits de dades i sense paratitat
    U1MODEbits.STSEL = 0;  // 1 Stop bit;
    U1STAbits.UTXEN = 1;
    estat = 0;
    // Activo les interrupcions
    IEC0bits.U1RXIE = 1;
    QuantsTX = QuantsRX = IniciRx = IniciTx = FiRx = FiTx = 0;
}

static char *temporal;

void MotorSIO(void){
    switch(estat){
        case 0:
            if (QuantsTX > 0){
                estat = 1;
            }
            break;
        case 1:
            temporal=TreuTX();
            estat = 2;
            break;
        case 2:
            if (*temporal)
                estat = 3;
            else
                estat = 0;
            break;
        case 3:
            if (U1STAbits.TRMT != 0){
                U1TXREG = *temporal++;
                U1STAbits.UTXEN = 1;
                estat=2;
            }
            break;
    }
}

void SiPuts(char *s) {
	while(*s) SiSendChar(*s++); 
}

void SiPutsCooperatiu(char *s) {
    PosaTX(s);
}

int SiCharAvail(void) {
	return QuantsRX;
}

char SiGetChar(void) {
	return TreuRX();
}

void SiSendChar(char c) {
	while(U1STAbits.TRMT == 0) ClrWdt();
	U1TXREG = c;
	U1STAbits.UTXEN = 1;
}

static void PosaTX(char *c) {
	BufferTX[IniciTx++] = c;
	if (IniciTx == BUFFER_TX_SIZE) IniciTx = 0;
	QuantsTX++;
}

static char* TreuTX(void) {
	char *tmp;
	tmp = BufferTX[FiTx++];
	if (FiTx == BUFFER_TX_SIZE) FiTx = 0;
	QuantsTX --;
	return tmp;
}

static void PosaRX(char c) {
	BufferRX[IniciRx++] = c;
	if (IniciRx == BUFFER_RX_SIZE) IniciRx = 0;
	QuantsRX++;
}
static char TreuRX(void) {
	char tmp;
	tmp = BufferRX[FiRx++];
	if (FiRx == BUFFER_RX_SIZE) FiRx = 0;
	QuantsRX --;
	return tmp;
}
void __attribute__((interrupt, no_auto_psv)) _U1RXInterrupt(void) {
        IFS0bits.U1RXIF = 0;
	if (U1STAbits.OERR == 1) U1STAbits.OERR = 0;
	PosaRX(U1RXREG);
}