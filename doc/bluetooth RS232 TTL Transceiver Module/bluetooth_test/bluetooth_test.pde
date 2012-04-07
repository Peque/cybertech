/*
 * bluetooth_test.pde
 *
 * Copyright 2012
 * 			 - Juan Herrero Macías <jn.herrerom@gmail.com>
 * 			 - Miguel Sánchez de León Peque <msdeleonpeque@gmail.com>
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston,
 * MA 02110-1301, USA.
 *
 *
 */

 /*
 * This is just a small test to check if our bluetooth device is working properly
 * If we type ON; through putty the board LED will turn on
 * OFF; will turn off the board LED
 * (All commands must end with ";" character)
 */

#include <SoftwareSerial.h>

#define STRING_LENGTH 256
#define LED_PIN 13;

int i = 0;

SoftwareSerial bluetooth(3, 2); // RX, TX

void setup() {
  pinMode(LED_PIN, OUTPUT);  // pin 13 (on-board LED) as OUTPUT
  bluetooth.begin (9600);
}

void loop() {

	while  ((bluetooth.available() && i < STRING_LENGTH ) )  {    // if data is available to read
		char string [STRING_LENGTH] ;
		char a;
		delay(20);
		a = bluetooth.read();
		if (a != ';') {
			if ( a == 13 || a== 10) continue;
			string[i] = a;         // read it and store it in 'val'
			i++;
		} else {
			string[i] = '\0';
			bluetooth.print ((int) string[0]);
			bluetooth.println(string);

			if ( !strcmp(string, "OFF\0") )  {      // if '0' was received led 13 is switched off
				digitalWrite(LED_PIN, LOW);   	 // turn Off pin 13 off
				bluetooth.println("13 off");
			}

			if ( !strcmp(string, "ON\0") )  {       // if '1' was received led 13 on
			  digitalWrite(ledpin = LED_PIN, HIGH); 	 // turn ON pin 13 on
			  bluetooth.println("13 on");
			}
			string[0] = '\0';				//Erase the string
			i = 0;					//Reset the counter
			break;
		}
	}
  }
