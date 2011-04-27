
// Sensor definitions
#define SENSOR_N 5
#define IR_0 15
#define IR_1 16
#define IR_2 17
#define IR_3 18
#define IR_4 19
#define IR_K0 1
#define IR_K1 3
#define IR_K2 4
#define IR_K3 5
#define IR_K4 7
#define MIDDLE_LINE ((IR_K4 + IR_K0)/2)
#define MIN_READ_VALUE 300
#define MAX_READ_VALUE 300
#define SHARP_SENSOR 14
#define SHARP_AREAD_N 50

// Motor definitions
#define MOTOR_MAX_SPEED 127	       // Max motor speed (absolute value)
#define MOTOR_BREAK_SPEED 0       // Break one wheel to find the path again
#define Kp 50.
#define Kd 15000.
#define Ki 0.0005

// Bend 90º
#define TIME_TO_TURN 100

// Change lane
#define TIME_TO_CHANGE 60
#define TIME_TO_LEAVE_LANE 200
#define TIME_TO_FIND_NEW_PATH 200
#define INITIAL_LANE_PIN 8         // Set this to high if LEFT_LANE
#define DISTANCE_TO_CHANGE 350     // Distance from the robot to the object in mm
int LEFT_LANE;

// Software serial:
/*
 * Important:
 *     The qik_rxPin goes to the Qik's "TX" pin
 *     The qik_txPin goes to the Qik's "RX" pin
 */
#define qik_rxPin 0
#define qik_txPin 1
#define qik_rstPin 2

// Bytes used to talk to the motor controller Qik2s9v1
#define INITIALPACKET 0xAA
#define MOTOR0FORWARDPACKET 0x88
#define MOTOR0FORWARDFASTPACKET 0x89
#define MOTOR0REVERSEPACKET 0x8A
#define MOTOR0REVERSEFASTPACKET 0x8B
#define MOTOR1FORWARDPACKET 0x8C
#define MOTOR1FORWARDFASTPACKET 0x8D
#define MOTOR1REVERSEPACKET 0x8E
#define MOTOR1REVERSEFASTPACKET 0x8F
#define MOTOR0COASTPACKET 0x86
#define MOTOR1COASTPACKET 0x87
#define FWVERSIONPACKET 0x81
#define ERRORPACKET 0x82
#define GETCONFIG 0x83
#define SETCONFIG 0x84

// RGB LED
#define LED_RED 9
#define LED_GREEN 10
#define LED_BLUE 11

// Global variables
int IR[SENSOR_N];
uint8_t IR_pins[SENSOR_N], IR_factors[SENSOR_N];
float line_position;
float vm_left, vm_right;
float error;
uint8_t TURN_LEFT = 0;

// PID variables
float err, prev_err, integral, derivative;
unsigned long dt, time, prev_time;
float correction;


void setup()
{
	// Serial setup:
	Serial.begin(9600);

	// Initialize pins
	pinMode(INITIAL_LANE_PIN, INPUT);
	IR_pins = { IR_0, IR_1, IR_2, IR_3, IR_4 };
	IR_factors = { IR_K0, IR_K1, IR_K2, IR_K3, IR_K4 };

	// Initialize motors
	init_qik();
	set_speed_left(0);
	set_speed_right(0);

	// Initialize lane
	if (digitalRead(INITIAL_LANE_PIN) == HIGH) LEFT_LANE = 1;
	else LEFT_LANE = 0;
}

void loop()
{
	asign();
	line_position = set_line_pos();
	correction = pid_output();
	if (line_position) {
		speed_regulation();
	} else {
		find_path();
	}
	change_lane();
//	debug_serial();
//	set_distance();
//	speed_regulation();
}

void asign()
{
	for (int i=0; i<SENSOR_N; i++) {
		IR[i] = analogRead(IR_pins[i]);
		if (i == 0 && IR[0] > MIN_READ_VALUE) TURN_LEFT = 1;
		if (i == SENSOR_N - 1 && IR[SENSOR_N - 1] > MIN_READ_VALUE) TURN_LEFT = 0;
	}
}

void set_speed_left(int speed_fr)
{
	uint8_t speed, FORWARD;

	// Fix incorrect values for speed
	speed_fr = (speed_fr > MOTOR_MAX_SPEED) ? MOTOR_MAX_SPEED : (speed_fr < -MOTOR_MAX_SPEED) ? -MOTOR_MAX_SPEED : speed_fr;

	FORWARD = (speed_fr < 0) ? 0 : 1;
	speed = abs(speed_fr);

	if (FORWARD) {
		// Motor 0 forward at speed
		Serial.print(MOTOR0FORWARDPACKET, BYTE);
		Serial.print(speed, BYTE);
	} else {
		// Motor 1 reverse at speed
		Serial.print(MOTOR0REVERSEPACKET, BYTE);
		Serial.print(speed, BYTE);
	}
}

void set_speed_right(int speed_fr)
{
	int speed, FORWARD;

	// Fix incorrect values for speed
	speed_fr = (speed_fr > MOTOR_MAX_SPEED) ? MOTOR_MAX_SPEED : (speed_fr < -MOTOR_MAX_SPEED) ? -MOTOR_MAX_SPEED : speed_fr;

	FORWARD = (speed_fr < 0) ? 0 : 1;
	speed = abs(speed_fr);

	if (FORWARD) {
		// Motor 1 forward at speed
		Serial.print(MOTOR1FORWARDPACKET, BYTE);
		Serial.print(speed, BYTE);
	} else {
		// Motor 1 reverse at speed
		Serial.print(MOTOR1REVERSEPACKET, BYTE);
		Serial.print(speed, BYTE);
	}
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

void debug_serial()
{
	for (int i=0; i<SENSOR_N; i++) {
		Serial.print(IR[i]);
		Serial.print("	");
	}
	Serial.println(get_distance());
	Serial.println(" ");
}

float set_line_pos()
{
	float aux=0, cont=0;
	for (int i=0; i<SENSOR_N; i++) {
		if (IR[i] > MAX_READ_VALUE) {
			aux += IR_factors[i];
			cont += 1;
		}
	}
	return cont ? aux/cont : 0;
}

float pid_output()
{
	float output;

	time = millis();

	dt = time - prev_time;

	err = line_position - MIDDLE_LINE;
	integral += err*dt;
	derivative = (err - prev_err)/dt;

	output = Kp*err + Ki*integral + Kd*derivative;

	prev_time = time;
	prev_err = err;

	return output;
}

void speed_regulation()
{
	if (correction < 0) { // Turn left
		set_speed_left(MOTOR_MAX_SPEED + correction);
		set_speed_right(MOTOR_MAX_SPEED);
	} else { // Turn right
		set_speed_right(MOTOR_MAX_SPEED - correction);
		set_speed_left(MOTOR_MAX_SPEED);
	}
}

void find_path()
{
	unsigned long time = millis();
	if (TURN_LEFT) {
		set_speed_right(MOTOR_MAX_SPEED);
		set_speed_left(-MOTOR_MAX_SPEED);
		while ((millis() - time < TIME_TO_TURN) && (no_line_found()));

	} else {
		set_speed_left(MOTOR_MAX_SPEED);
		set_speed_right(-MOTOR_MAX_SPEED);
		while ((millis() - time < TIME_TO_TURN) && (no_line_found()));
	}
	if (no_line_found()) {
		set_speed_left(MOTOR_MAX_SPEED);
		set_speed_right(MOTOR_MAX_SPEED);
		while (no_line_found());
	}
	integral = 0;
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
float get_distance()
{
    uint8_t i;
    float Vsm = 0; // Average sensor's input voltage
    for (i = 0; i < SHARP_AREAD_N; i++) {
        Vsm += analogRead(SHARP_SENSOR);
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

void change_lane()
{
	if (get_distance() < DISTANCE_TO_CHANGE) {
		if (LEFT_LANE) change_to_right();
		else change_to_left();
	}
}

void change_to_right()
{
	set_speed_left(MOTOR_MAX_SPEED);
	set_speed_right(-MOTOR_MAX_SPEED);
	delay(TIME_TO_CHANGE);
	set_speed_right(MOTOR_MAX_SPEED/2);
	set_speed_left(MOTOR_MAX_SPEED/2);
	delay(TIME_TO_LEAVE_LANE);
	while (no_line_found());
	set_speed_right(MOTOR_MAX_SPEED);
	set_speed_left(-MOTOR_MAX_SPEED);
	delay(TIME_TO_FIND_NEW_PATH);
	LEFT_LANE = 0;
}

void change_to_left()
{
	set_speed_right(MOTOR_MAX_SPEED);
	set_speed_left(-MOTOR_MAX_SPEED);
	delay(TIME_TO_CHANGE);
	set_speed_left(MOTOR_MAX_SPEED/2);
	set_speed_right(MOTOR_MAX_SPEED/2);
	delay(TIME_TO_LEAVE_LANE);
	while (no_line_found());
	set_speed_left(MOTOR_MAX_SPEED);
	set_speed_right(-MOTOR_MAX_SPEED);
	delay(TIME_TO_FIND_NEW_PATH);
	LEFT_LANE = 1;
}

int no_line_found()
{
	for (int i=0; i<SENSOR_N; i++) if (analogRead(IR_pins[i]) > MIN_READ_VALUE) return 0;
	return 1;
}
