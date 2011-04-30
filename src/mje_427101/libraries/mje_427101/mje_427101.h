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
#define TIME_TO_PASSTHROUGH 600        // TODO: this should depend on speed...      LANE_WIDTH/v_max
#define TIME_TO_EXIT_NODE 375          // TODO: this should depend on speed ???
#define TIME_TO_RECHECK 140            // TODO: this should depend on speed...      FORESEE/v_max
#define TIME_TO_TURN 150               // TODO: this should depend on speed ???
#define DELAY_TURNING_LEFT 270         // TODO: BOTH CONSTANTS SHOULD BE THE SAME !!!!!!!!
#define DELAY_TURNING_RIGHT 270        //        and should depend on speed...      2*PI*DIAMETER/(4*v_max)
#define DELAY_TURN_BACK 360            // TODO: this should depend on speed...      PI*DIAMETER/(2*v_max)
#define TURN_BACK_PAUSE 80

// SHARP sensors
#define SHARP_LEFT 14                  // Left sensor in A0
#define SHARP_FRONT 15                 // Front sensor in A1
#define SHARP_RIGHT 16                 // Right sensor in A2
#define SHARP_AREAD_N 100              // Repeat SHARP analogRead N times
#define SHARP_AREAD_DELAY 0            // Delay between readings (ms)
#define MAX_DIST_SIDE 450.             // Max. distance considering a side wall
#define MAX_DIST_FRONT 550.            // Min. distance considering a front wall
#define DIST_TURN_BACK 150.            // Distance from sensor to front wall to turn back
#define DIST_TURNING 325.              // Distance from sensor to front wall to turn either left or right
#define NOM_DIST_SIDE 250              // Nominal distance to a side wall

// PID
#define Kp .3
#define Ki 0.00001
#define Kd 100.

// Configuration
#define MAX_SPEED 127         // Max motor speed  (absolute value)
#define MAX_CORRECTION 40     // Max correction (absolute value)
#define LANE_WIDTH 500.       // Distance between walls in the maze
#define DIAMETER 112.         // Distance between wheels
#define FORESEE 100.          // Front reading distance for side sensors (from reflective object, supposed centered, to the wheels)
#define PI 3.1415926536       // [...]
#define CONFIG_DIST 150.      // Distance for sensors' reading in mm
#define CONFIG_PREC 50.       // Sets the sensors' reading distance precision in mm (+/-)
#define CONFIG_TIME 2000      // Time to confirm configuracion in ms

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
typedef enum position { LEFT, FRONT, RIGHT, BACK };

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
