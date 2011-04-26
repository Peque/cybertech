
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
#define MIN_READ_VALUE 40
#define MAX_READ_VALUE 100

// Motor definitions
#define MOTOR_LEFT_SPEED_PIN 11
#define MOTOR_LEFT_DIR_PIN 9
#define MOTOR_RIGHT_SPEED_PIN 10
#define MOTOR_RIGHT_DIR_PIN 8
#define MOTOR_MAX_SPEED 60        // Max motor speed (absolute value)
#define INC 10

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


void setup()
{
	// Serial setup:
	Serial.begin(9600);

	// Initialize pins
	pinMode(MOTOR_LEFT_SPEED_PIN, OUTPUT);
	pinMode(MOTOR_LEFT_DIR_PIN, OUTPUT);
	pinMode(MOTOR_RIGHT_SPEED_PIN, OUTPUT);
	pinMode(MOTOR_RIGHT_DIR_PIN, OUTPUT);
	IR_pins = { IR_0, IR_1, IR_2, IR_3, IR_4 };
	IR_factors = { IR_K0, IR_K1, IR_K2, IR_K3, IR_K4 };

	// Initialize motors
	init_qik();
	set_speed_left(0);
	set_speed_right(0);
}

void loop()
{
	asign();
	line_position = set_line_pos();
	if (line_position) {
		error = line_position - MIDDLE_LINE;
		speed_regulation();
	} else {
		find_path();
	}
//	debug_serial();
//	set_distance();
//	speed_regulation();
}

void asign()
{
	for (int i=0; i<SENSOR_N; i++) {
		IR[i] = analogRead(IR_pins[i]);
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
	uint8_t speed, FORWARD;

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

void speed_regulation()
{
	if (error < 0) { // Turn right
		if (vm_right < MOTOR_MAX_SPEED) vm_right += INC*abs(error);
		else vm_left -= INC*abs(error);
	} else if (error > 0) { // Turn left
		if (vm_left < MOTOR_MAX_SPEED) vm_left += INC*abs(error);
		else vm_right -= INC*abs(error);
	} else {
		if (vm_left < MOTOR_MAX_SPEED) vm_left += INC*abs(error);
		if (vm_right < MOTOR_MAX_SPEED) vm_right += INC*abs(error);
	}
	// Correct values out of range
	vm_left = (vm_left > MOTOR_MAX_SPEED) ? MOTOR_MAX_SPEED : (vm_left < 0) ? 0 : vm_left;
	vm_right = (vm_right > MOTOR_MAX_SPEED) ? MOTOR_MAX_SPEED : (vm_right < 0) ? 0 : vm_right;
	set_speed_left( (int) vm_left);
	set_speed_right( (int )vm_right);
}

void find_path()
{
}
