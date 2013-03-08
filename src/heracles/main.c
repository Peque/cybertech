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
#define MANUAL_SPEED_MAX_VALUE 10
#define BLUETOOTH_USART USART1
#define PING_PERIOD 1000000          // Ping period in microseconds
#define MAX_PWM_VALUE 65535
#define MAX_MANUAL_PWM_VALUE 40000   // Max speed in manual mode (%)
#define SENSOR_TRESHOLD 1000
#define SENSOR_ARRAY_MIDDLE 7.5
#define NUMBER_OF_IR_SENSORS 16


typedef enum { AUTO = 0, MANUAL } robot_mode;

robot_mode mode;

const char *dummy_str = "Hello!\n";
char buffer[BUFFER_SIZE];
char *p_buffer;

HardwareTimer ping_timer(2);   // TODO: avoid using wirish stuff
char waiting_for_ack = 0;

// PID Variables
float kp = 2000;
float ki = 0;
float kd = 0;
float error, prev_error, integral, derivative;
unsigned long dt, time, prev_time;
float correction;
float line_position;
float last_line_position = SENSOR_ARRAY_MIDDLE;
int MAX_SPEED = 40000;

// Calibration variables
int max_measurement = 4095; // 12 bit ADC so max possible reading is 4095
int min_measurement = 0; 

// Battery levels
uint16 power_bat, digital_bat;

// Joystick variables (manual mode)
int jleft_x, jleft_y, jright_x, jright_y;

// Sensor array
uint16 array_data[16];


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
	pwmWrite(15, (uint16) speed_left); // TODO: avoid using wirish stuff!!

	// Set speed right
	if (speed_right < 0) {
		gpio_write_bit(GPIOB, 3, 1);
		gpio_write_bit(GPIOA, 15, 0);
		speed_right = -speed_right;
	} else {
		gpio_write_bit(GPIOB, 3, 0);
		gpio_write_bit(GPIOA, 15, 1);
	}
	pwmWrite(16, (uint16) speed_right); // TODO: avoid using wirish stuff!!
	return 0;
}

int process_joysticks(int leftx, int lefty, int rightx, int righty)
{
	int speed_left, speed_right;

	speed_left = lefty + rightx / 3;
	speed_right = lefty - rightx / 3;

	speed_left = speed_left > MANUAL_SPEED_MAX_VALUE ? MANUAL_SPEED_MAX_VALUE : speed_left;
	speed_left = speed_left < -MANUAL_SPEED_MAX_VALUE ? -MANUAL_SPEED_MAX_VALUE : speed_left;
	speed_right = speed_right > MANUAL_SPEED_MAX_VALUE ? MANUAL_SPEED_MAX_VALUE : speed_right;
	speed_right = speed_right < -MANUAL_SPEED_MAX_VALUE ? -MANUAL_SPEED_MAX_VALUE : speed_right;

	speed_left = (speed_left * MAX_MANUAL_PWM_VALUE) / MANUAL_SPEED_MAX_VALUE;
	speed_right = (speed_right * MAX_MANUAL_PWM_VALUE) / MANUAL_SPEED_MAX_VALUE;

	set_speed(speed_left, speed_right);

	return 0;
}

int get_battery_level()
{
	power_bat = adc_read(ADC1, 8);  // POWER (D3)
	digital_bat = adc_read(ADC1, 7);  // DIGITAL (D4)

	return 0;
}

int parse_command(char *buffer)
{
	char *p_buffer;

	p_buffer = buffer;

	if (*p_buffer++ == ':') {
		if (*p_buffer == 's') {
			p_buffer++;
			if (*p_buffer == 'l') {
				p_buffer++;
				if (*p_buffer == 'x') {
					p_buffer += 2;
					// :slx:
					if (!sscanf(p_buffer, "%d", &jleft_x)) return 1;
					else process_joysticks(jleft_x, jleft_y, jright_x, jright_y);
				} else if (*p_buffer == 'y') {
					p_buffer += 2;
					// :sly:
					if (!sscanf(p_buffer, "%d", &jleft_y)) return 1;
					else process_joysticks(jleft_x, jleft_y, jright_x, jright_y);
				} else return 1;
			} else if (*p_buffer == 'r') {
				p_buffer++;
				if (*p_buffer == 'x') {
					p_buffer += 2;
					// :srx:
					if (!sscanf(p_buffer, "%d", &jright_x)) return 1;
					else process_joysticks(jleft_x, jleft_y, jright_x, jright_y);
				} else if (*p_buffer == 'y') {
					p_buffer += 2;
					// :sry:
					if (!sscanf(p_buffer, "%d", &jright_y)) return 1;
					else process_joysticks(jleft_x, jleft_y, jright_x, jright_y);
				} else return 1;
			} else if (*p_buffer == 'p') {
				p_buffer++;
				if (*p_buffer == 'i') {
					// :spid:
					p_buffer += 3;
					if (sscanf(p_buffer, "%f,%f,%f", &kp, &ki, &kd) != 3) return 1;
				} else if (*p_buffer == ':') {
					// :sp;
					p_buffer++;
					if (!sscanf(p_buffer, "%f", &kp)) return 1;
				}
			} else if (*p_buffer == 'i') {
				// :si:
				p_buffer++;
				if (!sscanf(p_buffer, "%f", &ki)) return 1;
			} else if (*p_buffer == 'd') {
				// :sd:
				p_buffer++;
				if (!sscanf(p_buffer, "%f", &kd)) return 1;
			} else if (*p_buffer == 'm') {
				p_buffer++;
				if (*p_buffer == 's') {
					// :sms:
					p_buffer += 2;
					if (!sscanf(p_buffer, "%d", &MAX_SPEED))  return 1;
				}
			}
			else return 1;
		} else if (*p_buffer == 'g') {
			p_buffer++;
			if (*p_buffer == 'p') {
				// :gpid:
				char float2str_buf[15];
				usart_putstr(BLUETOOTH_USART, "PID,");
				snprintf(float2str_buf, 15, "%e", kp);
				usart_putstr(BLUETOOTH_USART, float2str_buf);
				usart_putstr(BLUETOOTH_USART, ",");
				snprintf(float2str_buf, 15, "%e", ki);
				usart_putstr(BLUETOOTH_USART, float2str_buf);
				usart_putstr(BLUETOOTH_USART, ",");
				snprintf(float2str_buf, 15, "%e", kd);
				usart_putstr(BLUETOOTH_USART, float2str_buf);
				usart_putstr(BLUETOOTH_USART, "\n");
			} else if (*p_buffer == 'b') {
				// :gbl:
				char float2str_buf[15];
				get_battery_level();
				usart_putstr(BLUETOOTH_USART, "BL,");
				snprintf(float2str_buf, 15, "%e", power_bat * 3.3f / 4096);
				usart_putstr(BLUETOOTH_USART, float2str_buf);
				usart_putstr(BLUETOOTH_USART, ",");
				snprintf(float2str_buf, 15, "%e", digital_bat * 3.3f / 4096);
				usart_putstr(BLUETOOTH_USART, float2str_buf);
				usart_putstr(BLUETOOTH_USART, "\n");
			} else if (*p_buffer == 'l') {
				// :glp:
				char float2str_buf[15];
				usart_putstr(BLUETOOTH_USART, "LP,");
				snprintf(float2str_buf, 15, "%e", line_position);
				usart_putstr(BLUETOOTH_USART, float2str_buf);
				usart_putstr(BLUETOOTH_USART, "\n");
			} else if (*p_buffer == 'u') {
				// :gu:
				usart_putudec(BLUETOOTH_USART, systick_uptime_millis);
				usart_putstr(BLUETOOTH_USART, "\n");
			} else if (*p_buffer == 'm') {
				p_buffer++;
				if (*p_buffer == 's') {
					// :sms:
					char float2str_buf[15];
					usart_putstr(BLUETOOTH_USART, "MS,");
					snprintf(float2str_buf, 15, "%d", MAX_SPEED);
					usart_putstr(BLUETOOTH_USART, float2str_buf);
					usart_putstr(BLUETOOTH_USART, "\n");
				} else return 1;
			} else if (*p_buffer == 'a') {
				 p_buffer++;
				if (*p_buffer == 'c') {
					// :ac:
					mode = AUTO;
					usart_putstr(BLUETOOTH_USART, "Switched to Automatic Mode");
					usart_putstr(BLUETOOTH_USART, "\n");
				}
			} else if (*p_buffer == 'm') {
				 p_buffer++;
				if (*p_buffer == 'c') {
					// :mc:
					mode = MANUAL;
					set_speed (0, 0);
					usart_putstr(BLUETOOTH_USART, "Switched to Manual Mode");
					usart_putstr(BLUETOOTH_USART, "\n");
				}
			} else return 1;
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

	/*
	 * Sensor array initialization:
	 *
	 *    % GPIO PC15 (D12) --> S0
	 *    % GPIO PC14 (D13) --> S1
	 *    % GPIO PA0  (D11) --> 1A
	 *    % GPIO PA1  (D10) --> 2A
	 *    % GPIO PA4  (D7)  --> 3A
	 *    % GPIO PA5  (D6)  --> 4A
	 */
	gpio_set_mode(GPIOC, 15, GPIO_OUTPUT_PP);    // S0 (D12)
	gpio_set_mode(GPIOC, 14, GPIO_OUTPUT_PP);    // S1 (D13)
	gpio_set_mode(GPIOA, 0, GPIO_INPUT_ANALOG);  // 1A (D11)
	gpio_set_mode(GPIOA, 1, GPIO_INPUT_ANALOG);  // 2A (D10)
	gpio_set_mode(GPIOA, 4, GPIO_INPUT_ANALOG);  // 3A (D7)
	gpio_set_mode(GPIOA, 5, GPIO_INPUT_ANALOG);  // 4A (D6)

	// Set output mode in D33 (Maple Mini's SMD LED) and set it to high
	gpio_set_mode(GPIOB, 1, GPIO_OUTPUT_PP);
	gpio_write_bit(GPIOB, 1, 1);

	// Stop motors
	set_speed(0, 0);

	// Serial 1 initialization
	Serial1.begin(1382400);            // TODO: avoid using wirish stuff

	// Set manual mode
	mode = MANUAL;

	// Ping timer
	// TODO: avoid using wirish stuff!
    //ping_timer.pause();
    //ping_timer.setPeriod(PING_PERIOD);
    //ping_timer.setChannel1Mode(TIMER_OUTPUT_COMPARE);
    //ping_timer.setCompare(TIMER_CH1, 1);  // Interrupt 1 count after each update
    //ping_timer.attachCompare1Interrupt(handler_ping);
    //ping_timer.refresh();
    //ping_timer.resume();
}

void sensor_array_read(void)
{
	// Set demux control signals to 00 and read data into the array
	gpio_write_bit(GPIOC, 15, 0);        // S0
	gpio_write_bit(GPIOC, 14, 0);        // S1
	array_data[3]  = adc_read(ADC1, 0);  // 1A (D11)
	array_data[4]  = adc_read(ADC1, 1);  // 2A (D10)
	array_data[11] = adc_read(ADC1, 4);  // 3A (D7)
	array_data[12] = adc_read(ADC1, 5);  // 4A (D6)

	// Set demux control signals to 01 and read data into the array
	gpio_write_bit(GPIOC, 15, 1);        // S0
	gpio_write_bit(GPIOC, 14, 0);        // S1
	array_data[1]  = adc_read(ADC1, 0);  // 1A (D11)
	array_data[6]  = adc_read(ADC1, 1);  // 2A (D10)
	array_data[10] = adc_read(ADC1, 4);  // 3A (D7)
	array_data[13] = adc_read(ADC1, 5);  // 4A (D6)

	// Set demux control signals to 10 and read data into the array
	gpio_write_bit(GPIOC, 15, 0);        // S0
	gpio_write_bit(GPIOC, 14, 1);        // S1
	array_data[2]  = adc_read(ADC1, 0);  // 1A (D11)
	array_data[5]  = adc_read(ADC1, 1);  // 2A (D10)
	array_data[9]  = adc_read(ADC1, 4);  // 3A (D7)
	array_data[14] = adc_read(ADC1, 5);  // 4A (D6)

	// Set demux control signals to 1 and read data into the array
	gpio_write_bit(GPIOC, 15, 1);        // S0
	gpio_write_bit(GPIOC, 14, 1);        // S1
	array_data[0]  = adc_read(ADC1, 0);  // 1A (D11)
	array_data[7]  = adc_read(ADC1, 1);  // 2A (D10)
	array_data[8]  = adc_read(ADC1, 4);  // 3A (D7)
	array_data[15] = adc_read(ADC1, 5);  // 4A (D6)
}

void set_line_position(void)
{
	float aux=0, cont=0;
	int i;
	for (i = 0; i < 16; i++) {
		if (array_data[i] > SENSOR_TRESHOLD) {
			aux += i;
			cont += 1;
		}
	}
	line_position = cont ? aux/cont : -1;
}
	
	/**
 * @brief Returns the line position
 * 
 * The return value will go from 1 to the number of sensors the array has
 * If there is no line it will return -1
 *
 * @author Juan Herrero Macías <jn.herrerom@gmail.com>
 * @date 2013/03/08
 */
void set_analog_line_position(void)
{
	float aux=0, cont=0;
	int i;
	for (i = 1; i <= NUMBER_OF_IR_SENSORS; i++) {
		if (array_data[i] > SENSOR_TRESHOLD) {
			aux += i * (array_data - min_measurement);
			cont += 1;
		}
	}
	line_position = cont ? aux/(max_measurement - min_measurement) : -1;
}

void debug_sensor_array(void)
{
	int i;
	for (i = 0; i < 16; i++) {
		if (array_data[i] > SENSOR_TRESHOLD) usart_putc(BLUETOOTH_USART, '1');
		else usart_putc(BLUETOOTH_USART, '0');
	}
	usart_putc(BLUETOOTH_USART, ' ');
	usart_putudec(BLUETOOTH_USART, line_position * 10);
	usart_putc(BLUETOOTH_USART, '\n');
}

float get_pid_output(void)
{
	float output;

	time = systick_uptime_millis;
	dt = time - prev_time;

	error = line_position - SENSOR_ARRAY_MIDDLE;
	integral += error*dt;
	derivative = (error - prev_error)/dt;

	output = kp*error + kd*derivative + ki*integral;

	prev_time = time;
	prev_error = error;

	return output;
}

void auto_mode(void)
{
	sensor_array_read();
	set_line_position();

	correction = get_pid_output();

	if (correction > 0) {
		set_speed((int) MAX_SPEED, (int) MAX_SPEED - correction);
		//~ usart_putc(BLUETOOTH_USART, '+');
		//~ usart_putudec(BLUETOOTH_USART, correction);
	} else {
		set_speed((int) MAX_SPEED + correction, (int) MAX_SPEED);
		//~ usart_putc(BLUETOOTH_USART, '-');
		//~ usart_putudec(BLUETOOTH_USART, -correction);
	}
	//~ usart_putc(BLUETOOTH_USART, '\n');

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

	delay(1);
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
