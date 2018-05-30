#include <avr/io.h>
#include <math.h>

#define XLOW 0X300; /*Aca pongo las posiciones de memoria donde busca la gravedad de cada eje*/
#define XHIGH 0X301;  /*Que por estar en registros vienen separadas*/
#define ZLOW 0X302;
#define ZHIGH 0X303;
#define ANGPOS 0X304;

#define pi 3.1415;

#define XMAX ???;
#define XMIN ???;
#define ZMAX ???;
#define ZMIN ???; /*Esto se pone despues de calibrar el acelerometro (con arduino)*/

unsigned int volatile * const xal = (unsigned int *) XLOW;
unsigned int volatile * const xah = (unsigned int *) XHIGH;
unsigned int volatile * const zal = (unsigned int *) ZLOW;
unsigned int volatile * const zah = (unsigned int *) ZHIGH;
unsigned int volatile * const angp = (unsigned int *) ANGPOS;

void angulo(void)
{
	signed float x,z;
	unsigned int xb,zb;
	unsigned char ang;

	xb=((*xah)<<8)+*xal;
	zb=((*zah)<<8)+*zal;

	x=2*(xb-XMIN)/(XMAX-XMIN)-1;
	z=2*(zb-ZMIN)/(ZMAX-ZMIN)-1;

	ang=((char)atan2(z,x)+pi)*(180/(2*pi));

	*angp=ang;
	
}











