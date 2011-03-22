

#include <CompactQik2s9v1.h>
#include <NewSoftSerial.h>


// Software serial:
/*
 * Important:
 *     The rxPin goes to the Qik's "TX" pin
 *     The txPin goes to the Qik's "RX" pin
 */
#define txPin 2
#define rxPin 3
#define rstPin 4

// SHARP sensors
#define SHARP_FRONT 14         // Front sensor in A0
#define SHARP_LEFT 15          // Left sensor in A1
#define SHARP_RIGHT 16         // Right sensor in A2
#define SHARP_AREAD_N 10       // Repeat SHARP analogRead N times
#define SHARP_AREAD_DELAY 0    // Delay between readings (ms)

// PID
#define Kp 0.1
#define Ki 0
#define Kd 0
unsigned long prev_time;
float prev_err;

// Instant position variables
float dist_left, dist_right, dist_front;

// Configuration
int choose_left = 1; // Left by default

// RGB LED
#define LED_RED 9
#define LED_GREEN 10
#define LED_BLUE 11


NewSoftSerial motorSerial =  NewSoftSerial(rxPin, txPin);
CompactQik2s9v1 motor = CompactQik2s9v1(&motorSerial,rstPin);

void setup()  
{
	// Serial setup
	Serial.begin(9600);
	motorSerial.begin(9600);

	// Motor setup
	motor.begin();
	motor.stopBothMotors();

	// LED setup
	pinMode(LED_RED, OUTPUT);
	pinMode(LED_GREEN, OUTPUT);
	pinMode(LED_BLUE, OUTPUT);

	// Initialization
	initialization();
}

void loop() 
{
/* */

	float output;

	// Set instant position
	dist_left = get_distance(SHARP_LEFT);
	dist_right = get_distance(SHARP_RIGHT);
	dist_front = get_distance(SHARP_FRONT);

	output = pid_output();
	
	if (output > 127) output = 127;
	if (output < -127) output = -127;

	if (get_distance(SHARP_FRONT) > 200) {
		if (output > 0) {
			motor.motor0Forward(127-abs(output));
			motor.motor1Forward(127);
			set_rgb(0, 2*abs(output), 0);
		} else {
			motor.motor0Forward(127);
			motor.motor1Forward(127-abs(output));
			set_rgb(0, 0, 2*abs(output));
		}
	} else {
		motor.motor0Coast();        // Lets the motor turn freely (TODO: avoid this for being weight dependent)
		motor.motor1Coast();        // Lets the motor turn freely (TODO: avoid this for being weight dependent)
		set_rgb(255, 0, 0);
		turn_back();
		if (get_distance(SHARP_FRONT) < 200) delay(5000);
	}
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
 * @brief Returns PID output
 *
 * The pid_output() function performs a proportional, integral and
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
float pid_output()
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
	motor.motor0Forward(125);
	motor.motor1Reverse(125);
	delay(250); /* TODO: this delay should depend on the motors' speed and/or weight.
	             *       We should create a variable to set in the initialization()
	             *       function. IE: two turnnings and divide the time by 4 (all
	             *       around should be free space except for a thin object static
	             *       in the front of the robot).
	             * */
	motor.motor0Coast();        // Lets the motor turn freely (TODO: avoid this for being weight dependent)
	motor.motor1Coast();        // Lets the motor turn freely (TODO: avoid this for being weight dependent)
	delay(300);
}

void initialization()
{
	unsigned long time = millis();
	int conf;
	do {
		conf = get_config();
		if (((millis() - time)/500) % 2 == 0) set_rgb(255, 0, 0);
		else set_rgb(0, 0, 255);
	} while (conf < 2);
	if (conf == 2) choose_left = 1;
	else choose_left = 0;
	while (get_config() != 1) {
		if (choose_left) set_rgb(255, 0, 0);
		else set_rgb(0, 0, 255);
	}
	set_rgb(0, 255, 0);
	delay(2000);
	
}

/**
 * @brief Gets configuration parameters from one of the sensors.
 *
 * The get_config() function reads from all sensors until it gets an
 * appropiate response. That means it must read a value at the correct
 * distance and for a few seconds without interruptions.
 *
 * While the sensor is reading, the LED will blink fast with green, red
 * or blue color depending on the selected sensor (front, left or blue
 * respectively). After the reading is confirmed, the LED will stop
 * blinking.
 *
 * @return Sensor which has confirmed the reading: 1 for FRONT, 2 for LEFT, 3 for RIGHT and 0 for NONE.
 * @author Miguel Sánchez de León Peque <msdeleonpeque@gmail.com>
 * @date 2011/03/22
 */
int get_config()
{
	unsigned long time = millis();
	for (uint8_t i = 1; i < 4; i++) {
		// Check de appropiate distance
		if (abs((int) get_distance(13 + i) - 150) < 30) {
			// Check continuous reading
			while (abs((int) get_distance(13 + i) - 150) < 30) {
				if (((millis() - time)/50) % 2 == 0) set_rgb(i==2 ? 255 : 0, i==1 ? 255 : 0, i==3 ? 255 : 0);
				else set_rgb(0, 0, 0);
				// Confirm and return value after 3 seconds
				if (millis() - time > 3000) {
					while (abs((int) get_distance(13 + i) - 150) < 30) set_rgb(i==2 ? 255 : 0, i==1 ? 255 : 0, i==3 ? 255 : 0);
					return i;
				}
			}
		}
	}
	// Failed to confirm configuration settings
	return 0;
}

// TODO: implement this function
int simple_way()
{
	return 0;
}

// TODO: implement this function
int move_forward()
{
	return 0;
}

// TODO: implement this function
int solve_node()
{
	return 0;
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
