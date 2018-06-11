/*
 * Current_value.c
 *
 * Created: 10/6/2018 15:59:35
 *  Author: camis
 */ 

#include <avr/io.h>

#define XLOW 0X400 /*Aca pongo las posiciones de memoria donde busca la corriente*/
#define XHIGH 0X401 /*Que por estar en registros viene separada*/
#define I 0X402

#define VOFFSET 2.5 /*La tension de offset es 2.5 mV (cuando la corriente es nula)*/
#define SENSIBILIDAD 0.185 /*Al trabajar con el sensor de 5 A, la sensibilidad es 185 mV/A*/

unsigned int volatile * const xal = (unsigned int *) XLOW;
unsigned int volatile * const xah = (unsigned int *) XHIGH;
unsigned int volatile * const iv = (unsigned int *) I;
void current_value(void);
void current_value(void)
{
	unsigned int xb;

	xb=((*xah)<<8)+*xal;

	*iv=(xb-VOFFSET)/SENSIBILIDAD;
	*iv=(*iv)*1000;
	
}
