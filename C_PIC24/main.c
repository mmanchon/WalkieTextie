#include <xc.h>
#include <string.h>
#include <stdlib.h>
#include <stdio.h>

#include "time.h"
#include "TPWM.h"
#include "LcTLCD.h"
#include "AuTAudio.h"
#include "AdTADC.h"
#include "SiTSio.h"
#include "TAD_Control.h"
#include "TAD_RF.h"
#include "TAD_MSG.h"

// Configuration Bits - 24.1 del Datasheet 
_CONFIG2(		IESO_OFF				// Two Speed Start-up               DISABLED
			&	SOSCSEL_LPSOSC       		// Low Power Secondary Oscillator   ENABLE
			&	WUTSEL_LEG           		// Legacy Wake-up timer selected
		 	&	FNOSC_FRCPLL        		// Fast RC oscillator w/ divide and PLL
		 	& 	FCKSM_CSDCMD			// Clock switching and clock monitor
			&	OSCIOFNC_ON			// OSCO/RC15 function               RC15
			&	IOL1WAY_OFF			// Una configuraci� per I/O remapejables deshabilitat
			&	POSCMOD_NONE			// Primary disabled
			& 	I2C1SEL_SEC
);

_CONFIG1(		JTAGEN_OFF                              // JTAG                             DISABLED
			&	GCP_OFF				// Code Protect                     DISABLED
			&	GWRP_OFF			// Write Protect                    DISABLED
			&	BKBUG_OFF			// Background Debugger              DISABLED
			&	COE_OFF				// Clip-on Emulation                DISABLED
			&	ICS_PGx1			// ICD pins select share            PGC1/PGD1
			&	FWDTEN_OFF			// Watchdog Timer                   DISABLED
			&	WINDIS_OFF			// Windowed WDT                     DISABLED
			&	FWPSA_PR128			// Watchdog prescaler	1:128
			&	WDTPS_PS2048			// Watchdog postscale	1:2048      Pre=128 i Post=2048 --> WatchDog Timer = 8seg
);

void initCPU(){
    CLKDIV=0x0000;          // Divisi� del clock pel timer i CPU per 1
 //   OSCCON=0x0020;
    RCONbits.SWDTEN = 0;    // Desactivem el Watchdog
}

int main(void){
    initCPU();
    TiInit();
    PWMInit();
    LcInit(2,16);
    AuInit();
    AdInit();
    SiInit();
    LcClear();
    LcCursorOff();
    LcGotoXY(0,0);
    LcPutString("Booting...");
    initMotorLCD();
    initControl();
    InitRF();
    initMSG();
    while(1){
        
        MotorPWM(0);
        MotorPWM(1);
        MotorPWM(2);
        MotorLCD();
        MotorAudio();
        MotorControl();
        MotorSIO();
        MotorRF();
    }
}

