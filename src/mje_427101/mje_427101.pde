

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

// SHARP sensors:
#define SHARP_FRONT A0         // Front sensor in A0
#define SHARP_RIGHT A1         // Right sensor in A1
#define SHARP_LEFT A2          // Left sensor in A2
#define SHARP_AREAD_N 10       // Repeat SHARP analogRead N times
#define SHARP_AREAD_DELAY 0    // Delay between readings (ms)

// RGB LED
#define LED_RED 9
#define LED_GREEN 10
#define LED_BLUE 11


NewSoftSerial motorSerial =  NewSoftSerial(rxPin, txPin);
CompactQik2s9v1 motor = CompactQik2s9v1(&motorSerial,rstPin);


void setup()  
{
	// Serial setup:
	Serial.begin(9600);
	motorSerial.begin(9600);

	// Motor setup:
	motor.begin();
	motor.stopBothMotors();

	// LED setup:
	pinMode(LED_RED, OUTPUT);
	pinMode(LED_GREEN, OUTPUT);
	pinMode(LED_BLUE, OUTPUT);
}



void loop() 
{
/* */
	
/* */
	float signal;
	signal = get_distance(SHARP_FRONT);
	Serial.println(signal);
	delay(100);
/* *
	motor.motor0Forward(125);
	motor.motor1Forward(125);
	delay(4000);
	motor.motor0Coast();        // Lets the motor turn freely
	motor.motor1Coast();        // Lets the motor turn freely
	delay(2000);
	motor.motor0Reverse(125);
	motor.motor1Reverse(125);
	delay(4000);
* */
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
    return 270/(5.0/1023*Vsm); // TODO: Linearize the output dividing the curve in 3-4 pieces
}

/**
 * @brief Set RGB LED's colors.
 *
 * The set_rgb(int red, int green, int blue) function is used to change
 * the brightness of the RGB LED's colors.
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
