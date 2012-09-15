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
#define AT_SPEED_MAX_VALUE 10
#define MAX_MANUAL_SPEED 0.6     // Max speed in manual mode (%)
#define BLUETOOTH_USART USART1
#define PING_PERIOD 200000       // Ping period in microseconds


typedef enum { AUTO = 0, MANUAL } robot_mode;

robot_mode mode;

const char *dummy_str = "Hello!\n";
char buffer[BUFFER_SIZE];
char *p_buffer;

HardwareTimer ping_timer(2);   // TODO: avoid using wirish stuff
char waiting_for_ack = 0;


int set_speed(int speed_left, int speed_right)
{
	// Set speed left
	if (speed_left < 0) {
		gpio_write_bit(GPIOB, 5, 1);
		gpio_write_bit(GPIOB, 4, 0);
		speed_left = -speed_left;
	} else {
		gpio_write_bit(GPIOB, 5, 0);
		gpio_write_bit(GPIOB, 4, 1);
	}
	pwmWrite(15, (int) ((speed_left * 65535 * MAX_MANUAL_SPEED) / AT_SPEED_MAX_VALUE)); // TODO: avoid using wirish stuff!!

	// Set speed right
	if (speed_right < 0) {
		gpio_write_bit(GPIOA, 3, 1);
		gpio_write_bit(GPIOA, 15, 0);
		speed_right = -speed_right;
	} else {
		gpio_write_bit(GPIOA, 3, 0);
		gpio_write_bit(GPIOA, 15, 1);
	}
	pwmWrite(16, (int) ((speed_right * 65535 * MAX_MANUAL_SPEED) / AT_SPEED_MAX_VALUE)); // TODO: avoid using wirish stuff!!
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
		} else if (!strncmp(p_buffer, "uptime:", 3)) {
			usart_putudec(BLUETOOTH_USART, systick_uptime_millis);
			usart_putstr(BLUETOOTH_USART, "\n");
		} else return 1;
	}

	ping_timer.refresh();   // TODO: avoid using wirish stuff
	waiting_for_ack = 0;

	return 0;
}


void handler_ping()
{
	if (waiting_for_ack) {
		set_speed(0, 0);
		waiting_for_ack = 0;
	} else {
		usart_putstr(BLUETOOTH_USART, "ping\n");
		waiting_for_ack = 1;
	}
}


void setup(void)
{
	// Initialize buffer pointer
	p_buffer = (char *) buffer;

	/*
	 *  Left motor (A):
	 *
	 *    % GPIO PB5  (D17) --> AIN1
	 *    % GPIO PB4  (D18) --> AIN2
	 *    % GPIO PB7  (D15) --> PWMA
	 */
	gpio_set_mode(GPIOB, 5, GPIO_OUTPUT_PP);
	gpio_set_mode(GPIOB, 4, GPIO_OUTPUT_PP);
	pinMode(15, PWM);                     // TODO: avoid using wirish stuff

	/*
	 *  Right motor (B):
	 *
	 *    % GPIO PB3  (D19) --> BIN1
	 *    % GPIO PA15 (D20) --> BIN2
	 *    % GPIO PB6  (D16) --> PWMB
	 */
	gpio_set_mode(GPIOB, 3, GPIO_OUTPUT_PP);
	gpio_set_mode(GPIOA, 15, GPIO_OUTPUT_PP);
	pinMode(16, PWM);                     // TODO: avoid using wirish stuff

	// Set output mode in D33 (Maple Mini's SMD LED) and set it to high
	gpio_set_mode(GPIOB, 1, GPIO_OUTPUT_PP);
	gpio_write_bit(GPIOB, 1, 1);

	// Serial 1 initialization
	Serial1.begin(230400);               // TODO: avoid using wirish stuff

	// Stop motors
	set_speed(0, 0);

	// Set manual mode
	mode = MANUAL;

	// Ping timer
	// TODO: avoid using wirish stuff!
    ping_timer.pause();
    ping_timer.setPeriod(PING_PERIOD);
    ping_timer.setChannel1Mode(TIMER_OUTPUT_COMPARE);
    ping_timer.setCompare(TIMER_CH1, 1);  // Interrupt 1 count after each update
    ping_timer.attachCompare1Interrupt(handler_ping);
    ping_timer.refresh();
    ping_timer.resume();
}


void auto_mode(void)
{

}


void manual_mode(void)
{
	while (usart_data_available(BLUETOOTH_USART)) {

		uint8 c_input = usart_getc(BLUETOOTH_USART);

		*p_buffer = (char) c_input;
		p_buffer++;

		if (c_input == (uint8) '\n') {
			*p_buffer = '\0';
			p_buffer = (char *) buffer;
			if (parse_command(buffer)) usart_putstr(BLUETOOTH_USART, "ERROR: Unknown command!\n");;
		}

	}
}


int main(void)
{
	setup();

	while (1) {

		if (mode == AUTO) auto_mode();
		else if (mode == MANUAL) manual_mode();

	}

	return 0;
}
