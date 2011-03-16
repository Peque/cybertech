
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
#define SHARP_AREAD_N 10.0     // Repeat SHARP analogRead N times
#define SHARP_AREAD_DELAY 0.0  // Delay between readings (ms)



NewSoftSerial mySerial =  NewSoftSerial(rxPin, txPin);
CompactQik2s9v1 motor = CompactQik2s9v1(&mySerial,rstPin);

byte motorSelection;
byte motorSpeed;

void setup()  
{
    Serial.begin(9600);
    mySerial.begin(9600);
    motor.begin();
    motor.stopBothMotors();
}



void loop() 
{
    float signal;
    signal = get_distance(SHARP_FRONT);
    Serial.println(signal);
    delay(100);
 /*
    motorSelection = Serial.read();
    motor.motor0Forward(125);
    motor.motor1Forward(125);
    delay(4000);
    motor.motor0Coast();     
    motor.motor1Coast();
    delay(2000);
    motor.motor0Reverse(125);
    motor.motor1Reverse(125);
    delay(4000);
  */
}

/**
 * @brief Returns sensor's distance in cm.
 *
 * The get_distance(uint8_t sensor) function calculates de distance
 * from the specified sensor to the reflective object and returns this
 * value in cm. The distance is calculated this way:
 * @f[
 * distance = 27/(5.0/1024*Vs)
 * @f]
 * Where Vs is the sensor's analog input reading and 27 is the constant
 * scale factor (V*cm).
 *
 * @param[in] sensor Name of the sensor's analog input.
 * @return Linearized output of the distance from sensor to the reflective object in cm.
 * @author Miguel Sánchez de León Peque <msdeleonpeque@gmail.com>
 * @date 2011/03/15
 */
float get_distance(uint8_t sensor)
{
    byte i;
    float Vsm = 0; // Average sensor's input voltage
    for (i = 0; i < SHARP_AREAD_N; i++) {
        Vsm += analogRead(sensor);
        delay(SHARP_AREAD_DELAY);
    }
    Vsm /= SHARP_AREAD_N;
    /*
    * In its simplest form, the linearizing equation can be that the
    * distance to the reflective object is approximately equal to a
    * constant scale factor (~27 V*cm) divided by the sensor’s output
    * voltage:
    */
    return 27/(5.0/1024*Vsm); // TODO: Linearize the output dividing the curve in 3-4 pieces
}
