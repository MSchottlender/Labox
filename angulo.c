/*
 * CFile1.c
 *
 * Created: 8/6/2018 19:21:57
 *  Author: marti
 */ 
#include <avr/io.h>
#include <math.h>

#define YLOW 0X300 /*Aca pongo las posiciones de memoria donde busca la gravedad de cada eje*/
#define YHIGH 0X301  /*Que por estar en registros vienen separadas*/
#define ZLOW 0X302
#define ZHIGH 0X303
#define ANGPOS 0X304

#define pi 3.1415

unsigned int volatile const * yal = (unsigned int *) YLOW;
unsigned int volatile const * yah = (unsigned int *) YHIGH;
unsigned int volatile const * zal = (unsigned int *) ZLOW;
unsigned int volatile const * zah = (unsigned int *) ZHIGH;
unsigned int volatile * const angp = (unsigned int *) ANGPOS;

void angulo(void)
{
	int YMAX,YMIN,ZMAX,ZMIN;
	int acel=2;
	if (acel==1)
	{
		YMAX=996;
		YMIN=336;
		ZMAX=872;
		ZMIN=235;
	}
	if(acel==2)
	{
		YMAX=986;
		YMIN=342;
		ZMAX=866;
		ZMIN=213;
	}
	if(acel==3)
	{
		YMAX=997;
		YMIN=347;
		ZMAX=866;
		ZMIN=221;
	}
	if(acel==4)
	{
		YMAX=999;
		YMIN=372;
		ZMAX=863;
		ZMIN=234;
	}
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
	
	if(acel!=2)
	{	
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
	}
	if(acel==2)
	{
		ang=acosf(y)*180/pi;
		/*if(z>0)
		{
			ang=(acosf(x))*180/pi;
		}
		if(z<0 && x<0)
		{
			ang=180;
		}
		if(z<0 && x>0)
		{
			ang=0;
		}*/
	}
	/*Va de 0 a 180 grados*/
	*angp=(char)ang;
}
