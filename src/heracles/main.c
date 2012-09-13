/*
 * test.c
 *
 * Copyright 2012 Miguel Sánchez de León Peque <msdeleonpeque@gmail.com>
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
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


#include "gpio.h"
#include "usart.h"
#include <string.h>
#include <stdio.h>


// TODO: avoid using wirish stuff
#include "wirish.h"
__attribute__((constructor)) void premain() {
	init();
}


#define BUFFER_SIZE 64

const char *dummy_str = "Hello!\n";
char buffer[BUFFER_SIZE];
char *p_buffer;


int set_speed(int speed_left, int speed_right)
{
	// Set speed left
	if (speed_left < 0) {
		gpio_write_bit(GPIOA, 6, 1);
		gpio_write_bit(GPIOA, 7, 0);
		speed_left = -speed_left;
	} else {
		gpio_write_bit(GPIOA, 6, 0);
		gpio_write_bit(GPIOA, 7, 1);
	}
	pwmWrite(3, (speed_left * 65535) / 10); // TODO: avoid using wirish stuff!!
	// TODO: Set speed right
	return 0;
}

int parse_command(char *buffer)
{
	char *p_buffer;

	p_buffer = buffer;

	if (!strncmp(p_buffer, "at+", 3)) {
		p_buffer += 3;
		if (!strncmp(p_buffer, "speed:", 3)) {
			p_buffer += 6;
			int speed_left;
			int speed_right;
			if (sscanf(p_buffer, "%d,%d", &speed_left, &speed_right) != 2) return 1;
			else set_speed(speed_left, speed_right);
		} else return 1;
	} else return 1;

	return 0;
}


void setup(void)
{
	p_buffer = (char *) buffer;

	gpio_set_mode(GPIOA, 6, GPIO_OUTPUT_PP);
	gpio_set_mode(GPIOA, 7, GPIO_OUTPUT_PP);
	pinMode(3, PWM);                     // TODO: avoid using wirish stuff

	// Set output mode in D33 (Maple Mini's SMD LED) and set it to high
	gpio_set_mode(GPIOB, 1, GPIO_OUTPUT_PP);
	gpio_write_bit(GPIOB, 1, 1);

	// Serial 1 initialization
	Serial1.begin(230400);               // TODO: avoid using wirish stuff
}


void loop(void)
{
	while (SerialUSB.available()) {      // TODO: avoid using wirish stuff, specially in loop()!

		uint8 input = SerialUSB.read();  // TODO: avoid using wirish stuff, specially in loop()!

		switch(input) {
			case 'a':
				// Send "Hello!" through the bluetooth device
				usart_putstr(USART1, dummy_str);
				break;
			case 'l':
				// Toogle board's LED
				gpio_toggle_bit(GPIOB, 1);
				break;
			case 't':
				// Send the system uptime through the bluetooth device, in milliseconds
				usart_putudec(USART1, systick_uptime_millis);
				usart_putstr(USART1, "\n");
				break;
			default :
				break;
		}

	}

	while (usart_data_available(USART1)) {

		uint8 c_input = usart_getc(USART1);

		*p_buffer = (char) c_input;
		p_buffer++;

		if (c_input == (uint8) '\n') {
			*p_buffer = '\0';
			p_buffer = (char *) buffer;
			if (parse_command(buffer)) usart_putstr(USART1, "Unknown command!\n");;
		}

	}
}


int main(void)
{
	setup();

	while (1) loop();

	return 0;
}
