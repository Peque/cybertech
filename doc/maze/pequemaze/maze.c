/*
 *      maze.c
 *
 *      Copyright 2009-2010 Miguel Sánchez de León Peque <msdeleonpeque@gmail.com>
 *
 *      This program is free software; you can redistribute it and/or modify
 *      it under the terms of the GNU General Public License as published by
 *      the Free Software Foundation; either version 2 of the License, or
 *      (at your option) any later version.
 *
 *      This program is distributed in the hope that it will be useful,
 *      but WITHOUT ANY WARRANTY; without even the implied warranty of
 *      MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *      GNU General Public License for more details.
 *
 *      You should have received a copy of the GNU General Public License
 *      along with this program; if not, write to the Free Software
 *      Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston,
 *      MA 02110-1301, USA.
 *
 *
 * 		08.05.2009
 */



// Cambiar la definición de las coordenadas: definir arriba como 1.
// sustituir a_abajo por a_derecha y a_derecha por a_arriba.

// Elección del modo de ejecución por medio de parámetros pasados a la
// función main

// Para laberintos pequeños o demasiado grandes, cambiar al algoritmo
// directo

// Crear el archivo ".lbr" con la matriz real (elementos del tipo
// "casilla") y sus dimensiones al comienzo del archivo.



#include <stdlib.h>
#include <stdio.h>
#include <time.h>
#include <math.h>
#include "laberinto.h"


int main(int argc, char **argv)
{

	srandom(time(NULL));
	srand48(time(NULL));

	unsigned i, j, area=0;

	while (area < 9) {
		printf("Introduzca el área del laberinto (mayor que 8): ");
		scanf("%d",&area);
	}

	do {
		dim.x = lado_lab(area);
		if (dim.x != 0) dim.y = area/dim.x;
	} while ((dim.x == 0)||(dim.y == 0)||(dim.x/dim.y > 1.5)||\
			(dim.y/dim.x > 1.5));


//////////////////////////////////////////////////////////
// Creación de la matriz dinámica
//////////////////////////////////////////////////////////

	casilla **m = (casilla **)malloc(dim.x*sizeof(casilla *));

	for (i = 0; i < dim.x; i++) {
		m[i] = (casilla *)malloc(dim.y*sizeof(casilla));
	}


//////////////////////////////////////////////////////////
// Creación del recorrido principal
//////////////////////////////////////////////////////////

	printf("\nIntroduzca '1' para utilizar el algoritmo directo o '2'\n");
	printf("para el algoritmo inverso (no es aconsejable para dimensiones\n");
	printf("superiores a 150.000 casillas): ");
	scanf("%d",&i);
	printf("\n");
	if (i == 1) {
		if (area > 2000000) {
			printf("Ha escogido un área: %d (muy grande)\n", area);
			printf("Espere unos segundos o cancele la ejecución.");
			fflush(stdout);
		}
		laberinto_ac(m);
	} else {
		if (area > 200000) {
			printf("Ha escogido el algoritmo inverso para un laberinto de\n");
			printf("área %d. Espere unos segundos o cancele la ejecución.", area);
			fflush(stdout);
		}
		laberinto_arp(m);
	}


//////////////////////////////////////////////////////////
// Mostramos los resultados
//////////////////////////////////////////////////////////

	FILE *archivo;

	archivo = fopen("./resultado.txt", "w");

	for (i=0 ; i<dim.x ; i++){
		for (j=0 ; j<dim.y ; j++) {
			if (m[i][j].nivel != 1) {
				fprintf(archivo, "%d", m[i][j].nivel);
			} else fprintf(archivo, " ");
		}
	fprintf(archivo, "\n");
	}


	for (j=0 ; j<dim.y ; j++) {
		fprintf(archivo, " _");
	}
	fprintf(archivo, "\n");
	for (i=0 ; i<dim.x ; i++) {
		fprintf(archivo, "|");
		for (j=0 ; j<dim.y ; j++) {
			if (m[i][j].extremo) fprintf(archivo, "* ");
			else {
			if ((m[i][j].a_abajo)&&(m[i][j].a_derecha))\
				fprintf(archivo, "  ");
			if ((m[i][j].a_abajo)&&(!m[i][j].a_derecha))\
				fprintf(archivo, " |");
			if ((!m[i][j].a_abajo)&&(m[i][j].a_derecha))\
				fprintf(archivo, "_ ");
			if ((!m[i][j].a_abajo)&&(!m[i][j].a_derecha))\
				fprintf(archivo, "_|");
			}
		}
	fprintf(archivo, "\n");
	}

	fflush(archivo);
	fclose(archivo);


	return 0;
}


double fact(float k)
{
	double f = 1;
	while (k > 0) f *= k--;
	return f;
}

/* La siguiente función calcula la probabilidad de que la variable
 * aleatoria Z, distribuida según una normal estándar (de media 0 y
 * desviación típica 1), sea menor o igual que el parámetro 'z'. */

double fdist_prob_normalst(double z)
{
	return 1./2*(1+erf(z/sqrt(2)));
}

/* La función 'dist_prob_normal_inversa' calcula y devuelve el valor
 * 'z' que cumple P(Z<='z')='Z' en una distribución normal estándar.
 * Siendo 'Z' parámetro de la función. */

double fdist_prob_normalst_inversa(double Z)
{
	double z = 0, Z0, paso = 2;
	char znegativo = (Z < 0.5);
	if (znegativo) Z = 1 - Z;
	while ((Z0 = fdist_prob_normalst(z)) < Z ) z += paso;
	while (fabs(Z0 - Z) > minerr)
	{
		paso /= 2;
		if (Z0 < Z) z += paso;
		else z -= paso;
		Z0 = fdist_prob_normalst(z);
	}
	if (znegativo) return -z;
	else return z;
}

/* La siguiente función calcula la probabilidad de que la variable
 * aleatoria Z, distribuida según una normal de media 'my' y desviación
 * típica 'sigma', sea menor o igual que el parámetro 'x'. */

double fdist_prob_normal(double x, double my, double sigma)
{
	return fdist_prob_normalst((x-my)/sigma);
}

/* La función 'fdist_prob_normal_inversa' calcula y devuelve el valor
 * 'x' que cumple P(X<='x')='X' en una distribución normal de media
 * 'my' y desviación típica 'sigma'. Siendo 'X' parámetro de la
 * función. */

double fdist_prob_normal_inversa(double X, double my, double sigma)
{
	return fdist_prob_normalst_inversa(X)*sigma + my;
}

/* La siguiente función calcula la probabilidad de que la variable
 * aleatoria X, distribuida según una poisson (discreta), sea 'x'.
 * 'lambda' es el parámetro de la distribución. */

double prob_poisson(unsigned x, double lambda)
{
	return pow(lambda, x)*exp(-lambda)/fact(x);
}

/* La siguiente función calcula la probabilidad de que la variable
 * aleatoria X, distribuida según una poisson (discreta), sea menor
 * o igual que 'x'. 'lambda' es el parámetro de la distribución. */

double fdist_prob_poisson(unsigned x, double lambda)
{
	double X=0;
	while(x > 0) X += prob_poisson(x--, lambda);
	X += prob_poisson(0, lambda);
	return X;
}

/* La siguiente función calcula el valor 'x' que cumple P(X<='x')='X'
 * en una distribución poisson. 'lambda' es el parámtro de la
 * distribución. */

unsigned fdist_prob_poisson_inversa(double X, double lambda)
{
	unsigned x=0;
	double X0=0;
	while(X > X0) X0 += prob_poisson(x++, lambda);
	return x - 1;
}


/*			1		2		3
 *	 (0, 0) -----------------		|
 * 			|				|		|
 * 	  	4	|				| 5		|
 * 			|				|		`´
 * 			-----------------		x
 * 			6		7		8
 *
 * 				----> y
 *
 * (posición devuelta por pos_extremo en la matriz) */

int pos_extremo(casilla **m)
{
	if (pos.x == 0) {
		if (pos.y == 0) {
			return 1;
		} else {
			if (pos.y == dim.y-1) {
				return 3;
			} else return 2;
		}
	}
	if (pos.x == dim.x-1) {
		if (pos.y == 0) {
			return 6;
		} else {
			if (pos.y == dim.y-1) {
				return 8;
			} else return 7;
		}
	}
	if (pos.y == 0) return 4;
	if (pos.y == dim.y-1) return 5;
	return 0;
}

int encerrado(casilla **m)
{
	switch (pos_extremo(m)) {
		case 0 :
			if ((m[pos.x+1][pos.y].asignado == 1)&&\
				(m[pos.x-1][pos.y].asignado == 1)&&\
				(m[pos.x][pos.y+1].asignado == 1)&&\
				(m[pos.x][pos.y-1].asignado == 1)) return 1;
			break;
		case 1 :
			if ((m[pos.x+1][pos.y].asignado == 1)&&\
				(m[pos.x][pos.y+1].asignado == 1)) return 1;
			break;
		case 2 :
			if ((m[pos.x+1][pos.y].asignado == 1)&&\
				(m[pos.x][pos.y+1].asignado == 1)&&\
				(m[pos.x][pos.y-1].asignado == 1)) return 1;
			break;
		case 3 :
			if ((m[pos.x+1][pos.y].asignado == 1)&&\
				(m[pos.x][pos.y-1].asignado == 1)) return 1;
			break;
		case 4 :
			if ((m[pos.x+1][pos.y].asignado == 1)&&\
				(m[pos.x-1][pos.y].asignado == 1)&&\
				(m[pos.x][pos.y+1].asignado == 1)) return 1;
			break;
		case 5 :
			if ((m[pos.x+1][pos.y].asignado == 1)&&\
				(m[pos.x-1][pos.y].asignado == 1)&&\
				(m[pos.x][pos.y-1].asignado == 1)) return 1;
			break;
		case 6 :
			if ((m[pos.x-1][pos.y].asignado == 1)&&\
				(m[pos.x][pos.y+1].asignado == 1)) return 1;
			break;
		case 7 :
			if ((m[pos.x-1][pos.y].asignado == 1)&&\
				(m[pos.x][pos.y+1].asignado == 1)&&\
				(m[pos.x][pos.y-1].asignado == 1)) return 1;
			break;
		case 8 :
			if ((m[pos.x-1][pos.y].asignado == 1)&&\
				(m[pos.x][pos.y-1].asignado == 1)) return 1;
			break;
		default :
			return 1;
	}
	return 0;
}

int dir_viable(casilla **m, int dir)
{
	unsigned p = pos_extremo(m);
	switch (dir) {
		case 1 :
			if ((p==3)||(p==5)||(p==8)||\
				(m[pos.x][pos.y+1].asignado == 1)) {
				return 0;
			} else return 1;
			break;
		case 2 :
			if ((p==6)||(p==7)||(p==8)||\
				(m[pos.x+1][pos.y].asignado == 1)) {
				return 0;
			} else return 1;
			break;
		case 3 :
			if ((p==1)||(p==4)||(p==6)||\
				(m[pos.x][pos.y-1].asignado == 1)) {
				return 0;
			} else return 1;
			break;
		case 4 :
			if ((p==1)||(p==2)||(p==3)||\
				(m[pos.x-1][pos.y].asignado == 1)) {
				return 0;
			} else return 1;
			break;
		default :
			return 0;
	}
	return 0;
}

void mover_pos(int dir)
{
	switch (dir) {
		case 1 :
			pos.y += 1;
			break;
		case 2 :
			pos.x += 1;
			break;
		case 3 :
			pos.y -= 1;
			break;
		case 4 :
			pos.x -= 1;
			break;
	}
}

void representar_pasillo(casilla **m, int dir, unsigned lg, unsigned n)
{
	unsigned k;
	switch (dir) {
		case 1 :
			for (k=0 ; k<lg ; k++) {
				m[pos.x][pos.y+k].a_derecha = 1;
				m[pos.x][pos.y+k+1].asignado = 1;
				m[pos.x][pos.y+k+1].nivel = n;
			}
			pos.y += lg;
			break;
		case 2 :
			for (k=0 ; k<lg ; k++) {
				m[pos.x+k][pos.y].a_abajo = 1;
				m[pos.x+k+1][pos.y].asignado = 1;
				m[pos.x+k+1][pos.y].nivel = n;
			}
			pos.x += lg;
			break;
		case 3 :
			for (k=1 ; k<=lg ; k++) {
				m[pos.x][pos.y-k].a_derecha = 1;
				m[pos.x][pos.y-k].asignado = 1;
				m[pos.x][pos.y-k].nivel = n;
			}
			pos.y -= lg;
			break;
		case 4 :
			for (k=1 ; k<=lg ; k++) {
				m[pos.x-k][pos.y].a_abajo = 1;
				m[pos.x-k][pos.y].asignado = 1;
				m[pos.x-k][pos.y].nivel = n;
			}
			pos.x -= lg;
			break;
	}
}

int generar_pasillo(casilla **m, unsigned n)
{
	unsigned dir, lv=0, lg;
	p_cartes pos0 = {pos.x, pos.y};
	if (encerrado(m)) return 1;
	do {
		dir = 1 + (unsigned) (4.*rand()/(RAND_MAX+1.0));
	} while (!dir_viable(m, dir));

// Aleatorizar con la longitud media:
	while (dir_viable(m, dir)) {
		mover_pos(dir);
		lv++;
	}
	pos.x = pos0.x;
	pos.y = pos0.y;
	if (lv > l_med) {
		do {
			lg = fdist_prob_poisson_inversa(drand48(), l_med);
		} while ((lg > lv)||(lg == 0));
	} else {
		do {
			lg = fdist_prob_poisson_inversa(drand48(), lv);
		} while ((lg > lv)||(lg == 0));
	}

//


/*/ Aleatorizar con la longitud máxima:
	while ((lv<l_max)&&(dir_viable(m, dir))) {
		mover_pos(dir);
		lv++;
	}
	pos.x = pos0.x;
	pos.y = pos0.y;
	do {
		lg=fdist_prob_poisson_inversa(drand48(),lv);
	} while ((lg>lv)||(lg==0));
/*/

	representar_pasillo(m, dir, lg, n);
	area_rest -= lg;
	return 0;
}

int deshacer(casilla **m, unsigned retroceso)
{
	while (retroceso > 0) {
		if (m[pos.x][pos.y].a_derecha == 1) {
			m[pos.x][pos.y].a_derecha = 0;
			m[pos.x][pos.y].asignado = 0;
			m[pos.x][pos.y].nivel = 0;
			pos.y += 1;
			++area_rest;
		} else {
			if (m[pos.x][pos.y].a_abajo == 1) {
				m[pos.x][pos.y].a_abajo = 0;
				m[pos.x][pos.y].asignado = 0;
				m[pos.x][pos.y].nivel = 0;
				pos.x += 1;
				++area_rest;
			} else {
				if ((pos.y!=0)&&(m[pos.x][pos.y-1].a_derecha == 1)) {
					m[pos.x][pos.y].asignado = 0;
					m[pos.x][pos.y].nivel = 0;
					m[pos.x][pos.y-1].a_derecha = 0;
					pos.y -= 1;
					++area_rest;
				} else {
					if ((pos.x!=0)&&(m[pos.x-1][pos.y].a_abajo == 1)) {
						m[pos.x][pos.y].asignado = 0;
						m[pos.x][pos.y].nivel = 0;
						m[pos.x-1][pos.y].a_abajo = 0;
						pos.x -= 1;
						++area_rest;
					}
				}
			}
		}
		--retroceso;
	}
	return 0;
}

int recorrido_principal(casilla **m)
{
	unsigned A = (unsigned) dim.x*dim.y*p_libre_nivel1, i, j;
	area_rest = (dim.x)*(dim.y);
	for (i=0 ; i<dim.x ; i++){
		for (j=0 ; j<dim.y ; j++) {
			m[i][j].asignado = 0;
			m[i][j].a_derecha = 0;
			m[i][j].a_abajo = 0;
			m[i][j].extremo = 0;
			m[i][j].nivel = 0;
		}
	} // Queda inicializada la matriz a cero.
	pos.x = (unsigned) ((float) (dim.x)*rand()/(RAND_MAX + 1.0));
	pos.y = (unsigned) ((float) (dim.y)*rand()/(RAND_MAX + 1.0));
	m[pos.x][pos.y].extremo = 1;
	m[pos.x][pos.y].asignado = 1;
	m[pos.x][pos.y].nivel = 1;
	--area_rest;
	i = 0;
	do {
		if (generar_pasillo(m, 1)) {
			i++;
			deshacer(m, l_retroceso);
		}
		if (i==n_retrocesos) return 1;
	} while (area_rest >= A);
	m[pos.x][pos.y].extremo = 1;
	return 0;
}

int recorridos_adicionales(casilla **m)
{
	unsigned A = (unsigned) dim.x*dim.y*(area_rest_final), i, dir;
	do {
		do {
			pos.x = (unsigned) ((float) (dim.x)*rand()/(RAND_MAX + 1.0));
			pos.y = (unsigned) ((float) (dim.y)*rand()/(RAND_MAX + 1.0));
			dir = 1 + (unsigned) (4.*rand()/(RAND_MAX+1.0));

			while ((m[pos.x][pos.y].asignado == 0)&&(pos.x != 0)&&\
			(pos.y != 0)&&(pos.x != dim.x-1)&&(pos.y !=dim.y-1)) {
				mover_pos(dir);
			}

		} while ((encerrado(m))||(m[pos.x][pos.y].asignado == 0));



		for (i=0;i<n_pasillos_sec;i++) {
			(generar_pasillo(m, 2));
		}
	} while (area_rest > A);
	return 0;
}

unsigned lado_lab(unsigned area)
{
	double parte_entera, parte_decimal, x;
	x = fdist_prob_normal_inversa(drand48(), sqrt(area), sqrt(area));
	if (x < 0) x = -x;
	parte_decimal = modf(x, &parte_entera);
	if (parte_decimal < 0.5) return (parte_entera);
	else return (parte_entera + 1);
}

int laberinto_arp(casilla **m)
{
	time_t comienzo, final;
	comienzo = time(NULL);
	while (recorrido_principal(m));
	final = time(NULL);
	recorridos_adicionales(m);
	printf("\nMatriz creada.");
	printf("\nTiempo empleado: %d segundos\n", (unsigned) difftime(final, comienzo));
	return 0;
}

int estado_casilla(casilla **m, int dir)
{
	switch (dir) {
		case 1 :
			if (m[pos.x][pos.y].a_derecha == 1) {
				return m[pos.x][pos.y+1].nivel;
			} else return 0;
			break;
		case 2 :
			if (m[pos.x][pos.y].a_abajo == 1) {
				return m[pos.x+1][pos.y].nivel;
			} else return 0;
			break;
		case 3 :
			if (m[pos.x][pos.y-1].a_derecha == 1) {
				return m[pos.x][pos.y-1].nivel;
			} else return 0;
			break;
		case 4 :
			if (m[pos.x-1][pos.y].a_abajo == 1) {
				return m[pos.x-1][pos.y].nivel;
			} else return 0;
			break;
	}
	return -1;
}

int nivel2_disponible(casilla **m, int *dir)
{
	switch (*dir) {
		case 1 :
			if (estado_casilla(m, 2) == 2) {
				*dir = 2;
				return 2;
			} else {
				if (estado_casilla(m, 1) == 2) {
					*dir = 1;
					return 1;
				} else {
					if (estado_casilla(m, 4) == 2) {
						*dir = 4;
						return 4;
					} else {
						if (estado_casilla(m, 3) == 2) {
							*dir = 3;
							return 3;
						}
					}
				}
			}
			return 0;
			break;
		case 2 :
			if (estado_casilla(m, 3) == 2) {
				*dir = 3;
				return 3;
			} else {
				if (estado_casilla(m, 2) == 2) {
					*dir = 2;
					return 2;
				} else {
					if (estado_casilla(m, 1) == 2) {
						*dir = 1;
						return 1;
					} else {
						if (estado_casilla(m, 4) == 2) {
							*dir = 4;
							return 4;
						}
					}
				}
			}
			return 0;
			break;
		case 3 :
			if (estado_casilla(m, 4) == 2) {
				*dir = 4;
				return 4;
			} else {
				if (estado_casilla(m, 3) == 2) {
					*dir = 3;
					return 3;
				} else {
					if (estado_casilla(m, 2) == 2) {
						*dir = 2;
						return 2;
					} else {
						if (estado_casilla(m, 1) == 2) {
							*dir = 1;
							return 1;
						}
					}
				}
			}
			return 0;
			break;
		case 4 :
			if (estado_casilla(m, 1) == 2) {
				*dir = 1;
				return 1;
			} else {
				if (estado_casilla(m, 4) == 2) {
					*dir = 4;
					return 4;
				} else {
					if (estado_casilla(m, 3) == 2) {
						*dir = 3;
						return 3;
					} else {
						if (estado_casilla(m, 2) == 2) {
							*dir = 2;
							return 2;
						}
					}
				}
			}
			return 0;
			break;
	}
	return 0;
}

int retr_hasta_nivel2(casilla **m, int *dir)
{
	while (! (nivel2_disponible(m, dir))) {
		m[pos.x][pos.y].nivel = 3;
		if (estado_casilla(m, 1) == 1) {
			mover_pos(1);
		} else {
			if (estado_casilla(m, 2) == 1) {
				mover_pos(2);
			} else {
				if (estado_casilla(m, 3) == 1) {
					mover_pos(3);
				} else {
					if (estado_casilla(m, 4) == 1) {
						mover_pos(4);
					}
				}
			}
		}
	}
	return 0;
}

int encontrar_sol_ac(casilla **m, p_cartes pos_inicio, p_cartes pos_fin)
{
	int dir;
	pos.x = pos_inicio.x;
	pos.y = pos_inicio.y;
	dir = 1;
	m[pos.x][pos.y].nivel = 1;
	while((pos.x != pos_fin.x)||(pos.y != pos_fin.y)) {
		switch (dir) {
			case 1 :
				if (estado_casilla(m, 2) == 2) {
					dir = 2;
					mover_pos(dir);
					m[pos.x][pos.y].nivel = 1;
				} else {
					if (estado_casilla(m, 1) == 2) {
						mover_pos(dir);
						m[pos.x][pos.y].nivel = 1;
					} else {
						if (estado_casilla(m, 4) == 2) {
							dir = 4;
							mover_pos(dir);
							m[pos.x][pos.y].nivel = 1;
						} else {
							retr_hasta_nivel2(m, &dir);
						}
					}
				}
				break;
			case 2 :
				if (estado_casilla(m, 3) == 2) {
					dir = 3;
					mover_pos(dir);
					m[pos.x][pos.y].nivel = 1;
				} else {
					if (estado_casilla(m, 2) == 2) {
						mover_pos(dir);
						m[pos.x][pos.y].nivel = 1;
					} else {
						if (estado_casilla(m, 1) == 2) {
							dir = 1;
							mover_pos(dir);
							m[pos.x][pos.y].nivel = 1;
						} else {
							retr_hasta_nivel2(m, &dir);
						}
					}
				}
				break;
			case 3 :
				if (estado_casilla(m, 4) == 2) {
					dir = 4;
					mover_pos(dir);
					m[pos.x][pos.y].nivel = 1;
				} else {
					if (estado_casilla(m, 3) == 2) {
						mover_pos(dir);
						m[pos.x][pos.y].nivel = 1;
					} else {
						if (estado_casilla(m, 2) == 2) {
							dir = 2;
							mover_pos(dir);
							m[pos.x][pos.y].nivel = 1;
						} else {
							retr_hasta_nivel2(m, &dir);
						}
					}
				}
				break;
			case 4 :
				if (estado_casilla(m, 1) == 2) {
					dir = 1;
					mover_pos(dir);
					m[pos.x][pos.y].nivel = 1;
				} else {
					if (estado_casilla(m, 4) == 2) {
						mover_pos(dir);
						m[pos.x][pos.y].nivel = 1;
					} else {
						if (estado_casilla(m, 3) == 2) {
							dir = 3;
							mover_pos(dir);
							m[pos.x][pos.y].nivel = 1;
						} else {
							retr_hasta_nivel2(m, &dir);
						}
					}
				}
				break;
		}
	}
	return 0;
}

int laberinto_ac(casilla **m)
{
	unsigned i, j;
	time_t comienzo, final;
	comienzo = time(NULL);
	area_rest = (dim.x)*(dim.y);
	for (i=0 ; i<dim.x ; i++){
		for (j=0 ; j<dim.y ; j++) {
			m[i][j].asignado = 0;
			m[i][j].a_derecha = 0;
			m[i][j].a_abajo = 0;
			m[i][j].extremo = 0;
			m[i][j].nivel = 0;
		}
	} // Queda inicializada la matriz a cero.
	pos.x = (unsigned) ((float) (dim.x)*rand()/(RAND_MAX + 1.0));
	pos.y = (unsigned) ((float) (dim.y)*rand()/(RAND_MAX + 1.0));
	m[pos.x][pos.y].asignado = 1;
	m[pos.x][pos.y].nivel = 2;
	--area_rest;
	while (! generar_pasillo(m, 2));
	recorridos_adicionales(m);
	printf("\nMatriz creada, encontrando solución...\n");
	p_cartes pos_inicio = {0, 0}, pos_fin = {dim.x-1, dim.y-1};
	m[pos_inicio.x][pos_inicio.y].extremo = 1;
	m[pos_fin.x][pos_fin.y].extremo = 1;
	encontrar_sol_ac(m, pos_inicio, pos_fin);
	final = time(NULL);
	printf("Solución encontrada\n");
	printf("Tiempo empleado: %d segundos\n", (unsigned) difftime(final, comienzo));
	return 0;
}
