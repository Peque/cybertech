/*************************************************************
 CompactQik2s9v1 - basic class to control Pololu's Qik2s9v1
 motor controller (http://www.pololu.com/catalog/product/1110)
 
 This uses the default settings for the motor controller and the 
 Compact Protocol to communicate to it.

 This library also depends on the NewSoftSerial library which
 can be found at: http://arduiniana.org.

 This library is free software; you can redistribute it and/or
 modify it under the terms of the GNU Lesser General Public
 License as published by the Free Software Foundation; either
 version 2.1 of the License, or (at your option) any later version.

 This library is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 Lesser General Public License for more details.

 You should have received a copy of the GNU Lesser General Public
 License along with this library; if not, write to the Free Software
 Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA

 Author:  Eric Fialkowski (eric.fialkowski@gmail.com)
 History:
 Version 1.0	May 8, 2009		Initial code

 ************************************************************/
#ifndef CompactQik2s9v1_H
#define CompactQik2s9v1_H

#include "../NewSoftSerial/NewSoftSerial.h"
#include "WProgram.h"
#include <inttypes.h>

/*
	Bytes used to talk to the motor controller
*/
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

/*
	Bit location for the different errors
*/
#define DATAOVERRUNERRORBIT 3
#define FRAMEERRORBIT 4
#define CRCERRORBIT 5
#define FORMATERRORBIT 6
#define TIMEOUTERRORBIT 7

/*
	Constants for configuration
*/
#define CONFIG_DEVICEID 0
#define CONFIG_PWM 1
#define CONFIG_SHUTDOWN 2
#define CONFIG_TIMEOUT 3

/*
	PWM config values
	HF/LF = High/Low Frequency
	7/8 = 7/8 bits
*/
#define CONFIG_PWM_HF7 0
#define CONFIG_PWM_HF8 1
#define CONFIG_PWM_LF7 2
#define CONFIG_PWM_LF8 3
/*
  PWM constants defined by frequency
*/
#define CONFIG_PWM_31_5KHZ 0
#define CONFIG_PWM_15_7KHZ 1
#define CONFIG_PWM_7_8KHZ 2
#define CONFIG_PWM_3_9KHZ 3

#define CONFIG_OK 0

class CompactQik2s9v1 {
public:
	CompactQik2s9v1(NewSoftSerial *serial, uint8_t resetPin);
	
	void begin();
	
	void motor0Forward(uint8_t speed);
	void motor1Forward(uint8_t speed);
	
	void motor0Reverse(uint8_t speed);
	void motor1Reverse(uint8_t speed);
	
	void stopBothMotors();
	void stopMotor0();
	void stopMotor1();
	
	void motor0Coast();
	void motor1Coast();
	
	uint8_t getFirmwareVersion();

	uint8_t getError();
	
	bool hasDataOverrunError();
	bool hasDataOverrunError(bool fetchError);
	
	bool hasFrameError();
	bool hasFrameError(bool fetchError);
	
	bool hasCRCError();
	bool hasCRCError(bool fetchError);
	
	bool hasFormatError();
	bool hasFormatError(bool fetchError);
	
	bool hasTimeoutError();
	bool hasTimeoutError(bool fetchError);

	uint8_t getDeviceID();
	bool setDeviceID(uint8_t id);
	
	uint8_t getPWMParameter();
	bool setPWMParameter(uint8_t pwmParam);
	
	bool getShutdownOnError();
	bool setShutdownOnError(bool shutdown);
	
	uint8_t getSerialTimeout();
	
private:
	NewSoftSerial *_serial;
	uint8_t _resetPin;
	uint8_t _errByte;
	uint8_t _fwVersion;
	bool errorBitSet(uint8_t bitToCheck, bool fetchError);
	void sendByte(uint8_t byte);
	uint8_t readByte();
};

#endif

