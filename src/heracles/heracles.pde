/*
 * heracles.pde
 *
 * Copyright 2012
 *
 *   - Miguel Sánchez de León Peque <msdeleonpeque@gmail.com>
 *   - Juan Herrero Macías <jn.herrerom@gmail.com>
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

//Battery Check
#define POWER_BATTERY_PIN 1
#define DIGITAL_BATTERY_PIN 2
#define MIN_BATTERY_LEVEL 710 // 3.2V (experimental value)
#define LOW_BATTERY_LEVEL 760 // 3.4V (experimental value)
#define LED_BATTERY_PIN 8 // Pin 8 seems to provide 2.5V on HIGH, which is enough for a LED...

// Motor driver
#define ML_IN0 7
#define ML_IN1 13   // Pin 8 seems to be broken...
#define ML_PWM 9
#define MR_PWM 10
#define MR_IN1 11
#define MR_IN0 12

// SHARP sensors
#define SHARP_LEFT 4                   // Left sensor in A4
#define SHARP_FRONT 3                  // Front sensor in A3
#define SHARP_RIGHT 2                  // Right sensor in A2

// Configuration
#define MAX_SPEED 255     // Max motor speed  (absolute value)

// PID Constants
#define Kp 50.
#define Kd 3500.
// #define Ki 0.0005

// Line Follower Constants
#define QTR_MIDDLE_LINE 3.5

// RGB LED
#define LED_RED 2
#define LED_GREEN 3
#define LED_BLUE 4



/*
 * TODO: create a header file to support type definitions
 *
 *   typedef enum { LEFT, FRONT, RIGHT, BACK } position;
 *
 * Use this tipe in motors_set_speed() function.
 */
#define FRONT 0
#define RIGHT 1
#define BACK 2
#define LEFT 3


// Global variables
int qtr_sensors[QTR_NSENSORS];
unsigned long current_time;

// PID Variables
float error, prev_error, integral, derivative;
unsigned long dt, time, prev_time;
float correction;
float line_position;
float last_line_position = 3.5;

// Test Variables

int counter = 0;


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

	// Initialize LED pins
	pinMode(LED_RED, OUTPUT);
	pinMode(LED_GREEN, OUTPUT);
	pinMode(LED_BLUE, OUTPUT);

	// Check batteries on start
	pinMode(LED_BATTERY_PIN, OUTPUT);
	//~ check_batteries();
}


void loop()
{
	sharp_debug();
	set_rgb(255, 0, 0);
	delay(1000);
	set_rgb(0, 255, 0);
	delay(1000);
	set_rgb(0, 0, 255);
	delay(1000);
}

/**
 * @brief Returns distance from sensor SHARP 2Y0A21 to the reflective object in mm.
 *
 * The get_distance(uint8_t sensor) function calculates de distance
 * from the specified sensor to the reflective object and returns this
 * value in mm. The distance is calculated this way:
 * @f[
 * distance = 270/(5.0/1023*Vo)
 * @f]
 * Where Vo is the sensor's analog output reading (0V -> 0, 5V -> 1023),
 * 270 is the constant scale factor (V*mm) and 10 is the correction (mm).
 *
 * @param[in] sensor Name of the sensor's analog input.
 * @return Linearized output of the distance from sensor to the reflective object in mm.
 * @author Miguel Sánchez de León Peque <msdeleonpeque@gmail.com>
 * @date 2011/03/15
 */
float get_2Y0A21_distance(uint8_t sensor)
{
	float Vo;

	Vo = analogRead(sensor);

    // Prevent incorrect values when the reflective surface is too far away:
    Vo = Vo < 60 ? 60 : Vo;

    /*
    * In its simplest form, the linearizing equation can be that the
    * distance to the reflective object is approximately equal to a
    * constant scale factor (~270 V*mm) divided by the sensor’s output
    * voltage minus a correction (~10 mm):
    */
    return 270/(5.0/1023*Vo)-10; // TODO: Linearize the output dividing the curve in 3-4 pieces (not very important though...)
}


/**
 * @brief Returns distance from sensor SHARP 2D120X to the reflective object in mm.
 *
 * The get_distance(uint8_t sensor) function calculates de distance
 * from the specified sensor to the reflective object and returns this
 * value in mm. The distance is calculated this way:
 * @f[
 * distance = 132/(5.0/1023*Vo)-5
 * @f]
 * Where Vo is the sensor's analog output reading (0V -> 0, 5V -> 1023),
 * 132 is the constant scale factor (V*mm) and 5 is the correction (mm).
 *
 * @param[in] sensor Name of the sensor's analog input.
 * @return Linearized output of the distance from sensor to the reflective object in mm.
 * @author Miguel Sánchez de León Peque <msdeleonpeque@gmail.com>
 * @date 2012/04/23
 */
float get_2D120X_distance(uint8_t sensor)
{
    float Vo;

    Vo = analogRead(sensor);

	// Prevent incorrect values when the reflective surface is too far away:
    Vo = Vo < 60 ? 60 : Vo;

    /*
    * In its simplest form, the linearizing equation can be that the
    * distance to the reflective object is approximately equal to a
    * constant scale factor (~132 V*mm) divided by the sensor’s output
    * voltage minus a correction (~5 mm):
    */
    return 132/(5.0/1023*Vo)-5; // TODO: Linearize the output dividing the curve in 3-4 pieces (not very important though...)
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

void sharp_debug(void)
{
	Serial.print(get_2D120X_distance(SHARP_LEFT));
	Serial.print("    \t");
	Serial.print(get_2Y0A21_distance(SHARP_FRONT));
	Serial.print("    \t");
	Serial.println(get_2D120X_distance(SHARP_RIGHT));
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
void motors_set_speed(uint8_t motor_position, int speed_fr)
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

void qtrd_set_line_pos(void)
{
	float aux=0, cont=0;
	int i;

	for (i = 0; i < QTR_NSENSORS; i++) {
		if (qtr_sensors[i]) {
			aux += i;
			cont += 1;
		}
	}

	line_position = cont ? aux/cont : -1;
	if  (line_position != -1) last_line_position = line_position;
}

float qtrd_pid_output(void)
{
	float output;

	time = millis();

	dt = time - prev_time;

	error = line_position - QTR_MIDDLE_LINE;
//	integral += error*dt;

	derivative = (error - prev_error)/dt;

	if (qtr_sensors[0] || qtr_sensors[7]) output = 150*error + Kd*derivative;
	else output = Kp*error + Kd*derivative; // + Ki*integral

	prev_time = time;
	prev_error = error;
	return output;
}

void motors_speed_regulation(void)
{
		if (correction > 0) {
		motors_set_speed(RIGHT, MAX_SPEED - correction);
		motors_set_speed(LEFT, MAX_SPEED);
	} else {
		motors_set_speed(RIGHT, MAX_SPEED);
		motors_set_speed(LEFT, MAX_SPEED + correction);
	}
}


/**
 * @brief Checks battery levels to protect them.
 *
 * It warns battery levels lower than the reference LOW_BATTERY_LEVEL
 * and even aborts if the voltage is under MIN_BATTERY_LEVEL.
 *
 * @author Miguel Sánchez de León Peque <msdeleonpeque@gmail.com>
 * @author Juan Herrero Macías <jn.herrerom@gmail.com>
 * @date 2012/04/03
 */
void check_batteries()
{
	digitalWrite(LED_BATTERY_PIN, LOW);

	uint16_t v_level;

	v_level = analogRead(POWER_BATTERY_PIN);

	if (v_level < LOW_BATTERY_LEVEL) {
		if (v_level < MIN_BATTERY_LEVEL) {
			Serial.print("Error: low voltage in power battery! (");
			Serial.print(v_level);
			Serial.print("/1023)\nAborting...");
			digitalWrite(LED_BATTERY_PIN, HIGH);
			while (1);
		} else {
			Serial.print("Warning: low voltage in power battery! (");
			Serial.print(v_level);
			Serial.print("/1023)\nAborting...");
			digitalWrite(LED_BATTERY_PIN, HIGH);
		}
	}

	v_level = analogRead(DIGITAL_BATTERY_PIN);

	if (v_level < LOW_BATTERY_LEVEL) {
		if (v_level < MIN_BATTERY_LEVEL) {
			Serial.print("Error: low voltage in digital battery! (");
			Serial.print(v_level);
			Serial.print("/1023)\nAborting...");
			digitalWrite(LED_BATTERY_PIN, HIGH);
			while (1);
		} else {
			Serial.print("Warning: low voltage in digital battery! (");
			Serial.print(v_level);
			Serial.print("/1023)\nAborting...");
			digitalWrite(LED_BATTERY_PIN, HIGH);
		}
	}
}


/**
 * @brief Set RGB LED's colors.
 *
 * The set_rgb(uint8_t red, uint8_t green, uint8_t blue) function is
 * used to change the brightness of the RGB LED's colors.
 *
 * @param[in] red Value for red color: from 0 to 255.
 * @param[in] green Value for green color: from 0 to 255.
 * @param[in] blue Value for blue color: from 0 to 255.
 * @author Miguel Sánchez de León Peque <msdeleonpeque@gmail.com>
 * @date 2011/03/19
 */
void set_rgb(uint8_t red, uint8_t green, uint8_t blue)
{
    analogWrite(LED_RED, red);
    analogWrite(LED_GREEN, green);
    analogWrite(LED_BLUE, blue);
}
