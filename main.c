#include <xc.h>

#include "system.h"
#include <stdint.h>        /* For uint8_t definition */
#include <stdbool.h>       /* For true/false definition */
#include <pic16lf1459.h>

#include "usb.h"
#include "usb_device.h"
#include "usb_device_cdc.h"
#include "user.h"
#include "spi.h"

#include "nRF24L01P.h"

#define bit_is_set(b,n)   (b & (1<<n))

static uint8_t readBuffer[CDC_DATA_OUT_EP_SIZE];
static uint8_t writeBuffer[CDC_DATA_IN_EP_SIZE];

void main(void)
{          
    
    uint8_t status1;
    uint8_t status2;
    uint8_t fifostatus;
    uint8_t podatak[3];  
    uint8_t pom;
    uint8_t pom2=0x40;    
    
    TRISCbits.TRISC4 = 0;
    TRISCbits.TRISC5 = 0;
    LATCbits.LATC4 = 1;
    
    // USB initialization
    SYSTEM_Initialize(SYSTEM_STATE_USB_START);      //initialize CLOCK, MCU's (SPI) clock has to be less than USB clock    
    ANSELA=0;                                       //turn off analog functions
    ANSELB=0;
    ANSELC=0;     
    USBDeviceInit();
    USBDeviceAttach();
    CDCInitEP();
    CDCSetBaudRate(1200);       
    
    // SPI initialization
    SPI_init();         //nRF24L01+ setup
    nRF_Setup();
    //status = ReadRegister(NRF_CONFIG);
    //__delay_ms(100);
    //WriteRegister(NRF_STATUS,0x70);  
    // loop for reading the nRF status and sending data over USB
 
    //status = ReadRegister(NRF_CONFIG)
    //WriteCommand(FLUSH_RX);
    //WriteCommand(FLUSH_TX);
    status1 = ReadRegister(NRF_CONFIG);
    podatak[0]=0;
    while(1){    
        //__delay_ms(100);
        //LATCbits.LATC4 = 1;
        //__delay_ms(100);
        //LATCbits.LATC4 = 0;        
        status1 = ReadRegister(NRF_STATUS);
        status2 = ReadRegister(NRF_CONFIG);
        podatak[0]=0;
        podatak[1]=0;                        
        if bit_is_set(status1,6) {    // bit6 = RX_DR in STATUS register        
       
            //status2 = ReadRegister(NRF_STATUS);
            //fifostatus = ReadRegister(FIFO_STATUS); 
      
            //if(status==0) { 
            WriteRegister(NRF_STATUS,(status1 | 0x40)); // clear RX_DR
       
            if bit_is_set(status1,5) {    // bit5 = TX_DS in STATUS register
                WriteRegister(NRF_STATUS,(status1 | 0x20)); // clear TX_DS
            }
            
            ReadPayload(4, podatak); 
            LATCbits.LATC5 = 1;
            __delay_ms(100);
            LATCbits.LATC5 = 0;
            __delay_ms(50);
           
       
            // WriteRegister(NRF_STATUS,0x70); 
            
        }
        
        if( USBUSARTIsTxTrfReady() == true){  
            if(podatak[0]!=0 | podatak[1]!=0) 
            putUSBUSART(podatak,4);         
            // __delay_ms(500);
        }      
        CDCTxService();      
    }            
}
        

    
