EESchema Schematic File Version 2  date Wed 14 Nov 2012 05:36:36 AM CET
LIBS:power
LIBS:device
LIBS:transistors
LIBS:conn
LIBS:linear
LIBS:regul
LIBS:74xx
LIBS:cmos4000
LIBS:adc-dac
LIBS:memory
LIBS:xilinx
LIBS:special
LIBS:microcontrollers
LIBS:dsp
LIBS:microchip
LIBS:analog_switches
LIBS:motorola
LIBS:texas
LIBS:intel
LIBS:audio
LIBS:interface
LIBS:digital-audio
LIBS:philips
LIBS:display
LIBS:cypress
LIBS:siliconi
LIBS:opto
LIBS:atmel
LIBS:contrib
LIBS:valves
LIBS:motor_drivers
LIBS:bluetooth
LIBS:power_converter
LIBS:reflective_sensor
LIBS:74
LIBS:microcontroller
LIBS:heracles-cache
EELAYER 25  0
EELAYER END
$Descr A4 11700 8267
encoding utf-8
Sheet 1 4
Title ""
Date "14 nov 2012"
Rev ""
Comp ""
Comment1 ""
Comment2 ""
Comment3 ""
Comment4 ""
$EndDescr
Text Label 7850 4750 0    60   ~ 0
3V3
Wire Wire Line
	10000 4550 9600 4550
Wire Wire Line
	9600 4550 9600 4500
Wire Wire Line
	9600 4500 9200 4500
Wire Wire Line
	10000 4150 9600 4150
Wire Wire Line
	9600 4150 9600 4100
Wire Wire Line
	9600 4100 9200 4100
Wire Wire Line
	4800 4000 3600 4000
Wire Wire Line
	4800 4300 3600 4300
Wire Wire Line
	8200 4000 7000 4000
Wire Wire Line
	8200 4200 7000 4200
Wire Wire Line
	7000 4400 8200 4400
Wire Wire Line
	8200 4400 8200 4450
Wire Wire Line
	8200 4750 7850 4750
Wire Wire Line
	7900 3050 7400 3050
Wire Wire Line
	7400 3050 7400 3400
Wire Wire Line
	7400 3400 7000 3400
Wire Wire Line
	7000 3500 7500 3500
Wire Wire Line
	7500 3500 7500 3200
Wire Wire Line
	7500 3200 7900 3200
Wire Wire Line
	8200 4500 7000 4500
Wire Wire Line
	8200 4300 7000 4300
Wire Wire Line
	8200 4100 7000 4100
Wire Wire Line
	3600 4400 4800 4400
Wire Wire Line
	3600 4100 4800 4100
Wire Wire Line
	9200 4000 9600 4000
Wire Wire Line
	9600 4000 9600 3950
Wire Wire Line
	9600 3950 10000 3950
Wire Wire Line
	9200 4400 9600 4400
Wire Wire Line
	9600 4400 9600 4350
Wire Wire Line
	9600 4350 10000 4350
$Comp
L CONN_2 P?
U 1 1 50A31C57
P 10350 4050
F 0 "P?" V 10300 4050 40  0000 C CNN
F 1 "MOTORA" V 10400 4050 40  0000 C CNN
	1    10350 4050
	1    0    0    -1  
$EndComp
$Comp
L CONN_2 P?
U 1 1 50A31C51
P 10350 4450
F 0 "P?" V 10300 4450 40  0000 C CNN
F 1 "MOTORB" V 10400 4450 40  0000 C CNN
	1    10350 4450
	1    0    0    -1  
$EndComp
$Comp
L MAPLE_MINI U?
U 1 1 50A31370
P 5900 3850
F 0 "U?" H 5150 4950 60  0000 C CNN
F 1 "MAPLE_MINI" H 5350 2750 60  0000 C CNN
	1    5900 3850
	1    0    0    -1  
$EndComp
$Sheet
S 2550 3850 1050 700 
U 50A2F441
F0 "Sensor array" 60
F1 "sensor_array.sch" 60
F2 "2A" O R 3600 4100 60 
F3 "S0" I R 3600 4300 60 
F4 "1A" O R 3600 4000 60 
F5 "S1" I R 3600 4400 60 
$EndSheet
$Sheet
S 7900 2900 950  450 
U 509BC4E1
F0 "Bluetooth" 60
F1 "bluetooth.sch" 60
F2 "UART_RXD" I L 7900 3050 60 
F3 "UART_TXD" O L 7900 3200 60 
$EndSheet
$Sheet
S 8200 3800 1000 1150
U 509B0C31
F0 "Motor driver" 60
F1 "motor_driver.sch" 60
F2 "BO2" O R 9200 4500 60 
F3 "BO1" O R 9200 4400 60 
F4 "AO2" O R 9200 4100 60 
F5 "AO1" O R 9200 4000 60 
F6 "STBY" I L 8200 4750 60 
F7 "AIN1" I L 8200 4300 60 
F8 "AIN2" I L 8200 4200 60 
F9 "PWMA" I L 8200 4500 60 
F10 "PWMB" I L 8200 4400 60 
F11 "BIN2" I L 8200 4000 60 
F12 "BIN1" I L 8200 4100 60 
$EndSheet
$EndSCHEMATC
