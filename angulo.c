#include <avr/io.h>
#include <math.h>

#define YLOW 0X300 /*Aca pongo las posiciones de memoria donde busca la gravedad de cada eje*/
#define YHIGH 0X301  /*Que por estar en registros vienen separadas*/
#define ZLOW 0X302
#define ZHIGH 0X303
#define ANGPOS 0X304

#define pi 3.1415

#define YMAX 1006
#define YMIN 357
#define ZMAX 868
#define ZMIN 237 /*Esto se pone despues de calibrar el acelerometro (con arduino)*/

unsigned int volatile * const yal = (unsigned int *) YLOW;
unsigned int volatile * const yah = (unsigned int *) YHIGH;
unsigned int volatile * const zal = (unsigned int *) ZLOW;
unsigned int volatile * const zah = (unsigned int *) ZHIGH;
unsigned int volatile * const angp = (unsigned int *) ANGPOS;

void angulo(void)
{
	float y,z;
	unsigned int yb,zb;
	unsigned char ang;

	yb=((*yah)<<8)+*yal;
	zb=((*zah)<<8)+*zal;
	

	y=(200000*(yb-YMIN)/(YMAX-YMIN)-100000); /*mapeo multiplicado por 100000 para dar mas resolucion y presicion*/
	z=(200000*(zb-ZMIN)/(ZMAX-ZMIN)-100000);
	
	ang=atan(z/y)*180/pi+90; /*Va de 0 a 180 grados*/
	
	*angp=ang;
	
}
