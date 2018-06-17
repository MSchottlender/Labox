#include <avr/io.h>
#include <math.h>

#define YLOW 0X300 /*Aca pongo las posiciones de memoria donde busca la gravedad de cada eje*/
#define YHIGH 0X301  /*Que por estar en registros vienen separadas*/
#define ZLOW 0X302
#define ZHIGH 0X303
#define ANGPOS 0X304

#define pi 3.1415

#define YMAX 999
#define YMIN 372
#define ZMAX 863
#define ZMIN 234 /*Esto se pone despues de calibrar el acelerometro (con arduino)*/

unsigned int volatile const * yal = (unsigned int *) YLOW;
unsigned int volatile const * yah = (unsigned int *) YHIGH;
unsigned int volatile const * zal = (unsigned int *) ZLOW;
unsigned int volatile const * zah = (unsigned int *) ZHIGH;
unsigned int volatile * const angp = (unsigned int *) ANGPOS;

void angulo(void)
{
	float y,z;
	int yb,zb,yl,zl,yh,zh;
	unsigned char ang;

	yh=*yah; 
	yh=((*yah)<<8);
	yl=(char)(*yal);
	yb=yh;
	yb=yb+yl;
	
	
	zh=*zah;
	zh=((*zah)<<8);
	zl=(char)(*zal);
	zb=zh;
	zb=zb+zl;
	
	/* Quiero yb=844 zb=711 para obtener 45 grados*/


	y=(200000*(yb-YMIN)/(YMAX-YMIN)-100000); /*mapeo multiplicado por 100000 para dar mas resolucion y presicion*/
	z=(200000*(zb-ZMIN)/(ZMAX-ZMIN)-100000);
	
	ang=fabs(atan(z/y))*180/pi;
	if(y<0 && z<0)
	{
		ang=180-(fabs(atan(z/y))*180/pi);
	}
	if(y<0 && z>0)
	{
		ang=180;	
	}
	if(y>0 && z>0)
	{
		ang=0;
	}
 /*Va de 0 a 180 grados*/
	*angp=(char)ang;
	
}
