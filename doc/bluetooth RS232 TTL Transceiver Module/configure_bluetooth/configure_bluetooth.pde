
#include <SoftwareSerial.h>

#define CURRENT_BAUD_RATE 9600

 /*
  *  The purpose of this program is to be able to edit the name, the sync key and the baudrate
  *  of the bluetooth device (linvor, 1234 and 9600 by default) through the serial monitor with AT commands.
  *
  *  We should connect the device to the arduino as follows
  * 	VCC --> 5V
  * 	GND --> GND
  * 	RX --> Digital Pin 2
  * 	TX --> Digital Pin 3
  *
  *  If we succesfully connected the bluetooth device we will recieve the "OK" message and
  *  the firmware version as soon as we open the serial monitor. Afterwards we can type
  *  the AT commands we need.
  *
  *  Keep in mind that if we previously modified the baud rate we will
  *  need to update CURRENT_BAUD_RATE to the one that is running the device.
  *
 */

/*
	The supported commands are:

	AT+VERSION Returns the software version of the module
				OKlinvorV1.5
				*
	AT+BAUDx Sets the baud rate of the module
		The command AT+BAUD8 sets the
		baud rate to 115200 and will return the message OK115200
			1 >> 1200
			2 >> 2400
			3 >> 4800
			4 >> 9600 (Default)
			5 >> 19200
			6 >> 38400
			7 >> 57600
			8 >> 115200
			9 >> 230400

	AT+NAMEOpenPilot Sets the name of the module
		Any name can be specified up to 20 characters
		OKsetname
		*
	AT+PINxxxx Sets the pairing password of the device Any 4 digit number can be used, the default pincode is 1234
		OKsetPIN
		*
	AT+PN Sets the parity of the module
		AT+PN >> No parity check
		OK None
*/

SoftwareSerial mySerial(3, 2); // RX, TX

void setup()
{
Serial.begin(CURRENT_BAUD_RATE);
mySerial.begin(CURRENT_BAUD_RATE);

delay(100);
mySerial.print("AT");
delay(300);
mySerial.print("AT+VERSION");
delay(300);
Serial.println("Introduce AT command (Supported commands are in this program code)");
}

void loop()
{
	if (mySerial.available()) {
		Serial.write(mySerial.read());
		if (!mySerial.available())
		    Serial.println();
	}
	if (Serial.available())
	mySerial.write(Serial.read());
}
