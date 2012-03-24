/*
 * heracles.pde
 *
 * Copyright 2012 Miguel Sánchez de León Peque <msdeleonpeque@gmail.com>
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
 * 8 reflectance sensor array through a dual 4:1 analog multiplexer
 * (4 channels, 2 lines).
 *
 * We are controlling 8 reflectance sensors with 5 pins:
 *
 *  - LED on pin: turn the IR emmiters on (HIGH) or off (LOW).
 *  - Channel pins: these two pins are used to change the channel we are
 *    reading from.
 *  - Read pins: these two pins are used to get the data from the array.
 *
 * For us:
 *
 *  - Channel 00 means the 2 sensors in the middle.
 *  - Channel 01 means the next 2.
 *  - Channel 11 means the next 2.
 *  - Channel 10 means the 2 sensors in the ends.
 *  - Line 0 means the 4 left sensors.
 *  - Line 1 means the 4 right sensors.
 */
#define QTR_NSENSORS 8    // Number of reflectance sensors in the array
#define QTR_LEDON 2       // Pin: IR state (on/off)
#define MUX_DATA_0 3      // Pin: line 0
#define MUX_DATA_1 4      // Pin: line 1
#define MUX_IN_0 5        // Pin: channel (less significant bit)
#define MUX_IN_1 6        // Pin: channel (most significant bit)

// Motor driver
#define ML_IN0 7
#define ML_IN1 13   // Pin 8 seems to be broken...
#define ML_PWM 9
#define MR_PWM 10
#define MR_IN1 11
#define MR_IN0 12

// Configuration
#define MAX_SPEED 255     // Max motor speed  (absolute value)


/*
 * TODO: create a header file to support type definitions
 *
 *   typedef enum { LEFT, FRONT, RIGHT, BACK } position;
 *
 * Use this tipe in motors_speed() function.
 */
#define FRONT 0
#define RIGHT 1
#define BACK 2
#define LEFT 3


// Global variables
int qtr_sensors[QTR_NSENSORS];
unsigned long current_time;


void setup()
{
	// Serial setup:
	Serial.begin(115200);

	// Initialize sensor array and multiplexer pins
	pinMode(QTR_LEDON, OUTPUT);
	pinMode(MUX_IN_0, OUTPUT);
	pinMode(MUX_IN_1, OUTPUT);

	// Initialize motor pins
	pinMode(ML_IN0, OUTPUT);
	pinMode(ML_IN1, OUTPUT);
	pinMode(ML_PWM, OUTPUT);
	pinMode(MR_PWM, OUTPUT);
	pinMode(MR_IN1, OUTPUT);
	pinMode(MR_IN0, OUTPUT);
}


void loop()
{

	set_speed(RIGHT, -100);

	current_time = millis();
	while (millis() - current_time < 1000);

	set_speed(LEFT, 100);

	current_time = millis();
	while (millis() - current_time < 1000);

	set_speed(FRONT, 0);

	current_time = millis();
	while (millis() - current_time < 1000);
}


/**
 * @brief Turn off motors (set OUT1 and OUT2 to high impedance).
 *
 * The motors_stop() function turns off the motors with a coast effect.
 *
 * @warning
 *   There is no danger involved in using this coast state, but
 *   alternating between drive and brake produces a more linear
 *   relationship between motor RPM and PWM duty cycle than does
 *   alternating between drive and coast.

 * @author Miguel Sánchez de León Peque <msdeleonpeque@gmail.com>
 * @date 2012/03/24
 */
void motors_stop()
{
	digitalWrite(ML_IN0, LOW);
	digitalWrite(ML_IN1, LOW);
	digitalWrite(MR_IN0, LOW);
	digitalWrite(MR_IN1, LOW);
}


/**
 * @brief Print the digital sensor array readings through the serial port.
 *
 * For debugging purpouses, the qtrd_array_debug() function allows you
 * to easily print the digital sensor array reading through the serial
 * port.
 *
 * @author Miguel Sánchez de León Peque <msdeleonpeque@gmail.com>
 * @date 2012/03/24
 */
void qtrd_array_debug(void)
{
	int i;

	for (i = 0; i < QTR_NSENSORS; i++) {
		Serial.print(qtr_sensors[i]);
		Serial.print("	");
	}
	Serial.println(" ");
}


/**
 * @brief Read data from the digital reflectance sensor array.
 *
 * The qtrd_array_read() function is designed to work with an 8 sensor
 * array and through a dual 4:1 analog multiplexer. We have adjusted the
 * function to work with the Pololu QTR-8RC (digital) sensor array.
 *
 * @author Miguel Sánchez de León Peque <msdeleonpeque@gmail.com>
 * @date 2012/03/24
 */
void qtrd_array_read(void)
{
	// Turn IR emmiters on
	digitalWrite(QTR_LEDON, HIGH);

	// Set channel to X0
	digitalWrite(MUX_IN_0, 0);

	// Set I/O lines to output + HIGH
	pinMode(MUX_DATA_0, OUTPUT);
	pinMode(MUX_DATA_1, OUTPUT);
	digitalWrite(MUX_DATA_0, HIGH);
	digitalWrite(MUX_DATA_1, HIGH);

	// Seems that the time it takes to change the channel (digitalWrite)
	// is enough to let the capacitors charge
	digitalWrite(MUX_IN_1, 0);       // Set channel to 00
	digitalWrite(MUX_IN_0, 1);       // Set channel to 01
	digitalWrite(MUX_IN_1, 1);       // Set channel to 11
	digitalWrite(MUX_IN_0, 0);       // Set channel to 10

	// Set I/O lines to high impedance for reading
	pinMode(MUX_DATA_0, INPUT);
	pinMode(MUX_DATA_1, INPUT);

	// Let (some) capacitors discharge
	delayMicroseconds(300);

	// Set channel to X0
	digitalWrite(MUX_IN_0, 0);

	// Read and store data from the sensor array
	digitalWrite(MUX_IN_1, 0);                 // Set channel to 00
	qtr_sensors[3] = digitalRead(MUX_DATA_0);
	qtr_sensors[4] = digitalRead(MUX_DATA_1);
	digitalWrite(MUX_IN_0, 1);                 // Set channel to 01
	qtr_sensors[2] = digitalRead(MUX_DATA_0);
	qtr_sensors[5] = digitalRead(MUX_DATA_1);
	digitalWrite(MUX_IN_1, 1);                 // Set channel to 11
	qtr_sensors[1] = digitalRead(MUX_DATA_0);
	qtr_sensors[6] = digitalRead(MUX_DATA_1);
	digitalWrite(MUX_IN_0, 0);                 // Set channel to 10
	qtr_sensors[0] = digitalRead(MUX_DATA_0);
	qtr_sensors[7] = digitalRead(MUX_DATA_1);

	// Turn IR emmiters off
	digitalWrite(QTR_LEDON, LOW);
}


/**
 * @brief Set motors' speed (speed up or break them).
 *
 * The set_speed(position motor, int speed) function sets the speed of
 * the right (RIGHT), left (LEFT) or both motors (FRONT). It can make
 * the motors break.
 *
 * @param[in] motor_position Motor position (left, right or both).
 * @param[in] speed_fr Value for speed.
 * @author Miguel Sánchez de León Peque <msdeleonpeque@gmail.com>
 * @date 2012/03/24
 */
void set_speed(uint8_t motor_position, int speed_fr)
{
	uint8_t speed, FORWARD;

	// Fix incorrect values for speed
	speed_fr = (speed_fr > MAX_SPEED) ? MAX_SPEED : (speed_fr < -MAX_SPEED) ? -MAX_SPEED : speed_fr;

	FORWARD = (speed_fr < 0) ? 0 : 1;
	speed = abs(speed_fr);

	switch (motor_position) {
		case FRONT :
			if (FORWARD) {
				// Motor 0 forward at speed
				digitalWrite(ML_IN0, HIGH);
				digitalWrite(ML_IN1, LOW);
				// Motor 1 forward at speed
				digitalWrite(MR_IN0, HIGH);
				digitalWrite(MR_IN1, LOW);
			} else {
				// Motor 0 reverse at speed
				digitalWrite(ML_IN0, LOW);
				digitalWrite(ML_IN1, HIGH);
				// Motor 1 reverse at speed
				digitalWrite(MR_IN0, LOW);
				digitalWrite(MR_IN1, HIGH);
			}
			analogWrite(ML_PWM, speed);
			analogWrite(MR_PWM, speed);
			break;
		case LEFT :
			if (FORWARD) {
				// Motor 0 forward at speed
				digitalWrite(ML_IN0, HIGH);
				digitalWrite(ML_IN1, LOW);
			} else {
				// Motor 0 reverse at speed
				digitalWrite(ML_IN0, LOW);
				digitalWrite(ML_IN1, HIGH);
			}
			analogWrite(ML_PWM, speed);
			break;
		case RIGHT :
			if (FORWARD) {
				// Motor 1 forward at speed
				digitalWrite(MR_IN0, HIGH);
				digitalWrite(MR_IN1, LOW);
			} else {
				// Motor 1 reverse at speed
				digitalWrite(MR_IN0, LOW);
				digitalWrite(MR_IN1, HIGH);
			}
			analogWrite(MR_PWM, speed);
			break;
		default :
			// Break both motors
			digitalWrite(ML_IN0, HIGH);
			digitalWrite(ML_IN1, HIGH);
			digitalWrite(MR_IN0, HIGH);
			digitalWrite(MR_IN1, HIGH);
			break;
	}
}
