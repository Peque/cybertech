
#ifndef mje_427101_h
#define mje_427101_h

#include "WConstants.h"


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
#define MAX_DIST_SIDE 500      // Max. distance considering a side wall
#define MAX_DIST_FRONT 600     // Min. distance considering a front wall

// PID
#define Kp 0.8
#define Ki 0.0
#define Kd 0.0

// Configuration
#define LANE_WIDTH 500.0    // Distance between walls in the maze
#define DIAMETER 112.0      // Distance between wheels
#define FORESEE 100.0       // Front reading distance for side sensors (from reflective object, supposed centered, to the wheels)
#define PI 3.141592654      // [...]
#define CONFIG_DIST 150     // Distance for sensors' reading in mm
#define CONFIG_PREC 40      // Sets the sensors' reading distance precision in mm (+/-)

// Type for positions
typedef enum position { FRONT, LEFT, RIGHT };

// RGB LED
#define LED_RED 9
#define LED_GREEN 10
#define LED_BLUE 11


class mje_427101
{
	public:

	private:

};


#endif
