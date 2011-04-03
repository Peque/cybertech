/*
 *    mje_427101.pde
 *
 *    Copyright (C) 2011 Miguel Sánchez de León Peque <msdeleonpeque@gmail.com>
 *
 *    This program is free software: you can redistribute it and/or modify
 *    it under the terms of the GNU General Public License as published by
 *    the Free Software Foundation, either version 3 of the License, or
 *    (at your option) any later version.
 *
 *    This program is distributed in the hope that it will be useful,
 *    but WITHOUT ANY WARRANTY; without even the implied warranty of
 *    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 *    GNU General Public License for more details.
 *
 *    You should have received a copy of the GNU General Public License
 *    along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */


#include <mje_427101.h>


// PID variables
unsigned long prev_time;     // Previous time
float prev_err;              // Previous error

// Instant position variables
float dist_left, dist_right, dist_front;

// Configuration variables
float v_max = 0.54;         // Max speed in m/s
int CHOOSE_LEFT = 1;        // Left by default
int INITIALIZED = 0;        // Boolean variable to know if the robot is already initialized
int JUST_TURNED = 0;


void setup()
{
	// Serial setup
	Serial.begin(9600);

	// Motor setup
	init_qik();
	set_speed(FRONT, 0);

	// LED setup
	pinMode(LED_RED, OUTPUT);
	pinMode(LED_GREEN, OUTPUT);
	pinMode(LED_BLUE, OUTPUT);

	// Initialization
//	init_mje();
	delay(5000);
}

void loop()
{
	while (way_straight()) move_forward();
	if (way_simple()) turn();
	else solve_node();
}

void turn()
{
	if (dist_left > MAX_DIST_SIDE) turn_left();
	else if (dist_right > MAX_DIST_SIDE) turn_right();
	else if (dist_right < MAX_DIST_SIDE) turn_back();
	JUST_TURNED = 1;
}

void turn_right()   // TODO: merge turn_right() and turn_left() into one simple function
{
	set_rgb(0, 0, 255);
	set_speed(LEFT, 127);
	set_speed(RIGHT, 70); // TODO: this should depend on speed... 127*(LANE_WIDTH-DIAMETER)/(LANE_WIDTH+DIAMETER) (?)
	delay(650); // TODO: this should depend on speed... (PI/2*(LANE_WIDTH/2+DIAMETER/2))/(v_max) (?)
}

void turn_right_simple()   // TODO: merge turn_right_simple() and turn_left_simple() into one simple function
{
	// TODO: implement this function
}

void turn_left()
{
	set_rgb(255, 0, 0);
	set_speed(LEFT, 70); // TODO: this should depend on speed... 127*(LANE_WIDTH-DIAMETER)/(LANE_WIDTH+DIAMETER) (?)
	set_speed(RIGHT, 127);
	delay(650); // TODO: this should depend on speed... (PI/2*(LANE_WIDTH/2+DIAMETER/2))/(v_max) (?)
}

void turn_left_simple()   // TODO: merge turn_right_simple() and turn_left_simple() into one simple function
{
	// TODO: implement this function
}

void turn_none()
{
	unsigned long time = millis();
	float dist_0;

	if (dist_right < MAX_DIST_SIDE) {
		set_rgb(0, 0, 255);
		dist_0 = dist_right;
		while (millis() - time < TIME_TO_PASSTHROUGH) move_through(RIGHT, dist_0);
		set_rgb(0, 0, 0);
	} else if (dist_left < MAX_DIST_SIDE) {
		set_rgb(255, 0, 0);
		dist_0 = dist_left;
		while (millis() - time < TIME_TO_PASSTHROUGH) move_through(LEFT, dist_0);
		set_rgb(0, 0, 0);
	} else {
		set_rgb(0, 255, 0);
		set_speed(FRONT, 127);
		while (millis() - time < TIME_TO_PASSTHROUGH);
		set_rgb(0, 0, 0);
	}
}

void init_mje()
{
	unsigned long time = millis();
	int conf;
	do {
		conf = get_config(0);
		if (((millis() - time)/500) % 2 == 0) set_rgb(255, 0, 0);
		else set_rgb(0, 0, 255);
	} while (conf < 2);
	if (conf == 2) CHOOSE_LEFT = 1;
	else CHOOSE_LEFT = 0;
	while (get_config(1) != 1) {
		if (CHOOSE_LEFT) set_rgb(255, 0, 0);
		else set_rgb(0, 0, 255);
	}

	time = millis();
	set_speed(RIGHT, 127);
	set_speed(LEFT, -127);
	delay(100);
	while (abs((int) get_distance(SHARP_FRONT) - CONFIG_DIST) > CONFIG_PREC + 20);
	delay(100);
	while (abs((int) get_distance(SHARP_FRONT) - CONFIG_DIST) > CONFIG_PREC + 20);
	v_max = 2*PI*DIAMETER/(millis()-time);
	set_speed(FRONT, 0);

	for (int i=0; i<4; i++) {
		delay(1000);
		turn_back();
	}

	delay(5000);

	while (get_config(0) != 1) {
		if (((millis() - time)/200) % 2 == 0) set_rgb(0, 255, 0);
		else set_rgb(0, 0, 0);
	}

	set_rgb(0, 255, 0);
	delay(2000);

	INITIALIZED = 1;
}

void solve_node()
{
	if (CHOOSE_LEFT) {
		if (dist_left > MAX_DIST_SIDE) turn_left();
		else if (dist_front > MAX_DIST_FRONT) turn_none();
		else turn_right();
	} else {
		if (dist_right > MAX_DIST_SIDE) turn_right();
		else if (dist_front > MAX_DIST_FRONT) turn_none();
		else turn_left();
	}
}

void speed_up()
{
	int i = 1;
	while (i < 128) {
		set_speed(RIGHT, i);
		i += 5;
		set_speed(LEFT, i);
		i += 5;
	}
	set_speed(FRONT, 127);
}

/**
 * @brief Stop program execution.
 *
 * The debug_abort() function may be used for debugging, stopping the
 * program execution for ever.
 *
 * @author Miguel Sánchez de León Peque <msdeleonpeque@gmail.com>
 * @date 2011/02/24
 */
void debug_abort()
{
	debug_pause(0);
	while (1);
}

/**
 * @brief Pause program execution for a while.
 *
 * The debug_pause(int ms) function may be used for debugging, pausing
 * the program execution for ms miliseconds.
 *
 * @author Miguel Sánchez de León Peque <msdeleonpeque@gmail.com>
 * @date 2011/02/24
 */
void debug_pause(int ms)
{
	set_speed(FRONT, 0);
	set_rgb(0, 0, 0);
	delay(ms);
}

/**
 * @brief Gets configuration parameters from one of the sensors.
 *
 * The get_config(uint8_t interrupt) function reads from all sensors
 * until it gets an appropiate response. That means it must read a value
 * at the correct distance and for a few seconds without interruptions.
 *
 * While the sensor is reading, the LED will blink fast with green, red
 * or blue color depending on the selected sensor (front, left or blue
 * respectively). After the reading is confirmed, the LED will stop
 * blinking or the function will end (depending on the value of the
 * parameter "interrupt": 0 to stop blinking, 1 to exit function).
 *
 * @param[in] interrupt Toggle it to 1 if you want to exit get_config() after confirmation.
 * @return Sensor which has confirmed the reading: 1 for FRONT, 2 for LEFT, 3 for RIGHT and 0 for NONE.
 * @author Miguel Sánchez de León Peque <msdeleonpeque@gmail.com>
 * @date 2011/03/22
 */
int get_config(uint8_t interrupt)
{
	unsigned long time = millis();
	for (uint8_t i = 1; i < 4; i++) {
		// Check de appropiate distance
		if (abs((int) get_distance(13 + i) - CONFIG_DIST) < CONFIG_PREC) {
			// Check continuous reading
			while (abs((int) get_distance(13 + i) - CONFIG_DIST) < CONFIG_PREC) {
				if (((millis() - time)/50) % 2 == 0) set_rgb(i==2 ? 255 : 0, i==1 ? 255 : 0, i==3 ? 255 : 0);
				else set_rgb(0, 0, 0);
				// Confirm and return value after 3 seconds
				if (millis() - time > 3000) {
					if (!interrupt) while (abs((int) get_distance(13 + i) - CONFIG_DIST) < CONFIG_PREC) set_rgb(i==2 ? 255 : 0, i==1 ? 255 : 0, i==3 ? 255 : 0);
					return i;
				}
			}
		}
	}
	// Failed to confirm configuration settings
	return 0;
}

/**
 * @brief Returns distance from sensor to the reflective object in mm.
 *
 * The get_distance(uint8_t sensor) function calculates de distance
 * from the specified sensor to the reflective object and returns this
 * value in cm. The distance is calculated this way:
 * @f[
 * distance = 270/(5.0/1023*Vs)
 * @f]
 * Where Vs is the sensor's analog input reading (0V -> 0, 5V -> 1023)
 * and 270 is the constant scale factor (V*mm).
 *
 * @param[in] sensor Name of the sensor's analog input.
 * @return Linearized output of the distance from sensor to the reflective object in mm.
 * @author Miguel Sánchez de León Peque <msdeleonpeque@gmail.com>
 * @date 2011/03/15
 */
float get_distance(uint8_t sensor)
{
    uint8_t i;
    float Vsm = 0; // Average sensor's input voltage
    for (i = 0; i < SHARP_AREAD_N; i++) {
        Vsm += analogRead(sensor);
        delay(SHARP_AREAD_DELAY);
    }
    Vsm /= SHARP_AREAD_N;
    /*
    * In its simplest form, the linearizing equation can be that the
    * distance to the reflective object is approximately equal to a
    * constant scale factor (~270 V*mm) divided by the sensor’s output
    * voltage:
    */
    return 270/(5.0/1023*Vsm); // TODO: Linearize the output dividing the curve in 3-4 pieces (not very important though...)
}

/**
 * @brief Initializes Qik2s9v1 serial motor controller.
 *
 * The init_qik() function initializes the Qik2s9v1 serial motor
 * controller, reseting the device and sending the initial packet byte
 * to start the comunication.
 *
 * @author Miguel Sánchez de León Peque <msdeleonpeque@gmail.com>
 * @date 2011/02/24
 */
void init_qik()
{
	digitalWrite(qik_rstPin, LOW);
	delay(100);
	digitalWrite(qik_rstPin, HIGH);
	delay(10);

	Serial.print(INITIALPACKET, BYTE);

	delay(100);
}

/**
 * @brief Move forward between two side walls.
 *
 * The move_forward() function is used when there's no chance to turn
 * for the robot: it will move straight between the two side walls.
 *
 * @author Miguel Sánchez de León Peque <msdeleonpeque@gmail.com>
 * @date 2011/04/01
 */
void move_forward()
{
	float correction;
	correction = pid_both();

	// Fix corrections out of range
	correction = (correction > 127) ? 127 : (correction < -127) ? -127 : correction;

	set_speed(LEFT, 127 - ((correction < 0) ? 0 : abs(correction)));
	set_speed(RIGHT, 127 - ((correction < 0) ? abs(correction) : 0));

	if (dist_front < 150) turn_back();
	JUST_TURNED = 0;
}

void move_through(position wall_pos, float distance)
{
	float correction;

	set_pos();

	correction = pid_single(wall_pos, distance);

	// Fix corrections out of range
	correction = (correction > 127) ? 127 : (correction < -127) ? -127 : correction;

	set_speed(LEFT, 127 - ((correction < 0) ? 0 : abs(correction)));
	set_speed(RIGHT, 127 - ((correction < 0) ? abs(correction) : 0));
}

/**
 * @brief Returns PID output
 *
 * The pid_both() function performs a proportional, integral and
 * derivative controller:
 * @f[
 * output = Kp*err + Ki*integral + Kd*derivative
 * @f]
 * For now, we have not implemented the integral and derivative control
 * (Ki = Kd = 0).
 *
 * @return PID output
 * @author Miguel Sánchez de León Peque <msdeleonpeque@gmail.com>
 * @date 2011/03/20
 */
float pid_both()
{
	float err, integral, derivative, output;
	unsigned long dt, time;

	time = millis();

	dt = time - prev_time;

	err = dist_left - dist_right;
	integral += err*dt;
	derivative = (err - prev_err)/dt;

	output = Kp*err + Ki*integral + Kd*derivative;
	prev_time = time;
	prev_err = err;

	return output;
}

float pid_single(position wall_pos, float distance)
{
	float err, integral, derivative, output;
	unsigned long dt, time;

	time = millis();

	dt = time - prev_time;

	if (wall_pos == LEFT) err = dist_left - distance;
	else err = dist_right - distance;
	integral += err*dt;
	derivative = (err - prev_err)/dt;

	output = Kp*err + Ki*integral + Kd*derivative;
	prev_time = time;
	prev_err = err;

	return output;
}

/**
 * @brief Set instant position.
 *
 * The set_pos() function reads all the position sensors.
 *
 * @author Miguel Sánchez de León Peque <msdeleonpeque@gmail.com>
 * @date 2011/02/24
 */
void set_pos()
{
	// Set instant position
	dist_left = get_distance(SHARP_LEFT);
	dist_right = get_distance(SHARP_RIGHT);
	dist_front = get_distance(SHARP_FRONT);
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

/**
 * @brief Set motors' speed.
 *
 * The set_speed(position motor, int speed) function sets the speed of
 * the right (RIGHT), left (LEFT) or both motors (FRONT).
 *
 * @param[in] motor Motor position (left, right or both).
 * @param[in] speed Value for speed.
 * @author Miguel Sánchez de León Peque <msdeleonpeque@gmail.com>
 * @date 2011/04/01
 */
void set_speed(position motor_position, int speed_fr)
{
	uint8_t speed, FORWARD;

	// Fix incorrect values for speed
	speed_fr = (speed_fr > 127) ? 127 : (speed_fr < -127) ? -127 : speed_fr;

	FORWARD = (speed_fr < 0) ? 0 : 1;
	speed = abs(speed_fr);

	switch (motor_position) {
		case FRONT :
			if (FORWARD) {
				// Motor 0 forward at speed
				Serial.print(MOTOR0FORWARDPACKET, BYTE);
				Serial.print(speed, BYTE);
				// Motor 1 forward at speed
				Serial.print(MOTOR1FORWARDPACKET, BYTE);
				Serial.print(speed, BYTE);
			} else {
				// Motor 0 reverse at speed
				Serial.print(MOTOR0REVERSEPACKET, BYTE);
				Serial.print(speed, BYTE);
				// Motor 1 reverse at speed
				Serial.print(MOTOR1REVERSEPACKET, BYTE);
				Serial.print(speed, BYTE);
			}
			break;
		case LEFT :
			if (FORWARD) {
				// Motor 0 forward at speed
				Serial.print(MOTOR0FORWARDPACKET, BYTE);
				Serial.print(speed, BYTE);
			} else {
				// Motor 1 reverse at speed
				Serial.print(MOTOR0REVERSEPACKET, BYTE);
				Serial.print(speed, BYTE);
			}
			break;
		case RIGHT :
			if (FORWARD) {
				// Motor 1 forward at speed
				Serial.print(MOTOR1FORWARDPACKET, BYTE);
				Serial.print(speed, BYTE);
			} else {
				// Motor 1 reverse at speed
				Serial.print(MOTOR1REVERSEPACKET, BYTE);
				Serial.print(speed, BYTE);
			}
			break;
		default :
			// Stop both motors
			Serial.print(MOTOR0FORWARDPACKET, BYTE);
			Serial.print(0, BYTE);
			Serial.print(MOTOR1FORWARDPACKET, BYTE);
			Serial.print(0, BYTE);
			break;
	}
}

/**
 * @brief Tells the robot to turn back.
 *
 * The robot will turn back and wait for a brief period of time to
 * continue moving around. This function is supposed to be used only
 * while mapping the maze (the first time).
 *
 * @author Miguel Sánchez de León Peque <msdeleonpeque@gmail.com>
 * @date 2011/03/22
 */
void turn_back()
{
	set_speed(LEFT, 127);
	set_speed(RIGHT, -127);
	delay(PI*DIAMETER/(2*v_max));
	set_speed(FRONT, 0);
	delay(100);
}

/**
 * @brief Check if the robot must turn left or must turn right.
 *
 * The way_simple() function can check if the robot must turn left or
 * must turn right (that means there's a bend but not a node) and
 * returns TRUE or FALSE depending on that.
 *
 * @return TRUE or FALSE if the robot must turn right or must turn left.
 * @author Miguel Sánchez de León Peque <msdeleonpeque@gmail.com>
 * @date 2011/04/01
 */
int way_simple()
{
	set_speed(FRONT, 127);
	if (!JUST_TURNED) delay(TIME_TO_RECHECK);

	set_pos();

	if (dist_front < MAX_DIST_FRONT) {
		if (dist_right < MAX_DIST_SIDE || dist_left < MAX_DIST_SIDE)
			return 1;
	} else if (dist_right < MAX_DIST_SIDE && dist_left < MAX_DIST_FRONT) {
			return 1;
	} else return 0;
}

/**
 * @brief Check for any chances to turn.
 *
 * The way_straight() function can check if the robot is between two
 * side walls (there's no chance to turn) and returns TRUE or FALSE
 * depending on that.
 *
 * @return TRUE or FALSE if it is or it is not a straight way (can't turn).
 * @author Miguel Sánchez de León Peque <msdeleonpeque@gmail.com>
 * @date 2011/04/01
 */
int way_straight()
{
	set_pos();
	if (dist_left < MAX_DIST_SIDE && dist_right < MAX_DIST_SIDE) return 1;
	else return 0;
}
