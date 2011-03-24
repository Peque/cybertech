

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
#define SHARP_AREAD_N 5        // Repeat SHARP analogRead N times
#define SHARP_AREAD_DELAY 0    // Delay between readings (ms)
#define MAX_DIST_SIDE 400      // Max. distance considering a side wall
#define MAX_DIST_FRONT 500     // Min. distance considering a front wall

// PID
#define Kp 0.5
#define Ki 0.0
#define Kd 0.0
unsigned long prev_time;     // Previous time
float prev_err;              // Previous error
float correction;            // PID's output

// Instant position variables
float dist_left, dist_right, dist_front;

// Configuration
#define LANE_WIDTH 500.0    // Distance between walls in the maze
#define DIAMETER 112.0      // Distance between wheels
#define FORESEE 100.0       // Front reading distance for side sensors (from reflective object, supposed centered, to the wheels)
#define PI 3.141592654      // [...]
#define CONFIG_DIST 150     // Distance for sensors' reading in mm
#define CONFIG_PREC 40      // Sets the sensors' reading distance precision in mm (+/-)
float v_max = 0.7;          // Max speed in m/s
int choose_left = 1;        // Left by default
int initialized = 0;        // Boolean variable to know if the robot is already initialized
int just_turned = 0;

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
	// Set instant position
	dist_left = get_distance(SHARP_LEFT);
	dist_right = get_distance(SHARP_RIGHT);
	dist_front = get_distance(SHARP_FRONT);

	if (simple_way()) move_forward();
	else solve_node();
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
	motor.motor0Forward(127);
	motor.motor1Reverse(127);
	delay(PI*DIAMETER/(2*v_max));
	motor.motor0Forward(0);
	motor.motor1Reverse(0);
	delay(300);
}

void turn_right()   // TODO: merge turn_right() and turn_left() into one simple function
{
	if (!just_turned) delay(FORESEE/v_max);
	motor.motor1Forward(80); // TODO: speed dependent... 127*(LANE_WIDTH-DIAMETER)/(LANE_WIDTH+DIAMETER) (?)
	motor.motor0Forward(127);
	delay(700); // TODO: speed dependent... (PI/2*(LANE_WIDTH/2+DIAMETER/2))/v_max (?)
	just_turned = 1;
	// debug_pause(3000);
}

void turn_left()
{
	if (!just_turned) delay((FORESEE-100)/v_max);
	motor.motor1Forward(127);
	motor.motor0Forward(80); // TODO: speed dependent... 127*(LANE_WIDTH-DIAMETER)/(LANE_WIDTH+DIAMETER) (?)
	delay(700); // TODO: speed dependent... (PI/2*(LANE_WIDTH/2+DIAMETER/2))/v_max (?)
	just_turned = 1;
	// debug_pause(3000);
}

void initialization()
{
	unsigned long time = millis();
	int conf;
	do {
		conf = get_config(0);
		if (((millis() - time)/500) % 2 == 0) set_rgb(255, 0, 0);
		else set_rgb(0, 0, 255);
	} while (conf < 2);
	if (conf == 2) choose_left = 1;
	else choose_left = 0;
	while (get_config(1) != 1) {
		if (choose_left) set_rgb(255, 0, 0);
		else set_rgb(0, 0, 255);
	}
	
	time = millis();
	motor.motor1Forward(127);
	motor.motor0Reverse(127);
	delay(100);
	while (abs((int) get_distance(SHARP_FRONT) - CONFIG_DIST) > CONFIG_PREC + 20);
	delay(100);
	while (abs((int) get_distance(SHARP_FRONT) - CONFIG_DIST) > CONFIG_PREC + 20);
	v_max = 2*PI*DIAMETER/(millis()-time);
	motor.motor1Forward(0);
	motor.motor0Reverse(0);

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

	initialized = 1;
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

int simple_way()
{
	return 1;
	/*
	if ((dist_left < MAX_DIST_SIDE && dist_right < MAX_DIST_SIDE) || \
	(dist_front < MAX_DIST_FRONT && (dist_left < MAX_DIST_SIDE || dist_right < MAX_DIST_SIDE))) {
		// set_rgb(0, 255, 0);
		return 1;
	} else {
		// set_rgb(255, 0, 0);
		return 0;
	}*/
}

void move_forward()
{
	if (dist_left < MAX_DIST_SIDE && dist_right < MAX_DIST_SIDE) {
		set_rgb(0, 255, 0);
		correction = pid_output();
		// Fix corrections out of range
		if (correction > 127) correction = 127;
		if (correction < -127) correction = -127;

		if (correction > 0) {
			motor.motor0Forward(127-abs(correction));
			motor.motor1Forward(127);
		} else {
			motor.motor0Forward(127);
			motor.motor1Forward(127-abs(correction));
		}
		if (dist_front < 300) {
			set_rgb(0, 0, 0);
			turn_back();
		}
		just_turned = 0;
	} else if (dist_left > MAX_DIST_SIDE) {
		set_rgb(255, 0, 0);
		turn_left();
	} else if (dist_right > MAX_DIST_SIDE) {
		set_rgb(0, 0, 255);
		turn_right();
	}
}

// TODO: implement this function
void solve_node()
{
	// For now, just abort:
	abort();
}

void debug_pause(int ms)
{
	motor.motor0Forward(0);
	motor.motor1Forward(0);
	set_rgb(0, 0, 0);
	delay(ms);
}

void debug_abort()
{
	debug_pause(0);
	while (1);
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
