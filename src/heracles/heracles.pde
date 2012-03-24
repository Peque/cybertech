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

// Global variables
int qtr_sensors[QTR_NSENSORS];

void setup()
{
	// Serial setup:
	Serial.begin(115200);

	// Initialize pins
	pinMode(QTR_LEDON, OUTPUT);
	pinMode(MUX_IN_0, OUTPUT);
	pinMode(MUX_IN_1, OUTPUT);
}

void loop()
{
	qtrd_array_read();
	qtrd_array_debug();
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
