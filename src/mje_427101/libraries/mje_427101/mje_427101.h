/*
 *    mje_427101.h
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


#ifndef mje_427101_h
#define mje_427101_h

#include "WProgram.h"
#include "WConstants.h"


// Software serial:
/*
 * Important:
 *     The qik_rxPin goes to the Qik's "TX" pin
 *     The qik_txPin goes to the Qik's "RX" pin
 */
#define qik_rxPin 0
#define qik_txPin 1
#define qik_rstPin 2

// Time constants
#define TIME_TO_PASSTHROUGH 900 // TODO: this should depend on speed...  LANE_WIDTH/v_max
#define TIME_TO_RECHECK 180 // TODO: this should depend on speed...  FORESEE/v_max

// SHARP sensors
#define SHARP_FRONT 14				 // Front sensor in A0
#define SHARP_LEFT 15				 // Left sensor in A1
#define SHARP_RIGHT 16				 // Right sensor in A2
#define SHARP_AREAD_N 10			 // Repeat SHARP analogRead N times
#define SHARP_AREAD_DELAY 0			 // Delay between readings (ms)
#define MAX_DIST_SIDE 500			 // Max. distance considering a side wall
#define MAX_DIST_FRONT 600			 // Min. distance considering a front wall
// #define NOM_DIST_SIDE 275			 // Nominal distance to a side wall
#define NEW_WALL_CONTACT_DIST 375	 // Distance at which a new wall should appear when exiting a node

// PID
#define Kp 0.5
#define Ki 0.0
#define Kd 0.0

// Configuration
#define LANE_WIDTH 500.0    // Distance between walls in the maze
#define DIAMETER 112.0      // Distance between wheels
#define FORESEE 100.0       // Front reading distance for side sensors (from reflective object, supposed centered, to the wheels)
#define PI 3.141592654      // [...]
#define CONFIG_DIST 150     // Distance for sensors' reading in mm
#define CONFIG_PREC 40      // Sets the sensors' reading distance precision in mm (+/-)

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
