/*
 *      maze.h
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



//////////////////////////////////////////////////////////
// Inclusiones y macros
//////////////////////////////////////////////////////////

#include <stdlib.h>
#include <stdio.h>
#include <time.h>
#include <math.h>

#define pi 3.141592653589793
#define minerr 1e-15

#define p_libre_nivel1 0.9
#define l_max 3
#define l_med 2
#define l_retroceso 40
#define n_retrocesos 10000
#define n_pasillos_sec 10
#define area_rest_final 0.0



//////////////////////////////////////////////////////////
// Tipos y variables globales
//////////////////////////////////////////////////////////

typedef struct {
	unsigned char asignado : 1;
	unsigned char a_derecha : 1;
	unsigned char a_abajo : 1;
	unsigned char extremo : 1;
	unsigned char nivel : 4;
} casilla;

typedef struct {
	unsigned x;
	unsigned y;
} p_cartes;

unsigned area_rest;
p_cartes dim, pos;



//////////////////////////////////////////////////////////
// Funciones
//////////////////////////////////////////////////////////

double fact(float k);

double fdist_prob_normalst(double z);

double fdist_prob_normalst_inversa(double Z);

double fdist_prob_normal(double x, double my, double sigma);

double fdist_prob_normal_inversa(double X, double my, double sigma);

double prob_poisson(unsigned x, double lambda);

double fdist_prob_poisson(unsigned x, double lambda);

unsigned fdist_prob_poisson_inversa(double X, double lambda);

int pos_extremo(casilla **m);

int encerrado(casilla **m);

int dir_viable(casilla **m, int dir);

void mover_pos(int dir);

void representar_pasillo(casilla **m, int dir, unsigned lg, unsigned n);

int generar_pasillo(casilla **m, unsigned n);

int deshacer(casilla **m, unsigned retroceso);

int recorrido_principal(casilla **m);

int recorridos_adicionales(casilla **m);

unsigned lado_lab(unsigned area);

int laberinto_arp(casilla **m);

int estado_casilla(casilla **m, int dir);

int nivel2_disponible(casilla **m, int *dir);

int retr_hasta_nivel2(casilla **m, int *dir);

int encontrar_sol_ac(casilla **m, p_cartes pos_inicio, p_cartes pos_fin);

int laberinto_ac(casilla **m);
