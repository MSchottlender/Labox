/*
 * CFile1.c
 *
 * Created: 11/6/2018 11:34:36
 *  Author: camis
 */ 

#include <avr/io.h>

#define XLOW 0X400 /*Aca pongo las posiciones de memoria donde busca la corriente*/
#define XHIGH 0X401 /*Que por estar en registros viene separada*/
#define I 0X402 /*Esta sera la corriente de salida*/

#define VOFFSET 2.5 /*La tension de offset es 2.5 mV (cuando la corriente es nula)*/
#define VOFFSET_M 100 /*Offset de tension que se trabaja con muestras y no la tension analogica*/
#define SENSIBILIDAD 0.185 /*Al trabajar con el sensor de 5 A, la sensibilidad es 185 mV/A*/
#define SENSIBILIDAD_M 7.4 /*Sensibilidad que trabaja con muestras y no con la tension analogica*/

void Sensor_c(void){
/*Creo punteros que apuntan a los valores de memoria definidos previamente*/
unsigned int volatile * const xal = (unsigned int *) XLOW;
unsigned int volatile * const xah = (unsigned int *) XHIGH;
unsigned int volatile * const iv = (unsigned int *) I;

{
	unsigned int xb, x;

	xb=((*xah)<<8)+*xal;	/*Convierto el valor obtenido mediante adc (adcl y adch) en uno solo*/
	/*x=xb*0.0025;*/
	*iv=(xb-VOFFSET_M)/SENSIBILIDAD_M;	/*Obtengo la corriente en A*/
	*iv=(*iv)*1000;		/*Transformo el valor de la corriente a mA*/
	
}
}