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
 * 8 reflectance analogic sensor array in the middle and 4 reflectance digital sensors, 2 on each side of the array
 * Numbered from left to right D0, D1, A0 ... A7, D2, D3
 */

#define QTR_NSENSORS 8    // Number of reflectance sensors in the array
#define QTR_ADDITIONAL_SENSORS 4 //Number of additional DC sensors placed at each side of the array
//~ #define QTR_TRESHOLD 50 // It is now set in qrt_treshold int as the minimum sensor read at the start
#define QTR_CALIBRATE_ITERATIONS 10
#define MUX_DATA_0 3      // Pin: line 0
#define MUX_DATA_1 4      // Pin: line 1
#define MUX_IN_0 5        // Pin: channel (less significant bit)
#define MUX_IN_1 6        // Pin: channel (most significant bit)
#define QTR_SENSOR_A0 0
#define QTR_SENSOR_A1 1
#define QTR_SENSOR_A2 2
#define QTR_SENSOR_A3 3
#define QTR_SENSOR_A4 4
#define QTR_SENSOR_A5 5
#define QTR_SENSOR_A6 6
#define QTR_SENSOR_A7 7
#define QTR_SENSOR_D0 37
#define QTR_SENSOR_D1 36
#define QTR_SENSOR_D2 35
#define QTR_SENSOR_D3 34


//Battery Check
#define POWER_BATTERY_PIN 8
#define DIGITAL_BATTERY_PIN 9
#define MIN_BATTERY_LEVEL 710 // 3.2V (experimental value)
#define LOW_BATTERY_LEVEL 760 // 3.4V (experimental value)
#define LED_BATTERY_PIN 8 // Pin 8 seems to provide 2.5V on HIGH, which is enough for a LED...

// Motor driver
#define ML_IN0 30
#define ML_IN1 31
#define ML_PWM 6
#define MR_PWM 5
#define MR_IN1 29
#define MR_IN0 28

// Configuration
#define MAX_SPEED 255     // Max motor speed  (absolute value)

// PID Constants
#define Kp 50.
#define Kd 3500.
// #define Ki 0.0005

// Line Follower Constants
#define QTR_MIDDLE_LINE 3.5



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
int qtr_sensors[QTR_NSENSORS + QTR_ADDITIONAL_SENSORS];
int qtr_min_treshold = 0; // Minimum qtr sensor read value needed to be used when estimating the line position
int qtr_max_treshold = 1;
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

	// Initialize motor pins
	pinMode(ML_IN0, OUTPUT);
	pinMode(ML_IN1, OUTPUT);
	pinMode(ML_PWM, OUTPUT);
	pinMode(MR_PWM, OUTPUT);
	pinMode(MR_IN1, OUTPUT);
	pinMode(MR_IN0, OUTPUT);

	// Check batteries on start
	pinMode(LED_BATTERY_PIN, OUTPUT);
	//~ check_batteries();

	 qtr_min_treshold = qtra_calibrate();
}


void loop()
{
	qtra_array_read();
	qtr_array_debug();
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
 * @brief Sets a max and a min read value before starting for maximun analog read efficiency
 *
 * @author Juan Herrero Macias <jn.herrerom@gmail.com>
 * @date 2012/04/23
 */

int qtra_calibrate(void)
{
	int min_qtr_read[QTR_CALIBRATE_ITERATIONS];
	int max_qtr_read[QTR_CALIBRATE_ITERATIONS];
	int min_treshold = 0;
	int i, j, aux;
	for (j = 0; j < QTR_CALIBRATE_ITERATIONS; j++) {
		qtra_array_read();
		int min = 1023;
		int max = 0;
		for ( i = (QTR_ADDITIONAL_SENSORS / 2); i < (QTR_NSENSORS + (QTR_ADDITIONAL_SENSORS / 2) ); i++) {
			if ((aux = qtr_sensors[i]) < min) {
				min_qtr_read [j] = aux;
				min = aux;
			}
			if (aux > max) {
				max_qtr_read [j] = aux;
				max = aux;
			}
		}
		min_treshold += min_qtr_read[j];
		qtr_max_treshold += max_qtr_read[j];
		delay(50);
	}
	min_treshold = int (min_treshold / QTR_CALIBRATE_ITERATIONS);
	qtr_max_treshold = int (qtr_max_treshold / QTR_CALIBRATE_ITERATIONS);
	return min_treshold;
}


/**
 * @brief Print the sensor readings through the serial port.
 *
 * For debugging purpouses, the qtrd_array_debug() function allows you
 * to easily print the sensor reading through the serial
 * port.
 *
 * @author Miguel Sánchez de León Peque <msdeleonpeque@gmail.com>
 * @author Juan Herrero Macías <jn.herrerom@gmail.com>
 * @date 2012/04/23
 */
void qtr_array_debug(void)
{
	int i;

	for (i = 0; i < (QTR_NSENSORS + QTR_ADDITIONAL_SENSORS); i++) {
		Serial.print(qtr_sensors[i]);
		Serial.print("	");
	}
	Serial.print ("  min : ");
	Serial.print ((int)qtr_min_treshold);
	Serial.print ("  max : ");
	Serial.print ((int)qtr_max_treshold);
	Serial.println(" ");
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

// QTRA  functions

/**
 * @brief Read data from the analogic reflectance sensor array and the additional digital sensors
 *
 * The qtrd_array_read() function is designed to work with an 8 sensor
 * array connectoted to the pins defined by QTR_SENSOR_*
 *
 * @author Juan Herrero Macías <jn.herrerom@gmail.com>
 * @date 2012/04/22
 */
void qtra_array_read(void)
{
	//~ // First we charge the digital sensor capacitors
	pinMode(QTR_SENSOR_D0, OUTPUT);
	pinMode(QTR_SENSOR_D1, OUTPUT);
	pinMode(QTR_SENSOR_D2, OUTPUT);
	pinMode(QTR_SENSOR_D3, OUTPUT);
	digitalWrite(QTR_SENSOR_D0, HIGH);
	digitalWrite(QTR_SENSOR_D1, HIGH);
	digitalWrite(QTR_SENSOR_D2, HIGH);
	digitalWrite(QTR_SENSOR_D3, HIGH);
	//~ // We let them charging while we read analogic sensors
	qtr_sensors[2] = (analogRead(QTR_SENSOR_A0) - qtr_min_treshold);
	qtr_sensors[3] = analogRead(QTR_SENSOR_A1) - qtr_min_treshold;
	qtr_sensors[4] = analogRead(QTR_SENSOR_A2) - qtr_min_treshold;
	qtr_sensors[5] = analogRead(QTR_SENSOR_A3) - qtr_min_treshold;
	// We let them discharge
	pinMode(QTR_SENSOR_D0, INPUT);
	pinMode(QTR_SENSOR_D1, INPUT);
	pinMode(QTR_SENSOR_D2, INPUT);
	pinMode(QTR_SENSOR_D3, INPUT);
	// We the read the analogic sensors left
	qtr_sensors[6] = analogRead(QTR_SENSOR_A4) - qtr_min_treshold;
	qtr_sensors[7] = analogRead(QTR_SENSOR_A5) - qtr_min_treshold;
	qtr_sensors[8] = analogRead(QTR_SENSOR_A6) - qtr_min_treshold;
	qtr_sensors[9] = analogRead(QTR_SENSOR_A7) - qtr_min_treshold;
	// Then we read digital values
	delayMicroseconds (200);
	qtr_sensors[0] = digitalRead(QTR_SENSOR_D0);
	qtr_sensors[1] = digitalRead(QTR_SENSOR_D1);
	qtr_sensors[10] = digitalRead(QTR_SENSOR_D2);
	qtr_sensors[11] = digitalRead(QTR_SENSOR_D3);
}


//~ void qtra_set_line_pos(void)
//~ {
	//~ float num=0;
	//~ float den=0;
	//~ float cont=0;
	//~ int i;
//~
	//~ for ( i = (QTR_ADDITIONAL_SENSORS / 2); i < (QTR_NSENSORS - (QTR_ADDITIONAL_SENSORS / 2) ); i++) {
		//~ if (qtr_sensors[i] > qrt_treshold) {
			//~ num += i * qrt_sensors[i];
			//~ den += qrtsensors[i];
			//~ cont += 1;
		//~ }
	//~ }
//~
	//~ line_position = cont ? num/den : -1;
	//~ if  (line_position != -1) last_line_position = line_position;
//~ }

float qtra_pid_output(void)
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

// QTRD Functions

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
