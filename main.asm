							   EXPORT Ana_Program

Delay_suresi                   EQU 0x30D40;8mhz/3(clock sinyali)=2.333.333=0x239A95 (1sn) suanki delay 30D40=200000 yaklasik 87ms
RCC_APB2ENR                    EQU 0x40021018	

GPIOA_CRL	                   EQU 0x40010800
GPIOA_IDR	                   EQU 0x40010808
GPIOA_ODR	                   EQU 0x4001080C

GPIOB_CRL	                   EQU 0x40010C00
GPIOB_IDR	                   EQU 0x40010C08
GPIOB_ODR	                   EQU 0x40010C0C

	
							   AREA Bolum3, CODE, READONLY
								   
delay 
                               LDR r9,=Delay_suresi ;register r9 u Delay_suresindeki deger yap
sayac						   SUBS r9,#1 ;register r9 a 1 ekle
							   BNE sayac ;sayac'a esit degilse
							   BX LR ;geri dön
Ana_Program						                       
	                           LDR R1,=RCC_APB2ENR  ;GPIO'lar için Clock ayarlarini etkinlestir 
	                           LDR R0,[R1]          ;R1 in adresini R0 a yukle
	                           ORR R0,R0,#0xFC	    ;R0 ya 0xfc datasi arasinda veya islemi yaptir r0 a kaydet	
	                           STR R0,[R1]          ;R1 in adresini R0 a yukleyip bellege kaydet

	                           MOV R0,#0x00000080
	                           LDR R1,=GPIOB_CRL   ;gpioa 0  port ayari registeri   
	                           STR R0,[R1]			;çikis PA0 
							   
							   MOVS R0,#0x00000030
	                           LDR R1,=GPIOA_CRL   ;gpioa 0  port ayari registeri   
	                           STR R0,[R1]			;çikis PA0 							   
dongu
							   LDR R4,=GPIOB_IDR    ; input kontrol registeri
	                           LDR R5,[R4]			;R0 = GPIOB_IDR nin degeri
							   TST R5,#(1<<1)		;test bit b1 == if(GPIOB->IDR & 0X02)
							   BEQ dongu;0=0 ise döngüye geri don
							   
                               CBZ   R6,durum_0 ;R5 0 a esit ise durum_0 a git
                               MOVS  r6,#0x00
                               B     devam
durum_0                        MOVS  R6,#0x01  
							   
devam                          CMP R6,#0x01
                               BEQ led_acik     ;== if(GPIOB->IDR & 0X02)
led_kapali					   MOVS r0, #0x0002;pa1 kapali
                               STR r0, [r1, #0x0C];===GPIOC->ODR |=0x2000
							   
	                           B buton_kontrol	
							   
led_acik					   MOVS r0, #0x0000; pa1 açik
                               STR r0, [r1, #0x0C];===GPIOC->ODR &=~0x2000

buton_kontrol				   LDR R4,=GPIOB_IDR    ; input kontrol registeri
	                           LDR R5,[R4]			;R0 = GPIOB_IDR nin degeri
							   TST R5,#(1<<1)		;test bit b1 == if(GPIOB->IDR & 0X02)
							   BEQ dongu;0=0 ise döngüye geri don
                               BL delay;delay subroutine git islem yaptiktan sonra geri dön
							   B buton_kontrol
							   
			                   ALIGN
	                           END
