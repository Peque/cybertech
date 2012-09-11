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


// TODO: avoid using wirish stuff
#include "wirish.h"
__attribute__((constructor)) void premain() {
	init();
}


const char *dummy_str = "Hello!\n";


void setup(void)
{
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

		uint8 input = usart_getc(USART1);

		usart_putstr(USART1, "Received: ");
		usart_putstr(USART1, (const char *) &input);
		usart_putstr(USART1, "\n");

	}
}


int main(void)
{
	setup();

	while (1) loop();

	return 0;
}
