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
#define TIME_TO_PASSTHROUGH 900        // TODO: this should depend on speed...      LANE_WIDTH/v_max
#define TIME_TO_RECHECK 50             // TODO: this should depend on speed...      FORESEE/v_max
#define TIME_TO_TURN 250               // TODO: this should depend on speed ???
#define DELAY_EXIT_NODE 250            // TODO: this should depend on speed ???
#define DELAY_TURNING 290              // TODO: this should depend on speed...      2*PI*DIAMETER/(4*v_max)
#define DELAY_TURN_BACK 290            // TODO: this should depend on speed...      PI*DIAMETER/(2*v_max)

// SHARP sensors
#define SHARP_FRONT 14                 // Front sensor in A0
#define SHARP_LEFT 15                  // Left sensor in A1
#define SHARP_RIGHT 16                 // Right sensor in A2
#define SHARP_AREAD_N 50               // Repeat SHARP analogRead N times
#define SHARP_AREAD_DELAY 0            // Delay between readings (ms)
#define MAX_DIST_SIDE 500              // Max. distance considering a side wall
#define MAX_DIST_FRONT 600             // Min. distance considering a front wall
#define DIST_TURN_BACK 150             // Distance from sensor to front wall to turn back
#define NEW_WALL_CONTACT_DIST 300      // Distance at which a new wall should appear when exiting a node
// #define NOM_DIST_SIDE 275           // Nominal distance to a side wall

// PID
#define Kp 0.5
#define Ki 0.0
#define Kd 0.0

// Configuration
#define MAX_SPEED 127         // Max motor speed  (absolute value)
#define LANE_WIDTH 500.0      // Distance between walls in the maze
#define DIAMETER 112.0        // Distance between wheels
#define FORESEE 100.0         // Front reading distance for side sensors (from reflective object, supposed centered, to the wheels)
#define PI 3.141592654        // [...]
#define CONFIG_DIST 150       // Distance for sensors' reading in mm
#define CONFIG_PREC 50        // Sets the sensors' reading distance precision in mm (+/-)
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
typedef enum position { FRONT, LEFT, RIGHT, BACK };

// RGB LED
#define LED_RED 9
#define LED_GREEN 10
#define LED_BLUE 11

// Type for nodes
/*
 * We dicussed about using a dynamic stack or a vector. We're finally
 * using the vector for safe-memory reasons (the current struct uses
 * 1 Byte of memory for each node vs. 16 Bytes for a simple-linked
 * stack and 24 Bytes for a double-linked stack).
 */
typedef struct {
	unsigned char left : 2;
	unsigned char front : 2;
	unsigned char right : 2;
	unsigned char back : 2;
} node;

// Max number of nodes
#define MAX_N_NODES 100


class mje_427101
{
	public:

	private:

};


#endif
